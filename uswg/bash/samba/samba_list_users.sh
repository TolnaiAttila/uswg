#!/bin/bash

ARGS=$(getopt -n "$0" -o p: --long part: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""

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
tf=0
case "$part" in 
    only-system-users)

        for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4\}$" | cut -d':' -f 1`
            do
                for x in `sudo pdbedit -L | cut -d':' -f 1`
                    do
                        if [ "$i" == "$x" ]; then
                            tf=1
                        fi
                    done

                if [ $tf -eq 0 ]; then
                    echo $i
                fi
                tf=0
            done
        
        ;;
        

    samba-users)
        sudo pdbedit -L | cut -d':' -f 1
        
        ;;
    *)
        exit 155
        ;;
esac