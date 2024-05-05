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

        status=`sudo -S ufw status | grep "^Status:[[:space:]].\+$" | cut -d ' ' -f 2`
        if [ "$status" == "inactive" ]; then
            exit 158
        else
            if [ "$status" == "active" ]; then
                exit 157
            fi
        fi
        ;;
    
    incoming-default)
        policy=`sudo -S ufw status verbose | grep "^Default:[[:space:]].*incoming.*$" | cut -d ',' -f 1 | cut -d ' ' -f 2`
        echo -n "$policy"
        ;;
    outgoing-default)
        policy=`sudo -S ufw status verbose | grep "^Default:[[:space:]].*outgoing.*$" | cut -d ',' -f 2 | cut -d ' ' -f 2`
        echo -n "$policy"
        ;;

    
    rules)
        OLDIFS=$IFS
        IFS=$'\n'
        actionai="ALLOW IN"
        actionao="ALLOW OUT"
        actiondi="DENY IN"
        actiondo="DENY OUT"
        for i in `sudo ufw status numbered | tail -n +5 | grep -v "^$" | tr -s ' ' | grep "^.\+[[:space:]]ALLOW[[:space:]]IN[[:space:]].\+$" |  sed "s/\[.\+\] //"`
        do
            to=`echo "$i" | awk -F' ALLOW IN ' '{print $1}'`
            from=`echo "$i" | awk -F' ALLOW IN ' '{print $2}'`
            echo "$to"
            echo "$actionai"
            echo "$from"
        done
        for i in `sudo ufw status numbered | tail -n +5 | grep -v "^$" | tr -s ' ' | grep "^.\+[[:space:]]ALLOW[[:space:]]OUT[[:space:]].\+$" |  sed "s/\[.\+\] //"`
        do
            to=`echo "$i" | awk -F' ALLOW OUT ' '{print $1}'`
            from=`echo "$i" | awk -F' ALLOW OUT ' '{print $2}'`
            echo "$to"
            echo "$actionao"
            echo "$from"
        done
        for i in `sudo ufw status numbered | tail -n +5 | grep -v "^$" | tr -s ' ' | grep "^.\+[[:space:]]DENY[[:space:]]IN[[:space:]].\+$" |  sed "s/\[.\+\] //"`
        do
            to=`echo "$i" | awk -F' DENY IN ' '{print $1}'`
            from=`echo "$i" | awk -F' DENY IN ' '{print $2}'`
            echo "$to"
            echo "$actiondi"
            echo "$from"
        done
        for i in `sudo ufw status numbered | tail -n +5 | grep -v "^$" | tr -s ' ' | grep "^.\+[[:space:]]DENY[[:space:]]OUT[[:space:]].\+$" |  sed "s/\[.\+\] //"`
        do
            to=`echo "$i" | awk -F' DENY OUT ' '{print $1}'`
            from=`echo "$i" | awk -F' DENY OUT ' '{print $2}'`
            echo "$to"
            echo "$actiondo"
            echo "$from"
        done
        IFS=$OLDIFS
        ;;

    apps)
        sudo ufw app list | tail -n +2 | tr -s ' ' | sed "s/ //"
        ;;


    *)
        exit 155
        ;;
esac