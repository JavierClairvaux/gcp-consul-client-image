#!/usr/bin/env sh

#Installation
sudo apt update -y
sudo apt install unzip dnsmasq entr  -y

cd /usr/local/bin
sudo curl -o consul.zip https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
sudo unzip consul.zip
sudo rm -f consul.zip
sudo mkdir -p /etc/consul.d/scripts
  # creating consul user
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir -p /opt/consul
sudo chown --recursive consul:consul /opt/consul
cd ~
mkdir consul_service

  # SYSTEM D
  echo '[Unit]
  Description="HashiCorp Consul - A service mesh solution"
  Documentation=https://www.consul.io/
  Requires=network-online.target
  After=network-online.target
  ConditionFileNotEmpty=/etc/consul.d/config.json
  [Service]
  User=consul
  Group=consul
  ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/ -config-dir=/home/{{USER}}/consul_service
  ExecReload=/usr/local/bin/consul reload
  KillMode=process
  Restart=on-failure
  LimitNOFILE=65536

  [Install]
  WantedBy=multi-user.target' | sudo tee /etc/systemd/system/consul.service
sudo sed -i "s/{{USER}}/$USER/g" /etc/systemd/system/consul.service
sudo systemctl daemon-reload

  # CONFIGURATION
  #COPING CONFIG
echo '{
  "server": false,
  "node_name" : "{{NODE}}",
  "bind_addr": "{{IP}}",
  "datacenter": "{{DATACENTER}}",
  "data_dir": "/opt/consul",
  "domain": "consul",
  "enable_script_checks": true,
  "enable_syslog": true,
  "encrypt": "{{ENCRYPT_KEY}}",
  "leave_on_terminate": true,
  "log_level": "DEBUG",
  "rejoin_after_leave": true,
  "start_join": [
      "{{SERVER_IP}}"
  ],
  "ports": {
      "grpc" : 8502
    }
}'  | sudo tee  /etc/consul.d/config.json


sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/config.json


# dns masq update
# Netmask
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

sudo rm /etc/resolv.conf
echo "
  nameserver 127.0.0.1
  nameserver 8.8.8.8
" | sudo tee /etc/resolv.conf

# creating consul dnsmasq
# disabling
echo "
# Forwarding lookup of consul domain
server=/consul/127.0.0.1#8600
" | sudo tee /etc/dnsmasq.d/10-consul
#Install docker and pull consul envoy image
sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo docker pull javier1/consul-envoy

#entr config
cd 

mkdir consul_service
echo 'Unit]
Description="Entr file watching for new files for consul"

[Service]
Type=simple
ExecStart=/bin/bash /home/{{USER}}/entr/entr_script.sh

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/entr.service
sudo sed -i "s/{{USER}}/$USER/g" /etc/systemd/system/entr.service
sudo systemctl daemon-reload
