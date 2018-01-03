# ELKAutomation
For a quick and easy ELK stack server install

## What is it
ELKAutomation is a series of scripts and configuration files that make installing
the ELK stack extremely quick and easy. My first manual install of the ELK stack
took me multiple days - I struggled to find good and up-to-date 'how-to' guides for
an installation. The whole process was like fighting a hydra; every time I solved an
issue, 2 more issues came up. While many other people may not have had as much of
a struggling installing the stack as I have, I figure that these scripts could still
be useful for people that are laz - I mean efficient. It could also be beneficial
to those setting up a distributed ELK environment

## Installation
`git clone https://github.com/trdan6577/elkautomation.git`

## Usage
### Server Setup
Place the automation.conf file and the serversetup.sh file onto the server you want
to host the ELK stack. Make sure the configurations in the automation.conf file are
what you want and then run the serversetup.sh file
