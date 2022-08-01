#!/bin/bash
# DEBUG MODE:
set -euo pipefail
. ./.ztp-lib.sh
. .env
	
#number of arguments
NA=`echo $* | wc -w `


case "$NA" in
	0)
		ztp_dialogue
		;;
	2)
		URI=$1 ; TOKEN=$2
		;;
	*)
		usage
		exit 1
		;;
esac


validate_token
change_env_file
run_pnp_client_py

#
#check_NA $*
#
#if [ $skip_dialogue == true ]
#then
#	echo $URI $TOKEN
#else
#	ztp_dialogue
#	echo $URI $TOKEN
#fi
#



