#!/bin/sh

# This shell script ensures that strongswan has the exact configuration we want at any time.

SWANCTL_DIR="/usr/local/etc/wanpad/swanctl/conf.d"

if ! $(grep -q "include ${SWANCTL_DIR}/\*.conf" /etc/swanctl/swanctl.conf)
then
    echo "include ${SWANCTL_DIR}/*.conf" >> /etc/swanctl/swanctl.conf
fi
