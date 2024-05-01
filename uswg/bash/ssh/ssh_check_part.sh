#!/bin/bash

ARGS=$(getopt -n "$0" -o p:i: --long part:,input: -- "$@")

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
        
        --input | -i)
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

    startup-status)
        status=`sudo -S systemctl is-enabled ssh`
        echo "$status"
        
        ;;

    list-ip-address)
        for i in `ip address show | grep ".*inet[[:space:]].*" | grep -v ".*noprefixroute.*" | grep -v ".*127.0.0.1.*" | tr -s ' ' | cut -d ' ' -f 8`
            do
                ip=`ip address show | grep ".*inet[[:space:]].*" | grep -v ".*noprefixroute.*" | grep -v ".*127.0.0.1.*" | grep ".*${i}.*" | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1`
                echo "${i}: $ip"
            done
        ;;
    selected-port)
        path="/etc/.uswg_configs/ssh/ssh_sglobal.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 155
        fi

        port=`cat $path | grep "^Port[[:space:]].\+"`
        if [ -z "$port" ]; then
            exit 162
        fi

        cat $path | grep "^Port[[:space:]].\+" | cut -d ' ' -f 2
        
        ;;

    selected-ip-address)
        path="/etc/.uswg_configs/ssh/ssh_sglobal.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 155
        fi

        ip=`cat $path | grep "^ListenAddress[[:space:]].\+"`
        if [ -z "$ip" ]; then
            exit 162
        fi

        ip=`cat $path | grep "^ListenAddress[[:space:]].\+" | cut -d ' ' -f 2`
        if [ "$ip" == "0.0.0.0" ]; then
            adapter="any"
        else
            adapter=`ip address show | grep ".*inet[[:space:]].*" | grep -v ".*noprefixroute.*" | grep -v ".*127.0.0.1.*" | grep ".*${ip}/.*" | tr -s ' ' | cut -d ' ' -f 8`
        fi

        echo "${adapter}: ${ip}"


        ;;
    *)
        exit 155
        ;;

esac