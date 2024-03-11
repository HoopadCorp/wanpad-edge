#!/bin/sh
#
# Copyright (c) 2022-2023,  Mohsen Karbalaei Amini <mohsenkamini@gmail.com>
# Copyright (c) 2023-2024, Seyed Pouria Mousavizadeh Tehrani <p.mousavizadeh@protonmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

configure_birdwatcher()
{
	mkdir -p /usr/local/etc/birdwatcher/
	cp "${CLIENT_SERVICES_DIR}/birdwatcher/birdwatcher.conf" /usr/local/etc/birdwatcher/
}

enable_wanpad_systemd_services()
{
	find /etc/systemd/ -lname "/usr/local/share/wanpad/client-services/wanpad-*.service" -exec rm {} +
	# remove any wanpad_os service existing on the host
	systemctl daemon-reload
	for service in "$(ls /usr/local/share/wanpad/client-services/wanpad-*.service  | xargs)"
		do systemctl enable $service || true
	done
}

start_wanpad_services()
{
	service wanpad-* start || true
}

enable_ipv4_forward()
{
	echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/10-ip_forward.conf
	sysctl -w net.ipv4.ip_forward=1
}

set_fib_multipath_hash_policy()
{	
	echo 'net.ipv4.fib_multipath_hash_policy=1' > /etc/sysctl.d/10-fib_multipath_hash_policy.conf
	sysctl -w net.ipv4.fib_multipath_hash_policy=1
}

set_fib_ip_no_pmtu_disc_1()
{
	echo 'net.ipv4.ip_no_pmtu_disc=1' > /etc/sysctl.d/10-ip-no-pmtu-disc.conf
	sysctl -w net.ipv4.ip_no_pmtu_disc=1
}

configure_fprobe()
{
	cp "${CLIENT_SERVICES_DIR}/fprobe/fprobe.conf" "/etc/default/fprobe"
	until systemctl restart fprobe.service ;
		do set +x
		echo "trying to restart fprobe service... if this is taking too long consult Hoopad tech assistants"
		set -x
		sleep 5
	done
}

configure_ssh()
{
	if [ $OSKERNEL = "FreeBSD" ]; then
		sed -i '' -e '/.*Port */d' /etc/ssh/sshd_config
		envsubst < /usr/local/share/wanpad/ssh/99-wanpad.conf >> /etc/ssh/sshd_config
	else
		envsubst < /usr/local/share/wanpad/ssh/99-wanpad.conf > /etc/ssh/sshd_config.d/99-wanpad.conf
		echo "DebianBanner no" >> /etc/ssh/sshd_config.d/99-wanpad.conf
	fi
	set +x ;
	echo "\nNOTICE:
	The SSH port will be changed to $DEFAULT_SSH_PORT.\n"
	set -x;
	service sshd restart
}


# This function checks if wanpad has already configured this service 
# or not. if not it overrides the configuration with a default conf.
configure_snmpd()
{
	local wanpad_conf_message="# Configured By WANPAD"
	local service='snmp'
	local daemon='snmpd'
	if [ $OSKERNEL = "FreeBSD" ]; then
		wanpad_snmpd_config="/etc/${daemon}.config"
	else
		wanpad_snmpd_config="/etc/${service}/${daemon}.conf"
	fi
	local flag="$(grep "$wanpad_conf_message" $wanpad_snmpd_config)"

	if [[ -z "$flag" ]]
	then
		cp "${CLIENT_SERVICES_DIR}/${service}/${daemon}.conf" $wanpad_snmpd_config
		service ${daemon} restart
		set +x
		echo "snmp is not yet configured by wanpad"
		set -x
	else
		set +x
		echo "snmp is already configured by wanpad"
		set -x
	fi
}

# This function enables controller to be able to change the
# nameservers by simply editing /etc/resolv.conf .
save_current_nameserver_conf_and_disable_resolved()
{	
	current_etc_resolv_conf="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')"
 	if [ -n "$(netplan get)" ]; then
		netplan_conf_file="$(ls /etc/netplan/*.y*ml | head -1)"
		if [[ "$current_etc_resolv_conf" == "127.0.0.53" ]]
		then 
			nameserver1_temp="$(cat ${netplan_conf_file} | yq -e '.network.*.*.nameservers.addresses[]' | head -1)"
			nameserver2_temp="$(cat ${netplan_conf_file} | yq -e '.network.*.*.nameservers.addresses[]' | head -2 | tail -1)"
			
			if [[ -n "$nameserver1_temp" ]]
			then
				DEFAULT_NS1="$(echo "$nameserver1_temp")"
				if [[ -n "$nameserver1_temp" ]]
				then 
					DEFAULT_NS2="$(echo $nameserver2_temp)"
				fi
			fi
		else
			if [[ -n "$current_etc_resolv_conf" ]]
			then
				nameserver1_temp="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'| head -1)"
				nameserver2_temp="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'| head -2 | tail -1)"
				if [[ -n "$nameserver1_temp" ]]
				then
					DEFAULT_NS1="$(echo $nameserver1_temp)"
					if [[ -n "$nameserver1_temp" ]]
					then 
						DEFAULT_NS2="$(echo $nameserver2_temp)"
					fi
				fi
			fi
		fi
  	fi
	
	chattr -i /etc/resolv.conf
	rm /etc/resolv.conf

	[ "$OSKERNEL" == "Linux" ] && systemctl disable --now systemd-resolved

	[ -n "$DEFAULT_NS1" ] && echo "nameserver $DEFAULT_NS1" > /etc/resolv.conf
	[ -n "$DEFAULT_NS2" ] && echo "nameserver $DEFAULT_NS2" >> /etc/resolv.conf

	echo "PLEASE NOTE:
	The following servers are set as your DNS servers.
	you can change this configuration by editing /etc/resolv.conf\n"

	cat /etc/resolv.conf
}
