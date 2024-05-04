#!/bin/bash

action=$1

case "$action" in
    start)
        sudo -S ufw enable
        ;;
    
    stop)
        sudo -S ufw disable
        ;;
    reload)
        sudo -S ufw reload
        ;;
    *)
        exit 155
        ;;
esac