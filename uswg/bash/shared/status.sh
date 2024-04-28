#!/bin/bash

service=$1

installed=`systemctl list-units --type=service --all | grep $service.service`
installed2=`systemctl list-unit-files --type=service --state=disabled --no-pager | grep $service.service`
if [ -z "$installed" ] && [ -z "$installed2" ]; then
    exit 156
else
    status=`systemctl is-active $service`
    if [ $status == "active" ]; then
        exit 157
    fi
    
    if [ $status == "failed" ]; then
        exit 159
    fi

    if [ $status == "inactive" ]; then
        exit 158
    fi

    exit 160
fi

