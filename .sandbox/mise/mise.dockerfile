# syntax=docker/dockerfile:1
FROM alpine:3.20 AS fetch
ARG MISE_VERSION
RUN apk add --no-cache curl ca-certificates \
    && MISE_INSTALL_PATH=/tmp/mise sh -c "$(curl -fsSL https://mise.run)"

FROM scratch AS content
COPY --from=fetch /tmp/mise /usr/local/bin/mise
