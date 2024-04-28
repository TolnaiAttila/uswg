#!/bin/bash

ARGS=$(getopt -n "$0" -o p:i:g:d:n:s:h: --long part:,ip-address:,gateway:,dns-server:,network-adapter:,status:,hostname: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
ip=""
gateway=""
dns=""
adapter=""
status=""
hname=""

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

        --ip-address | -i)
            if [[ -n "$2" && "$2" != -* ]]; then
                ip="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        --gateway | -g)
            if [[ -n "$2" && "$2" != -* ]]; then
                gateway="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --dns-server | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                dns="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --network-adapter | -n)
            if [[ -n "$2" && "$2" != -* ]]; then
                adapter="$2"
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

        --hostname | -h)
            if [[ -n "$2" && "$2" != -* ]]; then
                hname="$2"
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

    adapter-configuration)
        if [ "$ip" == "empty" ] && [ "$gateway" == "empty" ] && [ "$dns" == "empty" ]; then
            if [ ! `ip address | grep "^[0-9]\+:[[:space:]].*$" | cut -d' ' -f2 | tr -d ':' | grep -v "^lo$" | grep "^${adapter}$"` ]; then
                exit 155
            fi
            
            if [ "$status" == "up" ]; then
                sudo -S ip link set $adapter up
            else
                if [ "$status" == "down" ]; then
                    sudo -S ip link set $adapter down
                else
                    exit 155
                fi
            fi

            filename="adapter_${adapter}.conf"
            path="/etc/.uswg_configs/adapter/"
            ./bash/shared/exist_file.sh $path$filename
            if [ $? -eq 0 ]; then
                sudo -S rm $path$filename
            fi

            exit 0
        else
            if [ ! `echo "$ip" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{2\}$"` ]; then
                exit 155
            fi
        
            if [ ! `echo "$gateway" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"` ]; then
                exit 155
            fi

            if [ ! `echo "$dns" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"` ]; then
                exit 155
            fi
        
            if [ ! `ip address | grep "^[0-9]\+:[[:space:]].*$" | cut -d' ' -f2 | tr -d ':' | grep -v "^lo$" | grep "^${adapter}$"` ]; then
                exit 155
            fi
        fi
        path="/etc/.uswg_configs/adapter/adapter_${adapter}.conf"

        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            sudo -S touch $path
        fi

        sudo -S truncate -s 0 $path

        sudo -S echo "adapter:${adapter}" | sudo -S tee -a $path > /dev/null
        sudo -S echo "addresses:${ip}" | sudo -S tee -a $path > /dev/null
        sudo -S echo "gateway4:${gateway}" | sudo -S tee -a $path > /dev/null
        sudo -S echo "nameservers:${dns}" | sudo -S tee -a $path > /dev/null


        if [ "$status" == "up" ]; then
                sudo -S ip link set $adapter up
            else
                if [ "$status" == "down" ]; then
                    sudo -S ip link set $adapter down
                else
                    exit 155
                fi
            fi

        ;;


    hostname)
        kk=""
        kk=`echo -n "$hname" | grep "^[a-zA-Z0-9]\{1,15\}$"`
        if [ -z "$hname" ] || [ -z "$kk" ]; then
            exit 155
        fi

        sudo -S hostnamectl set-hostname $hname

        ;;

    *)
        exit 155
        ;;

esac