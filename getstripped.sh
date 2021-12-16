#!/bin/bash
############################################################
#  Get User ID Database                                    #
#  VE3RD                                      2020-05-20   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /

wget https://database.radioid.net/static/user.csv -O /usr/local/etc/stripped.csv
sudo sed -i 's/United States/US/g' /usr/local/etc/stripped.csv
sudo mount -o remount,ro /


