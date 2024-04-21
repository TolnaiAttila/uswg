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

    status)
        if [ ! -d /etc/.uswg_configs/adapter ]; then
            exit 156
        fi
        ;;

    *)
        exit 155
        ;;
esac