# ELKAutomation
A quick and easy ELK stack server install

## What is it
ELKAutomation is a series of scripts and configuration files that make installing
the ELK stack extremely quick and easy. My first manual install of the ELK stack
took me multiple days - I struggled to find good and up-to-date 'how-to' guides for
an installation. The whole process was like fighting a hydra; every time I solved an
issue, 2 more issues came up. While many other people may not have had as much of
a struggling installing the stack as I have, I figure that these scripts could still
be useful for people that are laz - I mean ... uhh... efficient. It could also be beneficial
to those setting up a distributed ELK environment, though ELKAutomation does not
currently support a distributed enviornment.

For specific details on how it works, please see the 
[wiki](https://github.com/TRDan6577/ELKAutomation/wiki).

## Software Installed By ELKAutomation
* Latest version of [Nginx](https://nginx.com)
* Latest version of [Elasticsearch](https://elastic.co/products/elasticsearch) (6.x branch only)
* Latest version of [Logstash](https://elastic.co/products/logstash) (6.x branch only)
* Latest version of [Kibana](https://elastic.co/products/kibana) (6.x branch only)
* Latest version of apt-transport-https
* Latest version of apache2-utils
* Latest version of OpenJDK 8

## Prerequisites
* If you wish to secure all communications with your ELK instance, the server that will
be running the ELK stack AND all clients you wish to send logs from should have DNS 
resolvable hostnames. You can send logs from your clients to the Logstash instance
running on the ELKAutomation server using one of the 
[ELK beats data shippers](https://elastic.co/products/beats). If neither your server
nor your clients have resolvable hostnames, the certificates generated using this
program will not function correctly. If your clients do not have DNS resolvable
hostnames but your sever does, you can still secure communications to the nginx instance.
* ELKAutomation currently only supports systems that use the apt package manager.
Contributions to ELKAutomation that have support for other systems are welcome =)

## Installation
`git clone https://github.com/trdan6577/elkautomation.git`

## Usage
### Server Setup
In order to actually install the ELK stack using this program, you MUST edit
client.conf, server\_root.conf, and v3.ext. Conveniently, the parts you need
to edit are surrounded by carrots (< >). Just give the carrots the value they ask
for and the remove the carrots. After filling out these three files, just run
serverSetup.sh with administrative privileges.

## Things TODO
* Get a way to read a list of clients to make certificates for
* Have an option for no security (useful in private testing environments)
