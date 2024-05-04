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

    status)

        status=`sudo -S ufw status | grep "^Status:[[:space:]].\+$" | cut -d ' ' -f 2`
        if [ "$status" == "inactive" ]; then
            exit 158
        else
            if [ "$status" == "active" ]; then
                exit 157
            fi
        fi
        ;;
    
    incoming-default)
        policy=`sudo -S ufw status verbose | grep "^Default:[[:space:]].*incoming.*$" | cut -d ',' -f 1 | cut -d ' ' -f 2`
        echo -n "$policy"
        ;;
    outgoing-default)
        policy=`sudo -S ufw status verbose | grep "^Default:[[:space:]].*outgoing.*$" | cut -d ',' -f 2 | cut -d ' ' -f 2`
        echo -n "$policy"
        ;;

    *)
        exit 155
        ;;
esac