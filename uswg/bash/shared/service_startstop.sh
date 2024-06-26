#!/bin/bash

action=$1
service=$2


if [ "$service" == "isc-dhcp-server" ] || [ "$service" == "nfs-kernel-server" ] || [ "$service" == "smbd" ] || [ "$service" == "vsftpd" ] || [ "$service" == "systemd-networkd" ] || [ "$service" == "ssh" ] || [ "$service" == "ufw" ]; then

    case $action in
        stop)
            sudo -S systemctl stop $service
            ;;
        restart)
            sudo -S systemctl restart $service
            ;;
        None)
            exit 0
        ;;
        *)
            exit 155
            ;;
    esac

else
    exit 155
fi