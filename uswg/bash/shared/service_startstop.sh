#!/bin/bash

action=$1
service=$2

#megfelelo nevre atirni a szolgaltatasokat

if [ $service == "isc-dhcp-server" ] || [ $service == "dns" ] || [ $service == "nfs" ] || [ $service == "samba" ]; then

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
            exit 5
            ;;
    esac

else
    exit 5
fi