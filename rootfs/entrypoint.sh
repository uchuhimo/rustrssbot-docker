#!/bin/sh

/clash &

HTTP_PROXY=http://127.0.0.1:12080 \
HTTPS_PROXY=http://127.0.0.1:12080 \
RSSBOT_DONT_PROXY_FEEDS=1 \
/usr/bin/rssbot --min-interval $MIN_INTERVAL -d $DATAFILE $TELEGRAM_BOT_TOKEN