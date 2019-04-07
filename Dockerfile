#Download httpd Image
FROM ubuntu

#Verknüpfung des html ordner erstellen
#COPY ./public-html/ /usr/local/apache2/htdocs/

EXPOSE 443
#EXPOSE 80

#SSL für jede Seite aktivieren
RUN apt update && apt install -y apache2 && apt upgrade -y && a2enmod ssl && sed -i '57 i\ServerName localhost' /etc/apache2/apache2.conf && service apache2 restart && mkdir /etc/apache2/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt --batch && sed -i s/'\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem'/'\/etc\/apache2\/ssl\/apache.crt'/g /etc/apache2/sites-available/default-ssl.conf && sed -i s/'\/etc\/ssl\/private\/ssl-cert-snakeoil.key'/'\/etc\/apache2\/ssl\/apache.key'/g /etc/apache2/sites-available/default-ssl.conf && a2ensite default-ssl.conf && service apache2 reload && service apache2 status && touch /etc/apache2/startapache.sh && echo '#!/bin/bash' >> /etc/apache2/startapache.sh && echo "service apache2 restart" >> /etc/apache2/startapache.sh && chmod 700 /etc/apache2/startapache.sh
