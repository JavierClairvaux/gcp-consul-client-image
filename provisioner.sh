#!/bin/bash

#Variables
node_name=$1
consul_dc=$2
encrypt_key=$3
server_ip=$4

ip=`hostname -I | tr -d ' '`

sudo sed -i "s/{{NODE}}/${node_name}/g" /etc/consul.d/config.json
sudo sed -i "s/{{DATACENTER}}/${consul_dc}/g" /etc/consul.d/config.json
sudo sed -i "s/{{IP}}/${ip}/g" /etc/consul.d/config.json
sudo sed -i "s/{{ENCRYPT_KEY}}/${encrypt_key}/g" /etc/consul.d/config.json
sudo sed -i "s/{{SERVER_IP}}/${server_ip}/g" /etc/consul.d/config.json

#starting consul
sudo systemctl daemon-reload
sudo systemctl start consul
sudo systemctl status consul

#restart dnsmasq
sudo systemctl restart dnsmasq

