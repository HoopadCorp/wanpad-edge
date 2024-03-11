#!/bin/sh
#
# Copyright (c) 2023,  Mohsen Karbalaei Amini <mohsenkamini@gmail.com>
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

. /usr/local/etc/wanpad/wanpad.conf
. /usr/local/share/wanpad/common.sh

force_run_as_root

configure_birdwatcher
[ "$OSKERNEL" = "Linux" ] && enable_wanpad_systemd_services
start_wanpad_services
enable_ipv4_forward
set_fib_multipath_hash_policy
set_fib_ip_no_pmtu_disc_1
configure_fprobe
configure_ssh
configure_snmpd
save_current_nameserver_conf_and_disable_resolved
