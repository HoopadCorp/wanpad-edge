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


