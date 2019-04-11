#!/bin/bash
##################################
#Autor: Marvin Haimoff  	 #
#Datum: April 2019               #
#Im Rahmen des Modul 300 der TBZ #
##################################

#Create Variables
DIRECTORY=/home/$USER/Containers/httpd
DIRECTORY2=/home/$USER/Containers/openvpn

net=opache-net

#Create Bridge Network between the two Containers
docker network create $net

#Make Dir which contains the Dockerfile (if it doesn't allready exist)
if [ ! -d "$DIRECTORY" ]; then
  mkdir httpd
else
  rm -r httpd
  mkdir httpd
fi

cp /home/$USER/Containers/Dockerfile /home/$USER/Containers/httpd
cd /home/$USER/Containers/httpd

#Create Image and run it
docker build -t apache-ssl .
docker run -dit --name running-apache-ssl -p 443:443/tcp apache-ssl

#Start the Apache2 service
docker exec -it running-apache-ssl /etc/apache2/startapache.sh

#save the IP-Adress of the apache Container in a variable
ip1=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" running-apache-ssl)

#Connect httpd to a bridged network
docker network connect $net running-apache-ssl




#####################CREATE OPENVPN#########################
cd /home/$USER/Containers

#Make Dir for openvpn (if it doesn't allready exist)
if [ ! -d "$DIRECTORY2" ]; then
  mkdir openvpn
else
  rm -r openvpn
  mkdir openvpn
fi

#Create Volume for OpenVPN Container
export OVPN_DATA=openvpn_volume
docker volume create --name $OVPN_DATA

#Create PKI and the container + generate the client config
docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn initopenvpn -u udp://172.17.0.3
docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn initpki
docker run --name running-openvpn -v $OVPN_DATA:/etc/openvpn -v /etc/localtime:/etc/localtime:ro -d -p 1194:1194/udp --cap-add=NET_ADMIN martin/openvpn
docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn easyrsa build-client-full client
docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn getclient client > /home/$USER/Containers/openvpn/client.ovpn

#Connect httpd to a bridged network
docker network connect $net running-openvpn

#save the IP-Adress of the openvpn Container in a variable
ip2=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" running-openvpn)

#Get the public IP Address of the System
ifconfig -a
read -p "Please enter the TBZ interface IP-Address: " ip3

#Change the Client config File (remote-IP etc.)
sed -i s/verify-x509-name/'#verify-x509-name'/g /home/$USER/Containers/openvpn/client.ovpn
sed -i s/"remote $ip2"/"remote $ip3"/g /home/$USER/Containers/openvpn/client.ovpn
sed -i '18 i\auth-nocache' /home/$USER/Containers/openvpn/client.ovpn

#Show some infos about the containers
echo ""
echo ""
echo "***********************************************"
echo "PROCESS COMPLETED!"
echo "***********************************************"
echo ""
echo "***********************************************"
echo "IP-Address of the Apache Container: $ip1"
echo "IP-Address of the OpenVPN Container: $ip2"
echo "***********************************************"
