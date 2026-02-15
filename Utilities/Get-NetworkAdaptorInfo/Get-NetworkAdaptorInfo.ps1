# Network Adapter Information Script
# Purpose: Gather detailed network adapter information for troubleshooting connectivity issues
# Compatible with: Windows 11 (no admin rights required)
#
# USAGE EXAMPLES:
#   Default (1 day of WLAN events):
#     .\Get-NetworkAdapterInfo.ps1
#
#   Last 3 days of WLAN events:
#     .\Get-NetworkAdapterInfo.ps1 -WlanEventDays 3
#
#   Last 7 days of WLAN events:
#     .\Get-NetworkAdapterInfo.ps1 -WlanEventDays 7

# Parameters
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet(1, 3, 7)]
    [int]$WlanEventDays = 1
)

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

# ============================================
# COLLECT SYSTEM INFORMATION (Before HTML generation)
# ============================================

# Get WMI Computer System Info
$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue

# Get BIOS Info
$bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction SilentlyContinue

# Get OS Info
$os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue

# Machine ID (from registry)
$machineId = $null
try {
    $machineId = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name MachineGuid -ErrorAction SilentlyContinue
} catch {
    # Silent fail
}

# MDM Enrollment Status
$mdmEnrolled = $false
try {
    $mdmEnrollment = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\*" -ErrorAction SilentlyContinue | 
        Where-Object { $_.ProviderID -or $_.UPN }
    $mdmEnrolled = ($null -ne $mdmEnrollment)
} catch {
    # Silent fail
}

