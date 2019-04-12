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


## Container und Netzwerk erstellen

### Apache Container
Da ich aus dem Ubuntu Image ein Apache Image kreieren möchte, habe ich zuerst den Befehl ``docker build -t apache-ssl .`` verwendet.
Mit "-t" kann ein Imagename ausgewählt werden und der Punkt am Ende zeigt den Pfad an, in welchem sich das Dockerfile befindet
(Punkt = auktuelles Verzeichnis). Sobald dieses erstellt wird, wird alles was im Container geschieht als STDOUT ausgegeben.

Nach kurzer Überprüfung ist erscihtlich, dass das Image erstellt wurde: 
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/docker_images.PNG" alt="Netzwerkplan mit VPN-Tunnel" width="700"/>

Nun kann der Container mit dem neu erstellten Image gestartet werden. Dabei kann noch der entsprechende Port freigegeben werden (was jedoch nicht nötig:

```
docker run -dit --name running-apache-ssl apache-ssl
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

### OpenVPN Container
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

### Opache-Net Netzwerk
Damit die beiden Container über ein internes Netzwerk (in Netzwerkplan "opache-net") kommunizieren können, muss dieses zurest erstellt werden: ``docker network create opache-net``

Nachdem die beiden Container mit "docker up" gestartet wurden, müssen folgenden Befehle eingegeben werden: ``docker network connect opache-net running-openvpn`` & ``docker network connect opache-net running-apache-ssl``

&#160;

## Bash Skript erstellen (optional)
Damit beide Container automatisiert erstellt und konfiguriert werden, entschied ich mich dafür ein [Skript](https://github.com/Muffinman99991/TBZ_M300/blob/master/lb2/create-containers.sh) zu verfassen.

Diese erstellt separate Ordner (falls diese noch nicht vorhanden sind), kreiert ein gemeinsames Netz, über welches die Container intern kommunizieren sollte usw.


&#160;

## OpenVPN Client installieren
Sobald der [OpenVPN Client](https://openvpn.net/community-downloads/) installiert wurde, kann das Config File in den Ordner ``C:\Program Files\OpenVPN\config`` kopiert werden. In diesem Ordner müssen sich diesesmal keine Zertifikate und Schlüssel befinden, da diese alle in Textform im client.ovpn stehen.

Ausserdem muss das Config File dieses mal nicht angepasst werden, da diese schon im Bash Skript mit dem ``sed`` Befehl vorgenommen wird.

Leider muss das Client File auf irgendeine Art vom Ubuntu Host auf den entsprechenden Client gelangen. Da ich auf dem Ubuntu Host kein OpenSSH installiert habe, können die Zerfifikate so nichtt einfachso übertragen werden (wie bei LB1).
Dies könnte jedoch noch einfach erweitert werden.

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
### Test 1
**ID:** 1 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** Container im Opache-net

**Soll-Zustand:** Beide Container befinden sich im selber erstellten Opache-net

**Ist-Zustand:** Anhand folgendem Befehl wurde ersichtlich, dass sich beide Container im selber erstellten Opache-net befinden:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/opache-test.PNG" alt="ID 1" width="710"/>

**Erfüllt:** Ja

&#160;

### Test 2
**ID:** 2 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** Aktive Container

**Soll-Zustand:** Beide Container wurden erstellt und sind aktiv

**Ist-Zustand:** Anhand folgendem Befehl wurde ersichtlich, dass sich beide Container erstellt wurden und aktiv sind:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/docker-ps.PNG" alt="ID 2" width="910"/>

**Erfüllt:** Ja


&#160;

### Test 3
**ID:** 3 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** VPN-Verbindung

**Soll-Zustand:** Vom Client aus kann erfolgreich eine Verbindung ins VPN aufgebaut werden.

**Ist-Zustand:** Anhand dem OpenVPN-Status und dem grünen Icon ist ersichtlich, dass der test erfolgreich war:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/openvpn-test.PNG" alt="ID 3" width="510"/>

**Erfüllt:** Ja

&#160;

### Test 4
**ID:** 4 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** Verbindung ins Internet

**Soll-Zustand:** Vom Client aus bzw. durch den Tunnel Adapter kann erfolgreich aufs Internet zugegriffen werden.

**Ist-Zustand:** Jede Seite ist im Internet aufrufbar (ein beweis Bild notwendig):

**Erfüllt:** Ja

&#160;

### Test 5
**ID:** 5 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** Erreibarkeit der Apachewebseite

**Soll-Zustand:** Vom Client aus bzw. durch den Tunnel Adapter kann die Apache Webseite per https aufgerufen werden.

**Ist-Zustand:** Die Seite kann zwar aufgerufen werden, jedoch nur mit der IP des Docker0 Interfaces und nicht mit jener des Opaches-Net Interfaces:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/apache-https.PNG" alt="ID 5" width="590"/>

**Erfüllt:** Nur Teilweise

&#160;

### Test 6
**ID:** 6 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** Erreibarkeit der Apachewebseite über öffentl. IP

**Soll-Zustand:** Vom Client aus bzw. durch den Tunnel Adapter sollte die Apache-Webseite nicht über die öffentliche IP des Hosts erreichbar sein (IP: 10.71.14.4)

**Ist-Zustand:** Die Website ist über "https://10.71.14.4/" nicht erreichbar.

**Erfüllt:** Ja

&#160;

### Test 7
**ID:** 7 &#160; &#160; &#160; &#160; &#160; **Beschreibung:** Kommunikation via opache-net

**Soll-Zustand:** Die beiden Container können über das opache-net Netzwerk kommunizieren. Der Ping vom Apache Container sollte auf den OpenVPN Container funktionieren. Umgekehrt wird der Ping nicht möglich sein, da der OpenVPN Container zu wenig Ressourcen besitzt, um Programme herunterzuladen (apt ist nicht vorhanden, womit das Package "iputils-ping" nicht heruntergeladen werden kann).

**Ist-Zustand:** Ping war erfolgreich. Komischwerweise kann trotzdem nicht mit der Opache-net IP auf den Webserver zugegriffen werden.

*Hinweis zum Bild: mit dem Befehl ``docker exec -it [Containername] /bin/bash`` konnte ich eine Bash des Containers öffnen. In dieser pingte ich dann die opache-net Ip-Adresse des OpenVPN Containers an:*

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/ping.PNG" alt="ID 7" width="450"/>

**Erfüllt:** Ja


## Troubleshooting

Der einzige Weg wie das Aufrufen der Website möglich ist, ist wenn der Apache Container auch per Bridge-Network mit dem Host verbunden wird:
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/Ist_Netzwerklan.PNG" alt="ID 5" width="700"/>


Dies ist jedoch nicht der richtige Weg, da so die beiden Container **nicht über das opache-net kommunizieren, sondern über den Host bzw. über das docker0 Netz**.

Warum dies noch

