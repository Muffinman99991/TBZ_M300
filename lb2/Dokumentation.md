TBZ M300 LB2 (Dokumentation)
===============

In den folgenden Zeilen wurde dokumentiert, wie mit **Docker** zwei Container erstellt wurden (**OpenVPN Server**, **Apache Webserver**),
welche zusammen eine Containerumgebung bilden (alles automatisiert per Skript, Dockerfile & Dockercompose File). 
Auf den Apache Webserver kann nur dann zugegriffen werden, wenn man sich im VPN befindet.

Da ich das Ziel dieser LB nicht vollumfänglich erreicht, werden hier vorerst die Soll-Systemlandschaft gezeigt:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/Soll_Netzwerklan.PNG" alt="Netzwerkplan" width="750"/>

&#160;

Damit nur innerhalb des Tunnels auf die Webseite zugegriffen werden kann, wird der Tunnel wird über folgende Interfaces aufgebaut:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/Soll_Netzwerklan_VPN.PNG" alt="Netzwerkplan mit VPN-Tunnel" width="750"/>

&#160;

## Vorbereitungen

**Wichtig:** Einige Container können auf einer Windows Umgebung (oder einer emulierten Linux Umgebung wie mintty) nicht erstellt werden.
Es empfiehlt sich also eine Linux VM (welche Virtualisierung innerhalb der VM zulässt) zu verwenden, oder Docker direkt auf einem
Baremetall Linux zu installieren!

### Dockerfile erstellen
Um dieses zu erstellen kann einfach ein File mit dem Namen "Dockerfile" erstellt werden. Dieses sollte so heissen, denn Docker wird
nach diesem Namen suchen (ausser es wird ein spezieller Parameter verwendet)
Die zwei Befehle welche ich benutzt habe, waren ``FROM`` und ``RUN``. Mit dem ersten wird das ein Image aus ddem Dockerhub (oder Lokal)
definiert. Mit letzterem können Befehle innerhalb des Containers ausgeführt werden. Wird als beispielsweise ``RUN apt update`` ins File
geschrieben, so werden die Paketlisten innerhalb des Containers neu eingelesen.

Jedes mal, wenn ``RUN`` benutzt wird, wird ein neues Image erstellt, wobei der Zustand des alten dem Neuen mitgegeben wird. Optional kann
also auch folgende Kombination verwendet werden:
```
RUN [Befehl 1] && [Befehl 2] && [Befehl 3] && ...
``` 
So werden alle Befehle direkt im gleichen Container/Image erstellt.

Zusätzlich kann noch der Befehl ``EXPOSE`` verwendet werden, welcher einen spezifischen Port nach aussen freigibt.


## Container erstellen

### Apache
Da ich aus dem Ubuntu Image ein Apache Image kreieren möchte, habe ich zuerst den Befehl ``docker build -t apache-ssl .`` verwendet.
Mit "-t" kann ein Imagename ausgewählt werden und der Punkt am Ende zeigt den Pfad an, in welchem sich das Dockerfile befindet
(Punkt = auktuelles Verzeichnis). Sobald dieses erstellt wird, wird alles was im Container geschieht als STDOUT ausgegeben.

Nach kurzer Überprüfung ist erscihtlich, dass das Image erstellt wurde: 
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/docker_images.PNG" alt="Netzwerkplan mit VPN-Tunnel" width="700"/>

Nun kann der Container mit dem neu erstellten Image gestartet werden. Dabei sollte der entsprechende Port freigegeben werden:

```
docker run -dit --name running-apache-ssl -p 443:443/tcp apache-ssl
```

Auch wenn vorher im Dockerfile der Befehl ``service apache2 start`` (startet den Apache) geschrieben wurde, muss dieser Befehl nun auf 
irgedneine Art im laufenden Container neu ausgeführt werden, denn der vorherige Container (welchem zu einem Image wurde) wurde ja in diesem Sinne zerstört. Docker Images können keine laufendne Prozesse speichern. Ich löste dies so, dass ich im Dockerfile mit einem Befehl ein Skript innerhalb des Containers erstellte, welches ich dann
anschliessend nur noch ausführen kann.
```
docker exec -it running-apache-ssl /etc/apache2/startapache.sh
```
Das Skript besteht nur auf folgenden zwei Zeilen:
```
#!/bin/bash
service apache2 restart
```

Entweder kann hierzu im Docker File mit dem Befehl ``CMD`` oder ``ENTRYPOINT`` ein sogenannter "Startbefehl" mitgegeben werden, oder wie in meinem Fall ein Skript aufgerufen werden.

