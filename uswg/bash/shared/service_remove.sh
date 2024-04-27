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

    vsftpd)
        service="vsftpd"
        sudo -S systemctl stop $service
        sudo -S apt purge $service -y
        
        ./bash/shared/status.sh $service
        if [ $? -eq 159 ]; then
            sudo systemctl reset-failed $service
        fi
        sudo -S rm -d -r /etc/.uswg_configs/ftp
        ;;

    network-adapter)
        method=$2
        if [ -z "$method" ]; then
            exit 155
        fi
        case $method in
            disable)
                path="/etc/.uswg_configs/adapter/"
                if [ -d $path ]; then
                    sudo -S rm -d -r $path
                else
                    exit 167
                fi
                ;;
            restore)
                pathorig="/etc/.uswg_configs/adapter/original/"
                path="/etc/.uswg_configs/adapter/"
                pathnetplan="/etc/netplan/"
                pathnginx="/etc/.uswg_configs/adapter/original_nginx/"

                 if [ -d $pathorig ]; then
                    kk=""
                    kk=`ls -A $pathorig`
                    if [ -z "$kk" ]; then
                        exit 151
                    fi
                    sudo -S rm -r -d /etc/netplan/*
                    sudo -S cp -r /etc/.uswg_configs/adapter/original/* $pathnetplan
                else
                    exit 167
                fi
                
                if [ -d $pathnginx ]; then
                    kk=""
                    kk=`ls -A $pathnginx`
                    if [ -z "$kk" ]; then
                        exit 151
                    fi
                    
                    sudo -S truncate -s 0 /etc/nginx/sites-available/uswg.conf
                    sudo -S cat /etc/.uswg_configs/adapter/original_nginx/uswg.conf | sudo -S tee -a /etc/nginx/sites-available/uswg.conf > /dev/null
                else
                    exit 167
                fi

                if [ -d $path ]; then
                    sudo -S rm -d -r $path
                else
                    exit 167
                fi
                sudo -S netplan apply
                sudo -S nginx -s reload
                

                ;;
            failed-install-restore)
                pathorig="/etc/.uswg_configs/adapter/original/"
                path="/etc/.uswg_configs/adapter/"
                pathnetplan="/etc/netplan/"
                pathnginx="/etc/.uswg_configs/adapter/original_nginx/uswg.conf"


                if [ ! -d $path ]; then
                    exit 168
                fi

                kk=`ls -A $pathorig`
                if [ -z "$kk" ]; then
                    exit 168
                fi
                sudo -S rm -r -d /etc/netplan/*
                sudo -S cp -r /etc/.uswg_configs/adapter/original/* $pathnetplan

                
                ./bash/shared/exist_file.sh $pathnginx
                if [ $? -eq 0 ]; then
                    sudo -S truncate -s 0 /etc/nginx/sites-available/uswg.conf
                    sudo -S cat $pathnginx | sudo -S tee -a /etc/nginx/sites-available/uswg.conf > /dev/null
                fi

                sudo -S rm -d -r $path
                sudo -S netplan apply
                sudo -S systemctl restart systemd-networkd
                sudo -S nginx -s reload
                sudo -S systemctl restart uswg

                exit 168
                ;;
            *)
                exit 155
                ;;
        esac

        sudo -S netplan apply
        sudo -S systemctl restart systemd-networkd
        ;;

    *)
        exit 155
        ;;
esac