# Copyright (c) 2017 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

#### files created and/or modified
# /etc/default/isc-dhcp-server
# /etc/hostapd/hostapd.conf
# /etc/network/interfaces
# /usr/sbin/flightbox-wifi.sh


if [ $(whoami) != 'root' ]; then
    echo "${RED}This script must be executed as root, exiting...${WHITE}"
    exit
fi

rm -f /etc/rc*.d/*hostapd
rm -f /etc/network/if-pre-up.d/hostapd
rm -f /etc/network/if-post-down.d/hostapd
rm -f /etc/init.d/hostapd
rm -f /etc/default/hostapd

# what wifi interface, e.g. wlan0, wlan1..., uses the first one found
#wifi_interface=$(lshw -quiet -c network | sed -n -e '/Wireless interface/,+12 p' | sed -n -e '/logical name:/p' | cut -d: -f2 | sed -e 's/ //g')
wifi_interface=wlan0

##############################################################
## Setup IP4 forwarding
##############################################################

echo "${MAGENTA}IP forawarding $wifi_interface interface...${WHITE}"

if ! grep -q "net.ipv4.ip_forward=1" "/etc/sysctl.conf"; then
    echo "net.ipv4.ip_forward=1" >>/etc/sysctl.conf
fi

echo "${GREEN}...done${WHITE}"


##############################################################
## Setup DHCP server for IP address management
##############################################################
echo
echo "${YELLOW}**** Setup DHCP server for IP address management *****${WHITE}"

### set /etc/default/isc-dhcp-server
cp -n /etc/default/isc-dhcp-server{,.bak}
cat <<EOT > /etc/default/isc-dhcp-server
INTERFACES="$wifi_interface"
EOT

### set /etc/dhcp/dhcpd.conf
cp -n /etc/dhcp/dhcpd.conf{,.bak}
cat <<EOT > /etc/dhcp/dhcpd.conf
ddns-update-style none;
default-lease-time 86400; # 24 hours
max-lease-time 172800; # 48 hours
authoritative;
log-facility local7;
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.50;
    option broadcast-address 192.168.1.255;
    default-lease-time 12000;
    max-lease-time 12000;
    option domain-name "flightbox.local";
    option domain-name-servers 4.2.2.2;
}
EOT

echo "${GREEN}...done${WHITE}"

##############################################################
## Setup /etc/iptables.ipv4.nat
##############################################################
echo
echo "${YELLOW}**** Setup /etc/iptables.ipv4.nat *****${WHITE}"
cat <<EOT > /etc/iptables.ipv4.nat
# Generated by iptables-save v1.4.14 on Sat Oct 15 13:54:41 2016
*filter
:INPUT ACCEPT [28:2677]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [53:6989]
-A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i wlan0 -o eth0 -j ACCEPT
COMMIT
# Completed on Sat Oct 15 13:54:41 2016
# Generated by iptables-save v1.4.14 on Sat Oct 15 13:54:41 2016
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT
# Completed on Sat Oct 15 13:54:41 2016
EOT

chmod 755 /etc/iptables.ipv4.nat

echo "${GREEN}...done${WHITE}"

##############################################################
## Setup /etc/hostapd/hostapd.conf
##############################################################
echo
echo "${YELLOW}**** Setup /etc/hostapd/hostapd.conf *****${WHITE}"

cat <<EOT > /etc/hostapd/hostapd.conf
interface=$wifi_interface
ssid=FlightRadar
hw_mode=g
channel=5
wmm_enabled=1
ieee80211n=1
ignore_broadcast_ssid=0
EOT

echo "${GREEN}...done${WHITE}"


##############################################################
## Setup /etc/network/interfaces and /etc/dhcpd.conf
##############################################################
echo
echo "${YELLOW}**** Setup /etc/network/interfaces *****${WHITE}"

cp -n /etc/network/interfaces{,.bak}

cat <<EOT > /etc/network/interfaces
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet manual

#iface eth0 inet static
#  address 192.168.3.125
#  netmask 255.255.255.0
#  gateway 192.168.3.1  
   
allow-hotplug wlan0

iface wlan0 inet static
  address 192.168.1.1
  netmask 255.255.255.0
  post-up /usr/sbin/flightbox-wifi.sh
  post-up iptable-restore < /etc/iptables.ipv4.nat
EOT

if ! grep -q "interface eth0" "/etc/dhcpcd.conf"; then
    echo "interface eth0" >>/etc/dhcpcd.conf
fi
if ! grep -q "static ip_address=192.168.3.123/24" "/etc/dhcpcd.conf"; then
    echo "static ip_address=192.168.3.123/24" >>/etc/dhcpcd.conf
fi
if ! grep -q "static routers=192.168.3.1" "/etc/dhcpcd.conf"; then
    echo "static routers=192.168.3.1" >>/etc/dhcpcd.conf
fi
if ! grep -q "static domain_name_servers=8.8.8.8 4.2.2.1" "/etc/dhcpcd.conf"; then
    echo "static domain_name_servers=8.8.8.8 4.2.2.1" >>/etc/dhcpcd.conf
fi

echo "${GREEN}...done${WHITE}"


#################################################
## Setup /usr/sbin/flightbox-wifi.sh
#################################################
echo
echo "${YELLOW}**** Setup /usr/sbin/flightbox-wifi.sh *****${WHITE}"

# we use a slightly modified version to handle more hardware scenarios
chmod 755 ${SCRIPTDIR}/flightbox-wifi.sh
cp ${SCRIPTDIR}/flightbox-wifi.sh /usr/sbin/flightbox-wifi.sh

echo "${GREEN}...done${WHITE}"


#################################################
## Legacy wifiap cleanup
#################################################
echo
echo "${YELLOW}**** Legacy wifiap cleanup *****${WHITE}"

#### legacy file check
if [ -f "/etc/init.d/wifiap" ]; then
    service wifiap stop
    rm -f /etc/init.d/wifiap
    echo "${MAGENTA}legacy wifiap service stopped and file removed... *****${WHITE}"
fi

echo "${GREEN}...done${WHITE}"

