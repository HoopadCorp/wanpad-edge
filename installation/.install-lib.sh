#!/bin/bash
# DEBUG MODE:
set -euxo pipefail
. ./.env


function install_apt_deps () {

	apt update -y
	apt install `cat ${APT_DEPS_FILE}`
}

function install_pip_deps () {

	pip3 install -r ${PIP_DEPS_FILE}
}

function enable_wanpad_services () {

	systemctl daemon-reload
	for i in `ls /etc/wanpad/*/wanpad*.service  | xargs` ; do systemctl enable $i ; done
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
	echo "${DEFAULT_USER}	ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
	chmod 440 /etc/sudoers
}


function add_update_cron () {

	(crontab -l ; echo "0 5 * * * systemctl restart wanpad-update-repo.service") | crontab -
}
