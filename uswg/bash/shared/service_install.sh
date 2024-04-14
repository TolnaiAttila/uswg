#!/bin/bash

service=$1

if [ -z "$service" ]; then
    exit 155
fi

case $service in
    isc-dhcp-server)
        sudo -S apt update
        sudo -S apt install isc-dhcp-server -y

        if [ $? -ne 0 ]; then
            exit 153
        else
            sudo -S mkdir /etc/.uswg_configs/dhcp
            sudo -S mkdir /etc/.uswg_configs/dhcp/dhcp_config
            sudo -S mkdir /etc/.uswg_configs/dhcp/old_dhcp_config
        fi
        exit 0
        ;;

    bind9)
        sudo -S apt update
        sudo -S apt install bind9 -y

        if [ $? -ne 0 ]; then
            exit 153
        else

        sudo -S mkdir /etc/.uswg_configs/dns/dns_config
        sudo -S mkdir /etc/.uswg_configs/dns/old_dns_config

        fi

        exit 0
        ;;
    
    nfs-kernel-server)
        path="/etc/exports"
        sudo -S apt update
        sudo -S apt install nfs-kernel-server -y

        if [ $? -ne 0 ]; then
            exit 153
        fi
        sudo -S truncate -s 0 $path
        sudo -S mkdir /etc/.uswg_configs/nfs
        if [ ! -d /srv/nfs ]; then
            sudo -S mkdir /srv/nfs
        fi


        exit 0
        ;;
    
    
    samba)
        sudo -S apt update
        sudo -S apt install samba -y
        sudo -S apt install samba-common -y
        
        if [ $? -ne 0 ]; then
            exit 153
        fi
        path="/etc/samba/smb.conf"
        secondconfigpath="/etc/.uswg_configs/samba/samba_sglobal_config.conf"
        firstconfigpath="/etc/.uswg_configs/samba/samba_fglobal_config.conf"
        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        
        sudo -S mkdir /etc/.uswg_configs/samba
        sudo -S touch $secondconfigpath

        tmppath="/etc/.uswg_configs/samba/sambatmp.conf"
        sudo -S cat /etc/samba/smb.conf | grep -v "^\(\(#\)\|\(;\)\|\($\)\)" | sudo -S tee $tmppath > /dev/null
        
        sudo -S truncate -s 0 $path

        linenumber=`grep -n "\[.\+\]" $tmppath | grep -v "\[global\]" | head -n 1 | cut -d':' -f 1`
        linenumber=`expr $linenumber \- 1`
        sudo -S sed -i 's/^[[:space:]]*//' $tmppath
        tmppath2="/etc/.uswg_configs/samba/sambatmp2.conf"
        sudo -S head -n $linenumber $tmppath  | sudo -S tee -a $tmppath2 > /dev/null

        linenumber=""
        linenumber=`sudo -S grep -n "^workgroup.\+$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi
        linenumber=""
        linenumber=`sudo -S grep -n "^map[[:space:]]to[[:space:]]guest.\+$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi
        linenumber=""
        linenumber=`sudo -S grep -n "^usershare[[:space:]]allow[[:space:]]guests.\+$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi
        linenumber=""
        linenumber=`sudo -S grep -n "^netbios[[:space:]]name.\+$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi
        linenumber=""
        linenumber=`sudo -S grep -n "^security.\+$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi
        linenumber=""
        linenumber=`sudo -S grep -n "^public.\+$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi
        linenumber=""
        linenumber=`sudo -S grep -n "^\[global\]$" $tmppath2 | cut -d':' -f 1`
        if [ ! -z "$linenumber" ]; then
            sudo -S sed -i "${linenumber}d" $tmppath2
        fi

        sudo -S cat $tmppath2 | sudo -S tee $secondconfigpath > /dev/null
        sudo -S rm $tmppath
        sudo -S rm $tmppath2

        nbios=`hostname`
        sudo -S echo "[global]" | sudo -S tee -a $firstconfigpath > /dev/null
        sudo -S echo "workgroup = WORKGROUP" | sudo -S tee -a $firstconfigpath > /dev/null
        sudo -S echo "netbios name = $nbios" | sudo -S tee -a $firstconfigpath > /dev/null
        sudo -S echo "map to guest = bad user" | sudo -S tee -a $firstconfigpath > /dev/null
        sudo -S echo "usershare allow guests = yes" | sudo -S tee -a $firstconfigpath > /dev/null
        sudo -S echo "security = user" | sudo -S tee -a $firstconfigpath > /dev/null
        sudo -S echo "public = yes" | sudo -S tee -a $firstconfigpath > /dev/null
        
        sudo -S cat $firstconfigpath | sudo -S tee -a $path > /dev/null
        sudo -S cat $secondconfigpath | sudo -S tee -a $path > /dev/null

        if [ ! -d /srv/samba ]; then
            sudo -S mkdir /srv/samba
        fi
        ;;
    
    vsftpd)
        sudo -S apt update
        sudo -S apt install vsftpd -y
        
        if [ $? -ne 0 ]; then
            exit 153
        fi


        
        path="/etc/vsftpd.conf"
        configpath="/etc/.uswg_configs/ftp/ftp_fglobal_config.conf"
        configpath2="/etc/.uswg_configs/ftp/ftp_sglobal_config.conf"
        sudo -S mkdir /etc/.uswg_configs/ftp

        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        sudo -S cat $path | grep -v "^\(\(#\)\|\($\)\)" | grep -v "^\(\(listen=\)\|\(listen_ipv6=\)\|\(anonymous_enable=\)\|\(local_enable=\)\|\(dirmessage_enable=\)\|\(message_file=\)\|\(write_enable=\)\|\(chroot_local_user=\)\|\(chroot_list_enable=\)\|\(allow_writeable_chroot=\)\|\(chroot_list_file=\)\|\(userlist_deny=\)\|\(userlist_file=\)\|\(userlist_enable=\)\|\(force_dot_files=\)\|\(hide_ids=\)\|\(max_per_ip=\)\|\(max_clients=\)\|\(user_sub_token=\)\|\(local_root=\)\)" | sudo -S tee -a $configpath > /dev/null
        
        sudo -S echo "listen=YES" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "listen_ipv6=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "anonymous_enable=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "local_enable=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "dirmessage_enable=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "write_enable=YES" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "anon_upload_enable=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "anon_mkdir_write_enable=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "anon_other_write_enable=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "anon_world_readable_only=YES" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "force_dot_files=NO" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "hide_ids=YES" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "max_per_ip=5" | sudo -S tee -a $configpath2 > /dev/null
        sudo -S echo "max_clients=20" | sudo -S tee -a $configpath2 > /dev/null
        

        chrootlistpath="/etc/ftp_chroot_list"
        userlistpath="/etc/ftp_allowed_users"

        sudo -S echo "user_sub_token=\$USER" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "local_root=/srv/ftp/\$USER" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "userlist_deny=NO" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "userlist_enable=YES" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "userlist_file=${userlistpath}" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "chroot_local_user=YES" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "chroot_list_enable=YES" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "allow_writeable_chroot=YES" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "chroot_list_file=${chrootlistpath}" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "message_file=/etc/ftp_message" | sudo -S tee -a $configpath > /dev/null
        sudo -S echo "anon_root=/srv/ftp/anonymous_share" | sudo -S tee -a $configpath > /dev/null




        sudo -S truncate -s 0 $path

        sudo -S cat $configpath | sudo -S tee -a $path > /dev/null
        sudo -S cat $configpath2 | sudo -S tee -a $path > /dev/null


        messagepath="/etc/ftp_message"
        ./bash/shared/exist_file.sh $messagepath
        if [ $? -ne 0 ]; then
            sudo -S touch $messagepath
        fi
        ./bash/shared/exist_file.sh $chrootlistpath
        if [ $? -ne 0 ]; then
            sudo -S touch $chrootlistpath
        fi

        ./bash/shared/exist_file.sh $userlistpath
        if [ $? -ne 0 ]; then
            sudo -S touch $userlistpath
        fi
        sudo -S cp $chrootlistpath /etc/.uswg_configs/ftp/
        sudo -S cp $userlistpath /etc/.uswg_configs/ftp/
        sudo -S cp $messagepath /etc/.uswg_configs/ftp/

        shellpath="/etc/shells"
        ./bash/shared/exist_file.sh $shellpath

        if [ $? -ne 0 ]; then
            exit 151
        fi
        
        check=""
        check=`cat $shellpath | grep "^/usr/sbin/nologin$"`
        if [ -z "$check" ]; then
            sudo -S echo "/usr/sbin/nologin" | sudo -S tee -a $shellpath > /dev/null
        fi
        
        if [ ! -d /srv/ftp ]; then
            sudo -S mkdir /srv/ftp
        fi


        if [ ! -d /srv/ftp/anonymous_share ]; then
            sudo -S mkdir /srv/ftp/anonymous_share
        fi

        sudo -S chmod 777 /srv/ftp/anonymous_share
        

        ;;
        
    *)
        exit 155
        ;;
esac