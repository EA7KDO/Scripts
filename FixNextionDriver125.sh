#!/bin/bash
sudo mount -o remount,rw /
#sudo nextiondriver.service stop
#sudo rm /usr/local/bin/NextionDriver
#sudo cp NextionDriver /usr/local/bin/
if grep -Fq SendUserDataMask /etc/mmdvmhost; then     
	echo "SendUserDataMask Found"
 else     
	echo "Inserting SendUserDataMask"
	sed -i '/^\[NextionDriver\]/a\SendUserDataMask=0b00011110' /etc/mmdvmhost
fi

awk '/\[Nextion/{
  if($0~/NextionDriver/){
    found=1
  }
  else{
    found=""
  }
}
found==""
'

#sudo nextiondriver.service restart

