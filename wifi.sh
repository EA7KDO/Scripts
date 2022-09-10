#!/bin/bash
############################################################
#  This script will scan and Set WIFI                      #
#                                                          #
#  VE3RD                              Created 2022/08/01   #
############################################################
#set -o errexit
#set -o pipefail
#set -e

sudo mount -o remount,rw / > /dev/null

trap ctrl_c INT

function ctrl_c() {
  exit
}

export NCURSES_NO_UTF8_ACS=1
clear
echo -e "\e[1;97;44m"
tput setab 4
clear

##Set default colors
sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc
sudo sed -i '/tag_color = /c\tag_color = (YELLOW,BLUE,OFF)' ~/.dialogrc
sudo sed -i '/tag_key_color = /c\tag_key_color = (YELLOW,BLUE,OFF)' ~/.dialogrc
sudo sed -i '/tag_key_selected_color = /c\tag_key_selected_color = (YELLOW,BLUE,ON)' ~/.dialogrc

Mode="RO"
CallSign=""
DID=""

RED='\033[0;31m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

mode=$1
if [ -z "$mode" ]; then
mode="RO"
fi

function Home(){
ssid="TP-LINK_DB09"
pwd="Passport135"

# sudo nmcli dev wifi connect "TP-LINK_DB09" password "Password135"
 sudo nmcli dev wifi connect "$ssid" password "$pwd"

 return 
}

function Phone(){
ssid="TP-LINK_DB09M"
pwd="Passport135"
# sudo nmcli dev wifi connect "TP-LINK_DB09M" password "Password135"
 sudo nmcli dev wifi connect "$ssid" password "$pwd"
 
return 
}



function SafetyCheck(){
dialog \
	--stdout \
	--ascii-lines \
       --backtitle "Hotspot Configurator - by VE3RD" \
	--clear \
	--yesno "Do you want to Set your WiFi to $ssid" 7 50 

exitcode=$?
if [ $exitcode ==  0 ]; then
	sudo nmcli dev wifi connect "$ssid" password "$pwd"
fi


}
#########  Start of Functions  ################
function ScanWiFi(){

options=$( iwlist wlan0 scan |grep -wv \x00 | grep ESSID | cut -d ":" -f2 |  awk '{print $1, FNR, "N/A"}')
ssid=$(dialog \
	--ascii-lines \
       --backtitle "Hotspot Configurator - by VE3RD" \
	--title "WiFi ESSID Selector" \
        --stdout \
      --radiolist "Select ESSID from the following List:" 22 90 16 \
        "${cmd[@]}" ${options})

exitcode=$?

ssid=$(echo "$ssid" | tr -d '"')

if [ $exitcode -eq 0 ]; then
pwd=$(dialog \
	--stdout \
	--ascii-lines \
	--inputbox "Enter your Password for $ssid" 20 30 )

	dialog \
        	--stdout \
		--ascii-lines \
		--title "Selected ESID $ssid   MODE = $Mode" \
        	--infobox "\nResults Ready to Set\n\nESSID = $ssid\nPassw = $pwd\n\n" 20 80  
	SafetyCheck
fi


}

if [ "$1" == "Home" ]; then
	Home
	exit
fi

if [ "$1" == "Phone" ]; then
	Phone
	exit
fi


ScanWiFi
