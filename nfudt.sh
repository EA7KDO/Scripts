#!/bin/bash
######################################################################
#  Nextion TFT Support for Nextion 2.4 7 3.5" 	                     #
#  This script does a git pull from the Nextion_Temp Directory       #
#  and does an rsync to synchronize the changes with the             #
#  /usr/local/etc/Nextion Support Directory  	     		     #
#							             #
#  VE3RD                               2021-12-21                    #
######################################################################
if [ ! -d /home/pi-star/Nextion_Temp ]; then
echo " Nextion_Temp Directory Not Found"
echo " This looks like a NEW Install "
echo " Please use ./gitcopy2.sh"
exit



fi
sudo mount -o remount,rw /
cd /home/pi-star/Nextion_Temp
pwd
sudo git pull

echo "Git Pull Done"
sudo rsync /home/pi-star/Nextion_Temp/* /usr/local/etc/Nextion_Support/
echo "rsync done"
cd /home/pi-star/Scripts

