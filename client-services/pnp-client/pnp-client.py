import os
from decouple import config
import netifaces
import requests
import socket
import sys
import json
import configparser


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
            return sys.exit(1)
        elif request_tourl.status_code == 200:
            print(request_tourl.text)
        elif request_tourl.status_code == 201:
            response = request_tourl.json()
            public_key = response.get('cspu')
            os.system(f"sudo echo {public_key} > /home/hoopad/.ssh/authorized_keys")
            gateway = response.get('gateway')

            # if gateway exist in response then send a request to gateway and create wireguard.conf file
            if bool(gateway):
                ip_address, port, token = gateway.values()
                gateway_address = f"{ip_address}:{port}"
                scheme = 'http' if url.startswith('http') else 'https'
                #client_request_to_gateway(scheme, gateway_address, token, dsf)
        else:
            print("Error Code:", request_tourl.status_code)
        return sys.exit(0)


def client_request_to_gateway(scheme, gateway_address, token, dsf):
    result = requests.post(f"{scheme}://{gateway_address}/gateway", json={"token": token, "dsf": dsf})

    if result.status_code == 200:
        result = result.json()
        _config = configparser.ConfigParser()
        _config['Interface'] = {"Address": result.get('address'), "PrivateKey": result.get('device_private_key'),
                                "Endpoint": result.get('endpoint')}

        _config['Peer'] = {"PublicKey": result.get("gateway_public_key"), "AllowedIPs": result.get('allowed_ips')}

        wg_file = "wg0.conf"
        with open(f"./{wg_file}", "w") as wgconf:
            _config.write(wgconf)
        print(result)
        rm_old_wg0_cmd = f"sudo wg set wg0 peer {result.get('gateway_public_key')} remove ; sudo ip link del wg0"

        add_new_wg0_cmd = f"sudo wg-quick up ./{wg_file}"
        print(f"Try To Delete The Old Ones: {os.system(rm_old_wg0_cmd)}")
        os.system(add_new_wg0_cmd)
        controller = requests.post(f"{config('CONTROLLER_PLUG_PLAY_URL')}/wanpad/api/v1/gateway/confirm_wireguard",
                                   data={'dsf': dsf, 'ipv6': result.get('device_ipv6')})

        if controller.status_code == 200:
            print('Done')
        else:
            print(controller.text)
    else:
        print("Error Code:", result.status_code)


if __name__ == "__main__":
    client_program()
