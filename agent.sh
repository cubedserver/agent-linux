#!/bin/bash

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SERVERKEY=$(cat /opt/cubedserver/serverkey)
GATEWAY=$(cat /opt/cubedserver/gateway)
AGENT_VERSION="1.0.0"
POST=''

function merge_data()
{
	POST="$POST{$1}$2{/$1}"
}

function get_os() {
	if [ -f /etc/lsb-release ]; then
		os_name=$(lsb_release -s -d)
	elif [ -f /etc/debian_version ]; then
		os_name="Debian $(cat /etc/debian_version)"
	elif [ -f /etc/redhat-release ]; then
		os_name=`cat /etc/redhat-release`
	else
		os_name="$(cat /etc/*release | grep '^PRETTY_NAME=\|^NAME=\|^DISTRIB_ID=' | awk -F\= '{print $2}' | tr -d '"' | tac)"
		if [ -z "$os_name" ]; then
			os_name="$(uname -s)"
		fi
	fi
	echo "$os_name"
}

function get_cpu_speed() {
	cpu_speed=$(cat /proc/cpuinfo | grep 'cpu MHz' | awk -F\: '{print $2}' | uniq)
	if [ -z "$cpu_speed" ]; then
		cpu_speed=$(lscpu | grep 'CPU MHz' | awk -F\: '{print $2}' | sed -e 's/^ *//g' -e 's/ *$//g')
	fi
	echo "$cpu_speed"
}

function get_default_interface() {
	interface="$(ip route get 4.2.2.1 | grep dev | awk -F'dev' '{print $2}' | awk '{print $1}')"
	if [ -z $interface ]; then
		interface="$(ip link show | grep 'eth[0-9]' | awk '{print $2}' | tr -d ':' | head -n1)"
	fi
	echo "$interface"
}

function get_active_connections() {
	if [ -n "$(command -v ss)" ]; then
		active_connections="$(ss -tun | tail -n +2 | wc -l)"
	else
		active_connections="$(netstat -tun | tail -n +3 | wc -l)"
	fi
	echo "$active_connections"
}

function get_ping_latency() {
	ping_google="$(ping -B -w 2 -n -c 2 google.com | grep rtt | awk -F '/' '{print $5}')"
	echo "$ping_google"
}

# Hostname
hostname=$(hostname)
merge_data 'hostname' "$hostname"

# Kernel
kernel=$(uname -r)
merge_data 'kernel' "$kernel"

# Time
time=$(date +%s)
merge_data 'time' "$time"

# OS
os=$(get_os)
merge_data 'os' "$os"

# OS Arch
os_arch=`uname -m`","`uname -p`
merge_data 'os_arch' "$os_arch"

# CPU Model
cpu_model=$(cat /proc/cpuinfo | grep 'model name' | awk -F\: '{print $2}' | uniq)
merge_data 'cpu_model' "$cpu_model"

# CPU Cores
cpu_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
merge_data 'cpu_cores' "$cpu_cores"

# CPU Speed
cpu_speed=$(get_cpu_speed)
merge_data 'cpu_speed' "$cpu_speed"

# CPU Load
cpu_load=$(cat /proc/loadavg | awk '{print $1","$2","$3}')
merge_data 'cpu_load' "$cpu_load"

# CPU Info
cpu_info=$(grep -i cpu /proc/stat | awk '{print $1","$2","$3","$4","$5","$6","$7","$8","$9","$10","$11";"}' | tr -d '\n')
merge_data 'cpu_info' "$cpu_info"

sleep 1s

cpu_info_current=$(grep -i cpu /proc/stat | awk '{print $1","$2","$3","$4","$5","$6","$7","$8","$9","$10","$11";"}' | tr -d '\n')
merge_data 'cpu_info_current' "$cpu_info_current"

# Disks
disks=$(df -P -T -B 1k | grep '^/' | awk '{print $1","$2","$3","$4","$5","$6","$7";"}' | tr -d '\n')
merge_data 'disks' "$disks"

