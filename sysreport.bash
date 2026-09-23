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
	echo '--------------'
	echo

	# Print date
	report_date=$(date +'%A %B %d, %Y (%I:%M %p)')
	echo "Report Date: $report_date"
	echo

	# Linux system info
	echo
	echo 'System Info'
	echo '-----------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
	kernel=$(uname -rv)
	distro=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Unknown}")
	cpu_model=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ //')
	arch=$(uname -m)
	cpu_cores=$(nproc 2>/dev/null)
	hostname=$(hostname)
	process_count=$(ps -ef | wc -l)
	if command -v systemctl >/dev/null 2>&1; then
	services=$(systemctl list-units --type=service --state=running --no-legend)
else
	services="systemctl not available (non-systemd system?)"
fi
	if command -v journalctl >/dev/null 2>&1; then
	failedlogins=$(journalctl -q --no-pager -g "Failed password" 2>/dev/null | grep -v sudo | tail -n 10)
	[ -z "$failedlogins" ] && failedlogins="None found (or insufficient permissions to read logs)"
else
	failedlogins="journalctl not available on this system"
fi

	printf "Kernel: %s\nDistro: %s\nCPU Model: %s\nArchitecture: %s\nCPU Cores: %s\nHostname: %s\nProcess Count: %s\nActive Services:\n%s\nFailed Login Attempts:\n%s\n" \
  "$kernel" "$distro" "$cpu_model" "$arch" "$cpu_cores" "$hostname" "$process_count" "$services" "$failedlogins"

	echo
	echo "=============================="

	# Network info
	echo 'Network Info'
	echo '------------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"

	ipaddress=$(ip -4 address show | grep inet)
	iproute=$(ip route show)
	if command -v ss >/dev/null 2>&1; then
	connections=$(ss -tulnp 2>/dev/null)
else
	connections="ss not installed"
fi
	if command -v curl >/dev/null 2>&1; then
	publicip=$(curl -s --max-time 5 ifconfig.me)
	[ -z "$publicip" ] && publicip="Unavailable (no internet or request timed out)"
else
	publicip="curl not installed"
fi

	printf "IP Addresses:\n%s\n\nRouting Table:\n%s\nActive Network Connections:\n%s\nPublic IP Address:\n%s\n" \
	  "$ipaddress" "$iproute" "$connections" "$publicip"

	echo
	echo "=============================="

	# PCIe / GPU Info
		echo 'PCIe / GPU Info'
	echo '---------------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"

	if command -v lspci >/dev/null 2>&1; then
		pcie_devices=$(lspci)
		gpu_devices=$(lspci | grep -iE 'vga|3d|display')
		gpu_kernel_driver=$(lspci -k | grep -iE -A3 'vga|3d|display' | grep -i 'kernel driver in use' | sed 's/^\s*//')
	else
		pcie_devices="lspci not installed (install pciutils)"
		gpu_devices="lspci not installed (install pciutils)"
		gpu_kernel_driver="lspci not installed (install pciutils)"
	fi

	if command -v nvidia-smi >/dev/null 2>&1; then
		nvidia_driver=$(nvidia-smi --query-gpu=name,driver_version,vbios_version --format=csv,noheader 2>/dev/null)
		[ -z "$nvidia_driver" ] && nvidia_driver="nvidia-smi present but returned no data (driver not loaded?)"
	else
		nvidia_driver="nvidia-smi not found (no NVIDIA proprietary driver, or not installed)"
	fi

	amd_driver=""
	if command -v rocm-smi >/dev/null 2>&1; then
		amd_driver=$(rocm-smi --showdriverversion 2>/dev/null)
	fi
	[ -z "$amd_driver" ] && amd_driver="rocm-smi not found (no AMD ROCm driver, or not installed)"

	printf "All PCIe Devices:\n%s\n\nGPU Device(s):\n%s\n\nGPU Kernel Driver In Use:\n%s\n\nNVIDIA Driver Info (nvidia-smi):\n%s\n\nAMD ROCm Driver Info (rocm-smi):\n%s\n" \
		"$pcie_devices" "$gpu_devices" "$gpu_kernel_driver" "$nvidia_driver" "$amd_driver"


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
	echo '--------------'
	echo

	# Print date
	report_date=$(date +'%A %B %d, %Y (%I:%M %p)')
	echo "Report Date: $report_date"
	echo

	# Linux system info
	echo
	echo 'System Info'
	echo '-----------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
	kernel=$(uname -rv)
	distro=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Unknown}")
	cpu_model=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ //')
	arch=$(uname -m)
	cpu_cores=$(nproc 2>/dev/null)
	hostname=$(hostname)
	process_count=$(ps -ef | wc -l)
	if command -v systemctl >/dev/null 2>&1; then
	services=$(systemctl list-units --type=service --state=running --no-legend)
else
	services="systemctl not available (non-systemd system?)"
fi
	if command -v journalctl >/dev/null 2>&1; then
	failedlogins=$(journalctl -q --no-pager -g "Failed password" 2>/dev/null | grep -v sudo | tail -n 10)
	[ -z "$failedlogins" ] && failedlogins="None found (or insufficient permissions to read logs)"
else
	failedlogins="journalctl not available on this system"
fi

	printf "Kernel: %s\nDistro: %s\nCPU Model: %s\nArchitecture: %s\nCPU Cores: %s\nHostname: %s\nProcess Count: %s\nActive Services:\n%s\nFailed Login Attempts:\n%s\n" \
  "$kernel" "$distro" "$cpu_model" "$arch" "$cpu_cores" "$hostname" "$process_count" "$services" "$failedlogins"

	echo
	echo "=============================="

	# Network info
	echo 'Network Info'
	echo '------------'
	echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"

	ipaddress=$(ip -4 address show | grep inet)
	iproute=$(ip route show)
	if command -v ss >/dev/null 2>&1; then
	connections=$(ss -tulnp 2>/dev/null)
else
	connections="ss not installed"
fi
	if command -v curl >/dev/null 2>&1; then
	publicip=$(curl -s --max-time 5 ifconfig.me)
	[ -z "$publicip" ] && publicip="Unavailable (no internet or request timed out)"
else
	publicip="curl not installed"
fi

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
