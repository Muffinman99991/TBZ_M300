#!/bin/bash
##################################
#Autor: Marvin Haimoff  	 #
#Datum: Maerz 2019               #
#Im Rahmen des Modul 300 der TBZ #
##################################




##################VORBEREITUNGEN & INSTALLIEREN VON PAKETEN#####################
#Wecheln zum Root User. Somit werden alle der folgenden Befehle als root ausgefuehrt
sudo su

#Root Passwort setzen und SSH-Login als Root erlauben. Ohne diesen Schritt ist es zu einem spaeteren Zeitpunkt nicht moeglich,
#per scp die Certificate vom Server herunterzuladen
echo "root:Miau123"|chpasswd
sed -i s/without-password/yes/g /etc/ssh/sshd_config
service ssh reload

#Die Repos/Paketquellen werden neu eingetragen, zudem wird OpenVPN, Easy-RSA und Apache installiert
apt update
apt install -y openvpn easy-rsa
apt install -y apache2

#Alle Programme (sowie auch OpenVPN und RSA) auf den aktuellsten Stand bringen
apt upgrade -y


#Das example Serverconfig File wird in den Ordner /etc/openvpn kopiert.
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gunzip /etc/openvpn/server.conf.gz
cp -r /usr/share/easy-rsa /etc/openvpn/easy-rsa2




##################CA & ZERTIFIKATE ERSTELLEN#####################
cd /etc/openvpn/easy-rsa2/
cp openssl-1.0.0.cnf openssl.cnf
mkdir keys

sed -i s/'export KEY_COUNTRY="US"'/'export KEY_COUNTRY="CH"'/g /etc/openvpn/easy-rsa2/vars
sed -i s/'export KEY_PROVINCE="CA"'/'export KEY_PROVINCE="ZH"'/g /etc/openvpn/easy-rsa2/vars
sed -i s/'export KEY_CITY="SanFrancisco"'/'export KEY_CITY="Zuerich"'/g /etc/openvpn/easy-rsa2/vars
sed -i s/'export KEY_ORG="Fort-Funston"'/'export KEY_ORG="TBZ"'/g /etc/openvpn/easy-rsa2/vars
sed -i s/'export KEY_EMAIL="me@myhost.mydomain"'/'export KEY_EMAIL="marvin.haimoff@edu.tbz.ch"'/g /etc/openvpn/easy-rsa2/vars
sed -i s/'export KEY_OU="MyOrganizationalUnit"'/'export KEY_OU="M300"'/g /etc/openvpn/easy-rsa2/vars


source ./vars
#Folgende vier Befehle lassen sich ohne sudo Paramater nicht starten, auch wenn man schon als Root angemeldet ist
sudo -E ./clean-all
sudo -E ./build-ca --batch
sudo -E ./build-key-server --batch server
sudo -E ./build-key --batch client

#Das Erstellen des Diffie-Hellman Schluessels dauert ein wenig laenger
sudo -E ./build-dh

cd /etc/openvpn/server/
openvpn --genkey --secret ta.key

#Alle sobene erstellten Zertifikate und deren Schluessel, werden in den Ordner /etc/openvpn/ kopiert. Somit muss das OpenVPN
#Config File nicht mehr angepasst werden und die Zertifikate koennen anschliessend alle von diesem Ordner zum Client kopiert werden
cp /etc/openvpn/easy-rsa2/keys/ca.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa2/keys/server.crt /etc/openvpn/server/
cp /etc/openvpn/easy-rsa2/keys/server.key /etc/openvpn/server/
cp /etc/openvpn/easy-rsa2/keys/client.key /etc/openvpn/client/
cp /etc/openvpn/easy-rsa2/keys/client.crt /etc/openvpn/client/
cp /etc/openvpn/easy-rsa2/keys/dh2048.pem /etc/openvpn/

