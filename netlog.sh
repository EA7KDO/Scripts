#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Logging Calls on a Pi-Star Hotpot			   #
#  to assist with Net Logging                              #
#                                                          #
#  VE3RD                                      2021/07/05   #
############################################################
set -o errexit
set -o pipefail
set -e
sudo mount -o remount,rw /
callstat="dup"
callinfo="No Info"
lastcall=""
netcont="$1"
dur=$((0))
ver=20210706

clear
echo "NET Logging Program by VE3RD Version $ver"
echo ""
echo "Dates and Times Shown are Local to your hotspot"
echo ""

sudo touch /home/pi-star/netlog.sh
 
if [ ! "$1" ] || [ "$1" == "new" ]; then
	echo "No Net Controller Specified"
	netcont="N/A"
else
	echo "Net Controller is $netcont"
fi

if [ "$1" == "new" ] || [ "$2" == "new" ] || [ ! -f /home/pi-star/netlog.log ]; then
	dates=$(date '+%A %Y-%m-%d %T')

	echo "Log Started  $dates"
	echo "    Log Started  $dates" > /home/pi-star/netlog.log
	echo ""
#	date > /home/pi-star/netlog.log
fi


function userinfo(){
 	line=$(sed -n '/'"$call"',/p' /usr/local/etc/stripped.csv | tail -n1)	
#echo "$line"
	if [ line ]; then
		name=$(echo "$line" | cut -d "," -f 3)
		city=$(echo "$line"| cut -d "," -f 5)
		state=$(echo "$line" | cut -d "," -f 6)
		country=$(echo "$line" | cut -d "," -f 7)
	else
		callinfo="No Info"
		name=""
		city=""
		state=""
		country=""
	fi
#echo userinfo
}

function checkcall(){
	ck=$(sed -n '/'"$call"'/p' /home/pi-star/netlog.log | cut -d "," -f 2)
#        echo "Found Call x""$ck""x"
	if [ "$ck" ]; then
		ckt=$(sed -n '/'"$call"'/p' /home/pi-star/netlog.log | cut -d "," -f 1)
		callstat="Dup"
        else
#		echo "New Call $call"
		callstat="New"
	fi
	
#echo CheckCall
}

function Logit(){
	sudo mount -o remount,rw /
	## Write New Call to Log File
	echo "$Time ,$call,$name,$city,$state,$country " >> /home/pi-star/netlog.log
}

while true
do 

	f1=$(ls -tv /var/log/pi-star/MMDVM* | tail -n 1 )
	nline2=$(grep -w transmission "$f1" | tail -n 1)
	call2=$(echo "$nline2" | cut -d " " -f 14 )
	durt=$(echo "$nline2" | cut -d " " -f 18 )
	pl=$(echo "$nline2" | cut -d " " -f 20 )
	dur=$(printf "%1.0f\n" $durt)
	call=$call2
	
 	Time=$(date '+%T')  

	if [ "$lastcall" != "$call" ]; then
		if [ "$call" == "$netcont" ]; then

			echo -e '\e[1;31m'"-------------------- $Time  Net Control $netcont "
			echo -e "-------------------- $Time  Net Control $netcont " >> /home/pi-star/netlog.log

			name=""
			city=""
			state=""
			country=""
			callstat="NC"		
		else
			userinfo
			checkcall
		fi

		if [ $dur -lt 2 ]; then
			echo -e '\e[0;36m'"KeyUp $Time $call $name $durt"" sec"
			callstat=""
		fi

		if [ "$callstat" == "New" ] && [ "$call" != "$netcont" ]; then
			## Write New Call to Screen
			echo -e '\e[1;32m'"$Time -- $call --  $name, $city, $state, $country  Dur:$durt"" sec"  PL:"$pl"	

			Logit
		fi
		if [ "$callstat" == "Dup" ]; then
			## Write Duplicate Info to Screen
			echo  -e '\e[0;33m'"Duplicate -- $ckt -- $call  $name  Dur:$durt"" sec  PL: $pl"
		fi
		

	fi

	lastcall="$call"
	sleep 1
done
