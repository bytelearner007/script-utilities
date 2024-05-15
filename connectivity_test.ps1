# Domain to check
$Domain = "name.example.com"

# Define IP groups
$GTM_IPs = @("192.168.1.10", "192.168.1.11")  # Example IPs for GTM
$Regional_IPs_LDN = @("192.168.2.10", "192.168.2.11")  # Example IPs for London
$Regional_IPs_SGP = @("192.168.3.10", "192.168.3.11")  # Example IPs for Singapore
$Regional_IPs_AMER = @("192.168.4.10", "192.168.4.11")  # Example IPs for America
$AWS_NLB_IPs = @("192.168.5.10", "192.168.5.11")  # Example IPs for AWS NLB

# Test URL for downloading a file
$TestUrl = "http://$Domain/path/to/test/file"

# Resolve the DNS entry
$ResolvedIP = [System.Net.Dns]::GetHostAddresses($Domain) | Select-Object -ExpandProperty IPAddressToString

# Output the resolved IP
Write-Host "Resolved IP: $ResolvedIP"

# Determine IP category
$Category = "Unknown"
if ($GTM_IPs -contains $ResolvedIP) {
    $Category = "GTM IP"
} elseif ($Regional_IPs_LDN -contains $ResolvedIP -or $Regional_IPs_SGP -contains $ResolvedIP -or $Regional_IPs_AMER -contains $ResolvedIP) {
    $Category = "Regional IP"
} elseif ($AWS_NLB_IPs -contains $ResolvedIP) {
    $Category = "AWS NLB IP"
}

Write-Host "IP Category: $Category"

# Test file download, ignoring SSL certificate errors
$DownloadStatus = try {
    $Request = Invoke-WebRequest -Uri $TestUrl -TimeoutSec 5 -Method Head -ErrorAction Stop -SkipCertificateCheck
    "Download successful"
} catch {
    "Download failed: $_"
}

Write-Host $DownloadStatus

# Determine impact based on download status and IP category
if ($DownloadStatus -eq "Download successful" -and $Category -eq "AWS NLB IP") {
    Write-Host "Impacted for Migration"
} elseif ($DownloadStatus -eq "Download successful" -and ($Category -eq "GTM IP" -or $Category -eq "Regional IP")) {
    Write-Host "Not Impacted"
} else {
    Write-Host "Concern"
}