#Im Server-Conf File Compression aktivieren und tls-Authentifizierung deaktivieren
sed -i s/';comp-lzo'/comp-lzo/g /etc/openvpn/server.conf
sed -i s/';user nobody'/'user nobody'/g /etc/openvpn/server.conf
sed -i s/';group nogroup'/'group nogroup'/g /etc/openvpn/server.conf
sed -i s/'tls-auth ta.key'/'tls-auth \/etc\/openvpn\/server\/ta.key'/g /etc/openvpn/server.conf
sed -i '245 i\key-direction 0' /etc/openvpn/server.conf
sed -i s/'cert server.crt'/'cert \/etc\/openvpn\/server\/server.crt'/g /etc/openvpn/server.conf
sed -i s/'key server.key'/'key \/etc\/openvpn\/server\/server.key '/g /etc/openvpn/server.conf
sed -i '253 i\auth SHA512' /etc/openvpn/server.conf
sed -i s/'cipher AES-256-CBC'/';cipher AES-256-CBC'/g /etc/openvpn/server.conf




##################NETZWERK ANPASSUNGEN#####################
#IP forwarding aktivieren
sed -i s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g /etc/sysctl.conf

#UFW Firewall Regeln, welche geladen werden noch bevor die konventionell Regeln geladen werden. Diese Regeln sind notwendig,
#da der Adapter bzw. die Schnittstelle zwischen Host und der VM auf NAT gestellt ist (eth1 durch gewuenschte Schnittstelle ersetzen).
sed -i '10 i\*nat' /etc/ufw/before.rules
sed -i '11 i\:POSTROUTING ACCEPT [0:0]' /etc/ufw/before.rules
sed -i '12 i\-A POSTROUTING -s 10.8.0.0/8 -o eth1 -j MASQUERADE' /etc/ufw/before.rules
sed -i '13 i\COMMIT' /etc/ufw/before.rules

sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw

#konventionell Regeln erstellen
ufw allow 1194/udp
ufw allow OpenSSH

#Firewall neu laden
ufw disable
ufw --force enable

#IP-Tables fuer VPN Tunnel definieren. Ohne diesen Schritt kann spaeter nicht per 10.8.0.1 auf den Webserver zugegriffen werden
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT

#IP-Tables speichern, sodass diese auch nach einem Neustart noch vorhanden sind.
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt install -y iptables-persistent



##################VPN SERVER STARTEN#####################
service openvpn restart
systemctl start openvpn@server

#Bei Fehlermedlung Status checken:
#systemctl status openvpn@server


##################APACHE SSL KONFIGURIEREN##############################
a2enmod ssl
service apache2 restart

mkdir /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt --batch

sed -i s/'\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem'/'\/etc\/apache2\/ssl\/apache.crt'/g /etc/apache2/sites-available/default-ssl.conf
sed -i s/'\/etc\/ssl\/private\/ssl-cert-snakeoil.key'/'\/etc\/apache2\/ssl\/apache.key'/g /etc/apache2/sites-available/default-ssl.conf

a2ensite default-ssl.conf

service apache2 restart



#####BERECHTIGUNGEN VON FILES/ORDNER AENDERN#############
#User opache-admin wird hinzugefügt
useradd -M opache-admin

#opache User PW wird gesetzt
echo "opache-admin:Miau123$"|chpasswd

chown opache-admin /etc/openvpn/server
chmod 700 /etc/openvpn/server

chown opache-admin /etc/openvpn/client
chmod 700 /etc/openvpn/client

chown opache-admin /etc/openvpn/easy-rsa2
chmod 700 /etc/openvpn/easy-rsa2

chown opache-admin /etc/openvpn/ca.crt
chmod 700 /etc/openvpn/ca.crt

chown opache-admin /etc/openvpn/dh2048.pem
chmod 700 /etc/openvpn/dh2048.pem


chown opache-admin /etc/apache2/ssl
chmod 700 /etc/apache2/ssl




#Viel Spass :D
