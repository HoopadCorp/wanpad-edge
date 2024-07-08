OS=					$$(uname -o)
ARCH=				$$(if [ "$$(uname -m)" = "x86_64" ]; then echo amd64; else uname -m; fi;)
DEBUG=				$$(if [ "${OS}" = "FreeBSD" ]; then echo set -xeouv pipefail; else echo set -xeouv; fi)

WANPAD_VERSION=		$$(git rev-parse HEAD)
WANPAD_CMD=			/usr/local/bin/wanpadctl
WANPAD_USERNAME=	hoopad
WANPAD_GROUP=		hoopad

.PHONY: all
all:
	@echo "Nothing to be done. Please use make install or make uninstall"

.PHONY: deps
deps:
	@echo "Install applications"
	@if [ -e /etc/debian_version ]; then\
		DEBIAN_FRONTEND=noninteractive apt install -y net-tools git openvpn python3-pip wireguard snmpd libqmi-utils udhcpc build-essential\
		 python3-dev strongswan strongswan-starter strongswan-swanctl ocserv frr bird2 keepalived fprobe sudo golang-1.20-go git-lfs jq prometheus-smokeping-prober;\
	elif [ "${OS}" = "FreeBSD" ]; then\
		pkg install -y git-lite openvpn python3 py39-pip strongswan frr9 frr9-pythontools bird2 fprobe sudo node_exporter go jq gcc49;\
	fi
	@echo
	@echo "Install python applications"
	@pip install -r requirements.txt
	@echo
	@if [ ! -s /usr/local/bin/node_exporter ]; then\
		echo "Install node exporter (linux)";\
		wget "https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-${ARCH}.tar.gz"\
			-O /tmp/node_exporter.tar.gz;\
		tar xzvf /tmp/node_exporter.tar.gz -C /tmp --wildcards "*/node_exporter";\
		mv /tmp/node_exporter-*/node_exporter /usr/local/bin/;\
		rm -rf /tmp/node_exporter*;\
	fi
	@echo
	@echo "Install UDPSpeeder (FEC)"
	@echo
	@if [ ! -s /usr/local/bin/speederv2 ]; then\
		git clone https://github.com/wangyu-/UDPspeeder.git /tmp/UDPspeeder;\
		if [ -e /etc/debian_version ]; then\
			make -C /tmp/UDPspeeder;\
		elif [ "${OS}" = "FreeBSD" ]; then\
			ln -s /usr/local/bin/g++49 /usr/local/bin/g++;\
			make -C /tmp/UDPspeeder freebsd;\
		fi;\
		cp /tmp/UDPspeeder/speederv2 /usr/local/bin/;\
		rm -rf /tmp/UDPspeeder;\
	fi
	@echo
	@echo "Install birdwatcher"
	@echo
	@if [ ! -s /usr/local/bin/birdwatcher ]; then\
		if [ "${OS}" = "FreeBSD" ]; then\
			go install github.com/alice-lg/birdwatcher@latest;\
		else\
			/usr/lib/go-1.20/bin/go install github.com/alice-lg/birdwatcher@latest;\
		fi;\
		mv /root/go/bin/birdwatcher /usr/local/bin/;\
	fi


.PHONY: ca
ca:
	@if [ "${OS}" = "FreeBSD" ]; then\
		mkdir -p /usr/local/etc/ssl/certs/;\
		cp usr/local/share/wanpad/ssl/WANPAD_CA.crt /usr/local/etc/ssl/certs/;\
		certctl rehash;\
	else\
		cp usr/local/share/wanpad/ssl/WANPAD_CA.crt /usr/local/share/ca-certificates/;\
		update-ca-certificates;\
	fi

.PHONY: generate
generate:
	@if [ ! -s /etc/ssh/ssh_host_ecdsa_key.pub ]; then\
		ssh-keygen -A;\
	fi

