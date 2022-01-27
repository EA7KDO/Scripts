#!/bin/bash
#########################################################################
#  P25_Network Support                                                  #
#  This Script will install The Prime Security Password into            #
#  /root/P25Hosts.txt and run the Pi-Star Host File Updatde Routine    #
#                                                                       #
#  VE3RD                                                2020-05-12      #
###########################################################333###########
export NCURSES_NO_UTF8_ACS=1
declare -i slen

sudo mount -o remount,rw /

slen2=$(expr length "$sc2")

echo "$sc1"
echo "$sc2"
m1=""
m2="0000"
m3="tgif.network"
m5="62031"

	textstr="10210\t\mnet.hopto.org\t41000"

        sudo sed -i "\$a$textstr" /root/P25Hosts.txt

        echo "Updating Hostfiles..."

        sudo /usr/local/sbin/HostFilesUpdate.sh

        if [ "$?" == "0" ]; then
                echo "Host Files Successfully Updated"
        else
                echo "Host File Update Failed!"
        fi
        echo ""


echo "Created an entry in your PR% Local Host file called  10210"




