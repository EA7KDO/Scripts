#!/bin/bash
###############################################################
#  This script will flash the TFT File ino The Nextion Screen #
#                                                             #
#  VE3RD                                      2020/04/07      #
###############################################################
set -o errexit
set -o pipefail

echo "Stop services"
sudo pistar-watchdog.service stop > /dev/null
sudo systemctl stop mmdvmhost.timer
sudo systemctl stop mmdvmhost.service
sudo systemctl stop cron.service  
sudo systemctl stop mmdvmhost.service  
sudo systemctl stop mmdvmhost.timer
sudo systemctl stop nextiondriver.service 

echo "Services Stopped"


if [ -z "$1" ]; then
	echo "Syntax:  flash NX3224K024.tft  or flash NX4832K035.tft"
	echo "Where NX3224K024.tft is Your Screen File"
	echo "The file must be located in /usr/local/etc/"
	exit
fi

pathstr="/usr/local/etc/$1"

if [ -f "$pathstr" ]; then
	echo "File $pathstr Found - Proceeding to Flash"
else 
	echo "File $pathstr NOT Found - Flash Aborted!"
fi;

echo "Screen File = $pathstr"
sudo python nextion.py "$pathstr" /dev/ttyUSB0

sudo reboot
