FROM ekidd/rust-musl-builder:nightly-2020-08-26 AS builder
ADD https://api.github.com/repos/iovxw/rssbot/git/refs/heads/master rssbot-version.json
RUN git clone --depth 1 https://github.com/iovxw/rssbot.git
WORKDIR rssbot
RUN sudo chown -R rust:rust /home/rust
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder \
    /home/rust/src/rssbot/target/x86_64-unknown-linux-musl/release/rssbot \
    /usr/local/bin/
ENV DATAFILE="/rustrssbot/rssbot.json"
ENV TELEGRAM_BOT_TOKEN=""
ENV MIN_INTERVAL="300"
VOLUME /rustrssbot
ENTRYPOINT /usr/local/bin/rssbot --min-interval $MIN_INTERVAL -d $DATAFILE $TELEGRAM_BOT_TOKEN