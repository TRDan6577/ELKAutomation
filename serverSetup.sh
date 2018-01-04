#!/bin/bash
# Author: Tom Daniels <trd6577@g.rit.edu>
# File: serverSetup.sh
# Purpose: Sets up a secure ELK server instance

ERROR="\033[0;31m"   # Red
SUCCESS="\033[0;32m" # Green
WARNING="\033[1;33m" # Yellow
NC="\033[0m"         # No color

CERT_DIR=/etc/pki/elk

# You must be root to run this script
if [ $(id -u) != 0 ]; then
    echo -e "${ERROR}[-] Error: You must be root to run this script${NC}"
    exit 1
fi

# Make sure that the user edited server_root.conf and v3.ext
if [[ $(sha256sum server_root.conf) == "657f509b06782c95ab44a4e46675139cdb77163402e1e578def076e1c446c328  server_root.conf" ]]; then
    echo -e "${ERROR}[-] Error: You must fill in information in the server_root.conf file to successfully create certificates"
    exit 1
fi

if [[ $(sha256sum v3.ext) == "a0a5335daa6295596852a1758f0c1b3493dd25ffe81c0a44e59b08df97a410a5  v3.ext" ]]; then
    echo -e "${ERROR}[-] Error: You must fill in information in the v3.ext file to successfully create certificates"
    exit 1
fi

############################ Function definitions #############################

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

############################################################
# Function: generate_certs
# Purpose:  Generates the root, logstash, and kibana certificates. The 
#           certificates generated follow the requirements for Chrome/Chromium
#           so they won't give that angry untrusted page in a web browser.
#           The directory structure is as follows:
#               $ROOT_DIR/
#                 |-- certs/
#                 |-- private/
#                 |-- logstash/
#                 |   |-- certs/
#                 |   |-- private/
#                 |-- kibana/
#                 |   |-- certs/
#                 |   |-- private/
# Arguments:
#  $1 - root directory of the certificates. The default is /etc/pki/elk/
# Returns:
#  None
############################################################
generate_certs() {
    echo "[*] Generating certificates..."

    # Create the necessary folders
    mkdir -p /etc/pki/elk/logstash/certs 
    mkdir $CERT_DIR/logstash/private
    mkdir -p /etc/pki/elk/kibana/certs 
    mkdir $CERT_DIR/kibana/private
    mkdir -p $CERT_DIR/certs
    mkdir $CERT_DIR/private

    # Generate the root certificate and key
    # TODO: Error check
    openssl genrsa -out /etc/pki/elk/private/server_root.key 4092
    echo -e "${SUCCESS}[+] Generated root key in $CERT_DIR/private/${NC}"
    openssl req -x509 -new -nodes -key $CERT_DIR/private/server_root.key -sha256 -days 3650 -out /etc/pki/elk/certs/server_root.pem
    echo -e "${SUCCESS}[+] Generated root certificate in $CERT_DIR/certs/${NC}"

    # Generate the Logstash certificate and key
    openssl req -new -sha256 -nodes -out $CERT_DIR/logstash/private/logstash.csr -newkey rsa:4092 -keyout $CERT_DIR/logstash/private/logstash.key -config <( cat server_root.conf )
    echo -e "${SUCCESS}[+] Generated logstash key in $CERT_DIR/logstash/private/${NC}"
    openssl x509 -req -in $CERT_DIR/logstash/private/logstash.csr -CA $CERT_DIR/certs/server_root.pem -CAkey $CERT_DIR/private/server_root.key -CAcreateserial -out $CERT_DIR/logstash/certs/logstash.crt -days 3650 -sha256 -extfile v3.ext
    echo -e "${SUCCESS}[+] Generated logstash cert in $CERT_DIR/logstash/certs/${NC}"

    # Generate the Kibana certificate and key
    openssl req -new -sha256 -nodes -out $CERT_DIR/kibana/private/kibana.csr -newkey rsa:4092 -keyout $CERT_DIR/kibana/private/kibana.key -config <( cat server_root.conf )
    echo -e "${SUCCESS}[+] Generated kibana key in $CERT_DIR/kibana/private/${NC}"
    openssl x509 -req -in $CERT_DIR/kibana/private/kibana.csr -CA $CERT_DIR/certs/server_root.pem -CAkey $CERT_DIR/private/server_root.key -CAcreateserial -out $CERT_DIR/kibana/certs/kibana.crt -days 3650 -sha256 -extfile v3.ext
    echo -e "${SUCCESS}[+] Generated kibana cert in $CERT_DIR/kibana/certs/${NC}"
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

# Generate certificates. The certificate generation done here satisfies the
# strict Chrome/Chromium requirements for self-signed certs
generate_certs
