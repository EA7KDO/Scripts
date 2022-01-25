#!/bin/bash
#########################################################
#  Nextion TFT Support for Nextion 2.4" 		#
#  Gets all Scripts and support files from github       #
#  and copies them into the Nextion_Support directory   "
#  and copies the NX??? tft file into /usr/local/etc    #
#  and returns a script duration time to the Screen 	#
#  as a script completion flag				#
#							#
#  KF6S/VE3RD                               2020-05-12  #
#########################################################
# Valid Screen Names for EA7KDO - NX3224K024, NX4832K935
# Valid Screen Names for VE3RD - NX3224K024

if [[ $EUID -ne 0 ]]; then
	clear
	echo ""
   	echo "This script must be run as root"
	echo "Setting root user"
	echo "Re-Start Script"
	echo ""
	sudo su -s ./gitcopy2.sh
  # 	exit 1
else
 ./gitcopy2.sh
fi


