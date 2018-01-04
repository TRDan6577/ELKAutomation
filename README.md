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
to those setting up a distributed ELK environment.

It's important to note that while the configuration files contain some options,
there is no future plan for them to contain all configurable options. If the
configuration file doesn't contain an option that you think it shouuld,
please send a pull request. The idea with the configuration files is to
keep it simple. Give options that you think may be used by many people - not
options that are only used in very specific cirumstances.

## Installation
`git clone https://github.com/trdan6577/elkautomation.git`

## Usage
### Server Setup
Place the automation.conf file and the serversetup.sh file onto the server you want
to host the ELK stack. Make sure the configurations in the automation.conf file are
what you want and then run the serversetup.sh file

## Things TODO
* Create a diagram of final product after scripts are done. Include explaination
* Add a way to restrict access to the private keys so only root and a service
can access them
