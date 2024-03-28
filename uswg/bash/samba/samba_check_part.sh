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
    global)
        path="/etc/.uswg_configs/samba/samba_fglobal_config.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -eq 0 ]; then
            cat $path | grep "^workgroup[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | tr -d ' '
            cat $path | grep "^netbios[[:space:]]name[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | tr -d ' '
            cat $path | grep "^map[[:space:]]to[[:space:]]guest[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'
            cat $path | grep "^usershare[[:space:]]allow[[:space:]]guests[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'
            cat $path | grep "^security[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'
            cat $path | grep "^public[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'
        else
            exit 151
        fi
        ;;
    
    *)
        exit 155
        ;;
esac