# Network Adapter Information Script
# Purpose: Gather detailed network adapter information for troubleshooting connectivity issues
# Compatible with: Windows 11 (no admin rights required)

# Function to convert prefix length to subnet mask
function Convert-PrefixToSubnetMask {
    param([int]$PrefixLength)
    
    $subnetMasks = @{
        8  = "255.0.0.0"
        9  = "255.128.0.0"
        10 = "255.192.0.0"
        11 = "255.224.0.0"
        12 = "255.240.0.0"
        13 = "255.248.0.0"
        14 = "255.252.0.0"
        15 = "255.254.0.0"
        16 = "255.255.0.0"
        17 = "255.255.128.0"
        18 = "255.255.192.0"
        19 = "255.255.224.0"
        20 = "255.255.240.0"
        21 = "255.255.248.0"
        22 = "255.255.252.0"
        23 = "255.255.254.0"
        24 = "255.255.255.0"
        25 = "255.255.255.128"
        26 = "255.255.255.192"
        27 = "255.255.255.224"
        28 = "255.255.255.240"
        29 = "255.255.255.248"
        30 = "255.255.255.252"
        31 = "255.255.255.254"
        32 = "255.255.255.255"
    }
    
    return $subnetMasks[$PrefixLength]
}

# Initialize HTML output
$htmlOutput = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Network Adapter Information Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0078d4;
            border-bottom: 3px solid #0078d4;
            padding-bottom: 10px;
        }
        h2 {
            color: #005a9e;
            margin-top: 30px;
            border-left: 4px solid #0078d4;
            padding-left: 10px;
        }
        h3 {
            color: #106ebe;
            margin-top: 20px;
        }
        .info-section {
            background-color: #f9f9f9;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
            border: 1px solid #e0e0e0;
        }
        .adapter-box {
            background-color: #fff;
            border: 2px solid #0078d4;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #0078d4;
            color: white;
            font-weight: bold;
        }
        .success {
            color: #107c10;
            font-weight: bold;
        }
        .failed {
            color: #d13438;
            font-weight: bold;
        }
        .warning {
            color: #ff8c00;
            font-weight: bold;
        }
        .label {
            font-weight: bold;
            color: #005a9e;
            display: inline-block;
            min-width: 200px;
        }
        .timestamp {
            color: #666;
            font-size: 0.9em;
        }
        .event-log {
            background-color: #fffef0;
            border-left: 4px solid #ff8c00;
            padding: 10px;
            margin: 10px 0;
        }
        .summary-box {
            background-color: #e6f3ff;
            border: 1px solid #0078d4;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Network Adapter Information Report</h1>
        <div class="info-section">
            <p><span class="label">Generated:</span> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
            <p><span class="label">Host Name:</span> $env:COMPUTERNAME</p>
        </div>
"@

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Network Adapter Information Report" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Display Host Name
Write-Host "Host Name:" -ForegroundColor Yellow -NoNewline
Write-Host " $env:COMPUTERNAME`n"

# Get all network adapters that are up
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}

if ($adapters.Count -eq 0) {
    Write-Host "WARNING: No active network adapters found!" -ForegroundColor Red
    Write-Host "`nChecking all adapters (including disabled)...`n" -ForegroundColor Yellow
    $adapters = Get-NetAdapter
}

