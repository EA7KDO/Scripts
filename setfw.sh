#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Installing the Nextion Driver Firewall Rule             #
#                                                          #
#  VE3RD                                      2020/04/07   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /
sudo sh -c 'echo "iptables -A OUTPUT -p tcp --dport 5040 -j ACCEPT" > /root/ipv4.fw' 
sudo pistar-firewall
sudo mount -o remount,ro /

