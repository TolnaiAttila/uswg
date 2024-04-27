#!/bin/bash

ARGS=$(getopt -n "$0" -o p:i:d: --long part:,input:,directory-delete: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
input=""
dirdel=""

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

if [ -z "$part" ] || [ -z "$input" ]; then
    exit 155
fi

case "$part" in
    all)
        if [ -z "$dirdel" ]; then
            exit 155
        fi
        if [ "$dirdel" == "yes" ] || [ "$dirdel" == "no" ]; then
            check=`echo $input | grep "^delete_nfs_share_.\+_Button$"`
            if [ ! -z "$check" ]; then
                name=`echo $input | cut -d'_' -f 4`
                path="/etc/.uswg_configs/nfs/nfs_${name}_share.conf"

            else
                name=$input
                path="/etc/.uswg_configs/nfs/nfs_${name}_share.conf"
            fi

        
            ./bash/shared/exist_file.sh $path
            if [ $? -ne 0 ]; then
                exit 151
            fi

            dir=`cat $path | grep "^/srv/nfs/.\+$"`
            sudo -S rm $path

            if [ "$dirdel" == "yes" ]; then
                sudo -S rm -r -d $dir
            fi
        else
            exit 155
        fi
        ;;
    part)
        
        input=`echo $input | tr -d \"`
        
        check=`echo $input | grep "^delete_nfs_share_.\+_.\+_(.\+,.\+,.\+,.\+)_Button$"`
        if [ -z "$check" ]; then
            exit 155
        fi
        name=`echo $input | cut -d'_' -f 4`
        access=`echo $input | cut -d'_' -f 5`
        rule=`echo $input | cut -d'(' -f 2 | cut -d')' -f 1`
        
        path="/etc/.uswg_configs/nfs/nfs_${name}_share.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi

        linenumber=`sudo -S grep -n "^$access($rule)$" $path| cut -d':' -f1`
        
        sudo -S sed -i "${linenumber}d" $path

        ;;
    *)
        exit 155
        ;;
esac