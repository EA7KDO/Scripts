#!/bin/bash
###############################################################
#  This script will flash the TFT File ino The Nextion Screen #
#                                                             #
#  VE3RD                                      2020/04/07      #
###############################################################
set -o errexit
set -o pipefail

export NCURSES_NO_UTF8_ACS=1

## Programmed Shutdown
function exitcode
{
        echo "Script Execution Failed "
        echo "$scn"
        echo "$errtext"
	tput sgr0 
       clear 
       exit

}

function killservices
{

			echo "Stopping services - Reboot Required after This Script Finishes"

			sudo systemctl stop pistar-watchdog > /dev/null
			sudo systemctl stop mmdvmhost.timer > /dev/null
			sudo systemctl stop mmdvmhost.service > /dev/null
			sudo systemctl stop cron.service  > /dev/null
			sudo systemctl stop mmdvmhost.service  > /dev/null
			sudo systemctl stop mmdvmhost.timer > /dev/null
			sudo systemctl stop nextiondriver.service  > /dev/null

			echo "Services Stopped"

}
function flashscreen
{
			sudo python nextion.py "$pathstr" /dev/ttyUSB0
			echo "Rebooting ......"
			sudo reboot
}

errtxt="Nothing"

if [ -f ~/.dialog ]; then
 j=1
else
 dialog --create-rc ~/.dialogrc
fi
#use_colors = ON
#screen_color = (WHITE,BLUE,ON)
#title_color = (YELLOW,RED,ON)
sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc

echo -e '\e[1;44m'
clear
sudo mount -o remount,rw /
homedir=/home/pi-star/
curdir=$(pwd)
clear

declare -i tst
tst=0

found1=$(sudo sh -c 'echo ls /usr/local/etc/NX*.tft' | cut -d' ' -f2)
found2=$(sudo sh -c 'echo ls /usr/local/etc/NX*.tft' | cut -d' ' -f3)
found3=$(sudo sh -c 'echo ls /usr/local/etc/NX*.tft' | cut -d' ' -f4)

if [ "$found3" ]; then
	errtext="Too Many Screen files found in /ust/loca/etc/"
	echo "Script Aborted"
	exitcode
fi

if [ -z "$found1" ]; then
 errtext=" Sorry!  = Cannot find a Screen type in /usr/local/etc/"
 echo " Script Aborted!"
 exitcode
fi

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=5
BACKTITLE="Nextion Screen Flash Tool - VE3RD"
TITLE="Flash Selected Screen Type"
MENU="Select your Screen Type from List Found"

if [ -z "$found2" ]; then 
OPTIONS=(1 "Quit"
	 2 "$found1")
else
OPTIONS=(1 "Quit"
	 2 "$found1"
   	 3 "$found2")
fi

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
echo -e '\e[1;44m'

if [ "$found2" ]; then
	case $CHOICE in
        	1)
            		echo "You Chose to Quit"
	   		echo "Script Aborted!"
			tst=0
			echo="You Selected Quit Option at Level 1"
			sed -i '/use_colors = /c\use_colors = OFF' ~/.dialogrc
			tput sgr0 
			clear
			exit
			;;
        	2)
			scn="$found1"
			tst=1
			;;

		3) 
			scn="$found2"
			tst=2
			;;
		esac
else
	case $CHOICE in
        	1)
            		errtext="You Chose to Quit"
	   		echo "You Chose to Abort at Level2"
			echo "Script Aborted!"
			tst=0			
			sed -i '/use_colors = /c\use_colors = OFF' ~/.dialogrc
			tput sgr0 
			clear
			exit
			;;
        	2)
			scn="$found1"
			tst=1
			;;

		esac

fi

#Setup the string for the screen name and location
pathstr="$scn"

if [ -f "$pathstr" ]; then
	echo "File $pathstr Found - Proceeding to Flash"
	tst=1
else 
	echo "File $pathstr NOT Found - Flash Aborted!"
	tst=0
fi;

echo "Screen Type Entered to Flash = $pathstr"

if [ "$tst" > 0 ]; then
HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=5
BACKTITLE="Nextion Screen Flash Tool - VE3RD"
TITLE="You Have Chosen to Flash $scn"
MENU="Select Abort or Proceed"

OPTIONS=(1 "Abort"
	 2 "Proceed")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
echo -e '\e[1;44m'
case $CHOICE in
        1)
            	errtext="You Chose to Abort"
	   	echo "Script Aborted!"
		tst=0		
		exitcode
		;;
        2)
		echo "You Chose to Proceed and Flash the Screen"
		tst=1
		killservices
		flashscreen
		;;
esac

else
         echo "Error Detected - No Action Taken - Script Aborted!"
	 sed -i '/use_colors = /c\use_colors = OFF' ~/.dialogrc
	tput sgr0 
	clear
fi
