#!/bin/bash
# Author: Tom Daniels <trd6577@g.rit.edu>
# File: serverSetup.sh
# Purpose: Sets up a secure ELK server instance
# License: Mozilla Public License 2.0 (see included 'license' file)

# Set output color variables
ERROR="\033[0;31m"   # Red
SUCCESS="\033[0;32m" # Green
WARNING="\033[1;33m" # Yellow
NC="\033[0m"         # No color

# Set configuration variables
CERT_DIR=/etc/pki/elk
IP_ADDR=$(ip route get 8.8.8.8 | awk 'NR==1 {print$NF}')
DHPARAM_SIZE=1024
CLIENT=1  # Assume that the user changed the client.conf file

# Read in the config file for any variable value changes
. conf/automation.conf

############################################################
# Function: prereq_check
# Purpose:  This function checks to make sure all necessary prerequisites are
#           met before running the program. This includes the program being run
#           as root and the certificate configuration files being changed.
# Arugments:
#  None
# Returns:
#  None. Exits if error occurred
############################################################
prereq_check(){
    # You must be root to run this script
    if [ $(id -u) != 0 ]; then
        echo -e "${ERROR}[-] Error: You must be root to run this script${NC}"
        exit 1
    fi

    # Make sure that the user edited server_root.conf and v3.ext
    if [[ $(sha256sum conf/server_root.conf) == "657f509b06782c95ab44a4e46675139cdb77163402e1e578def076e1c446c328  conf/server_root.conf" ]]; then
        echo -e "${ERROR}[-] Error: You must fill in information in the"\
            "server_root.conf file to successfully create certificates"
        exit 1
    fi

    if [[ $(sha256sum conf/v3.ext) == "a0a5335daa6295596852a1758f0c1b3493dd25ffe81c0a44e59b08df97a410a5  conf/v3.ext" ]]; then
        echo -e "${ERROR}[-] Error: You must fill in information in the v3.ext"\
            "file to successfully create certificates"
        exit 1
    fi

    # Make sure the user configured the client.conf file for the certificates
    if [[ $(sha256sum conf/client.conf) == "be486eab65fcb632729bd3c7c0965376a8e716fc6d4f303eb7198e56135bc132  conf/client.conf" ]]; then
        echo -n -e "${WARNING}[!] WARNING: You must fill in the information in the"\
            "client.conf file to successfully create a client certificate."\
            "You may continue without a client certificate, but this means"\
            "that: \n"\
            "1) Anyone can send logs to Logstash and it will accept them\n"\
            "2) The logs sent will not be encrypted.\n\n${NC} Is this"\
            "acceptable? (y or n): "
        read ans
        while [[ $ans != 'y' ]] && [[ $ans != 'n' ]]; do
            echo -n "Please enter y or n: "
            read ans
        done
        if [[ $ans == 'y' ]]; then
            CLIENT=0
        else
            echo "Exiting..."
            exit 1
        fi
    fi

    # Make sure the IP address variable is correctly set
    if [[ $IP_ADDR == "" ]] || [[ $IP_ADDR == "127.0.0.1" ]]; then
        echo -e "${ERROR}[-] Error: Unable to automatically set your IP"\
            "address. Please set it manually in conf/automation.conf."
        exit 1
    fi

    # Get the password for the nginx logon 
    echo -n "Enter the password to be used for nginx authentication: "
    read -s PASSWORD
    echo
}

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
# Purpose:  Generates the root, logstash, client, and nginx
#           certificates. The certificates generated follow the requirements
#           for Chrome/Chromium so they won't give that angry untrusted page
#           in a web browser. The directory structure is as follows:
#               $ROOT_DIR/
#                 |-- certs/
#                 |-- private/
#                 |-- logstash/
#                 |   |-- certs/
#                 |   |-- private/
#                 |-- client/
#                 |   |-- certs/
#                 |   |-- private/
#                 |-- nginx/
#                 |   |-- certs/
#                 |   |-- dhgroup/
#                 |   |-- private/
# Arguments:
#  $1 - root directory of the certificates. The default is /etc/pki/elk/
# Returns:
#  None
############################################################
generate_certs() {
    echo "[*] Generating certificates..."

    # Create the necessary folders
    mkdir -p $CERT_DIR/logstash/certs 
    mkdir $CERT_DIR/logstash/private
    mkdir -p $CERT_DIR/nginx/certs
    mkdir $CERT_DIR/nginx/private
    mkdir -p $CERT_DIR/certs
    mkdir $CERT_DIR/private

    # Generate the root certificate and key
    openssl genrsa -out /etc/pki/elk/private/server_root.key 4092
    echo -e "  ${SUCCESS}[+] Generated root key in $CERT_DIR/private/${NC}"
    openssl req -x509 -new -nodes -key $CERT_DIR/private/server_root.key \
        -sha256 -days 3650 -out /etc/pki/elk/certs/server_root.pem -config \
        <( cat conf/server_root.conf )
    echo -e "  ${SUCCESS}[+] Generated root certificate in $CERT_DIR/certs/${NC}"

    # Generate the Logstash certificate and key
    openssl req -new -sha256 -nodes -out $CERT_DIR/logstash/private/logstash.csr \
        -newkey rsa:4092 -keyout $CERT_DIR/logstash/private/logstash.key -config \
        <( cat conf/server_root.conf )
    echo -e "  ${SUCCESS}[+] Generated logstash key in $CERT_DIR/logstash/private/${NC}"
    openssl x509 -req -in $CERT_DIR/logstash/private/logstash.csr -CA \
        $CERT_DIR/certs/server_root.pem -CAkey $CERT_DIR/private/server_root.key \
        -CAcreateserial -out $CERT_DIR/logstash/certs/logstash.crt -days 3650 \
        -sha256 -extfile conf/v3.ext
    echo -e "  ${SUCCESS}[+] Generated logstash cert in $CERT_DIR/logstash/certs/${NC}"

    # Generate the nginx certificate and key
    openssl req -new -sha256 -nodes -out $CERT_DIR/nginx/private/nginx.csr \
        -newkey rsa:4092 -keyout $CERT_DIR/nginx/private/nginx.key -config \
        <( cat conf/server_root.conf )
    echo -e "  ${SUCCESS}[+] Generated nginx key in $CERT_DIR/nginx/private/${NC}"
    openssl x509 -req -in $CERT_DIR/nginx/private/nginx.csr -CA \
        $CERT_DIR/certs/server_root.pem -CAkey $CERT_DIR/private/server_root.key \
        -CAcreateserial -out $CERT_DIR/nginx/certs/nginx.crt -days 3650 -sha256 \
        -extfile conf/v3.ext
    echo -e "  ${SUCCESS}[+] Generated nginx cert in $CERT_DIR/nginx/certs/${NC}"

    # Make sure that we're using certs for the client
    if [[ $CLIENT == 1 ]]; then
        # Create the directories
        mkdir -p $CERT_DIR/client_beat/certs
        mkdir $CERT_DIR/client_beat/private

        # Generate the client certificate and key
        openssl req -new -sha256 -nodes -out \
            $CERT_DIR/client_beat/private/client_beat.csr -newkey rsa:4092 -keyout \
            $CERT_DIR/client_beat/private/client_beat.key -config <( cat conf/client.conf )
        echo -e "  ${SUCCESS}[+] Generated client key in $CERT_DIR/client_beat/private/${NC}"
        openssl x509 -req -in $CERT_DIR/client_beat/private/client_beat.csr -CA \
            $CERT_DIR/certs/server_root.pem -CAkey $CERT_DIR/private/server_root.key \
            -CAcreateserial -out $CERT_DIR/client_beat/certs/client_beat.crt -days \
            3650 -sha256
        echo -e "  ${SUCCESS}[+] Generated client cert in $CERT_DIR/client_beat/certs/${NC}"
    fi

}