# Disk Usage
disks_inodes=$(df -P -i | grep '^/' | awk '{print $1","$2","$3","$4","$5","$6";"}' | tr -d '\n')
merge_data 'disks_inodes' "$disks_inodes"

# File Descriptors
file_descriptors=$(cat /proc/sys/fs/file-nr | awk '{print $1","$2","$3}')
merge_data 'file_descriptors' "$file_descriptors"

# RAM Total
ram_total=$(free | grep ^Mem: | awk '{print $2}')
merge_data 'ram_total' "$ram_total"

# RAM Free
ram_free=$(free | grep ^Mem: | awk '{print $4}')
merge_data 'ram_free' "$ram_free"

# RAM Caches
ram_caches=$(free | grep ^Mem: | awk '{print $6}')
merge_data 'ram_caches' "$ram_caches"

# RAM Buffers
ram_buffers=0
merge_data 'ram_buffers' "$ram_buffers"

# RAM USAGE
ram_usage=$(free | grep ^Mem: | awk '{print $3}')
merge_data 'ram_usage' "$ram_usage"

# SWAP Total
swap_total=$(cat /proc/meminfo | grep ^SwapTotal: | awk '{print $2}')
merge_data 'swap_total' "$swap_total"

# SWAP Free
swap_free=$(cat /proc/meminfo | grep ^SwapFree: | awk '{print $2}')
merge_data 'swap_free' "$swap_free"

# SWAP Usage
swap_usage=$(($swap_total-$swap_free))
merge_data 'swap_usage' "$swap_usage"

# Default Interface
default_interface=$(get_default_interface)
merge_data 'default_interface' "$default_interface"

# All Interfaces
all_interfaces=$(tail -n +3 /proc/net/dev | tr ":" " " | awk '{print $1","$2","$10","$3","$11";"}' | tr -d ':' | tr -d '\n')
merge_data 'all_interfaces' "$all_interfaces"

sleep 1s

all_interfaces_current=$(tail -n +3 /proc/net/dev | tr ":" " " | awk '{print $1","$2","$10","$3","$11";"}' | tr -d ':' | tr -d '\n')
merge_data 'all_interfaces_current' "$all_interfaces_current"

# IPv4 Addresses
ipv4_addresses=$(ip -f inet -o addr show | awk '{split($4,a,"/"); print $2","a[1]";"}' | tr -d '\n')
merge_data 'ipv4_addresses' "$ipv4_addresses"

# IPv6 Addresses
ipv6_addresses=$(ip -f inet6 -o addr show | awk '{split($4,a,"/"); print $2","a[1]";"}' | tr -d '\n')
merge_data 'ipv6_addresses' "$ipv6_addresses"

# Active Connections
active_connections=$(get_active_connections)
merge_data 'active_connections' "$active_connections"

# Ping Latency
ping_latency=$(get_ping_latency)
merge_data 'ping_latency' "$ping_latency"

# SSH Sessions
ssh_sessions=$(who | wc -l)
merge_data 'ssh_sessions' "$ssh_sessions"

# Uptime
uptime=$(cat /proc/uptime | awk '{print $1}')
merge_data 'uptime' "$uptime"

# Processes
processes=$(ps -e -o pid,ppid,rss,vsz,uname,pmem,pcpu,comm,cmd --sort=-pcpu,-pmem | awk '{print $1","$2","$3","$4","$5","$6","$7","$8","$9";"}' | tr -d '\n')
merge_data 'processes' "$processes"

# Upload data

curl --max-time 50 --insecure --connect-timeout 60 --silent "$GATEWAY" \
-H "User-Agent: CubedAgent v$AGENT_VERSION (Shell Script)" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
--data @<(cat <<EOF
    {
      "serverkey": "$SERVERKEY",
      "data": "$POST"
    }
EOF
)