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
wget https://database.radioid.net/static/user.csv -O /usr/local/etc/user.csv
sudo cp /usr/local/etc/user.csv /usr/local/etc/stripped.csv
#sudo sed -i 's/United States/USA/g' /usr/local/etc/stripped.csv
sudo mount -o remount,ro /

