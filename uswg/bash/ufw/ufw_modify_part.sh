#!/bin/bash

ARGS=$(getopt -n "$0" -o p:a: --long part:,action: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
action=""

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
        
        --action | -a)
            if [[ -n "$2" && "$2" != -* ]]; then
                action="$2"
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

    incoming-default)
        if [ "$action" == "allow" ]; then
            sudo -S ufw default allow incoming
        else
            if [ "$action" == "deny" ]; then
                sudo -S ufw default deny incoming
            else
                exit 155
            fi
        fi
        ;;

    outgoing-default)
        if [ "$action" == "allow" ]; then
            sudo -S ufw default allow outgoing
        else
            if [ "$action" == "deny" ]; then
                sudo -S ufw default deny outgoing
            else
                exit 155
            fi
        fi
        ;;
    *)
        exit 155
        ;;
esac