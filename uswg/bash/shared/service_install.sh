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

        linenumber=`sudo -S grep -n "\[.\+\]" $tmppath | grep -v "\[global\]" | head -n 1 | cut -d':' -f 1`
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

    network-adapter)
        path="/etc/.uswg_configs/adapter/"
        pathorig="/etc/.uswg_configs/adapter/original/"
        pathglobal="/etc/.uswg_configs/adapter/adapter_global.conf"
        pathnetplan="/etc/netplan/network_adapter.yaml"
        pathnginx="/etc/.uswg_configs/adapter/original_nginx/"
        
        ip=$2
        gateway=$3
        dns=$4
        a=$5
        nginx=$6

        if [ ! `echo "$ip" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{2\}$"` ]; then
            exit 155
        fi
        
        if [ ! `echo "$gateway" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"` ]; then
            exit 155
        fi

        if [ ! `echo "$dns" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"` ]; then
            exit 155
        fi
        
        if [ ! `ip address | grep "^[0-9]\+:[[:space:]].*$" | cut -d' ' -f2 | tr -d ':' | grep -v "^lo$" | grep "^${a}$"` ]; then
            exit 155
        fi

        if [ -z "$nginx" ]; then
            exit 155
        else
            if [ "$nginx" != "yes" ]; then
                if [ "$nginx" != "no" ]; then
                    exit 155
                fi
            fi
        fi

        networkdstatus=`systemctl is-active systemd-networkd`

        if [ "$networkdstatus" != "active" ]; then
            if [ "$networkdstatus" == "inactive" ]; then
                sudo -S systemctl restart systemd-networkd
            else
                exit 156
            fi
        fi

        networkdstatus=""
        networkdstatus=`systemctl is-active systemd-networkd`
        if [ "$networkdstatus" != "active" ]; then
            exit 164
        fi

        if [ ! -d $path ]; then
            sudo -S mkdir $path
        fi
        if [ ! -d $pathorig ]; then
            sudo -S mkdir $pathorig
        fi
        
        
        if [ `ls /etc/netplan | grep ".\+\.yaml$" | wc -l` -gt 0 ]; then
            sudo -S cp -r /etc/netplan/* $pathorig
        fi


        
        sudo -S touch $pathglobal
        sudo -S echo "network:" | sudo -S tee -a $pathglobal > /dev/null
        sudo -S echo " version: 2" | sudo -S tee -a $pathglobal > /dev/null
        sudo -S echo " renderer: networkd" | sudo -S tee -a $pathglobal > /dev/null
        sudo -S echo " ethernets:" | sudo -S tee -a $pathglobal > /dev/null

        sudo -S rm -r -d /etc/netplan/*

        sudo -S touch $pathnetplan
        sudo -S chmod 644 $pathnetplan
        


        sudo -S mkdir $pathnginx
        sudo -S cp /etc/nginx/sites-available/uswg.conf $pathnginx

        if [ "$nginx" == "yes"  ]; then
            ip=`echo "$ip" | cut -d '/' -f 1`
            linenumber=`sudo -S grep -n "server_name[[:space:]].*;$" /etc/nginx/sites-available/uswg.conf | cut -d':' -f1`
            newcontent="	server_name $ip;"
            sudo -S sed -i "${linenumber}s/.*/${newcontent}/" "/etc/nginx/sites-available/uswg.conf"
            sudo -S nginx -s reload
        fi
        ;;

    openssh-server)
        sudo -S apt update
        sudo -S apt install openssh-server -y
        
        if [ $? -ne 0 ]; then
            exit 153
        fi



        path="/etc/.uswg_configs/ssh/"
        pathconfig="/etc/ssh/sshd_config"
        pathfglobal="/etc/.uswg_configs/ssh/ssh_fglobal.conf"
        pathsglobal="/etc/.uswg_configs/ssh/ssh_sglobal.conf"

        sudo -S mkdir $path

        ./bash/shared/exist_file.sh $pathconfig
        if [ $? -ne 0 ]; then
            exit 151
        fi

        sudo -S touch $pathfglobal

        sudo -S cat $pathconfig | grep -v "\(^#.*$\)\|\(^$\)" | sudo -S tee -a $pathfglobal > /dev/null
        sudo -S echo "AddressFamily any" | sudo -S tee -a $pathfglobal > /dev/null
        
        sudo -S touch $pathsglobal
        
        sudo -S echo "Port 22" | sudo -S tee -a $pathsglobal > /dev/null
        sudo -S echo "ListenAddress 0.0.0.0" | sudo -S tee -a $pathsglobal > /dev/null

        sudo -S truncate -s 0 $pathconfig

        sudo -S cat $pathfglobal | sudo -S tee -a $pathconfig > /dev/null
        sudo -S cat $pathsglobal | sudo -S tee -a $pathconfig > /dev/null

        sudo -S systemctl enable --now ssh
        sudo systemctl restart ssh

        ;;
    
    ufw)
        sudo -S apt update
        sudo -S apt install ufw -y
        
        if [ $? -ne 0 ]; then
            exit 153
        fi

        path="/etc/.uswg_configs/ufw/"
        pathapp="/etc/ufw/applications.d/uswg"
        sudo -S mkdir $path


        ./bash/shared/exist_file.sh $pathapp
        if [ $? -ne 0 ]; then
            sudo -S touch $pathapp

            sudo -S echo "[uswgSamba]" | sudo -S tee -a $pathapp
            sudo -S echo "title=USWG Samba service" | sudo -S tee -a $pathapp
            sudo -S echo "description=Allow Samba service over USWG" | sudo -S tee -a $pathapp
            sudo -S echo "ports=137,138/udp|139,445/tcp" | sudo -S tee -a $pathapp
            sudo -S echo "" | sudo -S tee -a $pathapp

            sudo -S echo "[uswgSSH]" | sudo -S tee -a $pathapp
            sudo -S echo "title=USWG SSH service" | sudo -S tee -a $pathapp
            sudo -S echo "description=Allow SSH service over USWG" | sudo -S tee -a $pathapp
            sudo -S echo "ports=22/tcp" | sudo -S tee -a $pathapp
            sudo -S echo "" | sudo -S tee -a $pathapp

            sudo -S echo "[uswgFTP]" | sudo -S tee -a $pathapp
            sudo -S echo "title=USWG FTP service" | sudo -S tee -a $pathapp
            sudo -S echo "description=Allow FTP service over USWG" | sudo -S tee -a $pathapp
            sudo -S echo "ports=20,21,990,40000:50000/tcp" | sudo -S tee -a $pathapp
            sudo -S echo "" | sudo -S tee -a $pathapp

            sudo -S echo "[uswgNFS]" | sudo -S tee -a $pathapp
            sudo -S echo "title=USWG NFS service" | sudo -S tee -a $pathapp
            sudo -S echo "description=Allow NFS service over USWG" | sudo -S tee -a $pathapp
            sudo -S echo "ports=2049/tcp|2049/udp" | sudo -S tee -a $pathapp
            sudo -S echo "" | sudo -S tee -a $pathapp
            
            sudo -S echo "[uswgDHCP]" | sudo -S tee -a $pathapp
            sudo -S echo "title=USWG DHCP service" | sudo -S tee -a $pathapp
            sudo -S echo "description=Allow DHCP service over USWG" | sudo -S tee -a $pathapp
            sudo -S echo "ports=67/udp" | sudo -S tee -a $pathapp
            sudo -S echo "" | sudo -S tee -a $pathapp
            
            sudo -S echo "[uswgFull]" | sudo -S tee -a $pathapp
            sudo -S echo "title=USWG all services" | sudo -S tee -a $pathapp
            sudo -S echo "description=Allow all services over USWG" | sudo -S tee -a $pathapp
            sudo -S echo "ports=139,445,22,20,21,990,2049,40000:50000/tcp|2049,67,137,138/udp" | sudo -S tee -a $pathapp

        fi
        sudo -S ufw default deny incoming
        sudo -S ufw default allow outgoing
        sudo -S ufw allow 'Nginx full'
        sudo -S ufw enable 
        sudo -S ufw reload
        ;;

    *)
        exit 155
        ;;
esac