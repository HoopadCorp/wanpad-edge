#!/bin/bash

source .env
openvpn --config /etc/wanpad/openvpn/$client_name.ovpn


