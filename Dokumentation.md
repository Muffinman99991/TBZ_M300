TBZ M300 LB1 (Dokumentation)
===============

In den folgenden Zeilen wurde dokumentiert, wie mit **Vagrant** eine virtuelle Maschiene erstellt wurde, welche einen **OpenVPN Server**
und zugleich einen **Apache Webserver** beherbergt (alles automatisiert). Auf den Apache Webserver kann nur dann zugegriffen werden, wenn man sich im VPN befindet.

Folgende Systemlandschaft sollte das Ziel meiner Arbeit verdeutlichen:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/netzwerkplan_m300.png" alt="Netzwerkplan" width="850"/>

## Vorbereitungen

**Wichtig: Dieses Projekt funktioniert nur mit einer Ubuntu Version ab <b>18.04</b>.
Alle älteren Versionen beherbergen in ihren Repositorys eine ältere Version von OpenVPN,
welche Probleme mit IP-Routen aufweist.**

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




## OpenVPN Client installieren



## Zertifikate vom Server herunterladen



## Mit VPN verbinden



## Testing / Troubleshooting



