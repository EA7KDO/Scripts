#!/bin/bash

CYAN='\033[0;36m'
NC='\033[0m' # No Color

if [ -d /P25 ]; then
  rm -r /P25
fi


echo -e "${CYAN} Getting Source Code from Github ${NC}"
git clone https://github.com/g4klx/P25Clients /P25
cd /P25/P25Reflector

echo -e "${CYAN} Making Binary File ${NC}"
sudo make clean
sudo make

echo -e "${CYAN} Putting Binary into /usr/local/bin ${NC}"
make install

echo -e "${CYAN} Putting .ini File into /etc ${NC}"
cp P25Reflector.ini /etc/

echo -e "${CYAN} Adjusting File Paths in P25Reflector.ini ${NC}"
sudo sed -i '/^\[/h;G;/\[Log/s/\(FilePath=\).*/\1'"\/var\/log\/pi-star"'/m;P;d' /etc/P25Reflector.ini
sudo sed -i '/^\[/h;G;/\[Id Lookup/s/\(Name=\).*/\1'"\/usr\/local\/etc\/DMRIds.dat"'/m;P;d' /etc/P25Reflector.ini
sudo sed -i '/^\[/h;G;/\[General/s/\(Daemon=\).*/\10/m;P;d' /etc/P25Reflector.ini
sudo sed -i '/^\[/h;G;/\[Log/s/\(DisplayLevel=\).*/\10/m;P;d' /etc/P25Reflector.ini

echo -e "${CYAN} Getting New Service startup Script ${NC}"
wget https://raw.githubusercontent.com/VE3RD/Scripts-RD/main/p25reflector.service 
chmod +x p25reflector.service

echo -e "${CYAN} Putting service startup script into /usr/local/sbin/ ${NC}"
cp p25reflector.service /usr/local/sbin

test=$(grep 'p25reflector.service start' /etc/rc.local)
if [ -z "$test" ]; then
	echo -e "${CYAN} Setting P25Reflector to auto start on bootup ${NC}"
	sudo sed -i '/^exit.*/i sudo /usr/local/sbin/p25reflector.service start' /etc/rc.local
else
	echo -e "${CYAN} P25Reflector Boot Start Already Exists in /etc/rc.local  ${NC}"
fi
echo ""
echo -e "${CYAN} All DONE! - Have Fun!!! ${NC}"
echo ""
echo -e "${CYAN} Operational Commands ${NC}"
echo -e ""
echo -e "${CYAN} p25reflector.service start ${NC}"
echo -e "${CYAN} p25reflector.service stop ${NC}"
echo -e "${CYAN} p25reflector.service restart ${NC}"
echo -e "${CYAN} p25reflector.service status ${NC}"

