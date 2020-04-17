#!/bin/bash
#########################################################
#  Nextion TFT Support for Nextion 2.4" 		#
#  Gets all Scripts and support files from github       #
#  and copies them into the Nextion_Support directory   "
#  and copies the NX??? tft file into /usr/local/etc    #
#  and returns a script duration time to the Screen 	#
#  as a script completion flag				#
#							#
#  KF6S/VE3RD                               2020=02-09  #
#########################################################
# Use screen model from command $1
# Valid Screen Names for EA7KDO - NX3224K024, NX4832K935
# Valid Screen Names for VE3RD - NX3224K024
declare -i tst

if [ -z "$1" ]; then
	echo "No Screen Name Provided"
	exit
fi

s1="NX3224K024"
s2="NX4024K032"
s3="NX4832K035"
errtext="Error! - Aborting"

## Strip off .tft - Take only the first 10 characters
scn=$(echo "$1" | tr [:lower:] [:upper:])
#tr [:lower:] [:upper:]
scn="${scn:0:10}"

##Set Call to either 1 for EA7KDO or 2 for VE3RD 
call="$2"
#Feed back is off by default - Turn it on with anything as parameter 3
fb="$3"
#Set Default mode to EA7KDO
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

# EA7KDO Script Function
function getea7kdo
{
	tst=0
#	echo "Function EA7KDO"
	calltxt="EA7KDO"

    	if [ "$scn" == "NX3224K024" ]; then

		##  New Github Location  for the 32 inch screen - Remove the comment # when active
	#	sudo git clone --depth 1 https://github.com/EA7KDO/NX3224K024 /home/pi-star/Nextion_Temp

		### Old Github Location for the 24 ionch screen - Remove this when the new location becomes active
	  	sudo git clone --depth 1 https://github.com/EA7KDO/Nextion.Images /home/pi-star/Nextion_Temp
		tst=1
	fi     
	if [ "$scn" == "NX4832K035" ]; then
	  	sudo git clone --depth 1 https://github.com/EA7KDO/NX4832K035 /home/pi-star/Nextion_Temp
		tst=2
     	fi
	
	if [ "$tst" == 0 ]; then
		errtext="Invalid EA7KDO Screen Name $scn"	
		exitcode 
	fi
}

# VE3RD Script Function
function getve3rd
{
	tst=0
#	echo "Function VE3RD"
     	
	calltxt="VE3RD"
	if [ "$scn" = "$s1" ]; then	
	 	tst=1  
	  	sudo git clone --depth 1 https://github.com/VE3RD/Nextion /home/pi-star/Nextion_Temp
	fi
	if [ "$scn" = "$s2" ]; then
		tst=2	
  	  	sudo git clone --depth 1 https://github.com/VE3RD/Nextion /home/pi-star/Nextion_Temp
	fi
	if [ "$tst" = 0 ]; then
		errtext="Invalid VE3RD Screen Name $scn,  $s1,  $s2"
		exitcode 
	fi

}

#### Start of Main Code

# Usage Syntax if no parameters are supplies
if [ -z "$scn" ]; then
	echo " Syntax: gitcopy.sh NX????K???   // Will copy EA7KDO Files - Default for Screen"
	echo " Syntax: gitcopy.sh NX????K??? 1 // Will copy EA7KDO Files - Selected"
	echo " Syntax: gitcopy.sh NX????K??? 2 // Will copy VE3RD Files - Selected"
	echo " Adding a third parameter(anything) will provide feedback as the script runs (Commandline)"
	echo " " 
        echo  " Valid Screens - EA7KDO) - NX3224K024, NX4832K035"
        echo  " Valid Screens - VE3RD ) - NX3224K024, NX4032K032"
	echo " "
fi

#Process Extra Parameters
if [ -z "$2" ]; then
#  echo "Setting Default=EA7KDO"
  call="1"
fi
if [ "$scn" == "$s2" ]; then
#  echo "Override - Setting VE3RD for $s2"
  call="2"
fi

if [ "$call" == "0" ]; then
#  echo "Call Parameter set to 0 - Ea7KDO"
  call="1"
  fb="2"
fi

#echo "$scn  - $call" 
if [ "$fb" ]; then
	if [ "$call" == "1" ]; then
	        if [ "$scn" != "$s1" -a "$scn" != "$s3" ]; then
              		echo "EA7KDO Screen Name MUST be NX3224K024 or NX4832K035"
                       	errtext="Invalid EA7KDO Screen Name"
                        exitcode
		else
			echo "Loading EA7KDO $scn Screen Package"

                fi

        fi

	if [ "$call" == "2" ]; then
                if [ "$scn" != "$s1" -a "$scn" != "$s2" ]; then
			echo "VE3RD Screen Name MUST be NX3224K024 or NX4024K024"
			errtext="Invalid VE3RD Screen Name"
			exitcode
		else
			echo "Loading VE3RD $scn Screen Package"
		fi	
	fi
fi

#echo " End Processing Parameters  - $scn $call"

if [ ! -d /home/pi-star/Nextion_Temp ]; then
   sudo mkdir /home/pi-star/Nextion_Temp
fi

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

# Using /home/pi-star/Nextion_Temp/


#Test for /home/pi-star/Nextion_Temp and remove it, if it exists

if [ -d /home/pi-star/Nextion_Temp ]; then
  	sudo rm -R /home/pi-star/Nextion_Temp
fi

  # Get Nextion Screen/Scripts and support files from github
  # Get EA7KDO File Set

tst=0
if [ "$call" == "1" ]; then
	getea7kdo
 
fi


  # Get VE3RD File Set
if [ "$call" == "2" ]; then
	getve3rd
fi

if [ ! -d /usr/local/etc/Nextion_Support ]; then
	sudo mkdir /usr/local/etc/Nextion_Support
else
       sudo rm  /usr/local/etc/Nextion_Support/*
fi

sudo chmod +x /home/pi-star/Nextion_Temp/*.sh
sudo rsync -avqru /home/pi-star/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX* --exclude=profiles.txt

if [ -f /home/pi-star/Nextion_Temp/profiles.txt ]; then
	if [ ! -f /usr/local/etc/Nextion_Support/profiles.txt ]; then
        	if [ "$fb" ]; then
                	echo "Replacing Missing Profiles.txt"
        	fi
        	sudo cp  /home/pi-star/Nextion_Temp/profiles.txt /usr/local/etc/Nextion_Support/
	fi
fi

model="$scn"
if [ "$fb" ]; then
    echo "Remove Existing $model$tft and copy in the new one"
fi

if [ -f /usr/local/etc/$model$tft ]; then
	sudo rm /usr/local/etc/NX*K*.tft
fi
sudo cp /home/pi-star/Nextion_Temp/$model$tft /usr/local/etc/


 FILE=/usr/local/etc/$model$tft
 if [ ! -f "$FILE" ]; then
        # Copy failed
      echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sudo systemctl start cron.service  > /dev/null

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`

if [ ! "$fb" ]; then
 exec 2>&3
fi 

echo "$calltxt Scripts Loaded: $execution_time"




