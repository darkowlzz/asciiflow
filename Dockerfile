ARG BAZELISK_VERSION=1.12.0
ARG BAZELISK_URL=https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64

# Build based on https://github.com/lewish/asciiflow/blob/8b9148f6c639f27e09f226ef173828744a2fb645/.github/workflows/deploy.yaml
FROM ubuntu:20.04 AS builder
ARG BAZELISK_URL
RUN apt update && apt install wget -y
RUN wget ${BAZELISK_URL} -O /usr/local/bin/bazelisk && \
	chmod +x /usr/local/bin/bazelisk
COPY ./ /asciiflow
WORKDIR /asciiflow
RUN bazelisk build site/...

# Serve with caddy as the web server.
FROM caddy:2
COPY --from=builder /asciiflow/bazel-bin/site /site
WORKDIR /site
CMD caddy file-server
