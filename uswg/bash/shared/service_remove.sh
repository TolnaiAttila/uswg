#!/bin/bash

service=$1

if [ -z "$service" ]; then
    exit 155
fi

case $service in
    isc-dhcp-server)
        sudo -S systemctl stop isc-dhcp-server
        sudo -S apt purge isc-dhcp-server -y
        sudo rm -d -r /etc/.uswg_configs/dhcp

        
        ./bash/shared/status.sh $service

        if [ $? -eq 159 ]; then
            sudo systemctl reset-failed $service
        fi
        exit 0
        ;;
    bind9)
        
        sudo -S systemctl stop $service
        sudo -S apt purge $service -y

        sudo -S rm -d -r /etc/.uswg_configs/dns
        ./bash/shared/status.sh $service
        if [ $? -eq 159 ]; then
            sudo systemctl reset-failed $service
        fi

        exit 0
        ;;

    nfs-kernel-server)
        sudo -S systemctl stop $service
        sudo -S apt purge $service -y

        sudo -S rm -d -r /etc/.uswg_configs/nfs

        servicestatusname="nfs-server"
        ./bash/shared/status.sh $servicestatusname
        if [ $? -eq 159 ]; then
            sudo systemctl reset-failed $service
        fi
        ;;
    
    samba)
        service="smbd"
        sudo -S systemctl stop $service
        service="samba"
        sudo -S apt purge $service -y
        sudo -S apt purge samba-common -y
        
        service="smbd"
        ./bash/shared/status.sh $service
        if [ $? -eq 159 ]; then
            sudo systemctl reset-failed $service
        fi
        sudo -S rm -d -r /etc/.uswg_configs/samba
        ;;

    *)
        exit 155
        ;;
esac