foreach ($adapter in $adapters) {
    Write-Host "┌─────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "│ Adapter: $($adapter.Name)" -ForegroundColor Green
    Write-Host "└─────────────────────────────────────────────────────────────" -ForegroundColor Green
    
    # Add to HTML
    $htmlOutput += @"
        <div class="adapter-box">
            <h2>Adapter: $($adapter.Name)</h2>
            <table>
                <tr><th colspan="2">Basic Information</th></tr>
                <tr><td class="label">Interface Description</td><td>$($adapter.InterfaceDescription)</td></tr>
                <tr><td class="label">Status</td><td class="$(if ($adapter.Status -eq 'Up') {'success'} else {'failed'})">$($adapter.Status)</td></tr>
                <tr><td class="label">MAC Address</td><td>$($adapter.MacAddress)</td></tr>
                <tr><td class="label">Link Speed</td><td>$($adapter.LinkSpeed)</td></tr>
            </table>
            
            <h3>Driver Information</h3>
            <table>
                <tr><td class="label">Driver Description</td><td>$($adapter.DriverInformation)</td></tr>
                <tr><td class="label">Driver File Name</td><td>$($adapter.DriverFileName)</td></tr>
                <tr><td class="label">Driver Version</td><td>$($adapter.DriverVersion)</td></tr>
                <tr><td class="label">Interface Description</td><td>$($adapter.ifDesc)</td></tr>
            </table>
"@
    
    # Basic Adapter Information
    Write-Host "`n  Interface Description:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.InterfaceDescription)"
    
    Write-Host "  Status:" -ForegroundColor Yellow -NoNewline
    if ($adapter.Status -eq 'Up') {
        Write-Host " $($adapter.Status)" -ForegroundColor Green
    } else {
        Write-Host " $($adapter.Status)" -ForegroundColor Red
    }
    
    Write-Host "  MAC Address (Physical Address):" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.MacAddress)"
    
    Write-Host "  Link Speed:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.LinkSpeed)"
    
    # Driver Information
    Write-Host "`n  Driver Information:" -ForegroundColor Cyan
    Write-Host "    Driver Description:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.DriverInformation)"
    
    Write-Host "    Driver File Name:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.DriverFileName)"
    
    Write-Host "    Driver Version:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.DriverVersion)"
    
    Write-Host "    Interface Description (ifDesc):" -ForegroundColor Yellow -NoNewline
    Write-Host " $($adapter.ifDesc)"
    
    # Check if this is a wireless adapter
    if ($adapter.InterfaceDescription -match "Wi-Fi|Wireless|802.11|WiFi") {
        Write-Host "`n  Wireless Information:" -ForegroundColor Cyan
        
        # Get wireless interface information using netsh
        $netshOutput = netsh wlan show interfaces | Out-String
        
        # Check if this specific adapter is in the output
        if ($netshOutput -match $adapter.Name -or $netshOutput -match $adapter.InterfaceDescription) {
            # Parse netsh output
            if ($netshOutput -match "Interface type\s+:\s+(.+)") {
                Write-Host "    Interface Type:" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "State\s+:\s+(.+)") {
                $state = $matches[1].Trim()
                Write-Host "    State:" -ForegroundColor Yellow -NoNewline
                if ($state -eq "connected") {
                    Write-Host " $state" -ForegroundColor Green
                } else {
                    Write-Host " $state" -ForegroundColor Red
                }
            }
            
            if ($netshOutput -match "SSID\s+:\s+(.+)") {
                Write-Host "    SSID:" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "BSSID\s+:\s+(.+)") {
                Write-Host "    BSSID (Access Point):" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "Band\s+:\s+(.+)") {
                Write-Host "    Band:" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "Channel\s+:\s+(.+)") {
                Write-Host "    Channel:" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "Radio type\s+:\s+(.+)") {
                Write-Host "    Radio Type:" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "Authentication\s+:\s+(.+)") {
                Write-Host "    Authentication:" -ForegroundColor Yellow -NoNewline
                Write-Host " $($matches[1].Trim())"
            }
            
            if ($netshOutput -match "Signal\s+:\s+(.+)") {
                $signal = $matches[1].Trim()
                Write-Host "    Signal Strength:" -ForegroundColor Yellow -NoNewline
                Write-Host " $signal"
            }
        } else {
            Write-Host "    Status: Wireless adapter detected but no active connection" -ForegroundColor Yellow
        }
        
        # WLAN Event Logs (last 24 hours)
        Write-Host "`n  WLAN Event Log Analysis (Last 24 Hours):" -ForegroundColor Cyan
        
        try {
            $wlanEvents = Get-WinEvent -LogName Microsoft-Windows-WLAN-AutoConfig/Operational `
                -ErrorAction SilentlyContinue |
                Where-Object { $_.TimeCreated -gt (Get-Date).AddHours(-24) }
            
            if ($wlanEvents) {
                # Categorize events
                $disconnects = $wlanEvents | Where-Object { $_.Id -in 8000, 8001, 8002, 8003 }
                $roaming     = $wlanEvents | Where-Object { $_.Id -eq 11004 }
                $authFails   = $wlanEvents | Where-Object { $_.Id -eq 12011 }
                
                # Display disconnect events
                if ($disconnects) {
                    Write-Host "`n    Disconnect Events:" -ForegroundColor Yellow -NoNewline
                    Write-Host " $($disconnects.Count) found" -ForegroundColor Red
                    $disconnects | Select-Object -First 5 | ForEach-Object {
                        Write-Host "      [$($_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss'))] Event ID: $($_.Id) - $($_.LevelDisplayName)"
                        # Show abbreviated message (first 100 chars)
                        $msg = $_.Message -replace "`n", " " -replace "`r", ""
                        if ($msg.Length -gt 100) { $msg = $msg.Substring(0, 100) + "..." }
                        Write-Host "        $msg" -ForegroundColor Gray
                    }
                    if ($disconnects.Count -gt 5) {
                        Write-Host "      ... and $($disconnects.Count - 5) more disconnect events" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "    Disconnect Events:" -ForegroundColor Yellow -NoNewline
                    Write-Host " None found" -ForegroundColor Green
                }
                
                # Display roaming events
                if ($roaming) {
                    Write-Host "`n    Roaming Events:" -ForegroundColor Yellow -NoNewline
                    Write-Host " $($roaming.Count) found"
                    $roaming | Select-Object -First 3 | ForEach-Object {
                        Write-Host "      [$($_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss'))] Roamed to different access point"
                    }
                    if ($roaming.Count -gt 3) {
                        Write-Host "      ... and $($roaming.Count - 3) more roaming events" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "`n    Roaming Events:" -ForegroundColor Yellow -NoNewline
                    Write-Host " None found"
                }
                
                # Display authentication failures
                if ($authFails) {
                    Write-Host "`n    Authentication Failures:" -ForegroundColor Yellow -NoNewline
                    Write-Host " $($authFails.Count) found" -ForegroundColor Red
                    $authFails | Select-Object -First 3 | ForEach-Object {
                        Write-Host "      [$($_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss'))] Authentication failed"
                        $msg = $_.Message -replace "`n", " " -replace "`r", ""
                        if ($msg.Length -gt 100) { $msg = $msg.Substring(0, 100) + "..." }
                        Write-Host "        $msg" -ForegroundColor Gray
                    }
                    if ($authFails.Count -gt 3) {
                        Write-Host "      ... and $($authFails.Count - 3) more authentication failures" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "`n    Authentication Failures:" -ForegroundColor Yellow -NoNewline
                    Write-Host " None found" -ForegroundColor Green
                }
                
                # Summary
                Write-Host "`n    Event Summary:" -ForegroundColor Cyan
                Write-Host "      Total WLAN events logged: $($wlanEvents.Count)"
                Write-Host "      Disconnects: $($disconnects.Count)"
                Write-Host "      Roaming events: $($roaming.Count)"
                Write-Host "      Authentication failures: $($authFails.Count)"
                
            } else {
                Write-Host "    No WLAN events found in the last 24 hours" -ForegroundColor Gray
            }
        } catch {
            Write-Host "    Unable to retrieve WLAN event logs" -ForegroundColor Yellow
            Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Gray
        }
    }
    
    # Get IP Configuration
    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex -ErrorAction SilentlyContinue
    
    if ($ipConfig) {
        $htmlOutput += "<h3>IP Configuration</h3><table>"
        
        # IPv4 Address
        $ipv4 = $ipConfig.IPv4Address.IPAddress
        if ($ipv4) {
            Write-Host "`n  IPv4 Address:" -ForegroundColor Yellow -NoNewline
            Write-Host " $ipv4"
            $htmlOutput += "<tr><td class='label'>IPv4 Address</td><td>$ipv4</td></tr>"
            
            # Get Subnet Mask
            $ipAddress = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            if ($ipAddress) {
                $prefixLength = $ipAddress.PrefixLength
                $subnetMask = Convert-PrefixToSubnetMask -PrefixLength $prefixLength
                Write-Host "  Subnet Mask:" -ForegroundColor Yellow -NoNewline
                Write-Host " $subnetMask (/$prefixLength)"
                $htmlOutput += "<tr><td class='label'>Subnet Mask</td><td>$subnetMask (/$prefixLength)</td></tr>"
            }
        } else {
            Write-Host "`n  IPv4 Address:" -ForegroundColor Yellow -NoNewline
            Write-Host " Not configured" -ForegroundColor Red
            $htmlOutput += "<tr><td class='label'>IPv4 Address</td><td class='failed'>Not configured</td></tr>"
        }
        
        # Default Gateway
        $gateway = $ipConfig.IPv4DefaultGateway.NextHop
        Write-Host "  Default Gateway:" -ForegroundColor Yellow -NoNewline
        if ($gateway) {
            Write-Host " $gateway"
            $htmlOutput += "<tr><td class='label'>Default Gateway</td><td>$gateway</td></tr>"
        } else {
            Write-Host " Not configured" -ForegroundColor Red
            $htmlOutput += "<tr><td class='label'>Default Gateway</td><td class='failed'>Not configured</td></tr>"
        }
        
        # DNS Servers
        $dnsServers = $ipConfig.DNSServer.ServerAddresses
        Write-Host "  DNS Servers:" -ForegroundColor Yellow
        if ($dnsServers) {
            $dnsHtml = ""
            foreach ($dns in $dnsServers) {
                Write-Host "    - $dns"
                $dnsHtml += "$dns<br>"
            }
            $htmlOutput += "<tr><td class='label'>DNS Servers</td><td>$dnsHtml</td></tr>"
        } else {
            Write-Host "    Not configured" -ForegroundColor Red
            $htmlOutput += "<tr><td class='label'>DNS Servers</td><td class='failed'>Not configured</td></tr>"
        }
        
        # DHCP Status
        $dhcpEnabled = (Get-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4).Dhcp
        Write-Host "  DHCP Enabled:" -ForegroundColor Yellow -NoNewline
        Write-Host " $dhcpEnabled"
        $htmlOutput += "<tr><td class='label'>DHCP Enabled</td><td>$dhcpEnabled</td></tr>"
        
        # IPv6 Address (if available)
        $ipv6 = $ipConfig.IPv6Address.IPAddress
        if ($ipv6) {
            Write-Host "`n  IPv6 Address:" -ForegroundColor Yellow -NoNewline
            Write-Host " $ipv6"
            $htmlOutput += "<tr><td class='label'>IPv6 Address</td><td>$ipv6</td></tr>"
        }
        
        $htmlOutput += "</table>"
    } else {
        Write-Host "`n  IP Configuration:" -ForegroundColor Yellow -NoNewline
        Write-Host " Not available" -ForegroundColor Red
        $htmlOutput += "<p class='failed'>IP Configuration not available</p>"
    }
    
    Write-Host "`n"
    $htmlOutput += "</div>"  # Close adapter-box
}

