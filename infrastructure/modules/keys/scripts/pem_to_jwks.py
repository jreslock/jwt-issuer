#!/usr/bin/env python3
import sys, json, base64
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

def b64url(b):
    return base64.urlsafe_b64encode(b).rstrip(b'=').decode('ascii')

def main():
    args = json.load(sys.stdin)
    pem = args["public_key_pem"].encode()
    pub = serialization.load_pem_public_key(pem, backend=default_backend())
    numbers = pub.public_numbers()
    jwk = {
        "kty": "RSA",
        "kid": args.get("kid", "default"),
        "use": "sig",
        "alg": "RS256",
        "n": b64url(numbers.n.to_bytes((numbers.n.bit_length() + 7) // 8, 'big')),
        "e": b64url(numbers.e.to_bytes((numbers.e.bit_length() + 7) // 8, 'big')),
    }
    print(json.dumps({"jwks_json": json.dumps({"keys": [jwk]})}))

if __name__ == "__main__":
    main()
