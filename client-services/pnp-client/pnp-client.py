import os
from decouple import config
import netifaces
import requests
import socket
import sys
import json
import configparser
import yaml

filebeat_data = {'filebeat.config': {'modules': {'path': '${path.config}/modules.d/*.yml', 'reload.enabled': False}},
                 'filebeat.modules': [
                     {'module': 'system', 'syslog': {'enabled': True, 'var.paths': ['/var/log/syslog*']},
                      'auth': {'enabled': True, 'var.paths': ['/var/log/auth.log*']}}, {'module': 'iptables',
                                                                                        'log': {'enabled': True,
                                                                                                'var.paths': [
                                                                                                    '/var/log/kern.log*'],
                                                                                                'var.input': 'file'}},
                     {'module': 'netflow',
                      'log': {'enabled': True, 'var': {'netflow_host': '0.0.0.0', 'netflow_port': 2055}}}],
                 'output.elasticsearch': {
                     'ssl.certificate_authorities': ['/usr/local/share/ca-certificates/WANPAD.crt'], 'hosts': 'ENV_ME'},
                'setup.ilm.enabled': True,
                 'setup.ilm.rollover_alias': 'filebeat', 'setup.ilm.pattern': '{now/d}-000001',
                 'output.elasticsearch.index': 'filebeat-%{[agent.version]}-%{+yyyy.MM.dd}',
                 'setup.template.name': 'filebeat', 'setup.template.pattern': 'filebeat-*'}


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
        request_to_url = requests.post(url, verify=False, data=data, timeout=6)
        if request_to_url.status_code == 400:
            print(request_to_url.text)
            return sys.exit(1)
        elif request_to_url.status_code == 200:
            print(request_to_url.text)
        elif request_to_url.status_code == 201:
            response = request_to_url.json()
            public_key = response.get('cspu')
            os.system(f"sudo echo {public_key} > /home/hoopad/.ssh/authorized_keys")
            gateway = response.get('gateway')

            filebeat = response.get('filebeat')
            filebeat_data['output.elasticsearch']['hosts'] = filebeat.get('hosts')
            filebeat_data['output.elasticsearch']['ssl.certificate_authorities'] = filebeat.get('ssl_crt')
            filebeat_data['output.elasticsearch.api_key'] = f"{filebeat.get('id')}:{filebeat.get('api_key')}"

            create_file_beat(filebeat_data, filebeat.get('conf_address'))

            # if gateway exist in response then send a request to gateway and create wireguard.conf file
            if bool(gateway):
                ip_address, port, token = gateway.values()
                gateway_address = f"{ip_address}:{port}"
                scheme = 'http' if url.startswith('http') else 'https'
                client_request_to_gateway(scheme, gateway_address, token, dsf)
        else:
            print("Error Code:", request_to_url.status_code)
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


def create_file_beat(data, address):
    with open(address, 'w+') as filebeat_config:
        yaml.dump(data, filebeat_config, default_flow_style=False)


if __name__ == "__main__":
    client_program()
