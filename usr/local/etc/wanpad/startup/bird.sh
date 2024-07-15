#!/bin/sh

# This shell script ensures that bird has the exact configuration we want at any time.

BIRD_DIR="/usr/local/etc/wanpad/bird/conf.d"

if ! $(grep -q "include \"${BIRD_DIR}/\*.conf\";" /etc/bird/bird.conf)
then
    echo "include \"${BIRD_DIR}/*.conf\";" >> /etc/bird/bird.conf
fi
