#!/bin/bash


path="/etc/.uswg_configs/adapter/adapter_global.conf"

./bash/shared/exist_file.sh $path
if [ $? -ne 0 ]; then
    exit 151
fi


path2="/etc/netplan/network_adapter.yaml"

sudo -S truncate -s 0 $path2

sudo -S cat $path | sudo -S tee -a $path2 > /dev/null


path3="/etc/.uswg_configs/adapter/"
for i in `ls $path3 | grep "^adapter_.\+\.conf$" | grep -v "^adapter_global.conf$"`
    do
        outadapter=`cat $path3$i | grep "^adapter:.\+$" | cut -d ':' -f 2`
        outip=`cat $path3$i | grep "^addresses:.\+$" | cut -d ':' -f 2`
        outgateway=`cat $path3$i | grep "^gateway4:.\+$" | cut -d ':' -f 2`
        outdns=`cat $path3$i | grep "^nameservers:.\+$" | cut -d ':' -f 2`
        
        if [ -z "$outadapter" ]; then
            outadapter="empty"
        fi
        if [ -z "$outip" ]; then
            outip="empty"
        fi
        if [ -z "$outgateway" ]; then
            outgateway="empty"
        fi
        if [ -z "$outdns" ]; then
            outdns="empty"
        fi


        sudo -S echo "  ${outadapter}:" | sudo -S tee -a $path2 > /dev/null
        sudo -S echo "   addresses: [${outip}]" | sudo -S tee -a $path2 > /dev/null
        sudo -S echo "   gateway4: ${outgateway}" | sudo -S tee -a $path2 > /dev/null
        sudo -S echo "   nameservers:" | sudo -S tee -a $path2 > /dev/null
        sudo -S echo "    addresses: [${outdns}]" | sudo -S tee -a $path2 > /dev/null
    done