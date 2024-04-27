#!/bin/bash

if [ "$1" == "netplan" ]; then
    sudo -S netplan apply
else
    exit 155
fi