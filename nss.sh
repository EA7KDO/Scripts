#!/bin/bash
######################################################################
#  Prime_TGIF_Network Support        	 			     #
#  This Script will test the /usr/local/etc/DMR_Hosts.txt File       #
#  and /root/DMR_Hosts File for the prime.tgif.network IPAddress     #
#  and add the required line to /root/DMR_Hosts.txt if it was 	     #
#  not found in ether file				 	     #
#								     #
#  VE3RD                               			2020-04-24   #
######################################################################
sudo mount -o remount,rw /
export NCURSES_NO_UTF8_ACS=1
declare -i mode=0
declare -r TAB="`echo -e "\t"`"
linetext=""
fname=""
## mode=0 - Addm New Line to Custom
## mode=1 - Accept Main File
## mode=2 - Accept Custom File

#use_colors = ON
#screen_color = (WHITE,BLUE,ON)
#title_color = (YELLOW,RED,ON)
sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc

echo -e '\e[1;44m'

#m1=$(sudo sed -n "/\t$m2/p" /usr/local/etc/DMR_Hosts.txt)
function parseline
{
clear
 p1a=$(echo "$linetext" | cut -d$'\t' -f1)
 p2=$(echo "$linetext" | cut -d$'\t' -f3)
 p3=$(echo "$linetext" | cut -d$'\t' -f4)
 p4=$(echo "$linetext" | cut -d$'\t' -f6)
 p5=$(echo "$linetext" | cut -d$'\t' -f7)

p1=$(echo "$p1a" | sed -e 's/ /_/g')
echo "$p1${TAB}$p2${TAB}$p3${TAB}$p4${TAB}$p5"
}

function addline
{
# display values just entered
	m1a=$(echo "$VALUES" | sed -n 1p)
	m2=$(echo "$VALUES" | sed -n 2p)
	m3=$(echo "$VALUES" | sed -n 3p)
	m4=$(echo "$VALUES" | sed -n 4p)
	m5=$(echo "$VALUES" | sed -n 5p)
	
	m1=$(echo "$m1a" | sed -e 's/ /_/g')


	textstr="$m1${TAB}${TAB}$m2${TAB}$m3${TAB}${TAB}$m4${TAB}$m5"

	sudo sed -i "\$a$textstr" /root/DMR_Hosts.txt
	sudo mount -o remount,rw /
	echo -e '\e[1;40m'
	clear
        echo "Updating Hostfiles..."
        sudo /usr/local/sbin/HostFilesUpdate.sh 
        if [ "$?" == "0" ]; then
		echo "Host Files Successfully Updated"	
	else
		echo "Host File Update Failed!"
	fi
	echo ""


}
function readmain
{
echo "ReadMain"
fname="/usr/local/etc/DMR_Hosts.txt"
mode=1
linetext=$(tail /usr/local/etc/DMR_Hosts.txt | sed -n '/'"$SVR"'/p')
	if [ -z "$linetext" ]; then
		echo "Nothing Found for $SVR"
		readcustom
	else
		echo "$linetext"
		parseline
		displayline
	fi

}
function readcustom
{
fname="/root/DMR_Hosts.txt"
mode=2
linetext=$(sudo tail /root/DMR_Hosts.txt | sed -n '/'"$SVR"'/p')
		echo "$linetext"
		parseline
		displayline
}

function displayline
{
name="$p1"
sid="0000"
addr="$p3"
passwd="$p4"
port="$p5"

# open fd
exec 3>&1

# Store data to $VALUES variable
VALUES=$(dialog --ok-label "OK" \
	  --backtitle "TGIF Network Special Access Script - VE3RD" \
	  --title "Server Access Data Fields in $fname" \
	  --form "OK to Edit Data Fields or Cancel to Abort Script (No Spaces Anywhere)" \
18 75 0 \
	"     Server Name:" 1 1	"$name" 	1 18 25 0 \
	"       Server ID:" 2 1	"$sid"  	2 18 25 0 \
	"  Server Address:" 3 1	"$addr"  	3 18 25 0 \
	"        Password:" 4 1	"$passwd" 	4 18 25 0 \
	"            Port:" 5 1	"$port"  	5 18 25 0 \
2>&1 1>&3)
response=$?

m1a=$(echo "$VALUES" | sed -n 1p)
m2=$(echo "$VALUES" | sed -n 2p)
m3=$(echo "$VALUES" | sed -n 3p)
m4=$(echo "$VALUES" | sed -n 4p)
m5=$(echo "$VALUES" | sed -n 5p)

m1=$(echo "$m1" |sed -e 's/ /_/g')
m2="0000"
textstr="$m1${TAB}${TAB}$m2${TAB}$m3${TAB}${TAB}$m4${TAB}$m5"


if [ "$response" == "0" ] && [ "$mode" == 1 ]; then
	clear
	echo "Edit Data Line Chosen"	
	readcustom
fi
if [ "$response" == "1" ] && [ "$mode" == 1 ]; then
	echo -e '\e[1;40m'
	clear
	echo "Script Aborted By User"	
	exit
fi

if [ "$response" == "1" ] && [ "$mode" == 2 ]; then
	echo -e '\e[1;40m'
	clear
	echo " Script Aborted By User"
	exit
fi

if [ "$response" == "0" ] && [ "$mode" == 2 ]; then
	if [ -z "$p3" ]; then
		echo " Adding Data Line"
		addline
		echo "Added Data Line to /root/DMR_Hosts.txt"	
	else
		echo "Removing Last Line and Adding New Data"
	 	sudo sed -i '$d' /root/DMR_Hosts.txt 
		addline
	fi
fi
response=""
# close fd
exec 3>&-

}

#######################################################################
whiptail --backtitle "Curtesy of VE3RD" --title "NSS.sh Hostfile Editor Instruction Set" --msgbox --scrolltext --ok-button "OK"  "$(cat nss.info)" 35 145 3>&1 1>&2 2>&3


# show an inputbox
SVR=$(dialog --title "Test for Existence of Server Hostname" \
--backtitle "New TGIF Server Access Script - VE3RD" \
--inputbox "Enter the Server Address (lower case) " 8 60 3>&1 1>&2 2>&3 3>&- )

# get response
response=$?
if [ "$response" == "1" ]; then
	echo -e '\e[1;40m'
	clear
	echo "Script Aborted By User" 
	exit 
fi
if [ -z "$SVR" ]; then
	echo -e '\e[1;40m'
	clear
	echo " No Data Entered - Script Aborted"
	exit
fi

readmain






