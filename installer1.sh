#!/bin/bash

clear

echo "██╗░░░██╗███████╗██╗░░░░██╗░██████╗░░"
echo "██║░░░██║██╔════╝██║░░░░██║██╔════╝░░"
echo "██║░░░██║███████╗██║░█╗░██║██║░░███╗░"
echo "██║░░░██║╚════██║██║███╗██║██║░░░██║░"
echo "╚██████╔╝███████║╚███╔███╔╝╚██████╔╝░"
echo "░╚═════╝░╚══════╝░╚══╝╚══╝░░╚═════╝░░"
echo "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
echo "██████╗░░█████╗░██████╗░████████╗░██╗"
echo "██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝███║"
echo "██████╔╝███████║██████╔╝░░░██║░░░╚██║"
echo "██╔═══╝░██╔══██║██╔══██╗░░░██║░░░░██║"
echo "██║░░░░░██║░░██║██║░░██║░░░██║░░░░██║"
echo "╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░░╚═╝"

echo ""
echo ""
echo ""

sudo useradd uswguser -c "uswguser" -g sudo -m -d /home/uswguser -s /bin/bash
echo "-----------------"
echo "uswguser password"
echo "-----------------"
sudo passwd uswguser

sudo echo "uswguser ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

sudo cp -r uswg/ /home/uswguser/
sudo cp requirements.txt /home/uswguser
sudo cp uswg.conf /home/uswguser
sudo cp uswg.service /home/uswguser
sudo cp installer2.sh /home/uswguser
sudo cp uswglog.conf /home/uswguser
sudo cp uswg /home/uswguser

sudo chown -R uswguser:sudo /home/uswguser
sudo chmod -R 770 /home/uswguser/

