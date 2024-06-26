#!/bin/bash

path="/etc/.uswg_configs/nfs/"
pathconfig="/etc/exports"

sudo -S truncate -s 0 $pathconfig

rule=""
counter="0"

for i in `ls $path | grep "^nfs_.\+_share\.conf$"`
    do
        counter="0"
        fullpath="$path$i"
        linenumber=`wc -l $fullpath | cut -d' ' -f 1`
        if [ $linenumber -gt 2 ]; then
            for x in `cat $fullpath`
                do
                    permcheck=`echo $x | grep "^[0-7][0-7][0-7]$"`
                    if [ -z "$permcheck" ]; then
                        if [ $counter -ne 0 ]; then
                            rule="$rule $x"
                        else
                            rule="$x"
                        fi
                    fi
                    counter=`expr $counter \+ 1`
                done
       
            sudo -S echo "$rule" | sudo -S tee -a $pathconfig > /dev/null
            rule=""
        fi
    done
