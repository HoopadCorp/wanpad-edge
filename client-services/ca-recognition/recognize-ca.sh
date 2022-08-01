#!/bin/bash

cp /etc/wanpad/ca-recognition/WANPAD.crt /usr/local/share/ca-certificates/WANPAD.crt
cp /etc/wanpad/ca-recognition/HOOPAD.crt /usr/local/share/ca-certificates/HOOPAD.crt
update-ca-certificates