# Connection Test Function
function Test-NetworkEndpoint {
    param(
        [string]$EndpointName,
        [string]$EndpointAddress,
        [int]$Count = 5
    )
    
    Write-Host "`nTesting $EndpointName ($EndpointAddress)..." -NoNewline
    $pingResult = Test-Connection -ComputerName $EndpointAddress -Count $Count -ErrorAction SilentlyContinue
    
    if ($pingResult) {
        $avgPing = ($pingResult | Measure-Object -Property Latency -Average).Average
        $minPing = ($pingResult | Measure-Object -Property Latency -Minimum).Minimum
        $maxPing = ($pingResult | Measure-Object -Property Latency -Maximum).Maximum
        $packetLoss = (($Count - $pingResult.Count) / $Count) * 100
        
        Write-Host " SUCCESS" -ForegroundColor Green
        Write-Host "  Average Response Time: $([math]::Round($avgPing, 2)) ms" -NoNewline
        Write-Host " (Min: $([math]::Round($minPing, 2)) ms, Max: $([math]::Round($maxPing, 2)) ms)"
        
        $script:htmlOutput += "<tr><td class='label'>$EndpointName ($EndpointAddress)</td><td class='success'>SUCCESS<br>Avg: $([math]::Round($avgPing, 2)) ms (Min: $([math]::Round($minPing, 2)) ms, Max: $([math]::Round($maxPing, 2)) ms)</td></tr>"
        
        if ($packetLoss -gt 0) {
            Write-Host "  Packet Loss: $packetLoss%" -ForegroundColor Yellow
            $script:htmlOutput += "<tr><td colspan='2' class='warning'>Packet Loss: $packetLoss%</td></tr>"
        }
    } else {
        Write-Host " FAILED" -ForegroundColor Red
        $script:htmlOutput += "<tr><td class='label'>$EndpointName ($EndpointAddress)</td><td class='failed'>FAILED</td></tr>"
    }
}

