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

bgp_mesh_usage()
{
    echo -e "Usage: wanpadctl adm set bgp mesh [ local-as ] [ devices ]"
}

get_device_group()
{
	local response_json="$(get_api /wanpad/api/v1/devices/devices-group/)"

    local val_status_code=$(echo $response_json | jq -s '.[1].http_code' )

	case $val_status_code in
		200)
            echo $response_json | jq -s '.[0]'
			;;
		*)
			print_error "Something went wrong. Please check your token again and the problem still remains, reach out to our technical support."
            echo $response_json | jq
			exit 1
			;;
	esac
}

# add_device_group()
# # TODO: add a single device to a group
# {
# 	local response_json="$(post_api /wanpad/api/v1/devices/devices-group/ "$1")"

#     local val_status_code=$(echo $response_json | jq -s '.[1].http_code' )

# 	case $val_status_code in
# 		200)
#             echo $response_json | jq -s '.[0]'
# 			;;
# 		*)
# 			print_error "Something went wrong. Please check your token again and the problem still remains, reach out to our technical support."
#             echo $response_json | jq
# 			exit 1
# 			;;
# 	esac
# }

bgp_mesh_selected_device()
{
    local LOCAL_AS=$1
    if [ $LOCAL_AS -lt 1 ] && [ $LOCAL_AS -gt 4294967295 ]
    then
        print_error "<1-4294967295>  Autonomous system number"
        exit 1
    fi
    shift
    local data="$(echo $@ | jq -R "split(\",\")|{devices:[.[]], local_as: \"$LOCAL_AS\"}")"

	local response_json="$(post_api /wanpad/api/v1/bgp/multi/bgp/neighbors/selected_devices/ $data)"

    local val_status_code=$(echo $response_json | jq -s '.[1].http_code' )

	case $val_status_code in
		200)
            echo $response_json | jq -s '.[0]'
			;;
		*)
			print_error "Something went wrong. Please check your token again and the problem still remains, reach out to our technical support."
            echo $response_json | jq
			exit 1
			;;
	esac
}

show_devices()
{
	local response_json="$(get_api /wanpad/api/v1/devices/devices-list/)"

    local val_status_code=$(echo $response_json | jq -s '.[1].http_code' )

	case $val_status_code in
		200)
            echo $response_json | jq -s '.[0]'
			;;
		*)
			print_error "Something went wrong. Please check your token again and the problem still remains, reach out to our technical support."
            echo $response_json | jq
			exit 1
			;;
	esac
}