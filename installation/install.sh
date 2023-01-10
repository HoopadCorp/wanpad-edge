#!/bin/bash
# DEBUG MODE:
set -euo pipefail
. ./.env
. ./.install-lib.sh



create_hoopad_user || true
install_apt_deps
install_pip_deps
birdwatcher_conf
extract_filebeat
enable_wanpad_services
start_wanpad_services
add_update_cron || true
enable_ipv4_forward
set_fib_multipath_hash_policy_1
set_fib_ip_no_pmtu_disc_1
fprobe_conf
set_ssh_default_port
snmpd_initial_conf
