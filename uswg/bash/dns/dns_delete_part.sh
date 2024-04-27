#!/bin/bash

ARGS=$(getopt -n "$0" -o p:a: --long part:,input: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
input=""

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

    --input | -a)
        if [[ -n "$2" && "$2" != -* ]]; then
            input="$2"
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
        if [ -z "$input" ]; then
            exit 155
        fi
        path="/etc/.uswg_configs/dns/dns_config/dns_listenon.conf"
        ip=`echo $input | cut -d'_' -f 3`
        port=`echo $input | cut -d'_' -f 4`
        line="$ip port $port;"
        linenumber=`sudo -S grep -n "^$line$" $path | cut -d':' -f 1`
        
        if [[ -n "$linenumber" ]]; then
            sudo -S sed -i "${linenumber}d" $path
        else
            exit 162
        fi

        ;;
    *)
        exit 155
        ;;
esac