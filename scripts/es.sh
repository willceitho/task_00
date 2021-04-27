#!/bin/env bash
function node_ip {
for dev in enp0s3; do
    ip address show dev $dev |
        grep -oP 'inet\s+\K\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
done
}

function elastic_repo {
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat > /etc/yum.repos.d/elasticsearch.repo <<EOF

[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
}

# Vars
echo -n 'Specify node role (if many, use "master, data"): '
read node_roles
app=elasticsearch

# Install ES and config 
elastic_repo
yum install -y --enablerepo=elasticsearch $app 

swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

mkdir /etc/systemd/system/elasticsearch.service.d/
cat > /etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF

cat > /etc/$app/unicast_hosts.txt <<EOF
192.168.0.201
192.168.0.202
192.168.0.210
EOF

cat > /etc/$app/$app.yml <<EOF
# ------------------------------------ Node ------------------------------------
node.name: `(node_ip)`
node.roles: [ `(echo $node_roles)` ]
# ---------------------------------- Network -----------------------------------
network.host: `(node_ip)`
http.port: 9200
# ---------------------------------- Cluster -----------------------------------
cluster.name: es_cluster
cluster.initial_master_nodes: ["192.168.0.201","192.168.0.202"]
# --------------------------------- Discovery ----------------------------------
#discovery.seed_hosts: ["192.168.0.201","192.168.0.202"]
discovery.seed_providers: file
# ----------------------------------- Paths ------------------------------------
path.data: /var/lib/`(echo $app)`
path.logs: /var/log/`(echo $app)`
# ----------------------------------- Other ------------------------------------
bootstrap.memory_lock: true
EOF


systemctl daemon-reload
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl enable $app.service
systemctl start $app.service
