# Network Adapter Information Script

A comprehensive PowerShell script for diagnosing and troubleshooting network connectivity issues on Windows 11 systems. Perfect for remote support and corporate IT environments.

## Overview

This script gathers detailed network adapter information and performs connectivity tests, then exports the results both to the console and as a professional HTML report. It requires no administrator privileges and works in restricted corporate environments.

## Features

### System Information
- **User Information**
  - Username
  - User Domain
  - User DNS Domain

- **System Details**
  - Computer Name
  - System Manufacturer and Model
  - BIOS Date and Version
  - OS Build Number
  - Machine ID (GUID)
  - MDM Enrollment Status
  - System Uptime

### Network Adapter Information
- **Basic Information**
  - Interface description
  - Connection status (Up/Down)
  - MAC/Physical address
  - Link speed

- **Driver Details**
  - Driver description
  - Driver file name
  - Driver version
  - Interface description (ifDesc)

- **IP Configuration**
  - IPv4/IPv6 addresses
  - Subnet mask (with CIDR notation)
  - Default gateway
  - DNS servers
  - DHCP status

### Wireless-Specific Information (for Wi-Fi adapters)
- Interface type
- Connection state
- SSID (network name)
- BSSID (Access Point MAC address)
- Band (2.4GHz/5GHz)
- Channel
- Radio type (802.11ac, 802.11ax, etc.)
- Authentication method
- Signal strength

### Route Table Information
- Complete IPv4 routing table
- Destination networks with subnet masks
- Gateway addresses ("On-link" for direct connections)
- Interface assignments
- Route metrics
- Summary statistics (total routes, default routes)

### WLAN Event Log Analysis (Configurable Timeframe: 1, 3, or 7 Days)
- **Connection Events** - Successful wireless connections with timestamps
- **Disconnection Events** - Wireless disconnections with detailed reasons
- **AP Disconnect/Connect Events** - Access point roaming and handoffs
- **Authentication Failures** - Connection attempt failures
- **Event Pattern Analysis** - Connection/disconnection ratio with warnings
- **Detailed Event Tables** - Formatted output showing timestamps, event IDs, and extracted details (SSID, MAC address)
- Event summary with counts and timestamps
- **Configurable timeframe:** 1, 3, or 7 days (default: 1 day)

### Connectivity Tests
- **Gateway connectivity** - Tests each adapter's default gateway
- **Internet connectivity** - Pings Google DNS (8.8.8.8)
- **DNS resolution** - Tests DNS functionality
- **Custom corporate endpoints** - Easily add your own test targets

All tests include:
- 5 ping attempts for reliability
- Average, minimum, and maximum response times
- Packet loss detection

### HTML Report Export
- Professional, styled HTML report with consistent 25/75 column layouts
- Automatic save to `C:\install\NetworkAdapterReport_YYYYMMDD_HHMMSS.html`
- Color-coded status indicators (green=success, red=failed, yellow=warning)
- Opens automatically in default browser
- Perfect for email attachments and documentation
- Includes all system information, adapters, routes, and WLAN events
- Properly formatted multi-column tables for route and event data

## Requirements

- **Operating System:** Windows 11 (also compatible with Windows 10)
- **PowerShell:** 5.1 or higher (included in Windows 11)
- **Permissions:** Standard user (no admin rights required)
- **Network Access:** Script does not require internet access to run (only for connectivity tests)

## Installation