# System Uptime
$uptimeString = "Unknown"
if ($os) {
    $uptime = (Get-Date) - $os.LastBootUpTime
    $uptimeString = "{0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
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
            table-layout: fixed;
        }
        /* Column widths ONLY for two-column info tables */
        table.info-table td:first-child:not([colspan]),
        table.info-table th:first-child:not([colspan]) {
            width: 25%;
        }
        table.info-table td:last-child:not([colspan]),
        table.info-table th:last-child:not([colspan]) {
            width: 75%;
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
            <p><span class="label">WLAN Event Log Timeframe:</span> Last $WlanEventDays day$(if ($WlanEventDays -gt 1) {'s'})</p>
        </div>
        
        <h2>System Information</h2>
        <div class="info-section">
            <h3>User Info</h3>
            <table class="info-table">
                <tr><td class="label">Username</td><td>$env:USERNAME</td></tr>
                <tr><td class="label">User Domain</td><td>$env:USERDOMAIN</td></tr>
                <tr><td class="label">User DNS Domain</td><td>$env:USERDNSDOMAIN</td></tr>
            </table>
            
            <h3>System Info</h3>
            <table class="info-table">
                <tr><td class="label">ComputerName</td><td>$env:COMPUTERNAME</td></tr>
"@

# Add Computer System Info to HTML
if ($computerSystem) {
    $htmlOutput += "<tr><td class='label'>System Manufacturer</td><td>$($computerSystem.Manufacturer)</td></tr>"
    $htmlOutput += "<tr><td class='label'>System Product Name</td><td>$($computerSystem.Model)</td></tr>"
}

# Add BIOS Info to HTML
if ($bios) {
    $htmlOutput += "<tr><td class='label'>BIOS Date</td><td>$($bios.ReleaseDate.ToString('yyyy-MM-dd'))</td></tr>"
    $htmlOutput += "<tr><td class='label'>BIOS Version</td><td>$($bios.SMBIOSBIOSVersion)</td></tr>"
}

# Add OS Info to HTML
if ($os) {
    $htmlOutput += "<tr><td class='label'>OS Build</td><td>$($os.Version) (Build $($os.BuildNumber))</td></tr>"
}

# Add Machine ID to HTML
if ($machineId) {
    $htmlOutput += "<tr><td class='label'>Machine Id</td><td>$($machineId.MachineGuid)</td></tr>"
} else {
    $htmlOutput += "<tr><td class='label'>Machine Id</td><td>Unable to retrieve</td></tr>"
}

# Add MDM Status to HTML
if ($mdmEnrolled) {
    $htmlOutput += "<tr><td class='label'>MDM Joined</td><td class='success'>Yes</td></tr>"
} else {
    $htmlOutput += "<tr><td class='label'>MDM Joined</td><td>No</td></tr>"
}

# Add Uptime to HTML
$htmlOutput += "<tr><td class='label'>UpTime</td><td>$uptimeString</td></tr>"

$htmlOutput += @"
            </table>
        </div>
"@

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Network Adapter Information Report" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================
# SYSTEM INFORMATION
# ============================================
Write-Host "System Information" -ForegroundColor Cyan
Write-Host "----------------------------------------`n" -ForegroundColor Cyan

# User Info
Write-Host "User Info:" -ForegroundColor Yellow
Write-Host "  Username:" -ForegroundColor Yellow -NoNewline
Write-Host " $env:USERNAME"
Write-Host "  User Domain:" -ForegroundColor Yellow -NoNewline
Write-Host " $env:USERDOMAIN"
Write-Host "  User DNS Domain:" -ForegroundColor Yellow -NoNewline
Write-Host " $env:USERDNSDOMAIN"

# System Info
Write-Host "`nSystem Info:" -ForegroundColor Yellow

# Computer Name
Write-Host "  ComputerName:" -ForegroundColor Yellow -NoNewline
Write-Host " $env:COMPUTERNAME"

# Display pre-collected Computer System Info
if ($computerSystem) {
    Write-Host "  System Manufacturer:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($computerSystem.Manufacturer)"
    Write-Host "  System Product Name:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($computerSystem.Model)"
}

# Display pre-collected BIOS Info
if ($bios) {
    Write-Host "  BIOS Date:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($bios.ReleaseDate.ToString('yyyy-MM-dd'))"
    Write-Host "  BIOS Version:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($bios.SMBIOSBIOSVersion)"
}

# Display pre-collected OS Info
if ($os) {
    Write-Host "  OS Build:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($os.Version) (Build $($os.BuildNumber))"
}

# Display Machine ID
if ($machineId) {
    Write-Host "  Machine Id:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($machineId.MachineGuid)"
} else {
    Write-Host "  Machine Id:" -ForegroundColor Yellow -NoNewline
    Write-Host " Unable to retrieve"
}

# Display MDM Enrollment Status
Write-Host "  MDM Joined:" -ForegroundColor Yellow -NoNewline
if ($mdmEnrolled) {
    Write-Host " Yes" -ForegroundColor Green
} else {
    Write-Host " No"
}

# Display System Uptime
Write-Host "  UpTime:" -ForegroundColor Yellow -NoNewline
Write-Host " $uptimeString"

Write-Host "  WLAN Event Log Timeframe:" -ForegroundColor Yellow -NoNewline
Write-Host " Last $WlanEventDays day$(if ($WlanEventDays -gt 1) {'s'})`n"


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
            <h3>Basic Information</h3>
            <table class="info-table">
                <tr><td class="label">Interface Description</td><td>$($adapter.InterfaceDescription)</td></tr>
                <tr><td class="label">Status</td><td class="$(if ($adapter.Status -eq 'Up') {'success'} else {'failed'})">$($adapter.Status)</td></tr>
                <tr><td class="label">MAC Address</td><td>$($adapter.MacAddress)</td></tr>
                <tr><td class="label">Link Speed</td><td>$($adapter.LinkSpeed)</td></tr>
            </table>
            
            <h3>Driver Information</h3>
            <table class="info-table">
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
        $htmlOutput += "<h3>Wireless Information</h3><table class='info-table'>"
        
        # Get wireless interface information using netsh
        $netshOutput = netsh wlan show interfaces | Out-String
        
        # Check if this specific adapter is in the output
        if ($netshOutput -match $adapter.Name -or $netshOutput -match $adapter.InterfaceDescription) {
            # Parse netsh output
            if ($netshOutput -match "Interface type\s+:\s+(.+)") {
                $interfaceType = $matches[1].Trim()
                Write-Host "    Interface Type:" -ForegroundColor Yellow -NoNewline
                Write-Host " $interfaceType"
                $htmlOutput += "<tr><td class='label'>Interface Type</td><td>$interfaceType</td></tr>"
            }
            
            if ($netshOutput -match "State\s+:\s+(.+)") {
                $state = $matches[1].Trim()
                Write-Host "    State:" -ForegroundColor Yellow -NoNewline
                if ($state -eq "connected") {
                    Write-Host " $state" -ForegroundColor Green
                    $htmlOutput += "<tr><td class='label'>State</td><td class='success'>$state</td></tr>"
                } else {
                    Write-Host " $state" -ForegroundColor Red
                    $htmlOutput += "<tr><td class='label'>State</td><td class='failed'>$state</td></tr>"
                }
            }
            
            if ($netshOutput -match "SSID\s+:\s+(.+)") {
                $ssid = $matches[1].Trim()
                Write-Host "    SSID:" -ForegroundColor Yellow -NoNewline
                Write-Host " $ssid"
                $htmlOutput += "<tr><td class='label'>SSID</td><td>$ssid</td></tr>"
            }
            
            if ($netshOutput -match "BSSID\s+:\s+(.+)") {
                $bssid = $matches[1].Trim()
                Write-Host "    BSSID (Access Point):" -ForegroundColor Yellow -NoNewline
                Write-Host " $bssid"
                $htmlOutput += "<tr><td class='label'>BSSID (Access Point)</td><td>$bssid</td></tr>"
            }
            
            if ($netshOutput -match "Band\s+:\s+(.+)") {
                $band = $matches[1].Trim()
                Write-Host "    Band:" -ForegroundColor Yellow -NoNewline
                Write-Host " $band"
                $htmlOutput += "<tr><td class='label'>Band</td><td>$band</td></tr>"
            }
            
            if ($netshOutput -match "Channel\s+:\s+(.+)") {
                $channel = $matches[1].Trim()
                Write-Host "    Channel:" -ForegroundColor Yellow -NoNewline
                Write-Host " $channel"
                $htmlOutput += "<tr><td class='label'>Channel</td><td>$channel</td></tr>"
            }
            
            if ($netshOutput -match "Radio type\s+:\s+(.+)") {
                $radioType = $matches[1].Trim()
                Write-Host "    Radio Type:" -ForegroundColor Yellow -NoNewline
                Write-Host " $radioType"
                $htmlOutput += "<tr><td class='label'>Radio Type</td><td>$radioType</td></tr>"
            }
            
            if ($netshOutput -match "Authentication\s+:\s+(.+)") {
                $authentication = $matches[1].Trim()
                Write-Host "    Authentication:" -ForegroundColor Yellow -NoNewline
                Write-Host " $authentication"
                $htmlOutput += "<tr><td class='label'>Authentication</td><td>$authentication</td></tr>"
            }
            
            if ($netshOutput -match "Signal\s+:\s+(.+)") {
                $signal = $matches[1].Trim()
                Write-Host "    Signal Strength:" -ForegroundColor Yellow -NoNewline
                Write-Host " $signal"
                $htmlOutput += "<tr><td class='label'>Signal Strength</td><td>$signal</td></tr>"
            }
            
            $htmlOutput += "</table>"
        } else {
            Write-Host "    Status: Wireless adapter detected but no active connection" -ForegroundColor Yellow
            $htmlOutput += "<p class='warning'>Wireless adapter detected but no active connection</p></table>"
        }
    }
    
    # Get IP Configuration
    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex -ErrorAction SilentlyContinue
    
    if ($ipConfig) {
        $htmlOutput += "<h3>IP Configuration</h3><table class='info-table'>"
        
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

# Route Table Information
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Route Table Information" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$htmlOutput += "<h2>Route Table</h2>"
$htmlOutput += "<table><tr><th>Destination</th><th>Netmask</th><th>Gateway</th><th>Interface</th><th>Metric</th></tr>"

try {
    # Get routing table
    $routes = Get-NetRoute -AddressFamily IPv4 | 
        Where-Object { $_.DestinationPrefix -ne '255.255.255.255/32' } |
        Sort-Object -Property RouteMetric, DestinationPrefix
    
    if ($routes) {
        Write-Host "Active Routes:" -ForegroundColor Yellow
        Write-Host ("{0,-20} {1,-18} {2,-18} {3,-25} {4,6}" -f "Destination", "Netmask", "Gateway", "Interface", "Metric") -ForegroundColor Cyan
        Write-Host ("{0,-20} {1,-18} {2,-18} {3,-25} {4,6}" -f "-----------", "-------", "-------", "---------", "------") -ForegroundColor Cyan
        
        foreach ($route in $routes) {
            # Parse destination prefix
            $destParts = $route.DestinationPrefix -split '/'
            $destination = $destParts[0]
            $prefixLength = $destParts[1]
            
            # Convert prefix to netmask
            if ($prefixLength -eq 0) {
                $netmask = "0.0.0.0"
            } else {
                $netmask = Convert-PrefixToSubnetMask -PrefixLength ([int]$prefixLength)
            }
            
            # Get gateway
            $gateway = if ($route.NextHop -eq '0.0.0.0') { 'On-link' } else { $route.NextHop }
            
            # Get interface alias
            $interfaceAlias = (Get-NetAdapter -InterfaceIndex $route.InterfaceIndex -ErrorAction SilentlyContinue).Name
            if (-not $interfaceAlias) { $interfaceAlias = "Interface $($route.InterfaceIndex)" }
            
            # Display route
            Write-Host ("{0,-20} {1,-18} {2,-18} {3,-25} {4,6}" -f $destination, $netmask, $gateway, $interfaceAlias, $route.RouteMetric)
            
            # Add to HTML
            $htmlOutput += "<tr><td>$destination</td><td>$netmask</td><td>$gateway</td><td>$interfaceAlias</td><td>$($route.RouteMetric)</td></tr>"
        }
        
        # Summary
        Write-Host "`n  Total Routes: $($routes.Count)" -ForegroundColor Cyan
        $defaultRoutes = $routes | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }
        if ($defaultRoutes) {
            Write-Host "  Default Routes: $($defaultRoutes.Count)" -ForegroundColor Cyan
        }
        
    } else {
        Write-Host "No routes found" -ForegroundColor Yellow
        $htmlOutput += "<tr><td colspan='5'>No routes found</td></tr>"
    }
    
    $htmlOutput += "</table>"
    
} catch {
    Write-Host "ERROR: Unable to retrieve route table" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
    $htmlOutput += "<p class='failed'>Unable to retrieve route table: $($_.Exception.Message)</p>"
}

