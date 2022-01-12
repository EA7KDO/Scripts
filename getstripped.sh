#!/bin/bash
############################################################
#  Get User ID Database from radioid.net                   #
#  Save it to /usr/local/etc/stripped.csv                  #
#  Cpnvert 'United States' to 'USA'                        #
#  					                   #
#  VE3RD                                      2022-01-12   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /

wget https://database.radioid.net/static/user.csv -O /usr/local/etc/stripped.csv
sudo sed -i 's/United States/USA/g' /usr/local/etc/stripped.csv
sudo mount -o remount,ro /

