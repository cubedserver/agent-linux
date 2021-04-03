#!/bin/bash

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SERVERKEY=$1
GATEWAY=$2
AGENT_URL=https://raw.githubusercontent.com/cubedserver/agent-linux/main/agent.sh
LOG=/tmp/cubedserver.log

echo -e "\e[32mWelcome to Cubed Agent Installer!\e[0m\n"

# Are we running as root
if [ $(id -u) != "0" ]; then
	echo "Cubed Agent installer needs to be run with root priviliges"
	echo "Try again with root privilileges"
	exit 1;
fi

echo -e "\e[32mInstalling Dependencies...\e[0m"

# RHEL / CentOS / etc
if [ -n "$(command -v yum)" ]; then
	yum -y install cronie gzip curl >> $LOG 2>&1
	service crond start >> $LOG 2>&1
	chkconfig crond on >> $LOG 2>&1

	# Check if perl available or not
	if ! type "perl" >> $LOG 2>&1; then
		yum -y install perl >> $LOG 2>&1
	fi

	# Check if unzip available or not
	if ! type "unzip" >> $LOG 2>&1; then
		yum -y install unzip >> $LOG 2>&1
	fi

	# Check if curl available or not
	if ! type "curl" >> $LOG 2>&1; then
		yum -y install curl >> $LOG 2>&1
	fi
fi

# Debian / Ubuntu
if [ -n "$(command -v apt-get)" ]; then
	apt-get update -y >> $LOG 2>&1
	apt-get install -y cron curl gzip >> $LOG 2>&1
	service cron start >> $LOG 2>&1

	# Check if perl available or not
	if ! type "perl" >> $LOG 2>&1; then
		apt-get install -y perl >> $LOG 2>&1
	fi

	# Check if unzip available or not
	if ! type "unzip" >> $LOG 2>&1; then
		apt-get install -y unzip >> $LOG 2>&1
	fi

	# Check if curl available or not
	if ! type "curl" >> $LOG 2>&1; then
		apt-get install -y curl >> $LOG 2>&1
	fi
fi

# ArchLinux
if [ -n "$(command -v pacman)" ]; then
	pacman -Sy  >> $LOG 2>&1
	pacman -S --noconfirm cronie curl gzip >> $LOG 2>&1
	systemctl start cronie >> $LOG 2>&1
	systemctl enable cronie >> $LOG 2>&1

	# Check if perl available or not
	if ! type "perl" >> $LOG 2>&1; then
		pacman -S --noconfirm perl >> $LOG 2>&1
	fi

	# Check if unzip available or not
	if ! type "unzip" >> $LOG 2>&1; then
		pacman -S --noconfirm unzip >> $LOG 2>&1
	fi

	# Check if curl available or not
	if ! type "curl" >> $LOG 2>&1; then
		pacman -S --noconfirm curl >> $LOG 2>&1
	fi
fi


# OpenSuse
if [ -n "$(command -v zypper)" ]; then
	zypper --non-interactive install cronie curl gzip >> $LOG 2>&1
	service cron start >> $LOG 2>&1

	# Check if perl available or not
	if ! type "perl" >> $LOG 2>&1; then
		zypper --non-interactive install perl >> $LOG 2>&1
	fi

	# Check if unzip available or not
	if ! type "unzip" >> $LOG 2>&1; then
		zypper --non-interactive install unzip >> $LOG 2>&1
	fi

	# Check if curl available or not
	if ! type "curl" >> $LOG 2>&1; then
		zypper --non-interactive install curl >> $LOG 2>&1
	fi
fi


# Gentoo
if [ -n "$(command -v emerge)" ]; then

	# Check if crontab is present or not available or not
	if ! type "crontab" >> $LOG 2>&1; then
		emerge cronie >> $LOG 2>&1
		/etc/init.d/cronie start >> $LOG 2>&1
		rc-update add cronie default >> $LOG 2>&1
 	fi

	# Check if perl available or not
	if ! type "perl" >> $LOG 2>&1; then
		emerge perl >> $LOG 2>&1
	fi

	# Check if unzip available or not
	if ! type "unzip" >> $LOG 2>&1; then
		emerge unzip >> $LOG 2>&1
	fi

	# Check if curl available or not
	if ! type "curl" >> $LOG 2>&1; then
		emerge net-misc/curl >> $LOG 2>&1
	fi

	# Check if gzip available or not
	if ! type "gzip" >> $LOG 2>&1; then
		emerge gzip >> $LOG 2>&1
	fi