1. Download the `Get-NetworkAdapterInfo.ps1` script
2. Save it to a convenient location (e.g., `C:\Scripts` or user's Desktop)
3. Ensure the `C:\install` directory exists or has write permissions (script will create it)

## Usage

### Method 1: Right-Click Execution
1. Right-click on `Get-NetworkAdapterInfo.ps1`
2. Select **"Run with PowerShell"**
3. The script will execute and display results in the console (default: 1 day of WLAN events)
4. HTML report will open automatically in your browser

### Method 2: PowerShell Console
```powershell
# Navigate to script location
cd C:\Scripts

# Execute with default settings (1 day of WLAN events)
.\Get-NetworkAdapterInfo.ps1

# Execute with 3 days of WLAN events
.\Get-NetworkAdapterInfo.ps1 -WlanEventDays 3

# Execute with 7 days of WLAN events
.\Get-NetworkAdapterInfo.ps1 -WlanEventDays 7
```

### Method 3: Remote Execution
For remote troubleshooting scenarios:
```powershell
# Using PowerShell remoting (with custom WLAN timeframe)
Invoke-Command -ComputerName REMOTE-PC -FilePath .\Get-NetworkAdapterInfo.ps1 -ArgumentList 3

# Copy script to remote machine first, then execute with 7 days of events
Copy-Item .\Get-NetworkAdapterInfo.ps1 -Destination "\\REMOTE-PC\C$\Temp\"
Invoke-Command -ComputerName REMOTE-PC -ScriptBlock {
    C:\Temp\Get-NetworkAdapterInfo.ps1 -WlanEventDays 7
}
```

## Script Parameters

### -WlanEventDays
**Type:** Integer  
**Valid Values:** 1, 3, 7  
**Default:** 1  
**Description:** Specifies how many days of WLAN event logs to retrieve and analyze.

**Examples:**
```powershell
# Default - last 1 day
.\Get-NetworkAdapterInfo.ps1

# Last 3 days - useful for intermittent issues
.\Get-NetworkAdapterInfo.ps1 -WlanEventDays 3

# Last 7 days - comprehensive analysis for recurring problems
.\Get-NetworkAdapterInfo.ps1 -WlanEventDays 7
```

**Use Cases:**
- **1 Day (Default):** Quick troubleshooting of current issues
- **3 Days:** Investigation of intermittent connectivity problems
- **7 Days:** Comprehensive analysis for recurring or pattern-based issues

## Customization

### Adding Corporate Endpoints

To add custom connectivity tests for your corporate environment, edit the script and uncomment/modify the examples in the "Corporate Endpoints" section:

```powershell
# Uncomment and customize these examples:
Test-NetworkEndpoint -EndpointName "Corporate VPN Gateway" -EndpointAddress "vpn.company.com"
Test-NetworkEndpoint -EndpointName "Internal File Server" -EndpointAddress "fileserver.internal.company.com"
Test-NetworkEndpoint -EndpointName "Domain Controller" -EndpointAddress "dc01.company.local"
Test-NetworkEndpoint -EndpointName "Internal Web Portal" -EndpointAddress "intranet.company.com"
Test-NetworkEndpoint -EndpointName "Exchange Server" -EndpointAddress "mail.company.com"
Test-NetworkEndpoint -EndpointName "Office 365" -EndpointAddress "outlook.office365.com"
```

### Adjusting Ping Count

To change the number of pings per test, modify the `$Count` parameter:

```powershell
Test-NetworkEndpoint -EndpointName "Critical Server" -EndpointAddress "server.company.com" -Count 10
```

### Changing HTML Export Location

To change the output directory, modify the `$reportPath` variable:

```powershell
$reportPath = "C:\install"  # Change to your preferred location
```

## Output Examples

### Console Output
```
========================================
Network Adapter Information Report
Generated: 2025-02-15 14:30:00
========================================

System Information
----------------------------------------

User Info:
  Username: john.smith
  User Domain: CORPORATE
  User DNS Domain: corporate.company.com

System Info:
  ComputerName: LAPTOP-ABC123
  System Manufacturer: Dell Inc.
  System Product Name: Latitude 7420
  BIOS Date: 2024-08-15
  BIOS Version: 1.25.0
  OS Build: 10.0.22631 (Build 22631)
  Machine Id: 12345678-90ab-cdef-1234-567890abcdef
  MDM Joined: Yes
  UpTime: 3 days, 14 hours, 22 minutes
  WLAN Event Log Timeframe: Last 1 day

┌─────────────────────────────────────────────────────────────
│ Adapter: Wi-Fi
└─────────────────────────────────────────────────────────────

  Interface Description: Intel(R) Wi-Fi 6 AX201 160MHz
  Status: Up
  MAC Address (Physical Address): 12:34:56:78:9A:BC
  Link Speed: 1.2 Gbps
  
  Wireless Information:
    SSID: Corporate-WiFi
    Band: 5 GHz
    Signal Strength: 95%
    ...

========================================
WLAN Event Log Analysis
Timeframe: Last 1 day
========================================

Event Summary:
  Total WLAN events: 45
  Connections: 8
  Disconnections: 15
  AP Disconnect/Connect: 12
  Authentication failures: 2

Connection Events:

  TimeStamp            | Id     | Message
  -------------------- | ------ | -------
  2025-02-15 09:15:23 | 8001   | Wireless security started | MAC: AA:BB:CC:DD:EE:FF | SSID: Corporate-WiFi

Disconnection Events:

  TimeStamp            | Id     | Message
  -------------------- | ------ | -------
  2025-02-15 10:45:12 | 8003   | WLAN disconnect complete | MAC: AA:BB:CC:DD:EE:FF | SSID: Corporate-WiFi

Connection Pattern Analysis:
  Connection/Disconnection Ratio: 8:15
  WARNING: More disconnections than connections detected!
  This may indicate a persistent connectivity problem.
```

### HTML Report
The HTML report includes all the same information with:
- Professional styling and layout with consistent 25/75 column widths
- Color-coded status indicators
- System information section at the top
- Organized tables for all adapters
- Route table with complete routing information
- Full WLAN event logs with formatted tables
- Connectivity test results
- Printer-friendly design

## Troubleshooting

### "Execution Policy" Error

If you receive an execution policy error:

```powershell
# Check current policy
Get-ExecutionPolicy

# Temporarily bypass for this session
PowerShell.exe -ExecutionPolicy Bypass -File .\Get-NetworkAdapterInfo.ps1

# Or set policy for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### HTML Report Not Saving

**Issue:** "Failed to save HTML report"

**Solutions:**
1. Ensure `C:\install` directory exists
2. Check write permissions on the directory
3. Try running from a different location with write access
4. Modify the `$reportPath` variable in the script to a location you can write to

### No Wireless Information Displayed

**Issue:** Wireless adapter detected but no details shown

**Solutions:**
1. Ensure the adapter is enabled
2. Connect to a wireless network
3. Check if `netsh wlan show interfaces` works manually
4. Verify Windows WLAN AutoConfig service is running

### WLAN Event Logs Not Available

**Issue:** "Unable to retrieve WLAN event logs"

**Solutions:**
1. Event log access may be restricted in some corporate environments
2. This is informational only and doesn't affect other functionality
3. Contact IT if event log access is required

## Use Cases

### Remote Troubleshooting
1. Send script to user via email or file share
2. Have user execute the script
3. User sends back the HTML report
4. Review comprehensive network diagnostics remotely

### Baseline Documentation
1. Run script on working systems
2. Save HTML reports for reference
3. Compare against reports from problematic systems
4. Identify configuration differences

### Corporate Deployment
1. Deploy script via Group Policy or SCCM
2. Customize corporate endpoints
3. Schedule periodic execution
4. Collect HTML reports centrally for analysis

### Training and Documentation
1. Use HTML reports for training materials
2. Document network configurations
3. Create troubleshooting guides
4. Build knowledge base articles

## Security Considerations

- **No Admin Required:** Script runs with standard user permissions
- **Read-Only Operations:** Only gathers information, makes no configuration changes
- **No Credentials:** Does not prompt for or store any passwords
- **Local Execution:** No data sent to external servers
- **Open Source:** All code is visible and auditable

## Script Maintenance

### Updating Corporate Endpoints
Regularly review and update the corporate endpoint tests to reflect:
- Infrastructure changes
- New critical services
- Decommissioned servers
- Network redesigns

### Version Control
Consider maintaining the script in a version control system (Git) to:
- Track changes over time
- Enable rollback if needed
- Collaborate with team members
- Document modification history

## Support and Feedback

For issues, questions, or feature requests:
1. Review this README thoroughly
2. Check the Troubleshooting section
3. Examine the script comments for additional guidance
4. Contact your IT support team for corporate environment issues

## License

This script is provided as-is for corporate IT use. Modify and distribute as needed within your organization.

## Changelog

### Version 1.2 (Current)
- **System Information Section:** Added comprehensive user and system details
  - User: Username, Domain, DNS Domain
  - System: Manufacturer, Model, BIOS, OS Build, Machine ID, MDM Status, Uptime
- **Enhanced WLAN Event Logs:** Moved to standalone section after connectivity tests
  - Now tracks BOTH connection AND disconnection events
  - Renamed "Roaming Events" to "AP Disconnect/Connect Events"
  - Formatted table output (TimeStamp | Id | Message)
  - Intelligent message extraction (first line, MAC address, SSID)
  - Connection pattern analysis with warnings
  - Displays up to 15 events per category (increased from 10)
  - Full HTML integration with all event details
- **Route Table Display:** Complete IPv4 routing table with gateway, interface, and metrics
- **HTML Report Improvements:**
  - Fixed column width ratios (25/75) for all two-column tables
  - System information included in report
  - Wireless information now appears in HTML
  - Proper table formatting for multi-column tables (routes, events)
  - Consistent styling across all sections

### Version 1.1
- Added configurable WLAN event log timeframe parameter (-WlanEventDays)
- Support for 1, 3, or 7 days of WLAN event history
- Added route table information display
- Enhanced HTML report with route table data

### Version 1.0 (Initial Release)
- Basic adapter information gathering
- Driver details collection
- IP configuration display
- Connectivity testing with 5 pings
- HTML report generation
- Wireless-specific information
- WLAN event log analysis (24 hours)
- Corporate endpoint customization
- Detailed response time metrics (avg/min/max)
- Packet loss detection
- Professional HTML styling

## Author Notes

This script was designed specifically for corporate IT environments where:
- Admin rights are restricted
- Remote troubleshooting is common
- Documentation is critical
- Network reliability is paramount

Feel free to customize and extend it for your specific needs!

---

**Last Updated:** February 2025  
**Compatible With:** Windows 11, Windows 10  
**PowerShell Version:** 5.1+
