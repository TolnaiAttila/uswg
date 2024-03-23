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
        else

        sudo -S mkdir /etc/bind/.uswg_dns_config
        sudo -S mkdir /etc/bind/.old_uswg_dns_config

        fi

        exit 0
        ;;
    
    nfs-kernel-server)
        path="/etc/exports"
        sudo -S apt update
        sudo -S apt install nfs-kernel-server -y

        if [ $? -ne 0 ]; then
            exit 3
        fi
        sudo -S truncate -s 0 $path
        sudo -S mkdir /etc/.uswg_nfs_config
        if [ ! -d /srv/nfs ]; then
            sudo -S mkdir /srv/nfs
        fi


        exit 0
        ;;
    
    
    samba)
        sudo -S apt update
        sudo -S apt install samba -y
        
        if [ $? -ne 0 ]; then
            exit 3
        fi

        if [ ! -d /srv/samba ]; then
            sudo -S mkdir /srv/samba
        fi
        ;;


        
    *)
        exit 5
        ;;
esac