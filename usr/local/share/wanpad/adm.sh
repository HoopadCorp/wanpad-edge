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

. /usr/local/share/wanpad/common.sh

# Handle special-case commands first.
case "$1" in
help|-h|--help)
    adm_usage
    ;;
esac

if [ "$1" = "get" ]
then
    if [ "$2" = "device" ]
    then
        if [ "$3" = "group" ]
        then
            get_device_group $4
        elif [ "$3" = "info" ]
        then
            get_device $4
        fi
    fi
# elif [ "$1" = "add" ]
# then
#     if [ "$2" = "device" ]
#     then
#         if [ "$3" = "group" ]
#         then
#             add_device_group $4
#         fi
#     fi
elif [ "$1" = "set" ]
then
    if [ "$2" = "bgp" ]
    then
        if [ "$3" = "mesh" ]
        then
            shift 3
            if [ $# -ne 2 ]
            then
                bgp_mesh_usage
                exit 1
            fi
            bgp_mesh_selected_device "$1" "$2"
        fi
    fi
elif [ "$1" = "show" ]
then
    if [ "$2" = "device" ]
    then
        if [ -z "$3" ]
        then
            show_devices
        elif [ "$3" = "name" ]
        then
            show_device_by_name "$4"
        fi
    fi
fi