#!/bin/bash
#########################################################
#  Nextion TFT Support for Nextion 3.5 Beta by VE3RD 	#
#  Gets all Scripts and support files from github       #
#  and copies them into the Nextion_Support directory   "
#  and copies the NX??? tft file into /usr/local/etc    #
#  and returns a script duration time to the Screen 	#
#  as a script completion flag				#
#							#
#  KF6S/VE3RD                               2024-05-03  #
#########################################################
# Use screen model from command $1
# Valid Screen Names for VE3ZRD - NX3224K024, NX4832K935
declare -i tst

if [ -z "$0" ]; then
	clear
	echo ""
	echo "  No Screen Name Provided"
	echo
        echo "	 Valid Screens -VE3RD NX4832K035  BETA"
	echo " " 
	echo " 	Syntax: gitcopy.sh NX????K???   // Will copy VE3RD Beta Files - Default for Screen"
	echo " 	Adding a second parameter(anything) will provide feedback as the script runs (Commandline)"
	echo " "
	exit
fi
 p1=$(pwd) ; cd .. ; homedir=$(pwd) ; cd "$p1"

s3="NX4832K035"
errtext="Error! - Aborting"

## Strip off .tft - Take only the first 10 characters
scn=$(echo "$s3" | tr [:lower:] [:upper:])
#tr [:lower:] [:upper:]
scn="${scn:0:10}"

#Feed back is off by default - Turn it on with anything as parameter  2
fb="$2"
#Set Call to VE3ZRD
calltxt="VE3ZRD"


## Programmed Shutdown
function exitcode
{
	echo "Script Execution Failed "
	echo "$scn"
	echo "$errtext"
	exit

}

function cleandirs()
{
if [ -d /usr/local/etc/Nextion_Support ]; then
    sudo rm -R /usr/local/etc/Nextion_Support
fi
if [ -d "$homedir"/Nextion_Temp ]; then
    sudo rm -R "$homedir"/Nextion_Temp
fi
if [ -f /usr/local/etc/"$model$tft" ]; then
	sudo rm /usr/local/etc/NX*.tft
fi
if [ "$fb" ]; then
    echo "Removed /usr/local/etc/Nextion_Support Directory"
    echo "Removed "$homedir"/Nextion_Temp Directory"
    echo "Remove Existing $model$tft"
fi

}


function ChkColorSet()
{
	if [ ! -f  /etc/Colors.ini ]; then
		cp /usr/local/etc/Nextion_Support/Colors.ini /etc/
	fi

	if [ ! -f  /etc/profiles.txt ]; then
		cp /usr/local/etc/Nextion_Support/profiles.txt /etc/
	fi
}


# VE3ZRD Script Function
function getve3zrdbeta
{
	tst=0
#	echo "Function VE3ZRD"
	calltxt="VE3ZRD"

	if [ "$scn" == "NX4832K035" ]; then
		cleandirs
#	  	sudo git clone --depth 1 https://github.com/VE3ZRD/NX4832K035-KDO "$homedir"/Nextion_Temp
	  	sudo git clone --depth 1 https://github.com/TGIF_Network/NX4832K035-Beta "$homedir"/Nextion_Temp
		sudo chmod +x "$homedir"/Nextion_Temp/*.sh
		mkdir /usr/local/etc/Nextion_Support
		sudo rsync -avqru "$homedir"/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX* 
		sudo cp "$homedir"/Nextion_Temp/"$model$tft" /usr/local/etc/
		if [ "$fb" ]; then
		    	echo "Downloaded new VE3ZRD Screen package for $model$tft"
			echo "Copied new tft to /usr/local/etc/"	
		fi
     	fi
	
	tst=2	
	
	if [ "$tst" == 0 ]; then
		errtext="Invalid VE3ZRD Screen Name $scn"	
		exitcode 
	fi
}


#### Start of Main Code


#echo "$scn  - $call" 
if [ "$fb" ]; then
	        if [ "$scn" != "$s1" -a "$scn" != "$s3" ]; then
              		echo "VE3ZRD Screen Name MUST be NX4832K035"
                       	errtext="Invalid VE3ZRD Screen Name"
                        exitcode
		else
			echo "Loading VE3ZRD $scn Screen Package"
                fi
fi

#echo " End Processing Parameters  - $scn $call"

#Start Duration Timer
start=$(date +%s.%N)

#Disable all command feedback
if [ ! "$fb" ]; then
	exec 3>&2
	exec 2> /dev/null 
fi

model="$scn"
tft='.tft' 
#gz='.gz'
#Put Pi-Star file system in RW mode
sudo mount -o remount,rw /
sleep 1s

#Stop the cron service
sudo systemctl stop cron.service  > /dev/null

# Using "$homedir"/Nextion_Temp/


getve3zrdbeta
 
model="$scn"

 ChkColorSet

 FILE=/usr/local/etc/"$model$tft"
 if [ ! -f "$FILE" ]; then
        # Copy failed
      echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sudo systemctl start cron.service  > /dev/null

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f secs" $duration`

if [ ! "$fb" ]; then
 exec 2>&3
fi 


# echo "$scn Ready  $execution_time"
echo "Beta $scn Ready! $execution_time"


