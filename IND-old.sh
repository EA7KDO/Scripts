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

arg1="$?"

export NCURSES_NO_UTF8_ACS=1

if [ -f ~/.dialog ]; then
 j=1
else
 sudo dialog --create-rc ~/.dialogrc
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
echo " " 
echo " If this is a fresh pi-star install - Select Uppdate" 
echo " This will do a pistar update before installing the Driver" 
echo " " 
echo " Selecting Start will install the driver without doing the Update" 
echo " " 
echo " This script Installs the Nextion Driver. It will require a reboot " 
echo " Part way through the procedure. After the Reboot, run this script again" 
echo " and select 'Continue' in the following menu" 
echo " " 
sleep 3

continue=0
####################
function cleandriver(){

	#Remove NextionDriver Section
	sed -i '/\[NextionDriver/,/^$/d' /etc/mmdvmhost
	echo "Removing Nextion Driver Configuration"
	#Reset Nextion Port
        tport="/dev/ttyUSB0"
        TOPort=$(echo "$tport" | sed "s/\//\\\\\//g")
        echo "Setting Nextion Port to /dev/ttyUSB0 for Pi-Star"
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1'"$TOPort"'/m;P;d'  /etc/mmdvmhost
	
	if [ -f /etc/mmdvmhost.old ]; then
		#Remove /etc/mmdvmhost.old
		echo "Removing old /etc/mmdvmhost.old"
		sudo rm /etc/mmdvmhost.old
	fi
	echo "Configuration Removed - Restarting Script"
       sleep 2
}



function preparedir
{
                if [ -d /Nextion ] ; then
                        sudo rm -R /Nextion
                fi
		sudo git clone https://github.com/on7lds/NextionDriverInstaller.git /Nextion/
}
####################
function preparedir2 () {
  if [ ! -d /Nextion ] ; then
             echo "Downloading Files to create /Nextion Directory"
                sudo git clone https://github.com/on7lds/NextionDriverInstaller.git /Nextion/
  fi

}
##################
function installnxd
{

		echo " "
		echo "STARTING NEXTION DRIVER INSTALLATION"
		echo " "
		echo "Remove Existing Nextion Driver"
		sudo mount -o remount,rw /

		#Remove the Nextion Driver if it exists
                if [ -f /usr/local/bin/NextionDriver ] ; then
			sudo rm /usr/local/bin/NextionDriver
		fi
		sudo mount -o remount,rw /

		#Download the driver to /Nextion/
		echo "Remove /Nextion Install Directory"
                if [ -d /Nextion ] ; then
                        sudo rm -R /Nextion
                fi
		sudo mount -o remount,rw /
		echo "Get Files from github"
		 sudo git clone https://github.com/on7lds/NextionDriverInstaller.git /Nextion/

		#Check to ensure we created the Install Directory
                if [ -d /Nextion ] ; then
                        echo "Install Directory created ok"
		else
			echo "Failed to Create Install Directory- Check RW Permissions"
			exit
                fi


		#Run the Install Script
		echo "Running the Install Script"
		sudo mount -o remount,rw /
		sudo /Nextion/install.sh 
		
    		exit

}

function clearcomments()
{
sed '/DMRid/s/^#//g' -i /etc/mmdvmhost

}
##############################  MAIN PROGRAM #################
if [ ! -d /temp ] ; then
   sudo mkdir /temp
fi


HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=10
BACKTITLE="This SCRIPT will Install the Nextion Driver,  BC,  and Firewall Rule  - VE3RD $ver"
TITLE="Main Menu - Nextion Driver Installation"
MENU="Select your Installation Mode"

