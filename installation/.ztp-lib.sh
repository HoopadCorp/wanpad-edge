#!/bin/bash

# DEBUG MODE:
#set -euxo pipefail

usage () {
	
	echo "
usage:
	
	./ztp-init.sh [-h|--help] [WANPAD Controller URI] [token] 
	
		You can either pass these parameters using the helping
	       	dialogue or as arguments like shown above.

		Run ./ztp-init.sh to start the script with the
		dialogues to get parameters from you.
		"
}


check_NA () {

	if [ $NA -gt 0 ]
	then
		skip_dialogue=true
		URI=$1 ; TOKEN=$2
	else
		skip_dialogue=false
	fi

}

ztp_dialogue () {
	
	echo "
Please Provide the following information:
"
	read -r -p "WANPAD controller URI: " "URI"
	read -r -p "Your access token: " "TOKEN"
	echo $URI $TOKEN
}

set_django_port () {
	
	is_mobinnet=`echo $URI | grep mobinnet`
	if [[ -n $is_mobinnet ]]
	then
		DJANGO_PORT=3001
	else
		DJANGO_PORT=8001
	fi
}

validate_token () {

	#local URL=`echo $URI | cut -d '/' -f3`

	local val_status_code=`curl -is -X POST https://${URI}:${DJANGO_PORT}/wanpad/api/v1/auth/validate_token/ \
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
			echo something went wrong. Please check your token again and 
			the problem still remains, reach out to our technical support.
			exit 1
			;;
		esac
}

change_env_file () {

	echo "URI=https://$URI:${DJANGO_PORT}/wanpad/api/v1/devices/plug_play/" > ${ZTP_ENV_FILE}
	echo "TOKEN=$TOKEN" >> ${ZTP_ENV_FILE}
}

run_pnp_client_py () {

	cd ${PNP_SERVICE_DIR} 
	python3 pnp-client.py
}
