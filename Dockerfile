FROM ubuntu:20.04

# Install necessary tools
RUN apt-get update && \
    apt-get install -y curl jq git

# Install GitHub Actions Runner
RUN mkdir -p /actions-runner && \
    cd /actions-runner && \
    curl -L --fail -O https://github.com/actions/runner/releases/download/v2.305.0/actions-runner-linux-x64-2.305.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.305.0.tar.gz


WORKDIR /actions-runner

COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
