#!/bin/bash
#########################################################################
#  MNet_Network Support                                                 #
#  This Script will install The MNet Security Password into             #
#  /root/DMR_Hosts.txt and run the Pi-Star Host File Updatde Routine    #
#  and add the required line to /root/DMR_Hosts.txt if it was           #
#  not found in ether file.						#
#  Place the Security Password into /home/pi-star/MNet.txt		#
#                                                                       #
#  VE3RD                                                2020-08-22      #
#########################################################################
export NCURSES_NO_UTF8_ACS=1

s1=""
s2=""
s3=""

slen2=$(expr length "$sc2")

s1=$(grep 10210 /root/P25Hosts.txt | cut -f1)

s2=$(grep 10211 /root/P25Hosts.txt | cut -f1)

s3=$(grep 10230 /root/P25Hosts.txt | cut -f1)

echo "S1:$s1"
echo "S2:$s2"
echo "S3:$s3"

if [ "$s1" == '' ]; then
	echo "Addding 10210"
	textstr="10210\tmnet.hopto.org\t41000"
	sudo sed -i "\$a$textstr" /root/P25Hosts.txt
fi

if [ "$s2" == '' ]; then
	echo "Addding 10211"
	textstr="10211\tmnet.hopto.org\t41010"
	sudo sed -i "\$a$textstr" /root/P25Hosts.txt
fi

if [ "$s3" == '' ] && [ "$1" != "" ]; then
	echo "Addding 10230"
	textstr="10230\tmitchp25.hopto.org\t41000"
	sudo sed -i "\$a$textstr" /root/P25Hosts.txt
fi
echo "Updating Hostfiles..."

sudo /usr/local/sbin/HostFilesUpdate.sh

if [ "$?" == "0" ]; then
	echo "Host Files Successfully Updated"
else
	echo "Host File Update Failed!"
fi
echo ""






