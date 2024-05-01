#!/bin/bash

ARGS=$(getopt -n "$0" -o p:s:i:P: --long part:,status:,ip-address:,port: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
status=""
ip=""
port=""

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

        --ip-address | -i)
            if [[ -n "$2" && "$2" != -* ]]; then
                ip="$2"
                shift 2
            else
                exit 161
            fi
            ;;


        --port | -P)
            if [[ -n "$2" && "$2" != -* ]]; then
                port="$2"
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

    access)

        path="/etc/.uswg_configs/ssh/ssh_sglobal.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 155
        fi
        
        check=""
        check=`echo "$port" | grep "^[0-9]\{1,5\}$"`
        if [ -z "$check" ]; then
            exit 155
        fi

        check=""
        check=`echo $ip | grep "^.\+:[[:space:]][0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"`
        if [ -z "$check" ]; then
            exit 155
        fi

        ip=`echo $ip | cut -d ' ' -f 2`

        sudo -S truncate -s 0 $path

        sudo -S echo "Port ${port}" | sudo -S tee -a $path
        sudo -S echo "ListenAddress ${ip}" | sudo -S tee -a $path
        

        ;;
    
    *)
        exit 155
        ;;

esac