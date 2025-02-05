FROM ubuntu:20.04

RUN apt-get update && apt-get install -y curl jq git

# Install GitHub Actions Runner
ENV RUNNER_VERSION=2.303.0
RUN curl -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | tar xz

# Set up entrypoint
COPY entrypoint.sh /entrypoint.sh

# RUN ["/bin/sh", "-c", "chmod +x /entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
