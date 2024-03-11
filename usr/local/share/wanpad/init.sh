#!/bin/bash
#
# Copyright (c) 2023,  Mohsen Karbalaei Amini <mohsenkamini@gmail.com>
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

. /usr/local/share/wanpad/common.sh

force_run_as_root
	
#number of arguments
NA=`echo $* | wc -w `

case "$NA" in
	0)
		ztp_dialogue
		;;
	2)
		DOMAIN=$1
		TOKEN=$2
		;;
	*)
		usage
		exit 1
		;;
esac

save_ztp_config
validate_token $2
run_ztp_py