# Connection Test
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Connectivity Tests" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$htmlOutput += "<h2>Connectivity Tests</h2><table><tr><th>Endpoint</th><th>Result</th></tr>"

# Test Gateway Connectivity
Write-Host "Testing connectivity to gateway(s)..." -ForegroundColor Yellow
foreach ($adapter in $adapters | Where-Object {$_.Status -eq 'Up'}) {
    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex -ErrorAction SilentlyContinue
    $gateway = $ipConfig.IPv4DefaultGateway.NextHop
    
    if ($gateway) {
        Write-Host "`n  Gateway for $($adapter.Name):" -ForegroundColor Cyan
        Test-NetworkEndpoint -EndpointName "Default Gateway" -EndpointAddress $gateway
    }
}

Write-Host "`n----------------------------------------" -ForegroundColor Cyan
Write-Host "Internet & DNS Connectivity" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

# Test Internet Connectivity
Test-NetworkEndpoint -EndpointName "Google DNS" -EndpointAddress "8.8.8.8"

# Test DNS Resolution
Write-Host "`nTesting DNS resolution (google.com)..." -NoNewline
try {
    $dnsTest = Resolve-DnsName -Name google.com -ErrorAction Stop
    Write-Host " SUCCESS" -ForegroundColor Green
    
    # Ping resolved address
    Test-NetworkEndpoint -EndpointName "Google.com" -EndpointAddress "google.com"
} catch {
    Write-Host " FAILED" -ForegroundColor Red
}

