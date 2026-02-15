# WiFI Troubleshooting: Notes


Windows Event Log items

**Windows WLAN Event 11004** indicates that wireless security has stopped, signifying that the WLAN AutoConfig service has disconnected from a network. It often causes temporary, random Wi-Fi drops and is frequently seen alongside events 11005 (security started) and 11010 (security succeeded).  
Common causes include driver issues, network card misconfigurations, or EAP authentication issues.   

Key Troubleshooting Steps for Event 11004:  
- Update/Reinstall Drivers: Update or clean-reinstall the Wi-Fi adapter driver (especially for Intel modules).
- Restart WLAN Service: Restart the "WLAN AutoConfig" service in services.msc and set to Automatic.  
- Check Certificate/Auth: Clear outdated cached certificates in the MMC certificate snap-in and verify GPO settings, specifically for enterprise networks.  
- Disable Power Saving: Disable "Allow the computer to turn off this device to save power" in the Network Adapter properties in Device Manager.  
- Reset Network: Use the "Network reset" option in Windows Settings.  
The event frequently appears during "micro-drops" where the network connection is lost for a few seconds.  


**Event ID 11004 (Wireless Security Stopped):** This event is triggered when the security handshake (authentication/encryption) for an active session is terminated. It is typically a consequence of a disconnection or a session timeout rather than the cause itself. Common triggers include:
The user manually disconnecting.
The Wi-Fi driver dropping the connection due to signal loss.
The system entering a low-power or hibernate state.

**Event ID 11010 (Wireless Security Started):** This event marks the start of the security negotiation phase (e.g., WPA2/WPA3 handshake). It usually follows a successful association with an access point.

------------------------

When you see **Event 11004** (Security Stopped) followed by **Event 11010** (Security Started) with a 5–30 second gap, it indicates a "**Micro-Drop**" and ****Reconnect loop**. Your system is losing its secure session and then hunting for a new one shortly after.  

**Likely Causes for the 5-30 Second Delay**  
- **Driver Timeout or Failure:** The most common culprit is a Wi-Fi driver that has crashed or hung. The 5–30 second gap is the time it takes for the driver to reset itself and restart the security handshake.
- **"Limitless Connectivity" Monitoring:** The Windows WLAN-AutoConfig service monitors internet reachability. If it detects a momentary loss of internet (even if Wi-Fi is still "connected"), it may drop the security session to force a fresh, clean reconnection.
- **IP Address Conflict or DHCP Delay:** If the security stops (11004), the subsequent delay often comes from the system waiting to receive a new IP address from your router before it can successfully start a new security session.
- **Interference or Signal Weakness:** If your device is at the edge of the router's range, external interference (like a microwave or a neighbor's router) can kill the session. The 30-second delay is the "cooling off" period before the AutoConfig service attempts to re-associate

------
Get-WinEvent -LogName Microsoft-Windows-WLAN-AutoConfig/Operational -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-7) } | Where-Object { ($_.Id -eq 11004) -or ($_.Id -eq 11010) -or ($_.Id -eq 8003) }

