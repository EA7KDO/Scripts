#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Installing the Nextion Driver 			   #
#							   #
#  VE3RD                                      2020/02/12   #
############################################################
set -o errexit
set -o pipefail
export NCURSES_NO_UTF8_ACS=1
sudo mount -o remount,rw /
homedir=/home/pi-star/
curdir=$(pwd)
clear
echo " "
echo " If this is a fresh pi-star install - Select Uppdate"
echo " This will do a pistar update before installing the Driver"
echo " "
echo " Selecting Start will install the driver witout doing the Update"
echo " "
echo " This script Installs the Nextion Driver. It will require a reboot "
echo " Part way through the procedure. After the Reboot, run this script again"
echo " and select 'Continue' in the following menu"
echo " "
continue=0

function installnxd
{
		echo " "
		echo "STARTING NEXTION DRIVER INSTALLATION"
		echo " "
		echo "Remove Existing Nextion Driver"

		#Remove the Nextion Driver if it exists
                if [ -f /usr/local/bin/NextionDriver ] ; then
			sudo rm /usr/local/bin/NextionDriver
		fi

		#Download the driver to /Nextion/
		echo "Remove /Nextion Directory"
                if [ -d /Nextion ] ; then
                        sudo rm -R /Nextion
                fi
		echo "Get Files from github"
		if [ -d /Nextion ]; then
			rm -d /Nextion
		fi
		sudo git clone https://github.com/on7lds/NextionDriverInstaller.git /Nextion/
		#Run the Install Script
		echo "Run the Install Script"
		sudo /Nextion/install.sh 
		
    		exit

}


if [ ! -d /temp ] ; then
   sudo mkdir /temp
fi

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=5
BACKTITLE="Nextion Driver & Support Install Script"
TITLE="Install Nextion Driver Main Menu"
MENU="Choose one of the following options:"

OPTIONS=(1 "Pi-Star Update + Install Nextion Driver"
         2 "Install Nextion Driver - No Update"
         3 "Continue after Reboot"
	 4 "Quit")

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
            echo "You Chose Pi-Star Update + Install"
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
	4)   echo " You Chose to Quit"
		exit

	;;
esac

clear

echo " "


	sudo chmod 755 /usr/local/sbin/nextion*
			sudo sed -i '/^\[/h;G;/Nextion/s/\(Brightness=\).*/\199/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(IdleBrightness=\).*/\199/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver/s/\(LogLevel=\).*/\12/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
	echo " "

TITLE="Select Your Screen to Pi Interface"
MENU="Choose one of the following options:"

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
case $CHOICE in

         1)   		echo "Setting the Port to TTL Adapter, and ScreenLayout to 3 ON7LDSHS LS "
			sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1\/dev\/ttyUSB0/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(ScreenLayout=\).*/\14/m;P;d'  /etc/mmdvmhost
			# if using TTL_Adapter set WaitForLan=0 we do not need to wait for LAN if using USB for screen
			sudo sed -i '/^\[/h;G;/NextionDriver/s/\(WaitForLan=\).*/\10/m;P;d'  /etc/mmdvmhost
		;;
        2)
            		echo "Setting the Ports to GPIO, ScreenLayout to 3 ON7LDSHS"
			sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1\/dev\/ttyAMA0/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(ScreenLayout=\).*/\13/m;P;d'  /etc/mmdvmhost                        
            	;;
        3)
			exit            	
            	;;
        	*) echo "invalid option $REPLY";;
    	esac
	sudo /Nextion/check_installation.sh
        
        echo " "

        m1=$(sudo sed -n '/^[ \t]*\[Nextion\]/,/\[/s/^[ \t]*DisplayTempInFahrenheit[^#; \t]*=[ \t]*//p' /etc/mmdvmhost)

        if [ -z "$m1" ]; then
                sudo mount -o remount,rw /
sudo sed -i '/^\[Nextion\]/,/^\[/ { x; /^$/ !{ x; H }; /^$/ { x; h; }; d; }; x; /^\[Nextion\]/ { s/\(\n\+[^\n]*\)$/\nDisplayTempInFahrenheit=0\1/; p; x; p; x; d }; x' /etc/mmdvmhost
         fi



TITLE="Select Temperature Mode"
MENU="Choose one of the following options:"

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
                ;;

                2)
                        echo "Celcius Selected "
			sudo sed -i '/^\[/h;G;/Nextion/s/\(DisplayTempInFahrenheit=\).*/\10/m;P;d'  /etc/mmdvmhost
                ;;
                3)
			exit
                ;;
        esac


	echo "Installing BC"
	sudo apt-get install bc

	sudo mount -o remount,rw /

	sudo rm -R /temp
	sudo sh -c 'echo "iptables -A OUTPUT -p tcp --dport 5040 -j ACCEPT" > /root/ipv4.fw'

	sudo pistar-firewall

	echo "Nextion Driver Installation Completed"
	echo "Rebooting Pi-Star"
	#rm -R /Nextion
        
	if [ -f /home/pi-star/ndis.txt ]; then
	sudo  rm /home/pi-star/ndis.txt
	fi
	sudo reboot


