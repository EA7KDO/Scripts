#!/bin/bash
rm /usr/local/etc/stripped2.cs*
rm /home/pi-star/Scripts/stripped2.csv
wget https://github.com/EA7KDO/Scripts/blob/master/stripped2.csv /home/pi-star/Scripts/stripped2.csv
cp /home/pi-star/Scripts/stripped2.csv /usr/local/etc/

