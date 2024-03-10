#!/bin/sh
#
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

. /usr/local/etc/wanpad/wanpad.conf

. /usr/local/share/wanpad/lib/base-lib.sh
. /usr/local/share/wanpad/lib/adm-lib.sh

if [ -n "$LITE_VERSION" ]
then
    if [ "$1" != "adm" ]
    then
        echo "Error: Sub-commands other than 'adm' are not supported in the WANPAD Edge Lite version."
    fi
    echo "Lite version is administration only."
    echo "Please install WANPAD Edge for full installation."
    exit 1
fi

. /usr/local/share/wanpad/lib/install-lib.sh
. /usr/local/share/wanpad/lib/ztp-lib.sh