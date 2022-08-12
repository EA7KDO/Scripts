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
declare -i GWPage=1
declare -i sectN=1
declare -i indx=1
((GWPage=1))
export GWPage

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc
Mode="RO"
CallSign=""
DID=""

RED='\033[0;31m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

mode=$1
if [ -z "$mode" ]; then
mode="RO"
fi

#########  Start of Functions  ################
function exitcode
{
	txt='Abort Function\n\n
	This Script will Now Stop'"\n$exittext"
	dialog --title "  Programmed Exit  " --ascii-lines --msgbox "$txt" 8 78
	tput setab 9 mode="" clear echo -e '\e[1;40m' run="Done" 
exit

}
########
function SelectMode(){

smode=$(dialog \
        --ascii-lines \
        --keep-tite \
        --clear \
        --stdout \
        --title "Mode Selector" \
        --radiolist "Select Mode $indx"  20 30 20 \
        1 "D-Star" OFF \
        2 "DMR" ON \
        3 "YSF" OFF \
        4 "NXDN" OFF \
        5 "P25" OFF )

exitcode=$?

if [ $exitcode -eq 1 ]; then
        exit
fi
F1=""
F2=""
F3=""
case "$smode" in
        1)      F1="/usr/local/etc/DPlus_Hosts.txt"
                F2="/usr/local/etc/DExtra_Hosts.txt"
                F3="/usr/local/etc/DCS_Hosts.txt"
                modes="D-Star"
        ;;
        2) F1="/usr/local/etc/DMR_Hosts.txt" ; modes="DMR"
        ;;
        3) F1="/usr/local/etc/YSFHosts.txt"
           F2="/usr/local/etc/FCSHosts.txt2"
           modes="YSF"
        ;;
        4) F1="/usr/local/etc/NXDNHosts.txt"
           F2="/usr/local/etc/NXDNHostsLocal.txt"
           modes="NXDN"
        ;;
        5) F1="/usr/local/etc/P25Hosts.txt"
           F2="/usr/local/etc/P25HostsLocal.txt"
            modes="P25"
        ;;
esac

if [ -z "$smode" ]; then
  SelectMode
fi

SearchBox

}

function SearchBox(){
sbox=$(dialog \
        --ascii-lines \
        --clear \
        --stdout \
        --title "Mode Selector" \
        --inputbox "Enter $modes Search Text $indx"  20 30  )

exitcode=$?

if [ $exitcode -eq 1 ]; then
        exit
fi

if [ -z "$sbox" ]; then
  SearchBox
fi

#echo "Searching for $sbox in $F1"

Svr=$(grep -E "$sbox" $F1 $F2 $F3 |sed -e '/^#.*/d' | tr -s "\t" | tr "\t" ";" | awk '{print $1, FNR, "N/A"}' | cut -d ":" -f2)

echo "Test2 = $Svr"


##Svr=$(echo "$Svr" | awk '{print $1, FNR, "off"}')


choose

}
#Select master from a list of possible items
function choose () {
 options=$Svr
  status=OFF

cmd=$(dialog --title "Master Server Selector" \
        --column-separator \
        --keep-tite \
        --stdout \
        --colors \
        --ascii-lines \
      --radiolist "Select $modes Server:" 22 90 16 \
        "${cmd[@]}" ${options})

exitcode=$?

if [ -z "$cmd" ]; then
  exit
fi

if [ $exitcode -eq 1 ]; then

  SelectMode
fi
if [ $exitcode -eq 255 ]; then
  SelectMode
fi

echo "Selected = $cmd"
Parse

}


## Check and parse out the selected Master
function Parse () {
      choice="$cmd"


  if [ -z "$cmd" ]; then
          dialog --ascii-lines --clear --title "Parse Function" --msgbox "No Selection Found" 3 70
        exit

  fi

  echo "Choice = $choice   Mode = $smode    CMD: $cmd"

     case "$smode" in
        1) #D-STAR
          SvrRoom=$(echo "$choice" | cut -d ";" -f1)
          SvrAddr=$(echo "$choice" | cut -d ";" -f2)
          dstr="MODE = $modes\nRoom: $SvrRoom \nAddress: $SvrAddr"
        ;;
        2) #DMR
          SvrName=$(echo "$choice" | cut -d ";" -f1)
          SvrAddr=$(echo "$choice" | cut -d ";" -f3)
          SvrPwd=$(echo "$choice" | cut -d ";" -f4)
          SvrPort=$(echo "$choice" | cut -d ";" -f5)
          dstr="MODE = $modes\nName: $SvrName \nAddr: $SvrAddr\nPasswd: $SvrPwd \nPort: $SvrPort"
        ;;
        3) #YSF

          SvrTG=$(echo "$choice" | cut -d ";" -f1)
          SvrName=$(echo "$choice" | cut -d ";" -f3)
          SvrAddress=$(echo "$choice" | cut -d ";" -f4)
          SvrPort=$(echo "$choice" | cut -d ";" -f5)
          dstr="MODE = $modes\nTG: $SvrTG \nName: $SvrName \nAddr: $SvrAddress \nPort: $SvrPort"
        ;;
        4) #NXDN
          SvrTG=$(echo "$choice" | cut -d ";" -f1)
          SvrAddr=$(echo "$choice" | cut -d ";" -f2)
          SvrPort=$(echo "$choice" | cut -d ";" -f3)
        dstr="MODE = $modes\nTG: $SvrTG \nAddr: $SvrAddr \nPort: $SvrPort"
        ;;
        5)      #P25
          SvrTG=$(echo "$choice" | cut -f1)
          SvrAddr=$(echo "$choice" | cut -f2)
          SvrPort=$(echo "$choice" | cut -f3)
        dstr="MODE = $modes\nTG: $SvrTG \nAddr: $SvrAddr \nPort: $SvrPort"

        ;;
     esac
 dialog --ascii-lines --clear --title "Selected $modes Server Detail" --msgbox "$dstr" 10 70


clear
MenuMain
}



function MasterServ(){

exec 3>&1

SrcTxt=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --title "  Search for a Master Server Step 1 " \
        --inputbox "Enter your Search Text" 8 40 \
	2>&1 1>&3 )

SrcTxt=^$SrcTxt
echo "Search For $SrcTxt"

#tcmd=$(grep $SrcTxt /usr/local/etc/DMR_Hosts.txt |sed 's|[\t][\t][\t]*||g' | tr "\t" "|" )
tcmd=$(grep "$SrcTxt" /usr/local/etc/DMR_Hosts.txt | tr -s "\t" | tr "\t" "|")

COUNTER=1
RADIOLIST=""  # variable where we will keep the list entries for radiolist dialog
for i in "$tcmd"; do
    RADIOLIST="$COUNTER $i off"
    let COUNTER=COUNTER+1
done

echo "$RADIOLIST"

SvrStr=$(dialog \
	--ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --title "  DMR Master Sever List " \
	--menu "Select the DMR Master Server" 20 70 10 0 \
	$RADIOLIST \
 	2>&1 1>&3 )


 exitcode=$?

if [ $errorcode -eq 1 ]; then
    MenuMain
fi
if [ $errorcode -eq 255 ]; then
    MenuMain
fi
if [ $errorcode -ne 0 ]; then
   exit
    MenuMain
fi



#echo "$SvrStr"
SvrName=$(echo "$SvrStr" | cut -d "|" -f1)
SvrAddr=$(echo "$SvrStr" | cut -d "|" -f3)
SvrPassw=$(echo "$SvrStr" | cut -d "|" -f4)
SvrPort=$(echo "$SvrStr" | cut -d "|" -f5)
echo "$SvrName"
echo "$SvrAddr"
echo "$SvrPassw"
echo "$SvrPort"
exit

#dialog --ascii-lines --infobox "Server Name = $SvrName\nServer Address = $SvrAddr\nPassword = $SvrPassw\Port = $SvrPort\" 10 60 ; sleep 2
dialog --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --title " Details of Selected DMR Master Server " \
	--msgbox "Server Name = $SvrName\nServer Address = $SvrAddr\nPassword = $SvrPassw\nPort = $SvrPort" 10 60 
 errorcode=$?

if [ $errorcode -eq 1 ]; then
    MenuMain
fi
if [ $errorcode -eq 255 ]; then
    MenuMain
fi

MasterServ

}

function Services(){
MMDVM=$(pgrep MMDVMHost)
DMRG=$(pgrep DMRGateway)
P25G=$(pgrep P25Gateway)
YSFG=$(pgrep YSFGateway)
NXDNG=$(pgrep NXDNGateway)

if [ -z $MMDVM ]; then MMDVM="Stopped" ; fi
if [ -z $DMRG ]; then DMRG="Stopped" ; fi
if [ -z $P25G ]; then P25G="Stopped" ; fi
if [ -z $YSFG ]; then YSFG="Stopped" ; fi
if [ -z $NXDNG ]; then NXDNG="Stopped" ; fi


dialog  --ascii-lines \
	--backtitle "MMDVM Host Configurator - VE3RD" \
        --title "  Running Services  " \
    	--mixedform " Check List - Display ONLY:" 20 40 12 \
        "MMDVMHost" 	1 1 	"$MMDVM" 	1 15 20 0 2 \
        "DMRGateway" 	2 1 	"$DMRG" 	2 15 20 0 2 \
        "P25Gateway" 	3 1	"$P25G" 	3 15 20 0 2 \
        "YSFGateway" 	4 1	"$YSFG" 	4 15 20 0 2 \
        "NXDNGateway"	5 1	"$NXDNG" 	5 15 20 0 2 

errorcode=$?

if [ $errorcode -eq 1 ]; then
        MenuMain1
fi
if [ $errorcode -eq 255 ]; then
        MenuMainT
fi



MenuMaint
}




