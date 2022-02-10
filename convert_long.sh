#!/bin/bash
############################################################
#  This script will lookup long country names and convert  #
#  a two or three letter short form for stripped.csv       #
#  IE: convert 'United States' to 'USA'                    #
#  					                   #
#  VE3RD                                      2022-02-10   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /

cat /usr/local/etc/stripped.csv |                                          # piping file contents to the loop
while read line; do                                      # reading the input stream line by line
#	echo "$line" 
#	echo "$line" | cut -d "," -f 7
	cntry=$(echo "$line" | cut -d "," -f 7)
#	echo "Short: $cntry"

#	size=${#cntry}

	cntry2=$(awk "/$cntry/" ./country.csv | cut -d "," -f2)
	if [ ! -z cntry2 ]; then
#		sudo sed -i 's/United States/USA/g' /usr/local/etc/stripped.csv
	        sudo sed -i #s/'"$cntry"'/'"$cntry2"'/# /usr/local/etc/stripped.csv
	fi
done


