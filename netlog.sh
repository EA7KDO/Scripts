#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Logging Calls on a Pi-Star Hotpot			   #
#  to assist with Net Logging                              #
#                                                          #
#  VE3RD                              Created 2021/07/05   #
############################################################
set -o errexit 
set -o pipefail 
set -e 
ver=20210714

sudo mount -o remount,rw / 

callstat="dup" 
callinfo="No Info" 
lastcall2="" 
lastcall1=""
P1="$1" 
P2="$2" 
netcont=${P1^^} 
stat=${P2^^} 
#echo "$netcont"   "$stat" 
dur=$((0)) 
cnt=$((0))
cm=0
lcm=0

 
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

	if [ ! "$netcont" ] || [ "$netcont" == "NEW" ]; then
		echo "No Net Controller Specified"
		netcont="N/A"
	else
		echo "Net Controller is $netcont"
		echo ""
	fi
}

function getserver(){

Addr=$(sed -nr "/^\[DMR Network\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

if [ $Addr = "127.0.0.1" ]; then
	fg=$(ls /var/log/pi-star/DMRGateway* | tail -n1)
	NetNum=$(sudo tail -n1 "$fg" | cut -d " " -f 6)
	NName=$(sed -nr "/^\[DMR Network "${NetNum##*( )}"\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
  	server="$NName"
else
	ms=$(sudo sed -n '/^[^#]*'"$Addr"'/p' /usr/local/etc/DMR_Hosts.txt | sed -E "s/[[:space:]]+/|/g" | cut -d'|' -f1)
 	server="$ms"
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

function getnewcall(){
        f1=$(ls -tv /var/log/pi-star/MMDVM* | tail -n 1 )
        nline1=$(tail -n 1 "$f1")
	tg=""

	if [[ $nline1 =~ "header" ]]; then
   		cm=1
 		call=$(echo "$nline1" | cut -d " " -f 12) 
		tg=$(echo "$nline1" | cut -d " " -f 15)
        	call1="$call"
        	ln2=""
	fi
	if [[ $nline1 =~ "transmission" ]]; then
        	call=$(echo "$nline1" | cut -d " " -f 14 )
		tg=$(echo "$nline1" | cut -d " " -f 17)
        	call2="$call"
        	ln1=""
		if [ "$cm" == 1 ]; then
			tput cuu 1
		fi
        	cm=2
	fi
	if [[ $nline1 =~ "watchdog" ]]; then
        	cm=3
        	call2="$call"
	fi

	if [ "$cm" != 1 ] && [ "lcm" == 1 ]; then
   		tput cuu 1
	fi
}



######## Start of Main Program

if [ "$netcont" == "NEW" ] || [ "$stat" == "NEW" ] || [ ! -f /home/pi-star/netlog.log ]; then
	## Delete and start a new data file starting with date line
	dates=$(date '+%A %Y-%m-%d %T')
        header 
else
	cntt=$(tail -n 1 /home/pi-star/netlog.log | cut -d "," -f 1)
	cnt=$((cntt))
	echo "Restart Program - Counter = $cnt"
#	echo "New Header $cntt"
#	tput cuu 1
#	tput el 1
#	tput el
fi

while true
do 
	cm=0	

	getnewcall
	if [ ! "$call" ]; then
         call="$netcont"
	fi
	getuserinfo
	checkcall

#	if [ "$lastcall1" != "$call1" ] && [ "$cm" == 1 ]; then
	if [ "$cm" == 1 ]; then
		printf '\e[0;35m'
		getserver
		if [ "$lcm" == 1 ]; then
			tput cuu 1
		else
			tput el 1
			tput el
		fi
		echo "    Active Transmission from $call1 $name, $city, $state, $country  $tg $server"
		lcm=1
		call2=""
		lastcall2="n/a"
	fi

 	Time=$(date '+%T')  

	if [ "$lastcall2" != "$call2" ] && [ "$cm" == 2 ]; then
		if [ "$call2" == "$netcont" ]; then
			getserver
			sudo mount -o remount,rw /
		tput el 1
		tput el
			
			echo -e '\e[1;34m'"-------------------- $Time  Net Control $netcont $name    $tg $server                  "          
			echo -e "$cnt,--------------------- $Time  Net Control $netcont " >> /home/pi-star/netlog.log

			name=""
			city=""
			state=""
			country=""
			callstat="NC"		
		fi
		
		durt=$(echo "$nline1" | cut -d " " -f 18 )
		pl=$(echo "$nline1" | cut -d " " -f 20 )
		dur=$(printf "%1.0f\n" $durt)

		if [ $dur -lt 3 ] && [ "$cm" == 2 ]; then
			#### Keyup < 3 seconds
			getuserinfo
			printf '\e[0;36m'
			lcm=0
			tput el 1
			tput el
			printf "KeyUp %-8s %-6s  %s,  %s,  %s,  %s,  %s,  %s\n" "$Time" "$call" "$name" "$city" "$state" "$country" " Dur: $durt sec"  "PL: $pl               "	
			callstat=""
		fi

		if [ "$callstat" == "New" ] && [ "$call" != "$netcont" ] && [ "$cm" == 2 ]; then
			## Write New Call to Screen
			cnt=$((cnt+1))
			printf '\e[1;32m'

			tput el 1
			tput el
			printf "%-4d New %-8s -- %-6s -- %-12s %-14s %-14s  %-12s %-14s %s\n" "$cnt" "$Time" "$call" "$name" "$city" "$state" "$country" " Dur: $durt sec"  "PL: $pl"	
			lcm=0
			Logit
		fi
		if [ "$callstat" == "Dup" ] && [ "$cm" == 2 ]; then
			## Write Duplicate Info to Screen
			lcm=0
			tput el 1
			tput el
			printf '\e[0;33m'
			printf "Duplicate %-3s - %-15s - %-8s %-12s %-14s %-9s\n" "$cnt2" "$Time/$ckt" "$call" "$name" "Dur: $durt sec" "PL: $pl" 
		fi

		lastcall2="$call2"
	fi

	if [ "$lcm" == 1 ] && [ "$cm" != 1 ]; then
		tput cuu 1
	fi	


	if [ "$cm" == 3 ] && [ "$lastcall3" != "$call" ]; then
        	call2="$call"
		durt=$(echo "$nline1" | cut -d " " -f 18 )
		pl=$(echo "$nline1" | cut -d " " -f 20 )
		dur=$(printf "%1.0f\n" $durt)
		printf '\e[1;31m'
		tput el 1
		tput el
		echo "$Time - DMR Network Watchdog Timer has Expired for $call, $name, $dur Sec   PL:$pl        "
		lastcall3="$call"
		lcm=0
	fi
	if [ "$lcm" == 1 ]; then
		tput cuu 1
		lcm=0
	fi
sleep 1
done

