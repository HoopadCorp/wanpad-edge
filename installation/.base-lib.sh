#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

function print_error () {
# usage:
# ERROR_MSG="some error"
# print_error

  echo -e "${RED}
 ERROR:
  ${ERROR_MSG}
  ${NC}
  "
}

function print_green () {
# usage:
# GREEN_MSG="some solution"
# print_green

  echo -e "${GREEN}
  ${GREEN_MSG}
  ${NC}
  "
}

function force_run_as_root () {

  uid=`id -u`
  if [[ $uid != 0 ]]
  then
  ERROR_MSG="Please login as user \"root\" and try again."
  print_error
  
  echo "
  You can do this by running: "
  GREEN_MSG="sudo -i"
  print_green
  
  
#  echo -e "${RED}
# ERROR:
#  Please login as user \"root\" and try again.
#  ${NC}You can do this by running: 
#  ${Green}
#  sudo -i
#  ${NC}"
  exit 1
  fi
}

function force_root_home_dir () {

  pwd=`pwd`
  if [[ $pwd =~ /root.* ]]
  then
  echo ""
  else
  
  ERROR_MSG="You need to clone the repo under \"/root\""
  print_error
  
  echo "
  You can do this by running: "
  GREEN_MSG="cd /root/
  git clone https://github.com/HoopadCorp/wanpad-edge.git"
  print_green
  
  
#  echo -e "${RED} 
# ERROR:
#  You need to clone the repo under \"/root\"
#  ${NC}You can do this by running:
#  ${Green}
#  cd /root/
#  git clone https://github.com/HoopadCorp/wanpad-edge.git
#  ${NC}"
  exit 1
  fi
}
