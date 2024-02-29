#!/bin/bash

service=$1

if [ -z "$service" ]; then
    exit 5
fi

case $service in
    isc-dhcp-server)
        sudo -S systemctl stop isc-dhcp-server
        sudo -S apt purge isc-dhcp-server -y
        sudo rm -d -r /etc/dhcp/.uswg_dhcp_config/
        sudo rm -d -r /etc/dhcp/.old_uswg_dhcp_config/

        
        ./bash/shared/status.sh $service

        if [ $? -eq 9 ]; then
            sudo systemctl reset-failed $service
        fi
        exit 0
        ;;
    bind9)
        
        sudo -S systemctl stop $service
        sudo -S apt purge $service -y

        ./bash/shared/status.sh $service

        if [ $? -eq 9 ]; then
            sudo systemctl reset-failed $service
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