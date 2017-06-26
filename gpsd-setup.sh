# Copyright (c) 2017 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

echo "${MAGENTA}"
echo "************************************"
echo "**** ognd install and setup... ******"
echo "************************************"
echo "${WHITE}"

##############################################################
##  GPSD install and settings
##############################################################
echo
echo "${YELLOW}**** GPSD install and config... *****${WHITE}"

cd /home/pi/opt
rm -rf gpsd-3.16.tar.gz

wget http://download.savannah.gnu.org/releases/gpsd/gpsd-3.16.tar.gz
tar xvf gpsd-3.16.tar.gz
cd gpsd-3.16
scons && scons check && scons udev-install


echo "${GREEN}...done${WHITE}"


