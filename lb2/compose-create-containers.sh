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

#Create Network
docker network create --driver bridge $net

#Make Dir which contains the Dockerfile (if it doesn't allready exist)
if [ ! -d "$DIRECTORY" ]; then
  mkdir httpd
else
  rm -r httpd
  mkdir httpd
fi

cp docker-compose.yml httpd
cp Dockerfile httpd
cd httpd


##############Creates Apache Container with Docker-compose###################
docker-compose up -d
#or -->
#docker-compose up > compose-output.log 2>&1 &



##############Create OpenVPN Container (without compose)#####################
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
docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn initopenvpn -u udp://openvpn-server
docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn initpki
docker run --name running-openvpn -v $OVPN_DATA:/etc/openvpn -v /etc/localtime:/etc/localtime:ro -d -p 1194:1194/udp --cap-add=NET_ADMIN martin/openvpn
docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn easyrsa build-client-full client
docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn getclient client > /home/$USER/Containers/openvpn/client.ovpn

#Connect openvpn container with opache-net
docker network connect $net running-openvpn

ip1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' running-apache-ssl)
ip2=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" running-openvpn)
ip3=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' running-openvpn)
ip4=$(echo $ip3 | cut -c 11-)

#Get the public IP Address of the System
ifconfig -a
read -p "Please enter the TBZ interface IP-Address: " ip5

#Change the Client config File (remote-IP etc.)
sed -i s/verify-x509-name/'#verify-x509-name'/g /home/$USER/Containers/openvpn/client.ovpn
sed -i s/"remote openvpn-server"/"remote $ip5"/g /home/$USER/Containers/openvpn/client.ovpn
sed -i '18 i\auth-nocache' /home/$USER/Containers/openvpn/client.ovpn

#Show some infos about the containers
echo ""
echo ""
echo "**************************************************************"
echo "PROCESS COMPLETED!"
echo "**************************************************************"
echo ""
echo "**************************************************************"
echo "IP-Address of the Apache Container:	$ip1"
echo "IP-Address of the OpenVPN Container:	$ip4, $ip2"
echo "**************************************************************"
