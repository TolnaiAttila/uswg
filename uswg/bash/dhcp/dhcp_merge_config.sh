#!/bin/bash

path="/etc/.uswg_configs/dhcp/dhcp_config/"
pathconfig="/etc/dhcp/dhcpd.conf"

sudo truncate -s 0 $pathconfig

for i in `ls /etc/.uswg_configs/dhcp/dhcp_config | grep "^dhcp_\(\(base\)\|\(subnet\)\).*\.conf$"`
    do
        fullpath="$path$i"
        cat $fullpath | sudo tee -a $pathconfig
    done

for i in `ls /etc/.uswg_configs/dhcp/dhcp_config | grep "^dhcp_\(static\).*\.conf$"`
    do
        fullpath="$path$i"
        cat $fullpath | sudo tee -a $pathconfig
    done

for i in `ls /etc/.uswg_configs/dhcp/dhcp_config | grep "^dhcp_\(custom\).*\.conf$"`
    do
        fullpath="$path$i"
        cat $fullpath | sudo tee -a $pathconfig
    done