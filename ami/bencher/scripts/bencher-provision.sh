#!/bin/bash
#
# Copyright 2018-present, Facebook, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e -x

# sudo yum install -y epel-release
sudo yum update -y

sudo yum remove -y java-1.7.0-openjdk
sudo yum install -y java-1.8.0-openjdk-devel
sudo yum install -y ntp
sudo yum install -y git-core
sudo yum -y install wget
sudo yum -y install unzip

# Install tomcat8
sudo groupadd tomcat
sudo useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
cd ~
wget http://mirror.rise.ph/apache/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz
sudo mkdir /opt/tomcat
sudo tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
sudo chgrp -R tomcat conf
sudo chmod g+rwx conf
sudo chmod g+r -R conf
sudo chown -R tomcat webapps/ work/ temp/ logs/
sudo cp ~/resources/systemmd/tomcat.service /etc/systemd/system/tomcat.service



# build and install ndbench

## setup log dir
sudo mkdir /var/log/ndbench
sudo chown tomcat:tomcat /var/log/ndbench


## checkout code
cd ~
git clone https://github.com/Netflix/ndbench.git
cd ndbench

## config logging with fix size rotations otherwise ndbench log will fill up disks fairly quick
cp ~/resources/ndbench/log4j.properties ndbench-web/src/main/resources/
cp ~/resources/ndbench/Log4jInit.java ndbench-web/src/main/java/com/netflix/ndbench/defaultimpl/Log4jInit.java
cp ~/resources/ndbench/web.xml ndbench-web/src/main/webapp/WEB-INF/web.xml


## build and deploy to tomcat8
./gradlew build
sudo cp ./ndbench-web/build/libs/ndbench-web-*.war /opt/tomcat/webapps/ROOT.war