OPTIONS=(1 "Pi-Star Update + Install Nextion Driver"
         2 "Install Nextion Driver - No Update"
         3 "Continue after Reboot from Option 1 or 2"
	 4 "Check Nextion Driver Installation"
	 5 "Update stripped.csv"
	 6 "Remove NextionDriver Configuration"
	 7 "Download & Install Nextion Screen Support Files"
	 8 "Quit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
echo -e '\e[1;37m'
case $CHOICE in
        1)
            echo "You Chose Pi-Star Update + Install"
	        sudo systemctl stop cron.service

		sudo mount -o remount,rw /
		sudo pistar-update
		sudo mount -o remount,rw /
		installnxd
            ;;
        2)
            echo "You Chose Install - No Update"
		installnxd
            ;;
        3)
            echo "You Chose Continue after Reboot"
		continue=1
            ;;
	4)
	    echo "Checking Nextion Driver Installation"
		preparedir2
		sudo /Nextion/check_installation.sh
		echo "Sleeping 7 Seconds before re-staring the script"
		sleep 7
		sudo ./IND.sh
	   ;;
	5)
		sudo wget https://database.radioid.net/static/user.csv  --output-document=/usr/local/etc/stripped.csv
#		sudo rsync -avqru /home/pi-star/Nextion_Temp/stripped2.csv  /usr/local/etc/
		exit
	   ;;
	6)
            	echo "You chose to Remove the NextionDriver Configuration"
		cleandriver
		sudo ./IND.sh
	   ;;
	7)
            	echo "This function will install the Nextion Support Files"
		sudo ./gitcopy2.sh
		sudo ./IND.sh 
	   ;;
	8)   echo " You Chose to Quit"
		exit

	;;
esac

clear
echo "Checking Nextion Driver Installation"
echo ""
	preparedir2
	sudo /Nextion/check_installation.sh
echo "Sleeping 3 seconds"
        sleep 3

echo " "

sudo mount -o remount,rw /

sudo chmod 755 /usr/local/sbin/nextion*
sudo sed -i '/^\[/h;G;/Nextion]/s/\(Brightness=\).*/\199/m;P;d'  /etc/mmdvmhost
sudo sed -i '/^\[/h;G;/Nextion]/s/\(IdleBrightness=\).*/\199/m;P;d'  /etc/mmdvmhost
sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(LogLevel=\).*/\12/m;P;d'  /etc/mmdvmhost
sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost


if [ -d /home/rock/ ]; then
	tport="/dev/ttyAML0"
	TOPort=$(echo "$tport" | sed "s/\//\\\\\//g")
	echo "Setting NextionDriver Port to /dev/ttyAML0 for the RadXA Board"
	sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1'"$TOPort"'/m;P;d'  /etc/mmdvmhost
else
	tport="/dev/ttyUSB0"
	TOPort=$(echo "$tport" | sed "s/\//\\\\\//g")
	echo "Setting NextionDriver Port to /dev/ttyUSB0 for Pi-Star"
	sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1'"$TOPort"'/m;P;d'  /etc/mmdvmhost
fi
	echo "$TOPort"
sleep 2

TITLE="Second Level Menue - Continue"
MENU="Choose your Screen-to-Pi Interface"

OPTIONS=(1 "USB to TTL Interface"
         2 "GPIO Pins"
	 3 "Quit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
sudo mount -o remount,rw /

case $CHOICE in

         1)   		echo "Setting the Port to TTL Adapter, and ScreenLayout to 4 ON7LDSHS LS "
			sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1\/dev\/ttyUSB0/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(ScreenLayout=\).*/\14/m;P;d'  /etc/mmdvmhost
			# if using TTL_Adapter set WaitForLan=0 we do not need to wait for LAN if using USB for screen
			sudo sed -i '/^\[/h;G;/NextionDriver/s/\(WaitForLan=\).*/\10/m;P;d'  /etc/mmdvmhost
			if [ -d /home/rock/ ]; then
        			tport="/dev/ttyAML0"
        			TOPort=$(echo "$tport" | sed "s/\//\\\\\//g")
        			echo "Setting NextionDriver Port to /dev/ttyAML0 for the RadXA Board"
        			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1'"$TOPort"'/m;P;d'  /etc/mmdvmhost
			fi

			sleep 3
		;;
        2)
            		echo "Setting the Ports to GPIO, ScreenLayout to 3 ON7LDSHS"
			sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1\/dev\/ttyAMA0/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(ScreenLayout=\).*/\13/m;P;d'  /etc/mmdvmhost                        
			sleep 3
            	;;
        3)
			exit            	
            	;;
        	*) echo "invalid option $REPLY";;
    	esac
        echo " "

        m1=$(sudo sed -n '/^[ \t]*\[Nextion\]/,/\[/s/^[ \t]*DisplayTempInFahrenheit[^#; \t]*=[ \t]*//p' /etc/mmdvmhost)
	sudo mount -o remount,rw /

        if [ -z "$m1" ]; then
                sudo mount -o remount,rw /

                p1="/^\[Nextion\]/,/^\[/ { x; /^$/ !{ x; H }; /^$/ { x; h; }; d; }; x; /^\[Nextion\]/ "
                p2=" { s/\(\n\+[^\n]*\)$/\nDisplayTempInFahrenheit=0\1/; p; x; p; x; d }; x"
                sudo sed -i "$p1$p2" /etc/mmdvmhost
         fi



