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

RED='\033[0;31m'
NC='\033[0m' # No Color

print_error ()
{
# usage:
# ERROR_MSG="some error"
# print_error
  echo -e "${RED}
 ERROR:
  ${ERROR_MSG}${NC}"
}

force_run_as_root()
{
  uid=`id -u`
  if [ $uid != 0 ]; then
    ERROR_MSG="Please run as \"root\" and try again."
    print_error
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