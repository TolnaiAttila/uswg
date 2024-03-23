#!/bin/bash

path="/etc/.uswg_configs/dhcp/dhcp_config/"
dhpath="/etc/dhcp/dhcpd.conf"
adapterpath="/etc/default/isc-dhcp-server"

oldpath="/etc/.uswg_configs/dhcp/old_dhcp_config/"
olddhpath="/etc/.uswg_configs/dhcp/old_dhcp_config/dhcpd.conf"
oldadapterpath="/etc/.uswg_configs/dhcp/old_dhcp_config/isc-dhcp-server"

rmdhpath="/etc/.uswg_configs/dhcp/dhcp_config/dhcpd.conf"
rmadapterpath="/etc/.uswg_configs/dhcp/dhcp_config/isc-dhcp-server"

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

