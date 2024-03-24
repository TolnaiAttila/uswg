#!/bin/bash

ARGS=$(getopt -n "$0" -o x:n:d:a:p:s:c:r:i: --long action:,name:,directory:,access:,permission:,sync:,subtree-check:,root-squash:,directory-permission: -- "$@")

if [ $? -ne 0 ]; then
    exit 10
fi

eval set -- "$ARGS"

action=""
name=""
directory=""
access=""
permission=""
sync=""
subtree=""
squash=""
dirperm=""

while true; do
    case "$1" in
        --action | -x)
            if [[ -n "$2" && "$2" != -* ]]; then
                action="$2"
                shift 2
            else
                exit 10
            fi
            ;;

          --directory-permission | -i)
            if [[ -n "$2" && "$2" != -* ]]; then
                dirperm="$2"
                shift 2
            else
                exit 10
            fi
            ;;

        --name | -n)
            if [[ -n "$2" && "$2" != -* ]]; then
                name="$2"
                shift 2
            else
                exit 10
            fi
            ;;

        --directory | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                directory="$2"
                shift 2
            else
                exit 10
            fi
            ;;
        
        --access | -a)
            if [[ -n "$2" && "$2" != -* ]]; then
                access="$2"
                shift 2
            else
                exit 10
            fi
            ;;
        
        --permission | -p)
            if [[ -n "$2" && "$2" != -* ]]; then
                permission="$2"
                shift 2
            else
                exit 10
            fi
            ;;
        --sync | -s)
            if [[ -n "$2" && "$2" != -* ]]; then
                sync="$2"
                shift 2
            else
                exit 10
            fi
            ;;
        --subtree-check | -c)
            if [[ -n "$2" && "$2" != -* ]]; then
                subtree="$2"
                shift 2
            else
                exit 10
            fi
            ;;

        --root-squash | -r)
            if [[ -n "$2" && "$2" != -* ]]; then
                squash="$2"
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


if [ -z "$name" ] || [ -z "$access" ] || [ -z "$action" ]; then
    exit 5
fi

if [ "$permission" != "ro" ] && [ "$permission" != "rw" ]; then
    exit 5
fi

if [ "$sync" != "sync" ] && [ "$sync" != "async" ]; then
    exit 5
fi

if [ "$squash" != "no_root_squash" ] && [ "$squash" != "root_squash" ]; then
    exit 5
fi

if [ "$subtree" != "subtree_check" ] && [ "$subtree" != "no_subtree_check" ]; then
    exit 5
fi

path="/etc/.uswg_configs/nfs/nfs_${name}_share.conf"

case "$action" in
    create)

        if [ -z "$directory" ] || [ -z "$dirperm" ]; then
            exit 5
        fi

        dirslash=`echo $directory | grep "^/srv/nfs/.\+$"`
        if [ ! -z "$dirslash" ]; then
            directory=`echo $directory | cut -d'/' -f4-`
        else
            dirslash=`echo $directory | grep "^/.\+$"`
            if [ ! -z "$dirslash" ]; then
                directory=`echo $directory | cut -d'/' -f3-`
            fi
        fi
        
        ./bash/shared/exist_file.sh $path
        if [ $? -eq 0 ]; then
            exit 4
        fi

        sudo -S touch $path

        if [ ! -d "/srv/nfs/$directory" ]; then
            sudo -S mkdir -p /srv/nfs/$directory
            sudo -S chmod $dirperm /srv/nfs/$directory
        fi
        
        sudo -S echo "/srv/nfs/$directory" | sudo -S tee -a $path > /dev/null
        sudo -S echo "$dirperm" | sudo -S tee -a $path > /dev/null
        check=`grep "^$access(.\+)$" $path`
        if [ -z "$check" ]; then
            sudo -S echo "$access($permission,$sync,$squash,$subtree)" | sudo -S tee -a $path > /dev/null
        else 
            exit 5
        fi
        ;;

    append)

        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 1
        fi
        
        check=`grep "^$access(.\+)$" $path`
        if [ -z "$check" ]; then
            sudo -S echo "$access($permission,$sync,$squash,$subtree)" | sudo -S tee -a $path > /dev/null
        else
            exit 5
        fi

        ;;
    
    *)
        exit 5
        ;;

esac








