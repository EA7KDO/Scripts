#!/bin/bash
###############################################################
#  This script will flash the TFT File into The Nextion Screen #
#                                                             #
#  VE3RD                                      2020/04/07      #
###############################################################
set -o errexit
set -o pipefail

if [ -z "$1" ]; then
        echo "No Screen Name Provided"
	echo "Syntax:  flash NX3224K024.tft"
	echo "OR" 
	echo "Syntax:  flash NX4832K035.tft"
	echo "Where NX3224K024.tft or NX4832K035.tft  is Your Screen File"
	echo "The file must be located in /usr/local/etc/"
	exit
fi

declare -i tst
tst=0

## Strip off .tft - Force upper case
scn=$(echo "$1" | tr [:lower:] [:upper:])
## Take only the first 10 characters and Add the .tft file extension in lower case
scn="${scn:0:10}.tft"

#Setup the string for the screen name and location
pathstr="/usr/local/etc/$scn"

if [ -f "$pathstr" ]; then
	echo "File $pathstr Found - Proceeding to Flash"
	tst=1
else 
	echo "File $pathstr NOT Found - Flash Aborted!"
	tst=0
fi;

echo "Screen Type Entered to Flash = $pathstr"

if [ "$tst" = 1 ]; then
	echo "Stopping services - Reboot Required after This Script Finishes"
	sudo pistar-watchdog.service stop > /dev/null
	sudo systemctl stop mmdvmhost.timer
	sudo systemctl stop mmdvmhost.service
	sudo systemctl stop cron.service  
	sudo systemctl stop mmdvmhost.service  
	sudo systemctl stop mmdvmhost.timer
	sudo systemctl stop nextiondriver.service 

	echo "Services Stopped"

	sudo python nextion.py "$pathstr" /dev/ttyUSB0
	echo "Rebooting ......"
	sudo reboot
else
         echo "Error Detected - No Action Taken - Script Aborted!"
fi
