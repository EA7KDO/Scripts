#!/bin/bash
###################################################################
#  Prime_TGIF_Network Support        	 			  #
#  This Script will test the /usr/local/etc/DMR_Hosts.txt File    #
#  and /root/DMR_Hosts File for the prime.tgif.network IPAddress  #
#  and add the required line to /root/DMR_Hosts.txt if it was 	  #
#  not found in ether file				 	  #
#								  #
#  VE3RD                               2020=04-22                 #
###################################################################
sudo mount -o remount,rw /
export NCURSES_NO_UTF8_ACS=1

#use_colors = ON
#screen_color = (WHITE,BLUE,ON)
#title_color = (YELLOW,RED,ON)
sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc

echo -e '\e[1;44m'

# useradd1.sh - A simple shell script to display the form dialog on screen
# set field names i.e. shell variables
name=""
addr=""
port=""
passwd=""

# open fd
exec 3>&1

# Store data to $VALUES variable
VALUES=$(dialog --ok-label "Submit" \
	  --backtitle "TGIF Network Special Access" \
	  --title "Enter Required Fields" \
	  --form "Special Access Fields" \
18 50 0 \
	"     Server Name:" 1 1	"$name" 	1 18 25 0 \
	"  Server Address:" 2 1	"$addr"  	2 18 25 0 \
	"            Port:" 3 1	"$port"  	3 18 25 0 \
	"        Password:" 4 1	"$passwd" 	4 18 25 0 \
2>&1 1>&3)

# close fd
exec 3>&-

clear
# display values just entered
m1=$(echo "$VALUES" | sed -n 1p)
m2=$(echo "$VALUES" | sed -n 2p)
m3=$(echo "$VALUES" | sed -n 3p)
m4=$(echo "$VALUES" | sed -n 4p)

echo "    Server Name : $m1"
echo " Server Address : $m2"
echo "     Server Port: $m3"
echo "  Server Passwd : $m4"



declare -r TAB="`echo -e "\t"`"
#echo -e "A${TAB}B"

textstr="$m1${TAB}${TAB}0000${TAB}$m2${TAB}${TAB}$m4${TAB}$m3"
#echo "$textstr"

m1=$(sudo sed -n "/\t$m2/p" /usr/local/etc/DMR_Hosts.txt)

if [ -z "$m1" ]; then
	echo " The Data Entry is  missing from /usr/local/etc/DMR_Hosts.txt"
	echo " Checking Root DMR_Hosts.txt"
else
	echo " /usr/local/etc/DMR_Hosts.txt is Fine"
	echo " No Action Taken"
	exit
fi

m2=$(sudo sed -n "/\t$m2/p" /root/DMR_Hosts.txt)

if [ -z "$m2" ]; then
		echo "/root/DMR_Hosts.txt Updated "
		echo "Now doing a pstar-update and reboot"

		sudo sed -i "\$a$textstr" /root/DMR_Hosts.txt
		sudo pistar-update
		sudo reboot

else
		echo " /root/DMR_Host.txt is fine"
		echo "Doing a pistar-update to load the file"
		sudo pistar-update
		sudo reboot

fi


