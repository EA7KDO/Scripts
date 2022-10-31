#!/bin/bash
#########################################################
#  Nextion Support for Nextion screen. Used to dump     #
#  current TG and change to TG4000                      #
#                                                       #
#  K5MRE & KF6S & VE3RD                     05-19-2021  #
#########################################################
# Use passed TS if present or default to TS2 (zero based code=1)
# Enhanced to work when the DMRGateway is used.

if [ -z "$1" ]; then
TS="1"
else
TS=$1
fi

TG=4000

#This Function tests each network in the DMRGateway File for the Network connected to the TGIF Server
# and then obtains the digital ID used to connect to the server
function getnetid {
Net1=$(sed -nr "/^\[DMR Network 1\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
Net2=$(sed -nr "/^\[DMR Network 2\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
Net3=$(sed -nr "/^\[DMR Network 3\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
Net4=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
Net5=$(sed -nr "/^\[DMR Network 5\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
Net6=$(sed -nr "/^\[DMR Network 6\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)

if [ Net1 = "TGIF_Network" ]; then
 ID=$(sed -nr "/^\[DMR Network 1\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
fi
if [ Net2 = "TGIF_Network" ]; then
 ID=$(sed -nr "/^\[DMR Network 2\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
fi
if [ Net3 = "TGIF_Network" ]; then
 ID=$(sed -nr "/^\[DMR Network 3\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
fi
if [ Net4 = "TGIF_Network" ]; then
 ID=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
fi
if [ Net5 = "TGIF_Network" ]; then
 ID=$(sed -nr "/^\[DMR Network 5\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
fi
if [ Net6 = "TGIF_Network" ]; then
 ID=$(sed -nr "/^\[DMR Network 6\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
fi
}

# This function tests to see if you are using the DMRGateway, and if so, it will run the getnetid function above
# OR   pickup the ID from /etc/mmdvmhost
function CheckMode {

        ## gate indicates use of the DMRGateway and Network 4
        addr=$(sed -nr "/^\[DMR Network\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
        if [ "$addr" = "127.0.0.1" ] ; then
                ID=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
                #run the following function to get the network user ID
                getnetid
        else
                ID=$(sed -nr "/^\[DMR\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
        fi
}

# Run Function CheckMode to find correct DGId
CheckMode

## Main script starts here
#echo "ID:$ID      Address:$addr     TS:$TS    TG:$TG"
curl -s http://tgif.network:5040/api/sessions/update/$ID/$TS/$TG
## To check arquments being passed to command take off the ## in front of echo below
## echo curl -s http://tgif.network:5040/api/sessions/update/$ID/$TS/$TG
				
