#!/usr/bin/env bash

if ! command -v awscurl &> /dev/null; then
    echo "awscurl could not be found"
    exit 1
fi

# Get the token vendor API Gateway URL
TOKEN=$(awscurl --service execute-api \
    --region us-east-1 \
    -X POST \
    --header "Content-Type: application/json" \
    https://your-api-gateway-url/token
)

# Print the token
echo "Token: $TOKEN"
