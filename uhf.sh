#!/bin/bash
######################################################################
#  Prime_TGIF_Network Support        	 			     #
#  This Script will update the /usr/local/etc/DMR_Hosts.txt File     #
#								     #
#  VE3RD                               			2020-05-01   #
######################################################################
sudo mount -o remount,rw /

        echo "Updating Hostfiles..."
        sudo /usr/local/sbin/HostFilesUpdate.sh 
        if [ "$?" == "0" ]; then
		echo "Host Files Successfully Updated"	
	else
		echo "Host File Update Failed!"
	fi


