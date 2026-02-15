# Network Adapter Information Script

A comprehensive PowerShell script for diagnosing and troubleshooting network connectivity issues on Windows 11 systems. Perfect for remote support and corporate IT environments.

## Overview

This script gathers detailed network adapter information and performs connectivity tests, then exports the results both to the console and as a professional HTML report. It requires no administrator privileges and works in restricted corporate environments.

## Features

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

### WLAN Event Log Analysis (Last 24 Hours)
- **Disconnect Events** - Tracks unexpected disconnections
- **Roaming Events** - Access point handoffs
- **Authentication Failures** - Connection attempt failures
- Event summary with counts and timestamps

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
- Professional, styled HTML report
- Automatic save to `C:\install\NetworkAdapterReport_YYYYMMDD_HHMMSS.html`
- Color-coded status indicators
- Opens automatically in default browser
- Perfect for email attachments and documentation

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
3. The script will execute and display results in the console
4. HTML report will open automatically in your browser

### Method 2: PowerShell Console
```powershell
# Navigate to script location
cd C:\Scripts

# Execute the script
.\Get-NetworkAdapterInfo.ps1
```

### Method 3: Remote Execution
For remote troubleshooting scenarios:
```powershell
# Using PowerShell remoting
Invoke-Command -ComputerName REMOTE-PC -FilePath .\Get-NetworkAdapterInfo.ps1

# Copy script to remote machine first, then execute
Copy-Item .\Get-NetworkAdapterInfo.ps1 -Destination "\\REMOTE-PC\C$\Temp\"
Invoke-Command -ComputerName REMOTE-PC -ScriptBlock {
    C:\Temp\Get-NetworkAdapterInfo.ps1
}
```

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

Host Name: DESKTOP-ABC123

┌─────────────────────────────────────────────────────────────
│ Adapter: Wi-Fi
└─────────────────────────────────────────────────────────────

  Interface Description: Intel(R) Wi-Fi 6 AX201 160MHz
  Status: Up
  MAC Address (Physical Address): 12:34:56:78:9A:BC
  Link Speed: 1.2 Gbps

  Driver Information:
    Driver Version: 22.140.0.7
    ...

  IPv4 Address: 192.168.1.100
  Subnet Mask: 255.255.255.0 (/24)
  Default Gateway: 192.168.1.1
  ...
```

### HTML Report
The HTML report includes all the same information with:
- Professional styling and layout
- Color-coded status indicators
- Organized tables
- Easy-to-read formatting
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

### Version 1.0 (Initial Release)
- Basic adapter information gathering
- Driver details collection
- IP configuration display
- Connectivity testing with 5 pings
- HTML report generation
- Wireless-specific information
- WLAN event log analysis
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
