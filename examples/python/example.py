#! /usr/bin/env python3

import sys
import boto3
from requests_aws4auth import AWS4Auth
import requests

def main():
    REGION = 'us-east-1'
    SERVICE = 'execute-api'
    URL = 'https://your-api-gateway-url/token'

    # Get AWS credentials (from environment or config)
    session = boto3.Session()
    credentials = session.get_credentials().get_frozen_credentials()

    auth = AWS4Auth(
        credentials.access_key,
        credentials.secret_key,
        REGION,
        SERVICE,
        session_token=credentials.token
    )

    headers = {'Content-Type': 'application/json'}

    response = requests.post(URL, auth=auth, headers=headers)

    if response.status_code == 200:
        print('Token:', response.text)
        sys.exit(0)
    else:
        print(f'Error: {response.status_code} {response.text}', file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
