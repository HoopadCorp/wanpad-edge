#!/bin/python3

import os
from decouple import config
import netifaces
import requests
import socket
import sys
import json


def get_interfaces():
    interfaces = netifaces.interfaces()
    out_interfaces = {}

    for interface in interfaces:
        addrs = netifaces.ifaddresses(interface)
        if netifaces.AF_INET in addrs.keys():
            out_interfaces[interface] = addrs[netifaces.AF_INET]

    return out_interfaces


def client_program():
    with open('/etc/ssh/ssh_host_ecdsa_key.pub', 'r') as f:
        dsf = f.read().split(' ')[1]
        data = {"interfaces": json.dumps(get_interfaces()),
                "hostname": socket.gethostname(),
                "token": config('TOKEN'),
                "dsf": dsf}
        url = config('URI')
        request_tourl = requests.post(url, verify=False, data=data, timeout=6)
        if request_tourl.status_code == 400:
            print(request_tourl.text)
            print(sys.exit(1))
            return sys.exit(1)
        elif request_tourl.status_code == 200:
            public_key = request_tourl.text
            os.system(f"sudo echo {public_key} > /home/hoopad/.ssh/authorized_keys")
            print(sys.exit(0))
            return sys.exit(0)


if __name__ == "__main__":
    client_program()