#TITLE="Select Temperature Mode"
MENU="Select your Temperature Display Type"

OPTIONS=(1 "Fahrenheit"
         2 "Celcius"
	 3 "Quit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
                1)
                        echo "Fahrenheit Selected"
			sudo sed -i '/^\[/h;G;/Nextion/s/\(DisplayTempInFahrenheit=\).*/\11/m;P;d'  /etc/mmdvmhost                        
			sleep 3 
               ;;

                2)
                        echo "Celcius Selected "
			sudo sed -i '/^\[/h;G;/Nextion/s/\(DisplayTempInFahrenheit=\).*/\10/m;P;d'  /etc/mmdvmhost
			sleep 3
                ;;
                3)
			exit
                ;;
        esac

	sudo mount -o remount,rw /

	# Clear all comment flags on Nextion Driver Block, DMRid lines
	sudo sed '/DMRid/s/^#//g' -i /etc/mmdvmhost

	#Reset DMRidx State and Country Fields
	sudo sed -i '/^\[/h;G;/NextionDriver/s/\(DMRidX1=\).*/\15/m;P;d'  /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/NextionDriver/s/\(DMRidX2=\).*/\16/m;P;d'  /etc/mmdvmhost

	#Set UserDataMask Fields if not already there.
	if grep -Fq SendUserDataMask /etc/mmdvmhost; then
        	echo "SendUserDataMask Found"
 	else
        	echo "Inserting SendUserDataMask"
        	sed -i '/^\[NextionDriver\]/a\SendUserDataMask=0b00011110' /etc/mmdvmhost
	fi



	echo "Installing BC"
	sudo apt-get install bc

	sudo mount -o remount,rw /
	sudo mount -o remount,rw /

	sudo rm -R /temp
	sudo sh -c 'echo "iptables -A OUTPUT -p tcp --dport 5040 -j ACCEPT" > /root/ipv4.fw'

echo -e '\e[1;33m'
echo ""
	if [ ! -f /etc/cron.daily/getstripped ]; then
		echo "setting getstripped to run in daily crontab"
		sudo cp /home/pi-star/Scripts/getstripped.sh /etc/cron.daily/getstripped
	else
		echo "getstripped found in /etc/cron.daily/"
		echo "No Action Required!"
	fi

echo ""

echo -e '\e[1;37m'

sleep 3

	sudo pistar-firewall

	#rm -R /Nextion
	sudo mount -o remount,rw /
        
	if [ -f /home/pi-star/ndis.txt ]; then
	sudo  rm /home/pi-star/ndis.txt
	fi

sleep 3
sudo wget https://database.radioid.net/static/user.csv  --output-document=/usr/local/etc/stripped.csv


	echo "Nextion Driver Installation Completed"
	echo "Auxilliary Function Installation Completed"
	echo "Rebooting Pi-Star in 3 seconds"
sleep 5

echo -e '\e[1;40m'
clear
sleep 3
	sudo reboot


