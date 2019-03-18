TBZ M300 LB1 (Dokumentation)
===============

In den folgenden Zeilen wurde dokumentiert, wie mit **Vagrant** eine virtuelle Maschiene erstellt wurde, welche einen **OpenVPN Server**
und zugleich einen **Apache Webserver** beherbergt (alles automatisiert). Auf den Apache Webserver kann nur dann zugegriffen werden, wenn man sich im VPN befindet.

Folgende Systemlandschaft sollte das Ziel meiner Arbeit verdeutlichen:

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/netzwerkplan_m300.png" alt="Netzwerkplan" width="850"/>

## Vorbereitungen
### Vagrant Initialisieren
Damit eine virtuelle Maschiene mittels Vagrant erstellt werden kann, muss dazu der entsprechenden Ordner als Vagrant Umgebung initialisiert werden. Dies wird mit `vagrant init` erstellt (innerhalb des Ordners).

Bild

Anschliessend kann das Vagrant File nach Belieben verändert werden. Ich entschied mich für die Vagrant Cloud Box 


