#!/bin/bash
sudo mount -o remount,rw /
if [ ! -f /var/www/dashboard/mmdvmhost/functions.php.orig ]; then
	cp /var/www/dashboard/mmdvmhost/functions.php /var/www/dashboard/mmdvmhost/functions.php.orig 
fi
cp /home/pi-star/Scripts/functions.php /var/www/dashboard/mmdvmhost/
echo "Key Up on a different TG to initalize the storage file"

