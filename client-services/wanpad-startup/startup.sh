#!/bin/bash

# You need to mention the scripts you want to 
# run at startup here.

DIR="/etc/wanpad/wanpad-startup"

. ${DIR}/wanpad-startup-1.sh
. ${DIR}/wanpad-startup-2.sh
. ${DIR}/wanpad-startup-3.sh


