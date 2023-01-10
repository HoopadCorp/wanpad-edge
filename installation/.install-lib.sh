#!/bin/bash
# DEBUG MODE:
set -euxo pipefail
. ./.env


function install_apt_deps () {

	apt update -y
	apt install -y `cat ${APT_DEPS_FILE}`
}

function install_pip_deps () {

	pip3 install -r ${PIP_DEPS_FILE}
}

function birdwatcher_conf () {

	mkdir -p /etc/birdwatcher/
	cp "${CLIENT_SERVICES_DIR}/birdwatcher/birdwatcher.conf" /etc/birdwatcher/birdwatcher.conf
	
}

function enable_wanpad_services () {

	find /etc/systemd/system/ -lname "/root/wanpad_os/client-services/*" -exec rm {} +
	# remove any wanpad_os service existing on the host
	mkdir -p /etc/wanpad/
	ln -sf /root/wanpad-edge/client-services/* /etc/wanpad/
	systemctl daemon-reload
	for i in `ls /etc/wanpad/*/wanpad*.service  | xargs` ; do systemctl enable $i || true ; done
}

function start_wanpad_services () {
	
	for i in `ls /etc/systemd/system/wanpad-* | sed 's|/etc/systemd/system/||g'` ; do systemctl start $i || true ; done
}

function create_hoopad_user () {

	mkdir -p /home/${DEFAULT_USER}/.ssh 
	useradd ${DEFAULT_USER} -m -d /home/${DEFAULT_USER} -s /bin/bash || true
	touch /home/${DEFAULT_USER}/.ssh/authorized_keys
	chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}
	usermod -aG sudo ${DEFAULT_USER}
	chmod 640 /etc/sudoers
	#echo "${DEFAULT_USER}	ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/${DEFAULT_USER}
	grep -qxF "${DEFAULT_USER}	ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers || echo "${DEFAULT_USER}	ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers 
	chmod 440 /etc/sudoers
}


function add_update_cron () {

	(crontab -l ; echo "0 5 * * * systemctl restart wanpad-update-repo.service") | crontab -
}

function enable_ipv4_forward () {
	echo "net.ipv4.ip_forward=1" | tee /etc/sysctl.d/10-ip_forward.conf && sysctl -w net.ipv4.ip_forward=1
}

function set_fib_multipath_hash_policy_1 () {
	
	sysctl -w net.ipv4.fib_multipath_hash_policy=1
	echo 'net.ipv4.fib_multipath_hash_policy = 1' | tee /etc/sysctl.d/10-fib_multipath_hash_policy.conf
}

function set_fib_ip_no_pmtu_disc_1 () {
	
	sysctl -w net.ipv4.ip_no_pmtu_disc=1
	echo 'net.ipv4.ip_no_pmtu_disc = 1' | tee /etc/sysctl.d/10-ip-no-pmtu-disc.conf
}

function fprobe_conf () {

	local service='fprobe'
	cp "${CLIENT_SERVICES_DIR}/${service}/${service}.conf" "/etc/default/${service}"
	until systemctl restart fprobe.service ; do set +x ;echo "trying to restart fprobe service... if this is taking too long consult Hoopad tech assistants" ; set -x;  sleep 5 ;done
}

function extract_filebeat () {
	
	local service='filebeat'
	tar xvf ${TAR_FILES_DIR}/${service}.tar.gz -C "${CLIENT_SERVICES_DIR}/"
}

function set_ssh_default_port () {
	
	# delete any comments or configs for Port
	local SSHD_CONFIG_ADDR=/etc/ssh/sshd_config
	local current_port=`grep "^Port " ${SSHD_CONFIG_ADDR} | awk '{print $2}'`
	if [[ $current_port != $DEFAULT_SSH_PORT ]]
	then
		set +x ;
		echo "
		
		
NOTICE:
	After this operation you won't be able to access SSH service at port $current_port anymore.
	The SSH port will be changed to $DEFAULT_SSH_PORT
	
	
	
"
		set -x;
	fi
	
	sed -i '/.*Port */d' ${SSHD_CONFIG_ADDR}
	echo "Port ${DEFAULT_SSH_PORT}" | tee -a ${SSHD_CONFIG_ADDR}
	systemctl restart sshd
	
}


function snmpd_initial_conf () {

	local wanpad_conf_message=""
	local service='snmp'
	local daemon='snmpd'
	flag=`grep "${wanpad_conf_message}" /etc/${service}/${daemon}.conf`
	if [ -z $flag ]
	then
	cp "${CLIENT_SERVICES_DIR}/${service}/${daemon}.conf" "/etc/${service}/${daemon}.conf"
	systemctl stop ${daemon}
	fi
}