################################# Script start ################################# 

# Check to make sure the prerequisites are met for the program
prereq_check

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
echo -e "[*] Adding the repository to the list in /etc/sources... ${SUCCESS}Success${NC}"

# Update again with the new repository
update_repos

# Install elasticsearch, kibana, logstash, apt-transport-https, apache2-utils,
# and nginx
echo -n "[*] Installing elasticsearch, logstash, kibana, nginx, and apt-transport-https... "
apt-get -y -q2 install apt-transport-https elasticsearch logstash kibana nginx \
    apache2-utils > /dev/null 2>&1
check_error "attempting to install the packages" "apt-get install" $?

# Generate certificates. The certificate generation done here satisfies the
# strict Chrome/Chromium requirements for self-signed certs
generate_certs

# Configure elasticsearch. We want to listen on localhost:9200
echo -n "[*] Configuring elasticsearch... "
sudo sed -i -e 's/#network.host: 192.168.0.1/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml
sudo sed -i -e 's/#http.port: 9200/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml
sudo sed -i -e 's/#node.name: node-1/node.name: ${HOSTNAME}/g' /etc/elasticsearch/elasticsearch.yml
sudo sed -i -e 's/#cluster.name: my-application/cluster.name: elk-automation/g' /etc/elasticsearch/elasticsearch.yml

