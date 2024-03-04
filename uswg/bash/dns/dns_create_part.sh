#!/bin/bash

ARGS=$(getopt -n "$0" -o p:a:b --long part:,port:,ip-address: -- "$@")

if [ $? -ne 0 ]; then
    exit 10
fi

eval set -- "$ARGS"

part=""
port=""
ip=""

while true; do
  case "$1" in
    --part | -p)
        if [[ -n "$2" && "$2" != -* ]]; then
            part="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --port | -a)
        if [[ -n "$2" && "$2" != -* ]]; then
            port="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --ip-address | -b)
        if [[ -n "$2" && "$2" != -* ]]; then
            ip="$2"
            shift 2
        else
            exit 10
        fi
        ;;


    --)
        shift
        break
        ;;

    *)
        exit 10
        ;;
    esac
done


if [ -z "$part" ]; then
    exit 5
fi

case "$part" in
    listen-on)
        if [ -z "$port" ] || [ -z "$ip" ]; then
            exit 5
        fi
        
        path="/etc/bind/.uswg_dns_config/dns_listenon.conf"

        ./bash/shared/exist_file.sh $path

        if [ $? -ne 0 ]; then
            sudo -S touch $path
            sudo -S echo "listen-on {" | sudo -S tee -a $path > /dev/null
            sudo -S echo "};" | sudo -S tee -a $path > /dev/null
        fi
        
        linenumber=`grep -n "^};$" $path | cut -d':' -f 1`
        if [[ -n "$linenumber" ]]; then
            sudo -S sed -i "${linenumber}d" $path
        else
            exit 11
        fi

        sudo -S echo "$ip port $port;" | sudo -S tee -a $path > /dev/null
        sudo -S echo "};" | sudo -S tee -a $path > /dev/null

    ;;
    forwarders)
    ;;
    acl)
    ;;
    allow-query)
    ;;

    *)
        exit 5
        ;;
esac