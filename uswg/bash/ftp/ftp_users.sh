#!/bin/bash

ARGS=$(getopt -n "$0" -o p:u:d:c:a:s: --long part:,username:,directory-delete:,chroot:,password1:,password2: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
uname=""
dirdel=""
chroot=""
passwd1=""
passwd2=""

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

        --username | -u)
            if [[ -n "$2" && "$2" != -* ]]; then
                uname="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --directory-delete | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                dirdel="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --chroot | -c)
            if [[ -n "$2" && "$2" != -* ]]; then
                chroot="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --password1 | -a)
            if [[ -n "$2" && "$2" != -* ]]; then
                passwd1="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --password2 | -s)
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

case "$part" in

    list-allowed-ftp-users)
        path="/etc/.uswg_configs/ftp/ftp_allowed_users"

        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        cat $path
        ;;
    list-passwdless-users)
        
        for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1`
            do
                sudo passwd -S $i | grep "^.\+[[:space:]]\(\(L\)\|\(NP\)\)[[:space:]].\+$" | cut -d ' ' -f 1
            done
        
        ;;
    list-denied-ftp-users)
    #with passwd
    path="/etc/.uswg_configs/ftp/ftp_allowed_users"
    ./bash/shared/exist_file.sh $path
    if [ $? -ne 0 ]; then
        exit 151
    fi
        for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1`
            do
                if [ ! `cat $path | grep "^${i}$"` ]; then
                    sudo passwd -S $i | grep "^.\+[[:space:]]P[[:space:]].\+$" | cut -d ' ' -f 1
                fi
            done
        ;;
    
    list-chroot-ftp-users)
        path="/etc/.uswg_configs/ftp/ftp_chroot_list"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        cat $path
        ;;

    
    allow-ftp-share)
        path="/etc/.uswg_configs/ftp/ftp_allowed_users"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        
        if [ -z "$uname" ]; then
        
            exit 155
        fi
        
        path="/etc/.uswg_configs/ftp/ftp_allowed_users"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        kk=1
        for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1`
            do
                if [ ! `cat $path | grep "^${i}$"` ]; then
                    if [ `sudo passwd -S $i | grep "^.\+[[:space:]]P[[:space:]].\+$" | cut -d ' ' -f 1 | grep "^${uname}$"` ]; then
                        kk=0
                        break
                    fi
                fi
            done
        
        if [ $kk -ne 0 ]; then
            
            exit 155
        fi

        sudo -S echo $uname | sudo -S tee -a $path > /dev/null
        if [ ! -d /srv/ftp/$uname ]; then
            sudo -S mkdir /srv/ftp/$uname
        fi

        sudo -S chown $uname:users /srv/ftp/$uname
        sudo -S chmod 755 /srv/ftp/$uname
        
        
        ;;

    deny-ftp-share)
        if [ -z "$uname" ]; then
            exit 155
        fi

        path="/etc/.uswg_configs/ftp/ftp_allowed_users"

        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi

        if [ ! `cat $path | grep "^${uname}$"` ]; then
            exit 155
        fi
        
        path2="/etc/.uswg_configs/ftp/ftp_chroot_list"
        ./bash/shared/exist_file.sh $path2
        if [ $? -ne 0 ]; then
            exit 151
        fi

        if [ "$dirdel" == "yes" ]; then
            sudo -S rm -r -d /srv/ftp/$uname
        else
            if [ "$dirdel" != "no" ]; then
                exit 155
            fi
        fi

        linenumber=`grep -n "^${uname}$" $path | cut -d':' -f 1`
        sudo -S sed -i "${linenumber}d" $path


        if [ `grep "^${uname}$" $path2` ]; then
            linenumber=`grep -n "^${uname}$" $path2 | cut -d':' -f 1`
            sudo -S sed -i "${linenumber}d" $path2
        fi


        ;;


    chroot-modify)
        if [ -z "$uname" ]; then
            exit 155
        fi

        path="/etc/.uswg_configs/ftp/ftp_allowed_users"
    
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi

        path2="/etc/.uswg_configs/ftp/ftp_chroot_list"
        ./bash/shared/exist_file.sh $path2
        if [ $? -ne 0 ]; then
            exit 151
        fi

        if [ ! `cat $path | grep "^${uname}$"` ]; then
            exit 155
        fi

        if [ "$chroot" == "allow" ]; then
            if [ ! `cat $path2 | grep "^${uname}$"` ]; then
                sudo -S echo $uname | sudo -S tee -a $path2 > /dev/null
            fi
        else
            if [ "$chroot" == "deny" ]; then
                if [ `cat $path2 | grep "^${uname}$"` ]; then
                    linenumber=`grep -n "^${uname}$" $path2 | cut -d':' -f 1`
                    sudo -S sed -i "${linenumber}d" $path2
                fi
            else
                exit 155
            fi
        fi
        ;;

    add-passwd)
        if [ -z "$uname" ] || [ -z "$passwd1" ] || [ -z "$passwd2" ]; then
            exit 155
        fi

        if [ "$passwd1" != "$passwd2" ]; then
            exit 163
        fi

        kk=1

        for i in `cat /etc/passwd | cut -d':' -f 1-3 | grep -v "^nobody:.\+" | grep "[0-9]\{4,5\}$" | cut -d':' -f 1`
            do
                if [ `sudo passwd -S $i | grep "^.\+[[:space:]]\(\(L\)\|\(NP\)\)[[:space:]].\+$" | cut -d ' ' -f 1 | grep "^${uname}$"` ]; then
                    kk=0
                    break
                fi
            done

        if [ $kk -ne 0 ]; then
            exit 155
        fi

        (echo "$passwd1"; echo "$passwd2") | sudo -S passwd $uname


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
    *)
        exit 155
        ;;

esac