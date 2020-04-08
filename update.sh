#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Updating the Scripts Directory                          #
#                                                          #
#  VE3RD                                      2020/04/08   #
############################################################
set -o errexit
set -o pipefail
cd /home/pi-star/Scripts
sudo mount -o remount,rw /
sudo git pull
sudo mount -o remount,ro /

