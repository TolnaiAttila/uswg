#!/bin/bash

service=$1

if [ -z "$service" ]; then
    exit 5
fi

case $service in
    isc-dhcp-server)
        sudo -S apt update
        sudo -S apt install isc-dhcp-server -y

        if [ $? -ne 0 ]; then
            exit 3
        else
            sudo -S mkdir /etc/dhcp/.uswg_dhcp_config
            sudo -S mkdir /etc/dhcp/.old_uswg_dhcp_config 
        fi
        exit 0
        ;;
    bind9)
        sudo -S apt update
        sudo -S apt install bind9 -y

        if [ $? -ne 0 ]; then
            exit 3
        fi
        exit 0
        ;;
    samba)
        ;;
    nfs)
        ;;
    *)
        exit 5
        ;;
esac