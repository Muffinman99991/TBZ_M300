#!/bin/bash
##################################
#Autor: Marvin Haimoff  	 #
#Datum: April 2019               #
#Im Rahmen des Modul 300 der TBZ #
##################################

#Create Bridge Network between the two Containers
docker network create opache-net

#Make Dir which contains the Dockerfile
mkdir httpd
cd
cp Dockerfile Containers/httpd
cd Containers/httpd

#Create Image
sudo docker build -t apache-ssl .
sudo docker run -dit --name running-apache-ssl -p 443:443/tcp apache-ssl

sudo docker exec -it running-apache-ssl /etc/apache2/startapache.sh

#Connect httpd to a bridged network
docker network connect opache-net running-apache-ssl


#####################CREATE OPENVPN#########################
cd ..
mkdir openvpn

export OVPN_DATA=openvpn_volume
docker volume create --name $OVPN_DATA

docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn initopenvpn -u udp://172.17.0.3
docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn initpki
docker run --name openvpn -v $OVPN_DATA:/etc/openvpn -v /etc/localtime:/etc/localtime:ro -d -p 1194:1194/udp --cap-add=NET_ADMIN martin/openvpn
docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn easyrsa build-client-full client nopass
docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn getclient client > openvpn/client.ovpn

docker network connect opache-net openvpn

sed -i s/verify-x509-name/'#verify-x509-name'/g openvpn/client.ovpn
sed -i s/'remote 172.17.0.3'/'remote 192.168.193.13'/g openvpn/client.ovpn
sed -i '18 i\auth-nocache' openvpn/client.ovpn


