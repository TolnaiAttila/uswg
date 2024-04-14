#!/bin/bash

configpath="/etc/vsftpd.conf"
path="/etc/.uswg_configs/ftp/"
ffile="ftp_fglobal_config.conf"
sfile="ftp_sglobal_config.conf"

sudo -S truncate -s 0 $configpath

sudo -S cat $path$ffile | sudo -S tee -a $configpath > /dev/null
sudo -S cat $path$sfile | sudo -S tee -a $configpath > /dev/null


message="ftp_message"
chroot="ftp_chroot_list"
users="ftp_allowed_users"
path2="/etc/"
sudo -S truncate -s 0 $path2$message
sudo -S truncate -s 0 $path2$chroot
sudo -S truncate -s 0 $path2$users

sudo -S cat $path$message | sudo -S tee -a $path2$message > /dev/null
sudo -S cat $path$chroot | sudo -S tee -a $path2$chroot > /dev/null
sudo -S cat $path$users | sudo -S tee -a $path2$users > /dev/null