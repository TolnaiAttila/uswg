#!/bin/bash

ARGS=$(getopt -n "$0" -o p:a:i:d:n:f:t:P:o:A: --long part:,action:,input:,direction:,network-adapter:,from:,to:,port:,protocol:,app: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
action=""
input=""
direct=""
adapter=""
from=""
to=""
port=""
proto=""
app=""

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
        
        --action | -a)
            if [[ -n "$2" && "$2" != -* ]]; then
                action="$2"
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
        
        --direction | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                direct="$2"
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

        --from | -f)
            if [[ -n "$2" && "$2" != -* ]]; then
                from="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --to | -t)
            if [[ -n "$2" && "$2" != -* ]]; then
                to="$2"
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

        --protocol | -o)
            if [[ -n "$2" && "$2" != -* ]]; then
                proto="$2"
                shift 2
            else
                exit 161
            fi
            ;;


        --app | -A)
            if [[ -n "$2" && "$2" != -* ]]; then
                app="$2"
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

    incoming-default)
        if [ "$action" == "allow" ]; then
            sudo -S ufw default allow incoming
        else
            if [ "$action" == "deny" ]; then
                sudo -S ufw default deny incoming
            else
                exit 155
            fi
        fi
        ;;

    outgoing-default)
        if [ "$action" == "allow" ]; then
            sudo -S ufw default allow outgoing
        else
            if [ "$action" == "deny" ]; then
                sudo -S ufw default deny outgoing
            else
                exit 155
            fi
        fi
        ;;
    
    delete-rule)

        if [ -z "$input" ]; then
            exit 155
        fi

        number=`sudo ufw status numbered | tr -s ' ' | grep "${input}" | cut -d '[' -f 2- | cut -d ']' -f 1 | tr -d ' '`
        if [ -z "$number" ]; then
            exit 155
        fi

        echo "y" | sudo ufw delete $number

        ;;
    
    add-rule)
        case "$action" in 
            allow)
                action="allow"
                ;;
            deny)
                action="deny"
                ;;
            *)
                exit 155
                ;;
        esac
        case "$direct" in
            in)
                direct="in"
                ;;
            out)
                direct="out"
                ;;
            *)
                exit 155
                ;;
        esac

        if [ ! -z "$adapter" ]; then
        
            if [ "$adapter" != "any" ]; then
                check=`ip address | grep "^[0-9]\+:[[:space:]].*$" | cut -d' ' -f2 | tr -d ':' | grep -v "^lo$" | grep "^${adapter}$"`
                if [ -z "$check" ]; then
                    exit 155
                fi
            fi
        else
            exit 155
        fi

        if [ -z "$from" ] || [ -z "$to" ] || [ -z "$port" ] || [ -z "$proto" ]; then
            exit 155
        fi

        check=""
        check=`echo "$from" | grep "\(^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\|\(^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,2\}\)\|\(^any\)$"`
        if [ -z "$check" ]; then
            exit 155
        fi

        check=""
        check=`echo "$to" | grep "\(^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$\)\|\(^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,2\}$\)\|\(^any$\)"`
        if [ -z "$check" ]; then
            exit 155
        fi

        check=""
        check=`echo "$port" | grep "\(^[0-9]\{1,5\}$\)\|\(^[0-9]\{1,5\}:[0-9]\{1,5\}$\)\|\(^any$\)"`
        if [ -z "$check" ]; then
            exit 155
        fi


        check=""
        check=`echo "$proto" | grep "\(^tcp$\)\|\(^udp$\)"`
        if [ -z "$check" ]; then
            exit 155
        fi


        if [ "$adapter" == "any" ]; then
            adapter=""
        else
            adapter="on ${adapter}"
        fi

        
        if [ "$port" == "any" ]; then
            port=""
        else
            port="port ${port}"
        fi

        comm=`echo "sudo -S ufw $action $direct $adapter from $from to $to $port proto $proto" | tr -s ' '`
        eval "$comm"
        ;;


    add-app)
        if [ -z "$app" ]; then
            exit 155
        fi

        check=""
        check=`sudo ufw app list | tail -n +2 | tr -s ' ' | sed "s/ //" | grep "^${app}$"`
        if [ -z "$check" ]; then
            exit 155
        fi

        sudo -S ufw allow $app

        ;;

    *)
        exit 155
        ;;
esac