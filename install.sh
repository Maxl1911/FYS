#!/bin/bash

echo "Instalatie script voor het FYS project"
echo "Updaten van het systeem"

sleep 3


#########################################
#               Updaten                 #
#########################################


if (id -u == 0)
    then 
    apt update -y # Update the repositorys to the latest versions

    else 
    echo "Draai het script A.U.B als root"
fi
#########################################
#               User Config             #
#########################################

# Confugration of the user

echo "Het maken van de vereiste users"

username = corendon 
password = corendon
echo $username:$password | chpasswd
echo "De user $username is aangemaakt"

sleep 10

# disabeling the root account
sudo passwd -l root

#########################################
#               Apache install          #
#########################################


#Installeren van bepaalde apache pakketen
apt -y install apache2 libapache2-mod-wsgi-py3 php libapache2-mod-php php-mysql

# Copieren van de bestenden
cp fyssite.conf /etc/apache2/sites-available/fyssite.conf
a2ensite fyssite
systemctl restart apache2
cp fyssite /var/www/

#########################################
#               Pyton Venv              #
#########################################

cd /var/www/fyssite

apt install python3-venv
sudo python3 -m venv venv
. venv/bin/activate
pip install flask
cd venv/bin/
wget https://raw.githubusercontent.com/naztronaut/RaspberryPi-RGBW-Control/master/utils/activate_this.py

systemctl restart apache2



