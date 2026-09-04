#!/bin/bash

read -p "Enter directory name: " dir_name

mkdir "$dir_name"

touch "$dir_name/processes.txt"

current_date=$(date)
hostname=$(hostname)
username=$(whoami)
disk_usage=$(df -h)

echo "===== System Information ====="
echo "Date: $current_date"
echo "Hostname: $hostname"
echo "Username: $username"

echo ""
echo "===== Disk Usage ====="
echo "$disk_usage"

echo ""
echo "===== Running Processes ====="
ps

ps > "$dir_name/processes.txt"

echo ""
echo "Running processes have been saved to $dir_name/processes.txt"