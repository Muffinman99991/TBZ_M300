::Für dieses Batchfile ist Putty.exe bzw. pscp.exe zwingend notwendig!
::
::
::Das Root Passwort, die Server IP, der remote Pfad und der lokale Pfad sollte gegebenfalls geändert werden.
::pscp.exe -pw <root passwort> root@<Server-IP>:<Pfad auf Server> <Lokaler Pfad>
::
::
::Befindet sich ein Leerschlag im Windows Pfad, so muss aus dem Pfad ein String gemacht werden (<"Pfad">)
::
::Möchte das Passwort nicht in diesem File eingegeben werden, so kann der Parameter <-pw> weggelassen werden und man wird beim Ausführen 
::des Befehles 3x nach dem Root PW gefragt.
::
pscp.exe -pw Miau123 root@192.168.33.10:/etc/openvpn/client.key "C:\Program Files\OpenVPN\config"
pscp.exe -pw Miau123 root@192.168.33.10:/etc/openvpn/client.crt "C:\Program Files\OpenVPN\config"
pscp.exe -pw Miau123 root@192.168.33.10:/etc/openvpn/ca.crt "C:\Program Files\OpenVPN\config"
