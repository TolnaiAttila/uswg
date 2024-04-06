#!/bin/bash

ARGS=$(getopt -n "$0" -o p:i:d: --long part:,input:,directory-delete: -- "$@")

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
        
        --directory-delete | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                dirdel="$2"
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

    nobody-share)
        if [ -z "$input" ]; then
            exit 155
        fi
        
        check=""
        check=`echo $input | grep "^delete_samba_share_.\+_Button$"`

        if [ -z "$check" ]; then
            exit 155
        fi

        name=`echo $input | grep "^delete_samba_share_.\+_Button$" | cut -d'_' -f 4`
        path="/etc/.uswg_configs/samba/samba_nobody_${name}_share.conf"
        
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi

        if [ "$dirdel" == "no" ] || [ "$dirdel" == "yes" ]; then
            if [ "$dirdel" == "yes" ]; then
                sharepath=`cat $path | grep "^\(\(path\)\|\(#path\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                sudo -S rm -r -d $sharepath
            fi
        else
            exit 155
        fi
        sudo -S rm $path

        ;;

    *)
        exit 155
        ;;
esac