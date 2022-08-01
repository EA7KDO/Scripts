#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Configring MMDVMHost 		   	           #
#                                                          #
#  VE3RD                              Created 2022/08/01   #
############################################################
#set -o errexit
#set -o pipefail
#set -e
export NCURSES_NO_UTF8_ACS=1
clear
echo -e "\e[1;97;44m"
tput setab 4
clear

CallSign=""
DID=""


RED='\033[0;31m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

function exitcode
{
txt='Abort Function\n\n
This Script will Now Stop'"\n$exittext"

dialog --title "  Programmed Exit  " --ascii-lines --msgbox "$txt" 8 78

tput setab 9
mode=""
clear
echo -e '\e[1;40m'
run="Done"
exit

}

function CheckMode(){
md1=$(sed -nr "/^\[D-Star\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md2=$(sed -nr "/^\[DMR\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md3=$(sed -nr "/^\[System Fusion\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md4=$(sed -nr "/^\[NXDN\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md5=$(sed -nr "/^\[P25\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
tm1="OFF"
tm2="OFF"
tm3="OFF"
tm4="OFF"
tm5="OFF"

if [ "$md1" == "1" ]; then
	tmode="D-Star"
	tm1="ON"
	return
elif [ "$md2" == "1" ]; then
        tmode="DMR"
	tm2="ON"
        return
elif [ "$md3" == "1" ]; then
        tmode="D-Star"
	tm3="ON"
        return
elif [ "$md3" == "1" ]; then
        tmode="D-Star"
	tm4="ON"
        return
elif [ "$md3" == "1" ]; then
        tmode="D-Star"
	tm5="ON"
        return
else
	tmode="DMR"
	tm2="ON"
fi
}

function CheckDisplay(){
d=$(sed -nr "/^\[General\]/ { :l /Display[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d1="OFF"
d2="OFF"
d3="OFF"
d4="OFF"
d5="OFF"
d6="OFF"

case "$d" in
  "None") d1="ON" ;;
  "OLED") d2="ON" ;;
  "Nextion") d4="ON" ;;
  "HD44780") d5="ON" ;;
  *) d6="ON" ;;
esac

}



# cleanup  - add a trap that will remove $OUTPUT
# if any of the signals - SIGHUP SIGINT SIGTERM it received.
#trap "rm $OUTPUT; Trapped Exit ; exit" SIGHUP SIGINT SIGTERM

m1=$(sed -nr "/^\[General\]/ { :l /Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

# show an inputbox
declare -a CallSign=( $(dialog --title "Call Sign Input Box" \
	--ascii-lines \
	--clear \
	--colors \
	--backtitle "MMDVM Host Configurator - VE3RD" \
	--inputbox "Enter your CallSign - Upper Case" 8 70  "$m1" 2>&1 >/dev/tty) )


CallSign=$(echo "$CallSign" | tr '[:lower:]' '[:upper:]')

# get response
response=$?

echo "$response : $CallSign"

if [ -z "$CallSign" ]; then
        errtext=" Cancel Selected"
	exitcode
fi
# get data stored in $OUPUT using input redirection
#name=$(<$OUTPUT)

# make a decsion 

# show an inputbox
m2=$(sed -nr "/^\[DMR\]/ { :l /Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

declare -a DID=( $(dialog --title "DMR ID Input Box" \
        --ascii-lines \
        --clear \
        --colors \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --inputbox "Enter your DMR Digital ID (9 Digit)" 8 70 "$m2" 2>&1 >/dev/tty) )

# get response
response=$?
if [ -z "$DID" ]; then
        errtext=" Cancel Selected"
	exitcode
fi

m3=$(hostname)
declare -a HostN=( $(dialog --title "Host Name Input Box" \
        --ascii-lines \
        --clear \
        --colors \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --inputbox "Enter Your Hotspot Name" 8 70 "$m3" 2>&1 >/dev/tty) )

# get response
response=$?
if [ -z "$HostN" ]; then
        errtext=" Cancel Selected"
	exitcode
fi


extra="000000000"

m4=$(sed -nr "/^\[Info\]/ { :l /RXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

declare -a Frequency=( $(dialog --title "Frequency Input Box" \
        --ascii-lines \
        --clear \
        --colors \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --inputbox "Enter your Hotspot Frequency" 8 70 "$m4" 2>&1 >/dev/tty) )

	F1=$(echo "$Frequency" | tr -d . | tr -d , )
  	F2="$F1""$extra"
	F3=$(echo "$F2" | cut -c 1-9 )

	Frequency="$F3"

# get response
response=$?
if [ -z "$Frequency" ]; then
        errtext=" Cancel Selected"
	exitcode
fi


CheckMode

declare -a Mode=( $(dialog --title "Main Mode Selection" \
        --ascii-lines \
        --clear \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --radiolist "Select Your Default Mode (Space Bar to Select)" 12 70 30 \
	"D-Star" "" "$tm1" \
	"DMR" "" "$tm2" \
	"YSF" "" "$tm3" \
	"NXDN" "" "$tm4" \
	"P25" "" "$tm5" 2>&1 >/dev/tty) )

if [ -z "$Mode" ]; then
        errtext=" Cancel Selected"
	exitcode
fi


m5=$(sed -nr "/^\[General\]/ { :l /Display[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

CheckDisplay

declare -a Display=( $(dialog --title "Hotspot Display Selection ($m5)" \
        --ascii-lines \
        --clear \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --radiolist "Select Your Display Type (Space Bar to Select)" 16 70 30  \
	"None" "" "$d1" \
	"OLED" "" "$d2" \
	"Nextion" "" "$d4" \
	"HD44780" "" "$d5" \
	"Other" "" "$d6" 2>&1 >/dev/tty) )


# get response
response=$?
if [ -z "$Display" ]; then
        errtext=" Cancel Selected"
	exitcode
fi

m6=$(sed -nr "/^\[DMR Network\]/ { :l /Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

BM=${m6%_*} 
m1t="OFF"
m2t="OFF"
m3t="OFF"
m4t="OFF"

if [ "$m6" == "tgif.network" ]; then
	m1t="ON"
elif [ "$m6" == "mnet.hopto.org" ]; then
	m2t="ON"
elif [ "$BM" == "BM" ]; then
	m3t="ON"
elif [ "$m6" == "127.0.0.1" ]; then
	m4t="ON"
else
	m5t="ON"
fi
echo "Master : $m6"

declare -a Master=( $(dialog --title "DMR Master Server Selection" \
        --ascii-lines \
        --clear \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --radiolist "Select Your Master Server (Space Bar to Select)" 12 70 30  \
	"TGIF_Network" "" "$m1t" \
	"MNET_Network" "" "$m2t" \
	"BM 3103" "" "m3t" \
	"DMRGateway" ""  "$m4t" \
	"Other" "" "m5t" 2>&1 >/dev/tty) )


# get response
response=$?
if [ -z "$Master" ]; then
	clear
        errtext=" Cancel Selected"
	exitcode
fi



 #sudo sed -i '/^\[/h;G;/D-Star/s/\(Enable=\).*/\1'"$2"'/m;P;d'  /etc/mmdvmhost
 #sudo sed -i '/^\[/h;G;/D-Star Network/s/\(Enable=\).*/\1'"$2"'/m;P;d'  /etc/mmdvmhost


# show an search for Server Address/Password

declare -a SearchTxt=( $(dialog --title " DMR Server Search Utility" \
        --ascii-lines \
        --clear \
        --colors \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --inputbox "Enter your Search Criteria" 8 70  "tgif" 2>&1 >/dev/tty) )



# get response
response=$?

grep "$SearchTxt" /usr/local/etc/DMR_Hosts.txt | tr "\t" " " | sed 's/\( \)*/\1/g' | tail -5  | cut  -d " " -f1 > tmpfile1
grep "$SearchTxt" /usr/local/etc/DMR_Hosts.txt | tr "\t" " " | sed 's/\( \)*/\1/g' | tail -5  | cut  -d " " -f4 > tmpfile4

 paste tmpfile1 tmpfile4 | pr -t -e24 > tmpfile

while read LINE
  do
   case $LINE in
	'/ >'*|---*|'/ > '*)
        continue;;
  esac
 echo -n " 1\"$LINE\"" >result
done < tmpfile


#dialog  \
#	--menu "Latest news " 20 50 30 `cat tmpfile' \

#declare -a Master2=( $(dialog --title "DMR Master Server Selection - Search" \
#        --radiolist "Select Your Master Server (Space Bar to Select)" 12 70 30  \
#        "$RServer" "$RPassw" "ON" \
#        "None" "None" "OFF" 2>&1 >/dev/tty) )


#dialog  --ascii-lines --menu "Latest news " 20 50 30 `cat tmpfile`

declare -a MasterS=( $(dialog  --ascii-lines \
        --ascii-lines \
        --clear \
        --backtitle "MMDVM Host Configurator - VE3RD" \
	--menu "Select from the Following Located Servers" 20 50 20 `cat tmpfile`  2>&1 >/dev/tty) )


echo "$MasterS"




#-------------------------


v1="Call Sign    = $CallSign\n" 
v2="Digital Id   = $DID\n" 
v3="Host Name    = $HostN\n" 
v4="Frequency    = $Frequency\n"
v5="Display Type = $Display\n" 
v6="Master Server= $Master\n"
v7="Master Search= $MasterS\n" 
vt="$v1$v2$v3$v4$v5$v6$v7"

dialog --title " Configuration Items " --ascii-lines --msgbox "$vt" 13 50


clear
#mmdvmhost.service restart


