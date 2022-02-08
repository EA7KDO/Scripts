#!/bin/bash
if [ -f /usr/local/etc/stripped2.* ]; then
rm /usr/local/etc/stripped2.*
fi
if [ -f /home/pi-star/Scripts/stripped2.csv ]; then
rm /home/pi-star/Scripts/stripped2.csv
fi
sudo wget https://raw.githubusercontent.com/EA7KDO/Scripts/master/stripped2.csv /home/pi-star/Scripts/stripped2.csv
cp /home/pi-star/Scripts/stripped2.csv /usr/local/etc/

