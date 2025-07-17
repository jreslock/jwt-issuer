package main

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"encoding/json"
	"os"
	"strings"
	"sync"
	"testing"

	"github.com/aws/aws-lambda-go/events"
	"github.com/golang-jwt/jwt/v5"
)

func TestExtractRoleName(t *testing.T) {
	tests := []struct {
		arn      string
		expected string
	}{
		{"arn:aws:sts::123456789012:assumed-role/snowflake-app/MySession", "snowflake-app"},
		{"arn:aws:sts::123456789012:assumed-role/role-name/session", "role-name"},
		{"arn:aws:iam::123456789012:user/myuser", ""},
		{"", ""},
	}
	for _, tt := range tests {
		if got := extractRoleName(tt.arn); got != tt.expected {
			t.Errorf("extractRoleName(%q) = %q, want %q", tt.arn, got, tt.expected)
		}
	}
}

func TestExtractSessionName(t *testing.T) {
	tests := []struct {
		arn      string
		expected string
	}{
		{"arn:aws:sts::123456789012:assumed-role/snowflake-app/MySession", "MySession"},
		{"arn:aws:sts::123456789012:assumed-role/role-name/session", "session"},
		{"arn:aws:iam::123456789012:user/myuser", "myuser"},
		{"", ""},
	}
	for _, tt := range tests {
		if got := extractSessionName(tt.arn); got != tt.expected {
			t.Errorf("extractSessionName(%q) = %q, want %q", tt.arn, got, tt.expected)
		}
	}
}

func TestSnowflakeUsernameFromEmail(t *testing.T) {
	tests := []struct {
		email    string
		expected string
	}{
		{"test@test.com", "TEST"},
		{"alice@example.com", "ALICE"},
		{"bob", "BOB"},
		{"", ""},
	}
	for _, tt := range tests {
		if got := snowflakeUsernameFromEmail(tt.email); got != tt.expected {
			t.Errorf("snowflakeUsernameFromEmail(%q) = %q, want %q", tt.email, got, tt.expected)
		}
	}
}

func TestHandler_SSOUser(t *testing.T) {
	privKey := generateTestPrivateKey()
	signingKey = privKey
	signingKeyErr = nil
	if err := os.Setenv("SIGNING_KEY_SECRET_ARN", "test/path"); err != nil {
		t.Fatalf("failed to set SIGNING_KEY_SECRET_ARN: %v", err)
	}
	if err := os.Setenv("JWT_ISSUER_URL", "https://test-issuer"); err != nil {
		t.Fatalf("failed to set JWT_ISSUER_URL: %v", err)
	}
	if err := os.Setenv("AUDIENCE", "https://test-audience"); err != nil {
		t.Fatalf("failed to set AUDIENCE: %v", err)
	}
	t.Cleanup(func() {
		if err := os.Unsetenv("SIGNING_KEY_SECRET_ARN"); err != nil {
			t.Fatalf("failed to unset SIGNING_KEY_SECRET_ARN: %v", err)
		}
		if err := os.Unsetenv("JWT_ISSUER_URL"); err != nil {
			t.Fatalf("failed to unset JWT_ISSUER_URL: %v", err)
		}
		if err := os.Unsetenv("AUDIENCE"); err != nil {
			t.Fatalf("failed to unset AUDIENCE: %v", err)
		}
	})

	event := events.APIGatewayProxyRequest{
		RequestContext: events.APIGatewayProxyRequestContext{
			Identity: events.APIGatewayRequestIdentity{
				UserArn: "arn:aws:sts::123456789012:assumed-role/AWSReservedSSO_admin_20e0242991ced029/someone@example.com",
			},
		},
	}
	resp, err := handler(context.Background(), event)
	if err != nil {
		t.Fatalf("handler returned error: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("handler returned status %d, want 200", resp.StatusCode)
	}
	if !strings.Contains(resp.Body, "token") {
		t.Errorf("handler response body missing token: %s", resp.Body)
	}

	var tr TokenResponse
	if err := json.Unmarshal([]byte(resp.Body), &tr); err != nil {
		t.Fatalf("failed to unmarshal response: %v", err)
	}
	tokenStr := tr.Token

	pubKey := &privKey.PublicKey
	parsedToken, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			t.Fatalf("unexpected signing method: %v", token.Header["alg"])
		}
		return pubKey, nil
	})
	if err != nil {
		t.Fatalf("failed to parse/verify JWT: %v", err)
	}
	if !parsedToken.Valid {
		t.Error("token is not valid")
	}
}

func TestHandler_WorkloadRole(t *testing.T) {
	// Set up a fake signing key for testing
	signingKey = generateTestPrivateKey()
	signingKeyErr = nil
	if err := os.Setenv("SIGNING_KEY_SECRET_ARN", "test/path"); err != nil {
		t.Fatalf("failed to set SIGNING_KEY_SECRET_ARN: %v", err)
	}
	if err := os.Setenv("JWT_ISSUER_URL", "https://test-issuer"); err != nil {
		t.Fatalf("failed to set JWT_ISSUER_URL: %v", err)
	}
	if err := os.Setenv("AUDIENCE", "https://test-audience"); err != nil {
		t.Fatalf("failed to set AUDIENCE: %v", err)
	}
	t.Cleanup(func() {
		if err := os.Unsetenv("SIGNING_KEY_SECRET_ARN"); err != nil {
			t.Fatalf("failed to unset SIGNING_KEY_SECRET_ARN: %v", err)
		}
		if err := os.Unsetenv("JWT_ISSUER_URL"); err != nil {
			t.Fatalf("failed to unset JWT_ISSUER_URL: %v", err)
		}
		if err := os.Unsetenv("AUDIENCE"); err != nil {
			t.Fatalf("failed to unset AUDIENCE: %v", err)
		}
	})

	event := events.APIGatewayProxyRequest{
		RequestContext: events.APIGatewayProxyRequestContext{
			Identity: events.APIGatewayRequestIdentity{
				UserArn: "arn:aws:sts::123456789012:assumed-role/my-ecs-task-role/TaskSession",
			},
		},
	}
	resp, err := handler(context.Background(), event)
	if err != nil {
		t.Fatalf("handler returned error: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("handler returned status %d, want 200", resp.StatusCode)
	}
	if !strings.Contains(resp.Body, "token") {
		t.Errorf("handler response body missing token: %s", resp.Body)
	}
}

func TestGetSigningKey_NoEnv(t *testing.T) {
	if err := os.Unsetenv("SIGNING_KEY_SECRET_ARN"); err != nil {
		t.Fatalf("failed to unset SIGNING_KEY_SECRET_ARN: %v", err)
	}
	signingKey = nil
	signingKeyOnce = sync.Once{} // reset
	_, err := getSigningKeyFromSecretsManager()
	if err == nil {
		t.Error("expected error when SIGNING_KEY_SECRET_ARN is not set")
	}
}

func generateTestPrivateKey() *rsa.PrivateKey {
	key, err := rsa.GenerateKey(rand.Reader, 4096)
	if err != nil {
		panic(err)
	}
	return key
}
