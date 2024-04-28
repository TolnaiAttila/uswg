#!/bin/bash
pathfglobal="/etc/.uswg_configs/ssh/ssh_fglobal.conf"
pathsglobal="/etc/.uswg_configs/ssh/ssh_sglobal.conf"
pathconfig="/etc/ssh/sshd_config"



./bash/shared/exist_file.sh $pathfglobal
if [ $? -ne 0 ]; then
    exit 151
fi


./bash/shared/exist_file.sh $pathsglobal
if [ $? -ne 0 ]; then
    exit 151
fi


sudo -S truncate -s 0 $pathconfig

sudo -S cat $pathfglobal | sudo -S tee -a $pathconfig > /dev/null
sudo -S cat $pathsglobal | sudo -S tee -a $pathconfig > /dev/null
