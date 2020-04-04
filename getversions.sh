#!/bin/bash
############################################################
#  Get Cross Mode 			                   #
#  Build Binary Bit Pattern                                #
#                                                          #
#  Returns a string      		                   #
#                                                          #
#  VE3RD                                        2019-11-14 #
############################################################
set -o errexit
set -o pipefail

if [ -z $1 ]; then
exit
fi

if [ $1 = 1 ]; then 
#m1=$(sudo cat /etc/pistar-release | grep "\Pi-Star_Build_Date") 
#m2=$(sudo cat /etc/pistar-release | grep "\Version")
#m3=$(sudo cat /etc/pistar-release | grep "\ircddbgateway")  
m1=$(sudo sed -n '/^[^#]*Pi-Star_Build_Date/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")
m2=$(sudo sed -n '/^[^#]*Version/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")
m3=$(sudo sed -n '/^[^#]*ircddbgateway/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")

mt="$m1|$m2|$m3"
echo "$mt"
fi

if [ $1 = 4 ]; then
#m4=$(sudo cat /etc/pistar-release | grep "\dstarrepeater")  
#m5=$(sudo cat /etc/pistar-release | grep "\MMDVMHost")  
#m6=$(sudo cat /etc/pistar-release | grep "\kernel")
#m7=$(sudo cat /etc/pistar-release | grep "\Hardware")
m4=$(sudo sed -n '/^[^#]*dstarrepeater/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")
m5=$(sudo sed -n '/^[^#]*MMDVMHost/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")
m6=$(sudo sed -n '/^[^#]*kernel/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")
m7=$(sudo sed -n '/^[^#]*Hardware/p' /etc/pistar-release | sed -E "s/[[:space:]]+//g")
#m8=$(sudo sed -n '/^[^#]version/p' /var/www/dashboard/config/version.php | sed -E "s/[[:space:]]+//g")
m8=$(sudo sed -n '/^[^#]*version/p' /var/www/dashboard/config/version.php | sed -E "s/[[:space:]]+//g" | sed -E "s/'//g" | sed -E "s/;//g" | cut -c2- | sed -E "s/version=/Dashboard:/g" )


mt="$m4|$m5|$m6|$m7|$m8"
echo "$mt"

fi



