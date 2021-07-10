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
ver=20210708 


sudo mount -o remount,rw / 

callstat="dup" 
callinfo="No Info" 
lastcall="" 
P1="$1" 
P2="$2" 
netcont=${P1^^} 
stat=${P2^^} 
echo "$netcont"   "$stat" 
dur=$((0)) 
cnt=$((0))


function getnewcall(){
	f1=$(ls -tv /var/log/pi-star/MMDVM* | tail -n 1 )
	nline2=$(grep -w transmission "$f1" | tail -n 1)
	call2=$(echo "$nline2" | cut -d " " -f 14 )
}

 
function header(){
	clear
	set -e sudo mount -o remount,rw / 
	echo ""
	echo "NET Logging Program by VE3RD Version $ver"
	echo ""
	echo "Dates and Times Shown are Local to your hotspot"
	echo ""
	echo "Net Log Started $dates"
	echo "0, Net Log Started $dates" > /home/pi-star/netlog.log
	echo ""

	if [ ! "$P1" ] || [ "$P1" == "NEW" ]; then
		echo "No Net Controller Specified"
		netcont="N/A"
	else
		echo "Net Controller is $netcont"
		echo ""
	fi
}

function getuserinfo(){
 	line=$(sed -n '/'"$call"',/p' /usr/local/etc/stripped.csv | tail -n1)	

	if [ line ]; then
		name=$(echo "$line" | cut -d "," -f 3 | cut -d " " -f 1)
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
}

function checkcall(){
	cnt2=0
	ck=$(sed -n '/'"$call"'/p' /home/pi-star/netlog.log | cut -d "," -f 3)
	if [ "$ck" ]; then
		ckt=$(sed -n '/'"$call"'/p' /home/pi-star/netlog.log | cut -d "," -f 2)
		cnt2=$(sed -n '/'"$call"'/p' /home/pi-star/netlog.log | cut -d "," -f 1)
		if [ ! cnt2 ]; then
			cnt2=0
			callstat=""
		else
			callstat="Dup"
		fi	
	        
	else
#		echo "New Call $call"
		callstat="New"
		
	fi
	
#echo CheckCall
}

function Logit(){
	sudo mount -o remount,rw /
	## Write New Call to Log File
	echo "$cnt,$Time,$call,$name,$city,$state,$country " >> /home/pi-star/netlog.log
}

######## Start of Main Program

if [ "$netcont" == "NEW" ] || [ "$stat" == "NEW" ] || [ ! -f /home/pi-star/netlog.log ]; then
	dates=$(date '+%A %Y-%m-%d %T')
        header
	getnewcall
	lastcall="$call"
	cnt=0
else
	cntt=$(tail -n 1 /home/pi-star/netlog.log | cut -d "," -f 1)
#	echo "New Header $cntt"
	cnt=$((cntt))
	tput cuu 1
	tput el 1
	tput el

fi


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
			sudo mount -o remount,rw /

			echo -e '\e[1;31m'"-------------------- $Time  Net Control $netcont "
			echo -e "0,--------------------- $Time  Net Control $netcont " >> /home/pi-star/netlog.log

			name=""
			city=""
			state=""
			country=""
			callstat="NC"		
		else
			getuserinfo
			checkcall
		fi

		if [ $dur -lt 3 ]; then
			######echo -e '\e[0;36m\033[<1>A'
			printf '\e[0;36m'
			printf "KeyUp %-10s %-8s %-14s %-5s sec\n" "$Time" "$call" "$name" "$durt"
			callstat=""
		fi

		if [ "$callstat" == "New" ] && [ "$call" != "$netcont" ]; then
			## Write New Call to Screen
			cnt=$((cnt+1))
			printf '\e[1;32m'
	#		echo -e '\e[1;32m'"$Time -- $call --  $name, $city, $state, $country  Dur:$durt"" sec"  PL:"$pl"	
			printf "%-4d New %-8s -- %-6s -- %-12s %-14s %-14s  %-12s %-14s %s\n" "$cnt" "$Time" "$call" "$name" "$city" "$state" "$country" " Dur: $durt sec"  "PL: $pl"	

			Logit
		fi
		if [ "$callstat" == "Dup" ]; then
			## Write Duplicate Info to Screen
#			echo  -e '\e[0;33m'"Duplicate -- $ckt -- $call  $name  Dur:$durt"" sec  PL: $pl"
			printf '\e[0;33m'
			
			printf "Duplicate %-3s -- %-15s-- %-8s %-12s %-14s %-9s\n" "$cnt2" "$Time/$ckt" "$call" "$name" "Dur: $durt sec" "PL: $pl" 
		fi

	fi

	lastcall="$call"
	sleep 1
done

