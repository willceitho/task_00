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

cat > file <<EOF
`(node_ip)`
EOF

# Vars
node_roles="$1"
app=elasticsearch
# Install ES and config 
elastic_repo
yum install -y --enablerepo=elasticsearch $app 
cat > /etc/$app/$app.yml <<EOF
# ------------------------------------ Node ------------------------------------
node.name: `(node_ip)`
node.roles: [ `(echo $node_roles)` ]
# ---------------------------------- Network -----------------------------------
network.host: `(node_ip)`
http.port: 9200
# ---------------------------------- Cluster -----------------------------------
cluster.name: es_cluster
cluster.initial_master_nodes: ["192.168.0.201","192.168.0.210"]
# --------------------------------- Discovery ----------------------------------
discovery.seed_hosts: ["192.168.0.201","192.168.0.210"]
# ----------------------------------- Paths ------------------------------------
path.data: /var/lib/`(echo $app)`
path.logs: /var/log/`(echo $app)`
#bootstrap.memory_lock: true
EOF
systemctl daemon-reload
systemctl enable $app.service
systemctl start $app.service
