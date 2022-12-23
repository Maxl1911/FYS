#!/bin/bash

echo "Instalatie script voor het FYS project"
echo "Updaten van het systeem"

sleep 3


#########################################
#               Updaten                 #
#########################################


if [id -u == 0]
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

$username = corendon 
$password = corendon
echo $username:$password | chpasswd
echo "De user $username is aangemaakt"

sleep 10

# disabeling the root account
sudo passwd -l root

#########################################
#               Apache install          #
#########################################


#Installeren van bepaalde apache pakketen
apt -y install apache2 libapache2-mod-wsgi-py3 php libapache2-mod-php php-mysql libmariadb3 libmariadb-dev python3-venv

# Copieren van de bestenden
cp fyssite.conf /etc/apache2/sites-available/fyssite.conf
a2dissite 000-default
a2ensite fyssite
systemctl restart apache2
cp -R fyssite /var/www/


#########################################
#               MariaDb                 #
#########################################

apt -y install mariadb-server
systemctl start mariadb.service
echo "N N N y y y y" | mysql_secure_installation


mariadb -e "GRANT ALL ON *.* TO 'corendon'@'localhost' IDENTIFIED BY 'corendon' WITH GRANT OPTION; FLUSH PRIVILEGES;"
#########################################
#               Pyton Venv              #
#########################################

cd /var/www/fyssite

python3-venv
sudo python3 -m venv venv
. venv/bin/activate
pip install mariadb
pip install flask
cd venv/bin/
wget https://raw.githubusercontent.com/naztronaut/RaspberryPi-RGBW-Control/master/utils/activate_this.py

systemctl restart apache2



