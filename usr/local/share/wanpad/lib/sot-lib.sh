#!/bin/sh
#
# Copyright (c) 2024, Seyed Pouria Mousavizadeh Tehrani <p.mousavizadeh@protonmail.com>
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

# This file exists for administration of the WANPAD controller. Will be completed in the near future.

sot_usage()
{
    cat << EOF
Usage:
  wanpadctl sot OPERATION COMMAND [args]

OPERATION
    Specifies the action to perform on the object.  The set of possible actions depends on the object type.  As a rule, it is possible to add, update, delete and show (or list ) objects, but some objects
    do not allow all of these operations or have some additional commands. The help command is available for all objects.

Available Commands:
	smokeping		compare desired and current config file of smokeping probe to update the file and restart the service. (update operation only)

Use "wanpad -v|--version" for version information.
EOF
    exit 1
}

smokeping_compare_and_update()
{
	diff -q /etc/prometheus/smokeping_prober.yml.sot /etc/prometheus/smokeping_prober.yml
	if [ "$?" != 0 ]
	then
		cp /etc/prometheus/smokeping_prober.yml.sot /etc/prometheus/smokeping_prober.yml
		service prometheus-smokeping-prober restart
	fi
}
