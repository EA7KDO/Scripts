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

declare -i slen

if [ "$1" ]; then
        sc1="$1"
	slen1=$(expr length "$sc1")

	if [ "$slen1" != 15 ]; then
		echo "Wrong String Length for Security Password"
		exit
	fi
	m4="$sc1"
else

	if [ -f /home/pi-star/MNet.txt ]; then
		sc1=$(cat /home/pi-star/MNet.txt)
		slen1=$(expr length "$sc1")

		if [ "$slen1" != 15 ]; then
			echo "Wrong String Length for Security Password"
			exit
		fi

		m4="$sc1"
	else
		echo "Security Password Not Found"
		exit
	fi 
fi

sudo mount -o remount,rw /

slen2=$(expr length "$sc2")

echo "$sc1"
echo "$sc2"
m1="MNet_Network"
m2="0000"
m3="mnet.hopto.org"
m5="62031"

textstr="$m1\t\t$m2\t$m3\t\t\t$m4\t\t$m5"

sudo sed -i "\$a$textstr" /root/DMR_Hosts.txt

echo "Updating Hostfiles..."

sudo /usr/local/sbin/HostFilesUpdate.sh

if [ "$?" == "0" ]; then
	echo "Host Files Successfully Updated"
else
	echo "Host File Update Failed!"
fi
echo ""






