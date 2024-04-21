#!/bin/bash

ARGS=$(getopt -n "$0" -o p:l:L:u:m:w:f:h:M:c:a:U:d:o:W:t: --long part:,listen-ipv4:,listen-ipv6:,local-enable:,message-enable:,write-enable:,force-dot-files:,hide-ids:,max-p-ip:,max-clients:,anon-enable:,anon-upload-enable:,anon-mkdir-enable:,anon-other-write-enable:,anon-world-readonly:,message-text: -- "$@")

if [ $? -ne 0 ]; then
    exit 161
fi

eval set -- "$ARGS"

part=""
ipv4=""
ipv6=""
localen=""
messageen=""
writeen=""
dotfiles=""
hideids=""
maxpip=""
maxclients=""
anonen=""
anonupen=""
anonmkdir=""
anonotherwriteen=""
anonworldro=""
messagetext=""

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
        
        --listen-ipv4 | -l)
            if [[ -n "$2" && "$2" != -* ]]; then
                ipv4="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        --listen-ipv6 | -L)
            if [[ -n "$2" && "$2" != -* ]]; then
                ipv6="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --local-enable | -u)
            if [[ -n "$2" && "$2" != -* ]]; then
                localen="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --message-enable | -m)
            if [[ -n "$2" && "$2" != -* ]]; then
                messageen="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --write-enable | -w)
            if [[ -n "$2" && "$2" != -* ]]; then
                writeen="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --force-dot-files | -f)
            if [[ -n "$2" && "$2" != -* ]]; then
                dotfiles="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --hide-ids | -h)
            if [[ -n "$2" && "$2" != -* ]]; then
                hideids="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --max-p-ip | -M)
            if [[ -n "$2" && "$2" != -* ]]; then
                maxpip="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --max-clients | -c)
            if [[ -n "$2" && "$2" != -* ]]; then
                maxclients="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --anon-enable | -a)
            if [[ -n "$2" && "$2" != -* ]]; then
                anonen="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --anon-upload-enable | -U)
            if [[ -n "$2" && "$2" != -* ]]; then
                anonupen="$2"
                shift 2
            else
                exit 161
            fi
            ;;
        
        --anon-mkdir-enable | -d)
            if [[ -n "$2" && "$2" != -* ]]; then
                anonmkdir="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --anon-other-write-enable | -o)
            if [[ -n "$2" && "$2" != -* ]]; then
                anonotherwriteen="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --anon-world-readonly | -W)
            if [[ -n "$2" && "$2" != -* ]]; then
                anonworldro="$2"
                shift 2
            else
                exit 161
            fi
            ;;

        --message-text | -t)
            if [[ -n "$2" && "$2" != -* ]]; then
                messagetext="$2"
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
        path="/etc/.uswg_configs/ftp/ftp_sglobal_config.conf"
        
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            sudo -S touch $path
        fi
        
        if [ -z "$ipv4" ] || [ -z "$ipv6" ] || [ -z "$localen" ] || [ -z "$messageen" ] || [ -z "$writeen" ] || [ -z "$dotfiles" ] || [ -z "$hideids" ] || [ -z "$maxpip" ] || [ -z "$maxclients" ] || [ -z "$anonen" ] || [ -z "$anonupen" ] || [ -z "$anonmkdir" ] || [ -z "$anonotherwriteen" ] || [ -z "$anonworldro" ]; then
            exit 155
        fi
        
        if [ "$ipv4" == "yes" ]; then
            outipv4="listen=YES"
        else
            if [ "$ipv4" == "no" ]; then
                outipv4="listen=NO"
            else
                exit 155
            fi

        fi

        if [ "$ipv6" == "yes" ]; then
            outipv6="listen_ipv6=YES"
        else
            if [ "$ipv6" == "no" ]; then
                outipv6="listen_ipv6=NO"
            else
                exit 155
            fi

        fi

        if [ "$anonen" == "yes" ]; then
            outanonen="anonymous_enable=YES"
        else
            if [ "$anonen" == "no" ]; then
                outanonen="anonymous_enable=NO"
            else
                exit 155
            fi

        fi

        if [ "$localen" == "yes" ]; then
            outlocalen="local_enable=YES"
        else
            if [ "$localen" == "no" ]; then
                outlocalen="local_enable=NO"
            else
                exit 155
            fi

        fi

        if [ "$messageen" == "yes" ]; then
            outmessageen="dirmessage_enable=YES"
        else
            if [ "$messageen" == "no" ]; then
                outmessageen="dirmessage_enable=NO"
            else
                exit 155
            fi

        fi

        if [ "$writeen" == "yes" ]; then
            outwriteen="write_enable=YES"
        else
            if [ "$writeen" == "no" ]; then
                outwriteen="write_enable=NO"
            else
                exit 155
            fi

        fi

        if [ "$dotfiles" == "yes" ]; then
            outdotfiles="force_dot_files=YES"
        else
            if [ "$dotfiles" == "no" ]; then
                outdotfiles="force_dot_files=NO"
            else
                exit 155
            fi

        fi

        if [ "$hideids" == "yes" ]; then
            outhideids="hide_ids=YES"
        else
            if [ "$hideids" == "no" ]; then
                outhideids="hide_ids=NO"
            else
                exit 155
            fi

        fi

        if [ "$anonupen" == "yes" ]; then
            outanonupen="anon_upload_enable=YES"
        else
            if [ "$anonupen" == "no" ]; then
                outanonupen="anon_upload_enable=NO"
            else
                exit 155
            fi

        fi
        if [ "$anonmkdir" == "yes" ]; then
            outanonmkdir="anon_mkdir_write_enable=YES"
        else
            if [ "$anonmkdir" == "no" ]; then
                outanonmkdir="anon_mkdir_write_enable=NO"
            else
                exit 155
            fi

        fi

        if [ "$anonotherwriteen" == "yes" ]; then
            outanonotherwriteen="anon_other_write_enable=YES"
        else
            if [ "$anonotherwriteen" == "no" ]; then
                outanonotherwriteen="anon_other_write_enable=NO"
            else
                exit 155
            fi

        fi

        if [ "$anonworldro" == "yes" ]; then
            outanonworldro="anon_world_readable_only=YES"
        else
            if [ "$anonworldro" == "no" ]; then
                outanonworldro="anon_world_readable_only=NO"
            else
                exit 155
            fi

        fi

        check=""
        check=`echo $maxpip | grep "^[0-9]\{1,3\}$"`
        if [ -z "$check" ]; then
            exit 155
        else
            outmaxpip="max_per_ip=${maxpip}"
        fi

        check=""
        check=`echo $maxclients| grep "^[0-9]\{1,3\}$"`
        if [ -z "$check" ]; then
            exit 155
        else
            outmaxclients="max_clients=${maxclients}"
        fi
        
        sudo -S truncate -s 0 $path

        sudo -S echo $outipv4 | sudo -S tee -a $path > /dev/null
        sudo -S echo $outipv6 | sudo -S tee -a $path > /dev/null
        sudo -S echo $outanonen | sudo -S tee -a $path > /dev/null
        sudo -S echo $outlocalen | sudo -S tee -a $path > /dev/null
        sudo -S echo $outmessageen | sudo -S tee -a $path > /dev/null
        sudo -S echo $outwriteen | sudo -S tee -a $path > /dev/null
        sudo -S echo $outanonupen | sudo -S tee -a $path > /dev/null
        sudo -S echo $outanonmkdir | sudo -S tee -a $path > /dev/null
        sudo -S echo $outanonotherwriteen | sudo -S tee -a $path > /dev/null
        sudo -S echo $outanonworldro | sudo -S tee -a $path > /dev/null
        sudo -S echo $outdotfiles | sudo -S tee -a $path > /dev/null
        sudo -S echo $outhideids | sudo -S tee -a $path > /dev/null
        sudo -S echo $outmaxpip | sudo -S tee -a $path > /dev/null
        sudo -S echo $outmaxclients | sudo -S tee -a $path > /dev/null
        
        ;;
    message)

        path="/etc/.uswg_configs/ftp/ftp_message"
        
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            sudo -S touch $path
        fi

        if [ "$messagetext" == "empty" ]; then
            sudo -S truncate -s 0 $path
        else
            sudo -S truncate -s 0 $path
            sudo -S echo $messagetext | sudo -S tee -a $path > /dev/null
        fi
        
        ;;

    
    *)
        exit 155
        ;;
esac
