#!/bin/bash
ssid="YourESSID"
pwd="YourPasswd"

sudo nmcli dev wifi connect "$ssid" password "$pwd"

