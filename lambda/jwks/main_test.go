package main

import (
	"context"
	"encoding/json"
	"os"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

// Mock SSM client and environment for testing
func TestHandler_ValidJWKS(t *testing.T) {
	// Set up a valid JWKS in a temp env var
	validJWKS := `{"keys":[{"kty":"RSA","kid":"test","use":"sig","alg":"RS256","n":"abc","e":"AQAB"}]}`
	if err := os.Setenv("JWKS_SSM_PARAM", "test-param"); err != nil {
		t.Fatalf("failed to set JWKS_SSM_PARAM: %v", err)
	}
	defer func() {
		if err := os.Unsetenv("JWKS_SSM_PARAM"); err != nil {
			t.Fatalf("failed to unset JWKS_SSM_PARAM: %v", err)
		}
	}()

	// Patch ssmClient.GetParameter to return validJWKS
	origGetParameter := getParameter
	getParameter = func(paramName string) (string, error) {
		return validJWKS, nil
	}
	defer func() { getParameter = origGetParameter }()

	event := events.APIGatewayProxyRequest{}
	resp, err := handler(context.Background(), event)
	if err != nil {
		t.Fatalf("handler returned error: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
	var jwks map[string]interface{}
	if err := json.Unmarshal([]byte(resp.Body), &jwks); err != nil {
		t.Errorf("response is not valid JSON: %v", err)
	}
}

func TestHandler_InvalidJWKS(t *testing.T) {
	invalidJWKS := `not-json`
	if err := os.Setenv("JWKS_SSM_PARAM", "test-param"); err != nil {
		t.Fatalf("failed to set JWKS_SSM_PARAM: %v", err)
	}
	defer func() {
		if err := os.Unsetenv("JWKS_SSM_PARAM"); err != nil {
			t.Fatalf("failed to unset JWKS_SSM_PARAM: %v", err)
		}
	}()

	origGetParameter := getParameter
	getParameter = func(paramName string) (string, error) {
		return invalidJWKS, nil
	}
	defer func() { getParameter = origGetParameter }()

	event := events.APIGatewayProxyRequest{}
	resp, err := handler(context.Background(), event)
	if err != nil {
		t.Fatalf("handler returned error: %v", err)
	}
	if resp.StatusCode != 500 {
		t.Errorf("expected 500, got %d", resp.StatusCode)
	}
}

func TestHandler_SSMError(t *testing.T) {
	if err := os.Setenv("JWKS_SSM_PARAM", "test-param"); err != nil {
		t.Fatalf("failed to set JWKS_SSM_PARAM: %v", err)
	}
	defer func() {
		if err := os.Unsetenv("JWKS_SSM_PARAM"); err != nil {
			t.Fatalf("failed to unset JWKS_SSM_PARAM: %v", err)
		}
	}()

	origGetParameter := getParameter
	getParameter = func(paramName string) (string, error) {
		return "", os.ErrNotExist
	}
	defer func() { getParameter = origGetParameter }()

	event := events.APIGatewayProxyRequest{}
	resp, err := handler(context.Background(), event)
	if err != nil {
		t.Fatalf("handler returned error: %v", err)
	}
	if resp.StatusCode != 500 {
		t.Errorf("expected 500, got %d", resp.StatusCode)
	}
}
