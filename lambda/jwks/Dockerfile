# syntax=docker/dockerfile:1

FROM public.ecr.aws/lambda/provided:al2023

ARG TARGETARCH
ARG TARGETOS

COPY ../../artifacts/jwks-$TARGETOS-$TARGETARCH ./jwks

ENTRYPOINT ["./jwks"]
