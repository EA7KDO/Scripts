#!/bin/bash
sudo nextiondriver.service stop
sudo rm /usr/local/bin/NextionDriver
sudo cp NextionDriver /usr/local/bin/
sudo nextiondriver.service start
sudo reboot
