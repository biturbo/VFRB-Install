# Copyright (c) 2017 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.


BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)


if [ $(whoami) != 'root' ]; then
    echo "${BOLD}${RED}This script must be executed as root, exiting...${WHITE}${NORMAL}"
    exit
fi


SCRIPTDIR="`pwd`"

RPI3BxREV=a02082
RPI3ByREV=a22082

REVISION="$(cat /proc/cpuinfo | grep Revision | cut -d ':' -f 2 | xargs)"

ARM6L=armv6l
ARM7L=armv7l
ARM64=aarch64

MACHINE="$(uname -m)"


echo "${MAGENTA}"
echo "**************************************"
echo "**** FlightBox Setup Starting... *****"
echo "**************************************"
echo "${WHITE}"

if which ntp >/dev/null; then
    ntp -q -g
fi


##############################################################
##  Stop exisiting services
##############################################################
echo
echo "${YELLOW}**** Stop exisiting services... *****${WHITE}"

if [ -f "/etc/init.d/hostapd" ]; then
    systemctl stop hostapd
	#service hostapd stop
    echo "${MAGENTA}hostapd service found and stopped...${WHITE}"
fi

if [ -f "/etc/init.d/isc-dhcp-server" ]; then
    systemctl stop isc-dhcp-server
	#service isc-dhcp-server stop
    echo "${MAGENTA}isc-dhcp service found and stopped...${WHITE}"
fi

echo "${GREEN}...done${WHITE}"


##############################################################
##  Dependencies RPI3
##############################################################
 echo
 echo "${YELLOW}**** Installing dependencies... *****${WHITE}"

 apt-get install -y rpi-update
 rpi-update
 apt-get remove -y libpam-chksshpwd
 apt-get autoremove -y

# apt-get update -y apt-mark hold plymouth
 apt-get dist-upgrade -y
 apt-get upgrade -y
 apt-get install -y git
# git config --global http.sslVerify false
 apt-get install -y iw lshw wget isc-dhcp-server tcpdump cmake automake pkg-config libjpeg-dev 
 apt-get install -y i2c-tools 
 apt-get install -y libusb-1.0-0.dev build-essential mercurial autoconf fftw3 fftw3-dev libtool libfftw3-dev 
 apt-get remove -y hostapd
 apt-get install -y hostapd
 apt-get install -y gpsd gpsd-clients procserv nano libconfig-dev libconfig9 
 apt-get install -y libgps-dev minicom telnet gedit
 apt-get install -y libboost-dev libboost-system-dev libboost-thread-dev libboost-regex-dev libboost-chrono-dev libboost-signals-dev
 apt-get autoremove -y
 
 systemctl stop gpsd.socket
 systemctl disable gpsd.socket
 systemctl disable hciuart
 
 chmod 755 rpi.sh
 chmod 755 flightbox-wifi.sh
 chmod 755 wifi-ap.sh
 chmod 755 ogn-setup.sh


# ##############################################################
# ##  Hardware check
# ##############################################################
echo
echo "${YELLOW}**** Hardware check... *****${WHITE}"

echo
echo "${MAGENTA}Raspberry Pi3 detected...${WHITE}"

    . ${SCRIPTDIR}/rpi.sh

echo "${GREEN}...done${WHITE}"

##############################################################
##  Hardware blacklisting
##############################################################
echo
echo "${YELLOW}**** Hardware blacklisting... *****${WHITE}"

if ! grep -q "blacklist dvb_usb_rtl28xxu" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist dvb_usb_rtl28xxu >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist e4000" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist e4000 >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist rtl2832" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist rtl2832 >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist dvb_usb_rtl2832u" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist dvb_usb_rtl2832u >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist dvb_usb_rtl2830u" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist dvb_usb_rtl2830u >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

##############################################################
##  OGN RTL-SDR tools build
##############################################################
echo
echo "${YELLOW}**** OGN RTL-SDR library build... *****${WHITE}"

mkdir /home/pi/opt

cd /home/pi/opt

rm -rf rtl-sdr
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr/
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_UDEV_RULES=ON
make
make install
ldconfig

