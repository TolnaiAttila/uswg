#!/bin/bash

ARGS=$(getopt -n "$0" -o p: --long part: -- "$@")

if [ $? -ne 0 ]; then
    exit 10
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


path="/etc/.uswg_nfs_config/"


case "$part" in 
    rowspan)
        counter="0"

        for i in `ls $path | grep "^nfs_.*_share\.conf$"`
            do
                fullpath="$path$i"
                for x in `cat $fullpath`
                    do
                        counter=`expr $counter \+ 1`
                    done
                counter=`expr $counter \- 1`
                echo $counter
                counter="0"
            done
        ;;

    configuration)
        
        for i in `ls $path | grep "^nfs_.*_share\.conf$"`
            do
                echo $i | cut -d'_' -f 2
                fullpath="$path$i"
                for x in `cat $fullpath`
                    do
                        line=`echo $x | grep ".*(.*).*"`
                        if [ ! -z "$line" ]; then
                            echo $x | cut -d'(' -f 1
                            echo "(`echo $x | cut -d'(' -f 2`"
                        else
                            echo $x
                        fi
                        
                    done
            done

        ;;
    
    *)
        exit 5
        ;;
esac