### OpenVPN
Leider gelang es mir nciht aus diesem Image ein zweites Images zu erstellen, denn das Erstellen dieses Containers erfordert zahlreiche Eingaben. Jeder Server besitzt ein andere Key bzw. eine andere CA, weswegen es auch keinen Sinn ergiebt hier ein verallgemeinertes Image zu erstellen. Damit der Container voll funktionstüchtig erstellt wird, müssen folgenden Befehle eingegeben werden:

```
$ export OVPN_DATA=openvpn_data
$ docker volume create --name $OVPN_DATA
$ docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn initopenvpn -u udp://[IP-Adresse vom Container]
$ docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn initpki
$ docker run --name openvpn -v $OVPN_DATA:/etc/openvpn -v /etc/localtime:/etc/localtime:ro -d -p 1194:1194/udp --cap-add=NET_ADMIN martin/openvpn
$ docker run -v $OVPN_DATA:/etc/openvpn --rm -it martin/openvpn easyrsa build-client-full [CLIENTNAME]
$ docker run -v $OVPN_DATA:/etc/openvpn --rm martin/openvpn getclient [CLIENTNAME] > [CLIENTNAME.ovpn]
```

## Bash Skript erstellen (optional)
In das Bash skript werden alle Befehle reingeschrieben, welche auf der VM ausgeführt werden. Wichtig dabei ist, dass jeder Befehl ohne Aufforderung einer Eingabe ausgeführt wird. Während Vagrant die VM bereitstellt, können keine Eingaben getätigt werden.

Damit die VM weis, um welche Sprache es sich bei dem Skript handelt, muss in der ersten Linie des Skripts `#!/bin/bash` stehen. Gefolgt von `sudo su`, denn so muss nicht vor jedem Befehl manuell als SuperUser (`sudo`) ausgeführt werden.

&#160;

## VM erstellen
Die virtuelle Maschiene wird dem Befehl ``vagrant up`` erstellt. Hier zu ist es wichtig, dass das Vagrant File im betreffenden Ordner vorhanden ist, und zugleich keine Fehler aufweist. Um das Vagrant File nach Fehler zu überprüfen, kann der Befehl ``vagrant validate`` angewendet werden.

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/validate.PNG" alt="Validate" width="360"/>
&#160;

Bei einem Fehler wird die entsprechende Linie sowie der Fehler angezeigt.
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/validate_error.PNG" alt="Validate Error" width="460"/>
&#160;

Nachdem die VM erfolgreich erstellt wurde, gelangt man zurück zu seiner Kommandozeile. Mit dem Befehl ``vagrant status`` lässt sich zusätzlich anzeigen, in welchem Zustand sich die VM befindet bzw. ob diese überhaupt erstellt wurde.

Nun lässt sich per ``vagrant ssh`` eine SSH Session zur VM öffnen.

&#160;

