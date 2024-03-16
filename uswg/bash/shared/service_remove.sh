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

        sudo -S rm -d -r /etc/bind/.uswg_dns_config
        sudo -S rm -d -r /etc/bind/.old_uswg_dns_config
        ./bash/shared/status.sh $service
        if [ $? -eq 9 ]; then
            sudo systemctl reset-failed $service
        fi

        exit 0
        ;;

    nfs-kernel-server)
        sudo -S systemctl stop $service
        sudo -S apt purge $service -y
        
        servicestatusname="nfs-server"
        ./bash/shared/status.sh $servicestatusname
        if [ $? -eq 9 ]; then
            sudo systemctl reset-failed $service
        fi
        ;;
    
    samba)
        ;;

    *)
        exit 5
        ;;
esac