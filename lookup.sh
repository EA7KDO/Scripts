#!/bin/bash
#########################################################################
#  User Data Lookup Utility                                             #
#  This Script will set the user lookup to either                       #
#  QRZ or RadioID                                                       #
#                                                                       #
#  VE3RD                                                2021-02-07      #
###########################################################333###########
export NCURSES_NO_UTF8_ACS=1
#declare -i slen

if [ "$1" ]; then
char="$1"
char=${char^^}
	key=${char:0:1}
else
	key="Q"
fi
#echo "$key"

fn=/etc/pistar-css.ini
sudo mount -o remount,rw /

serv="QRZ"

if [ "$key" == "Q" ]; then
	serv="QRZ"
fi
if [ "$key" == "R" ]; then

      serv="RadioID"
fi

echo "$serv"
#  /etc/pistar-css.ini:Service=QRZ
 sudo sed -i '/^\[/h;G;/Lookup/s/\(Service=\).*/\1'"$serv"'/m;P;d' /etc/pistar-css.ini 

sudo mount -o remount,ro /





