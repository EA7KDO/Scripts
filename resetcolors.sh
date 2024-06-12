#!/bin/bash
############################################################
#  This script will remove the old /etc/Colors.ini         #
#  and copy in the new one		                   #
#                                                          #
#  VE3RD                                      2024/06/12   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /
sudo rm /etc/Colors.ini
sudo cp /usr/local/etc/Nextion_Support/Colors.ini /etc/
sudo mount -o remount,ro /

