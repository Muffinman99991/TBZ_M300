TBZ M300 LB2 (Dokumentation)
===============

In den folgenden Zeilen werden alle notwendigen Schritte erklärt:

1. Auf dem Host (auf dem sich Docker befindet) im home Verzechnis ein Ordner "Containers" erstellen (/home/$USER/Containers)

2. compose-create-containers.sh, create-containers.sh, docker-compose.yml und das Dockerfile auf den Host (auf dem sich Docker befindet) herunterladen. Alle Files in den "Containers" Ordner kopieren.

Das "create-containers.sh" File wird benutzt, um alle Container (ohne Docker-compose) automatisiert zu erstellen und das "compose-create-containers.sh" wird benutzt, um alle Container **mit Docker Compose** automatisiert zu erstellen.

3. "create-containers.sh" mir ``./create-containers.sh``ausführen (evt. müssen die Berechtigungen mit chmod noch angepasst werden)

Der Installation folgen (ein CA Passwort definieren und dieses mehrmals eingeben & bei "PEM Passphrase" ein PW eingeben, welches schlussendlich auf dem Client beim Verbinden ins VPN eingegeben werden muss)

Am Schluss wenn man aufgefordert wird, das TBZ Interface einzugeben, gibt man die IP des öffentliches Interface ein (die IP mit welcher beide VMs miteinander kommunizieren können

4. OpenVPN Client auf dem Client installieren: https://openvpn.net/community-downloads/

5. Das File ``/home/$USER/Containers/openvpn/client.ovpn`` auf irgendeineweise (google drive, usb Stick usw.) auf den Client kopieren und in den OpenVPN Ordner unter Config einfügen.

6. OpenVPN.exe auf dem Client starten und unten rechts auf das Symbol klicken (Rechtsklick) --> auf verbinden drücken

7. Passwort eingeben, welches man vorher beim PEM Passphrase eingab

FERTIG !!!

Die gleichen Schritte zählen beim Ausführen des "compose-create-containers.sh" Files auch jedoch müssen zuerst alle vorher erstellten Images, Container, Volumes und co. gelöscht werden