##############
function CheckSetModes(){
md1=$(sed -nr "/^\[D-Star\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md2=$(sed -nr "/^\[DMR\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md3=$(sed -nr "/^\[System Fusion\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md4=$(sed -nr "/^\[NXDN\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
md5=$(sed -nr "/^\[P25\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

dm1=$(sed -nr "/^\[DMR Network 1\]/ { :l /Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm2=$(sed -nr "/^\[DMR Network 2\]/ { :l /Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm3=$(sed -nr "/^\[DMR Network 3\]/ { :l /Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm4=$(sed -nr "/^\[DMR Network 4\]/ { :l /Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm5=$(sed -nr "/^\[DMR Network 5\]/ { :l /Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm6=$(sed -nr "/^\[DMR Network 6\]/ { :l /Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
echo "DMR Net4 Enabled = $dm4"

 opmodes=$(dialog \
        --title "Modes and Enables Screen" \
        --ok-label "Submit" \
        --backtitle "MMDVM Host Configurator - VE3RD" \
	--stdout \
        --ascii-lines \
        --mixedform "Modes Enable and DMRGateay Enables (Editable)" 25 60 20 \
        "Op Modes"    	1 1 "Op Modes"  	1 15 35 0 2 \
        "D-Star"       	2 1 "$md1"     		2 15 35 0 0 \
        "DMR"          	3 1 "$md2"     		3 15 35 0 0 \
        "YSF"       	4 1 "$md3"     		4 15 35 0 0 \
        "NXDN"      	5 1 "$md4"     		5 15 35 0 0 \
        "P25"          	6 1 "$md5"     		6 15 35 0 0 \
        "DMRGateway"    7 1 "DMRGateway"     	7 15 35 0 2 \
        "Net 1"    	8 1 "$dm1"     		8 15 35 0 0 \
        "Net 2"    	9 1 "$dm2"     		9 15 35 0 0 \
        "Net 3"   	10 1 "$dm3"    		10 15 35 0 0 \
        "Net 4"     	11 1 "$dm4"   		11 15 35 0 0 \
        "Net 5"         12 1 "$dm5"   		12 15 35 0 0 \
        "Net 6"      	13 1 "$dm6"    		13 15 35 0 0 ) 

errorcode=$?

if [ $errorcode -eq 1 ]; then
	MenuMain
fi
if [ $errorcode -eq 255 ]; then
	MenuMain
fi
if [ $mode == "RO" ]; then
	MenuMain
fi



DStar=$(echo "$opmodes" | sed -n '2p' )
DMR=$(echo "$opmodes" | sed -n '3p' )
YSF=$(echo "$opmodes" | sed -n '4p' )
NXDN=$(echo "$opmodes" | sed -n '5p' )
P25=$(echo "$opmodes" | sed -n '6p' )

Net1=$(echo "$opmodes" | sed -n '8p' )
Net2=$(echo "$opmodes" | sed -n '9p' )
Net3=$(echo "$opmodes" | sed -n '10p' )
Net4=$(echo "$opmodes" | sed -n '11p' )
Net5=$(echo "$opmodes" | sed -n '12p' )
Net6=$(echo "$opmodes" | sed -n '13p' )



if [ "$DStar" != "$md1" ]; then 
        sudo sed -i '/^\[/h;G;/D-Star]/s/\(Enable=\).*/\1'"$DStar"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMR" != "$md2" ]; then 
        sudo sed -i '/^\[/h;G;/DMR]/s/\(Enable=\).*/\1'"$DMR"'/m;P;d' /etc/mmdvmhost
fi
if [ "$YSF" != "$md3" ]; then 
        sudo sed -i '/^\[/h;G;/System Fusion]/s/\(Enable=\).*/\1'"$YSF"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NXDN" != "$md4" ]; then 
        sudo sed -i '/^\[/h;G;/NXDM]/s/\(Enable=\).*/\1'"$NXDN"'/m;P;d' /etc/mmdvmhost
fi
if [ "$P25" != "$md5" ]; then 
        sudo sed -i '/^\[/h;G;/P25]/s/\(Enable=\).*/\1'"$P25"'/m;P;d' /etc/mmdvmhost
fi


if [ "$Net1" != "$dm1" ]; then 
        sudo sed -i '/^\[/h;G;/DMR Network 1]/s/\(Enabled=\).*/\1'"$Net1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Net2" != "$dm2" ]; then 
        sudo sed -i '/^\[/h;G;/DMR Network 2]/s/\(Enabled=\).*/\1'"$Net2"'/m;P;d' /etc/dmrgateway
fi
if [ "$Net3" != "$dm3" ]; then 
        sudo sed -i '/^\[/h;G;/DMR Network 3]/s/\(Enabled=\).*/\1'"$Net3"'/m;P;d' /etc/dmrgateway
fi
if [ "$Net4" != "$dm4" ]; then 
        sudo sed -i '/^\[/h;G;/DMR Network 4]/s/\(Enabled=\).*/\1'"$Net4"'/m;P;d' /etc/dmrgateway
fi
if [ "$Net5" != "$dm5" ]; then 
        sudo sed -i '/^\[/h;G;/DMR Network 5]/s/\(Enabled=\).*/\1'"$Net5"'/m;P;d' /etc/dmrgateway
fi
if [ "$Net6" != "$dm6" ]; then 
        sudo sed -i '/^\[/h;G;/DMR Network 6]/s/\(Enabled=\).*/\1'"$Net6"'/m;P;d' /etc/dmrgateway
fi

CheckSetModes

}

function LogMon(){
F1=$(dialog \
        --ascii-lines \
        --title "Select a file" \
        --stdout \
        --title "Please choose a file" \
        --fselect "/var/log/pi-star/" 30 0 )

# delete file

if [ $returncode -eq 1 ]; then
        dialog --ascii-lines --infobox "Cancel Selected\nSleeping 2 seconds" 10 30 ; sleep 2
   MenuMain
fi
if [ $returncode -eq 255 ]; then
        dialog --ascii-lines --infobox "Cancel Selected\nSleeping 2 seconds" 10 30 ; sleep 2
   MenuMain
fi

if [ ! -z "$F1" ]; then
	echo "File = $F1"
else
        dialog --ascii-lines --infobox "You Forgot to Select a File with the Space Bar\nGo Back and Try Again" 10 30 ; sleep 2
	LogMon
fi

F2=$(dialog \
        --ascii-lines \
        --title "Select a file" \
        --stdout \
        --title "Please choose a file" \
        --tailbox "$F1" 40 0 )

if [ ! -z "$F1" ]; then
echo "File = $F1"
else
 echo " No File "
MenuMaint
fi

MenuMaint
}


#################
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
#############
function EditModeGroup(){
   dialog --ascii-lines --infobox "Not Yet Implemented - Sleeping 2 seconds" 10 40 ; sleep 2
	MenuMain
}
############
function EditTimers(){
ds1=$(sed -nr "/^\[D-Star]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
ds2=$(sed -nr "/^\[D-Star Network]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

dm1=$(sed -nr "/^\[DMR]/ { :l /CallHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
dm2=$(sed -nr "/^\[DMR]/ { :l /TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
dm3=$(sed -nr "/^\[DMR]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
dm4=$(sed -nr "/^\[DMR Network]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

y1=$(sed -nr "/^\[System Fusion]/ { :l /^TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
y2=$(sed -nr "/^\[System Fusion]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
y3=$(sed -nr "/^\[System Fusion Network]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

P1=$(sed -nr "/^\[P25]/ { :l /^TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
P2=$(sed -nr "/^\[P25]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
P3=$(sed -nr "/^\[P25 Network]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

P4=$(sed -nr "/^\[Network]/ { :l /^RFHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
P5=$(sed -nr "/^\[Network]/ { :l /^NetHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)

n1=$(sed -nr "/^\[NXDN]/ { :l /^TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n2=$(sed -nr "/^\[NXDN]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n3=$(sed -nr "/^\[NXDN Network]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

n4=$(sed -nr "/^\[Network]/ { :l /^RFHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
n5=$(sed -nr "/^\[Network]/ { :l /^NetHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)

mm1=$(sed -nr "/^\[General]/ { :l /RFModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm2=$(sed -nr "/^\[General]/ { :l /NetModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

echo "RFModeHang - $mm1"
echo "NetModeHang - $mm2"

tim=$(dialog  --ascii-lines \
	--stdout \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --title " RF / Net / ModeHang Timers  " \
        --mixedform " Timers and ModeHangs " 0 40 0 \
        "D-Star"   		1 1 "D-Star" 1 25 35 0 2 \
        "ModeHang"       	2 3 "$ds1"   2 25 35 0 0 \
        "Net ModeHang"		3 3 "$ds2"   3 25 35 0 0 \
        "DMR"            	4 1 "DMR"    4 25 35 0 2 \
        "CallHang"       	5 3 "$dm1"   5 25 35 0 0 \
        "TXHang"      		6 3 "$dm2"   6 25 35 0 0 \
        "ModeHang"          	7 3 "$dm3"   7 25 35 0 0 \
        "NetModeHang"          	8 3 "$dm4"   8 25 35 0 0 \
        "YSF"                   9 1 "YSF"    9 25 35 0 2 \
        "TXHang"                10 3 "$y1"   10 25 35 0 0 \
        "ModeHang"              11 3 "$y2"   11 25 35 0 0 \
        "Net ModeHang"          12 3 "$y3"   12 25 35 0 0 \
        "P25"                   13 1 "P25"   13 25 35 0 2 \
        "TXHang"                14 3 "$P1"   14 25 35 0 0 \
        "ModeHang"              15 3 "$P2"   15 25 35 0 0 \
        "Net ModeHang"          16 3 "$P3"   16 25 35 0 0 \
        "RFHangTime GW Net"     17 3 "$P4"   17 25 35 0 0 \
        "NetHangTime GW Net"    18 3 "$P5"   18 25 35 0 0 \
        "NXDN"                  19 1 "NXDN"  19 25 35 0 2 \
        "TXHang"                20 3 "$n1"   20 25 35 0 0 \
        "ModeHang"              21 3 "$n2"   21 25 35 0 0 \
        "Net ModeHang"          22 3 "$n3"   22 25 35 0 0 \
        "RFHangTime GW Net"     23 3 "$n4"   23 25 35 0 0 \
	"NetHangTime GW Net"   	24 3 "$n5"   24 25 35 0 0 \
        "MMDVM	"     		25 1 "MMDVM" 25 25 35 0 2 \
        "RF ModeHang"     	26 3 "$mm1"  26 25 35 0 0 \
	"Net ModeHang"   	27 3 "$mm2"  27 25 35 0 0 \
)


errorcode=$?
echo  "Error Code = $errorcode"

if [ $errorcode -eq 1 ]; then
MenuMain
fi
if [ $errorcode -eq 255 ]; then
MenuMain
fi
if [ $mode == "RO" ]; then
	MenuMain
fi


## 1
dsMH=$(echo "$tim" | sed -n '2p' )
dsNMH=$(echo "$tim"  | sed -n '3p' )
## 4
dmCHT=$(echo "$tim"  | sed -n '5p' )
dmTXH=$(echo "$tim"  | sed -n '6p' )
dmMH=$(echo "$tim"  | sed -n '7p' )
dmNMH=$(echo "$tim"  | sed -n '8p' )
## 9
yTXH=$(echo "$tim"  | sed -n '10p' )
yMH=$(echo "$tim"  | sed -n '11p' )
yNMH=$(echo "$tim"  | sed -n '12p' )
## 13
p2TXH=$(echo "$tim"  | sed -n '14p' )
p2MH=$(echo "$tim"  | sed -n '15p' )
p2NMH=$(echo "$tim"  | sed -n '16p' )
p2GRFHT=$(echo "$tim"  | sed -n '17p' )
p2GNHT=$(echo "$tim"  | sed -n '18p' )
## 19
nxTXH=$(echo "$tim"  | sed -n '20p' )
nxMH=$(echo "$tim"  | sed -n '21p' )
nxNMH=$(echo "$tim"  | sed -n '22p' )
nxGRFHT=$(echo "$tim"  | sed -n '23p' )
nxGNHT=$(echo "$tim"  | sed -n '24p' )
## 25
mmRFMH==$(echo "$tim"  | sed -n '26p' )
mmNMH=$(echo "$tim"  | sed -n '27p' )

echo " DM1 $dmCHT"
echo " DM2 $dmTXH"
echo " DM3 $dmMH"
echo " DM4 $dmNMH"


#D-Star
if [ "$dsMH" != "$ds1" ]; then
  sed -i "/^\[D-Star\]/,/^$/s/^ModeHang=$ds1/ModeHang=$dsMH/" /etc/mmdvmhost
fi
if [ "$dsNMH" != "$ds2" ]; then
  sed -i "/^\[D-Star Network\]/,/^$/s/^ModeHang=$ds2/ModeHang=$dsNMH/" /etc/mmdvmhost
fi
#DMR

if [ "$dmCHT" != "$dm1" ]; then
  sed -i "/^\[DMR\]/,/^$/s/CallHang=$dm1/CallHang=$dmCHT/" /etc/mmdvmhost
fi
if [ "$dmTXH" != "$dm2" ]; then
  sed -i "/^\[DMR\]/,/^$/s/TXHang=$dm2/TXHang=$dmTXH/" /etc/mmdvmhost
fi
if [ "$dmMH" != "$dm3" ]; then
  sed -i "/^\[DMR\]/,/^$/s/ModeHang=$dm3/ModeHang=$dmMH/" /etc/mmdvmhost
fi
if [ "$dmNMH" != "$dm4" ]; then
  sed -i "/^\[DMR Network\]/,/^$/s/ModeHang=$dm4/ModeHang=$dmNMH/" /etc/mmdvmhost
fi

#YSF
if [ "$yTXH" != "$y1" ]; then
#       sed -i "/^\[System Fusion\]/,/^$/s/TXHang=$y1/TXHang=$yTXH/" /etc/mmdvmhost
#        sudo sed -i '/^\[/h;G;/[System Fusion]/s/\(TXHang=\).*/\1'"$yTXH"'/m;P;d' /etc/mmdvmhost
  sudo sed -i '/^\[/h;G;/System Fusion]/s/\(^TXHang=\).*/\1'"$yTXH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$yMH" != "$y2" ]; then
#  sed -i "/^\[System Fusion\]/,/^$/s/ModeHang=$y2/ModeHang=$yMH/" /etc/mmdvmhost
#        sudo sed -i '/^\[/h;G;/[System Fusion]/s/\(ModeHang=\).*/\1'"$yMH"'/m;P;d' /etc/mmdvmhost
sudo sed -i '/^\[/h;G;/System Fusion]/s/\(^ModeHang=\).*/\1'"$yMH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$yNMH" != "$y3" ]; then
sudo sed -i '/^\[/h;G;/System Fusion Network]/s/\(^ModeHang=\).*/\1'"$yNMH"'/m;P;d' /etc/mmdvmhost
fi


#sudo sed -i '/^\[/h;G;/System Fusion Network]/s/\(^ModeHang=\).*/\1'"$yNMH"'/m;P;d' /etc/mmdvmhost
#P25
if [ "$p2TXH" != "$P1" ]; then
sudo sed -i '/^\[/h;G;/P25]/s/\(^TXHang=\).*/\1'"$p2TXH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$p2MH" != "$P2" ]; then
sudo sed -i '/^\[/h;G;/P25]/s/\(^ModeHang=\).*/\1'"$p2MH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$p2NMH" != "$P3" ]; then
sudo sed -i '/^\[/h;G;/P25 Network]/s/\(^ModeHang=\).*/\1'"$p2NMH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$p2GRFHT" != "$P4" ]; then
sudo sed -i '/^\[/h;G;/Network]/s/\(^RFHangTime=\).*/\1'"$p2GRFHT"'/m;P;d' /etc/p25gateway
fi
if [ "$p2GNHT" != "$P5" ]; then
sudo sed -i '/^\[/h;G;/Network]/s/\(^NetHangTime=\).*/\1'"$p2GNHT"'/m;P;d' /etc/p25gateway
fi


#NXDN
if [ "$nxTXH" != "$n1" ]; then
sudo sed -i '/^\[/h;G;/NXDN]/s/\(^TXHang=\).*/\1'"$nxTXH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$nxMH" != "$n2" ]; then
sudo sed -i '/^\[/h;G;/NXDN]/s/\(^ModeHang=\).*/\1'"$nxMH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$nxNMH" != "$n3" ]; then
sudo sed -i '/^\[/h;G;/NXDN Network]/s/\(^ModeHang=\).*/\1'"$nxNMH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$nxGRFHT" != "$n4" ]; then
sudo sed -i '/^\[/h;G;/Network]/s/\(^RFHangTime=\).*/\1'"$nxGRFHT"'/m;P;d' /etc/nxdngateway
fi
if [ "$nxGNHT" != "$n5" ]; then
sudo sed -i '/^\[/h;G;/Network]/s/\(^NetHangTime=\).*/\1'"$nxGNHT"'/m;P;d' /etc/nxdngateway
fi

#MMDVM
if [ "$mmRFMH" != "$mm1" ]; then
sudo sed -i '/^\[/h;G;/General]/s/\(^RFModeHang=\).*/\1'"$mmRFMH"'/m;P;d' /etc/mmdvmhost
fi
if [ "$mmNMH" != "$mm2" ]; then
sudo sed -i '/^\[/h;G;/General]/s/\(^NetModeHang=\).*/\1'"$mmNMH"'/m;P;d' /etc/mmdvmhost
fi


dialog --ascii-lines --infobox "Data Write Complete - Sleeping 2 seconds" 10 40 ; sleep 2

EditTimers
}
#############

function EditDMRGateNet(){
N="$1"
echo "$N"
sect="DMR Network $N"
echo "Section = $sect"

dm1a=$(sed -nr "/^\[$sect]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm2a=$(sed -nr "/^\[$sect]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm3a=$(sed -nr "/^\[$sect]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm4a=$(sed -nr "/^\[$sect]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm5a=$(sed -nr "/^\[$sect]/ { :l /^Password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm6a=$(sed -nr "/^\[$sect]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm7a=$(sed -nr "/^\[$sect]/ { :l /^Local[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm8a=$(sed -nr "/^\[$sect]/ { :l /^TGRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm9a=$(sed -nr "/^\[$sect]/ { :l /^TGRewrite1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm10a=$(sed -nr "/^\[$sect]/ { :l /^PCRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm11a=$(sed -nr "/^\[$sect]/ { :l /^SrcRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)

exec 3>&1

 dmrgn=$(dialog \
	--title "DMRGateway Networks Section - Page $N" \
	--ok-label "Submit" \
	--extra-button \
	--colors \
	--extra-label "Next Page" \
	--backtitle "MMDVM Host Configurator - VE3RD" \
	--ascii-lines \
	--mixedform "DMRGateway $sect Configuration Items (Editable)" 30 60 15 \
	"Jump To Net" 	1 1 	"0" 		1 15 35 0 0 \
	"DMR Net $N" 	3 1 	"$DMR Net $N" 	3 15 35 0 2 \
	"Enabled" 	4 1 	"$dm1a" 	4 15 35 0 0 \
	"Name" 		5 1 	"$dm2a" 	5 15 35 0 0 \
	"Id" 		6 1 	"$dm3a" 	6 15 35 0 0 \
	"Address" 	7 1 	"$dm4a" 	7 15 35 0 0 \
	"Password" 	8 1 	"$dm5a" 	8 15 35 0 0 \
	"Port" 		9 1 	"$dm6a" 	9 15 35 0 0 \
	"Local" 	10 1 	"$dm7a" 	10 15 35 0 0 \
	"TGRewrite0" 	11 1 	"$dm8a" 	11 15 35 0 0 \
	"TGRewrite1" 	12 1 	"$dm9a" 	12 15 35 0 0 \
	"PCRewrite0" 	13 1 	"$dm10a" 	13 15 35 0 0 \
	"SrcRewrite0" 	14 1 	"$dm11a" 	14 15 35 0 0 \
 	2>&1 1>&3 )

errorcode=$?

if [ $errorcode -eq 1 ]; then
MenuMain
fi

if [ $errorcode -eq 3 ]; then
        ((N=$N+1))
	EditDMRNet "$N"     
fi

if [ $errorcode -eq 0 ] ; then
	Jump=$(echo "$dmrgn"  | sed -n '1p' )

	Enabled=$(echo "$dmrgn" | sed -n '3p' )
	Name=$(echo "$dmrgn"  | sed -n '4p' )
	Id=$(echo "$dmrgn"  | sed -n '5p' )
	Address=$(echo "$dmrgn"  | sed -n '6p' )
	Password=$(echo "$dmrgn"  | sed -n '7p' )
	Port=$(echo "$dmrgn"  | sed -n '8p' )
	Local=$(echo "$dmrgn"  | sed -n '9p' )
	TGRewrite0=$(echo "$dmrgn"  | sed -n '10p' )
	TGRewrite1=$(echo "$dmrgn"  | sed -n '11p' )
	PCRewrite0=$(echo "$dmrgn"  | sed -n '12p' )
	SrcRewrite0=$(echo "$dmrgn"  | sed -n '13p' )
#	echo "S: $SrcRewrite0"
fi

if [ "$Jump" -gt 0 ] && [ "$Jump" -lt 7 ]; then
	EditDMRGateNet "$Jump"
fi
if [ $mode == "RO" ]; then
	EditDMRGateNet "$N"
fi


if [ "$Enabled" != "$dm1a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Enabled=\).*/\1'"$Enabled"'/m;P;d' /etc/dmrgateway
fi
if [ "$Name" != "$dm2a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Name=\).*/\1'"$Name"'/m;P;d' /etc/dmrgateway
fi
if [ "$Id" != "$dm3a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Id=\).*/\1'"$Id"'/m;P;d' /etc/dmrgateway
fi
if [ "$Address" != "$dm4a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Address=\).*/\1'"$Address"'/m;P;d' /etc/dmrgateway
fi
if [ "$Password" != "$dm5a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Password=\).*/\1'"$Password"'/m;P;d' /etc/dmrgateway
fi
if [ "$Port" != "$dm6a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Port=\).*/\1'"$Port"'/m;P;d' /etc/dmrgateway
fi
if [ "$Local" != "$dm7a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Local=\).*/\1'"$Local"'/m;P;d' /etc/dmrgateway
fi
if [ "$TGRewrite0" != "$dm8a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite0=\).*/\1'"$TGRewrite0"'/m;P;d' /etc/dmrgateway
fi
if [ "$TGRewrite1" != "$dm9a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite1=\).*/\1'"$TGRewrite1"'/m;P;d' /etc/dmrgateway
fi
if [ "$PCRewrite0" != "$dm10a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(PCRewrite0=\).*/\1'"$PCRewrite0"'/m;P;d' /etc/dmrgateway
fi
if [ "$SrcRewrite0" != "$dm11a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(SrcRewrite0=\).*/\1'"$SrcRewrite0"'/m;P;d' /etc/dmrgateway
fi

exec 3>&1
 EditDMRGateNet "$indx"


}
############
function EditDMRGate23(){
 

if [ $GWPage -gt 3 ]; then
   (( GWPage=1 ))
	EditDMRGate
fi 

if [ "$GWPage" -eq 2 ]; then
	Sect1="DMR Network 1"
	Sect2="DMR Network 2"
	Sect3="DMR Network 3"
	DMRNeta="DMR Net 1"
	DMRNetb="DMR Net 2"
	DMRNetc="DMR Net 3"
	elabel="Net 456"
fi
if [ "$GWPage" -eq 3 ]; then
	Sect1="DMR Network 4"
	Sect2="DMR Network 5"
	Sect3="DMR Network 6"
	DMRNeta="DMR Net 4"
	DMRNetb="DMR Net 5"
	DMRNetc="DMR Net 6"
	elabel="MainGW"
fi

EditDMRGateNet 2

# sed -nr "/^\[$Sect2/ 

dm1a=$(sed -nr "/^\[$Sect1]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm2a=$(sed -nr "/^\[$Sect1]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm3a=$(sed -nr "/^\[$Sect1]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm4a=$(sed -nr "/^\[$Sect1]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm5a=$(sed -nr "/^\[$Sect1]/ { :l /^Password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm6a=$(sed -nr "/^\[$Sect1]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm7a=$(sed -nr "/^\[$Sect1]/ { :l /^Local[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm8a=$(sed -nr "/^\[$Sect1]/ { :l /^TGRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm9a=$(sed -nr "/^\[$Sect1]/ { :l /^TGRewrite1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm10a=$(sed -nr "/^\[$Sect1]/ { :l /^PCRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm11a=$(sed -nr "/^\[$Sect1]/ { :l /^SrcRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)

dm1b=$(sed -nr "/^\[$Sect2]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm2b=$(sed -nr "/^\[$Sect2]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm3b=$(sed -nr "/^\[$Sect2]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm4b=$(sed -nr "/^\[$Sect2]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm5b=$(sed -nr "/^\[$Sect2]/ { :l /^Password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm6b=$(sed -nr "/^\[$Sect2]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm7b=$(sed -nr "/^\[$Sect2]/ { :l /^Local[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm8b=$(sed -nr "/^\[$Sect2]/ { :l /^TGRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm9b=$(sed -nr "/^\[$Sect2]/ { :l /^TGRewrite1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm10b=$(sed -nr "/^\[$Sect2]/ { :l /^PCRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm11b=$(sed -nr "/^\[$Sect2]/ { :l /^SrcRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)

dm1c=$(sed -nr "/^\[$Sect3]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm2c=$(sed -nr "/^\[$Sect3]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm3c=$(sed -nr "/^\[$Sect3]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm4c=$(sed -nr "/^\[$Sect3]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm5c=$(sed -nr "/^\[$Sect3]/ { :l /^Password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm6c=$(sed -nr "/^\[$Sect3]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm7c=$(sed -nr "/^\[$Sect3]/ { :l /^Local[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm8c=$(sed -nr "/^\[$Sect3]/ { :l /^TGRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm9c=$(sed -nr "/^\[$Sect3]/ { :l /^TGRewrite1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm10c=$(sed -nr "/^\[$Sect3]/ { :l /^PCRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
dm11c=$(sed -nr "/^\[$Sect3]/ { :l /^SrcRewrite0[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)


exec 3>&1

 dmrg2=$(dialog \
        --title "DMRGateway Networks Section - Page $GWPage" \
        --ok-label "Submit" \
	--extra-button \
	--colors \
	--extra-label "Next Page" \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --ascii-lines \
        --mixedform "DMRGateway Configuration Items (Editable)" 0 60 40 \
        "DMR Neta A"  	1 1 "$DMRNeta"  1 15 35 0 2 \
        "Enabled"  	2 1 "$dm1a"  	2 15 35 0 0 \
        "Name"     	3 1 "$dm2a"  	3 15 35 0 0 \
        "Id"      	4 1 "$dm3a"  	4 15 35 0 0 \
        "Address"       5 1 "$dm4a"  	5 15 35 0 0 \
        "Password"      6 1 "$dm5a"  	6 15 35 0 0 \
        "Port"    	7 1 "$dm6a"  	7 15 35 0 0 \
        "Local"    	8 1 "$dm7a"  	8 15 35 0 0 \
        "TGRewrite0"    9 1 "$dm8a"  	9 15 35 0 0 \
        "TGRewrite1"    10 1 "$dm9a"  	10 15 35 0 0 \
        "PCRewrite0" 	11 1 "$dm10a"  	11 15 35 0 0 \
        "SrcRewrite0" 	12 1 "$dm11a"  	12 15 35 0 0 \
    	"DMR Net B"     13 1 "$DMRNetb" 13 15 35 0 2 \
        "Enabled"       14 1 "$dm1b"    14 15 35 0 0 \
        "Name"          15 1 "$dm2b"    15 15 35 0 0 \
        "Id"            16 1 "$dm3b"    16 15 35 0 0 \
        "Address"       17 1 "$dm4a"  	17 15 35 0 0 \
        "Password"      18 1 "$dm5b"    18 15 35 0 0 \
        "Port"          19 1 "$dm6b"    19 15 35 0 0 \
        "Local"         20 1 "$dm7b"    20 15 35 0 0 \
        "TGRewrite0"    21 1 "$dm8b"    21 15 35 0 0 \
        "TGRewrite1"    22 1 "$dm9b"    22 15 35 0 0 \
        "PCRewrite0"    23 1 "$dm10b"   23 15 35 0 0 \
        "SrcRewrite"    24 1 "$dm11b"   24 15 35 0 0 \
        "DMRNet C"      25 1 "$DMRNetc" 25 15 35 0 2 \
        "Enabled"       26 1 "$dm1c"    26 15 35 0 0 \
        "Name"          27 1 "$dm2c"    27 15 35 0 0 \
        "Id"            28 1 "$dm3c"    28 15 35 0 0 \
        "Address"       29 1 "$dm4a"  	29 15 35 0 0 \
        "Password"      30 1 "$dm5c"    30 15 35 0 0 \
        "Port"          31 1 "$dm6c"    31 15 35 0 0 \
        "Local"         32 1 "$dm7c"    32 15 35 0 0 \
        "TGRewrite0"    33 1 "$dm8c"    33 15 35 0 0 \
        "TGRewrite1"    34 1 "$dm9c"    34 15 35 0 0 \
        "PCRewrite0"    35 1 "$dm10c"   35 15 35 0 0 \
        "SrcRewrite"    36 1 "$dm11c"   36 15 35 0 0 2>&1 1>&3 )

errorcode=$?

if [ $errorcode -eq 1 ]; then
   dialog --ascii-lines --infobox "Cancel selected - Sleeping 2 seconds" 10 40 ; sleep 2
        EditDMRGate
fi



if [ $errorcode -eq 3 ]; then
	((GWPage++))
	if (( $GWPage >= 4 )); then
   		(( GWPage=1 ))
		EditDMRGate
	else
		EditDMRGate23
	fi
fi 

if [ $errorcode -eq 255 ]; then
	EditDMRGate23
fi

if [ $mode == "RO" ]; then
	EditDMRGate23
fi


############  Net 1/4
echo Starting Net A"
if [ $GWPage -eq 2 ]; then
	sect="DMR Network 1"
fi
if [ $GWPage -eq 3 ]; then
	sect="DMR Network 4"
fi
 
echo " Net 1 Check - Sect = $sect"
sleep 2

Enabled1=$(echo "$dmrg2" | sed -n '2p' )
Name1=$(echo "$dmrg2"  | sed -n '3p' )
Id1=$(echo "$dmrg2"  | sed -n '4p' )
Address1=$(echo "$dmrg2"  | sed -n '5p' )
Password1=$(echo "$dmrg2"  | sed -n '6p' )
Port1=$(echo "$dmg2"  | sed -n '7p' )
Local1=$(echo "$dmrg2"  | sed -n '8p' )
TGRewrite01=$(echo "$dmrg2"  | sed -n '9p' )
TGRewrite11=$(echo "$dmrg2"  | sed -n '10p' )
PCRewrite01=$(echo "$dmrg2"  | sed -n '11p' )
SrcRewrite01=$(echo "$dmrg2"  | sed -n '12p' )

##Net1/4

if [ "$Enabled1" != "$dm1a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Enabled=\).*/\1'"$Enabled1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Name1" != "$dm2a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Name=\).*/\1'"$Name1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Id1" != "$dm3a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Id=\).*/\1'"$Id1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Address1" != "$dm4a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Address=\).*/\1'"$Address1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Password1" != "$dm5a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Password=\).*/\1'"$Password1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Port1" != "$dm6a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Port=\).*/\1'"$Port1"'/m;P;d' /etc/dmrgateway
fi

if [ "$Local1" != "$dm7a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Local=\).*/\1'"$Local1"'/m;P;d' /etc/dmrgateway
fi

if [ "$TGRewrite01" != "$dm8a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite0=\).*/\1'"$TGRewrite01"'/m;P;d' /etc/dmrgateway
fi
if [ "$TGRewrite11" != "$dm9a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite1=\).*/\1'"$TGRewrite11"'/m;P;d' /etc/dmrgateway
fi
if [ "$PCRewrite01" != "$dm10a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(PCRewrite0=\).*/\1'"$PCRewrite01"'/m;P;d' /etc/dmrgateway
fi
if [ "$SrcRewrite01" != "$dm11a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(SrcRewrite0=\).*/\1'"$SrcRewrite01"'/m;P;d' /etc/dmrgateway
fi

echo Starting Net B"
###### Start Net 2/5
if [ $GWPage -eq 2 ]; then
	sect="DMR Network 2"
fi
if [ $GWPage -eq 3 ]; then
	sect="DMR Network 5"
fi

echo " Net 2 Check - Sect = $sect"
sleep 5

Enabled1=$(echo "$dmrg2" | sed -n '14p' )
Name1=$(echo "$dmrg2"  | sed -n '15p' )
Id1=$(echo "$dmrg2"  | sed -n '16p' )
Address1=$(echo "$dmrg2"  | sed -n '17p' )
Password1=$(echo "$dmrg2"  | sed -n '18p' )
Port1=$(echo "$dmrg2"  | sed -n '19' )
Local1=$(echo "$dmrg2"  | sed -n '20p' )
TGRewrite01=$(echo "$dmrg2"  | sed -n '21p' )
TGRewrite11=$(echo "$dmrg2"  | sed -n '22p' )
PCRewrite01=$(echo "$dmrg2"  | sed -n '23p' )
SrcRewrite01=$(echo "$dmrg2"  | sed -n '24p' )


##Net 2/5
i=1
echo i
if [ "$Enabled1" != "$dm1a" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Enabled=\).*/\1'"$Enabled1"'/m;P;d' /etc/dmrgateway
fi


if [ "$Enabled1" != "$dm1b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Enabled=\).*/\1'"$Enabled1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$Name1" != "$dm2b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Name=\).*/\1'"$Name1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$Id1" != "$dm3b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Id=\).*/\1'"$Id1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$Address1" != "$dm4b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Address=\).*/\1'"$Address1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$Password1" != "$dm5b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Password=\).*/\1'"$Password1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$Port1" != "$dm6b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Port=\).*/\1'"$Port1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$Local1" != "$dm7b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Local=\).*/\1'"$Local1"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$TGRewrite01" != "$dm8b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite0=\).*/\1'"$TGRewrite01"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$TGRewrite11" != "$dm9b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite1=\).*/\1'"$TGRewrite11"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$PCRewrite01" != "$dm10b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(PCRewrite0=\).*/\1'"$PCRewrite01"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))
if [ "$SrcRewrite01" != "$dm11b" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(SrcRewrite0=\).*/\1'"$SrcRewrite01"'/m;P;d' /etc/dmrgateway
fi
 echo $((i=i+1))

echo "Starting Net C"
exit
#############  Start Net 3/6

if [ $GWPage -eq 2 ]; then
	sect="DMR Network 3"
fi
if [ $GWPage -eq 3 ]; then
	sect="DMR Network 6"
fi

echo " Net 3 Check - Sect = $sect"
sleep 5
	

Enabled1=$(echo "$dmrg2" | sed -n '26p' )
Name1=$(echo "$dmrg2"  | sed -n '27p' )
Id1=$(echo "$dmrg2"  | sed -n '28p' )
Address1=$(echo "$dmrg2"  | sed -n '29p' )
Password1=$(echo "$dmrg2"  | sed -n '30p' )
Port1=$(echo "$dmrg2"  | sed -n '31p' )
Local1=$(echo "$dmrg2"  | sed -n '32p' )
TGRewrite01=$(echo "$dmrg2"  | sed -n '33p' )
TGRewrite11=$(echo "$dmrg2"  | sed -n '34p' )
PCRewrite01=$(echo "$dmrg2"  | sed -n '35p' )
SrcRewrite1=$(echo "$dmrg2"  | sed -n '36p' )

if [ -z "$SrcRewrite" ]; then
echo "SrcRewrite  Net3"
exit
fi

if [ "$Enabled1" != "$dm1c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Enabled=\).*/\1'"$Enabled1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Name1" != "$dm2c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Name=\).*/\1'"$Name1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Id1" != "$dm3c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Id=\).*/\1'"$Id1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Address1" != "$dm4c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Address=\).*/\1'"$Address1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Password1" != "$dm5c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Password=\).*/\1'"$Password1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Port1" != "$dm6c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Port=\).*/\1'"$Port1"'/m;P;d' /etc/dmrgateway
fi
if [ "$Local1" != "$dm7c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(Local=\).*/\1'"$Local1"'/m;P;d' /etc/dmrgateway
fi
if [ "$TGRewrite01" != "$dm8c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite0=\).*/\1'"$TGRewrite01"'/m;P;d' /etc/dmrgateway
fi
if [ "$TGRewrite11" != "$dm9c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(TGRewrite1=\).*/\1'"$TGRewrite11"'/m;P;d' /etc/dmrgateway
fi
if [ "$PCRewrite01" != "$dm10c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(PCRewrite0=\).*/\1'"$PCRewrite01"'/m;P;d' /etc/dmrgateway
fi
if [ "$SrcRewrite01" != "$dm11c" ]; then
        sudo sed -i '/^\[/h;G;/[$sect]/s/\(SrcRewrite0=\).*/\1'"$SrcRewrite01"'/m;P;d' /etc/dmrgateway
fi

EditDMRGate23

}
####################

function EditDMRGate(){
((GWPage=0))
elabel="Net 123"

#EditDMRGateNet 1
#exit


g1=$(sed -nr "/^\[General\]/ { :l /^RuleTrace[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g2=$(sed -nr "/^\[General\]/ { :l /^StartNet[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g3=$(sed -nr "/^\[General\]/ { :l /^GWMode[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g4=$(sed -nr "/^\[General\]/ { :l /^Daemon[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g5=$(sed -nr "/^\[General\]/ { :l /^RFTimeout[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g6=$(sed -nr "/^\[General\]/ { :l /^NetTimeout[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)

g7=$(sed -nr "/^\[Log\]/ { :l /^DisplayLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g8=$(sed -nr "/^\[Log\]/ { :l /^FileLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g9=$(sed -nr "/^\[Log\]/ { :l /^FilePath[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g10=$(sed -nr "/^\[Log\]/ { :l /^FileRoot[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)

g11=$(sed -nr "/^\[Info\]/ { :l /^Latitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g12=$(sed -nr "/^\[Info\]/ { :l /^Longitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g13=$(sed -nr "/^\[Info\]/ { :l /^Location[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g14=$(sed -nr "/^\[Info\]/ { :l /^Description[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g15=$(sed -nr "/^\[Info\]/ { :l /^URL[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g16=$(sed -nr "/^\[Info\]/ { :l /^RXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g17=$(sed -nr "/^\[Info\]/ { :l /^TXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g18=$(sed -nr "/^\[Info\]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
g19=$(sed -nr "/^\[Info\]/ { :l /^Power[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)


exec 3>&1

  dmrg1=$(dialog  \
        --title "DMRGateway Sections - Page $GWPage" \
        --ok-label "Submit" \
	--extra-button \
	--extra-label "$elabel" \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --ascii-lines \
        --mixedform "DMRGateway Configuration Items\nItems marked -gw4 are only available in DMRGateway-4 by VE3RD" 30 70 30 \
        "General"    		1 1 "General"  	1 22 35 0 2 \
        "RuleTrace"    		2 1 "$g1"  	2 22 35 0 0 \
        "StartNet -gw4"     	3 1 "$g2"     	3 22 35 0 0 \
        "GWMode   -gw4"       	4 1 "$g3"     	4 22 35 0 0 \
        "Daemon"      		5 1 "$g4"     	5 22 35 0 0 \
        "RFTimeout"   		6 1 "$g5"     	6 22 35 0 0 \
        "NetTimeout"  		7 1 "$g6"     	7 22 35 0 0 \
        "LOG"   		8 1 "LOG"     	8 22 35 0 2 \
        "DisplayLevel"  	9 1 "$g7"     	9 22 35 0 0 \
        "File Level"  		10 1 "$g8"     	10 22 35 0 0 \
        "FilePath"   		11 1 "$g9"     	11 22 35 0 0 \
        "FileRoot"  		12 1 "$g10"     12 22 35 0 0 \
        "INFO"  		13 1 "INFO"     13 22 35 0 2 \
        "Latitude"  		14 1 "$g11"     14 22 35 0 0 \
        "Longitude"  		15 1 "$g12"     15 22 35 0 0 \
        "Location"  		16 1 "$g13"     16 22 35 0 0 \
        "Description"  		17 1 "$g14"     17 22 35 0 0 \
        "URL"  			18 1 "$g15"     18 22 35 0 0 \
        "RXFrequency"  		19 1 "$g16"     19 22 35 0 0 \
        "TXFrequency"  		20 1 "$g17"     20 22 35 0 0 \
        "Enabled"  		21 1 "$g18"     21 22 35 0 0 \
        "Power"  		22 1 "$g19"     22 22 35 0 0 \
	2>&1 1>&3 )

errorcode=$?

if [ $errorcode -eq 1 ]; then
	MenuMain
fi

if [ $errorcode -eq 3 ]; then
	GWPage=0
	EditDMRGateNet 1
fi

if [ $errorcode -eq 255 ]; then
	MenuMain
fi
if [ $mode == "RO" ]; then
	EditDMRGate
fi


RuleTrace=$(echo "$dmrg1" | sed -n '2p' )
StartNet=$(echo "$dmrg1"  | sed -n '3p' )
GWMode=$(echo "$dmrg1"  | sed -n '4p' )
Daemon=$(echo "$dmrg1"  | sed -n '5p' )
RFTimeout=$(echo "$dmrg1"  | sed -n '6p' )
NetTimeout=$(echo "$dmrg1"  | sed -n '7p' )

DisplayLevel=$(echo "$dmrg1"  | sed -n '9p' )
FileLevel=$(echo "$dmrg1"  | sed -n '10p' )
FilePath=$(echo "$dmrg1"  | sed -n '11p' )
FileRoot=$(echo "$dmrg1"  | sed -n '12p' )

Latitude=$(echo "$dmrg1"  | sed -n '14p' )
Longitude=$(echo "$dmrg1"  | sed -n '15p' )
Location=$(echo "$dmrg1"  | sed -n '16p' )
Description=$(echo "$dmrg1"  | sed -n '17p' )
URL=$(echo "$dmrg1"  | sed -n '18p' )
RXFrequency=$(echo "$dmrg1"  | sed -n '19p' )
TXFrequency=$(echo "$dmrg1"  | sed -n '20p' )
Enabled=$(echo "$dmrg1"  | sed -n '21p' )
Power=$(echo "$dmrg1"  | sed -n '22p' )

if [ "$RuleTrace" != "$g1" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(RuleTrace=\).*/\1'"$RuleTrace"'/m;P;d' /etc/dmrgateway
fi
if [ "$StartNet" != "$g2" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(StartNet=\).*/\1'"$StartNet"'/m;P;d' /etc/dmrgateway
fi
if [ "$GWMode" != "$g3" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(GWMode=\).*/\1'"$GWMode"'/m;P;d' /etc/dmrgateway
fi
if [ "$Daemon" != "$g4" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Daemon=\).*/\1'"$Daemon"'/m;P;d' /etc/dmrgateway
fi
if [ "$RFTimeout" != "$g5" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(RFTimeout=\).*/\1'"$RFTimeout"'/m;P;d' /etc/dmrgateway
fi
if [ "$NetTimeout" != "$g6" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(NetTimeout=\).*/\1'"$NetTimeout"'/m;P;d' /etc/dmrgateway
fi
##
if [ "$DisplayLevelLevel" != "$g7" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(DisplayLevel=\).*/\1'"$DisplayLevel"'/m;P;d' /etc/dmrgateway
fi
if [ "$FileLevel" != "$g8" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileLevel=\).*/\1'"$FileLevel"'/m;P;d' /etc/dmrgateway
fi
if [ "$FilePath" != "$g9" ]; then
  TO=$(echo "$FilePath" | sed "s/\//\\\\\//g")
        sudo sed -i '/^\[/h;G;/Log]/s/\(FilePath=\).*/\1'"$TO"'/m;P;d' /etc/dmrgateway
fi
if [ "$FileRoot" != "$g10" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileRotate=\).*/\1'"$FileRotate"'/m;P;d' /etc/dmrgateway
fi
##
if [ "$Latitude" != "$g11" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Latitude=\).*/\1'"$Latitude"'/m;P;d' /etc/dmrgateway
fi
if [ "$Longitude" != "$g12" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Longitude=\).*/\1'"$Longitude"'/m;P;d' /etc/dmrgateway
fi
if [ "$Location" != "$g13" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Location=\).*/\1'"$Location"'/m;P;d' /etc/dmrgateway
fi
if [ "$Description" != "$g14" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Description=\).*/\1'"$Description"'/m;P;d' /etc/dmrgateway
fi
if [ "$URL" != "$g15" ]; then
  TO=$(echo "$URL" | sed "s/\//\\\\\//g")
        sudo sed -i '/^\[/h;G;/Info]/s/\(URL=\).*/\1'"$TO"'/m;P;d' /etc/dmrgateway
fi
if [ "$RXFrequency" != "$g16" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1'"$RXFrequency"'/m;P;d' /etc/dmrgateway
fi
if [ "$TXFrequency" != "$17" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1'"$TXFrequency"'/m;P;d' /etc/dmrgateway
fi
if [ "$Enabled" != "$18" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Enabled=\).*/\1'"$Enabled"'/m;P;d' /etc/dmrgateway
fi
if [ "$Power" != "$19" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Power=\).*/\1'"$Power"'/m;P;d' /etc/dmrgateway
fi

EditDMRGate

}
###################
function EditLog(){
#3
echo "Setting Varibles"
l1=$(sed -nr "/^\[Log\]/ { :l /DisplayLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
l2=$(sed -nr "/^\[Log\]/ { :l /FileLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
l3=$(sed -nr "/^\[Log\]/ { :l /FilePath[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
l4=$(sed -nr "/^\[Log\]/ { :l /FileRoot[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
l5=$(sed -nr "/^\[Log\]/ { :l /FileRotate[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

exec 3>&1
  Logd=$(dialog  \
        --title "MMDVM Log Section" \
	--ok-label "Submit" \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --ascii-lines \
        --mixedform "MMDVM Log  Configuration Items (Editable)" \
        20 50 0 \
        "DisplayLevel"	1 1 "$l1"  1 15 35 0 0 \
        "FileLevel"  	2 1 "$l2"  2 15 35 0 0 \
        "FilePath"  	3 1 "$l3"  3 15 35 0 0 \
        "FileRoot"  	4 1 "$l4"  4 15 35 0 2 \
        "FileRotate"  	5 1 "$l5"  5 15 35 0 0 \
	2>&1 1>&3)


errorcode=$?
if [ $errorcode -eq 1 ]; then
   dialog --ascii-lines --infobox "Cancel selected - Sleeping 2 seconds" 10 40 ; sleep 2
	MenuMain
fi
if [ $errorcode -eq 255 ]; then
   dialog --ascii-lines --infobox "ESC Button Pressed - Sleeping 2 seconds" 10 40 ; sleep 2
	MenuMain
fi
if [ $mode == "RO" ]; then
	MenuMain
fi


DisplayLevel=$(echo "$Logd" | sed -n '1p' )
FileLevel=$(echo "$Logd"  | sed -n '2p' )
FilePath=$(echo "$Logd"  | sed -n '3p' )
FileRoot=$(echo "$Logd"  | sed -n '4p' )
FileRotate=$(echo "$Logd"  | sed -n '5p' )

if [ -z $FilePath ]; then
   dialog --ascii-lines --infobox "Bad Data - Aborting - Sleeping 2 seconds" 10 40 ; sleep 2
  MenuMain
fi

if [ "$DisplayLevel" != "$l1" ]; then 
        sudo sed -i '/^\[/h;G;/Log]/s/\(DisplayLevel=\).*/\1'"$DisplayLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$FileLevel" != "$l2" ]; then 
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileLevel=\).*/\1'"$FileLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$FilePath" != "$l3" ]; then 
  TO=$(echo "$FilePath" | sed "s/\//\\\\\//g")
        sudo sed -i '/^\[/h;G;/Log]/s/\(FilePath=\).*/\1'"$TO"'/m;P;d' /etc/mmdvmhost
fi
if [ "$FileRotate" != "$l5" ]; then 
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileRotate=\).*/\1'"$FileRotate"'/m;P;d' /etc/mmdvmhost
fi

EditLog
}
#########################
function EditGeneral(){
#1
eg1=$(sed -nr "/^\[General\]/ { :l /Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg2=$(sed -nr "/^\[General\]/ { :l /Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg3=$(sed -nr "/^\[General\]/ { :l /Timeout[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg4=$(sed -nr "/^\[General\]/ { :l /Duplex[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg5=$(sed -nr "/^\[General\]/ { :l /RFModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg6=$(sed -nr "/^\[General\]/ { :l /NetModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg7=$(sed -nr "/^\[General\]/ { :l /Display[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
eg8=$(sed -nr "/^\[General\]/ { :l /Daemon[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

returncode=0
returncode=$?
exec 3>&1

Gen=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
	--separate-widget  $'\n'   \
	--ok-label "Save" \
	--title "General Section" \
	--form "\n MMDVM General Configuration Items (Editable)" 20 70 12\
	"Callsign"  	1 1 "$eg1"  1 15 35 0 \
	"Id"  		2 1 "$eg2"  2 15 35 0 \
	"Timeout" 	3 1 "$eg3"  3 15 35 0 \
	"Duplex"  	4 1 "$eg4"  4 15 35 0 \
	"RFModeHang"  	5 1 "$eg5"  5 15 35 0 \
	"NetModeHang"  	6 1 "$eg6"  6 15 35 0 \
	"Display"  	7 1 "$eg7"  7 15 35 0 \
	"Daemon"  	8 1 "$eg8"  8 15 35 0 \
 	2>&1 1>&3)

returncode=$?

Callsign=$(echo "$Gen" | sed -n '1p')

if [  $returncode -eq 1 ]; then 
	dialog --ascii-lines --infobox "Cancel Selected - Function Aborted\nSleeping 2 seconds" 10 40 ; sleep 2
 	MenuMain
fi

if [ -z "$Callsign" ]; then 
        dialog --ascii-lines --infobox " No Data Detected - Function Aborted\nSleeping 2 seconds" 10 40 ; sleep 2
        MenuMain
fi

Callsign=$(echo "$Gen" | sed -n '1p')
Id=$(echo "$Gen" | sed -n '2p' )
Timeout=$(echo "$Gen"  | sed -n '3p' )
Duplex=$(echo "$Gen"  | sed -n '4p' )
RFModeHang=$(echo "$Gen"  | sed -n '5p' )
NetModeHang=$(echo "$Gen"  | sed -n '6p')
Display=$(echo "$Gen"  | sed -n '7p' )
Daemon=$(echo "$Gen" | sed -n '8p' )

echo "Callsign1 $eg1:$Callsign"

##  Write Values Back
if [ "$Callsign" != "$eg1" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(Callsign=\).*/\1'"$Callsign"'/m;P;d' /etc/mmdvmhost
echo "Callsign2 $eg1:$Callsign"
fi
echo "Callsign3 $eg1:$Callsign"


if [ "$Id" != "$eg2" ]; then 
	sudo sed -i '/^\[/h;G;/General]/s/\(Id=\).*/\1'"$Id"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Timeout" != "$eg3" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(Timeout=\).*/\1'"$Timeout"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Duplex" != "$eg4" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(Duplex=\).*/\1'"$Duplex"'/m;P;d' /etc/mmdvmhost
fi
if [ "$RFModeHang" != "$eg5" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(RFModeHang=\).*/\1'"$RFModeHang"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetModeHang" != "$eg6" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(NetModeHang=\).*/\1'"$NetModeHang"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Display" != "$eg7" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(Display=\).*/\1'"$Display"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Daemon" != "$eg8" ]; then 
        sudo sed -i '/^\[/h;G;/General]/s/\(Daemon=\).*/\1'"$Daemon"'/m;P;d' /etc/mmdvmhost
fi
  
EditGeneral
}
####################
function EditModem(){
#4

mm1=$(sed -nr "/^\[Modem\]/ { :l /^^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm2=$(sed -nr "/^\[Modem\]/ { :l /^TXDelay[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm3=$(sed -nr "/^\[Modem\]/ { :l /^RXOffset[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm4=$(sed -nr "/^\[Modem\]/ { :l /^TXOffset[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm5=$(sed -nr "/^\[Modem\]/ { :l /^DMRDelay[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm6=$(sed -nr "/^\[Modem\]/ { :l /^RXLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm7=$(sed -nr "/^\[Modem\]/ { :l /^TXLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm8=$(sed -nr "/^\[Modem\]/ { :l /^RFLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm9=$(sed -nr "/^\[Modem\]/ { :l /^DMRTXLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm10=$(sed -nr "/^\[Modem\]/ { :l /^YSFTXLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm11=$(sed -nr "/^\[Modem\]/ { :l /^P25TXLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm12=$(sed -nr "/^\[Modem\]/ { :l /^NXDNTXLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm13=$(sed -nr "/^\[Modem\]/ { :l /^Trace[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm14=$(sed -nr "/^\[Modem\]/ { :l /^UARTPort[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
mm15=$(sed -nr "/^\[Modem\]/ { :l /^UARTSpeed[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
exec 3>&1

Modems=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --separate-widget  $'\n'   \
        --ok-label "Save" \
        --title "Modem Section" \
        --mixedform "\n Modem Configuration Items (Editable)" 30 40 0 \
        "Port"        1 1 "$mm1"               1 15 35 0 0 \
        "TXDelay"     2 1 "$mm2"               2 15 35 0 0 \
        "RXOffset"    3 1 "$mm3"               3 15 35 0 0 \
        "TXOffset"    4 1 "$mm4"               4 15 35 0 0 \
        "DMRDelay"    5 1 "$mm5"       	       5 15 35 0 0 \
        "RXLevel"     6 1 "$mm6"               6 15 35 0 0 \
        "TXLevel"     7 1 "$mm7"               7 15 35 0 0 \
        "RFLevel"     8 1 "$mm8"               8 15 35 0 0 \
        "DMRTXLevel"  9 1 "$mm9"               9 15 35 0 0 \
        "YSFTXLevel"  10 1 "$mm10"              10 15 35 0 0 \
        "P25TXLevel"  11 1 "$mm11"              11 15 35 0 0 \
        "NXDNTXLevel" 12 1 "$mm12"              12 15 35 0 0 \
        "Trace"       13 1 "$mm13"              13 15 35 0 0 \
        "UARTPort"    14 1 "$mm14"              14 15 35 0 0 \
        "UARTSpeed"   15 1 "$mm15"              15 15 35 0 0 \
 	2>&1 1>&3)

returncode=$?

Port=$(echo "$Modems" | sed -n '1p')


if [  $returncode -eq 1 ]; then 
	dialog --ascii-lines --infobox "Cancel Selected - Function Aborted\nSleeping 2 seconds" 10 40 ; sleep 2
 	MenuMain
fi
if [  $returncode -eq 255 ]; then 
 	MenuMain
fi
echo "Ports  $mm1 :  $Port"
exit

Port=$(echo "$Modems" | sed -n '1p' )
TXDelay=$(echo "$Modems" | sed -n '2p' )
RXOffset=$(echo "$Modems" | sed -n '3p' )
TXOffset=$(echo "$Modems" | sed -n '4p' )
DMRDelay=$(echo "$Modems" | sed -n '5p' )
RXLevel=$(echo "$Modems" | sed -n '6p' )
TXLevel=$(echo "$Modems" | sed -n '7p' )
RFLevel=$(echo "$Modems" | sed -n '8p' )
DMRTXLevel=$(echo "$Modems" | sed -n '9p' )
YSFTXLevel=$(echo "$Modems" | sed -n '10p' )
P25TXLevel=$(echo "$Modems" | sed -n '11p' )
NXDNTXLevel=$(echo "$Modems" | sed -n '12p' )
Trace=$(echo "$Modems" | sed -n '13p' )
UARTPort=$(echo "$Modems" | sed -n '14p' )
UARTSpeed=$(echo "$Modems" | sed -n '15p' )

if [ "$Port" != "$mm1" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(Port=\).*/\1'"$Port"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXDelay" != "$mm2" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(TXDelay=\).*/\1'"$TXDelay"'/m;P;d' /etc/mmdvmhost
fi
if [ "$RXOffset" != "$mm3" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(RXOffset=\).*/\1'"$RXOffset"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXOffset" != "$mm4" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(TXOffset=\).*/\1'"$TXOffset"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRDelay" != "$mm5" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(DMRDelay=\).*/\1'"$DMRDelay"'/m;P;d' /etc/mmdvmhost
fi
if [ "$RXLevel" != "$mm6" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(RXLevel=\).*/\1'"$RXLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXLevel" != "$mm7" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(TXLevel=\).*/\1'"$TXLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$RFLevel" != "$mm8" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(RFLevel=\).*/\1'"$RFLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRTXLevel" != "$mm9" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(DMRTXLevel=\).*/\1'"$DMRTXLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$YSFTXLevel" != "$mm10" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(YSFTXLevel=\).*/\1'"$YSFTXLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$P25TXLevel" != "$mm11" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(P25TXLevel=\).*/\1'"$P25TXLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NXDNTXLevel" != "$mm12" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(NXDNTXLevel=\).*/\1'"$NXDNTXLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Trace" != "$mm13" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(Trace=\).*/\1'"$Trace"'/m;P;d' /etc/mmdvmhost
fi
if [ "$UARTPort" != "$mm14" ]; then
  TO=$(echo "$UARTPort" | sed "s/\//\\\\\//g")
        sudo sed -i '/^\[/h;G;/Modem]/s/\(UARTPort=\).*/\1'"$TO"'/m;P;d' /etc/mmdvmhost
fi
if [ "$UARTSpeed" != "$mm15" ]; then
        sudo sed -i '/^\[/h;G;/Modem]/s/\(UARTSpeed=\).*/\1'"$UARTSpeed"'/m;P;d' /etc/mmdvmhost
fi

EditModem
}

###############
function EditDMR(){
#5
d1=$(sed -nr "/^\[DMR\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d2=$(sed -nr "/^\[DMR\]/ { :l /CallHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d3=$(sed -nr "/^\[DMR\]/ { :l /TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d4=$(sed -nr "/^\[DMR\]/ { :l /Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d5=$(sed -nr "/^\[DMR Network\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d6=$(sed -nr "/^\[DMR Network\]/ { :l /Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d7=$(sed -nr "/^\[DMR Network\]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d8=$(sed -nr "/^\[DMR Network\]/ { :l /Type[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d9=$(sed -nr "/^\[DMR Network\]/ { :l /Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d10=$(sed -nr "/^\[DMR Network\]/ { :l /LocalPort[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)


exec 3>&1

DMRs=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
	--extra-button \
	--extra-label "Options" \
        --separate-widget  $'\n'   \
        --ok-label "Save" \
        --title "DMR Section" \
        --mixedform "\n DMR Configuration Items (Editable)" 20 70 12\
        "DMR General"   1 1 "General" 	 	1 25 35 0 2 \
        "Enable"      	2 1 "$d1" 	 	2 25 35 0 0 \
        "CallHang"    	3 1 "$d2" 	 	3 25 35 0 0 \
        "TXHang" 	4 1 "$d3" 	 	4 25 35 0 0 \
        "Id x9"         5 1 "$d4"  	 	5 25 35 0 0 \
        "DMR Network"   6 1 "DMR Network" 	6 25 35 0 2 \
        "Enable"    	7 1 "$d5" 	 	7 25 35 0 0 \
        "Address"   	8 1 "$d6" 	 	8 25 35 0 0 \
        "ModeHang"  	9 1 "$d7" 	 	9 25 35 0 0 \
        "Type"         10 1 "$d8" 	       10 25 35 0 0 \
        "Port"         11 1 "$d9" 	       11 25 35 0 0 \
        "LocalPort"    12 1 "$d10"	       12 25 35 0 0 \
         2>&1 1>&3 )

returncode=$?

if [ $returncode -eq 1 ]; then 
	dialog --ascii-lines --infobox "Cancel Selected1 - Function Aborted\nSleeping 2 seconds" 10 40 ; sleep 2
	MenuMain
fi

if [ $returncode -eq 255 ]; then 
	MenuMain
fi

if [ "$mode" == "RO" ]; then
 MenuMain

fi

Enable=$(echo "$DMRs" | sed -n '2p' )
CallHang=$(echo "$DMRs" | sed -n '3p' )
TXHang=$(echo "$DMRs"  | sed -n '4p' )
Id=$(echo "$DMRs"  | sed -n '5p' )
### 6
NetEnable=$(echo "$DMRs"  | sed -n '7p' )
NetAddress=$(echo "$DMRs"  | sed -n '8p')
NetModeHang=$(echo "$DMRs"  | sed -n '9p' )
NetType=$(echo "$DMRs" | sed -n '10p' )
NetPort=$(echo "$DMRs" | sed -n '11p' )
NetLocalPort=$(echo "$DMRs" | sed -n '12p' )


##  Write Values Back
if [ "$Enable" != "$d1" ]; then
        sudo sed -i '/^\[/h;G;/DMR]/s/\(Enable=\).*/\1'"$Enable"'/m;P;d' /etc/mmdvmhost
fi
if [ "$CallHang" != "$d2" ]; then
        sudo sed -i '/^\[/h;G;/DMR]/s/\(CallHang=\).*/\1'"$CallHang"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXHang" != "$d3" ]; then
        sudo sed -i '/^\[/h;G;/DMR]/s/\(TXHang=\).*/\1'"$TXHang"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Id" != "$d4" ]; then
        sudo sed -i '/^\[/h;G;/DMR]/s/\(Id=\).*/\1'"$Id"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetEnable" != "$d5" ]; then
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Enable=\).*/\1'"$NetEnable"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetAddress" != "$d6" ]; then
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Address=\).*/\1'"$NetAddress"'/m;P;d' /etc/mmdvmhost
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(RemoteAddress=\).*/\1'"$NetAddress"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetModeHang" != "$d7" ]; then
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(ModeHang=\).*/\1'"$NetModeHang"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetType" != "$d8" ]; then
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Type=\).*/\1'"$NetType"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetPort" != "$d9" ]; then
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Port=\).*/\1'"$NetPort"'/m;P;d' /etc/mmdvmhost
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(RemotePort=\).*/\1'"$NetPort"'/m;P;d' /etc/mmdvmhost
        sudo sed -i '/^\[/h;G;/DMR Network]/s/\(LocalPort=\).*/\1'"$NetPort"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NetLocalPort" != "$d10" ]; then
        sudo sed -i '/^\[/h;G;/DMR Networl]/s/\(LocalPort=\).*/\1'"$NetLocalPort"'/m;P;d' /etc/mmdvmhost
fi

	
dialog --ascii-lines --infobox "DMR Data Write Complete " 10 30 ; sleep 1


EditDMR
}

######################
function EditP25(){
#6

#P25 Section
d1=$(sed -nr "/^\[P25\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d2=$(sed -nr "/^\[P25\]/ { :l /NAC[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d3=$(sed -nr "/^\[P25\]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d4=$(sed -nr "/^\[P25\]/ { :l /TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
#P25 Network
d5=$(sed -nr "/^\[P25 Network\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
d6=$(sed -nr "/^\[P25 Network\]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

#P25 Gateway 
# Network Section
d7=$(sed -nr "/^\[General\]/ { :l /Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d8=$(sed -nr "/^\[Log\]/ { :l /FilePath[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d9=$(sed -nr "/^\[Log\]/ { :l /DisplayLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d10=$(sed -nr "/^\[Log\]/ { :l /FileLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d11=$(sed -nr "/^\[Network\]/ { :l /HostsFile1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d12=$(sed -nr "/^\[Network\]/ { :l /HostsFile2[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d13=$(sed -nr "/^\[Network\]/ { :l /P252DMRAddress[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d14=$(sed -nr "/^\[Network\]/ { :l /P252DMRPort[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d15=$(sed -nr "/^\[Network\]/ { :l /Static[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d16=$(sed -nr "/^\[Network\]/ { :l /RFHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)
d17=$(sed -nr "/^\[Network\]/ { :l /NetHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/p25gateway)


returncode=0
returncode=$?
exec 3>&1


P25d=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --separate-widget  $'\n'   \
        --ok-label "Save" \
        --title "P25 Section" \
        --mixedform "\n P25 Configuration Items (Editable)" 30 70 25\
        "P25 General"     	1 1 "General"  	1 25 35 0 2 \
        "Enable"        	2 3 "$d1"  	2 25 35 0 0 \
        "NAC"           	3 3 "$d2"  	3 25 35 0 0 \
        "ModeHang"      	4 3 "$d3"  	4 25 35 0 0 \
        "TXHang"        	5 3 "$d4"  	5 25 35 0 0 \
        "P25 Network"   	6 1 "Network" 	6 25 35 0 2 \
        "Enable"        	7 3 "$d5"  	7 25 35 0 0 \
        "ModeHang"      	8 3 "$d6"  	8 25 35 0 0 \
        "P25Gateway General"   	9 1 "General"  	9 25 35 0 2 \
        "Callsign"             10 3 "$d7"      10 25 35 0 0 \
        "P25Gateway Log"       11 1 "Log"      11 25 35 0 2 \
        "FilePath"             12 3 "$d8"      12 25 35 0 0 \
        "DisplayLevel"         13 3 "$d9"      13 25 35 0 0 \
        "FileLevel"            14 3 "$d10"     14 25 35 0 0 \
        "P25Gateway Network"   15 1 "Network"  15 25 35 0 2 \
        "HostsFile1"           16 3 "$d11"     16 25 35 0 0 \
        "HostsFile2"           17 3 "$d12"     17 25 35 0 0 \
        "P252DMRAddress"       18 3 "$d13"     18 25 35 0 0 \
        "P252DMRPort"          19 3 "$d14"     19 25 35 0 0 \
        "Static Talk Group"    20 3 "$d15"     20 25 35 0 0 \
        "RFHangTime"           21 3 "$d16"     21 25 35 0 0 \
        "NetHangTime"          22 3 "$d17"     22 25 35 0 0 \
 	2>&1 1>&3)

returncode=$?

if [ $returncode -eq 1 ]; then
        dialog --ascii-lines --infobox "Cancel Selected - Function Aborted!" 5 60
	MenuMain
fi
if [ $returncode -eq 0 ]; then
        dialog --ascii-lines --infobox "P25 Updating P25 Parameters" 5 60
fi

Enable1=$(echo "$P25d" | sed -n '2p')
NAC=$(echo "$P25d" | sed -n '3p')
ModeHang1=$(echo "$P25d" | sed -n '4p')
TXHang1=$(echo "$P25d" | sed -n '5p')

#P25 Network
Enable2=$(echo "$P25d" | sed -n '7p')
ModeHang2=$(echo "$P25d" | sed -n '8p')

#P25Gateway General
Callsign=$(echo "$P25d" | sed -n '10p')

#P25Gateway Log
FilePath=$(echo "$P25d" | sed -n '12p')
DisplayLevel=$(echo "$P25d" | sed -n '13p')
FileLevel=$(echo "$P25d" | sed -n '14p')

#P25Gateway Network
HostsFile1=$(echo "$P25d" | sed -n '16p')
HostsFile2=$(echo "$P25d" | sed -n '17p')
P252DMRAddress=$(echo "$P25d" | sed -n '18p')
P252DMRPort=$(echo "$P25d" | sed -n '19p')
Static=$(echo "$P25d" | sed -n '20p')
RFHangTime=$(echo "$P25d" | sed -n '21p')
NetHangTime=$(echo "$P25d" | sed -n '22p')


if [ "$Enable" != "$d1" ]; then
        sudo sed -i '/^\[/h;G;/P25]/s/\(Enable=\).*/\1'"$Enable1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$NAC" != "$d2" ]; then
        sudo sed -i '/^\[/h;G;/P25]/s/\(NAC=\).*/\1'"$NAC"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ModeHang" != "$d3" ]; then
        sudo sed -i '/^\[/h;G;/P25]/s/\(ModeHang=\).*/\1'"$ModeHang1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXHang" != "$d4" ]; then
        sudo sed -i '/^\[/h;G;/P25]/s/\(TXHang=\).*/\1'"$TXHang1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Enable" != "$d5" ]; then
        sudo sed -i '/^\[/h;G;/P25 Network]/s/\(Enable=\).*/\1'"$Enable2"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ModeHang" != "$d6" ]; then
        sudo sed -i '/^\[/h;G;/P25 Network]/s/\(ModeHang=\).*/\1'"$ModeHang2"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Callsign" != "$d7" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Callsign=\).*/\1'"$Callsign"'/m;P;d' /etc/p25gateway
fi

if [ "$FilePath" != "$d8" ]; then
  FROM=$(echo "$d8" | sed "s/\//\\\\\//g")
  TO=$(echo "$FilePath" | sed "s/\//\\\\\//g")
  sed -i "/^\[Log\]/,/^$/s/^FilePath=$FROM/FilePath=$TO/" /etc/p25gateway
fi
if [ "$DisplayLevel" != "$d9" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(DisplayLevel=\).*/\1'"$DisplayLevel"'/m;P;d' /etc/p25gateway
fi

if [ "$FileLevel" != "$d10" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileLevel=\).*/\1'"$FileLevel"'/m;P;d' /etc/p25gateway
fi

if [ "$HostsFile1" != "$d11" ]; then
  FROM=$(echo "$d11" | sed "s/\//\\\\\//g")
  TO=$(echo "$HostsFile1" | sed "s/\//\\\\\//g")
  sed -i "/^\[Network\]/,/^$/s/^HostsFile1=$FROM/HostsFile1=$TO/" /etc/p25gateway
fi
if [ "$HostsFile2" != "$d12" ]; then
  FROM=$(echo "$d12" | sed "s/\//\\\\\//g")
  TO=$(echo "$HostsFile2" | sed "s/\//\\\\\//g")
  sed -i "/^\[Network\]/,/^$/s/^HostsFile2=$FROM/HostsFile2=$TO/" /etc/p25gateway
fi
if [ "$P252DMRAddress" != "$d13" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(P252DMRAddress=\).*/\1'"$P252DMRAddress"'/m;P;d' /etc/p25gateway
fi
if [ "$P252DMRPort" != "$d14" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(P252DMRPort=\).*/\1'"$P252DMRPort"'/m;P;d' /etc/p25gateway
fi
if [ "$Static" != "$d15" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(Static=\).*/\1'"$Static"'/m;P;d' /etc/p25gateway
fi
if [ "$RFHangTime" != "$d16" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(RFHangTime=\).*/\1'"$RFHangTime"'/m;P;d' /etc/p25gateway
fi
if [ "$NetHangTime" != "$d17" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(NetHangTime=\).*/\1'"$NetHangTime"'/m;P;d' /etc/p25gateway
fi


dialog --ascii-lines --infobox "P25 Data Write Complete " 10 30 ; sleep 1

EditP25
}
#######################
function EditNXDN(){
#7
#P25 Section
nd1=$(sed -nr "/^\[NXDN\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd2=$(sed -nr "/^\[NXDN\]/ { :l /RAN[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd3=$(sed -nr "/^\[NXDN\]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd4=$(sed -nr "/^\[NXDN\]/ { :l /TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
#NXDN Network
nd5=$(sed -nr "/^\[NXDN Network\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd6=$(sed -nr "/^\[NXDN Network\]/ { :l /ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

#NXDN Gateway 
# Network Section
nd7=$(sed -nr "/^\[General\]/ { :l /Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd8=$(sed -nr "/^\[Log\]/ { :l /FilePath[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd9=$(sed -nr "/^\[Log\]/ { :l /DisplayLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd10=$(sed -nr "/^\[Log\]/ { :l /FileLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd11=$(sed -nr "/^\[Network\]/ { :l /HostsFile1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd12=$(sed -nr "/^\[Network\]/ { :l /HostsFile2[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd13=$(sed -nr "/^\[Network\]/ { :l /NXDN2DMRAddress[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd14=$(sed -nr "/^\[Network\]/ { :l /NXDN2DMRPort[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd15=$(sed -nr "/^\[Network\]/ { :l /Static[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd16=$(sed -nr "/^\[Network\]/ { :l /RFHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)
nd17=$(sed -nr "/^\[Network\]/ { :l /NetHangTime[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/nxdngateway)


returncode=0
returncode=$?
exec 3>&1


nxdnd=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --separate-widget  $'\n'   \
        --ok-label "Save" \
        --title "nxdn Section" \
        --mixedform "\n NXDN Configuration Items (Editable)" 30 70 25\
        "NXDN General"     	1 1 "General"  	1 25 35 0 2 \
        "Enable"        	2 3 "$nd1"  	2 25 35 0 0 \
        "RAN"           	3 3 "$nd2"  	3 25 35 0 0 \
        "ModeHang"      	4 3 "$nd3"  	4 25 35 0 0 \
        "TXHang"        	5 3 "$nd4"  	5 25 35 0 0 \
        "NXDN Network"   	6 1 "Network" 	6 25 35 0 2 \
        "Enable"        	7 3 "$nd5"  	7 25 35 0 0 \
        "ModeHang"      	8 3 "$nd6"  	8 25 35 0 0 \
        "nxdnGateway General"   	9 1 "General"  	9 25 35 0 2 \
        "Callsign"             10 3 "$nd7"      10 25 35 0 0 \
        "nxdnGateway Log"       11 1 "Log"      11 25 35 0 2 \
        "FilePath"             12 3 "$nd8"      12 25 35 0 0 \
        "DisplayLevel"         13 3 "$nd9"      13 25 35 0 0 \
        "FileLevel"            14 3 "$nd10"     14 25 35 0 0 \
        "NXDN Gateway Network"   15 1 "Network"  15 25 35 0 2 \
        "HostsFile1"           16 3 "$nd11"     16 25 35 0 0 \
        "HostsFile2"           17 3 "$nd12"     17 25 35 0 0 \
        "NXDN2DMRAddress"       18 3 "$nd13"     18 25 35 0 0 \
        "NXDN2DMRPort"          19 3 "$nd14"     19 25 35 0 0 \
        "Static Talk Group"    20 3 "$nd15"     20 25 35 0 0 \
        "RFHangTime"           21 3 "$nd16"     21 25 35 0 0 \
        "NetHangTime"          22 3 "$nd17"     22 25 35 0 0 \
 	2>&1 1>&3)

returncode=$?

if [ $returncode -eq 1 ]; then
        dialog --ascii-lines --infobox "Cancel Selected - Function Aborted!" 5 60
	MenuMain
fi
if [ $returncode -eq 0 ]; then
        dialog --ascii-lines --infobox "nxdn Updating nxdn Parameters" 5 60
fi

Enable1=$(echo "$nxdnd" | sed -n '2p')
RAN=$(echo "$nxdnd" | sed -n '3p')
ModeHang1=$(echo "$nxdnd" | sed -n '4p')
TXHang1=$(echo "$nxdnd" | sed -n '5p')

#nxdn Network
Enable2=$(echo "$nxdnd" | sed -n '7p')
ModeHang2=$(echo "$nxdnd" | sed -n '8p')

#nxdnGateway General
Callsign=$(echo "$nxdnd" | sed -n '10p')

#nxdnGateway Log
FilePath=$(echo "$nxdnd" | sed -n '12p')
DisplayLevel=$(echo "$nxdnd" | sed -n '13p')
FileLevel=$(echo "$nxdnd" | sed -n '14p')

#nxdnGateway Network
HostsFile1=$(echo "$nxdnd" | sed -n '16p')
HostsFile2=$(echo "$nxdnd" | sed -n '17p')
NXDN2DMRAddress=$(echo "$nxdnd" | sed -n '18p')
NXDN2DMRPort=$(echo "$nxdnd" | sed -n '19p')
Static=$(echo "$nxdnd" | sed -n '20p')
RFHangTime=$(echo "$nxdnd" | sed -n '21p')
NetHangTime=$(echo "$nxdnd" | sed -n '22p')


if [ "$Enable" != "$nd1" ]; then
        sudo sed -i '/^\[/h;G;/NXDN]/s/\(Enable=\).*/\1'"$Enable1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$RAN" != "$nd2" ]; then
        sudo sed -i '/^\[/h;G;/NXDN]/s/\(RAN=\).*/\1'"$RAN"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ModeHang" != "$nd3" ]; then
        sudo sed -i '/^\[/h;G;/NXDN]/s/\(ModeHang=\).*/\1'"$ModeHang1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXHang" != "$nd4" ]; then
        sudo sed -i '/^\[/h;G;/NXDN]/s/\(TXHang=\).*/\1'"$TXHang1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Enable" != "$nd5" ]; then
        sudo sed -i '/^\[/h;G;/NXDN Network]/s/\(Enable=\).*/\1'"$Enable2"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ModeHang" != "$nd6" ]; then
        sudo sed -i '/^\[/h;G;/NXDN Network]/s/\(ModeHang=\).*/\1'"$ModeHang2"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Callsign" != "$nd7" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Callsign=\).*/\1'"$Callsign"'/m;P;d' /etc/nxdngateway
fi

if [ "$FilePath" != "$nd8" ]; then
  FROM=$(echo "$nd8" | sed "s/\//\\\\\//g")
  TO=$(echo "$FilePath" | sed "s/\//\\\\\//g")
  sed -i "/^\[Log\]/,/^$/s/^FilePath=$FROM/FilePath=$TO/" /etc/nxdngateway
fi
if [ "$DisplayLevel" != "$nd9" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(DisplayLevel=\).*/\1'"$DisplayLevel"'/m;P;d' /etc/nxdngateway
fi

if [ "$FileLevel" != "$nd10" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileLevel=\).*/\1'"$FileLevel"'/m;P;d' /etc/nxdngateway
fi

if [ "$HostsFile1" != "$nd11" ]; then
  FROM=$(echo "$nd11" | sed "s/\//\\\\\//g")
  TO=$(echo "$HostsFile1" | sed "s/\//\\\\\//g")
  sed -i "/^\[Network\]/,/^$/s/^HostsFile1=$FROM/HostsFile1=$TO/" /etc/nxdngateway
fi
if [ "$HostsFile2" != "$nd12" ]; then
  FROM=$(echo "$nd12" | sed "s/\//\\\\\//g")
  TO=$(echo "$HostsFile2" | sed "s/\//\\\\\//g")
  sed -i "/^\[Network\]/,/^$/s/^HostsFile2=$FROM/HostsFile2=$TO/" /etc/nxdngateway
fi
if [ "$NXDN2DMRAddress" != "$nd13" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(NXDN2DMRAddress=\).*/\1'"$NXDN2DMRAddress"'/m;P;d' /etc/nxdngateway
fi
if [ "$NXDN2DMRPort" != "$nd14" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(NXDN2DMRPort=\).*/\1'"$NXDN2DMRPort"'/m;P;d' /etc/nxdngateway
fi
if [ "$Static" != "$nd15" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(Static=\).*/\1'"$Static"'/m;P;d' /etc/nxdngateway
fi
if [ "$RFHangTime" != "$nd16" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(RFHangTime=\).*/\1'"$RFHangTime"'/m;P;d' /etc/nxdngateway
fi
if [ "$NetHangTime" != "$nd17" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(NetHangTime=\).*/\1'"$NetHangTime"'/m;P;d' /etc/nxdngateway
fi


dialog --ascii-lines --infobox "NXDN Data Write Complete " 5 30 ; sleep 1

EditNXDN

}
##############
function EditYSF(){
#8

#YSF Section
y1=$(sed -nr "/^\[System Fusion\]/ { :l /^Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
y2=$(sed -nr "/^\[System Fusion\]/ { :l /^LowDeviation[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
y3=$(sed -nr "/^\[System Fusion\]/ { :l /^TXHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
y4=$(sed -nr "/^\[System Fusion\]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
#YSF Network Network
y5=$(sed -nr "/^\[System Fusion Network\]/ { :l /^Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

y6=$(sed -nr "/^\[System Fusion Network\]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

#YSF Gateway 
# General Section
y7=$(sed -nr "/^\[General\]/ { :l /Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y8=$(sed -nr "/^\[General\]/ { :l /Suffix[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y9=$(sed -nr "/^\[General\]/ { :l /WiresXCommandPassthrough[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y10=$(sed -nr "/^\[General\]/ { :l /Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y11=$(sed -nr "/^\[General\]/ { :l /Daemon[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)

#Info Section
y12=$(sed -nr "/^\[Info\]/ { :l /RXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y13=$(sed -nr "/^\[Info\]/ { :l /TXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y14=$(sed -nr "/^\[Info\]/ { :l /Power[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y15=$(sed -nr "/^\[Info\]/ { :l /Latitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y16=$(sed -nr "/^\[Info\]/ { :l /Longitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y17=$(sed -nr "/^\[Info\]/ { :l /Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y18=$(sed -nr "/^\[Info\]/ { :l /Description[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)

#Log
y19=$(sed -nr "/^\[Log\]/ { :l /DisplayLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y20=$(sed -nr "/^\[Log\]/ { :l /FileLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y21=$(sed -nr "/^\[Log\]/ { :l /FilePath[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y22=$(sed -nr "/^\[Log\]/ { :l /FileRoot[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)

#Network
y23=$(sed -nr "/^\[Network\]/ { :l /Startup[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)

#YSF Network
y24=$(sed -nr "/^\[YSF Network\]/ { :l /Enable[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)
y25=$(sed -nr "/^\[YSF Network\]/ { :l /Hosts[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/ysfgateway)

exec 3>&1

ysfd=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --separate-widget  $'\n' \
        --ok-label "Save" \
        --title "YSF Section" \
        --mixedform "\n YSF Configuration Items (Editable)" 0 70 0 \
        "YSF General"     	1 1 "YSF General"  		1 25 35 0 2 \
        "Enable"        	2 3 "$y1"  			2 25 35 0 0 \
        "LowDeviation"          3 3 "$y2"  			3 25 35 0 0 \
        "TXHang"	      	4 3 "$y3"  			4 25 35 0 0 \
        "ModeHang"        	5 3 "$y4"  			5 25 35 0 0 \
        "YSF Network"   	6 1 "YSF Network" 		6 25 35 0 2 \
        "Enable"        	7 3 "$y5"  			7 25 35 0 0 \
        "ModeHang"      	8 3 "$y6"  			8 25 35 0 0 \
        "YSFGateway General"   	9 1 "YSF Gateway General"  	9 25 35 0 2 \
        "Callsign"             	10 3 "$y7"      		10 25 35 0 0 \
        "Suffix"	       	11 3 "$y8"      		11 25 35 0 0 \
        "WiresXPassthrough"    	12 3 "$y9"      		12 25 35 0 0 \
        "Id"                   	13 3 "$y10"     		13 25 35 0 0 \
        "Daemon"               	14 3 "$y11"     		14 25 35 0 0 \
        "YSFGateway Info"      	15 1 "YSFGateway Info"  	15 25 35 0 2 \
        "RXFrequency"          	16 3 "$y12"     		16 25 35 0 0 \
        "TXFrequency"          	17 3 "$y13"     		17 25 35 0 0 \
        "Power"       		18 3 "$y14"     		18 25 35 0 0 \
        "Latitude"          	19 3 "$y15"     		19 25 35 0 0 \
        "Longitude"    		20 3 "$y16"     		20 25 35 0 0 \
        "Name"           	21 3 "$y17"     		21 25 35 0 0 \
        "Description"          	22 3 "$y18"     		22 25 35 0 0 \
        "YSFGateway Log"       	23 1 "YSFGateway Log"     	23 25 35 0 2 \
        "DisplayLevel"          24 3 "$y19"     		24 25 35 0 0 \
        "FileLevel"          	25 3 "$y20"     		25 25 35 0 0 \
        "FilePath"          	26 3 "$y21"     		26 25 35 0 0 \
        "FileRoot"          	27 3 "$y22"     		27 25 35 0 0 \
        "YSGGateway Network"   	28 1 "YSFGateway Network"     	28 25 35 0 2 \
        "Startup"          	29 3 "$y23"     		29 25 35 0 0 \
        "YSFGateway YSF Net"   	30 1 "$YSFGateway YSF Net"     	30 25 35 0 2 \
        "Enable"          	31 3 "$y24"     		31 25 35 0 0 \
        "Hosts"          	32 3 "$y25"     		32 25 35 0 0 \
 	2>&1 1>&3)

returncode=$?

if [ $returncode -eq 1 ]; then
MenuMain
fi

if [ $returncode -eq 255 ]; then
MenuMain
fi


##  1
Enable1=$(echo "$ysfd" | sed -n '2p')
LowDeviation=$(echo "$ysfd" | sed -n '3p')
TXHang=$(echo "$ysfd" | sed -n '4p')
ModeHang1=$(echo "$ysfd" | sed -n '5p')
## 6
Enable2=$(echo "$ysfd" | sed -n '7p')
ModeHang2=$(echo "$ysfd" | sed -n '8p')
## 9
Callsign=$(echo "$ysfd" | sed -n '10p')
Suffix=$(echo "$ysfd" | sed -n '11p')
WiresXPass=$(echo "$ysfd" | sed -n '12p')
Id=$(echo "$ysfd" | sed -n '13p')
Daemon=$(echo "$ysfd" | sed -n '14p')
## 15
RXFrequency=$(echo "$ysfd" | sed -n '16p')
TXFrequency=$(echo "$ysfd" | sed -n '17p')
Power=$(echo "$ysfd" | sed -n '18p')
Latitude=$(echo "$ysfd" | sed -n '19p')
Longitude=$(echo "$ysfd" | sed -n '20p')
Name=$(echo "$ysfd" | sed -n '21p')
Description=$(echo "$ysfd" | sed -n '22p')
## 23
DisplayLevel=$(echo "$ysfd" | sed -n '24p')
FileLevel=$(echo "$ysfd" | sed -n '25p')
FilePath=$(echo "$ysfd" | sed -n '26p')
FileRoot=$(echo "$ysfd" | sed -n '27p')
## 28
Startup=$(echo "$ysfd" | sed -n '29p')
## 30
Enable3=$(echo "$ysfd" | sed -n '31p')
Hosts=$(echo "$ysfd" | sed -n '32p')


if [ "$FilePath" != "$y21" ]; then
  FROM=$(echo "$y21" | sed "s/\//\\\\\//g")
  TO=$(echo "$FilePath" | sed "s/\//\\\\\//g")
 # sed -i "/^\[Log\]/,/^$/s/^FilePath=$FROM/FilePath=$TO/" /etc/ysfgateway
  sudo sed -i '/^\[/h;G;/Log]/s/\(FilePath=\).*/\1'"$TO"'/m;P;d' /etc/ysfgateway
fi

if [ "$Hosts" != "$y25" ]; then
  FROM=$(echo "$y25" | sed "s/\//\\\\\//g")
  TO=$(echo "$Hosts" | sed "s/\//\\\\\//g")
#  sed -i "/^\[YSF Network\]/,/^$/s/^Hosts=$FROM/FilePath=$TO/" /etc/ysfgateway
  sudo sed -i '/^\[/h;G;/YSF Network]/s/\(Hosts=\).*/\1'"$TO"'/m;P;d' /etc/ysfgateway
fi

if [ "$Enable1" != "$y1" ]; then
        sudo sed -i '/^\[/h;G;/System Fusion]/s/\(Enable=\).*/\1'"$Enable1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$LowDeviation" != "$y2" ]; then
        sudo sed -i '/^\[/h;G;/System Fusion]/s/\(LowDeviation=\).*/\1'"$LowDeviation"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXHang" != "$y3" ]; then
        sudo sed -i '/^\[/h;G;/System Fusion]/s/\(TXHang=\).*/\1'"$TXHang"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ModeHang1" != "$y4" ]; then
        sudo sed -i '/^\[/h;G;/System Fusion]/s/\(ModeHang=\).*/\1'"$ModeHang1"'/m;P;d' /etc/mmdvmhost
fi
##
if [ "$Enable2" != "$y5" ]; then
        sudo sed -i '/^\[/h;G;/System Fusion Network]/s/\(Enable=\).*/\1'"$Enable2"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ModeHang2" != "$y6" ]; then
        sudo sed -i '/^\[/h;G;/System Fusion Network]/s/\(ModeHang=\).*/\1'"$ModeHang2"'/m;P;d' /etc/mmdvmhost
fi
##
if [ "$Callsign" != "$y7" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Callsign=\).*/\1'"$Callsign"'/m;P;d' /etc/ysfgateway
fi
if [ "$Suffix" != "$y8" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Suffix=\).*/\1'"$Suffix"'/m;P;d' /etc/ysfgateway
fi
if [ "$WiresXPass" != "$y19" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(WiresXCommandPassthrough=\).*/\1'"$WiresXPass"'/m;P;d' /etc/ysfgateway
fi
if [ "$Id" != "$y10" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Id=\).*/\1'"$Id"'/m;P;d' /etc/ysfgateway
fi
if [ "$ndaemon" != "$y11" ]; then
        sudo sed -i '/^\[/h;G;/General]/s/\(Daemon=\).*/\1'"$Daemon"'/m;P;d' /etc/ysfgateway
fi
##
if [ "$RXFrequency" != "$y12" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1'"$RXFrequency"'/m;P;d' /etc/ysfgateway
fi
if [ "$TXFrequency" != "$y13" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1'"$TXFrequency"'/m;P;d' /etc/ysfgateway
fi
if [ "$Power" != "$y14" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Power=\).*/\1'"$Power"'/m;P;d' /etc/ysfgateway
fi
if [ "$Latitude" != "$y15" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Latitude=\).*/\1'"$Latitude"'/m;P;d' /etc/ysfgateway
fi
if [ "$Longitude" != "$y16" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Longitude=\).*/\1'"$Longitude"'/m;P;d' /etc/ysfgateway
fi
if [ "$Name" != "$y17" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Name=\).*/\1'"$Name"'/m;P;d' /etc/ysfgateway
fi
if [ "$Description" != "$y18" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Description=\).*/\1'"$Description"'/m;P;d' /etc/ysfgateway
fi

##

if [ "$DisplayLevel" != "$y19" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(DisplayLevel=\).*/\1'"$DisplayLevel"'/m;P;d' /etc/ysfgateway
fi
if [ "$FileLevel" != "$y20" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileLevel=\).*/\1'"$FileLevel"'/m;P;d' /etc/ysfgateway
fi
if [ "$FileRoot" != "$y22" ]; then
        sudo sed -i '/^\[/h;G;/Log]/s/\(FileRoot=\).*/\1'"$FileRoot"'/m;P;d' /etc/ysfgateway
fi
##
if [ "$Startup" != "$y23" ]; then
        sudo sed -i '/^\[/h;G;/Network]/s/\(Startup=\).*/\1'"$Startup"'/m;P;d' /etc/ysfgateway
fi
##
if [ "$Enable3" != "$y24" ]; then
        sudo sed -i '/^\[/h;G;/YSF Network]/s/\(Enable=\).*/\1'"$Enable3"'/m;P;d' /etc/ysfgateway
fi
##

#dialog \
#        --backtitle "MMDVM Host Configurator - VE3RD" \
#	--title " Edit Nextion Sections "  \
#	--ascii-lines --msgbox " This function Under Construction"  13 50
#

EditYSF

}

###################
function MenuMaint(){
if [ ! -d /etc/backups ]; then
  mkdir /etc/backups
fi


HEIGHT=25
WIDTH=40
CHOICE_HEIGHT=15
BACKTITLE="MMDVM Host Configurator - VE3RD"
TITLE="Maintnance Menu"
MENU="Choose one of the following options:"


MAINT=$(dialog --clear \
                --ascii-lines \
                --extra-button \
                --extra-label "MainMenu" \
                --cancel-label "EXIT" \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                1 "Backup Config Files" \
		2 "Restore Config Files" \
		3 "Restart MMDVMHost" \
		4 "Restart DMRGateway" \
		5 "Restart ALL Services" \
		6 "Reboot Hotspot" \
		7 "Update Host Files" \
		8 "Log File Monitor" \
		9 "Services" 2>&1 >/dev/tty)
exitcode=$?

if [ "$exitcode" -eq 3 ]; then
   MenuMain
fi

if [ "$exitcode" -eq 255 ]; then
   MenuMain
fi

if [ "$exitcode" -eq 1 ]; then
        dialog --ascii-lines --infobox "Cancel Selected - Exiting Script\nSleeping 2 seconds" 5 40 ; sleep 2
	clear

        exit
fi


if [ "$MAINT" -eq 1 ]; then
		dates=$(date +%F)
                cp /etc/mmdvmhost /etc/backups/mmdvmhost"-$dates"
		err1=$?
                cp /etc/ysfgateway /etc/backups/ysfgateway"-$dates"
		err2=$?
                cp /etc/nxdngateway /etc/backups/nxdngateway"-$dates"
		err3=$?
                cp /etc/p25gateway /etc/backups/p25gateway"-$dates"
		err4=$?
                cp /etc/dmrgateway /etc/backups/dmrgateway"-$dates"
		err5=$?
	errt=[[ $err1+$err2+$err3+$err4+$err5]]

	if [ $errt -gt 0 ]; then
        	dialog --ascii-lines --infobox "Backups FAILED!!  - Reloading Menu" 5 40 ; sleep 2        	
	else
		dialog --ascii-lines --infobox "Backups Complete - Reloading Menu" 5 40 ; sleep 2
	fi
		
	MenuMaint
fi


if [ "$MAINT" -eq 2 ]; then

     F1=$(dialog \
        --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD    -Tab Moves Cursor Between Areas -Tab Selects File" \
        --stdout \
        --title "Please choose a file" \
        --fselect /etc/backups/ 14 75 )

	exitcode=$?
	if [ $exitcode -eq 1 ]; then
		dialog --ascii-lines --infobox "Cancel Selected\nFunction Aborted" 5 40 ; sleep 2
		MenuMaint
	fi
	if [ $exitcode -eq 255 ]; then
		dialog --ascii-lines --infobox "ESC Button Detected\nFunction Aborted" 5 40 ; sleep 2
		MenuMaint
	fi


        if [ ! -z "$F1" ]; then
 		bf=$(echo "$F1" | cut -d "-" -f 1 )
		fn=$(echo "$bf" | cut -d "/" -f 4 )	
		dest="/etc/$fn"
	  	cp $F1 $dest
		err=$?
		if [ $err -eq 0 ]; then
			dialog --ascii-lines --infobox "Backup Config File $F1\nRestored to $dest" 5 60 ; sleep 5
		else
			dialog --ascii-lines --infobox "Restore Operation Failed" 5 40 ; sleep 2
		
		fi
	else
		dialog --ascii-lines --infobox "ERR - No File\nFunction Aborted" 5 40 ; sleep 2
        fi
fi

if [ "$MAINT" -eq 3 ]; then
sudo mmdvmhost.services restart
fi

if [ "$MAINT" -eq 4 ]; then
sudo dmrgateway.services restart
fi

if [ "$MAINT" -eq 5 ]; then
	sudo mmdvmhost.service restart
	sudo dmrgateway.service restar
	sudo p25gateway.service restart
	sudo ysfgateway.service restart
	sudo nxdngateway.service restart
fi

if [ "$MAINT" -eq 6 ]; then
	echo "Rebooting Hotspot - Log back in when it come up"
	sudo reboot
	exit
fi

if [ "$MAINT" -eq 7 ]; then
	echo "Updating All Host Files"
	echo "Please WAIT a few seconds"
	sudo HostFilesUpdate.sh
fi

if [ "$MAINT" -eq 8 ]; then
	LogMon
fi

if [ "$MAINT" -eq 9 ]; then
	Services
fi

MenuMaint

}
################
function EditNextion(){
#10
#ds1=$(sed -nr "/^\[D-Star]/ { :l /^ModeHang[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n1=$(sed -nr "/^\[Nextion]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n2=$(sed -nr "/^\[Nextion\]/ { :l /Brightness[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n3=$(sed -nr "/^\[Nextion\]/ { :l /DisplayClock[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n4=$(sed -nr "/^\[Nextion\]/ { :l /UTC[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n5=$(sed -nr "/^\[Nextion\]/ { :l /ScreenLayout[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n6=$(sed -nr "/^\[Nextion]/ { :l /IdleBrightness[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
n7=$(sed -nr "/^\[Nextion\]/ { :l /DisplayTempInFahrenheit[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

nd1=$(sed -nr "/^\[NextionDriver\]/ { :l /Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd2=$(sed -nr "/^\[NextionDriver\]/ { :l /SendUserDataMask[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd3=$(sed -nr "/^\[NextionDriver\]/ { :l /DataFilesPath[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd4=$(sed -nr "/^\[NextionDriver\]/ { :l /LogLevel[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd5=$(sed -nr "/^\[NextionDriver\]/ { :l /GroupsFile[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd6=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidFile[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd7=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidDelimiter[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd8=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidId[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd9=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidCall[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd10=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidName[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd11=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidX1[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd12=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidX2[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd13=$(sed -nr "/^\[NextionDriver\]/ { :l /DMRidX3[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd14=$(sed -nr "/^\[NextionDriver\]/ { :l /ShowModeStatus[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd15=$(sed -nr "/^\[NextionDriver\]/ { :l /RemoveDim[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd16=$(sed -nr "/^\[NextionDriver\]/ { :l /WaitForLan[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
nd17=$(sed -nr "/^\[NextionDriver\]/ { :l /SleepWhenInactive[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)


exec 3>&1

Next=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --separate-widget  $'\n'   \
        --ok-label "Save" \
        --title "Nextion Sections" \
        --mixedform "\n Nextion Configuration Items (Editable)" 30 70 30 \
        "Nextion"      		1 1 "General"   	1 20 35 0 2 \
        "Port"      		2 1 "$n1"   		2 20 35 0 0 \
        "Brightness"         	3 1 "$n2"   		3 20 35 0 0 \
        "DisplayClock"        	4 1 "$n3"   		4 20 35 0 0 \
        "UTC"         		5 1 "$n4"   		5 20 35 0 0 \
        "ScreenLayout"      	6 1 "$n5"   		6 20 35 0 0 \
        "IdleBrightness"        7 1 "$n6"   		7 20 35 0 0 \
        "DisplayTemp Deg F"     8 1 "$n7"   		8 20 35 0 0 \
        "Nextion Driver"        9 1 "Nextion Driver"   	9 20 35 0 2 \
        "Port"       	       10 1 "$nd1"   		10 20 35 0 0 \
        "SendUserDataMask"     11 1 "$nd2"   		11 20 35 0 0 \
        "DataFilesPath"       	12 1 "$nd3"   		12 20 35 0 0 \
        "LogLevel"       	13 1 "$nd4"   		13 20 35 0 0 \
        "GroupsFile"       	14 1 "$nd5"   		14 20 35 0 0 \
        "DMRidFile"       	15 1 "$nd6"   		15 20 35 0 0 \
        "DMRidDelimiter"       	16 1 "$nd7"   		16 20 35 0 0 \
        "DMRIdId"       	17 1 "$nd8"   		17 20 35 0 0 \
        "DMRidCall"       	18 1 "$nd9"   		18 20 35 0 0 \
        "DMRidName"       	19 1 "$nd10"   		19 20 35 0 0 \
        "DMRidX1"       	20 1 "$nd11"   		20 20 35 0 0 \
        "DMRidX2"       	21 1 "$nd12"   		21 20 35 0 0 \
        "DMRidX3"       	22 1 "$nd13"   		22 20 35 0 0 \
        "ShowModeStatus"       	23 1 "$nd14"   		23 20 35 0 0 \
        "RemoveDim"       	24 1 "$nd15"   		24 20 35 0 0 \
        "WaitForLan"       	25 1 "$nd16"   		25 20 35 0 0 \
        "SleepWhenInactive"     26 1 "$nd17"   		26 20 35 0 0 \
        2>&1 1>&3)

returncode=$?
#echo "$Next"

exec 3>&-

if [ $returncode -eq 1 ]; then
        dialog --ascii-lines --infobox "No Data - Function Aborted\nSleeping 2 seconds" 10 30 ; sleep 2
   MenuMain
fi

#Nextion
Port1=$(echo "$Next" | sed -n '2p')

Brightness=$(echo "$Next" | sed -n '3p')
DisplayClock=$(echo "$Next" | sed -n '4p')
UTC=$(echo "$Next" | sed -n '5p')
ScreenLayout=$(echo "$Next" | sed -n '6p')
IdleBrightness=$(echo "$Next" | sed -n '7p')
TempInFahrenheit=$(echo "$Next" | sed -n '8p')

#NextionDriver"
Port=$(echo "$Next" | sed -n '10p')

SendDataMask=$(echo "$Next" | sed -n '11p')
DataFilesPath=$(echo "$Next" | sed -n '12p')
LogLevel=$(echo "$Next" | sed -n '13p')
GroupsFile=$(echo "$Next" | sed -n '14p')
DMRidFile=$(echo "$Next" | sed -n '15p')
DMRidDelimiter=$(echo "$Next" | sed -n '16p')
DMRidId=$(echo "$Next" | sed -n '17p')
DMRidCall=$(echo "$Next" | sed -n '18p')
DMRidName=$(echo "$Next" | sed -n '19p')


DMRidX1=$(echo "$Next" | sed -n '20p')
DMRidX2=$(echo "$Next" | sed -n '21p')
DMRidX3=$(echo "$Next" | sed -n '22p')
ShowModeStatus=$(echo "$Next" | sed -n '23p')
RemoveDim=$(echo "$Next" | sed -n '24p')
WaitForLan=$(echo "$Next" | sed -n '25p')
SleepWhenInactive=$(echo "$Next" | sed -n '25p')


if [ "$Port1" != "$n1" ]; then
  TO=$(echo "$Port1" | sed "s/\//\\\\\//g")
  sudo sed -i '/^\[/h;G;/Nextion]/s/\(^Port=\).*/\1'"$TO"'/m;P;d' /etc/mmdvmhost	
fi

if [ "$Brightness" != "$n2" ]; then
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(Brightness=\).*/\1'"$Brightness"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DisplayClock" != "$n3" ]; then
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(DisplayClock=\).*/\1'"$DisplayClock"'/m;P;d' /etc/mmdvmhost
fi
if [ "$UTC" != "$n4" ]; then
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(UTC=\).*/\1'"$UTC"'/m;P;d' /etc/mmdvmhost
fi
if [ "$ScreenLayout" != "$n5" ]; then
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(ScreenLayout=\).*/\1'"$ScreenLayout"'/m;P;d' /etc/mmdvmhost
fi
if [ "$IdleBrightness" != "$n6" ]; then
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(IdleBrightness=\).*/\1'"$IdleBrightness"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TempInFahrenheit" != "$n7" ]; then
        sudo sed -i '/^\[/h;G;/Nextion]/s/\(DisplayTempInFahrenheit=\).*/\1'"$TempInFahrenheit"'/m;P;d' /etc/mmdvmhost
fi
## NextionDriver
if [ "$Port" != "$nd1" ]; then
  FROM=$(echo "$nd1" | sed "s/\//\\\\\//g")
  TO=$(echo "$Port" | sed "s/\//\\\\\//g")
  sed -i "/^\[NextionDriver\]/,/^$/s/^Port=$FROM/Port=$TO/" /etc/mmdvmhost
fi
if [ "$SendDataMask" != "$nd2" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(SendUserDataMask=\).*/\1'"$SendDataMask"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DataFilesPath" != "$nd3" ]; then
  FROM=$(echo "$nd3" | sed "s/\//\\\\\//g")
  TO=$(echo "$DataFilesPath" | sed "s/\//\\\\\//g")
  sed -i "/^\[NextionDriver\]/,/^$/s/^DataFilesPath=$FROM/DataFilesPath=$TO/" /etc/mmdvmhost
fi
if [ "$LogLevel" != "$nd4" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(LogLevel=\).*/\1'"$LogLevel"'/m;P;d' /etc/mmdvmhost
fi
if [ "$GroupsFile" != "$nd5" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(GroupsFile=\).*/\1'"$GroupsFile"'/m;P;d' /etc/mmdvmhost
fi

#-------------
if [ "$DMRidFile" != "$nd6" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidFile=\).*/\1'"$DMRidFile"'/m;P;d' /etc/mmdvmhost
fi
if [ "DMRidDelimiter" != "$nd7" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidDelimiter=\).*/\1'"$DMRidDelimiter"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRidId" != "$nd8" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidId\).*/\1'"$DMRidId"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRidCall" != "$nd9" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidCall=\).*/\1'"$DMRidCall"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRidName" != "$nd10" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidName=\).*/\1'"$DMRidName"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRidX1" != "$nd11" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidX1=\).*/\1'"$DMRidX1"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRidX2" != "$nd12" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidX2=\).*/\1'"$DMRidX2"'/m;P;d' /etc/mmdvmhost
fi
if [ "$DMRidX3" != "$nd13" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(DMRidX3=\).*/\1'"$DMRidX3"'/m;P;d' /etc/mmdvmhost
fi
#----------
if [ "$ShowModeStatus" != "$nd14" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(ShowModeStatus=\).*/\1'"$ShowModeStatus"'/m;P;d' /etc/mmdvmhost
fi
if [ "$RemoveDim" != "$nd15" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(RemoveDim=\).*/\1'"$RemoveDim"'/m;P;d' /etc/mmdvmhost
fi
if [ "$WaitForLan" != "$nd16" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(WaitForLan=\).*/\1'"$WaitForLan"'/m;P;d' /etc/mmdvmhost
fi
if [ "$SleepWhenInactive" != "$nd17" ]; then
        sudo sed -i '/^\[/h;G;/NextionDriver]/s/\(SleepWhenInactive=\).*/\1'"$SleepWhenInactive"'/m;P;d' /etc/mmdvmhost
fi
        
dialog --ascii-lines --infobox "Nextion Data Write Complete " 10 30 
EditNextion
}

function EditScreens(){
#10

#TFT
tPort=$(sed -nr "/^\[TFT Serial\]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
tBrightness=$(sed -nr "/^\[TFT Serial\]/ { :l /^Brightness[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
##HD44780
hRows=$(sed -nr "/^\[HD44780\]/ { :l /^Rows[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hColumns=$(sed -nr "/^\[HD44780\]/ { :l /^Columns[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hPins=$(sed -nr "/^\[HD44780\]/ { :l /^Pins[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hI2CAddress=$(sed -nr "/^\[HD44780\]/ { :l /^I2CAddress[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hPWM=$(sed -nr "/^\[HD44780\]/ { :l /^PWM[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hPWMPin=$(sed -nr "/^\[HD44780\]/ { :l /^PWMPin[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hPWMBright=$(sed -nr "/^\[HD44780\]/ { :l /^PWMBright[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hPWMDim=$(sed -nr "/^\[HD44780\]/ { :l /^PWMDim[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hDisplayClock=$(sed -nr "/^\[HD44780\]/ { :l /^DisplayClock[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
hUTC=$(sed -nr "/^\[HD44780\]/ { :l /^UTC[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
###OLED
oType=$(sed -nr "/^\[OLED\]/ { :l /^Type[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
oBrightness=$(sed -nr "/^\[OLED\]/ { :l /^Brightness[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
oInvert=$(sed -nr "/^\[OLED\]/ { :l /^Invert[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
oScroll=$(sed -nr "/^\[OLED\]/ { :l /^Scroll[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
oRotate=$(sed -nr "/^\[OLED\]/ { :l /^Rotate[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
oCast=$(sed -nr "/^\[OLED\]/ { :l /^Cast[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
oLogoScreensaver=$(sed -nr "/^\[OLED\]/ { :l /^LogoScreensaver[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
##### LCDproc
lAddress=$(sed -nr "/^\[LCDproc\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
lPort=$(sed -nr "/^\[LCDproc\]/ { :l /^Port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
lDimOnIdle=$(sed -nr "/^\[LCDproc\]/ { :l /^DimOnIdle[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
lDisplayClock=$(sed -nr "/^\[LCDproc\]/ { :l /^DisplayClock[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
lUTC=$(sed -nr "/^\[LCDproc\]/ { :l /^UTC[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

exec 3>&1


  scrn=$(dialog  \
        --title "Display Screen Sections - Non - Nextion " \
        --ok-label "Submit" \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --ascii-lines \
        --mixedform "Display Screens - Currently Read Only" 0 70 0 \
        "TFT Serial"    	1 1 "TFT Serial"  	1 22 35 0 2 \
        "Port"    		2 3 "$tPort"  		2 22 35 0 0 \
        "Brightness"     	3 3 "$tBrightness"     	3 22 35 0 0 \
        "HD44780"       	4 1 "HD44780"     	4 22 35 0 2 \
        "Rows"      		5 3  "$hRows"     	5 22 35 0 0 \
        "Columns"   		6 3 "$hColumns"     	6 22 35 0 0 \
        "Pins"  		7 3 "$hPins"     	7 22 35 0 0 \
        "I2CAddress"   		8 3 "$hI2CAddress"     	8 22 35 0 0 \
        "PWM"  			9 3 "$hPWM"     	9 22 35 0 0 \
        "PWMPin"  		10 3 "$hPWMPin"     	10 22 35 0 0 \
        "PWMBright"   		11 3 "$hPWMBright"     	11 22 35 0 0 \
        "PWMDim"  		12 3 "$hPWMDim"     	12 22 35 0 0 \
        "DisplayClock"  	13 3 "$hDisplayClock"   13 22 35 0 0 \
        "UTC"  			14 3 "$hUTC"     	14 22 35 0 0 \
        "OLED"  		15 1 "OLED"     	15 22 35 0 2 \
        "Type"  		16 3 "$oType"     	16 22 35 0 0 \
        "Brightness"  		17 3 "$oBrightness"     17 22 35 0 0 \
        "Invert"  		18 3 "$oInvert"     	18 22 35 0 0 \
        "Scroll"  		19 3 "$oScroll"     	19 22 35 0 0 \
        "Rotate"  		20 3 "$oRotate"     	20 22 35 0 0 \
        "Cast"  		21 3 "$oCast"     	21 22 35 0 0 \
        "LogoScreensaver"  	22 3 "$oLogoScreensaver"     	22 22 35 0 0 \
        "LCDproc"  		23 1 "LCDproc"     	23 22 35 0 2 \
        "Address"  		24 3 "$lAddress"     	24 22 35 0 0 \
        "Port"  		25 3 "$lPort"     	25 22 35 0 0 \
        "DimOnIdle"  		26 3 "$lDimOnIdle"     	26 22 35 0 0 \
        "DisplayClock"  	27 3 "$lDisplayClock"   27 22 35 0 0 \
        "UTC"  			28 3 "$lUTC"     	28 22 35 0 0 \
	2>&1 1>&3 )

errorcode=$?

if [ $errorcode -eq 1 ]; then
MenuMain
fi


dialog \
        --backtitle "MMDVM Host Configurator - VE3RD" \
	--title " Edit Non Nextion Screens "  \
	--ascii-lines --msgbox " This function Under Construction" 13 50

result=$?
EditScreens
}
##########################
function EditInfo(){
#2
RXF=$(sed -nr "/^\[Info\]/ { :l /RXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
TXF=$(sed -nr "/^\[Info\]/ { :l /TXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
Lat=$(sed -nr "/^\[Info\]/ { :l /Latitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost) 
Lon=$(sed -nr "/^\[Info\]/ { :l /Longitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost) 
Loc=$(sed -nr "/^\[Info\]/ { :l /Location[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost) 
Des=$(sed -nr "/^\[Info\]/ { :l /Description[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost) 
URLs=$(sed -nr "/^\[Info\]/ { :l /URL[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)

exec 3>&1

Infod=$(dialog  --ascii-lines \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --separate-widget  $'\n'   \
        --ok-label "Save" \
        --title "Info Section" \
        --form "\n Info Configuration Items (Editable)" 20 70 12\
        "RXFrequency"      1 1 "$RXF"  	1 15 35 0 \
        "TXFrequency"      2 1 "$TXF"  	2 15 35 0 \
        "Latitude"         3 1 "$Lat" 	3 15 35 0 \
        "Longitude"        4 1 "$Lon"  	4 15 35 0 \
        "Location"         5 1 "$Loc"  	5 15 35 0 \
        "Description"      6 1 "$Des"  	6 15 35 0 \
        "URL"              7 1 "$URLs"  7 15 35 0 \
        2>&1 1>&3)

returncode=$?


if [ $returncode -eq 1 ]; then
        dialog --ascii-lines --infobox "No Data - Function Aborted\nSleeping 2 seconds" 10 30 ; sleep 2
        MenuMain
fi

if [ $mode == "RO" ]; then
	MenuMain
fi




Description=$(echo "$Infod" | sed -n '6p')
exec 3>&-


RXFrequency=$(echo "$Infod" | sed -n '1p' )
TXFrequency=$(echo "$Infod" | sed -n '2p' )
Latitude=$(echo "$Infod"  | sed -n '3p' )
Longitude=$(echo "$Infod"  | sed -n '4p' )
Location=$(echo "$Infod"  | sed -n '5p' )
Description=$(echo "$Infod"  | sed -n '6p')
URL=$(echo "$Infod"  | sed -n '7p' )

##  Write Values Back
if [ "$RXFrequency" != "$RXF" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1'"$RXFrequency"'/m;P;d' /etc/mmdvmhost
fi
if [ "$TXFrequency" != "$TXF" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1'"$TXFrequency"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Latitude" != "$Lat" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Latitude=\).*/\1'"$Latitude"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Longitude" != "$Lon" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Longitude=\).*/\1'"$Longitude"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Location" != "$Loc" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Location=\).*/\1'"$Location"'/m;P;d' /etc/mmdvmhost
fi
if [ "$Description" != "$Des" ]; then
        sudo sed -i '/^\[/h;G;/Info]/s/\(Description=\).*/\1'"$Description"'/m;P;d' /etc/mmdvmhost
fi
if [ "$URL" != "$URLs" ]; then
  FROM=$(echo "$URLs" | sed "s/\//\\\\\//g")
  TO=$(echo "$URL" | sed "s/\//\\\\\//g")
  sed -i "/^\[Info\]/,/^$/s/^URL=$FROM/URL=$TO/" /etc/mmdvmhost
fi

EditInfo
}

###############################
function MenuMain(){

#echo "Starting Main Menu Dialog"

HEIGHT=25
WIDTH=60
CHOICE_HEIGHT=35
BACKTITLE="MMDVM Host Configurator - VE3RD"
TITLE="Main Menu Mode=$mode"
MENU="Choose one of the following options\n RO Read Only"


CHOICE=$(dialog --clear \
		--stdout \
		--ascii-lines \
                --cancel-label "EXIT" \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
          	1 "Edit General Section" \
         	2 "Edit Info Section" \
         	3 "Edit Log Section" \
         	4 "Edit Modem Section" \
         	5 "Edit DMR Section" \
         	6 "Edit P25 Section" \
         	7 "Edit NXDN Section" \
         	8 "Edit YSF Section" \
         	9 "Edit Nextion Sections" \
        	10 "Edit Non Nextion Displays - RO" \
        	11 "Edit TBA - NYA" \
        	12 "Edit Timers" \
        	13 "Edit DMRGateway" \
        	14 "Maintenance & Backup/Restore" \
        	15 "Check - Set Modes and Enables" \
        	16 "Set Master All Modes" \
        	17 "Start Test Funtion" 2>&1 )
#>/dev/tty)

#       "${OPTIONS[@]}" )
#3 2>&1 1>&3 )
#2>&1 >/dev/tty)

exitcode=$?
#echo "ExitCode = $exitcode"
#echo "Choice = $CHOICE"


if [ $exitcode -eq 3 ]; then
  mmdvmhost.service restart
fi
if [ $exitcode -eq 1 ]; then
        dialog --ascii-lines --infobox "Cancel Selected - Exiting Script\nSleeping 2 seconds" 5 40 ; sleep 2
         exit
   
fi


if [ -z "$CHOICE" ]; then
        dialog --ascii-lines --infobox "Choice Box Empty - Exiting Script\nSleeping 2 seconds" 5 40 ; sleep 2
 exit
fi


case $CHOICE in
        1) EditGeneral ;;
        2) EditInfo ;;
        3) EditLog ;;
        4) EditModem ;;
        5) EditDMR ;;
        6) EditP25 ;;
        7) EditNXDN ;;
        8) EditYSF ;;
        9) EditNextion ;;
        10) EditScreens ;;
        11) EditModeGroup ;;
        12) EditTimers ;;
        13) EditDMRGate ;;
        14) MenuMaint ;;
        15) CheckSetModes ;;
        16) SelectMode ;;
        17) MasterServ ;;
esac


}
################

function searchNetHost(){

declare -a SearchTxt=( $(dialog --title " P25 Server Search Utility" \
        --ascii-lines \
        --clear \
        --colors \
        --backtitle "MMDVM Host Configurator - VE3RD" \
        --inputbox "Enter your Search Criteria" 8 70  "tgif" 2>&1 >/dev/tty) )
# get response
response=$?

grep "$SearchTxt" /usr/local/etc/P25_Hosts.txt | tr "\t" " " | sed 's/\( \)*/\1/g' | tail -5  | cut  -d " " -f1 > tmpfile1
grep "$SearchTxt" /usr/local/etc/P25_Hosts.txt | tr "\t" " " | sed 's/\( \)*/\1/g' | tail -5  | cut  -d " " -f4 > tmpfile4

 paste tmpfile1 tmpfile4 | pr -t -e24 > tmpfile

while read LINE
  do
   case $LINE in
	'/ >'*|---*|'/ > '*)
        continue;;
  esac
 #echo -n " 1\"$LINE\"" >result
done < tmpfile

}


##########################    Start of Main Program #########
echo "Staring Script"

if [ ! -d /etc/backups ]; then
 sudo mount -o remount,rw / > /dev/null

  mkdir /etc/backups
  dates=$(date +%F)
  cp /etc/mmdvmhost /etc/backups/mmdvmhost"-$dates"
  cp /etc/ysfgateway /etc/backups/ysfgateway"-$dates"
  cp /etc/nxdngateway /etc/backups/nxdngateway"-$dates"
  cp /etc/p25gateway /etc/backups/p25gateway"-$dates"
  cp /etc/dmrgateway /etc/backups/dmrgateway"-$dates"
sudo mount -o remount,ro / > /dev/null
fi


if [ "$mode" == "RW" ]; then
sudo mount -o remount,rw / > /dev/null
else
sudo mount -o remount,ro / > /dev/null
fi



MenuMain
#EditDMRGateNet 1
#EditInfo
#mmdvmhost.service restart

