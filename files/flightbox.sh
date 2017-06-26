#!/bin/sh
### BEGIN INIT INFO
# Provides:          flightbox
# Required-Start:    
# Required-Stop:     
# Should-Start:      
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Flightbox (PCAS) daemon 
# Description:       The flightbox service daemon is able see planes
### END INIT INFO

cd /dev
sudo ln -sf /dev/ttyAMA0 /dev/gps0

sudo rm /home/pi/opt/flightbox/flightbox.log
sudo python3 /home/pi/opt/flightbox/flightbox_watchdog.py

