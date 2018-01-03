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

# Function definitions

############################################################
# Function: update_repos
# Purpose:  Essentially just runs 'apt-get update' but with
#           some aesthetic fluff (user display). We run this
#           mutiple times so we have a function for it.
# Arguments:
#  None
# Returns:
#  None. Exits if error occurred
############################################################
update_repos(){
    echo -n "[*] Updating apt repositories... "
    apt-get -q=2 update 2> /dev/null
    check_error "updating repositories" "apt-get update" $?
}

############################################################
# Function: check_error
# Purpose:  Determines if an error was returned by a command
# Arguments:
#  $1 - short description of last command run
#  $2 - command run
#  $3 - error returned by command
# Returns:
#  None. Exits if error occurred
############################################################
check_error(){
    if [ $? != 0 ]; then
        echo -e "${ERROR}Failure\n[-] Error: An error occured while $1. '$2' returned $3"
        exit 1
    else
        echo -e "${SUCCESS}Success${NC}"
fi
}

# Make sure the repositories are up to date
update_repos

# Install OpenJDK. Java is required by the elasticsearch
echo -n "[*] Installing OpenJDK 8... "
apt-get -y -q=2 install openjdk-8-jre > /dev/null 2>&1
check_error "installing OpenJDK 8" "apt-get install openjdk-8-jre" $?

# Add elastic.co's public key
echo -n "[*] Grabbing elastic.co's public key... "
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - > /dev/null 2>&1
check_error "getting and installing elastic.co's public key" "apt-key add -" $?

# Add the repository definition
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" >> /etc/apt/sources.list.d/elastic-6.x.list
echo -e "[*] Adding the repository to the list in /etc/sources...${SUCCESS}Success${NC}"

# Update again with the new repository
update_repos

# Install elasticsearch, kibana, and logstash
echo -n "[*] Installing elasticsearch, logstash, kibana, and apt-transport-https... "
apt-get -y -q2 install apt-transport-https elasticsearch logstash kibana > /dev/null 2>&1
check_error "attempting to install the packages" "apt-get install" $?
