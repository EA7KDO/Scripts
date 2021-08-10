'''
 *   Copyright (C) 2016 Alex Koren
 *   Modified 8/9/2021: Michael Eckhoff - Modified to trigger nextion screen calibration
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
'''

import serial
import sys
import re

e = "\xff\xff\xff"

def getBaudrate(ser, fSize=None, checkModel=None):
    for baudrate in (2400, 4800, 9600, 19200, 38400, 57600, 115200):
        ser.baudrate = baudrate
        ser.timeout = 3000 / baudrate + .2
        print 'Trying with baudrate: ' + str(baudrate) + '...'
        ser.write("\xff\xff\xff")
        ser.write('connect')
        ser.write("\xff\xff\xff")
        r = ser.read(128)
        if 'comok' in r:
            print 'Connected with baudrate: ' + str(baudrate) + '...'
            noConnect = False
            status, unknown1, model, fwversion, mcucode, serial, flashSize = r.strip("\xff\x00").split(',')
            print 'Status: ' + status.split(' ')[0]
            if status.split(' ')[1] == "1":
                print 'Touchscreen: yes'
            else:
                print 'Touchscreen: no'
            print 'Model: ' + model
            print 'Firmware version: ' + fwversion
            print 'MCU code: ' + mcucode
            print 'Serial: ' + serial
            print 'Flash size: ' + flashSize
            if fSize and fSize > flashSize:
                print 'File too big!'
                return False
            if checkModel and not checkModel in model:
                print 'Wrong Display!'
                return False
            return True
    return False

def calibrate(ser, checkModel=None):
    if not getBaudrate(ser, 0, checkModel):
        print 'Could not find baudrate or wrong display.'
        exit(1)

    print 'Sending calibration command...'

    ser.write("\xff\xff\xff")
    ser.write('touch_j')
    ser.write("\xff\xff\xff")

    print 'Screen should be in calibration mode...'
    exit(0)

if __name__ == "__main__":
    if len(sys.argv) != 3 and len(sys.argv) != 2:
        print 'usage:\npython nextion.py /path/to/dev/ttyDevice [nextion_model_name]\
        \nexample: nextion.py /dev/ttyUSB0 NX3224T024\
        \nnote: model name is optional'
        exit(1)

    try:
        ser = serial.Serial(sys.argv[1], 9600, timeout=5)
    except serial.serialutil.SerialException:
        print 'could not open serial device ' + sys.argv[1]
        exit(1)
    if serial.VERSION <= "3.0":
        if not ser.isOpen():
            ser.open()
    else:
        if not ser.is_open:
            ser.open()

    checkModel = None
    if len(sys.argv) == 3:
        checkModel = sys.argv[2]
        pattern = re.compile("^NX\d{4}[TK]\d{3}$")
        if not pattern.match(checkModel):
            print 'Invalid model name. Please give a correct one (e.g. NX3224T024)'
            exit(1)
    calibrate(ser, checkModel)
