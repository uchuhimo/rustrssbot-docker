FROM ekidd/rust-musl-builder:nightly-2021-02-13 AS rssbot_builder

ADD https://api.github.com/repos/iovxw/rssbot/git/refs/heads/master /rssbot-version.json
RUN git clone --depth 1 https://github.com/iovxw/rssbot.git .
RUN sudo chown -R rust:rust /home/rust
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release

FROM golang:alpine as clash_builder

RUN apk add --no-cache make git && \
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
WORKDIR /clash-src
ADD https://api.github.com/repos/Dreamacro/clash/git/refs/heads/master /clash-version.json
RUN git clone --depth 1 https://github.com/Dreamacro/clash.git .
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go mod download && \
    make docker && \
    mv ./bin/clash-docker /clash

FROM alpine:latest

RUN apk --no-cache add ca-certificates
COPY --from=rssbot_builder \
    /home/rust/src/target/x86_64-unknown-linux-musl/release/rssbot \
    /usr/bin/
COPY --from=clash_builder /Country.mmdb /root/.config/clash/
COPY --from=clash_builder /clash /
ENV DATAFILE="/rustrssbot/rssbot.json"
ENV TELEGRAM_BOT_TOKEN=""
ENV MIN_INTERVAL="300"
ADD rootfs /
VOLUME /rustrssbot
ENTRYPOINT ["/entrypoint.sh"]