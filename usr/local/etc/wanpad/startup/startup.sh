#!/bin/sh

# You need to mention the scripts you want to 
# run at startup here.

DIR="/usr/local/etc/wanpad/startup"

. ${DIR}/startup-0.sh
. ${DIR}/startup-1.sh
. ${DIR}/startup-2.sh
. ${DIR}/startup-3.sh
. ${DIR}/startup-4.sh
. ${DIR}/startup-5.sh
. ${DIR}/startup-6.sh
. ${DIR}/startup-7.sh
. ${DIR}/startup-8.sh
. ${DIR}/startup-9.sh

. ${DIR}/swanctl.sh
. ${DIR}/bird.sh