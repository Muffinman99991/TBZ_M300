#!/bin/bash
##################################
#Autor: Marvin Haimoff  	 #
#Datum: M�rz 2019                #
#Im Rahmen des Modul 300 der TBZ #
##################################




##################VORBEREITUNGEN & INSTALLIEREN VON PAKETEN#####################
#Wecheln zum Root User. Somit werden alle der folgenden Befehle als root ausgef�hrt
sudo su

#Root Passwort setzen und SSH-Login als Root erlauben. Ohne diesen Schritt ist es zu einem sp�teren Zeitpunkt nicht m�glich,
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
source ./vars
#Folgende vier Befehle lassen sich ohne sudo Paramater nicht starten, auch wenn man schon als Root angemeldet ist
sudo -E ./clean-all
sudo -E ./build-ca --batch
sudo -E ./build-key-server --batch server
sudo -E ./build-key --batch client

#Das Erstellen des Diffie-Hellman Schl�ssels dauert ein wenig l�nger
sudo -E ./build-dh

#Alle sobene erstellten Zertifikate und deren Schl�ssel, werden in den Ordner /etc/openvpn/ kopiert. Somit muss das OpenVPN
#Config File nicht mehr angepasst werden und die Zertifikate k�nnen anschliessend alle von diesem Ordner zum Client kopiert werden
cp /etc/openvpn/easy-rsa2/keys/ca.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa2/keys/server.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa2/keys/server.key /etc/openvpn/
cp /etc/openvpn/easy-rsa2/keys/client.key /etc/openvpn/
cp /etc/openvpn/easy-rsa2/keys/client.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa2/keys/dh2048.pem /etc/openvpn/

#Im Server-Conf File Compression aktivieren und tls-Authentifizierung deaktivieren
sed -i s/';comp-lzo'/comp-lzo/g /etc/openvpn/server.conf
sed -i s/'tls-auth ta.key'/';tls-auth ta.key'/g /etc/openvpn/server.conf
sed -i '253 i\auth SHA256' /etc/openvpn/server.conf




##################NETZWERK ANPASSUNGEN#####################
#IP forwarding aktivieren
sed -i s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g /etc/sysctl.conf

#UFW Firewall Regeln, welche geladen werden noch bevor die konventionell Regeln geladen werden. Diese Regeln sind notwendig,
#da der Adapter bzw. die Schnittstelle zwischen Host und der VM auf NAT gestellt ist (eth1 durch gew�nschte Schnittstelle ersetzen).
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

#IP-Tables f�r VPN Tunnel definieren. Ohne diesen Schritt kann sp�ter nicht per 10.8.0.1 auf den Webserver zugegriffen werden
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT

#IP-Tables speichern, sodass diese auch nach einem Neustart noch vorhanden sind.
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt install -y iptables-persistent



##################VPN SERVER STARTEN#####################
systemctl start openvpn@server

#Bei Fehlermedlung Status checken:
#systemctl status openvpn@server








1.     https://community.openvpn.net/openvpn/wiki/255-qconnection-initiated-with-xxxxq-but-i-cannot-ping-the-server-through-the-vpn

2.     https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-18-04

3.     https://askubuntu.com/questions/117155/do-i-need-to-restore-iptable-rules-everytime-on-boot

###########################################################
lsb_release -a
do-release-upgrade


