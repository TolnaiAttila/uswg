#!/bin/bash

ARGS=$(getopt -n "$0" -o p:w:n:m:u:s:b: --long part:,workgroup:,netbios-name:,map-to-guest:,usershare-allow-guests:,security:,public: -- "$@")

if [ $? -ne 0 ]; then
    echo "eleje"
    exit 161
fi

eval set -- "$ARGS"

part=""
workgroup=""
bname=""
mtg=""
uag=""
security=""
public=""

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
        
        --workgroup | -w)
            if [[ -n "$2" && "$2" != -* ]]; then
                workgroup="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --netbios-name | -n)
            if [[ -n "$2" && "$2" != -* ]]; then
                bname="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --map-to-guest | -m)
            if [[ -n "$2" && "$2" != -* ]]; then
                mtg="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --usershare-allow-guests | -u)
            if [[ -n "$2" && "$2" != -* ]]; then
                uag="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --security | -s)
            if [[ -n "$2" && "$2" != -* ]]; then
                security="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --public | -b)
            if [[ -n "$2" && "$2" != -* ]]; then
                public="$2"
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
        if [ -z "$workgroup" ] || [ -z "$bname" ]; then
            exit 155
        fi
        outworkgroup="workgroup = $workgroup"
        outbname="netbios name = $bname"
        outmtg=""
        outuag=""
        outsecurity=""
        outpublic=""

        case "$mtg" in
            bad_user)
                outmtg="map to guest = bad user"
                ;;
            bad_passwd)
                outmtg="map to guest = bad password"
                ;;
            never)
                outmtg="map to guest = never"
                ;;
            not_configured)
                outmtg="#map to guest = not configured"
                ;;
            *)
                exit 155
                ;;
        esac
        
        case "$uag" in
            yes)
                outuag="usershare allow guests = yes"
                ;;
            no)
                outuag="usershare allow guests = no"
                ;;
            not_configured)
                outuag="#usershare allow guests = not configured"
                ;;
            *)
                exit 155
                ;;
        esac
        
        case "$security" in
            user)
                outsecurity="security = user"
                ;;
            share)
                outsecurity="security = share"
                ;;
            not_configured)
                outsecurity="#security = not configured"
                ;;
            *)
                exit 155
                ;;
        esac

        case "$public" in
            yes)
                outpublic="public = yes"
                ;;
            no)
                outpublic="public = no"
                ;;
            not_configured)
                outpublic="#public = not configured"
                ;;
            *)
                exit 155
                ;;
        esac
        path="/etc/.uswg_configs/samba/samba_fglobal_config.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -eq 0 ]; then
            sudo -S truncate -s 0 $path
        else
            sudo -S touch $path
        fi
        
        sudo -S echo '[global]' | sudo -S tee -a $path > /dev/null
        sudo -S echo $outworkgroup | sudo -S tee -a $path > /dev/null
        sudo -S echo $outbname | sudo -S tee -a $path > /dev/null
        sudo -S echo $outmtg | sudo -S tee -a $path > /dev/null
        sudo -S echo $outuag | sudo -S tee -a $path > /dev/null
        sudo -S echo $outsecurity | sudo -S tee -a $path > /dev/null
        sudo -S echo $outpublic | sudo -S tee -a $path > /dev/null
        ;;

    *)
        exit 155
        ;;

esac