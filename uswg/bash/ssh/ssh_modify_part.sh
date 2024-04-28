#!/bin/bash

ARGS=$(getopt -n "$0" -o p:s: --long part:,status: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
status=""

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
        
        --status | -s)
            if [[ -n "$2" && "$2" != -* ]]; then
                status="$2"
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

    startup)
        case "$status" in
            yes)
                sudo -S systemctl enable --now ssh
                ;;
            no)
                sudo -S systemctl disable --now ssh
                ;;
            *)
                exit 155
                ;;
        esac
        ;;

    access-ip)
        ;;
    access-port)
        ;;
    *)
        exit 155
        ;;

esac