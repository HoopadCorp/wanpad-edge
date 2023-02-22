#!/bin/bash


function force_run_as_root () {

  uid=`id -u`
  if [[ $uid != 0 ]]
  then
  echo "Please login as user \"root\" and try again.
  You can do this by running: 
  \"sudo -i\""
  exit 1
}

function force_root_home_dir () {

  pwd=`pwd`
  if [[ $pwd != /root/ ]]
  then
  echo "you need to clone the repo under \"/root\"
  You can do this by running:
  \"cd /root/\"
  \"git clone https://github.com/HoopadCorp/wanpad-edge.git\"
  "
  exit 1
}
