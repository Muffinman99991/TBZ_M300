TBZ M300 LB2 (Vorinformationen)
===============

Folgend ein paar Vorinformationen zur zweiten LB des Modules 300. 
Das Ziel dabei war, einen Apache Webserver und einen OpenVPN Server mittels Containervirtualisierung inbetrieb zu nehmen (zwei separate Container), 
und diese Umgebung so zu konfigurieren, dass auf den Webserver nur innerhalb des VPNs zugegriffen werden kann (von Hosts im gleichen Netz nicht erreichbar).


Was ist Docker?
-------------

Docker ist ein Programm, mit welchem Container bzw. ganze Container-Umgebungen erstellt werden können. 
Durch vordefinierte virtuelle Boxen (Vagrant Cloud Boxes), welche von offiziellen Herstellern oder von der Community 
selbt erstellt werden, lassen sich jegliche Betriebssyteme in kürzester Zeit virtualisieren.

[Alle verfügbaren Vagrant Boxen](https://app.vagrantup.com/boxes/search)

Was ist OpenVPN?
-------------

OpenVPN ist ein OpenSource Programm, mit welchem ein virtuelles privates netzwerk (VPN) erstellt werden kann. Die mögliche Konfiguration von OpwenVPN scheint fast Grenzenlos (Authentifizierungsart, Port und Verschlüsselungsalgorythmus frei wählbar).

[Mehr über OpenVPN](https://de.wikipedia.org/wiki/OpenVPN)

Was ist Apache?
-------------

Apache ist ein Opensource Webservice, welcher simple zu konfigurieren ist (meist reicht das installieren des Services und das austauschen des index.html Files schon) 

&#160;

Persönlicher Wissenstand (vor LB1)
-------------

### Virtualisierung
Bezüglich Virtualisierung besuche ich zum jetzigen Zeitpunkt den überbetrieblichen Kurs 340, welcher sich vollumfänglich mit Virtualisierung befasst. Ich besitzt dementspechende schon ein akzeptables Vorwissen an Virtualisierung.

#### Kentnisse in:
* VmWare Workstation
* ESXi

#### Neuland:
* Vagrant
* Oracle VirtualBox
* Container bzw. Betriebssystem-Virtualisierung

&#160;

### Linux
Die Grundlagen von Linux und Unix behersche ich gut. Seit einem halben Jahr bin ich bei der Arbeit im Linux Team unsere Firma tätig.
Ein Guru in Linux bin ich jedoch nicht

#### Kentnisse in:
* Navigieren in der Bash
* Ubuntu

#### Neuland:
* IP-Tables und ufw Firewall in Linux konfigurieren
* Git-Bash
* Alle Befehle automatisiert ausführen (ohne einen Input zu geben)

&#160;

### Vagrant
Bei diesem Thema ist für mich alles Neuland und ich besitzt keine Vorkentnisse.

&#160;

### Git
Auch mit Git hatte ich mich bis zu diesem Modul noch nciht befasst. Ich war oft auch GitHub unterwegs um diverse programme/Tools herunterzuladen, war mir jedoch nie bewusst, was Git üerhaupt ist. Die Markdown Sprache ist Ebenfalls Neuland für mich.

&#160;

### OpenVPN
Hatte Zuhause schon einen VPN Sevrer aufgesetzt, musste dabei jedoch keine Änderung am Server bzw. am Server Config-File ändern. Kentnnise in diesem Gebiet und vorallem mit OpenVPN sind relativ gut.

#### Kentnisse in:
* OpenVPN Client konfigurieren bzw. Client Config-File
* Zertifikate verwalten

#### Neuland:
* Server so zu bearbeiten, dass dieser Traffic an ein weiteres Netz weiterleitet.

&#160;

### Apache
Kenntnise eher mangelnd. Ich installiere des öfteren einen Apache Webserver in Linux Umgebungen, konfigurierte diesen jedoch noch nie.

&#160;

Wissenszuwachs & Reflexion
-------------

### Wissenzuwachs

Während dieser LB1 konnte ich mir viel neues Wissen aneignen. Im Bezug auf Linux konnte ich allgemein mein "Command-Wörterbuch" drastisch erweitern. Mit dem Command ``sed`` hatte ich bis jetzt noch nichts am Hut, obwohl dieser in Hinsicht auf Automatisierung sehr hilfreich ist. Ebenso lernte ich einiges über IP-Routen und deren Konfiguration in Linux.

Ausserdem konfigurierte ich Apache das erste Mal mit SSL und lernte doch einiges über die Funktionsweise von Webservern, insbesondere in Linux-Umbebungen. Hinsichtlich der Zertifikaten war nichts neuland für mich, da ich mit diese schon des Öfteren arbeitete.

In Vagrant konnte ich mit mir Abstand am meisten Wissen aneignen. Ich kenne die meisten Befehle im Bezug auf Vagrant, verstehe das Vagrant File und kann sogar den Ablauf beim automatisierten Erstellen einer VM aufzählen:

1. Virtuelle Maschiene wird im provider Programm kreiert (in meinem Fall Oracle Virtualbox). Zudem wird die VM mit einem weiteren NAT Interface ausgestattet, über welches die SSH Verbinung erfolgt
2. SSH Schlüssel werden zwischen Host und VM ausgetauscht. Evt. wird einer neuer privater SSH-Schlüssel erstellt
3. Die SSH Verbindung wird getestet
4. Per SSH verbindung wird das Bootstrap.sh Skript auf die VM geladen und ausgeführt

In Bezug auf Git lernte ich ebenfalls Einiges. Mir wurde während dieser LB klar, warum GIT benutzt wird, wie dieses Verionsverlauf Tool nützlich sein könnte und vorallem, wie es angewendet wird. In dieser gesammten Zeit schickte (Push & Commit) ich dutzende Dokumente von Git Bash oder Visual Studios aus an mein Github Repository.

Bei OpenVPN konnte ich meiner Meinung nach nicht viel Neues lernen. Bis jetzt hatte ich noch nie mit einem TA-Key (TLS Authentication Key) eine Verbindung zu einem OpenVPN Server aufgebaut. Zudem wurde mir klar wurde warum dieser Schlüssel nützlich sein könnte (der Verbindungskanal zwischen Client und OpenVPN Server, welcher genutzt wird um die Schlüssel auszutauschen, wird zusätzlich verschlüsselt. Durch diesen Vorgang können DDOS Attacken gegnüber dem )

### Reflexion

Zahlreiche Stunden investierte ich in diese Lernbeurteilung und konnte einiges mitnehmen. Für eine ganze Weile funktionierte der Zugriff auf das VPN nicht. Schlussendlich fand ich heraus, dass dies an einer veralteten OpenVPN Version lag. Diese leitet die entsprechenden Routen nicht weiter, weswegen nichts ins Internet zugegriffen werden konnte und ebenso nichts ins LAN. Für nächstes Projekt nehme ich mir mit, dass ich von Anfang an darauf achte, die aktuellste Distribution zu verwenden. Denn die neusten Distris beinhalten in Ihren Repos auch jeweils immer die neusten Version des entsprechenden Programms. In meinem Fall beherbergte Ubuntu 16.04 in ihren Repos einen Link zur OpenVPN Version kleiner als 2.4.





