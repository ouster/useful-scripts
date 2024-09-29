#!/bin/bash

# Check if a list of DNS IP addresses is provided as an argument
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 dns_ip_list.txt"
    exit 1
fi

# File containing the DNS IPs (one per line)
dns_file=$1

# Check if file exists
if [ ! -f "$dns_file" ]; then
    echo "File not found: $dns_file"
    exit 1
fi

# Function to ping a DNS server and return the average ping time
ping_dns() {
    local dns_ip=$1
    # Ping 3 times and extract the average round-trip time from the output
    local avg_ping=$(ping -c 3 -q "$dns_ip" | awk -F'/' 'END{ print $5 }')
    echo "$avg_ping $dns_ip"
}

# Ping each DNS and store the results in an array
declare -a results

while IFS= read -r dns_ip; do
    # Ping each DNS and capture the result
    if [ -n "$dns_ip" ]; then
        result=$(ping_dns "$dns_ip")
        results+=("$result")
    fi
done < "$dns_file"

# Sort the results by the average ping time (numerically)
sorted_results=$(printf "%s\n" "${results[@]}" | sort -n)

# Display the sorted results
echo "DNS IPs sorted by fastest ping:"
echo "$sorted_results"

