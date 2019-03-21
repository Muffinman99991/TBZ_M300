#Autor: Marvin Haimoff
#Datum: 18.03.2019
#Im Rahmen des Modules 300 an der TBZ in Zuerich


Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.


  # Die Vagrant Box und das Skript, welches auf der VM ausgeführt wird, wird definiert
  # boxes sind auf https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu1804"
  config.vm.provision "shell", path: "bootstrap.sh"


  #Netzwerkadapter der VM wird mit dem physischen Adapter der Host Maschiene gebridged.
  config.vm.network "public_network", ip: "192.168.192.64"


  #Shared Folder (damit das index.html File von Apache auf diesem Host abgelegt wird)
  config.vm.synced_folder ".", "/var/www/html"


  #Eigenschaften der VM aendern
  config.vm.provider "virtualbox" do |vb|
      vb.name = "m300-opache-server"
      vb.memory = "1024"
  end
  
 
 
############Wenn der Apache vom VPN aus nicht erreicht / gepingt werden kann,
# dann als Test folgende Linien auskommentieren
#INFO: 192.168.33.1 muss durch den gewünschten neuen Gateway ersetzt werden
#INFO: eth0 muss 2x durch das  Interface ersetzt werden, von der die Default
#Route gelöscht werden möchte (könnte z.B auch "ens33" sein)
############

##############Ab hier auskomentieren!#############
#config.vm.provision "shell",
#  run: "always",
#  inline: "route add default gw 192.168.33.1"

# delete default gw on eth0
#config.vm.provision "shell",
#  run: "always",
# inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != 
#\"0.0.0.0\") print \"route del default gw \" $2; }'`"
###################################################
  
  
end