.PHONY: install
install: ca deps generate
	@echo "Create ${WANPAD_USERNAME} user"
	@if [ "${OS}" = "FreeBSD" ]; then\
		pw useradd ${WANPAD_USERNAME} -g wheel -m || true;\
	else\
		adduser --ingroup sudo --disabled-password ${WANPAD_USERNAME} || true;\
	fi
	@install -d -o ${WANPAD_USERNAME} /home/${WANPAD_USERNAME}/.ssh/
	@touch /home/${WANPAD_USERNAME}/.ssh/authorized_keys
	@chown ${WANPAD_USERNAME} /home/${WANPAD_USERNAME}/.ssh/authorized_keys
	@echo
	@echo "Create WANPAD Sudoers file"
	@if [ "${OS}" = "FreeBSD" ]; then\
		echo 'Defaults !fqdn' > /usr/local/etc/sudoers.d/${WANPAD_USERNAME};\
		echo "${WANPAD_USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers.d/${WANPAD_USERNAME};\
	else\
		echo 'Defaults !fqdn' > /etc/sudoers.d/${WANPAD_USERNAME};\
		echo "${WANPAD_USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${WANPAD_USERNAME};\
	fi
	@echo
	@echo "Installing wanpad"
	@echo
	@cp -Rv usr /
	@echo
	@echo "Set ownership of wanpad configuration directory to ${WANPAD_USERNAME} and ${WANPAD_GROUP}"
	@echo
	@chown ${WANPAD_USERNAME}:${WANPAD_GROUP} -R /usr/local/etc/wanpad
	@chmod +x ${WANPAD_CMD}
	@echo
	@echo "Install filebeat"
	@echo
	@tar xzvf usr/local/share/wanpad/tar-files/filebeat.tar.gz -C /usr/local/share/wanpad/client-services/
	@ln -sf /usr/local/share/wanpad/client-services/filebeat/filebeat /usr/local/bin/
	@echo
	@if [ "${OS}" = "GNU/Linux" ]; then\
		echo "Configure apparmor (Linux)";\
		cp /usr/local/share/wanpad/apparmor.d/usr.sbin.swanctl /etc/apparmor.d/local/usr.sbin.swanctl;\
		aa-status --enabled && apparmor_parser -r /etc/apparmor.d/local/usr.sbin.swanctl;\
	fi
	@echo "Installing wanpad configuration"
	@if [ ! -s /usr/local/etc/wanpad/wanpad.conf ]; then\
		cp /usr/local/etc/wanpad/wanpad.conf.sample /usr/local/etc/wanpad/wanpad.conf;\
	else\
		echo "wanpad configuration file is already exists at /usr/local/etc/wanpad/wanpad.conf.";\
		echo "If you want the new configuration use the following command below:";\
		echo "\tcp /usr/local/etc/wanpad/wanpad.conf.sample /usr/local/etc/wanpad/wanpad.conf";\
	fi

.PHONY: installonly
installonly:
	@echo "Installing wanpad version"
	@echo
	@cp -Rv usr /
	@chmod +x ${WANPAD_CMD}
	@echo
	@echo "Installing wanpad configuration"
	@if [ ! -s /usr/local/etc/wanpad/wanpad.conf ]; then\
		cp /usr/local/etc/wanpad/wanpad.conf.sample /usr/local/etc/wanpad/wanpad.conf;\
	else\
		echo "wanpad configuration file is already exists at /usr/local/etc/wanpad/wanpad.conf.";\
		echo "If you want the new configuration use the following command below:";\
		echo "\tcp /usr/local/etc/wanpad/wanpad.conf.sample /usr/local/etc/wanpad/wanpad.conf";\
	fi

.PHONY: debug
debug:
	@echo
	@echo "Enable Debug"
	@if [ "${OS}" = "FreeBSD" ]; then\
		sed -i '' '1s/$$/\n${DEBUG}/' /usr/local/share/wanpad/common.sh;\
	else\
		sed -i -e '1s/$$/\n${DEBUG}/' /usr/local/share/wanpad/common.sh;\
	fi
	@echo "Updating wanpad version to match git revision."
	@echo "WANPAD_VERSION: ${WANPAD_VERSION}"
	@sed -i.orig "s/WANPAD_VERSION=.*/WANPAD_VERSION=${WANPAD_VERSION}/" ${WANPAD_CMD}
	@echo "This method is for testing & development."
	@echo "Please report any issues to https://github.com/HoopadCorp/wanpad-edge/issues"

.PHONY: undebug
undebug:
	@echo
	@echo "Disable Debug without reinstall"
	@if [ "${OS}" = "FreeBSD" ]; then\
		sed -i '' '2d' /usr/local/share/wanpad/common.sh;\
	else\
		sed -i -e '2d' /usr/local/share/wanpad/common.sh;\
	fi
	@echo "Updating wanpad version to match git revision."
	@echo "WANPAD_VERSION: ${WANPAD_VERSION}"
	@sed -i.orig "s/WANPAD_VERSION=.*/WANPAD_VERSION=${WANPAD_VERSION}/" ${WANPAD_CMD}
	@echo "This method is for testing & development."
	@echo "Please report any issues to https://github.com/HoopadCorp/wanpad-edge/issues"

.PHONY: dev
dev: install debug

.PHONY: uninstall
uninstall:
	@echo "Removing Wanpad command"
	@rm -vf ${WANPAD_CMD}
	@echo
	@echo "Removing Wanpad sub-commands"
	@rm -rvf /usr/local/share/wanpad
	@echo
	@echo "Removing man page"
	@rm -rvf /usr/local/share/man/man8/wanpadctl.8.gz
	@echo
	@echo "Removing Wanpad Node Exporter"
	@rm -rvf /usr/local/bin/node_exporter
	@echo
	@echo "Removing Wanpad birdwatcher"
	@rm -rvf mv /usr/local/bin/birdwatcher
	@echo
	@echo "Removing Wanpad Filebeat"
	@rm -rvf /usr/local/bin/filebeat
	@echo
	@echo "Removing Wanpad Private CA"
	@if [ "${OS}" = "FreeBSD" ]; then\
		rm -v /usr/local/etc/ssl/certs/WANPAD_CA.crt;\
		certctl rehash;\
	else\
		rm -v /usr/local/share/ca-certificates/WANPAD_CA.crt;\
		update-ca-certificates;\
	fi
	@echo
	@echo "removing startup script"
	@if [ ! "${OS}" = "FreeBSD" ]; then rm -vf /etc/systemd/system/*/wanpad*.service /etc/systemd/system/wanpad*.service; fi
	@echo "You may need to manually remove other filers if it is no longer needed."

.PHONY: clean
clean: uninstall

.PHONY: purge
purge: uninstall
	@echo "Removing Wanpad configurations"
	@rm -rvf /usr/local/etc/wanpad
	@echo
	@echo "Removing WANPAD username"
	@if [ "${OS}" = "FreeBSD" ]; then\
		rmuser ${WANPAD_USERNAME};\
	else\
		pkill -u ${WANPAD_USERNAME};\
		deluser --remove-all-files ${WANPAD_USERNAME};\
	fi
	@echo
	@if [ "${OS}" != "FreeBSD" ]; then echo "Removing WANPAD SSH configuration"; fi
	@if [ -s /etc/ssh/sshd_config.d/99-wanpad.conf ]; then\
		rm /etc/ssh/sshd_config.d/99-wanpad.conf;\
	fi
	@echo
	@echo "Uninstall dependencies"
	@echo "!!!!! You have 5 seconds to cancel this operation !!!!!"
	@sleep 5
	@pip uninstall -r requirements.txt
	@if [ -e /etc/debian_version ]; then\
		apt purge -y net-tools git openvpn python3-pip wireguard snmpd libqmi-utils udhcpc build-essential\
		 python3-dev strongswan strongswan-starter frr bird2 keepalived fprobe golang-1.20-go;\
	elif [ "${OS}" = "FreeBSD"]; then\
		pkg delete -y git openvpn python3 py39-pip strongswan frr9 frr9-pythontools bird2 fprobe sudo node_exporter go;\
	fi
