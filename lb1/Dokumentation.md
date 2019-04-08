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
config.vm.network "public_network", ip: "10.71.13.4"
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


