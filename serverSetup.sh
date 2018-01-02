#!/bin/bash
# Author: Tom Daniels <trd6577@g.rit.edu>
# File: serverSetup.sh
# Purpose: Sets up a secure ELK server instance

ERROR="\033[0;31m"   # Red
SUCCESS="\033[0;32m" # Green
WARNING="\033[1;33m" # Yellow
NC="\033[0m"         # No color

# You must be root to run this script
if [ $(id -u) != 0 ]; then
    echo -e "${ERROR}[-] Error: You must be root to run this script${NC}"
    exit 1
fi

# Install Java. Java is required by the ELK stack
echo -n "[*] Updating apt repositories... "
apt-get -q=2 update 2> /dev/null
if [ $? != 0 ]; then
    echo -e "${ERROR}Failure\n[-] Error: An error occured while updating repositories. 'apt-get update' returned $?"
    exit 1
else
    echo -e "${SUCCESS}Success${NC}"
fi

echo -n "[*] Installing OpenJDK 8... "
apt-get -y -q=2 install openjdk-8-jre 2> /dev/null
if [ $? != 0 ]; then
    echo -e "${ERROR}Failure\n[-] Error: An error occurred while installing OpenJDK 8. 'apt-get install openjdk-8-jre' returned $?"
    exit 1
else
    echo -e "${SUCCESS}Success${NC}"
fi

# Add elastic.co's public key to the sources.list
echo -n "[*] Grabbing elastic.co's public key... "
wget -q0 - https://artifcats.elastic.co/GPG-KEY-elasticsearch | apt-key add -
if [ $? != 0 ]; then
    echo -e "${ERROR}Failure\n[-] Error: An error occurred while getting and installing elastic.co's public key. 'apt-key add -' returned $?"
    exit 1
else
    echo -e "${SUCCESS}Success${NC}"
fi

# Update and install elasticsearch, kibana, and logstash
echo -n "[*] Installing elasticsearch, logstash, and kibana... "
apt-get -y -q2 install apt-transport-https elasticsearch logstash kibana
