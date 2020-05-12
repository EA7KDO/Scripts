#!/bin/bash
######################################################################
#  Prime_TGIF_Network Support        	 			     #
#  This Script will test the /usr/local/etc/DMR_Hosts.txt File       #
#  and /root/DMR_Hosts File for the prime.tgif.network IPAddress     #
#  and add the required line to /root/DMR_Hosts.txt if it was 	     #
#  not found in ether file				 	     #
#								     #
#  VE3RD                               			2020-05-12   #
######################################################################
sudo mount -o remount,rw /
export NCURSES_NO_UTF8_ACS=1
declare -i mode=0
declare -r TAB="`echo -e "\t"`"
declare -i slen

linetext=""
fname=""
SVR="prime"
ver="20200512"
sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
#sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (BLACK,CYAN,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc

export NEWT_COLORS='
window=,cyan
border=white,blue
button=yellow,red
'

echo -e '\e[1;44m'

function parseline
{
	clear
 	p1a=$(echo "$linetext" | cut -d$'\t' -f1)
	p1=$(echo "$p1a" | sed -e 's/ /_/g')
	slen=$(expr length "$p1")

if [ "$slen" -le 24 ]; then
 	p2=$(echo "$linetext" | cut -d$'\t' -f3)
 	p3=$(echo "$linetext" | cut -d$'\t' -f4)
 	p4=$(echo "$linetext" | cut -d$'\t' -f6)
 	p5=$(echo "$linetext" | cut -d$'\t' -f7)

fi
if [ "$slen" -le 16 ]; then
 	p2=$(echo "$linetext" | cut -d$'\t' -f4)
 	p3=$(echo "$linetext" | cut -d$'\t' -f5)
 	p4=$(echo "$linetext" | cut -d$'\t' -f7)
 	p5=$(echo "$linetext" | cut -d$'\t' -f8)

fi
if [ "$slen" -le 8 ]; then
 	p2=$(echo "$linetext" | cut -d$'\t' -f5)
 	p3=$(echo "$linetext" | cut -d$'\t' -f6)
 	p4=$(echo "$linetext" | cut -d$'\t' -f8)
 	p5=$(echo "$linetext" | cut -d$'\t' -f9)

fi
	echo "$p1${TAB}${TAB}${TAB}$p2${TAB}$p3${TAB}$p4${TAB}$p5"
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

if [ -z "$m3" ]; then
echo -e '\e[1;44m'
clear
echo " Missing Address - Script Aborting!"
exit
fi

slen=$(expr length "$m1")

if [ "$slen" -le 24 ]; then
	textstr="$m1${TAB}${TAB}$m2${TAB}$m3${TAB}${TAB}$m4${TAB}$m5"
fi
if [ "$slen" -le 16 ]; then
	textstr="$m1${TAB}${TAB}${TAB}$m2${TAB}$m3${TAB}${TAB}$m4${TAB}$m5"
fi
if [ "$slen" -le 8 ]; then
	textstr="$m1${TAB}${TAB}${TAB}${TAB}$m2${TAB}$m3${TAB}${TAB}$m4${TAB}$m5"
fi

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

function displayline
{
if [ -z "$p1" ]; then
	p1="Prime_TGIF_Network"
fi
	name="$p1"
	sid="0000"

if [ -z "$p3" ]; then
	p3="prime.tgif.network"
fi
	addr="$p3"
	passwd="passw0rd"
	port="62031"
	# open fd
	exec 3>&1
header="Press OK to Edit Data Fields or Cancel to Abort Script \n
    - Do Not Use Spaces in the Server Name Field \n
    - Use the UnderScore to separate words"

	# Store data to $VALUES variable
	VALUES=$(dialog --ok-label "OK" \
	  --backtitle "TGIF Network Special Access Script - VE3RD $ver" \
	  --title "Server Access Data Fields in $fname" \
	  --form "$header" 18 75 0 \
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
			echo "Added Data Line to /root/DMR_Hosts.txt and updated /usr/local/etc/DMR_hosts.trxt"	
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

function exitcode
{
exit 1
}
function readmain
{
	echo "ReadMain"
	fname="/usr/local/etc/DMR_Hosts.txt"
	mode=1
	linetext=$(sudo tail /usr/local/etc/DMR_Hosts.txt | sed -n '/'"$SVR"'/p')
	if [ -z "$linetext" ]; then
		echo "Nothing Found for $SVR"
#		readcustom
	else
		echo "$linetext"
		parseline
txt="The following Parameters have been found for the NEW TGIF Server 
If these are correct Press the YES Button 
If they are not correct press the  No button \n\n
    Name: $p1  
      ID: $p2 
 Address: $p3 
Password: $p4 
    Port: $p5 \n "

	sudo whiptail --title "New Server Parameters(If Found)" --yesno "$txt" 25 80
	response1=$?
	fi

	if [ "$response1" == 0 ]; then
		clear
		echo " User Aborted Script"
		exit
	else
		readcustom
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

whiptail --msgbox  "$(cat nss2.info)" --backtitle "Curtesy of VE3RD $ver" --title "NSS.sh Hostfile Editor Instruction Set"   35 145 3>&1 1>&2 2>&3
readmain


