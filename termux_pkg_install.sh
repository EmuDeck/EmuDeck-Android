#!/bin/sh
#

rm ~/storage/shared/emudeck.log &>> /dev/null
touch ~/storage/shared/emudeck.log &>> /dev/null
sleep .5
export DEBIAN_FRONTEND=noninteractive
apt-get update && 
	apt-get -o "Dpkg::Options::=--force-confold"  upgrade -q -y --force-yes &&
	apt-get -o "Dpkg::Options::=--force-confold"  dist-upgrade -q -y --force-yes
pkg autoclean
pkg update -y && pkg upgrade -y
pkg install git wget jq rsync unzip whiptail binutils build-essential liblz4 libuv ninja -y
