#!/usr/bin/bash
# Purpose: Creates a system information report and sends the output to a file for analysis

# Create reports directory if it doesn't exist
mkdir -p reports || { echo "Failed to create reports directory!"; exit 1; }

# Timestamp report file
timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
outfile="reports/systemreport_$timestamp.txt"

{
	echo '--------------'
	echo 'System Report'
	echo '-------------'
	echo

	# Print date
	date=$(date +'%A %B %d, %Y (%I:%M %p)')
	echo "Report Date: $date"
	echo

	# Linux system info
	echo
	echo 'System Info'
	echo '-----------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
	kernel=$(uname -rv)
	hostname=$(hostname)
	process_count=$(ps -ef | wc -l)
	services=$(systemctl list-units --type=service --state=running | sed '1,1d;$d')
	failedlogins=$(grep "Failed password" /var/log/auth.log | grep -v "sudo" | tail -n 10)

	printf "Kernel: %s\nHostname: %s\nProcess Count: %s\nActive Services:\n%s\nFailed Login Attempts:\n%s\n" \
	  "$kernel" "$hostname" "$process_count" "$services" "$failedlogins"

	echo
	echo "=============================="

	# Network info
	echo 'Network Info'
	echo '------------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"

	ipaddress=$(ip -4 address show | grep inet)
	iproute=$(ip route show)
	connections=$(ss -tulnp)
	publicip=$(curl -s ifconfig.me)

	printf "IP Addresses:\n%s\n\nRouting Table:\n%s\nActive Network Connections:\n%s\nPublic IP Address:\n%s\n" \
	  "$ipaddress" "$iproute" "$connections" "$publicip"

	echo
	echo "=============================="

	# System Utilization Info
	echo 'System Utilization Info'
	echo '-----------------------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"

	ram=$(free -h)
	uptime=$(uptime)
	cpu=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | grep -v "ps " | head -n 20)
	disk=$(df -h)
	loadavg=$(uptime | awk -F'load average:' '{ print $2 }')
	swap=$(free -h | grep Swap)

	printf "RAM Utilization:\n%s\n\nSystem Uptime:\n%s\nCPU Utilization:\n%s\nDisk Usage:\n%s\nLoad Average:\n%s\nSwap Usage:\n%s\n" \
		"$ram" "$uptime" "$cpu" "$disk" "$loadavg" "$swap"

} > "$outfile"

echo "System report has been saved to $outfile"
