#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Installing the Nextion Driver 			   #
#							   #
#  VE3RD                                      2020/10/04   #
############################################################
set -o errexit
set -o pipefail
ver="20200512"
sudo mount -o remount,rw /

if [ "$1" ]; then
	if [ -d /home/pi-star/Nextion_Driver ]; then
  		sudo rm -R /home/pi-star/Nextion_Driver &> /dev/null 
	fi
	sudo git clone --depth 1 https://github.com/ON7LDS/NextionDriver /home/pi-star/Nextion_Driver  &>/dev/null
	cd /home/pi-star/Nextion_Driver
	make &>/dev/null 
	systemctl stop nextiondriver.service 
	cp NextionDriver /usr/local/bin/
	systemctl start nextiondriver.service   &>/dev/null 
	sudo /usr/local/bin/NextionDriver -Version |head -n2 | tail -n1 | cut -d " " -f3

else

	if [ -d /home/pi-star/Nextion_Driver ]; then
  		sudo rm -R /home/pi-star/Nextion_Driver  
	fi
	sudo git clone --depth 1 https://github.com/ON7LDS/NextionDriver /home/pi-star/Nextion_Driver 
	cd /home/pi-star/Nextion_Driver
	make 
	systemctl stop nextiondriver.service 
	cp NextionDriver /usr/local/bin/
	systemctl start nextiondriver.service   
	sudo /usr/local/bin/NextionDriver -Version |head -n2 | tail -n1 | cut -d " " -f3
fi
sudo mount -o remount,ro /
