#!/bin/bash

clear

echo "██╗░░░██╗███████╗██╗░░░░██╗░██████╗░░░░░░"
echo "██║░░░██║██╔════╝██║░░░░██║██╔════╝░░░░░░"
echo "██║░░░██║███████╗██║░█╗░██║██║░░███╗░░░░░"
echo "██║░░░██║╚════██║██║███╗██║██║░░░██║░░░░░"
echo "╚██████╔╝███████║╚███╔███╔╝╚██████╔╝░░░░░"
echo "░╚═════╝░╚══════╝░╚══╝╚══╝░░╚═════╝░░░░░░"
echo "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
echo "██████╗░░█████╗░██████╗░████████╗██████╗░"
echo "██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝╚════██╗"
echo "██████╔╝███████║██████╔╝░░░██║░░░░█████╔╝"
echo "██╔═══╝░██╔══██║██╔══██╗░░░██║░░░██╔═══╝░"
echo "██║░░░░░██║░░██║██║░░██║░░░██║░░░███████╗"
echo "╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝"


echo ""
echo ""
echo ""

sudo apt update
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install sqlite3 -y
sudo apt install python3-venv -y

python3 -m venv uswgvenv
source uswgvenv/bin/activate
pip3 install wheel==0.42.0
pip3 install -r requirements.txt

deactivate

sudo mkdir /etc/.uswg_configs

sudo cp uswg.service /etc/systemd/system/
sudo cp uswglog.conf /etc/rsyslog.d/
sudo touch /var/log/uswg.log
sudo chown syslog:adm /var/log/uswg.log
sudo systemctl restart rsyslog
sudo systemctl daemon-reload
sudo systemctl enable uswg
sudo systemctl start uswg
sudo apt install nginx -y
sudo cp uswg.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/uswg.conf /etc/nginx/sites-enabled/

linenumber=`grep -n "^user[[:space:]].*;$" /etc/nginx/nginx.conf | cut -d':' -f1`
newcontent="user uswguser sudo;"
sudo -S sed -i "${linenumber}s/.*/${newcontent}/" "/etc/nginx/nginx.conf"
sudo systemctl restart nginx



read -p "Enter server IP or domain name: " input
linenumber=`grep -n "server_name[[:space:]].*;$" /etc/nginx/sites-available/uswg.conf | cut -d':' -f1`
newcontent="	server_name $input;"
sudo -S sed -i "${linenumber}s/.*/${newcontent}/" "/etc/nginx/sites-available/uswg.conf"



touch /home/uswguser/uswg/uswg.db
touch /home/uswguser/uswg/.env

secret=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo echo "SECRET_KEY = $secret" | sudo tee -a > /home/uswguser/uswg/.env
chown uswguser:sudo /home/uswguser/uswg/.env
source uswgvenv/bin/activate
python3 /home/uswguser/uswg/db_create.py

echo "-----------------"
echo "Add user to website."
echo "-----------------"
python3 /home/uswguser/uswg/create_user.py

deactivate
sudo systemctl restart uswg
sudo systemctl restart nginx
rm /home/uswguser/requirements.txt
rm /home/uswguser/uswg.conf
rm /home/uswguser/uswg.service
rm /home/uswguser/uswglog.conf

sudo usermod --shell /sbin/nologin uswguser

