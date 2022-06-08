#!/bin/bash
sudo apt-get -y update && sudo apt-get -y upgrade
export DOWNLOAD_FOLDER=/tmp
cd $DOWNLOAD_FOLDER
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt -y  install unzip
unzip $DOWNLOAD_FOLDER/awscliv2.zip
sudo $DOWNLOAD_FOLDER/aws/install