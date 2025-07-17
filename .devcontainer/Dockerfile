# syntax=docker/dockerfile:1

FROM public.ecr.aws/docker/library/golang:1.24.5-bookworm

# Add tfenv to PATH for the user
ENV PATH="/root/.tenv:/root/.local/bin:/$(go env GOPATH)/bin:$PATH"

RUN <<-EOF
    DEBIAN_FRONTEND=noninteractive apt-get -qq update < /dev/null > /dev/null && apt-get -qq install --no-install-recommends ca-certificates curl < /dev/null > /dev/null
    echo 'deb [trusted=yes] https://apt.fury.io/caarlos0/ /' | tee /etc/apt/sources.list.d/caarlos0.list
    echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | tee /etc/apt/sources.list.d/goreleaser.list
    DEBIAN_FRONTEND=noninteractive apt-get -qq update < /dev/null > /dev/null
    apt-get -qq install --no-install-recommends \
        git \
        goreleaser \
        jq \
        wget \
        pipx \
        svu \
        unzip \
        zsh  < /dev/null > /dev/null
    rm -rf /var/lib/apt/lists/*
    pipx install pre-commit
    pipx install go-task-bin

    ARCH=$(dpkg --print-architecture)

    # cosign
    LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | jq -r .tag_name | tr -d "v")
    curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_${ARCH}.deb"
    dpkg -i cosign_${LATEST_VERSION}_${ARCH}.deb
    rm -fr cosign_${LATEST_VERSION}_${ARCH}.deb

    # tenv
    LATEST_VERSION=$(curl --silent https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name)
    curl -O -L "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${LATEST_VERSION}_${ARCH}.deb"
    dpkg -i "tenv_${LATEST_VERSION}_${ARCH}.deb"
    rm -fr "tenv_${LATEST_VERSION}_${ARCH}.deb"

    # tofu
    tenv tofu install 1.10.1
    tenv tofu use 1.10.1

    # terraform-docs
    curl -sSL -o terraform-docs.tar.gz https://terraform-docs.io/dl/v0.20.0/terraform-docs-v0.20.0-linux-${ARCH}.tar.gz
    tar xzf terraform-docs.tar.gz -C /usr/local/bin terraform-docs
    chmod +x /usr/local/bin/terraform-docs
    rm terraform-docs.tar.gz

    # goimports
    go install golang.org/x/tools/cmd/goimports@v0.31.0 < /dev/null > /dev/null

    # golangci-lint
    curl -sSL -o golangci-lint.tar.gz https://github.com/golangci/golangci-lint/releases/download/v2.1.2/golangci-lint-2.1.2-linux-${ARCH}.tar.gz
    tar --strip-components=1 -xzf golangci-lint.tar.gz -C /usr/local/bin golangci-lint-2.1.2-linux-${ARCH}/golangci-lint
    chmod +x /usr/local/bin/golangci-lint
    rm -fr golangci-lint.tar.gz

    # git-chglog
    curl -sSL -o git-chglog.tar.gz https://github.com/git-chglog/git-chglog/releases/download/v0.15.4/git-chglog_0.15.4_linux_${ARCH}.tar.gz
    tar xzf git-chglog.tar.gz -C /usr/local/bin git-chglog
    chmod +x /usr/local/bin/git-chglog
    rm git-chglog.tar.gz

    # oras
    ORAS_VERSION="1.2.3"
    curl -sSL -o oras.tar.gz https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_${ARCH}.tar.gz
    tar xzf oras.tar.gz -C /usr/local/bin oras
    chmod +x /usr/local/bin/oras
    rm -fr oras.tar.gz
EOF
# Set working directory
WORKDIR /workspace
