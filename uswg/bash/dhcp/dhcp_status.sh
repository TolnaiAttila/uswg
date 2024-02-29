#!/bin/bash

installed=`systemctl list-units --type=service --all | grep isc-dhcp-server.service`
if [ -z "$installed" ]; then
    exit 6
else
    status=`systemctl list-units --type=service --all | grep isc-dhcp-server.service | tr -s ' ' | cut -d' ' -f4`
    if [ $status == "active" ]; then
        exit 7
    fi
    
    if [ $status == "failed" ]; then
        exit 9
    fi

    if [ $status == "inactive" ]; then
        exit 8
    fi
fi

