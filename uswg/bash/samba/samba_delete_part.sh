#!/bin/bash

ARGS=$(getopt -n "$0" -o p:i:d:f: --long part:,input:,directory-delete:,force-delete: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
input=""
dirdel=""
forcedel=""

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

        --force-delete | -f)
            if [[ -n "$2" && "$2" != -* ]]; then
                forcedel="$2"
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

if [ -z "$input" ]; then
    exit 155
fi
        
check=""
check=`echo $input | grep "^delete_samba_\(\(share\)\|\(group\)\)_.\+_Button$"`
if [ ! -z "$check" ]; then
    name=`echo $input | cut -d'_' -f 4`
else
    name=$input
fi


case "$part" in

    nobody-share)
       
        path="/etc/.uswg_configs/samba/samba_nobody_${name}_share.conf"
        ;;


    single-user-share)
        
        path="/etc/.uswg_configs/samba/samba_user_${name}_share.conf"
        ;;

    group-share)

        path="/etc/.uswg_configs/samba/samba_group_${name}_share.conf"
        ;;


    delete-user-list)
        
        path="/etc/.uswg_configs/samba/samba_list_${name}.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        
        configpath="/etc/.uswg_configs/samba/"

        if [ "$forcedel" == "yes" ]; then
            sudo -S rm $path
        else
            for i in `ls $configpath | grep "^samba_group_.\+_share.conf$"`
                do
                    check=""
                    check=`cat $configpath$i | grep "^\(\(valid\)\|\(invalid\)\)[[:space:]]users[[:space:]]=[[:space:]]@${name}$"`
                    if [ ! -z "$check" ]; then
                        exit 166
                    fi
                done
            
            sudo -S rm $path
        fi

        exit 0
        ;;


    *)
        exit 155
        ;;
esac






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
