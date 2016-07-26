#! /bin/sh

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

# Remove possible reminders from the previous devmido runs
rm -rf \
    /usr/local/bin/mn-conf \
    /usr/local/bin/mm-ctl \
    /usr/local/bin/mm-dpctl \
    /usr/local/bin/mm-meter \
    /usr/local/bin/mm-trace

# Install java
yum install -y java-1.8.0-openjdk-headless

# Install Zookeeper
yum install -y zookeeper zkdump nmap-ncat

# Install Cassandra
yum install -y dsc22

# Install the API
yum install -y tomcat midonet-api python-midonetclient

# Install the Agent
yum install -y midolman

# Install the plugin
yum install -y python-networking-midonet