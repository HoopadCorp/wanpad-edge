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

set_django_port
validate_token
change_env_file
run_pnp_client_py



