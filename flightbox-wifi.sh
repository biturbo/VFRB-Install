#!/bin/bash


# Preliminaries. Kill off old services.
/usr/bin/killall -9 hostapd
/usr/sbin/service isc-dhcp-server stop

DAEMON_CONF=/etc/hostapd/hostapd.conf
DAEMON_SBIN=/usr/sbin/hostapd

${DAEMON_SBIN} -B ${DAEMON_CONF}

sleep 5
/usr/sbin/service isc-dhcp-server start
