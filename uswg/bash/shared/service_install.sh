#!/bin/bash

service=$1

if [ -z "$service" ]; then
    exit 155
fi

case $service in
    isc-dhcp-server)
        sudo -S apt update
        sudo -S apt install isc-dhcp-server -y

        if [ $? -ne 0 ]; then
            exit 153
        else
            sudo -S mkdir /etc/.uswg_configs/dhcp
            sudo -S mkdir /etc/.uswg_configs/dhcp/dhcp_config
            sudo -S mkdir /etc/.uswg_configs/dhcp/old_dhcp_config
        fi
        exit 0
        ;;

    bind9)
        sudo -S apt update
        sudo -S apt install bind9 -y

        if [ $? -ne 0 ]; then
            exit 153
        else

        sudo -S mkdir /etc/.uswg_configs/dns/dns_config
        sudo -S mkdir /etc/.uswg_configs/dns/old_dns_config

        fi

        exit 0
        ;;
    
    nfs-kernel-server)
        path="/etc/exports"
        sudo -S apt update
        sudo -S apt install nfs-kernel-server -y

        if [ $? -ne 0 ]; then
            exit 153
        fi
        sudo -S truncate -s 0 $path
        sudo -S mkdir /etc/.uswg_configs/nfs
        if [ ! -d /srv/nfs ]; then
            sudo -S mkdir /srv/nfs
        fi


        exit 0
        ;;
    
    
    samba)
        sudo -S apt update
        sudo -S apt install samba -y
        sudo -S apt install samba-common -y
        
        if [ $? -ne 0 ]; then
            exit 153
        fi
        path="/etc/samba/smb.conf"
        configpath="/etc/.uswg_configs/samba/samba_base_config.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        
        sudo -S mkdir /etc/.uswg_configs/samba
        sudo -S touch $configpath
        sudo -S cat /etc/samba/smb.conf | grep -v "^\(\(#\)\|\(;\)\|\($\)\)" | sudo -S tee -a $configpath > /dev/null
        
        sudo -S truncate -s 0 $path

        sudo -S cat $configpath | sudo -S tee -a $path > /dev/null

        if [ ! -d /srv/samba ]; then
            sudo -S mkdir /srv/samba
        fi
        ;;
        
    *)
        exit 155
        ;;
esac