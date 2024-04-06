#!/bin/bash

ARGS=$(getopt -n "$0" -o p:w:n:m:u:s:b:a:c:v:i:r:t:g:d:e:f:h:j:k:l:o:q:x:A:B:C: --long part:,workgroup:,netbios-name:,map-to-guest:,usershare-allow-guests:,security:,public:,path:,comment:,valid-users:,invalid-users:,read-only:,writable:,guest-ok:,guest-only:,browsable:,create-mask:,directory-mask:,force-user:,force-group:,hide-dot-files:,share-name:,group-name:,username:,directory-permission:,owner-user:,owner-group: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
workgroup=""
bname=""
mtg=""
uag=""
security=""
public=""
sharepath=""
comment=""
validusers=""
invalidusers=""
readonly=""
writable=""
guestok=""
guestonly=""
browsable=""
createmask=""
directorymask=""
forceuser=""
forcegroup=""
hidedotfiles=""
sharename=""
groupname=""
username=""
dirperm=""
owneru=""
ownerg=""

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
        
        --workgroup | -w)
            if [[ -n "$2" && "$2" != -* ]]; then
                workgroup="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --netbios-name | -n)
            if [[ -n "$2" && "$2" != -* ]]; then
                bname="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --map-to-guest | -m)
            if [[ -n "$2" && "$2" != -* ]]; then
                mtg="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --usershare-allow-guests | -u)
            if [[ -n "$2" && "$2" != -* ]]; then
                uag="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --security | -s)
            if [[ -n "$2" && "$2" != -* ]]; then
                security="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --public | -b)
            if [[ -n "$2" && "$2" != -* ]]; then
                public="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --path | -a)
            if [[ -n "$2" && "$2" != -* ]]; then
                sharepath="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --comment | -c)
            if [[ -n "$2" && "$2" != -* ]]; then
                comment="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --valid-users | -v)
            if [[ -n "$2" && "$2" != -* ]]; then
                validusers="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --invalid-users | -i)
            if [[ -n "$2" && "$2" != -* ]]; then
                invalidusers="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --read-only | -r)
            if [[ -n "$2" && "$2" != -* ]]; then
                readonly="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --writable | -t)
            if [[ -n "$2" && "$2" != -* ]]; then
                writable="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --guest-ok | -g)
            if [[ -n "$2" && "$2" != -* ]]; then
                guestok="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --guest-only | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                guestonly="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --browsable | -e)
            if [[ -n "$2" && "$2" != -* ]]; then
                browsable="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --create-mask | -f)
            if [[ -n "$2" && "$2" != -* ]]; then
                createmask="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --directory-mask | -h)
            if [[ -n "$2" && "$2" != -* ]]; then
                directorymask="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --force-user | -j)
            if [[ -n "$2" && "$2" != -* ]]; then
                forceuser="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --force-group | -k)
            if [[ -n "$2" && "$2" != -* ]]; then
                forcegroup="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --hide-dot-files | -l)
            if [[ -n "$2" && "$2" != -* ]]; then
                hidedotfiles="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --share-name | -o)
            if [[ -n "$2" && "$2" != -* ]]; then
                sharename="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --group-name | -q)
            if [[ -n "$2" && "$2" != -* ]]; then
                groupname="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --username | -x)
            if [[ -n "$2" && "$2" != -* ]]; then
                username="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --directory-permission | -A)
            if [[ -n "$2" && "$2" != -* ]]; then
                dirperm="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --owner-user | -B)
            if [[ -n "$2" && "$2" != -* ]]; then
                owneru="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --owner-group | -C)
            if [[ -n "$2" && "$2" != -* ]]; then
                ownerg="$2"
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
        if [ -z "$workgroup" ] || [ -z "$bname" ]; then
            exit 155
        fi
        outworkgroup="workgroup = $workgroup"
        outbname="netbios name = $bname"
        outmtg=""
        outuag=""
        outsecurity=""
        outpublic=""

        case "$mtg" in
            bad_user)
                outmtg="map to guest = bad user"
                ;;
            bad_passwd)
                outmtg="map to guest = bad password"
                ;;
            never)
                outmtg="map to guest = never"
                ;;
            not_configured)
                outmtg="#map to guest = not configured"
                ;;
            *)
                exit 155
                ;;
        esac
        
        case "$uag" in
            yes)
                outuag="usershare allow guests = yes"
                ;;
            no)
                outuag="usershare allow guests = no"
                ;;
            not_configured)
                outuag="#usershare allow guests = not configured"
                ;;
            *)
                exit 155
                ;;
        esac
        
        case "$security" in
            user)
                outsecurity="security = user"
                ;;
            share)
                outsecurity="security = share"
                ;;
            not_configured)
                outsecurity="#security = not configured"
                ;;
            *)
                exit 155
                ;;
        esac

        case "$public" in
            yes)
                outpublic="public = yes"
                ;;
            no)
                outpublic="public = no"
                ;;
            not_configured)
                outpublic="#public = not configured"
                ;;
            *)
                exit 155
                ;;
        esac
        path="/etc/.uswg_configs/samba/samba_fglobal_config.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -eq 0 ]; then
            sudo -S truncate -s 0 $path
        else
            sudo -S touch $path
        fi
        
        sudo -S echo '[global]' | sudo -S tee -a $path > /dev/null
        sudo -S echo $outworkgroup | sudo -S tee -a $path > /dev/null
        sudo -S echo $outbname | sudo -S tee -a $path > /dev/null
        sudo -S echo $outmtg | sudo -S tee -a $path > /dev/null
        sudo -S echo $outuag | sudo -S tee -a $path > /dev/null
        sudo -S echo $outsecurity | sudo -S tee -a $path > /dev/null
        sudo -S echo $outpublic | sudo -S tee -a $path > /dev/null
        ;;


    single-user-share)

        ;;
    multi-user-share)
        ;;
    nobody-share)
        outsharename=""
        outsharepath=""
        outcomment=""
        outreadonly=""
        outwritable=""
        outguestok=""
        outguestonly=""
        outbrowsable=""
        outpublic=""
        outcreatemask=""
        outdirectorymask=""
        outforceuser=""
        outforcegroup=""
        outhidedotfiles=""
        
        if [ -z "$sharename" ] || [ -z "$sharepath" ]; then
        echo "gec sharename sharepath"
        echo "nev $sharename"
        echo "path $sharepath"
            exit 155
        fi
        outsharename="[$sharename]"

        
        dirslash=`echo $sharepath | grep "^/.\+$"`
        if [ ! -z "$dirslash" ]; then
                sharepath=`echo $sharepath | cut -d'/' -f3-`
        fi


        if [ ! -d "/srv/samba/$sharepath" ]; then
            sudo -S mkdir -p /srv/samba/$sharepath
        fi

        check=""
        
        if [ ! -z "$dirperm" ]; then
            check=`echo $dirperm | grep "^[0-7]\{3\}$"`
            if [ ! -z "$check" ]; then
                sudo -S chmod $dirperm /srv/samba/$sharepath
            fi
        fi

        check=""
        if [ "$owneru" != "not_configured" ]; then
            check=`cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1 | grep "^$owneru$"`
            if [ ! -z "$check" ]; then
                sudo -S chown $owneru /srv/samba/$sharepath
            fi
        fi

        check=""
        if [ "$ownerg" != "not_configured" ]; then
            check=`cat /etc/group | cut -d':' -f 1 | grep "^$ownerg$"`
            if [ ! -z "$check" ]; then
                sudo -S chown :$ownerg /srv/samba/$sharepath
            fi
        fi
        outsharepath="path = /srv/samba/$sharepath"


        if [ -z "$comment" ] || [ "$comment" == "not_configured" ]; then
            outcomment="#comment = not configured"
        else
            outcomment="comment = $comment"
        fi
        
        
        case "$readonly" in
            yes)
                outreadonly="read only = yes"
                ;;
            no)
                outreadonly="read only = no"
                ;;
            not_configured)
                outreadonly="#read only = not configured"
                ;;
            *)
            echo "gec readonly"
                exit 155
                ;;
        esac

        case "$writable" in
            yes)
                outwritable="writable = yes"
                ;;
            no)
                outwritable="writable = no"
                ;;
            not_configured)
                outwritable="#writable = not configured"
                ;;
            *)
            echo "gec writable"
                exit 155
                ;;
        esac

        case "$guestok" in
            yes)
                outguestok="guest ok = yes"
                ;;
            no)
                outguestok="guest ok = no"
                ;;
            not_configured)
                outguestok="#guest ok = not configured"
                ;;
            *)
            echo "gec guestok"
                exit 155
                ;;
        esac

        case "$guestonly" in
            yes)
                outguestonly="guest only = yes"
                ;;
            no)
                outguestonly="guest only = no"
                ;;
            not_configured)
                outguestonly="#guest only = not configured"
                ;;
            *)
            echo "gec guest only"
                exit 155
                ;;
        esac

        case "$browsable" in
            yes)
                outbrowsable="browsable = yes"
                ;;
            no)
                outbrowsable="browsable = no"
                ;;
            not_configured)
                outbrowsable="#browsable = not configured"
                ;;
            *)
            echo "gec browesable"
                exit 155
                ;;
        esac

        case "$public" in
            yes)
                outpublic="public = yes"
                ;;
            no)
                outpublic="public = no"
                ;;
            not_configured)
                outpublic="#public = not configured"
                ;;
            *)
            echo "gec public"
                exit 155
                ;;
        esac

        case "$hidedotfiles" in
            yes)
                outhidedotfiles="hide dot files = yes"
                ;;
            no)
                outhidedotfiles="hide dot files = no"
                ;;
            not_configured)
                outhidedotfiles="#hide dot files = not configured"
                ;;
            *)
            echo "gec dotfile"
                exit 155
                ;;
        esac

        ok=""
        echo $createmask
        if [ -z "$createmask" ] || [ "$createmask" == "not_configured" ]; then
            outcreatemask="#create mask = not configured"
        else
            ok=`echo $createmask | grep "^[0-7]\{4\}$"`
            if [ -z "$ok" ]; then
            echo "gec createmask"
                exit 155
            else
                outcreatemask="create mask = $createmask"
            fi
        fi

        ok=""

        if [ -z "$directorymask" ] || [ "$directorymask" == "not_configured" ]; then
            outdirectorymask="#directory mask = not configured"
        else
            ok=`echo $directorymask | grep "^[0-7]\{4\}$"`
            if [ -z "$ok" ]; then
            echo "gec dirmask"
                exit 155
            else
                outdirectorymask="directory mask = $directorymask"
            fi
        fi

        if [ -z "$forceuser" ] || [ "$forceuser" == "not_configured" ]; then
            outforceuser="#force user = not configured"
        else

            kk=1
            check=""
            for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1`
                do
                    check=`echo $i | grep "^$forceuser$"`
                    if [ ! -z "$check" ]; then
                        kk=0
                        break
                    fi
                done

            if [ $kk -ne 0 ]; then
            echo "gec frceuser"
                exit 155
            else
                outforceuser="force user = $forceuser"
            fi

        fi


        check=""
        if [ -z "$forcegroup" ] || [ "$forcegroup" == "not_configured" ]; then
            outforcegroup="#force group = not configured"
        else
            kk=1
            for i in `cat /etc/group | cut -d":" -f 1`
                do
                    check=`echo $i | grep "^$forcegroup$"`
                    if [ ! -z "$check" ]; then
                        kk=0
                        break
                    fi
                done


            if [ $kk -ne 0 ]; then
                echo "gec forcegroup $forcegroup"
                exit 155
            else
                outforcegroup="force group = $forcegroup"
            fi
        fi

        



        path="/etc/.uswg_configs/samba/samba_nobody_${sharename}_share.conf"

        ./bash/shared/exist_file.sh $path
        if [ $? -eq 0 ]; then
            exit 154
        fi

        sudo -S touch $path

        sudo -S echo $outsharename | sudo -S tee -a $path > /dev/null
        sudo -S echo $outsharepath | sudo -S tee -a $path > /dev/null
        sudo -S echo $outcomment | sudo -S tee -a $path > /dev/null
        sudo -S echo $outreadonly | sudo -S tee -a $path > /dev/null
        sudo -S echo $outwritable | sudo -S tee -a $path > /dev/null
        sudo -S echo $outguestok | sudo -S tee -a $path > /dev/null
        sudo -S echo $outguestonly | sudo -S tee -a $path > /dev/null
        sudo -S echo $outbrowsable | sudo -S tee -a $path > /dev/null
        sudo -S echo $outpublic | sudo -S tee -a $path > /dev/null
        sudo -S echo $outcreatemask | sudo -S tee -a $path > /dev/null
        sudo -S echo $outdirectorymask | sudo -S tee -a $path > /dev/null
        sudo -S echo $outforceuser | sudo -S tee -a $path > /dev/null
        sudo -S echo $outforcegroup | sudo -S tee -a $path > /dev/null
        sudo -S echo $outhidedotfiles | sudo -S tee -a $path > /dev/null



        ;;
    create-user-list)

        ;;

    append-user-list)
        ;;

    *)
        exit 155
        ;;

esac