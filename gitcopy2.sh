#!/bin/bash
#########################################################
#  Nextion TFT Support for Nextion 2.4" 		#
#  Gets all Scripts and support files from github       #
#  and copies them into the Nextion_Support directory   "
#  and copies the NX??? tft file into /usr/local/etc    #
#  and returns a script duration time to the Screen 	#
#  as a script completion flag				#
#							#
#  KF6S/VE3RD                               2020-05-12  #
#########################################################
# Valid Screen Names for EA7KDO - NX3224K024, NX4832K035
# Valid Screen Names for VE3RD - NX3224K024

#if [[ $EUID -ne 0 ]]; then
#	clear
#	echo ""
 #  	echo "This script must be run as root"
#	echo "Setting root user"
#	echo "Re-Start Script"
#	echo ""
#	sudo su
  # 	exit 1
#fi
p1=$(pwd) ; cd .. ; homedir=$(pwd) ; cd "$p1"

who=$(whoami)
echo "This script is running as $who user"
sleep 2

run=""

errtext="This is a test"


parm1="$1"
parm2="$2"
ver="20220124"
declare -i tst

export NCURSES_NO_UTF8_ACS=1
export LANG=en_US.UTF-8

if [ ! -f ~/.dialog ]; then
# j=1
# else
 sudo dialog --create-rc ~/.dialogrc
fi

sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc
echo -e '\e[1;44m'

if [ -z "$1" ]; then
	clear
fi

function exitcode
{
txt='Abort Function\n\n
This Script will Now Stop'"\n$errtext"

dialog --title "  Programmed Exit  " --ascii-lines --msgbox "$txt" 8 78

clear
echo -e '\e[1;40m'
run="Done"
exit

}



# EA7KDO Script Function
function getea7kdo
{
	tst=0
#	echo "Function EA7KDO"
	calltxt="EA7KDO"

if [ -d "$homedir"/Nextion_Temp ]; then
  	sudo rm -R "$homedir"/Nextion_Temp
fi

    	if [ "$scn" == "NX3224K024" ]; then
	  	sudo git clone --depth 1 https://github.com/EA7KDO/NX3224K024 "$homedir"/Nextion_Temp
		tst=1
	fi     
	if [ "$scn" == "NX4832K035" ]; then
	  	sudo git clone --depth 1 https://github.com/EA7KDO/NX4832K035 "$homedir"/Nextion_Temp
		tst=2
     	fi
	
}

# VE3RD Script Function
function getve3rd
{
if [ -d "$homedir"/Nextion_Temp ]; then
  	sudo rm -R "$homedir"/Nextion_Temp
fi
	tst=0
#	echo "Function VE3RD"
     	
	calltxt="VE3RD"
	if [ "$scn" = "NX3224K024" ]; then	
	 	tst=1  
	  	sudo git clone --depth 1 https://github.com/VE3RD/Nextion "$homedir"/Nextion_Temp
	elif [ "$scn" == "NX4832K035" ]; then
	  	sudo git clone --depth 1 https://github.com/VE3RD/NX4832K035 "$homedir"/Nextion_Temp
		tst=2
	else
		errtext="Invalid VE3RD Screen Name $scn,  $s1,  $s2"
		exitcode 
	fi

}

function getcall
{
#Set Screen Author
calltxt=""
if [ "$parm2" == VE3RD ] || [ "$parm1" == VE3RD ] ; then
	calltxt="VE3RD"
else
	calltxt="EA7KDO"
fi
}


#### Start of Main Code

## Select User Screens
getcall
S1=""
S2=""
if [ -f "/usr/local/etc/NX4832K035.tft" ]; then
   S1="NX4832K035"
   S1A=" Available     "
else 
   S1="NX4832K035"
   S1A=" Not Available "
fi
if [ -f "/usr/local/etc/NX3224K024.tft" ]; then
   S2="NX3224K024"
   S2A=" Available     "
else
   S2="NX3224K024"
   S2A=" Not Available "
fi


result=(dialog --backtitle "Screen Selector - $calltxt" --ascii-lines --menu "Choose Your $calltxt Nextion Screen Model" 22 76 16)

