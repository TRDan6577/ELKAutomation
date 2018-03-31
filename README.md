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
* The server that will be running the ELK stack should have a DNS resolvable hostname.
If this is not the case, you will not be able to generate certificates using this program
(at this point in time)
* If you plan on using one of the [ELK beats data shippers](https://elastic.co/products/beats)
for one of your clients, you will need to enter the DNS resolvable name of one
of your clients into client.conf
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
* Display a warning if client.conf is not filled out
* Get a way to read a list of clients to make certificates for
