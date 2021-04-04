#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOG=/tmp/cubedserver.log

echo -e "\e[32Cubed Agent Uninstaller\e[0m"

# Are we running as root
if [ $(id -u) != "0" ]; then
	echo "nCubed Agent uninstaller needs to be run with root priviliges"
	echo "Try again with root privilileges"
	exit 1;
fi


if [ -f /opt/cubedserver/agent.sh ]; then
	# Remove folder
	rm -rf /opt/cubedserver
	
	# Remove crontab
	crontab -r -u cubedagent >> $LOG 2>&1
	
	# Remove user
	userdel cubedagent >> $LOG 2>&1
fi

# Setup complete
echo -e "\e[32mUninstallation Completed!\e[0m"