#!/bin/env bash
function node_ip {
for dev in enp0s3; do
    ip address show dev $dev |
        grep -oP 'inet\s+\K\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
done
}

# Vars
app=kibana

# Install ES and config 
yum install -y --enablerepo=elasticsearch $app 
cat > /etc/$app/$app.yml <<EOF
server.host: `(node_ip)`
server.port: 5601

elasticsearch.hosts:
  - http://192.168.0.201:9200
  - http://192.168.0.202:9200

elasticsearch.sniffInterval: 60000
elasticsearch.sniffOnConnectionFault: true

logging.dest: /var/log/`(echo $app)`/`(echo $app)`.log
EOF
systemctl enable $app.service
systemctl start $app.service