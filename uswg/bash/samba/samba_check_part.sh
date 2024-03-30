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

            workgroup=`cat $path | grep "^\(\(workgroup\)\|\(#workgroup\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            bname=`cat $path | grep "^\(\(netbios\)\|\(#netbios\)\)[[:space:]]name[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            mtg=`cat $path | grep "^\(\(map\)\|\(#map\)\)[[:space:]]to[[:space:]]guest[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            uag=`cat $path | grep "^\(\(usershare\)\|\(#usershare\)\)[[:space:]]allow[[:space:]]guests[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            security=`cat $path | grep "^\(\(security\)\|\(#security\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            public=`cat $path | grep "^\(\(public\)\|\(#public\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`

            if [ -z "$workgroup" ]; then
                echo "empty"
            else
                echo $workgroup
            fi

            if [ -z "$bname" ]; then
                echo "empty"
            else
                echo $bname
            fi

            if [ -z "$mtg" ]; then
                echo "empty"
            else
                echo $mtg
            fi

            if [ -z "$uag" ]; then
                echo "empty"
            else
                echo $uag
            fi

            if [ -z "$security" ]; then
                echo "empty"
            else
                echo $security
            fi

            if [ -z "$public" ]; then
                echo "empty"
            else
                echo $public
            fi

        else
            exit 151
        fi
        ;;
        
    *)
        exit 155
        ;;
esac