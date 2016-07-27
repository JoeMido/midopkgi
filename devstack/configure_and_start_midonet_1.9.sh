#! /usr/bin/env bash

# Copyright (c) 2016 Midokura SARL
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# NOTE(yamamoto): This script is intended to consume the same set of
# environment variables as devmido/mido.sh so that it can be used as
# a drop-in replacement.

set -x
set -e

for x in midolman tomcat zookeeper cassandra; do
    sudo service $x stop || :
done

## Vars

SERVICE_HOST=${SERVICE_HOST:-127.0.0.1}
ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-127.0.0.1:2181}
API_PORT=${API_PORT:-8080}
API_URI=http://$SERVICE_HOST:$API_PORT/midonet-api
API_TIMEOUT=${API_TIMEOUT:-120}
export MIDO_API_URL=$API_URI
export MIDO_USER=${MIDO_USER:-admin}
export MIDO_PROJECT_ID=${MIDO_PROJECT_ID:-admin}
export MIDO_PASSWORD=${MIDO_PASSWORD:-midonet}


## Zookeeper

sudo mkdir -p /usr/java/default/bin/
if [ ! -f /usr/java/default/bin/java ]; then
    sudo ln -s /usr/bin/java /usr/java/default/bin/java
fi
sudo rm -rf /var/lib/zookeeper/*
sudo service zookeeper restart

## Cassandra

sudo chown cassandra:cassandra /var/lib/cassandra
sudo rm -rf /var/lib/cassandra/data/system/LocationInfo
CASSANDRA_FILE='/etc/cassandra/default.conf/cassandra.yaml'
sudo sed -i -e "s/^cluster_name:.*$/cluster_name: \'midonet\'/g" $CASSANDRA_FILE
CASSANDRA_ENV_FILE='/etc/cassandra/default.conf/cassandra-env.sh'
sudo sed -i 's/\(MAX_HEAP_SIZE=\).*$/\1128M/' $CASSANDRA_ENV_FILE
sudo sed -i 's/\(HEAP_NEWSIZE=\).*$/\164M/' $CASSANDRA_ENV_FILE
sudo sed -i -e "s/-Xss180k/-Xss228k/g" $CASSANDRA_ENV_FILE
sudo rm -rf /var/lib/cassandra/*
sudo service cassandra restart

## Midonet API

API_FILE=/usr/share/midonet-api/WEB-INF/web.xml
sudo sed -i -e "s/tomcat7/tomcat/g" $API_FILE
sudo sed -i -e "s%http://localhost:8080/midonet-api%$API_URI%g" $API_FILE
sudo sed -i -e "s/org.midonet.api.auth.keystone.v2_0.KeystoneService/org.midonet.cluster.auth.MockAuthService/g" $API_FILE

sudo cat > /etc/tomcat/Catalina/localhost/midonet-api.xml <<EOL
<Context
    path="/midonet-api"
    docBase="/usr/share/midonet-api"
    antiResourceLocking="false"
    privileged="true"
/>
EOL

sudo echo 'JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Xms512m -Xmx1024m -XX:MaxPermSize=256m"' >> /etc/sysconfig/tomcat
sudo service tomcat restart

## Midonet CLI

cat > ~/.midonetrc <<EOL
[cli]
api_url = $API_URI
username = $MIDO_USER
password = $MIDO_PASSWORD
project_id = $MIDO_PROJECT_ID
EOL

## Midolman
#cat > /etc/midolman/midolman.conf <<EOL
#[zookeeper]
#zookeeper_hosts = $ZOOKEEPER_HOSTS
#root_key = /midonet/v1
#EOL
sudo service midolman restart

### Plugin

sudo mkdir -p /etc/neutron/plugins/midonet
sudo cat > /etc/neutron/plugins/midonet/midonet.ini <<FOOOOOO
[MIDONET]
midonet_uri = $API_URI
username = $MIDO_USER
password = $MIDO_PASSWORD
project_id = $MIDO_PROJECT_ID
FOOOOOO