# Make sure the heap size is set to below the cutoff JVM uses for compressed
# object pointers. See https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html
# for more info
MEM_TOTAL=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
ES_JAVA_MEM=$((MEM_TOTAL/2048))
if [ $ES_JAVA_MEM -gt 30000 ]; then
    ES_JAVA_MEM=25000
fi
ES_JAVA_OPTS="-Xms$(echo $ES_JAVA_MEM)m -Xmx$(echo $ES_JAVA_MEM)m"
export ES_JAVA_OPTS
echo -e "${SUCCESS}Done${NC}"

# Put the logstash input file for beats in /etc/logstash/conf.d/
echo -n "[*] Configuring logstash... "
if ! [ -d /etc/logstash/conf.d ]; then
    mkdir -p /etc/logstash/conf.d/
fi
sed -i -e 's|\"CERTS DIR HERE\"|'"$CERT_DIR"'/|g' conf/beatsInput.conf
# Make sure we're using client certificates
if [[ $CLIENT != 1 ]]; then
    sed -i -e "s/true/false  # User didn\'t generate client cert/g" conf/beatsInput.conf
fi
mv conf/beatsInput.conf /etc/logstash/conf.d/
chown -R logstash:logstash /etc/logstash
echo -e "${SUCCESS}Success${NC}"

# Configure nginx
echo -n "[*] Configuring nginx... "
sed -i -e 's|\"CERTS DIR HERE\"|'"$CERT_DIR"'/|g' conf/default
sed -i -e 's/"IP ADDR HERE"/'"$IP_ADDR"'/g' conf/default
cp conf/default /etc/nginx/sites-available/
mv conf/default /etc/nginx/sites-enabled/
sudo htpasswd -b -c /etc/nginx/.htpasswd admin "$PASSWORD"
echo -e "${SUCCESS}Success${NC}"

# Generate the dhparams for nginx
echo -e "[*] Creating dhparams file for nginx - ${WARNING}WARNING - THIS WILL TAKE A LONG TIME${NC}"
mkdir $CERT_DIR/nginx/dhgroup/
openssl dhparam -out $CERT_DIR/nginx/dhgroup/dhparam.pem $DHPARAM_SIZE
echo -e "${SUCCESS}Success${NC}"

# Start all the services! We're done =)
echo -n "[*] Starting elasticsearch... "
service elasticsearch start
check_error "attempting to start elasticsearch" "service elasticsearch start" $?
echo -n "[*] Starting logstash... "
service logstash start
check_error "attempting to start logstash" "service logstash start" $?
echo -n "[*] Starting kibana... "
service kibana start
check_error "attempting to start kibana" "service kibana start" $?
echo -n "[*] Starting nginx... "
service nginx restart
check_error "attempting to restart nginx" "service nginx restart" $?

echo -e "\n\n${SUCCESS}[+] Successfully installed the ELK stack${NC}\n Your"\
    "username for nginx's basic authentication prompt is admin. The password"\
    "is the password you configured earlier. Have fun!"
