package main

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
)

var (
	paramName    = os.Getenv("JWKS_SSM_PARAM")
	logger       *slog.Logger
	getParameter = func(paramName string) (string, error) {
		sess := session.Must(session.NewSession())
		ssmClient := ssm.New(sess)
		param, err := ssmClient.GetParameter(&ssm.GetParameterInput{
			Name:           aws.String(paramName),
			WithDecryption: aws.Bool(false),
		})
		if err != nil {
			return "", err
		}
		return *param.Parameter.Value, nil
	}
)

func init() {
	h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo})
	logger = slog.New(h)
	logger.Info("Lambda cold start: logger initialized")
}

func handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	jwksStr, err := getParameter(paramName)
	if err != nil {
		logger.Error("Failed to get JWKS from SSM", "error", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       `{"error":"could not fetch JWKS"}`,
		}, nil
	}

	// Validate that it's valid JSON
	var jwks map[string]interface{}
	if err := json.Unmarshal([]byte(jwksStr), &jwks); err != nil {
		logger.Error("Invalid JWKS JSON", "error", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       `{"error":"invalid JWKS format"}`,
		}, nil
	}

	logger.Info("Successfully fetched JWKS from SSM")
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       jwksStr,
	}, nil
}

func main() {
	lambda.Start(handler)
}