options=(1 "$S1A 3.5 Inch Nextion Screen"
         2 "$S2A 2.4 Inch Nextion Screen"
         3 " Abort - Exit Script")

choices=$("${result[@]}" "${options[@]}" 2>&1 >/dev/tty)

#errt="$?"
clear
echo "Choice = $choices"

if [ -z "$choices" ]; then
#if [ "$choices" != "1" ] || [ "$choices" != "2" ] || [ "$choices" != "3" ]; then
  errtext="Cancel Button Pressed"
  exitcode
fi

for choice in $choices
do
    case $choice in
        1)
            echo "$S1A 3.5 Inch Nextion Screen Selected"
		scn="NX4832K035"
            ;;
        2)
            echo "$S2A 2.4 Inch Nextion Screen Selected"
		scn="NX3224K024"
            ;;
        3)
            echo "Abort - Exit Script"
		errtext="Abort Selected"
		exitcode
            ;;
    esac
done


if [ "$calltxt" == "VE3RD" ]; then
	if [ "$result" == "NX3224K024" ]; then
#echo "Trap2"
		scn="$result"
	else
#echo "Trap3"
		errtext=" Invalid  Screen name for $calltxt"
	fi
fi

echo "$scn $calltxt"


#echo " End Processing Parameters  - $scn $calltxt"

#Start Duration Timer
start=$(date +%s.%N)

model="$scn"
tft='.tft' 
#gz='.gz'
#Put Pi-Star file system in RW mode
sudo mount -o remount,rw / > /dev/null
sleep 1s

#Stop the cron service
sudo systemctl stop cron.service  > /dev/null


#Test for "$homedir"/Nextion_Temp and remove it, if it exists

if [ -d "$homedir"/Nextion_Temp ]; then
  	sudo rm -R "$homedir"/Nextion_Temp
fi

  # Get Nextion Screen/Scripts and support files from github
  # Get EA7KDO File Set

if [ "$calltxt" == "EA7KDO" ]; then
	echo "getting Screens for $calltxt"
	getea7kdo
 
fi


  # Get VE3RD File Set
if [ "$calltxt" == "VE3RD" ]; then
	echo "Getting Screens for $calltxt"
	getve3rd
fi


if [ ! -d /usr/local/etc/Nextion_Support ]; then
	sudo mkdir /usr/local/etc/Nextion_Support
else
       sudo rm -R /usr/local/etc/Nextion_Support
	sudo mkdir /usr/local/etc/Nextion_Support
fi

sudo chmod +x "$homedir"/Nextion_Temp/*.sh
sudo rsync -avqru "$homedir"/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX* --exclude=profiles.txt

sudo rsync -avqru "$homedir"/Scripts/stripped2.csv  /usr/local/etc/
sudo mount -o remount,rw / 
sudo wget https://database.radioid.net/static/user.csv -O /usr/local/etc/stripped.csv

if [ -f "$homedir"/Nextion_Temp/profiles.txt ]; then
	if [ ! -f /usr/local/etc/Nextion_Support/profiles.txt ]; then
        	if [ "$fb" ]; then
			txtn= "Replacing Missing Profiles.txt"
			txt="$txt\n""$txtn"
        	fi
        	sudo cp  "$homedir"/Nextion_Temp/profiles.txt /usr/local/etc/Nextion_Support/
	fi
fi

model="$scn"
    echo "Remove Existing $model$tft and copy in the new one"
txtn="Remove Existing $model$tft and copy in the new one"
txt="$txt""$txtn"

if [ -f /usr/local/etc/"$model$tft" ]; then
	sudo rm /usr/local/etc/NX*K*.tft
fi
sudo cp "$homedir"/Nextion_Temp/"$model$tft" /usr/local/etc/


 FILE=/usr/local/etc/"$model$tft"
 if [ ! -f "$FILE" ]; then
        # Copy failed
      	echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sudo systemctl start cron.service  > /dev/null

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`


txt="$calltxt Scripts Loaded: $execution_time"
#whiptail --title "$title" --msgbox "$txt" 8 90
dialog --title "  $title  " --ascii-lines --msgbox "$txt" 8 78

echo -e '\e[1;40m'

if [ -z "$1" ]; then
	clear
fi

sudo mount -o remount,ro /
exit
