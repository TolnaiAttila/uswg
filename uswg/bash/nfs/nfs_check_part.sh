#!/bin/bash

ARGS=$(getopt -n "$0" -o p:i --long part:,input: -- "$@")

if [ $? -ne 0 ]; then
    exit 10
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
                exit 10
            fi
            ;;
        
        --input | -i)
            if [[ -n "$2" && "$2" != -* ]]; then
                input="$2"
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

        for i in `ls $path | grep "^nfs_.\+_share\.conf$"`
            do
                fullpath="$path$i"
                for x in `cat $fullpath`
                    do
                        counter=`expr $counter \+ 1`
                    done
                counter=`expr $counter \- 2`
                echo $counter
                counter="0"
            done
        ;;

    configuration)
        
        if [ "$input" == "" ]; then

            for i in `ls $path | grep "^nfs_.\+_share\.conf$"`
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
        else
            if [ -z `echo $input | grep "^\(\(modify\)\|\(delete\)\)_nfs_share_.\+_Button$"` ]; then
                exit 5
            else
                sharename=`echo $input | cut -d'_' -f4`
                path="/etc/.uswg_nfs_config/nfs_${sharename}_share.conf"
                ./bash/shared/exist_file.sh $path

                if [ $? -eq 0 ]; then
                    
                    config=`cat $path`

                    echo $sharename

                    for i in $config
                        do
                            tmp=`echo $i | grep "^.\+(.\+,.\+,.\+)$"`
                            if [ ! -z "$tmp" ]; then
                                access=`echo $i | grep "^.\+(.\+,.\+,.\+)$" | cut -d'(' -f 1`
                                rwro=`echo $i | grep "^.\+(.\+,.\+,.\+)$" | cut -d'(' -f 2 | cut -d',' -f 1`
                                sync=`echo $i | grep "^.\+(.\+,.\+,.\+)$" | cut -d'(' -f 2 | cut -d',' -f 2`
                                squash=`echo $i | grep "^.\+(.\+,.\+,.\+)$" | cut -d'(' -f 2 | cut -d',' -f 3`
                                subtree=`echo $i | grep "^.\+(.\+,.\+,.\+)$" | cut -d'(' -f 2 | cut -d',' -f 4 | tr -d ')'`

                                echo $access
                                echo $rwro
                                echo $sync
                                echo $squash
                                echo $subtree
                            else
                                tmp=`echo $i | grep "^[0-7][0-7][0-7]$"`
                                if [ ! -z "$tmp" ]; then
                                    echo $i
                                else
                                    dir=`echo $i | grep "^/srv/.\+$"`
                                    echo $dir
                                fi
                            fi
                        done

                else
                    exit 1
                fi
            fi
        fi
        ;;

    only-name)

        path="/etc/.uswg_nfs_config/"
        allname=`ls $path | grep "^nfs_.\+_share\.conf$" | cut -d'_' -f2`
        echo $allname
        ;;
    
    *)
        exit 5
        ;;
esac