## OpenVPN Client installieren
Sobald der [OpenVPN Client](https://openvpn.net/community-downloads/) installiert wurde, kann das Config File in den Ordner ``C:\Program Files\OpenVPN\config`` kopiert werden. In diesem Ordner müssen sich ausserdem alle zum Aufbau des VPN-Tunnels notwendigen Zertifikate und Schlüssel befinden.

Das Config File lässt sich von meinem Repo [hier](https://github.com/Muffinman99991/TBZ_M300/blob/master/files/client.ovpn) downloaden. 
Wichtig ist dabei nur, dass die IP Adresse des Servers (auf der ersten Linie) angepasst wird. Der Rest stimmt, voraussichtlich dass bootstrap.sh und Get-Certs.bat File, wurden für die Konfiguration des Servers benutzt.

&#160;

## Zertifikate vom Server herunterladen
Das Batch-File lässt sich [hier](https://github.com/Muffinman99991/TBZ_M300/blob/master/files/Get-Certs.bat) downloaden. 
Damit dieses erfolgreich ausgeführt wird, ist pscp.exe zwingend notwendig. Pscp wird mit der Standardinstallation von Putty mitinstalliert. 

Auch in diesem File gilt es, die bei jeder Linie die IP-Adresse des Servers, sowie das root Passwort des Servers anzugeben:
``pscp.exe -pw <PASSWORT> root@<SERVER-IP>:/etc/openvpn/client/client.key "C:\Program Files\OpenVPN\config"``

Möchte das Passwort nicht in plaintext angegebn werden, so kann der Parameter ``-pw`` weggelassen werden und man wird beim Ausühren vier Mal nach dem Root Passwort aufgefordert.

Bei erfolgreichem Ausführen der Datei, erscheint folgende Ausgabe:
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/get-certs.PNG" alt="BashFile Ausgabe" width="720"/>

**Wichtig:** Das Batch File muss als Administrator ausgeführt werden

&#160;

## Mit VPN verbinden
Um sich nun per VPN mit dem Server zu verbinden, muss dass der OpenVPN Client gestartet werden (ausführen als Administrator). Anschliessend erscheint in der Taskleiste ganz rechts folgendes Symbol: <img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/ovpn-client.PNG" alt="OpenVPN Client Symbol" width="30"/>

Per Rechtsklick auf dieses und "Verbinden", beginnt der Datenaustausch zwischen dem Client bzw. den Client Tunnel Adapter und dem Server bzw. dem Server Tunnel Adapter. Dieser Vorgang kann bis zu einer Minute dauern. Im Statusfenster sollte während dem gesammmten Verbindungsaufbau keine roter Text (Fehlermeldungen) erscheinen.
Sobal die Verbindung aufgebaut wurde, erschient das Icon in der Taskleiste grün.

&#160;

## Sicherheit

### Firewall (UFW)
UFW steht für "Uncomplicated Firewall" und ist Heutzutage in vielen Linux / Unix Distros die vorinstallierte Firewall. 
Die Firewall des Opache Servers lässt nur die Ports 22 und 1194 zu. Die Ports 80 und 443 sind geschlossen, da diese nur vom internen VPN aus erreicht werden können. Alle restlichen Ports werden von der Firewall blockiert. Ist ist also grundsätzlich sinnlos zu versuchen  mit einem anderen Port aud die FW zuzugreifen.

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/ufw.PNG" alt="ufw" width="390"/>

### Lokale Berechtigungen
Damit die Verwaltung auf dem Opache Server einfacher und zugleich sicherer wird, wurde ein zusätzlicher benutzer erstellt. Nur dieser (und der Root) darf sicherheitsrelevante Daten wie die Schlüssel und co. anschauen und bearbeiten. Ebenfalls ist er der einzige User, welcher Apache SSL Certs erstellen und verwalten darf.

Hier lässts sich anmerken, dass alle Zertifikate in der Regel auf einem dazu dedizierten Server verwaltet werden. Dieser Server sollte strengstens beobachtet werden und die Zertifikate und notwendigen Schlüssel sollten nur über einen sicheren ssh Tunnel an die Server geschickt werden (z.B, per SCP)

### OpenVPN (Verschlüsselungen etc.) 
Obwohl OpenVPN als relativ sicher gilt, ist dies stark von der Konfiguration von OpenVPN abhängig. Standardmässig benutzt OpenVPB "BL-CBC" als Verschlüsselungsalgorythmus. Da dieser als sehr veraltet gilt und zusätzlich schon geknackt wurde, empfielt es sich AES mit einer akzeptablen Bit Länge zu verwenden (256Bit oder mehr). Ich benutzte hierfür AES-256-GCM.

Ebenso benutzt OpenVPN SHA1 als Hashwert. Auch bei diesem empfiehlt es sich die Bit lange um ein vielfaches zu erhöhen. Ich entschied ich mich hierfür für SHA512.

Damit der Kanal, über den die Zertifikate ausgetauscht werden, zusätzlich gesichert wird, wird ein PSK (Pre-shared-key) TLS Key verwendet.

Alles diese Infos lassen sich in meinem [client.ovpn](https://github.com/Muffinman99991/TBZ_M300/blob/master/files/client.ovpn) File finden.

## Testing / Troubleshooting
Wird nun vom Host aus ein beliebiger Browser aufgerufen und https://10.8.0.1/ eingegeben, so erscheint die Standard Apache Webseite (das index.html File wird aufgerufen):
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/apache-site.PNG" alt="Apache Index.html" width="1000"/>

Der Apache Server hört zwar auf jede Ip-Adresse des Ports 80 & 443, jedoch sind diese Ports in der UFW geschlossen, da nur vom VPN aus auf die Webseiten zugegriffen werden können. Es ist nutzlos die öffentliche IP des Servers im Browser anzugeben.

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/testfall.PNG" alt="index.html keinen Zugriff" width="750"/>


Um zu überprüfen, ob vom VPN aus ins Internet zugegriffen werden kann, kann nach einer hergestellten Verbinung vom Client zum Server eine öffentliche IP (z.B. im CMD) angepingt werden. 
Kann kein Ping auf das Lan odr das Web ausgeführt werden, so können folgenden Linien im Vagrant File hinzugefügt werden:


``config.vm.provision "shell",``

  ``run: "always",``
  
  ``inline: "route add default gw 192.168.33.1"``

 ``delete default gw on eth0``
 
 ``config.vm.provision "shell",``
 
  ``run: "always",``
  
 ``inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"``


INFO1: 192.168.33.1 muss durch den gewünschten neuen Gateway ersetzt werden

INFO2: eth0 muss 2x durch das  Interface ersetzt werden, von der die Default Route gelöscht werden möchte (könnte z.B auch "ens33" sein)
