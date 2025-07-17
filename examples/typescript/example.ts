// Required packages:
// npm install @aws-sdk/credential-providers @aws-sdk/signature-v4 @aws-sdk/protocol-http @aws-crypto/sha256-js node-fetch
// For Node.js types: npm install --save-dev @types/node

import { Sha256 } from "@aws-crypto/sha256-js";
import { fromIni } from "@aws-sdk/credential-providers";
import { HttpRequest } from "@aws-sdk/protocol-http";
import { SignatureV4 } from "@aws-sdk/signature-v4";
import fetch from "node-fetch";

const REGION = "us-east-1";
const SERVICE = "execute-api";
const URL = "https://your-api-gateway-url/token";

async function main() {
    // Get AWS credentials (from default profile or environment)
    const credentials = await fromIni()();

    // Prepare the HTTP request
    const request = new HttpRequest({
        method: "POST",
        protocol: "https:",
        path: "/v1/token",
        hostname: "token-vendor.om1.com",
        headers: {
            "content-type": "application/json",
        },
        body: "",
    });

    // Sign the request
    const signer = new SignatureV4({
        credentials,
        region: REGION,
        service: SERVICE,
        sha256: Sha256,
    });
    const signedRequest = await signer.sign(request);

    // Convert signed request to fetch options
    const fetchOptions = {
        method: signedRequest.method,
        headers: signedRequest.headers,
        body: signedRequest.body,
    };

    try {
        const response = await fetch(URL, fetchOptions);
        const text = await response.text();
        if (response.ok) {
            console.log("Token:", text);
            process.exit(0);
        } else {
            console.error(`Error: ${response.status} ${text}`);
            process.exit(1);
        }
    } catch (err) {
        console.error("Request failed:", err);
        process.exit(1);
    }
}

main();
