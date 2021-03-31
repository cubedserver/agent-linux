#!/bin/bash

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOG=/tmp/deployer.log

echo -e "\e[32mDeployer Agent Uninstaller\e[0m"

# Are we running as root
if [ $(id -u) != "0" ]; then
	echo "nMon Agent uninstaller needs to be run with root priviliges"
	echo "Try again with root privilileges"
	exit 1;
fi


if [ -f /opt/deployer/agent.sh ]; then
	# Remove folder
	rm -rf /opt/deployer
	
	# Remove crontab
	crontab -r -u deployeragent >> $LOG 2>&1
	
	# Remove user
	userdel deployeragent >> $LOG 2>&1
fi

# Setup complete
echo -e "\e[32mUninstallation Completed!\e[0m"