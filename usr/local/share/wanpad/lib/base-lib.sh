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

OSKERNEL=$(uname -s)

print_error()
{
  local RED='\033[0;31m'
  local NC='\033[0m' # No Color
  printf "${RED}ERROR:\t$1${NC}\n"
}

number_validator()
{
  case $1 in
      ''|*[!0-9]*)
      false
      ;;
      *)
      true
      ;;
  esac
}

force_run_as_root()
{
  uid=`id -u`
  if [ $uid != 0 ]; then
    print_error "Please run as \"root\" and try again."
    exit 1
  fi
}

get_arch()
{
  ARCH=$(uname -m)
  case $ARCH in
    x86_64 | amd64 )
      ARCH="amd64"
    ;;
    aarch64 | arm64 )
      ARCH="arm64"
    ;;
    armv7* )
      ARCH="armv7"
    ;;
    armv6* )
      ARCH="armv6"
    ;;
    i386 | i686 | x86 )
      ARCH="386"
    ;;
    * )
      echo Platform is not supported.
      exit 1
    ;;
  esac
}

get_scheme()
{
  if [ "$SSL" = "true" ]
  then
    export CONTROLLER_SCHEME="https"
  else
    export CONTROLLER_SCHEME="http"
  fi
}

usage()
{
    cat << EOF
wanpadctl(8) is an open-source utility for automating deployment and management of
WANPAD edges for SD-WAN controller.

Usage:
  wanpadctl command [args]

Available Commands:
  install   prepare and set up operating system to function as edge device.
  init      join to WANPAD controller.
  oob       connect to WANPAD controller using oob network.
  lte       configure lte module. (if any exists.)

Use "wanpad -v|--version" for version information.
Use "wanpad command -h|--help" for more information about a command.

EOF
    exit 1
}

get_controller_url()
{
  local CONTROLLER_API_PATH="$1"

	# Run get scheme for CONTROLLER_SCHEME variable
	get_scheme

	echo "${CONTROLLER_SCHEME}://${CONTROLLER_DOMAIN}:${CONTROLLER_API_PORT}${CONTROLLER_API_PATH}"
}

get_api()
{
	local CONTROLLER_URL="$(get_controller_url $1)"
	curl -s -X GET $CONTROLLER_URL -H 'Content-Type: application/json' -H "Authorization: Basic ${TOKEN}" -w "%{json}"
}

post_api()
{
  local data="$2"
	local CONTROLLER_URL="$(get_controller_url $1)"
	curl -s -X POST $CONTROLLER_URL -H 'Content-Type: application/json' -H "Authorization: Basic ${TOKEN}" -d "$data" -w "%{json}"
}