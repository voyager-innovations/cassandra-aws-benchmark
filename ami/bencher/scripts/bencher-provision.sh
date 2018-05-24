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
sudo yum install -y ntp
sudo yum install -y git-core
sudo yum -y install wget
sudo yum -y install unzip

# Install Java
JAVA_PACKAGE=jdk-8u171-linux-x64.rpm
curl -C - -LR#OH "Cookie: oraclelicense=accept-securebackup-cookie" -k \
	http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/$JAVA_PACKAGE
sudo rpm -ivh $JAVA_PACKAGE

# Install tomcat8
wget http://mirror.rise.ph/apache/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz
sudo mkdir ~/tomcat
sudo tar xvf apache-tomcat-8*tar.gz -C ~/tomcat --strip-components=1
cd ~/tomcat
sudo chmod g+rwx conf
sudo chmod g+r -R conf
sudo chown -R ec2-user webapps/ work/ temp/ logs/

# build and install ndbench

## setup log dir
sudo mkdir /var/log/ndbench
sudo chown ec2-user:ec2-user /var/log/ndbench

## checkout code
cd ~
git clone https://github.com/voyager-innovations/ndbench.git
cd ndbench

## config logging with fix size rotations otherwise ndbench log will fill up disks fairly quick
cp ~/resources/ndbench/log4j.properties ndbench-web/src/main/resources/
cp ~/resources/ndbench/Log4jInit.java ndbench-web/src/main/java/com/netflix/ndbench/defaultimpl/Log4jInit.java
cp ~/resources/ndbench/web.xml ndbench-web/src/main/webapp/WEB-INF/web.xml
cp ~/resources/ndbench/application.properties ndbench-core/src/main/resources/application.properties
cp ~/resources/ndbench/clusters.json ndbench-core/src/main/resources/clusters.json

## build and deploy to tomcat8
./gradlew build
sudo cp ./ndbench-web/build/libs/ndbench-web-*.war ~/tomcat/webapps/ROOT.war

# Valid values for DISCOVERY_ENV
# CF(Cloud Foundry), AWS, AWS_ASG (AWS Auto Scaling Group), CONFIG_FILE
echo 'DISCOVERY_ENV=AWS' >> ~/.bash_profile
