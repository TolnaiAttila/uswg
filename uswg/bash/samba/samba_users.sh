#!/bin/bash

ARGS=$(getopt -n "$0" -o e:u:P:p --long part:,username:,password1:,password2: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
uname=""
passwd1=""
passwd2=""

while true; do
    case "$1" in
        --part | -e)
            if [[ -n "$2" && "$2" != -* ]]; then
                part="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --username | -u)
            if [[ -n "$2" && "$2" != -* ]]; then
                uname="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --password1 | -P)
            if [[ -n "$2" && "$2" != -* ]]; then
                passwd1="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --password2 | -p)
            if [[ -n "$2" && "$2" != -* ]]; then
                passwd2="$2"
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
    list-leftover-system-users)

        for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1`
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
    
    list-all-users)
        cat /etc/passwd | cut -d':' -f 1
        ;;
    list-samba-users)
        sudo pdbedit -L | cut -d':' -f 1
        
        ;;
    
    add-samba-user)
        if [ -z "$uname" ] || [ -z "$passwd1" ] || [ -z "$passwd2" ]; then
            exit 155
        fi

        if [ "$passwd1" != "$passwd2" ]; then
            exit 163
        fi


        (echo "$passwd1"; echo "$passwd1") | sudo -S smbpasswd -a $uname -s
        
        ;;
    
    remove-samba-user)
        
        if [ -z "$uname" ]; then
            exit 155
        fi
        
        sudo -S smbpasswd -x $uname

        ;;

    add-system-user)
        if [ -z "$uname" ]; then
            exit 155
        fi
        if [ `cat /etc/passwd | cut -d':' -f 1 | grep "^${uname}$"` ]; then
            exit 165
        fi
        sudo adduser --gecos "" --gid 100 --disabled-password --home /home/$uname --shell /usr/sbin/nologin $uname
        ;;

    list-all-system-groups)
        cat /etc/group | cut -d':' -f 1
        ;;

    *)

        exit 155
        ;;
esac