# ============================================
# CORPORATE ENDPOINTS SECTION
# ============================================
# Add your corporate endpoints below using the Test-NetworkEndpoint function
# Examples:
Write-Host "`n----------------------------------------" -ForegroundColor Cyan
Write-Host "Corporate Endpoints (Customize Below)" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

# Uncomment and customize these examples for your corporate environment:
# Test-NetworkEndpoint -EndpointName "Corporate VPN Gateway" -EndpointAddress "vpn.company.com"
# Test-NetworkEndpoint -EndpointName "Internal File Server" -EndpointAddress "fileserver.internal.company.com"
# Test-NetworkEndpoint -EndpointName "Domain Controller" -EndpointAddress "dc01.company.local"
# Test-NetworkEndpoint -EndpointName "Internal Web Portal" -EndpointAddress "intranet.company.com"
# Test-NetworkEndpoint -EndpointName "Exchange Server" -EndpointAddress "mail.company.com"
# Test-NetworkEndpoint -EndpointName "Office 365" -EndpointAddress "outlook.office365.com"

Write-Host "`nNote: Customize corporate endpoints in the script as needed" -ForegroundColor Gray

$htmlOutput += "</table>"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Report Complete" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Close HTML document
$htmlOutput += @"
    </div>
</body>
</html>
"@

# Save HTML report to C:\install
$reportPath = "C:\install"
$reportFile = Join-Path $reportPath "NetworkAdapterReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

try {
    # Create directory if it doesn't exist
    if (-not (Test-Path $reportPath)) {
        New-Item -Path $reportPath -ItemType Directory -Force | Out-Null
    }
    
    # Save HTML file
    $htmlOutput | Out-File -FilePath $reportFile -Encoding UTF8 -Force
    
    Write-Host "HTML Report saved successfully!" -ForegroundColor Green
    Write-Host "Location: $reportFile" -ForegroundColor Cyan
    Write-Host "`nOpening report in default browser..." -ForegroundColor Yellow
    
    # Open the HTML file in default browser
    Start-Process $reportFile
    
} catch {
    Write-Host "ERROR: Failed to save HTML report" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease ensure you have write access to C:\install" -ForegroundColor Yellow
}

