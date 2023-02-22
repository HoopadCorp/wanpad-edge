#!/bin/bash

RED='\033[0;31m'


function force_run_as_root () {

  uid=`id -u`
  if [[ $uid != 0 ]]
  then
  echo -e "${RED}Please login as user \"root\" and try again.
  You can do this by running: 
  \"sudo -i\""
  exit 
  fi
}

function force_root_home_dir () {

  pwd=`pwd`
  if [[ $pwd =~ /root.* ]]
  then
  echo ""
  else
  echo -e "${RED}you need to clone the repo under \"/root\"
  You can do this by running:
  \"cd /root/\"
  \"git clone https://github.com/HoopadCorp/wanpad-edge.git\"
  "
  exit 1
  fi
}
