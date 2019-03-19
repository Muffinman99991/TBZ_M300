TBZ M300 LB1 (Dokumentation)
===============

In den folgenden Zeilen wurde dokumentiert, wie mit **Vagrant** eine virtuelle Maschiene erstellt wurde, welche einen **OpenVPN Server**
und zugleich einen **Apache Webserver** beherbergt (alles automatisiert). Auf den Apache Webserver kann nur dann zugegriffen werden, wenn man sich im VPN befindet.

Folgende Systemlandschaft sollte das Ziel meiner Arbeit verdeutlichen:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/netzwerkplan_m300.png" alt="Netzwerkplan" width="850"/>

## Vorbereitungen

**Wichtig: Dieses Projekt funktioniert nur mit einer Ubuntu Version ab <b>18.04</b>.
Alle älteren Versionen beherbergen in ihren Repositorys eine ältere Version von OpenVPN (<2.4),
welche Probleme mit IP-Routen aufweist. Die OpenVPN Version muss 2.4 oder höher sein!**

### Vagrant Initialisieren
Damit eine virtuelle Maschiene mittels Vagrant erstellt werden kann, muss dazu der entsprechenden Ordner als Vagrant Umgebung initialisiert werden. Dies wird mit `vagrant init` erstellt (innerhalb des Ordners).

Bild


## Vagrant File bearbeiten
Anschliessend kann das Vagrant File nach Belieben verändert werden. Ich entschied mich für die Vagrant Cloud Box **generic/ubuntu1804**, da es sich bei dieser Version um eine reativ neue handelt. Zu empfehlen wäre ebenso die Box **generic/ubuntu1810**.

Die Linie sollte dementsprechend wie folgt aussehen:

```
config.vm.box = "generic/ubuntu1804"
```
&#160;

Da unsere VM direkt vom LAN erreichbar sein sollte (Bridged), muss die folgende Linie auskommentiert werden:

```
#config.vm.network "public_network"
```
&#160;

Zusätzlich kann dann noch eine statishce IP, sowie das gebdridge Interface ausgewählt werden:

```
config.vm.network "public_network", ip: "10.71.13.4", bridge: "en1: ASXI Adapter"
```
&#160;

Da all unsere Befehle in einer separten Bash Skript geschrieben werden, muss dieses im Vagrant File definiert werden. Dieses Skript wird dann per SSH ins Guest System hochgeladen und ausgeführt.

```
config.vm.provision "shell", path: "bootstrap.sh"
```
&#160;

## Bash Skript erstellen
In das Bash skript werden alle Befehle reingeschrieben, welche auf der VM ausgeführt werden. Wichtig dabei ist, dass jeder Befehl ohne Aufforderung einer Eingabe ausgeführt wird. Während Vagrant die VM bereitstellt, können keine Eingaben getätigt werden.

Damit die VM weis, um welche Sprache es sich bei dem Skript handelt, muss in der ersten Linie des Skripts `#!/bin/bash` stehen. Gefolgt von `sudo su`, denn so muss nicht vor jedem Befehl manuell als SuperUser (`sudo`) ausgeführt werden.



## VM erstellen
Die virtuelle Maschiene wird dem Befehl ``vagrant up`` erstellt. Hier zu ist es wichtig, dass das Vagrant File im betreffenden Ordner vorhanden ist, und zugleich keine Fehler aufweist. Um das Vagrant File nach Fehler zu überprüfen, kann der Befehl ``vagrant validate`` angewendet werden.

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/validate.PNG" alt="Validate" width="360"/>
&#160;

Bei einem Fehler wird die entsprechende Linie sowie der Fehler angezeigt.

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/validate_error.PNG" alt="Validate Error" width="460"/>
&#160;

Nachdem die VM erfolgreich erstellt wurde, gelangt man zurück zu seiner Kommandozeile. Mit dem Befehl ``vagrant status`` lässt sich zusätzlich anzeigen, in welchem Zustand sich die VM befindet bzw. ob diese überhaupt erstellt wurde.

Nun lässt sich per ``vagrant ssh`` eine SSH Session zur VM öffnen.


## OpenVPN Client installieren
Sobald der [OpenVPN Client](https://openvpn.net/community-downloads/) installiert wurde, kann das Config File in den Ordner ``C:\Program Files\OpenVPN\config`` kopiert werden. In diesem Ordner müssen sich ausserdem alle zum Aufbau des VPN-Tunnels notwendigen Zertifikate und Schlüssel befinden.

Das Config File lässt sich von meinem Repo [hier](https://github.com/Muffinman99991/TBZ_M300/blob/master/client.ovpn) downloaden. 
Wichtig ist dabei nur, dass die IP Adresse des Servers (auf der ersten Linie) angepasst wird. Der Rest stimmt, voraussichtlich dass bootstrap.sh und Get-Certs.bat File, wurden für die Konfiguration des Servers benutzt.


## Zertifikate vom Server herunterladen
Das Batch-File lässt sich [hier](https://github.com/Muffinman99991/TBZ_M300/blob/master/Get-Certs.bat) downloaden. 
Damit dieses erfolgreich ausgeführt wird, ist pscp.exe zwingend notwendig. Pscp wird mit der Standardinstallation von Putty mitinstalliert. 

Auch in diesem File gilt es, die bei jeder Linie die IP-Adresse des Servers, sowie das root Passwort des Servers anzugeben:
``pscp.exe -pw <PASSWORT> root@<SERVER-IP>:/etc/openvpn/client/client.key "C:\Program Files\OpenVPN\config"``

Möchte das Passwort nicht in plaintext angegebn werden, so kann der Parameter ``-pw`` weggelassen werden und man wird beim Ausühren vier Mal nach dem Root Passwort aufgefordert.

Bei erfolgreichem Ausführen der Datei, erscheint folgende Ausgabe:
<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/get-certs.PNG" alt="BashFile Ausgabe" width="710"/>

**Wichtig:** Das Batch File muss als Administrator ausgeführt werden

## Mit VPN verbinden
Um sich nun per VPN mit dem Server zu verbinden, muss dass der OpenVPN Client gestartet werden (ausführen als Administrator). Anschliessend erscheint in der Taskleiste ganz rechts folgendes Symbol: <img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/ovpn-client.PNG" alt="OpenVPN Client Symbol" width="30"/>

Per Rechtsklick auf dieses und "Verbinden", beginnt der Datenaustausch zwischen dem Client bzw. den Client Tunnel Adapter und dem Server bzw. dem Server Tunnel Adapter. Dieser Vorgang kann bis zu einer Minute dauern. Im Statusfenster sollte während dem gesammmten Verbindungsaufbau keine roter Text (Fehlermeldungen) erscheinen.
Sobal die Verbindung aufgebaut wurde, erschient das Icon in der Taskleiste grün.


## Testing / Troubleshooting



