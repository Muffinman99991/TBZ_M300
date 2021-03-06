# TBZ_M300
## LB1
In LB1 geht es darum mit Vagrant automatisiert einen Service in Betrieb zu nehmen. Mit dem Befehl "Vagrant up", sollte das virtuelle System
somit schon betriebsbereit sein.

Mein Teamkollege und ich entschieden uns dafür zwei Services (OpenVPN & Apache Webserver) auf einer VM in Betrieben zu nehmen.
Folgend die Ziele:

* Mit Zertifikaten wird erfolgreich eine Verbindung zum VPN Server aufgebaut
* Vom VPN Netz aus ist eine Verbindung ins Internet möglich
* Webseiten des Apaches sind nur innerhalb des VPNs erreichbar. Von einer Person, welche sich im gleichen Netz wie die virtuelle Maschiene befindet, ist der Webserver nicht erreichbar
* Die Webseiten werden mit SSL erweitert, wodurch der Zugriff per HTTPS möglich wird

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/Vagrant.png" alt="drawing" width="150"/> &#160; &#160; &#160; &#160; &#160; &#160;<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/oracle.png" alt="drawing" width="180"/> <img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/openvpn.png" alt="drawing" width="140"/> &#160; <img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/apache.png" alt="drawing" width="200"/> 

&#160;
&#160;
## LB2
Das Prinzip der ersten LB bleibt auch bei dieser identsich. Mit dem Programm Docker, sollte ein -oder mehrere Conatiner erstellt werden, welche zussammen einen Service bilden. Es können die selben Servcies wie bei LB1 genutzt werden. Folgend die Ziele:

* Zwei separate Container (OpenVPN & Apache) miteinander verknüpfen
* Mit Zertifikaten wird erfolgreich eine Verbindung zum VPN Server aufgebaut
* Vom VPN Netz aus ist eine Verbindung ins Internet möglich
* Webseiten des Apaches sind nur innerhalb des VPNs oder der Host Maschine (auf der sich die Container befinden) erreichbar.
* Die Webseiten werden mit SSL erweitert, wodurch der Zugriff per HTTPS möglich wird

<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/Docker.PNG" alt="drawing" width="240"/> &#160; &#160; &#160; &#160; &#160; &#160;<img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/ubuntu.png" alt="drawing" width="160"/> <img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/openvpn.png" alt="drawing" width="140"/> &#160; <img src="https://github.com/Muffinman99991/TBZ_M300/blob/master/other/pics/apache.png" alt="drawing" width="200"/> 

