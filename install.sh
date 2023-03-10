#!/bin/bash

echo "Instalatie script voor het FYS project"
echo "Updaten van het systeem"

sleep 3


#########################################
#               Updaten                 #
#########################################

#Check als de user die het script runt 0 (root) is zo niet exit het script.
if [[ $EUID == 0 ]]; then
    apt update -qq -y # Update de repositorys naar de laatste versie

    else 
    echo "Draai het script A.U.B als root"
    exit
fi

#########################################
#               User Config             #
#########################################

# Confugration of the user

echo "Het maken van de vereiste users"

username="corendon" 
password="corendon"
sudo useradd -p $(openssl passwd -1 $password) $username
echo "De user $username is aangemaakt"

sleep 10
sudo echo "corendon ALL = ( ALL) PASSWD: ALL" > /etc/sudoers.d/corendon

# disabeling het root account
#sudo passwd -l root

#########################################
#             Apache install            #
#########################################
echo "Apache Install"

#Installeren van bepaalde apache pakketen en dependencies
DEBIAN_FRONTEND=noninteractive apt install -qq -y apache2 libapache2-mod-wsgi-py3 php libapache2-mod-php php-mysql libmariadb3 libmariadb-dev python3-venv build-essential libssl-dev libffi-dev python3-dev

# Copieren van de bestenden
cp fyssite.conf /etc/apache2/sites-available/fyssite.conf
a2dissite 000-default  #het disablen van de defualt site die apache maakt     
a2ensite fyssite    # Het enablen van de site van het project
systemctl restart apache2 # Apache restarten
cp -R fyssite /var/www/ # De website bestanen naar de goede plek zetten

#########################################
#             Apache SSL                #
#########################################
a2enmod ssl
systemctl restart apache2
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt << EOF

`#Country Name (2 letter code) [AU]:` NL
`#State or Province Name (full name) []:` Noord-Holland
`#Locality Name (eg, city) [Default City]:` Amsterdam
`#Organization Name (eg, company) [Default Company Ltd]:` FYS
`#Organizational Unit Name (eg, section) []:`
`#Common Name (eg, your name or your server's hostname) []:` FYS Team C
`#Email Address []:`
EOF

systemctl restart apache2


#########################################
#             IPset permission          #
#########################################
echo "Apache user IPset permission"


echo 'Cmnd_Alias IPSET = /usr/sbin/ipset' | sudo EDITOR='tee -a' visudo
echo 'www-data ALL=(ALL) NOPASSWD: IPSET'  | sudo EDITOR='tee -a' visudo


#########################################
#               MariaDb                 #
#########################################
echo "mariaDB install"
apt install -y -q mariadb-server # mariaDB server installeren.
systemctl start mariadb.service # De server aanzetten.

# Door milldel van EOF geef ik de waarde aan die tijdens de installatie ingeveord moeten worden.

mysql_secure_installation << EOF

`#Enter current password for root (enter for none):`
`#Change the root password? [Y/n]` n
`#Remove anonymous users? [Y/n]` y
`#Disallow root login remotely? [Y/n]` y
`#Remove test database and access to it? [Y/n]` y
`#Reload privilege tables now? [Y/n]` y
EOF

# maakd e database user corendon aan
mariadb -e "GRANT ALL ON *.* TO 'corendon'@'localhost' IDENTIFIED BY 'corendon' WITH GRANT OPTION; FLUSH PRIVILEGES;"
# Maak de database aan met de table en wat data 
mariadb -e "CREATE SCHEMA IF NOT EXISTS Corendon DEFAULT CHARACTER SET utf8; USE Corendon; CREATE TABLE IF NOT EXISTS Corendon.Passagier (
	ticketnummer INT NOT NULL,
	voornaam VARCHAR(30) NOT NULL,
	achternaam VARCHAR(30) NOT NULL,
	PRIMARY KEY (ticketnummer)
);
INSERT INTO Corendon.Passagier (ticketnummer, voornaam, achternaam)
VALUES
	('80438294', 'Rafael', 'Ribbers'),
	('80438295', 'Baban', 'Gurmail'),
	('80438296', 'Hirra', 'Patang'),
	('80438297', 'Max', 'Luiten'),
	('80438298', 'Annas', 'Aznag');"


#########################################
#               Accesss Point           #
#########################################
echo "accesspoint install"
DEBIAN_FRONTEND=noninteractive apt install -y -qq hostapd dnsmasq ifupdown


sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl mask systemd-resolved

cp hosts /etc/
rm /etc/resolv.conf
cp resolv.conf /etc/

systemctl unmask hostapd
systemctl enable hostapd

DEBIAN_FRONTEND=noninteractive apt install -qq -y netfilter-persistent iptables-persistent

cp dhcpcd.conf /etc/
cp routed-ap.conf /etc/sysctl.d/

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

netfilter-persistent save #Save the firewall rules so that it stays persistent after an reboot

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cp dnsmasq.conf /etc/

sudo rfkill unblock wlan

sudo cp hostapd.conf /etc/hostapd/

cp interfaces /etc/network/

sudo apt install ifupdown
sudo systemctl enable networking
sudo systemctl disable systemd-networkd
sudo systemctl restart networking



#########################################
#            	 Firewall		        #
#########################################

echo "Firewall instalation"

apt-get install ipset ipset-persistent netfilter-persistent

ipset create whitelist hash:ip #Create the whitelist

iptables -t nat -I PREROUTING -i wlan0 -m set --match-set whitelist src -j ACCEPT #Checks if ip existst in firewall, when true contiue
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to-destination 10.1.0.1:80 # redirect all tcp on port 80 traffic to the website
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j DNAT --to-destination 10.1.0.1:443 # redirect all tcp port 443 traffic to the website

# Blokeren van bepaalde websites
iptables -A FORWARD -m string --string "klm.nl" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "easyjet.com" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "transavia.com" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "pornhub.com" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "xhamster.com" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "youporn.com" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "xvideo.com" --algo bm --from 1 --to 600 -j REJECT
iptables -A FORWARD -m string --string "xnxx.com" --algo bm --from 1 --to 600 -j REJECT
netfilter-persistent save #Save the firewall rules so that it stays persistent after an reboot

#########################################
#               Pyton Venv              #
#########################################
echo "Python venv install"
cd /var/www/fyssite

sudo python3 -m venv venv
. venv/bin/activate
pip install mariadb
pip install flask
cd venv/bin/
wget https://raw.githubusercontent.com/naztronaut/RaspberryPi-RGBW-Control/master/utils/activate_this.py  # Download an actiavte this file for the vnenv so that wsgi can strart it

systemctl restart apache2



#POST REBOOT COMMANDS
# cd FYS
# sudo rm /etc/resolv.conf
# sudo cp resolv.conf /etc/
# sudo sytemctl restart dnsmasq
# sudo apt upgrade -y
#--------------------------



# sudo visudo

# Cmnd alias specification
#   Cmnd_Alias IPSET = /usr/sbin/ipset
# User privilege specification
#   root    ALL=(ALL:ALL) ALL
#   www-data ALL=(ALL) NOPASSWD: IPSET
# Members of the admin group may gain root privileges
#   %admin ALL=(ALL) ALL
