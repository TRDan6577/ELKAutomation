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
to those setting up a distributed ELK environment.

It's important to note that while the configuration files contain some options,
there is no future plan for them to contain all configurable options. If the
configuration file doesn't contain an option that you think it shouuld,
please send a pull request. The idea with the configuration files is to
keep it simple. Give options that you think may be used by many people - not
options that are only used in very specific cirumstances.

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
to edit are surrounded by carrots (< >). Just give the value the carrots ask
for and the remove the carrots. After filling out these three files, just run
serverSetup.sh with administrative privileges.

## Things TODO
* Create a diagram of final product after scripts are done. Include explaination
can access them
* Display a warning if client.conf is not filled out
