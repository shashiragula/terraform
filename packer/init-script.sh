#!/bin/sh

#install updates
sudo apt-get update

# install java
sudo apt-get install -y default-jdk

#set JAVA_HOME env variable
if [ $? -eq 0 ]
then
    sudo echo 'JAVA_HOME="/usr/lib/jvm/open-jdk"' >> /etc/environment
fi

#install git & maven
sudo apt-get install -y git
sudo apt-get install -y maven

#Create a directory for application and sync the code
cd ~
mkdir sample_app && cd sample_app
git clone https://github.com/efsavage/hello-world-war
