#!/bin/bash
############################################################
#  Get Name From:                                          #
#  /usr/local/etc/stripped.csv using call sign or dgid     #
#   as key                                                 #
#  Pass call sign or dgid in $1                            #
#  Pass Field Number in $2                                 #
#                                                          #
#                                                          #
#  KF6S/VE3RD                                  2020-11-24  #
############################################################
set -o errexit

if [ -z "$1" ]; then
         exit
fi

#NAME=$(cat /usr/local/etc/stripped.csv | grep -w -F $1 | head -1 | awk -F, '{print $3}')

#mt=$(sudo sed -n '/'"$1"'/p' /usr/local/etc/stripped.csv | head -1 | cut -d',' -f1)
mt=$(sudo sed -n '/'"$1"'/p' /usr/local/etc/stripped.csv | grep -w -F $1 | head -1)
if [ -z "$mt" ]; then
    echo "Not Found"
   exit
fi

Id=$(echo "$mt" | cut -d',' -f1)
Call=$(echo "$mt" | cut -d',' -f2)
Name1=$(echo "$mt" | cut -d',' -f3)
Name2=$(echo "$mt" | cut -d',' -f4)
City=$(echo "$mt" | cut -d',' -f5)
State=$(echo "$mt" | cut -d',' -f6)
Country=$(echo "$mt" | cut -d',' -f7)

case "$2" in
"1")
echo "$Id"
;;
"2")
echo "$Call"
;;
3)
echo "$Name1"
;;
4)
echo "$Name2"
;;
5)
echo "$City"
;;
6)
echo "$State"
;;
7)
echo "$Country"
;;
34)
echo "$Name1 $Name2"
;;
567)
echo "$City $State $Country"
;;
esac

