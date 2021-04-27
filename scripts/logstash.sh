#!/bin/env bash

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
app=logstash



# Install ES and config 
elastic_repo
mkdir -p /etc/logstash/conf.d/

yum install -y --enablerepo=elasticsearch $app 
cat > /etc/$app/conf.d/$app.conf <<EOF
input {
  file {
    path => ["/var/log/logstash/*.log"]
    start_position => "beginning"
  }
}

filter {
  date {
    match => [ "timestamp", ISO8601 ]
  }
}

output {
  elasticsearch {
    hosts => ["http://192.168.0.201:9200","http://192.168.0.202:9200"]
    index => "logstash-logs-%{+YYYY.MM}"
  }
}
EOF
systemctl enable $app.service
systemctl start $app.service

# filter {
#   grok {
#     match => { "message" => "\[%{TIMESTAMP_ISO8601:timestamp}\]\[%{DATA:severity}%{SPACE}\]\[%{DATA:source}%{SPACE}\]%{SPACE}%{GREEDYDATA:message}" }
#     overwrite => [ "message" ]
#   }
# }