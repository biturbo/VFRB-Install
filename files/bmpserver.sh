#!/bin/sh
### BEGIN INIT INFO
# Provides:          BMP280
# Required-Start:    
# Required-Stop:     
# Should-Start:      
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: BMP280 Server daemon WIMDA 
# Description:       The BMP280 service daemon is able see temp and pressure
### END INIT INFO

sudo python /home/pi/opt/bmp280/server.py