Write-Host "`n"

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

$htmlOutput += "<h2>Connectivity Tests</h2><table class='info-table'><tr><th>Endpoint</th><th>Result</th></tr>"

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

# ============================================
# WLAN EVENT LOGS SECTION
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "WLAN Event Log Analysis" -ForegroundColor Cyan
Write-Host "Timeframe: Last $WlanEventDays Day$(if ($WlanEventDays -gt 1) {'s'})" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$htmlOutput += "<h2>WLAN Event Log Analysis (Last $WlanEventDays Day$(if ($WlanEventDays -gt 1) {'s'}))</h2>"

try {
    $wlanEvents = Get-WinEvent -LogName Microsoft-Windows-WLAN-AutoConfig/Operational `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-$WlanEventDays) }
    
    if ($wlanEvents) {
        # Categorize events - INCLUDING CONNECTIONS
        $connections = $wlanEvents | Where-Object { $_.Id -in 8001, 11000, 11001 }  # Connection success events
        $disconnects = $wlanEvents | Where-Object { $_.Id -in 8003, 8000, 8002 }     # Disconnection events
        $roaming     = $wlanEvents | Where-Object { $_.Id -eq 11004 }                 # AP disconnect/connect (roaming)
        $authFails   = $wlanEvents | Where-Object { $_.Id -in 12011, 12013 }         # Authentication failures
        
        # Summary Box
        Write-Host "Event Summary:" -ForegroundColor Cyan
        Write-Host "  Total WLAN events: $($wlanEvents.Count)"
        Write-Host "  Connections: $($connections.Count)" -ForegroundColor Green
        Write-Host "  Disconnections: $($disconnects.Count)" -ForegroundColor $(if ($disconnects.Count -gt 0) {'Red'} else {'Green'})
        Write-Host "  AP Disconnect/Connect: $($roaming.Count)"
        Write-Host "  Authentication failures: $($authFails.Count)" -ForegroundColor $(if ($authFails.Count -gt 0) {'Red'} else {'Green'})
        Write-Host ""
        
        # HTML Summary
        $htmlOutput += @"
        <div class="summary-box">
            <h3>Event Summary</h3>
            <table class="info-table">
                <tr><td class="label">Total WLAN Events</td><td>$($wlanEvents.Count)</td></tr>
                <tr><td class="label">Connections</td><td class="success">$($connections.Count)</td></tr>
                <tr><td class="label">Disconnections</td><td class="$(if ($disconnects.Count -gt 0) {'failed'} else {'success'})">$($disconnects.Count)</td></tr>
                <tr><td class="label">AP Disconnect/Connect</td><td>$($roaming.Count)</td></tr>
                <tr><td class="label">Authentication Failures</td><td class="$(if ($authFails.Count -gt 0) {'failed'} else {'success'})">$($authFails.Count)</td></tr>
            </table>
        </div>
"@
        
        # Display CONNECTION events
        Write-Host "Connection Events:" -ForegroundColor Green
        $htmlOutput += "<h3 class='success'>Connection Events ($($connections.Count))</h3>"
        if ($connections) {
            # Console output with table format
            Write-Host ""
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "TimeStamp", "Id", "Message") -ForegroundColor Cyan
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "--------------------", "------", "-------") -ForegroundColor Cyan
            
            # HTML table
            $htmlOutput += "<div class='event-log' style='border-left: 4px solid #107c10;'><table style='width:100%'>"
            $htmlOutput += "<tr><th>TimeStamp</th><th>Id</th><th>Message</th></tr>"
            
            $connections | Select-Object -First 15 | ForEach-Object {
                $eventTime = $_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                $eventId = $_.Id
                
                # Extract specific information from the message
                $fullMessage = $_.Message
                $lines = $fullMessage -split "`r`n|`n"
                
                # Get first line (event description)
                $firstLine = $lines[0].Trim()
                
                # Extract Local MAC Address
                $macLine = $lines | Where-Object { $_ -match "Local MAC Address" } | Select-Object -First 1
                $macAddress = if ($macLine) { ($macLine -replace "Local MAC Address:", "").Trim() } else { "" }
                
                # Extract Network SSID
                $ssidLine = $lines | Where-Object { $_ -match "Network SSID" } | Select-Object -First 1
                $ssid = if ($ssidLine) { ($ssidLine -replace "Network SSID:", "").Trim() } else { "" }
                
                # Build condensed message
                $messageparts = @($firstLine)
                if ($macAddress) { $messageparts += "MAC: $macAddress" }
                if ($ssid) { $messageparts += "SSID: $ssid" }
                $condensedMessage = $messageparts -join " | "
                
                # Console output
                Write-Host ("  {0,-20} | {1,-6} | {2}" -f $eventTime, $eventId, $condensedMessage) -ForegroundColor Green
                
                # HTML output with line breaks for readability
                $htmlMessage = $firstLine
                if ($macAddress) { $htmlMessage += "<br><strong>MAC:</strong> $macAddress" }
                if ($ssid) { $htmlMessage += "<br><strong>SSID:</strong> $ssid" }
                
                $htmlOutput += "<tr><td class='timestamp'>$eventTime</td><td>$eventId</td><td>$htmlMessage</td></tr>"
            }
            
            if ($connections.Count -gt 15) {
                Write-Host ""
                Write-Host "  ... and $($connections.Count - 15) more connection events" -ForegroundColor Gray
                $htmlOutput += "<tr><td colspan='3'>... and $($connections.Count - 15) more connection events</td></tr>"
            }
            $htmlOutput += "</table></div>"
        } else {
            Write-Host "  No connection events found" -ForegroundColor Yellow
            $htmlOutput += "<p>No connection events found</p>"
        }
        Write-Host ""
        
        # Display DISCONNECTION events
        Write-Host "Disconnection Events:" -ForegroundColor Red
        $htmlOutput += "<h3 class='failed'>Disconnection Events ($($disconnects.Count))</h3>"
        if ($disconnects) {
            # Console output with table format
            Write-Host ""
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "TimeStamp", "Id", "Message") -ForegroundColor Cyan
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "--------------------", "------", "-------") -ForegroundColor Cyan
            
            # HTML table
            $htmlOutput += "<div class='event-log'><table style='width:100%'>"
            $htmlOutput += "<tr><th>TimeStamp</th><th>Id</th><th>Message</th></tr>"
            
            $disconnects | Select-Object -First 15 | ForEach-Object {
                $eventTime = $_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                $eventId = $_.Id
                
                # Extract specific information from the message
                $fullMessage = $_.Message
                $lines = $fullMessage -split "`r`n|`n"
                
                # Get first line (event description)
                $firstLine = $lines[0].Trim()
                
                # Extract Local MAC Address
                $macLine = $lines | Where-Object { $_ -match "Local MAC Address" } | Select-Object -First 1
                $macAddress = if ($macLine) { ($macLine -replace "Local MAC Address:", "").Trim() } else { "" }
                
                # Extract Network SSID
                $ssidLine = $lines | Where-Object { $_ -match "Network SSID" } | Select-Object -First 1
                $ssid = if ($ssidLine) { ($ssidLine -replace "Network SSID:", "").Trim() } else { "" }
                
                # Build condensed message
                $messageparts = @($firstLine)
                if ($macAddress) { $messageparts += "MAC: $macAddress" }
                if ($ssid) { $messageparts += "SSID: $ssid" }
                $condensedMessage = $messageparts -join " | "
                
                # Console output
                Write-Host ("  {0,-20} | {1,-6} | {2}" -f $eventTime, $eventId, $condensedMessage) -ForegroundColor Red
                
                # HTML output with line breaks for readability
                $htmlMessage = $firstLine
                if ($macAddress) { $htmlMessage += "<br><strong>MAC:</strong> $macAddress" }
                if ($ssid) { $htmlMessage += "<br><strong>SSID:</strong> $ssid" }
                
                $htmlOutput += "<tr><td class='timestamp'>$eventTime</td><td>$eventId</td><td>$htmlMessage</td></tr>"
            }
            
            if ($disconnects.Count -gt 15) {
                Write-Host ""
                Write-Host "  ... and $($disconnects.Count - 15) more disconnection events" -ForegroundColor Gray
                $htmlOutput += "<tr><td colspan='3'>... and $($disconnects.Count - 15) more disconnection events</td></tr>"
            }
            $htmlOutput += "</table></div>"
        } else {
            Write-Host "  No disconnection events found" -ForegroundColor Green
            $htmlOutput += "<p class='success'>No disconnection events found</p>"
        }
        Write-Host ""
        
        # Display ROAMING events (AP Disconnect/Connect)
        Write-Host "AP Disconnect/Connect Events:" -ForegroundColor Yellow
        $htmlOutput += "<h3>AP Disconnect/Connect Events ($($roaming.Count))</h3>"
        if ($roaming) {
            # Console output with table format
            Write-Host ""
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "TimeStamp", "Id", "Message") -ForegroundColor Cyan
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "--------------------", "------", "-------") -ForegroundColor Cyan
            
            # HTML table
            $htmlOutput += "<div class='event-log' style='border-left: 4px solid #0078d4;'><table style='width:100%'>"
            $htmlOutput += "<tr><th>TimeStamp</th><th>Id</th><th>Message</th></tr>"
            
            $roaming | Select-Object -First 15 | ForEach-Object {
                $eventTime = $_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                $eventId = $_.Id
                
                # Extract specific information from the message
                $fullMessage = $_.Message
                $lines = $fullMessage -split "`r`n|`n"
                
                # Get first line (event description)
                $firstLine = $lines[0].Trim()
                
                # Extract Local MAC Address
                $macLine = $lines | Where-Object { $_ -match "Local MAC Address" } | Select-Object -First 1
                $macAddress = if ($macLine) { ($macLine -replace "Local MAC Address:", "").Trim() } else { "" }
                
                # Extract Network SSID
                $ssidLine = $lines | Where-Object { $_ -match "Network SSID" } | Select-Object -First 1
                $ssid = if ($ssidLine) { ($ssidLine -replace "Network SSID:", "").Trim() } else { "" }
                
                # Build condensed message
                $messageparts = @($firstLine)
                if ($macAddress) { $messageparts += "MAC: $macAddress" }
                if ($ssid) { $messageparts += "SSID: $ssid" }
                $condensedMessage = $messageparts -join " | "
                
                # Console output
                Write-Host ("  {0,-20} | {1,-6} | {2}" -f $eventTime, $eventId, $condensedMessage)
                
                # HTML output with line breaks for readability
                $htmlMessage = $firstLine
                if ($macAddress) { $htmlMessage += "<br><strong>MAC:</strong> $macAddress" }
                if ($ssid) { $htmlMessage += "<br><strong>SSID:</strong> $ssid" }
                
                $htmlOutput += "<tr><td class='timestamp'>$eventTime</td><td>$eventId</td><td>$htmlMessage</td></tr>"
            }
            
            if ($roaming.Count -gt 15) {
                Write-Host ""
                Write-Host "  ... and $($roaming.Count - 15) more AP disconnect/connect events" -ForegroundColor Gray
                $htmlOutput += "<tr><td colspan='3'>... and $($roaming.Count - 15) more AP disconnect/connect events</td></tr>"
            }
            $htmlOutput += "</table></div>"
        } else {
            Write-Host "  No AP disconnect/connect events found"
            $htmlOutput += "<p>No AP disconnect/connect events found</p>"
        }
        Write-Host ""
        
        # Display AUTHENTICATION FAILURES
        Write-Host "Authentication Failures:" -ForegroundColor Red
        $htmlOutput += "<h3 class='failed'>Authentication Failures ($($authFails.Count))</h3>"
        if ($authFails) {
            # Console output with table format
            Write-Host ""
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "TimeStamp", "Id", "Message") -ForegroundColor Cyan
            Write-Host ("  {0,-20} | {1,-6} | {2}" -f "--------------------", "------", "-------") -ForegroundColor Cyan
            
            # HTML table
            $htmlOutput += "<div class='event-log'><table style='width:100%'>"
            $htmlOutput += "<tr><th>TimeStamp</th><th>Id</th><th>Message</th></tr>"
            
            $authFails | Select-Object -First 15 | ForEach-Object {
                $eventTime = $_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                $eventId = $_.Id
                
                # Extract specific information from the message
                $fullMessage = $_.Message
                $lines = $fullMessage -split "`r`n|`n"
                
                # Get first line (event description)
                $firstLine = $lines[0].Trim()
                
                # Extract Local MAC Address
                $macLine = $lines | Where-Object { $_ -match "Local MAC Address" } | Select-Object -First 1
                $macAddress = if ($macLine) { ($macLine -replace "Local MAC Address:", "").Trim() } else { "" }
                
                # Extract Network SSID
                $ssidLine = $lines | Where-Object { $_ -match "Network SSID" } | Select-Object -First 1
                $ssid = if ($ssidLine) { ($ssidLine -replace "Network SSID:", "").Trim() } else { "" }
                
                # Build condensed message
                $messageparts = @($firstLine)
                if ($macAddress) { $messageparts += "MAC: $macAddress" }
                if ($ssid) { $messageparts += "SSID: $ssid" }
                $condensedMessage = $messageparts -join " | "
                
                # Console output
                Write-Host ("  {0,-20} | {1,-6} | {2}" -f $eventTime, $eventId, $condensedMessage) -ForegroundColor Red
                
                # HTML output with line breaks for readability
                $htmlMessage = $firstLine
                if ($macAddress) { $htmlMessage += "<br><strong>MAC:</strong> $macAddress" }
                if ($ssid) { $htmlMessage += "<br><strong>SSID:</strong> $ssid" }
                
                $htmlOutput += "<tr><td class='timestamp'>$eventTime</td><td>$eventId</td><td>$htmlMessage</td></tr>"
            }
            
            if ($authFails.Count -gt 15) {
                Write-Host ""
                Write-Host "  ... and $($authFails.Count - 15) more authentication failures" -ForegroundColor Gray
                $htmlOutput += "<tr><td colspan='3'>... and $($authFails.Count - 15) more authentication failures</td></tr>"
            }
            $htmlOutput += "</table></div>"
        } else {
            Write-Host "  No authentication failures found" -ForegroundColor Green
            $htmlOutput += "<p class='success'>No authentication failures found</p>"
        }
        Write-Host ""
        # Connection/Disconnection Pattern Analysis
        if ($connections.Count -gt 0 -or $disconnects.Count -gt 0) {
            Write-Host "`nConnection Pattern Analysis:" -ForegroundColor Cyan
            Write-Host "  Connection/Disconnection Ratio: $($connections.Count):$($disconnects.Count)"
            
            if ($disconnects.Count -gt $connections.Count) {
                Write-Host "  WARNING: More disconnections than connections detected!" -ForegroundColor Red
                Write-Host "  This may indicate a persistent connectivity problem." -ForegroundColor Yellow
            } elseif ($disconnects.Count -eq 0 -and $connections.Count -gt 0) {
                Write-Host "  No disconnections detected - connection appears stable." -ForegroundColor Green
            }
            
            $htmlOutput += @"
            <div class="summary-box">
                <h3>Connection Pattern Analysis</h3>
                <p><strong>Connection/Disconnection Ratio:</strong> $($connections.Count):$($disconnects.Count)</p>
"@
            if ($disconnects.Count -gt $connections.Count) {
                $htmlOutput += "<p class='failed'><strong>WARNING:</strong> More disconnections than connections detected! This may indicate a persistent connectivity problem.</p>"
            } elseif ($disconnects.Count -eq 0 -and $connections.Count -gt 0) {
                $htmlOutput += "<p class='success'>No disconnections detected - connection appears stable.</p>"
            }
            $htmlOutput += "</div>"
        }
        
    } else {
        Write-Host "No WLAN events found in the last $WlanEventDays day$(if ($WlanEventDays -gt 1) {'s'})" -ForegroundColor Gray
        $htmlOutput += "<p>No WLAN events found in the specified timeframe.</p>"
    }
    
} catch {
    Write-Host "ERROR: Unable to retrieve WLAN event logs" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
    $htmlOutput += "<p class='failed'>Unable to retrieve WLAN event logs: $($_.Exception.Message)</p>"
}

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