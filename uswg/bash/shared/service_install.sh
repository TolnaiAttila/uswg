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
        configpath="/etc/.uswg_configs/ftp/ftp_base_config.conf"
        sudo -S mkdir /etc/.uswg_configs/ftp

        ./bash/shared/exist_file.sh $path
        if [ $? -ne 0 ]; then
            exit 151
        fi
        sudo -S cat $path | grep -v "^\(\(#\)\|\($\)\)" | sudo -S tee -a $configpath > /dev/null
        
        sudo -S truncate -s 0 $path

        sudo -S cat $configpath | sudo -S tee -a $path > /dev/null

        ;;
        
    *)
        exit 155
        ;;
esac