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

    message)
        path="/etc/ftp_message"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            echo "empty"
        else
            head -n 1 $path
        fi

        ;;

    global)
        path="/etc/.uswg_configs/ftp/ftp_sglobal_config.conf" 
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi

        outlisten=`cat $path | grep "^listen=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outlistenv6=`cat $path | grep "^listen_ipv6=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outlocalen=`cat $path | grep "^local_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outdirmessen=`cat $path | grep "^dirmessage_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outwriteen=`cat $path | grep "^write_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outdotfile=`cat $path | grep "^force_dot_files=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outhideids=`cat $path | grep "^hide_ids=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outmaxpip=`cat $path | grep "^max_per_ip=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outmaxclient=`cat $path | grep "^max_clients=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        
        outanoen=`cat $path | grep "^anonymous_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outanoupen=`cat $path | grep "^anon_upload_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outanomkdiren=`cat $path | grep "^anon_mkdir_write_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outanootherwriteen=`cat $path | grep "^anon_other_write_enable=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        outanoreadonlyworld=`cat $path | grep "^anon_world_readable_only=.\+$" | cut -d '=' -f 2 | tr [:upper:] [:lower:]`
        

        if [ -z "$outlisten" ]; then
            echo "empty"
        else
            echo $outlisten
        fi

        if [ -z "$outlistenv6" ]; then
            echo "empty"
        else
            echo $outlistenv6
        fi

        if [ -z "$outlocalen" ]; then
            echo "empty"
        else
            echo $outlocalen
        fi

        if [ -z "$outdirmessen" ]; then
            echo "empty"
        else
            echo $outdirmessen
        fi

        if [ -z "$outwriteen" ]; then
            echo "empty"
        else
            echo $outwriteen
        fi

        if [ -z "$outdotfile" ]; then
            echo "empty"
        else
            echo $outdotfile
        fi

        if [ -z "$outhideids" ]; then
            echo "empty"
        else
            echo $outhideids
        fi

        if [ -z "$outmaxpip" ]; then
            echo "empty"
        else
            echo $outmaxpip
        fi

        if [ -z "$outmaxclient" ]; then
            echo "empty"
        else
            echo $outmaxclient
        fi
        




        if [ -z "$outanoen" ]; then
            echo "empty"
        else
            echo $outanoen
        fi

        if [ -z "$outanoupen" ]; then
            echo "empty"
        else
            echo $outanoupen
        fi

        if [ -z "$outanomkdiren" ]; then
            echo "empty"
        else
            echo $outanomkdiren
        fi

        if [ -z "$outanootherwriteen" ]; then
            echo "empty"
        else
            echo $outanootherwriteen
        fi

        if [ -z "$outanoreadonlyworld" ]; then
            echo "empty"
        else
            echo $outanoreadonlyworld
        fi


        ;;

    *)
        exit 155
        ;;

esac