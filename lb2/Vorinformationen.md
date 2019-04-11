TBZ M300 LB2 (Vorinformationen)
===============

Folgend ein paar Vorinformationen zur zweiten LB des Modules 300. 
Das Ziel dabei war, einen Apache Webserver und einen OpenVPN Server mittels Containervirtualisierung inbetrieb zu nehmen (zwei separate Container), 
und diese Umgebung so zu konfigurieren, dass auf den Webserver nur innerhalb des VPNs zugegriffen werden kann (von Hosts im gleichen Netz nicht erreichbar).


Was ist Docker?
-------------

Docker ist ein Programm, mit welchem Container bzw. ganze Container-Umgebungen erstellt werden können. 
Durch vordefinierte Images (auf Docker Hub), welche von offiziellen Herstellern oder von der Community 
selbt erstellt werden, lassen sich diverse Container aller Art erstellen.

[Alle verfügbaren Docker Images](https://www.docker.com/products/docker-hub)

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
Bezüglich Virtualisierung besitze ich ein rtelativ breichgefächertes Wissen. Vor ein paar Wochen besuchte ich den überbetrieblichen Kurs 340, welcher sich vollumfänglich mit Virtualisierung befasst. Ich lernte einiges über Containervirtualisierung, erstellte jedoch bis zu dieser LB noch nie einen Container

#### Kentnisse in:
* VmWare Workstation
* ESXi

#### Neuland:
* Umgang mit Docker

&#160;

### Linux
Die Grundlagen von Linux und Unix behersche ich gut. Seit einem halben Jahr bin ich bei der Arbeit im Linux Team unsere Firma tätig.
Ein Guru in Linux bin ich jedoch nicht.

#### Kentnisse in:
* Navigieren in der Bash
* Ubuntu

#### Neuland:
* IP-Tables und ufw Firewall in Linux konfigurieren
* Git-Bash
* Alle Befehle automatisiert ausführen (ohne einen Input zu geben)

&#160;

### Docker
Bei diesem Thema ist für mich alles Neuland und ich besitzt keine Vorkentnisse.

&#160;

### OpenVPN
Hatte Zuhause schon einen VPN Sevrer aufgesetzt, musste dabei jedoch keine Änderung am Server bzw. am Server Config-File ändern. Kentnnise in diesem Gebiet und vorallem mit OpenVPN sind relativ gut.

#### Kentnisse in:
* OpenVPN Client konfigurieren bzw. Client Config-File
* Zertifikate verwalten & manuell erstellen

#### Neuland:
* Server so zu bearbeiten, dass dieser Traffic an ein weiteres Netz weiterleitet.
* Client erstellen, indem alle Schlüssel in Form von Text eingetragen sind.

&#160;

### Apache
Kenntnise eher mangelnd. Während der ersten LB konnte ich zwar einiges über Apache lernen, jedoch hauptsächlich nur über die Konfiguration in Bezug auf SSL. Ich müsste mich um ein Vielfaches intensiver mit Apache auseinandersetzen, damit ich darin das Meiste verstehe.

&#160;

Wissenszuwachs & Reflexion
-------------

### Wissenzuwachs

Während dieser LB2 konnte ich mir viel neues Wissen aneignen. Im Bezug auf Linux konnte ich allgemein mein "Command-Wörterbuch" ein wenig erweitern. Dabei handelt es sich um kleine/simple Befehle, welche mir den Umgang mit Bash erleichert (z.B. mit Taste "home" an den Anfang der Zeile, mit ``history`| grep [Wort]`` nach einem beriets eingegebenen Befehl filtern usw.) 
Da ich bis jetzt kaum mit Bash Skripten gearbeitet habe, lernte ich auch in diesem Bereich einiges.

In Docker konnte ich mit mir Abstand am meisten Wissen aneignen. Ich kenne die meisten Befehle im Bezug auf Docker und verstehe diese auch. Zudem kann ich den Ablauf beim automatisierten Erstellen eines Containers mittels Docker aufzählen:

#### ``docker run [Image]``:

1. Docker sucht im lokalen Image Ordner nach dem ausgewählten Image. Falls dies nicht vorhanden ist, wird es von Docker Hub heruntergeladen.
2. Der Container wird gestartet und das Resultat wird ausgegeben. Jenachdem welcher Parameter verwendet wird, kann der Container auch im Hintergrund ausgeführt werden. 


#### ``docker -t build [Image-Name] [Pfad zum Dockerfile]``

1. Docker sucht nach dem Dockerfile im angegebenen Pfad
2. Das Docker File wird von oben nach unten abgearbeitet. Pro Befehl (RUN, CMD etc.) wird ein neuer Container bzw. ein neues Images erstellt und dem neuen mitgegeben. Erst wenn alle Befehle ausgeführt wurden, wird das Image lokal gespeichert.


Bei OpenVPN konnte ich meiner Meinung nach nicht viel Neues lernen. Bis jetzt hatte ich noch nie mit einem TA-Key (TLS Authentication Key) eine Verbindung zu einem OpenVPN Server aufgebaut. Zudem wurde mir klar wurde warum dieser Schlüssel nützlich sein könnte (der Verbindungskanal zwischen Client und OpenVPN Server, welcher genutzt wird um die Schlüssel auszutauschen, wird zusätzlich verschlüsselt. Durch diesen Vorgang können DDOS Attacken gegnüber dem )

### Reflexion

Zahlreiche Stunden investierte ich in diese Lernbeurteilung und konnte einiges mitnehmen. Leider war diese Lernbeurteilung kein voller Erfolg, da ich mein ursprünglich geplantes Ziel nicht erreicht habe.

Für eine ganze Weile funktionierte der Zugriff auf das VPN nicht. Schlussendlich fand ich heraus, dass dies an einer veralteten OpenVPN Version lag. Diese leitet die entsprechenden Routen nicht weiter, weswegen nichts ins Internet zugegriffen werden konnte und ebenso nichts ins LAN. Für nächstes Projekt nehme ich mir mit, dass ich von Anfang an darauf achte, die aktuellste Distribution zu verwenden. Denn die neusten Distris beinhalten in Ihren Repos auch jeweils immer die neusten Version des entsprechenden Programms. In meinem Fall beherbergte Ubuntu 16.04 in ihren Repos einen Link zur OpenVPN Version kleiner als 2.4.





