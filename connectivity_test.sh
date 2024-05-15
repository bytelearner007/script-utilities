#!/bin/bash

# Domain to check
DOMAIN="example.com"

# Define IP groups
GTM_IPS=("ip1" "ip2")  # Example IPs for GTM
REGIONAL_IPS_LDN=("ip1" "ip2")  # Example IPs for London
REGIONAL_IPS_SGP=("ip1" "ip2")  # Example IPs for Singapore
REGIONAL_IPS_AMER=("ip1" "ip2")  # Example IPs for America
AWS_NLB_IPS=("ip1" "ip2")  # Example IPs for AWS NLB

# Test URL for downloading a file
TEST_URL="http://$DOMAIN/path/to/test/file"

# Resolve the DNS entry
RESOLVED_IP=$(getent hosts $DOMAIN | awk '{ print $1 }')

# Output the resolved IP
echo "Resolved IP: $RESOLVED_IP"

# Determine IP category
CATEGORY="Unknown"
if [[ " ${GTM_IPS[*]} " =~ " $RESOLVED_IP " ]]; then
    CATEGORY="GTM IP"
elif [[ " ${REGIONAL_IPS_LDN[*]} ${REGIONAL_IPS_SGP[*]} ${REGIONAL_IPS_AMER[*]} " =~ " $RESOLVED_IP " ]]; then
    CATEGORY="Regional IP"
elif [[ " ${AWS_NLB_IPS[*]} " =~ " $RESOLVED_IP " ]]; then
    CATEGORY="AWS NLB IP"
fi

echo "IP Category: $CATEGORY"

# Test file download
if curl --silent --fail --output /dev/null --connect-timeout 5 $TEST_URL; then
    DOWNLOAD_STATUS="Download successful"
else
    DOWNLOAD_STATUS="Download failed"
fi

echo $DOWNLOAD_STATUS

# Determine impact
if [[ "$DOWNLOAD_STATUS" == "Download successful" && "$CATEGORY" == "AWS NLB IP" ]]; then
    echo "Impacted for Migration"
elif [[ "$DOWNLOAD_STATUS" == "Download successful" && ( "$CATEGORY" == "GTM IP" || "$CATEGORY" == "Regional IP" ) ]]; then
    echo "Not Impacted"
else
    echo "Concern"
fi
