package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws/session"
	v4 "github.com/aws/aws-sdk-go/aws/signer/v4"
)

func main() {
	region := "us-east-1"
	service := "execute-api"
	url := "https://your-api-gateway-url/token"

	sess := session.Must(session.NewSession())
	creds := sess.Config.Credentials

	// Prepare the request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte{}))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create request: %v\n", err)
		os.Exit(1)
	}
	req.Header.Set("Content-Type", "application/json")

	// Sign the request
	signer := v4.NewSigner(creds)
	_, err = signer.Sign(req, nil, service, region, nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to sign request: %v\n", err)
		os.Exit(1)
	}

	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Request failed: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)

	if resp.StatusCode == 200 {
		fmt.Printf("Token: %s\n", body)
		os.Exit(0)
	} else {
		fmt.Fprintf(os.Stderr, "Error: %d %s\n", resp.StatusCode, string(body))
		os.Exit(1)
	}
}
