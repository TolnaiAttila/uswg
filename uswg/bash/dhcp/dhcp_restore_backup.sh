#!/bin/bash

path="/etc/dhcp/.uswg_dhcp_config/"
dhpath="/etc/dhcp/dhcpd.conf"
adapterpath="/etc/default/isc-dhcp-server"

oldpath="/etc/dhcp/.old_uswg_dhcp_config/"
olddhpath="/etc/dhcp/.old_uswg_dhcp_config/dhcpd.conf"
oldadapterpath="/etc/dhcp/.old_uswg_dhcp_config/isc-dhcp-server"

rmdhpath="/etc/dhcp/.uswg_dhcp_config/dhcpd.conf"
rmadapterpath="/etc/dhcp/.uswg_dhcp_config/isc-dhcp-server"

if [ -z `ls -A $path | tr -d ' ' | tr -d '\n'` ]; then
    sudo cp $oldpath* $path
    sudo truncate -s 0 $dhpath
    sudo truncate -s 0 $adapterpath
    cat $olddhpath | sudo tee -a $dhpath
    cat $oldadapterpath | sudo tee -a $adapterpath
    sudo rm $rmdhpath
    sudo rm $rmadapterpath
else
    sudo rm $path*
    sudo cp $oldpath* $path
    sudo truncate -s 0 $dhpath
    sudo truncate -s 0 $adapterpath
    cat $olddhpath | sudo tee -a $dhpath
    cat $oldadapterpath | sudo tee -a $adapterpath
    sudo rm $rmdhpath
    sudo rm $rmadapterpath
fi

