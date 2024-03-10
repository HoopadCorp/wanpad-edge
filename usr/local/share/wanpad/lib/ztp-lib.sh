#!/bin/sh
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

ztp_dialogue()
{
	echo "
Please Provide the following information:
"
	read -r -p "WANPAD controller address: " "CONTROLLER_DOMAIN"
	read -r -p "Your access token: " "TOKEN"
	echo $CONTROLLER_DOMAIN $TOKEN
}

validate_token()
{
	local CONTROLLER_TOKEN_VALIDATION_API_PATH="/wanpad/api/v1/auth/validate_token/"

	# Run get scheme for CONTROLLER_SCHEME variable
	get_scheme()

	# Set globally for python script
	export CONTROLLER_TOKEN_VALIDATION_URL="${CONTROLLER_SCHEME}://${CONTROLLER_DOMAIN}:${CONTROLLER_API_PORT}${CONTROLLER_TOKEN_VALIDATION_API_PATH}"

	local val_status_code=`curl -is -X POST $CONTROLLER_TOKEN_VALIDATION_URL \
		    -H 'Content-Type: application/json' \
		    -d '{"token": "'"${TOKEN}"'"}' | grep "HTTP/" | awk '{print $2}'`
	
	case $val_status_code in
		200)
			echo Great! your token is valid.
			;;
		4??)
			echo Sorry your token is not valid. Please check your token again or make a new one.
			exit 1
			;;
		*)
			echo Something went wrong. Please check your token again and 
			the problem still remains, reach out to our technical support.
			exit 1
			;;
	esac
}

save_ztp_config()
{
	sed -i.bak -e "/^CONTROLLER_DOMAIN=/s/=.*/=${CONTROLLER_DOMAIN}/" \
				-e "/^TOKEN=/s/=.*/=$TOKEN/" /usr/local/etc/wanpad/wanpad.conf
}

run_ztp_py()
{
	set -a
	. /usr/local/etc/wanpad/wanpad.conf
	set +a
	python3 /usr/local/share/wanpad/ztp/pnp-client.py
}