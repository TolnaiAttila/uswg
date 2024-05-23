#!/bin/bash

ARGS=$(getopt -n "$0" -o s:p:h:n: --long subnet-name:,part:,host-name:,network-adapter: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"


part=""
subnetname=""
hostname=""
networkadapter=""

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

    --subnet-name | -s)
        if [[ -n "$2" && "$2" != -* ]]; then
            subnetname="$2"
            shift 2
        else
            exit 161
        fi
        ;;

    --host-name | -h)
        if [[ -n "$2" && "$2" != -* ]]; then
            hostname="$2"
            shift 2
        else
            exit 161
        fi
        ;;

    --network-adapter | -n)
        if [[ -n "$2" && "$2" != -* ]]; then
            networkadapter="$2"
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
    static-host)
        path="/etc/.uswg_configs/dhcp/dhcp_config/dhcp_static_${hostname}.conf"

        ./bash/shared/exist_file.sh $path

        if [ $? -eq 0 ]; then
            sudo -S rm $path
        else
            exit 151
        fi
        ;;

    subnet)
        path="/etc/.uswg_configs/dhcp/dhcp_config/dhcp_subnet_${subnetname}.conf"

        ./bash/shared/exist_file.sh $path

        if [ $? -eq 0 ]; then
            sudo -S rm $path
        else
            exit 151
        fi
        ;;

    network-adapter)
        path="/etc/default/isc-dhcp-server"
        
        line=`cat /etc/default/isc-dhcp-server | grep "^INTERFACESv4=\".*$networkadapter.*\"$"`

        if [ ! -z "$line" ]; then
            sudo sed -i "/INTERFACESv4=/s/$networkadapter //" "$path"
            sudo sed -i "/INTERFACESv4=/s/ $networkadapter//" "$path"
            sudo sed -i "/INTERFACESv4=/s/$networkadapter//" "$path"
                    
        else
            exit 155
        fi

        ;;

    *)
        exit 155
        ;;
esac