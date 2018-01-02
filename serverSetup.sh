#!/bin/bash
# Author: Tom Daniels <trd6577@g.rit.edu>
# File: serverSetup.sh
# Purpose: Sets up a secure ELK server instance

ERROR="\033[0;31m"   # Red
SUCCESS="\033[0;32m" # Green
WARNING="\033[1;33m" # Yellow
NC="\033[0m"         # No color

# You must be root to run this script
if [ $(id -u) != 0 ]
then
    echo -e "${ERROR}[-] Error: You must be root to run this script${NC}"
    exit
fi

# TODO: Add a command line argument to skip all confirmations
# Install Java8. We'll do this by adding another repository to apt
echo -en "${WARNING}[*] Warning:${NC} The following repository will be added ppa:webupd8team/java. Is this okay? [y/N] "
read -n 1 RESPONSE

if [[ $RESPONSE != "\r" ]]; then echo ""; fi  # Keep consistent lines
if [[ $RESPONSE != "y" && $RESPONSE != "Y" ]]
then
    echo skipping
else
    echo installing
fi