fi


# Slackware
if [ -f "/etc/slackware-version" ]; then

	if [ -n "$(command -v slackpkg)" ]; then

		# Check if crontab is present or not available or not
		if ! type "crontab" >> $LOG 2>&1; then
			slackpkg -dialog=off -batch=on -default_answer=y install dcron >> $LOG 2>&1
		fi

		# Check if perl available or not
		if ! type "perl" >> $LOG 2>&1; then
			slackpkg -dialog=off -batch=on -default_answer=y install perl >> $LOG 2>&1
		fi

		# Check if unzip available or not
		if ! type "unzip" >> $LOG 2>&1; then
			slackpkg -dialog=off -batch=on -default_answer=y install infozip >> $LOG 2>&1
		fi

		# Check if curl available or not
		if ! type "curl" >> $LOG 2>&1; then
			slackpkg -dialog=off -batch=on -default_answer=y install curl >> $LOG 2>&1
		fi

		# Check if gzip available or not
		if ! type "gzip" >> $LOG 2>&1; then
			slackpkg -dialog=off -batch=on -default_answer=y install gzip >> $LOG 2>&1
		fi

	else
		echo "Please install slackpkg and re-run installation."
		exit 1;
	fi
fi


# Is Cron available?
if [ ! -n "$(command -v crontab)" ]; then
	echo "Cron is required but we could not install it."
	echo "Exiting installer"
	exit 1;
fi

# Is CURL available?
if [  ! -n "$(command -v curl)" ]; then
	echo "CURL is required but we could not install it."
	echo "Exiting installer"
	exit 1;
fi

if [ -f /opt/cubedserver/agent.sh ]; then

	echo -e "\e[32mRemoving previous installation...\e[0m"

	# Remove folder
	rm -rf /opt/cubedserver
	# Remove crontab
	crontab -r -u cubedagent >> $LOG 2>&1
	# Remove user
	userdel cubedagent >> $LOG 2>&1
fi

mkdir -p /opt/cubedserver >> $LOG 2>&1
wget -N --no-check-certificate -O /opt/cubedserver/agent.sh $AGENT_URL >> $LOG 2>&1

echo "$SERVERKEY" > /opt/cubedserver/serverkey
echo "$GATEWAY" > /opt/cubedserver/gateway

# Did it download ?
if ! [ -f /opt/cubedserver/agent.sh ]; then
	echo "Unable to install!"
	echo "Exiting installer"
	exit 1;
fi

useradd cubedagent -r -d /opt/cubedserver -s /bin/false >> $LOG 2>&1
groupadd cubedagent >> $LOG 2>&1

# Disable cagefs for nmon
if [ -f /usr/sbin/cagefsctl ]; then
	/usr/sbin/cagefsctl --disable cubedagent >> $LOG 2>&1
fi

# Modify user permissions
chown -R cubedagent:cubedagent /opt/cubedserver && chmod -R 700 /opt/cubedserver >> $LOG 2>&1

# Write the cron file

TASK=/etc/cron.d/cubedserver

echo "# Server Monitoring Sync Command" > $TASK
echo "# Note: You can optionally increase how often this runs. We will only log 1 record per minute maximum." >> $TASK
echo "# You can also comment it out if you do not wish to use server monitoring, or you can disable it" >> $TASK
echo "# inside your Deployer account and we will ignore the data being sent." >> $TASK
echo "# No identifying information is sent, and records are kept for a maximum of 14 days." >> $TASK
echo "* * * * * bash /opt/cubedserver/agent.sh >/dev/null 2>&1" >> $TASK

crontab -u cubedagent $TASK

# Run the first sync
echo -e "\e[32mRunning first sync...\e[0m"
bash /opt/cubedserver/agent.sh >/dev/null 2>&1

# Setup complete
echo -e "\e[32mSetup Complete!\e[0m"
