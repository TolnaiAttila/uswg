#!/bin/bash
OLDIFS=$IFS
configpath="/etc/samba/smb.conf"
path="/etc/.uswg_configs/samba/"
fglobal="samba_fglobal_config.conf"
sglobal="samba_sglobal_config.conf"

./bash/shared/exist_file.sh $path$fglobal
file1=$?
./bash/shared/exist_file.sh $path$sglobal
file2=$?
if [ $file1 -ne 0 ] || [ $file2 -ne 0 ]; then
    exit 151
fi
sudo -S truncate -s 0 $configpath
IFS=$'\n'
for i in `cat $path$fglobal`
    do
        tmp=`echo $i | grep -v "^#.\+$"`
        if [ ! -z "$tmp" ]; then
            sudo -S echo $i | sudo -S tee -a $configpath > /dev/null
        fi
    done

sudo -S cat $path$sglobal | sudo -S tee -a $configpath > /dev/null

for i in `ls $path | grep "^samba_.\+_share.conf$" | grep -v "^samba_group_.\+_share.conf$"`
    do
        for x in `cat $path$i`
            do
                tmp=`echo $x | grep -v "^#.\+$"`
                if [ ! -z "$tmp" ]; then
                    sudo -S echo $x | sudo -S tee -a $configpath > /dev/null
                fi
            done
    done

check=""

for i in `ls $path | grep "^samba_group_.\+_share.conf$"`
    do
        for x in `cat $path$i`
            do
                check=""
                tmp=`echo $x | grep -v "^#.\+$"`
                if [ ! -z "$tmp" ]; then
                    check=`echo $x | grep "^\(\(valid\)\|\(invalid\)\)[[:space:]]users[[:space:]]=[[:space:]]@.\+$"`
                    if [ ! -z "$check" ]; then
                        groupname=`echo $x | cut -d'@' -f 2`
                        filename="samba_list_${groupname}.conf"
                        ./bash/shared/exist_file.sh $path$filename
                        if [ $? -ne 0 ]; then
                            exit 151
                        fi
                        
                        lineend=`cat $path$filename | tr '\n' ','`
                        linestart=`echo $x | cut -d'=' -f 1`
                        check=""
                        check=`echo $lineend | grep "^.\+,$"`
                        if [ ! -z "$check" ]; then
                            lineend=`echo $lineend | sed 's/.$//'`
                        fi

                        fullline="${linestart}= ${lineend}"
                        sudo -S echo $fullline | sudo -S tee -a $configpath > /dev/null
                    else
                        sudo -S echo $x | sudo -S tee -a $configpath > /dev/null
                    fi
                    
                    
                fi
            done
    done


IFS=$OLDIFS