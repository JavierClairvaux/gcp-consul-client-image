#!/bin/bash

#Variables
node_name=$1
consul_dc=$2
encrypt_key=$3
server_ip=$4
user=$5

ip=`hostname  -I | cut -f1 -d' '`

sudo sed -i "s/{{NODE}}/${node_name}/g" /etc/consul.d/config.json
sudo sed -i "s/{{DATACENTER}}/${consul_dc}/g" /etc/consul.d/config.json
sudo sed -i "s/{{IP}}/${ip}/g" /etc/consul.d/config.json
sudo sed -i "s/{{ENCRYPT_KEY}}/${encrypt_key}/g" /etc/consul.d/config.json
sudo sed -i "s/{{SERVER_IP}}/${server_ip}/g" /etc/consul.d/config.json
sed -i "s/{{USER}}/$user/g" /home/$user/entr/entr_script.sh

#starting consul
sudo systemctl daemon-reload
sudo systemctl start consul
#restart entr
sudo systemctl restart entr 

#restart dnsmasq
sudo systemctl restart dnsmasq

