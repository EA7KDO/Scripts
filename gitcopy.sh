#!/bin/bash
#########################################################
#  Nextion TFT Support for Nextion 2.4" 		#
#  Gets all Scripts and support files from github       #
#  and copies them into the Nextion_Support directory   "
#  and copies the NX??? tft file into /usr/local/etc    #
#  and returns a script duration time to the Screen 	#
#  as a script completion flag				#
#							#
#  KF6S/VE3RD                               2021-12-21  #
#########################################################
# Use screen model from command $1
# Valid Screen Names for EA7KDO - NX3224K024, NX4832K935
declare -i tst

if [ -z "$1" ]; then
	clear
	echo ""
	echo "  No Screen Name Provided"
	echo
        echo "	 Valid Screens - EA7KDO) - NX3224K024, NX4832K035"
	echo " " 
	echo " 	Syntax: gitcopy.sh NX????K???   // Will copy EA7KDO Files - Default for Screen"
	echo " 	Adding a second parameter(anything) will provide feedback as the script runs (Commandline)"
	echo " "
	exit
fi
 p1=$(pwd) ; cd .. ; homedir=$(pwd) ; cd "$p1"

s1="NX3224K024"
s3="NX4832K035"
errtext="Error! - Aborting"

## Strip off .tft - Take only the first 10 characters
scn=$(echo "$1" | tr [:lower:] [:upper:])
#tr [:lower:] [:upper:]
scn="${scn:0:10}"

#Feed back is off by default - Turn it on with anything as parameter  2
fb="$2"
#Set Call to EA7KDO
calltxt="EA7KDO"

#echo "$scn"

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

# EA7KDO Script Function
function getea7kdo
{
	tst=0
#	echo "Function EA7KDO"
	calltxt="EA7KDO"

    	if [ "$scn" == "NX3224K024" ]; then
		cleandirs
	  	sudo git clone --depth 1 https://github.com/EA7KDO/NX3224K024 "$homedir"/Nextion_Temp
		chmod +x "$homedir"/Nextion_Temp/*.sh
		mkdir /usr/local/etc/Nextion_Support
		sudo rsync -avqru "$homedir"/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX* 
		sudo cp "$homedir"/Nextion_Temp/"$model$tft" /usr/local/etc/
		if [ "$fb" ]; then
		    	echo "Downloaded new Screen package for $model$tft"
			echo "Copied new tft to /usr/local/etc/"	
		fi
tst=1		
	fi     
	if [ "$scn" == "NX4832K035" ]; then
		cleandirs
	  	sudo git clone --depth 1 https://github.com/EA7KDO/NX4832K035 "$homedir"/Nextion_Temp
		sudo chmod +x "$homedir"/Nextion_Temp/*.sh
		mkdir /usr/local/etc/Nextion_Support
		sudo rsync -avqru "$homedir"/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX* 
		sudo cp "$homedir"/Nextion_Temp/"$model$tft" /usr/local/etc/
		if [ "$fb" ]; then
		    	echo "Downloaded new Screen package for $model$tft"
			echo "Copied new tft to /usr/local/etc/"	
		fi
     	fi
tst=2	
	if [ "$tst" == 0 ]; then
		errtext="Invalid EA7KDO Screen Name $scn"	
		exitcode 
	fi
}


#### Start of Main Code


#echo "$scn  - $call" 
if [ "$fb" ]; then
	        if [ "$scn" != "$s1" -a "$scn" != "$s3" ]; then
              		echo "EA7KDO Screen Name MUST be NX3224K024 or NX4832K035"
                       	errtext="Invalid EA7KDO Screen Name"
                        exitcode
		else
			echo "Loading EA7KDO $scn Screen Package"
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


getea7kdo
 
model="$scn"



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
echo "$scn Ready to Flash! $execution_time"



