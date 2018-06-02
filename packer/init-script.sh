#!/bin/sh

sudo apt-get update
sudo apt-get install -y default-jdk

if [ $? -eq 0 ]
then
    sudo echo 'JAVA_HOME="/usr/lib/jvm/open-jdk"' >> /etc/environment
fi

sudo apt-get install -y git
sudo apt-get install -y maven

cd ~
mkdir sample_app && cd sample_app

git clone https://github.com/efsavage/hello-world-war
