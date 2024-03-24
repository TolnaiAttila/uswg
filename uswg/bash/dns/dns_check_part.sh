#!/bin/bash

ARGS=$(getopt -n "$0" -o p: --long part: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""


while true; do
    case "$1" in
        --part | -p)
            if [[ -n "$2" && "$2" != -* ]]; then
                part="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --)
            shift
            break
            ;;

        *)
            exit 161
            ;;
    esac
done

if [ -z "$part" ]; then
    exit 155
fi

case "$part" in
    listen-on)
        path="/etc/.uswg_configs/dns/dns_config/dns_listenon.conf"
        ips=`cat $path | grep "^.\+[[:space:]]port[[:space:]].\+;$" | cut -d' ' -f 1`
        ports=`cat $path | grep "^.\+[[:space:]]port[[:space:]].\+;$" | cut -d' ' -f 3 | tr -d ';'`
        
        portarray=()
        for i in $ports;
        do
            portarray+=("$i")
        done
        

        index=0

        for i in $ips;
        do
            echo "$i ${portarray[$index]}"
            index=`expr $index \+ 1`
        done
        ;;
    *)
        exit 155
        ;;
esac