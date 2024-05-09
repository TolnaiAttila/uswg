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

    status)
        if [ ! -d /etc/.uswg_configs/adapter ]; then
            exit 156
        fi
        ;;

    check-adapter)
        path="/etc/.uswg_configs/adapter/"
        kk=""
        kk=`echo $input | grep "^modify_adapter_.\+_Button$"`
        if [ -z "$input" ] || [ -z "$kk" ]; then
            exit 155
        fi

        input=`echo $input | cut -d '_' -f 3`
        
        kk=""
        kk=`ip address | grep "^[0-9]\+:[[:space:]].*$" | cut -d' ' -f2 | tr -d ':' | grep -v "^lo$" | grep "^${input}$"`
        if [ -z "$kk" ]; then
            exit 155
        fi

        filename="adapter_${input}.conf"

        pathconfig=$path$filename

        ./bash/shared/exist_file.sh $pathconfig
        if [ $? -eq 0 ]; then
            outadapter=$input
            outmac=`ip address show dev $input | grep "link/ether[[:space:]].*[[:space:]]brd[[:space:]].*" | tr -s ' ' | cut -d ' ' -f 3`
            outip=`cat $pathconfig | grep "^addresses:.\+$" | cut -d ':' -f 2`
            outdns=`cat $pathconfig | grep "^nameservers:.\+$" | cut -d ':' -f 2`
            outstatus="unknown"

            kk=""
            kk=`ip address show up $input`
            if [ ! -z "$kk" ]; then
                outstatus="up"
            else
                outstatus="down"
            fi

        else
            outadapter=$input
            outmac=`ip address show dev $input | grep "link/ether[[:space:]].*[[:space:]]brd[[:space:]].*" | tr -s ' ' | cut -d ' ' -f 3`
            outip="empty"
            outdns="empty"
            outstatus="unknown"

            kk=""
            kk=`ip address show up $input`
            if [ ! -z "$kk" ]; then
                outstatus="up"
            else
                outstatus="down"
            fi
        fi

        if [ -z "$outadapter" ]; then
            outadapter="empty"
        fi
        if [ -z "$outmac" ]; then
            outmac="empty"
        fi
        if [ -z "$outip" ]; then
            outip="empty"
        fi
        if [ -z "$outdns" ]; then
            outdns="empty"
        fi
        echo "$outadapter"
        echo "$outmac"
        echo "$outip"
        echo "$outdns"
        echo "$outstatus"

        ;;

    list-all-adapters)
        path="/etc/.uswg_configs/adapter/"
        for i in `ip address | grep "^[0-9]\+:[[:space:]].*$" | cut -d' ' -f2 | tr -d ':' | grep -v "^lo$"`
            do
                pathconfig="${path}adapter_${i}.conf"
                ./bash/shared/exist_file.sh $pathconfig
                if [ $? -eq 0 ]; then
                    outadapter=$i
                    outmac=`ip address show dev $i | grep "link/ether[[:space:]].*[[:space:]]brd[[:space:]].*" | tr -s ' ' | cut -d ' ' -f 3`
                    outip=`cat $pathconfig | grep "^addresses:.\+$" | cut -d ':' -f 2`
                    outdns=`cat $pathconfig | grep "^nameservers:.\+$" | cut -d ':' -f 2`
                    outstatus="unknown"

                    kk=""
                    kk=`ip address show up $i`
                    if [ ! -z "$kk" ]; then
                        outstatus="up"
                    else
                        outstatus="down"
                    fi

                else
                    outadapter=$i
                    outmac=`ip address show dev $i | grep "link/ether[[:space:]].*[[:space:]]brd[[:space:]].*" | tr -s ' ' | cut -d ' ' -f 3`
                    outip="empty"
                    outdns="empty"
                    outstatus="unknown"

                    kk=""
                    kk=`ip address show up $i`
                    if [ ! -z "$kk" ]; then
                        outstatus="up"
                    else
                        outstatus="down"
                    fi
                fi


                if [ -z "$outadapter" ]; then
                    outadapter="empty"
                fi
                if [ -z "$outmac" ]; then
                    outmac="empty"
                fi
                if [ -z "$outip" ]; then
                    outip="empty"
                fi
                if [ -z "$outdns" ]; then
                    outdns="empty"
                fi
                echo "$outadapter"
                echo "$outmac"
                echo "$outip"
                echo "$outdns"
                echo "$outstatus"
            done
            ;;
    check-gateway)
        path="/etc/.uswg_configs/adapter/default_gateway.conf"
        ./bash/shared/exist_file.sh $path

        if [ $? -ne 0 ]; then
            exit 151
        fi

        outgateway=`cat $path | grep "^gateway4:.\+$" | cut -d ':' -f 2`
        
        if [ -z "$outgateway" ]; then
            outgateway="empty"
        fi

        outadapter=`cat $path | grep "^adapter:.\+$" | cut -d ':' -f 2`
        
        if [ -z "$outadapter" ]; then
            outadapter="empty"
        fi

        echo "${outadapter}"
        echo "${outgateway}"

        ;;
    hostname)
        hostname=`hostname`
        echo "$hostname"

        ;;

    *)
        exit 155
        ;;
esac