echo "${GREEN}...done${WHITE}"


##############################################################
##  dump1090 build and installation
##############################################################
echo
echo "${YELLOW}**** dump1090 build and installation... *****${WHITE}"

cd /home/pi/opt

rm -rf dump1090
git clone https://github.com/AvSquirrel/dump1090.git

cd dump1090

make 
cp -f dump1090 /usr/bin

echo "${GREEN}...done${WHITE}"

##############################################################
##  VFR-B build and installation
##############################################################
echo
echo "${YELLOW}**** VFR-B build and installation... *****${WHITE}"

cd /home/pi/opt

rm -rf VirtualFlightRadar-Backend
git clone https://github.com/Jarthianur/VirtualFlightRadar-Backend.git

rm -rf vfrb.ini
cp ${SCRIPTDIR}/files/vfrb.ini /home/pi/opt/VirtualFlightRadar-Backend/vfrb.ini

cd VirtualFlightRadar-Backend
./install.sh
./install.sh service 

echo "${GREEN}...done${WHITE}"

##############################################################
## Copying dump1090.sh / gpsd files
##############################################################
echo
echo "${YELLOW}**** Copying the dump1090.sh and GPSD utility... *****${WHITE}"

chmod 755 ${SCRIPTDIR}/files/dump1090.sh
cp ${SCRIPTDIR}/files/dump1090.sh /etc/init.d/dump1090.sh
systemctl enable dump1090.sh

chmod 755 ${SCRIPTDIR}/files/gpsd
rm -rf /etc/default/gpsd
cp ${SCRIPTDIR}/files/gpsd /etc/default/gpsd
ln -s /lib/systemd/system/gpsd.service /etc/systemd/system/multi-user.target.wants/

echo "${GREEN}...done${WHITE}"


##############################################################
##  System tweaks
##############################################################
echo
echo "${YELLOW}**** System tweaks... *****${WHITE}"

##### disable serial console
if [ -f /boot/cmdline.txt ]; then
    sed -i /boot/cmdline.txt -e "s/console=serial0,[0-9]\+ //"
fi

#
##### Set the keyboard layout to US.
if [ -f /etc/default/keyboard ]; then
    sed -i /etc/default/keyboard -e "/^XKBLAYOUT/s/\".*\"/\"us\"/"
fi

#### allow starting services
if [ -f /usr/sbin/policy-rc.d ]; then
    rm /usr/sbin/policy-rc.d
fi

echo "${GREEN}...done${WHITE}"

##############################################################
##  WiFi Access Point setup
##############################################################
echo
echo "${YELLOW}**** WiFi Access Point setup... *****${WHITE}"

. ${SCRIPTDIR}/wifi-ap.sh

echo "${GREEN}...done${WHITE}"

##############################################################
##  OGN setup
##############################################################
echo
echo "${YELLOW}**** OGN setup... *****${WHITE}"

. ${SCRIPTDIR}/ogn-setup.sh

echo "${GREEN}...done${WHITE}"


##############################################################
## Copying motd file
##############################################################
echo
echo "${YELLOW}**** Copying motd file... *****${WHITE}"

cp ${SCRIPTDIR}/files/motd /etc/motd

echo "${GREEN}...done${WHITE}"

##############################################################
## Copying the hostapd_manager.sh utility
##############################################################
echo
echo "${YELLOW}**** Copying the hostapd_manager.sh utility... *****${WHITE}"

chmod 755 ${SCRIPTDIR}/files/hostapd_manager.sh
cp ${SCRIPTDIR}/files/hostapd_manager.sh /usr/bin/hostapd_manager.sh

echo "${GREEN}...done${WHITE}"


# ##############################################################
# ## Disable ntpd at autostart
# ##############################################################
echo
#echo "${YELLOW}**** Disable ntpd autostart... *****${WHITE}"

#systemctl disable ntp


echo "${GREEN}...done${WHITE}"

##############################################################
## Epilogue
##############################################################
echo
echo
echo "${MAGENTA}**** Setup complete, don't forget to reboot! *****${WHITE}"
echo

echo ${NORMAL}

