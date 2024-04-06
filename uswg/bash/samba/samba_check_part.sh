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
    global)
        path="/etc/.uswg_configs/samba/samba_fglobal_config.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -eq 0 ]; then

            workgroup=`cat $path | grep "^\(\(workgroup\)\|\(#workgroup\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            bname=`cat $path | grep "^\(\(netbios\)\|\(#netbios\)\)[[:space:]]name[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            mtg=`cat $path | grep "^\(\(map\)\|\(#map\)\)[[:space:]]to[[:space:]]guest[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            uag=`cat $path | grep "^\(\(usershare\)\|\(#usershare\)\)[[:space:]]allow[[:space:]]guests[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            security=`cat $path | grep "^\(\(security\)\|\(#security\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`
            public=`cat $path | grep "^\(\(public\)\|\(#public\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2 | sed 's/ //'`

            if [ -z "$workgroup" ]; then
                echo "empty"
            else
                echo $workgroup
            fi

            if [ -z "$bname" ]; then
                echo "empty"
            else
                echo $bname
            fi

            if [ -z "$mtg" ]; then
                echo "empty"
            else
                echo $mtg
            fi

            if [ -z "$uag" ]; then
                echo "empty"
            else
                echo $uag
            fi

            if [ -z "$security" ]; then
                echo "empty"
            else
                echo $security
            fi

            if [ -z "$public" ]; then
                echo "empty"
            else
                echo $public
            fi

        else
            exit 151
        fi
        ;;

    nobody-share)

        if [ -z "$input" ]; then
            path="/etc/.uswg_configs/samba/"
            check=""
            for i in `ls $path | grep "^samba_nobody_.\+_share.conf"`
                do
                    
                    sharename=`cat $path$i | grep "^\[.\+\]$" | cut -d'[' -f 2 | cut -d']' -f 1`
                    sharepath=`cat $path$i | grep "^\(\(path\)\|\(#path\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    comment=`cat $path$i | grep "^\(\(comment\)\|\(#comment\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    readonly=`cat $path$i | grep "^\(\(read[[:space:]]only\)\|\(#read[[:space:]]only\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    writable=`cat $path$i | grep "^\(\(writable\)\|\(#writable\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    guestok=`cat $path$i | grep "^\(\(guest[[:space:]]ok\)\|\(#guest[[:space:]]ok\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    guestonly=`cat $path$i | grep "^\(\(guest[[:space:]]only\)\|\(#guest[[:space:]]only\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    browsable=`cat $path$i | grep "^\(\(browsable\)\|\(#browsable\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    public=`cat $path$i | grep "^\(\(public\)\|\(#public\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2- | sed 's/ //'`
                    createmask=`cat $path$i | grep "^\(\(create[[:space:]]mask\)\|\(#create[[:space:]]mask\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    directorymask=`cat $path$i | grep "^\(\(directory[[:space:]]mask\)\|\(#directory[[:space:]]mask\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    forceuser=`cat $path$i | grep "^\(\(force[[:space:]]user\)\|\(#force[[:space:]]user\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    forcegroup=`cat $path$i | grep "^\(\(force[[:space:]]group\)\|\(#force[[:space:]]group\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
                    hidedotfiles=`cat $path$i | grep "^\(\(hide[[:space:]]dot[[:space:]]files\)\|\(#hide[[:space:]]dot[[:space:]]files\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`

                    if [ -z "$sharename" ]; then
                        echo "empty"
                    else
                        echo $sharename
                    fi
                    
                    if [ -z "$sharepath" ] || [ ! -d "$sharepath" ]; then
                        echo "empty"
                        echo "empty"
                        echo "empty"
                        echo "empty"
                    else
                        echo $sharepath
                        stat -c %a $sharepath
                        stat -c %U $sharepath
                        stat -c %G $sharepath
                    fi

                    if [ -z "$comment" ]; then
                        echo "empty"
                    else
                        echo $comment
                    fi

                    if [ -z "$readonly" ]; then
                        echo "empty"
                    else
                        echo $readonly
                    fi

                    if [ -z "$writable" ]; then
                        echo "empty"
                    else
                        echo $writable
                    fi

                    if [ -z "$guestok" ]; then
                        echo "empty"
                    else
                        echo $guestok
                    fi

                    if [ -z "$guestonly" ]; then
                        echo "empty"
                    else
                        echo $guestonly
                    fi

                    if [ -z "$browsable" ]; then
                        echo "empty"
                    else
                        echo $browsable
                    fi

                    if [ -z "$public" ]; then
                        echo "empty"
                    else
                        echo $public
                    fi

                    if [ -z "$createmask" ]; then
                        echo "empty"
                    else
                        echo $createmask
                    fi

                    if [ -z "$directorymask" ]; then
                        echo "empty"
                    else
                        echo $directorymask
                    fi

                    if [ -z "$forceuser" ]; then
                        echo "empty"
                    else
                        echo $forceuser
                    fi

                    if [ -z "$forcegroup" ]; then
                        echo "empty"
                    else
                        echo $forcegroup
                    fi

                    if [ -z "$hidedotfiles" ]; then
                        echo "empty"
                    else
                        echo $hidedotfiles
                    fi
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                done

        else
            check=""
            check=`echo $input | grep "^modify_samba_share_.\+_Button$"`
            if [ -z "$check" ]; then
                exit 155
            fi
            name=`echo $input | cut -d'_' -f 4`
            path="/etc/.uswg_configs/samba/samba_nobody_${name}_share.conf"
            
            ./bash/shared/exist_file.sh $path
            if [ $? -ne 0 ]; then
                151
            fi

            sharename=`cat $path | grep "^\[.\+\]$" | cut -d'[' -f 2 | cut -d']' -f 1`
            sharepath=`cat $path | grep "^\(\(path\)\|\(#path\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            comment=`cat $path | grep "^\(\(comment\)\|\(#comment\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            readonly=`cat $path | grep "^\(\(read[[:space:]]only\)\|\(#read[[:space:]]only\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            writable=`cat $path | grep "^\(\(writable\)\|\(#writable\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            guestok=`cat $path | grep "^\(\(guest[[:space:]]ok\)\|\(#guest[[:space:]]ok\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            guestonly=`cat $path | grep "^\(\(guest[[:space:]]only\)\|\(#guest[[:space:]]only\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            browsable=`cat $path | grep "^\(\(browsable\)\|\(#browsable\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            public=`cat $path | grep "^\(\(public\)\|\(#public\)\)[[:space:]]=[[:space:]].\+$" | cut -d'=' -f 2- | sed 's/ //'`
            createmask=`cat $path | grep "^\(\(create[[:space:]]mask\)\|\(#create[[:space:]]mask\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            directorymask=`cat $path | grep "^\(\(directory[[:space:]]mask\)\|\(#directory[[:space:]]mask\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            forceuser=`cat $path | grep "^\(\(force[[:space:]]user\)\|\(#force[[:space:]]user\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            forcegroup=`cat $path | grep "^\(\(force[[:space:]]group\)\|\(#force[[:space:]]group\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`
            hidedotfiles=`cat $path | grep "^\(\(hide[[:space:]]dot[[:space:]]files\)\|\(#hide[[:space:]]dot[[:space:]]files\)\)[[:space:]]=[[:space:]].\+$" |  cut -d'=' -f 2- | sed 's/ //'`

            if [ -z "$sharename" ]; then
                echo "empty"
            else
                echo $sharename
            fi
                    
            if [ -z "$sharepath" ] || [ ! -d "$sharepath" ]; then
                echo "empty"
                echo "empty"
                echo "empty"
                echo "empty"
            else
                echo $sharepath
                stat -c %a $sharepath
                stat -c %U $sharepath
                stat -c %G $sharepath
            fi

            if [ -z "$comment" ]; then
                echo "empty"
            else
                echo $comment
            fi

            if [ -z "$readonly" ]; then
                echo "empty"
            else
                echo $readonly
            fi

            if [ -z "$writable" ]; then
                echo "empty"
            else
                echo $writable
            fi

            if [ -z "$guestok" ]; then
                echo "empty"
            else
                echo $guestok
            fi

            if [ -z "$guestonly" ]; then
                echo "empty"
            else
                echo $guestonly
            fi

            if [ -z "$browsable" ]; then
                echo "empty"
            else
                echo $browsable
            fi

            if [ -z "$public" ]; then
                echo "empty"
            else
                echo $public
            fi

            if [ -z "$createmask" ]; then
                echo "empty"
            else
                echo $createmask
            fi

            if [ -z "$directorymask" ]; then
                echo "empty"
            else
                echo $directorymask
            fi

            if [ -z "$forceuser" ]; then
                echo "empty"
            else
                echo $forceuser
            fi

            if [ -z "$forcegroup" ]; then
                echo "empty"
            else
                echo $forcegroup
            fi

            if [ -z "$hidedotfiles" ]; then
                echo "empty"
            else
                echo $hidedotfiles
            fi

        fi
        ;;
        
    *)
        exit 155
        ;;
esac