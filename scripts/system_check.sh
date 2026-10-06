#!/bin/bash

# ==========================================
# Linux IT Support - System Health Monitor
# ==========================================

STATUS="OK"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ------------------------------------------
# Function: Update overall status
# CRITICAL always has priority over WARNING
# ------------------------------------------
set_status() {
    if [ "$1" = "CRITICAL" ]; then
        STATUS="CRITICAL"
    elif [ "$1" = "WARNING" ] && [ "$STATUS" != "CRITICAL" ]; then
        STATUS="WARNING"
    fi
}

echo "================================="
echo "SYSTEM CHECK: $TIMESTAMP"
echo "================================="

echo "================================="
echo "        SYSTEM HEALTH CHECK"
echo "================================="

# ------------------------------------------
# Hostname
# ------------------------------------------
echo "Hostname:"
hostname

# ------------------------------------------
# Operating System
# ------------------------------------------
echo "Operating system:"
grep PRETTY_NAME /etc/os-release

# ------------------------------------------
# Kernel
# ------------------------------------------
echo "Kernel:"
uname -r

# ------------------------------------------
# Uptime
# ------------------------------------------
echo "Uptime:"
uptime

# ------------------------------------------
# CPU Monitoring
# ------------------------------------------
echo ""
echo "CPU Usage:"

CPU_USAGE=$(top -bn1 | awk -F',' '/%Cpu/ {
    for (i=1; i<=NF; i++) {
        if ($i ~ / id/) {
            gsub(/[^0-9.]/, "", $i)
            print 100 - $i
            exit
        }
    }
}')

CPU_USAGE=$(printf "%.0f" "$CPU_USAGE")

if [ "$CPU_USAGE" -gt 90 ]; then
    echo "CRITICAL: CPU usage is $CPU_USAGE%"
    set_status "CRITICAL"
elif [ "$CPU_USAGE" -gt 80 ]; then
    echo "WARNING: CPU usage is $CPU_USAGE%"
    set_status "WARNING"
else
    echo "OK: CPU usage is $CPU_USAGE%"
fi

# ------------------------------------------
# Memory Monitoring
# ------------------------------------------
echo ""
echo "Memory Usage:"

MEMORY_USAGE=$(free | awk '/Mem:/ {
    printf "%.0f", ($3 / $2) * 100
}')

if [ "$MEMORY_USAGE" -gt 90 ]; then
    echo "CRITICAL: Memory usage is $MEMORY_USAGE%"
    set_status "CRITICAL"
elif [ "$MEMORY_USAGE" -gt 80 ]; then
    echo "WARNING: Memory usage is $MEMORY_USAGE%"
    set_status "WARNING"
else
    echo "OK: Memory usage is $MEMORY_USAGE%"
fi

# ------------------------------------------
# Disk Monitoring
# ------------------------------------------
echo ""
echo "Disk Usage:"

DISK_USAGE=$(df -h / | awk 'NR==2 {
    gsub("%", "", $5)
    print $5
}')

if [ "$DISK_USAGE" -gt 90 ]; then
    echo "CRITICAL: Disk usage is $DISK_USAGE%"
    set_status "CRITICAL"
elif [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk usage is $DISK_USAGE%"
    set_status "WARNING"
else
    echo "OK: Disk usage is $DISK_USAGE%"
fi

# ------------------------------------------
# Service Monitoring
# ------------------------------------------
echo ""
echo "Service Monitoring:"

SERVICE="cron"

if systemctl is-active --quiet "$SERVICE"; then
    echo "OK: $SERVICE is running"
else
    echo "CRITICAL: $SERVICE is not running"
    set_status "CRITICAL"
fi

# ------------------------------------------
# Log Monitoring
# ------------------------------------------
echo ""
echo "Log monitoring:"

if sudo journalctl -u "$SERVICE" --since "10 minutes ago" 2>/dev/null |
    grep -Eiq "error|failed|failure|timeout|denied"; then

    echo "CRITICAL: Errors found in $SERVICE logs"
    set_status "CRITICAL"
else
    echo "OK: No errors found in the $SERVICE logs"
fi

# ------------------------------------------
# Network Monitoring
# ------------------------------------------
echo ""
echo "Network Monitoring:"

if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
    echo "OK: Network is reachable"
else
    echo "CRITICAL: Network is unreachable"
    set_status "CRITICAL"
fi

# ------------------------------------------
# Overall Status
# ------------------------------------------
echo ""
echo "================================="
echo "OVERALL STATUS: $STATUS"
echo "================================="

if [ "$STATUS" = "OK" ]; then
    exit 0
elif [ "$STATUS" = "WARNING" ]; then
    exit 1
elif [ "$STATUS" = "CRITICAL" ]; then
    exit 2
else
    exit 3
fi
