#!/bin/bash

path="/etc/.uswg_nfs_config/"
pathconfig="/etc/exports"

sudo truncate -s 0 $pathconfig

rule=""

for i in `ls $path | grep "^nfs_.*_share\.conf$"`
    do
        fullpath="$path$i"
        for x in `cat $fullpath`
            do
                permcheck=`echo $x | grep "^[0-7][0-7][0-7]$"`
                if [ -z "$permcheck" ]; then
                    rule="$rule $x"
                fi
            done
        sudo -S echo "$rule" | sudo -S tee -a $pathconfig > /dev/null
        rule=""
    done
