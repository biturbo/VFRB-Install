# Copyright (c) 2017 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

echo "${MAGENTA}"
echo "************************************"
echo "**** GPSD install and setup... ******"
echo "************************************"
echo "${WHITE}"

##############################################################
##  GPSD install and settings
##############################################################
echo
echo "${YELLOW}**** GPSD install and config... *****${WHITE}"

#cd /home/pi

#git clone https://git.savannah.nongnu.org/git/gpsd.git
#cd gpsd

ln -s /lib/systemd/system/gpsd /etc/systemd/system/multi-user.target.wants/
ln -s /lib/systemd/system/gpsd.service /etc/systemd/system/multi-user.target.wants/
ls -la /etc/systemd/system/multi-user.target.wants/gpsd


#rm -rf gpsd-3.16.tar.gz
#wget http://download.savannah.gnu.org/releases/gpsd/gpsd-3.16.tar.gz
#tar xvf gpsd-3.16.tar.gz
#cd gpsd-3.16
#scons && scons check && scons udev-install


echo "${GREEN}...done${WHITE}"


