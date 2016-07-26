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

# https://docs.midonet.org/docs/latest-en/quick-start-guide/rhel-7_kilo-rdo/content/_repository_configuration.html

# Enable repository prioritization
yum install -y yum-plugin-priorities

# Enable EPEL repo
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm

# Configure DataStax repository

cat > /etc/yum.repos.d/datastax.repo <<EOL
# DataStax (Apache Cassandra)
[datastax]
name = DataStax Repo for Apache Cassandra
baseurl = http://rpm.datastax.com/community
enabled = 1
gpgcheck = 1
gpgkey = https://rpm.datastax.com/rpm/repo_key
EOL

# Configure MidoNet repositories

cat > /etc/yum.repos.d/midonet.repo <<EOL
[mem]
name=MEM
baseurl=http://$REPO_USER:$REPO_PWD@yum.midokura.com/repo/v1.9/stable/RHEL/7/
enabled=1
gpgcheck=1
gpgkey=https://$REPO_USER:$REPO_PWD@yum.midokura.com/repo/RPM-GPG-KEY-midokura

[mem-openstack-integration]
name=MEM OpenStack Integration
baseurl=http://$REPO_USER:$REPO_PWD@repo.midokura.com/openstack-liberty/stable/el7/
enabled=1
gpgcheck=1
gpgkey=https://$REPO_USER:$REPO_PWD@repo.midokura.com/midorepo.key
EOL

