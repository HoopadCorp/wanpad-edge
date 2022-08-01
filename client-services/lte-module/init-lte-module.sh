#!/bin/sh

set -eux pipefail


ifname=`qmicli --device=/dev/cdc-wdm0 --device-open-proxy --get-wwan-iface`

ip link set ${ifname} down

echo Y > /sys/class/net/${ifname}/qmi/raw_ip

ip link set ${ifname} up

qmicli --device=/dev/cdc-wdm0 --device-open-proxy --wds-start-network="ip-type=4,apn=mtnirancell" --client-no-release-cid


udhcpc -q -f -n -i ${ifname}
