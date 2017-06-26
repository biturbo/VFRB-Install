# Copyright (c) 2017 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

echo "${MAGENTA}"
echo "************************************"
echo "****** Raspberry Pi setup... *******"
echo "************************************"
echo "${WHITE}"


##############################################################
##  Boot config settings
##############################################################
echo
echo "${YELLOW}**** Boot config settings... *****${WHITE}"

if ! grep -q "dtparam=audio=on" "/boot/config.txt"; then
    echo "dtparam=audio=on" >>/boot/config.txt
fi

if ! grep -q "max_usb_current=1" "/boot/config.txt"; then
    echo "max_usb_current=1" >>/boot/config.txt
fi

if ! grep -q "dtparam=i2c1=on" "/boot/config.txt"; then
    echo "dtparam=i2c1=on" >>/boot/config.txt
fi

if ! grep -q "dtparam=i2c1_baudrate=400000" "/boot/config.txt"; then
    echo "dtparam=i2c1_baudrate=400000" >>/boot/config.txt
fi

if ! grep -q "dtparam=i2c_arm_baudrate=400000" "/boot/config.txt"; then
    echo "dtparam=i2c_arm_baudrate=400000" >>/boot/config.txt
fi

if ! grep -q "dtoverlay=pi3-disable-bt" "/boot/config.txt"; then
    echo "dtoverlay=pi3-disable-bt" >>/boot/config.txt
fi

if ! grep -q "enable_uart=1" "/boot/config.txt"; then
    echo "enable_uart=1" >>/boot/config.txt
fi

if ! grep -q "dtparam=act_led_trigger=none" "/boot/config.txt"; then
    echo "dtparam=act_led_trigger=none" >>/boot/config.txt
fi

if ! grep -q "dtparam=act_led_activelow=on" "/boot/config.txt"; then
    echo "dtparam=act_led_activelow=on" >>/boot/config.txt
fi

if ! grep -q "arm_freq=900" "/boot/config.txt"; then
    echo "arm_freq=900" >>/boot/config.txt
fi

if ! grep -q "sdram_freq=450" "/boot/config.txt"; then
    echo "sdram_freq=450" >>/boot/config.txt
fi

if ! grep -q "core_freq=450" "/boot/config.txt"; then
    echo "core_freq=450" >>/boot/config.txt
fi

echo "${GREEN}...done${WHITE}"


##############################################################
##  Disable serial console
##############################################################
echo
echo "${YELLOW}**** Disable serial console... *****${WHITE}"

sed -i /boot/cmdline.txt -e "s/console=ttyAMA0,[0-9]\+ //"

echo "${GREEN}...done${WHITE}"

##############################################################
##  change Hostname and Hosts
##############################################################
echo
echo "${YELLOW}**** Change Hostname and Hosts... *****${WHITE}"

cp -n /etc/hostname{,.bak}
cat <<EOT > /etc/hostname
flightradar

EOT

cp -n /etc/hosts{,.bak}
cat <<EOT > /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       flightradar
EOT

echo "${GREEN}...done${WHITE}"

##############################################################
##  I2C setup
##############################################################
echo
echo "${YELLOW}**** I2C setup... *****${WHITE}"

if ! grep -q "i2c-bcm2708" "/etc/modules"; then
    echo "i2c-bcm2708" >>/etc/modules
fi

if ! grep -q "i2c-dev" "/etc/modules"; then
    echo "i2c-dev" >>/etc/modules
fi

echo "${GREEN}...done${WHITE}"


##############################################################
##  Sysctl tweaks
##############################################################
# echo
# echo "${YELLOW}**** Sysctl tweaks... *****${WHITE}"

# if grep -q "net.core.rmem_max" "/etc/sysctl.conf"; then
    # line=$(grep -n 'net.core.rmem_max' /etc/sysctl.conf | awk -F':' '{print $1}')d
    # sed -i $line /etc/sysctl.conf
# fi

# if grep -q "net.core.rmem_default" "/etc/sysctl.conf"; then
    # line=$(grep -n 'net.core.rmem_default' /etc/sysctl.conf | awk -F':' '{print $1}')d
    # sed -i $line /etc/sysctl.conf
# fi

# if grep -q "net.core.wmem_max" "/etc/sysctl.conf"; then
    # line=$(grep -n 'net.core.wmem_max' /etc/sysctl.conf | awk -F':' '{print $1}')d
    # sed -i $line /etc/sysctl.conf
# fi

# if grep -q "net.core.wmem_default" "/etc/sysctl.conf"; then
    # line=$(grep -n 'net.core.wmem_default' /etc/sysctl.conf | awk -F':' '{print $1}')d
    # sed -i $line /etc/sysctl.conf
# fi

# echo "net.core.rmem_max = 167772160" >>/etc/sysctl.conf
# echo "net.core.rmem_default = 167772160" >>/etc/sysctl.conf
# echo "net.core.wmem_max = 167772160" >>/etc/sysctl.conf
# echo "net.core.wmem_default = 167772160" >>/etc/sysctl.conf

# echo "${GREEN}...done${WHITE}"

