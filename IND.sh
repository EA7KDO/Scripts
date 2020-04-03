#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Installing the Nextion Driver 			   #
#							   #
#  VE3RD                                      2020/02/12   #
############################################################
set -o errexit
set -o pipefail
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
 
PS3='Choose the option that reflects what you need done: '
options=("Update" "Start" "Continue" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Update")
		echo "Update Option Chosen"
		sudo pistar-update
		sudo mount -o remount,rw /
		installnxd
            ;;

        "Start")
		installnxd
		break
            ;;
        "Continue")
		echo "Continue Option Chosen"
		continue=1
		break
            ;;
        "Quit")
		exit
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
echo " "


	sudo chmod 755 /usr/local/sbin/nextion*
			sudo sed -i '/^\[/h;G;/Nextion/s/\(Brightness=\).*/\199/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(IdleBrightness=\).*/\199/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver/s/\(LogLevel=\).*/\12/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
	echo " "


	echo "Identify your Inteface"
	PS3='Identify Your Interface: '
	options=("TTL_Adapter" "GPIO" "Quit")
	select opt in "${options[@]}"
	do
    		case $opt in
        	"TTL_Adapter")
            		echo "Setting the Port to TTL Adapter, and ScreenLayout to 3 ON7LDSHS LS "
			sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1\/dev\/ttyUSB0/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(ScreenLayout=\).*/\14/m;P;d'  /etc/mmdvmhost                        
			break
		;;
        	"GPIO")
            		echo "Setting the Ports to GPIO, ScreenLayout to 3 ON7LDSHS"
			sudo sed -i '/^\[/h;G;/Nextion]/s/\(Port=\).*/\1\/dev\/ttyNextionDriver/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(Port=\).*/\1\/dev\/ttyAMA0/m;P;d'  /etc/mmdvmhost                        
			sudo sed -i '/^\[/h;G;/Nextion/s/\(ScreenLayout=\).*/\13/m;P;d'  /etc/mmdvmhost                        
			break
            	;;
        	"Quit")
			exit            	
			break
            	;;
        	*) echo "invalid option $REPLY";;
    	esac
	done
	sudo /Nextion/check_installation.sh
        
        echo " "

        m1=$(sudo sed -n '/^[ \t]*\[Nextion\]/,/\[/s/^[ \t]*DisplayTempInFahrenheit[^#; \t]*=[ \t]*//p' /etc/mmdvmhost)

        if [ -z "$m1" ]; then
                sudo mount -o remount,rw /
sudo sed -i '/^\[Nextion\]/,/^\[/ { x; /^$/ !{ x; H }; /^$/ { x; h; }; d; }; x; /^\[Nextion\]/ { s/\(\n\+[^\n]*\)$/\nDisplayTempInFahrenheit=0\1/; p; x; p; x; d }; x' /etc/mmdvmhost
         fi

        PS3='Select The Temperature Mode:'
        options=("Celcius" "Fahrenheit" "Quit")
        select opt in "${options[@]}"
        do
                case $opt in
                "Celcius")
                        echo "Celcius Selected "
			sudo sed -i '/^\[/h;G;/Nextion/s/\(DisplayTempInFahrenheit=\).*/\10/m;P;d'  /etc/mmdvmhost
                        break
                ;;
                "Fahrenheit")
                        echo "Fahrenheit Selected"
			sudo sed -i '/^\[/h;G;/Nextion/s/\(DisplayTempInFahrenheit=\).*/\11/m;P;d'  /etc/mmdvmhost                        
			break
                ;;
                "Quit")
			exit
                        break
                ;;
                *) echo "invalid option $REPLY";;
        esac
        done


	echo "Installing BC"
	sudo apt-get install bc

	sudo rm -R /temp
	sudo pistar-firewall

	echo "Nextion Driver Installation Completed"
	echo "Rebooting Pi-Star"
	#rm -R /Nextion
        
	if [ -f /home/pi-star/ndis.txt ]; then
	  rm /home/pi-star/ndis.txt
	fi
	sudo reboot


