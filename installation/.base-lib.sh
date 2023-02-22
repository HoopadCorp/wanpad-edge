#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
Green='\033[0;32m'

function force_run_as_root () {

  uid=`id -u`
  if [[ $uid != 0 ]]
  then
  echo -e "${RED} ERROR:
  Please login as user \"root\" and try again.
  ${NC}You can do this by running: 
  ${Green}
  \"sudo -i\"
  ${NC}"
  exit 
  fi
}

function force_root_home_dir () {

  pwd=`pwd`
  if [[ $pwd =~ /root.* ]]
  then
  echo ""
  else
  echo -e "${RED} ERROR:
  You need to clone the repo under \"/root\"
  ${NC}You can do this by running:
  ${Green}
  \"cd /root/\"
  \"git clone https://github.com/HoopadCorp/wanpad-edge.git\"
  ${NC}"
  exit 1
  fi
}
