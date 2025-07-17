package main

import (
	"context"
	"crypto/rsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"log/slog"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/golang-jwt/jwt/v5"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

var (
	signingKey     *rsa.PrivateKey
	signingKeyOnce sync.Once
	signingKeyErr  error
	logger         *slog.Logger
)

func init() {
	// Set up slog logger with JSON handler for structured logs
	h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo})
	logger = slog.New(h)
	logger.Info("Lambda cold start: logger initialized")
}

// Fetch the signing key from AWS Secrets Manager
func getSigningKeyFromSecretsManager() (*rsa.PrivateKey, error) {
	if signingKey != nil {
		return signingKey, nil
	}
	signingKeyOnce.Do(func() {
		secretArn := os.Getenv("SIGNING_KEY_SECRET_ARN")
		if secretArn == "" {
			logger.Error("SIGNING_KEY_SECRET_ARN env var not set")
			signingKeyErr = os.ErrNotExist
			return
		}
		logger.Info("Fetching signing key from Secrets Manager", "secret_arn", secretArn)
		sess := session.Must(session.NewSession())
		secretsClient := secretsmanager.New(sess)
		secretValue, err := secretsClient.GetSecretValue(&secretsmanager.GetSecretValueInput{
			SecretId: aws.String(secretArn),
		})
		if err != nil {
			logger.Error("Failed to fetch signing key from Secrets Manager", "error", err)
			signingKeyErr = err
			return
		}
		var secretString string
		if secretValue.SecretString != nil {
			secretString = *secretValue.SecretString
		} else if secretValue.SecretBinary != nil {
			secretString = string(secretValue.SecretBinary)
		} else {
			logger.Error("Secret value missing string or binary data", "secret_arn", secretArn)
			signingKeyErr = os.ErrInvalid
			return
		}

		// Parse the secret as JSON and extract the private_key field
		type secretPayload struct {
			PrivateKey string `json:"private_key"`
			PublicKey  string `json:"public_key"`
		}
		var payload secretPayload
		err = json.Unmarshal([]byte(secretString), &payload)
		if err != nil {
			logger.Error("Failed to unmarshal secret JSON", "error", err)
			signingKeyErr = err
			return
		}
		if payload.PrivateKey == "" {
			logger.Error("private_key field missing in secret JSON")
			signingKeyErr = os.ErrInvalid
			return
		}

		block, _ := pem.Decode([]byte(payload.PrivateKey))
		if block == nil {
			logger.Error("Failed to decode signing key from Secrets Manager")
			signingKeyErr = os.ErrInvalid
			return
		}
		priv, err := x509.ParsePKCS1PrivateKey(block.Bytes)
		if err != nil {
			// Try PKCS#8 as a fallback
			key, err2 := x509.ParsePKCS8PrivateKey(block.Bytes)
			if err2 != nil {
				logger.Error("Failed to parse signing key from Secrets Manager", "error", err)
				signingKeyErr = err
				return
			}
			var ok bool
			signingKey, ok = key.(*rsa.PrivateKey)
			if !ok {
				logger.Error("Parsed key is not an RSA private key")
				signingKeyErr = os.ErrInvalid
				return
			}
		} else {
			signingKey = priv
		}
		logger.Info("Signing key successfully fetched from Secrets Manager")
	})
	return signingKey, signingKeyErr
}

type TokenResponse struct {
	Token string `json:"token"`
}

// Extracts the IAM role name from an assumed-role ARN
func extractRoleName(arn string) string {
	// Example: arn:aws:sts::123456789012:assumed-role/snowflake-app/MySession
	parts := strings.Split(arn, ":assumed-role/")
	if len(parts) < 2 {
		return ""
	}
	roleParts := strings.SplitN(parts[1], "/", 2)
	return roleParts[0] // returns "snowflake-app"
}

// Extracts the session name (email for SSO users) from an assumed-role ARN
func extractSessionName(arn string) string {
	parts := strings.Split(arn, "/")
	if len(parts) < 2 {
		return ""
	}
	return parts[len(parts)-1]
}

// Converts email to Snowflake username (first part, uppercased)
func snowflakeUsernameFromEmail(email string) string {
	parts := strings.SplitN(email, "@", 2)
	if len(parts) == 0 {
		return ""
	}
	return strings.ToUpper(parts[0])
}

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	identity := event.RequestContext.Identity
	logger.Info("Handling request", "user_arn", identity.UserArn, "account_id", identity.AccountID)

	arn := identity.UserArn
	key, err := getSigningKeyFromSecretsManager()
	if err != nil {
		logger.Error("Signing key unavailable", "error", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       `{"error":"signing key unavailable"}`,
		}, nil
	}

	issuer := os.Getenv("JWT_ISSUER_URL")
	if issuer == "" {
		logger.Error("JWT_ISSUER_URL env var not set")
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       `{"error":"JWT_ISSUER_URL env var not set"}`,
		}, nil
	}
	audience := os.Getenv("AUDIENCE")
	if audience == "" {
		logger.Error("AUDIENCE env var not set")
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       `{"error":"AUDIENCE env var not set"}`,
		}, nil
	}

	var (
		subject      string
		allowedRoles []string
	)

	if strings.Contains(arn, "AWSReservedSSO_") {
		// SSO user
		sessionName := extractSessionName(arn)
		logger.Info("Detected SSO user", "session_name", sessionName)
		// Use the first part of the email (uppercased) as the Snowflake username
		subject = snowflakeUsernameFromEmail(sessionName)
		allowedRoles = []string{subject}
	} else {
		// Workload (IAM role)
		roleName := extractRoleName(arn)
		logger.Info("Detected workload role", "role_name", roleName)
		// Use the uppercased IAM role name as the Snowflake user
		subject = strings.ToUpper(roleName)
		allowedRoles = []string{subject}
	}

	// Build JWT claims for Snowflake
	claims := jwt.MapClaims{
		"iss":   issuer,
		"sub":   subject,
		"aud":   audience,
		"scope": "session:role-any",
		"iat":   time.Now().Unix(),
		"exp":   time.Now().Add(15 * time.Minute).Unix(),
	}
	logger.Info("JWT claims created", "claims", claims)

	// Sign the token using the RSA256 algorithm
	// Do not use HS256 as it is not supported by Snowflake
	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	signedToken, err := token.SignedString(key)
	if err != nil {
		logger.Error("Token signing failed", "error", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       `{"error":"token signing failed"}`,
		}, nil
	}

	logger.Info("Token successfully signed", "subject", subject, "roles", allowedRoles)
	resp := TokenResponse{Token: signedToken}
	respBytes, _ := json.Marshal(resp)

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(respBytes),
	}, nil
}

func main() {
	logger.Info("Starting Lambda handler")
	lambda.Start(handler)
}
