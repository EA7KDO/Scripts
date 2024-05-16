#!/bin/bash
#########################################################
#  Support for Nextion screen, get power quality        #
#  since last re-boot. Pass "P" for simple display of   #
#  only Power info or "ALL" for all known values.       #
#                                                       #
#  KF6S                                     05-18-2020  #
#########################################################

set -o errexit
set -o pipefail

if [ -z "$1" ]; then
roption="P"
else roption=$1
fi

#echo "Report Option:" "$roption"

if [ $roption == $"P" ]; then
        hex=$(vcgencmd get_throttled | awk '{print substr( $0, 11, 200 ) }')
#	echo "$hex"
	echo $(($hex))
#	

        if (( ($hex & 0x01) == 0x01 ))
                then echo "Under voltage detected"
        fi

        if (( ($hex & 0x02) == 0x02 ))
                then echo "Arm frequency capped"
        fi

        if (( ($hex & 0x04) == 0x04 ))
                then echo "Currently throttled"
        fi

        if (( ($hex & 0x08) == 0x08 ))
                then echo "Soft temperature limit active"
        fi

        if (( ($hex & 0x8000)== 0x8000 ))
                then echo "Under voltage has occurred since last boot"
        fi

        if (( ($hex & 0x10000) == 0x10000 ))
	        then echo "Arm frequency capped has occurred"
        fi

        if (( ($hex & 0x20000) == 0x20000 ))
                then echo "Throttling has occurred"
        fi

        if (( ($hex & 0x40000)== 0x40000 ))
                then echo "Soft temperature limit has occurred"
        fi

        if (( ($hex == 0x00) ))
                then echo "Power looks good since last re-boot!"
        fi
fi

if [ $roption == $"ALL" ]; then
        echo "ARM cores:"
        vcgencmd measure_clock arm
        echo "VC4 scaler cores:"
        vcgencmd measure_clock core
        echo "H264 block:"
        vcgencmd measure_clock H264
        echo "Image Signal Processor:"
        vcgencmd measure_clock isp
        echo "3D block:"
        vcgencmd measure_clock v3d
        echo "UART:"
        vcgencmd measure_clock uart
        echo "PWM block (analogue audio output):"
        vcgencmd measure_clock pwm
        echo "SD card interface:"
        vcgencmd measure_clock emmc
        echo "Pixel valve:"
        vcgencmd measure_clock pixel
        echo "Analogue video encoder:"
        vcgencmd measure_clock vec
        echo "HDMI:"
        vcgencmd measure_clock hdmi
        echo "Display Peripheral Interface:"
        vcgencmd measure_clock dpi
        echo "Pixel value:"
        vcgencmd measure_clock pixel
        echo "Analogue video encoder:"
        vcgencmd measure_clock vec
        echo "HDMI:"
        vcgencmd measure_clock hdmi
        echo "Display Peripheral Interface:"
        vcgencmd measure_clock dpi
        echo "VC4 core voltage:"
        vcgencmd measure_volts core
        echo "SDRAM C:"
        vcgencmd measure_volts sdram_c
        echo "SDRAM I:"
        vcgencmd measure_volts sdram_i
        echo "SDRAM P:"
        vcgencmd measure_volts sdram_p
        echo "Temperature of the SoC on-board:"
        vcgencmd measure_temp
fi
