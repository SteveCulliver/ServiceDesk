# ServiceDesk Troubleshooting Runbook (On-Site + GSD) 

**Audience:** On-Site Support + Global ServiceDesk (GSD)  
**Goal:** Resolve quickly when possible, and escalate with complete evidence when not.  

**Rule:** Every action must answer two questions:
- **Purpose:** why we’re doing it (what hypothesis / routing decision it supports)
- **Capture:** what evidence goes into the ticket (screenshots, error codes, outcomes)

---
---

## 1) Ticket Intake Standard (All INC tickets)

### 1.1 Required ticket fields (minimum)

- [ ] **User:** Name, UPN/userID (521)
- [ ] **Device:** Hostname, asset tag
- [ ] **Device type:** Physical, VDI/CloudPC, or workstation
- [ ] **Location:** Home / office site / travelling; Wi-Fi or LAN; VPN yes/no
- [ ] **App/Service:** Name, URL (if web), version (if installed)
- [ ] **Impact:** Cannot work / degraded / single feature or function
- [ ] **Start time:** When it started + “last known working”
- [ ] **Error:** Exact message + code + screenshot/photo
- [ ] **Scope check:** “Is anyone else impacted?” (same team/site/app)

### 1.2 Problem classification (choose one lane)

- [ ] **Authentication - Sandoz 521** (sign-in, MFA, password, account locked)
- [ ] **Software - M365** (Outlook/Teams/OneDrive/etc.)
- [ ] **Software - Web applications** (browser-based app)
- [ ] **Software - Installed** (Company Portal app)
- [ ] **Hardware** (power/boot/peripherals)
- [ ] **Connectivity** (Wi-Fi/LAN/ZTNA/DNS/PROXY/NETSCOPE)
- [ ] **Accessories** (headset/mouse/keyboard/webcam/monitor)
    

> **Capture:** Your chosen lane as the ticket category/subcategory.

---
---

## 2) Decision Guide (1-minute routing)

### 2.1 Is this likely an outage/incident?

**Indicators**
- Multiple users affected (same app/site/time window)
- Same error code appears across users
- Service health banner known (if you have access)
	
**Action**
- Flag as **Potential Incident**, link related tickets, proceed with minimal troubleshooting and fast escalation.
	
> **Capture:** # affected, locations, timestamps, common error text/code.

### 2.2 Is this access/entitlement vs break/fix?

**Indicators**
- User can reach login page but gets “not authorized/forbidden/no role”
- New user/new role/new app
- Only one user affected and error appears after login
	
**Action**
- Route to **Access Request / App Owner** rather than break/fix.

> **Capture:** app name, URL, entitlement/role missing message, catalog item (if known).

---
---

## 3) Authentication (Account / Password / MFA)

### 3.1 Sandoz 521

#### 3.1.1 Procedure

- [ ] Does the user have an active **userID (521)**? (Workday & EndpointOps / Intune)
    - **Purpose:** Confirm the identity exists and is enabled (rule out disable/lock/termination).
    - **Capture:** Account status (exists/enabled/locked/disabled), lock reason (if shown), last sign-in (if available).
    - **Tip:** Workday is origin for all end-user accounts. All users must exist in Workday before they can be found in EntraID (ie EndPointOps/Intune).
    - **Tip:** Generic accounts & mailboxes do not have matching profile in Workday.
		
- [ ] Does the user have a registered **MFA**? (Authenticator / Phone / Token / YubiKey)
    - **Purpose:** Confirm the user can complete the required second factor (rule out enrollment/device issues)
	- **Capture:** MFA method(s), enrollment status, user’s available device, exact error text/code
	- **Tip:** Check user's mobile device has WiFi/Data access
    - **Tip:** Check user's mobile device has correct date/time/time-zone
		
- [ ] Is the **userID (521)** password valid?
	- **Purpose:** Separate bad password vs expired vs forced reset vs sync delay.
	- **Capture:** Exact error text/code, whether prompted to change password, last known successful login time.
		
- [ ] Is the user logging in via **521@sandoz.net & password** or **SSO (Microsoft Authentication)** or **Direct Application** login screen (eg SAP)?
	- **Purpose:** Identify the auth path to route correctly (SSO/Entra vs app-local auth).
	- **Capture:** App name, login URL, screenshot of login page (showing provider), where failure occurs (pre-auth/MFA/post-auth).
	- **Tip:** User's device must be Intune complaint
		
#### 3.1.2 Escalation Matrix

| Issue                      | Level 1   | Level 2             | Level 3   |
| -------------------------- | --------- | ------------------- | --------- |
| **Account not in Workday** | GSD & OSS | ServiceDesk Level-2 | local P&O |
| **Account not in EntraID** | GSD & OSS | ServiceDesk Level-2 | IAM-Simba |
| **MFA issue**              | GSD & OSS | ServiceDesk Level-2 |           |

### 3.2 SAP
#### 3.2.1 Procedure
SAP application issues

#### 3.2.2 Escalation Matrix

| Issue   | Level 1   | Level 2 | Level 3 |
| ------- | --------- | ------- | ------- |
| Issue01 | GSD & OSS | -nil-   | -nil-   |

### 3.3 In-House Application
#### 3.3.1 Procedure
Applications developed or hosted directly on Sandoz infrastructure
#### 3.3.2 Escalation Matrix
- **Direct app auth issue →** App owner/vendor support (refer to KBs)

### 3.4 External Hosted Application
#### 3.4.1 Procedure
Applications NOT hosted directly on Sandoz infrastructure
#### 3.4.2 Escalation Matrix
- **Direct app auth issue →** App owner/vendor support (refer to KBs)

---
---

## 4) Software

- [ ] Is the application **browser-based** or **installed** (Company Portal)?
    - **Purpose:** Choose the correct troubleshooting flow and ownership (web vs packaging/endpoint).
    - **Capture:** App name, access method, Company Portal name (if installed), version (if visible).
	    
### 4.1 General checks

#### 4.1.1 Procedure

- [ ] **Is the user’s account active?**
    - **Purpose:** Rule out identity lifecycle issues before app troubleshooting.
    - **Capture:** Account state + any lock/disable reason.
	    
- [ ] **Is the user’s password still valid?**
    - **Purpose:** Confirm credentials aren’t the root cause of sign-in failures.
    - **Capture:** Error text/code, password expiry prompt details.
        
- [ ] Is the user at **home**, **in office**, or on **VDI/CloudPC**?
    - **Purpose:** Determine policy/network path and support lane.
    - **Capture:** Location, connection type (LAN/Wi-Fi/VPN), device type (physical/VDI/CloudPC).
        
- [ ] **Is the network stable (Wi-Fi vs LAN)?**
    - **Purpose:** Identify transport instability and narrow to local network vs service issue.
    - **Capture:** Wi-Fi SSID or wired/dock, whether others are affected.
        
- [ ] **Has the user rebooted the device?**
    - **Purpose:** Clear hung services, complete pending updates, refresh auth tokens.
    - **Capture:** Reboot performed (yes/no), approximate time.
        
- [ ] **Is the issue isolated or affecting multiple users?**
    - **Purpose:** Decide incident/outage vs single-user/device issue.
    - **Capture:** Scope (how many / which site/team), shared error pattern.
        
- [ ] **Any recent change (patch, update, policy) that might affect the app?**
    - **Purpose:** Correlate onset to change windows (common root cause).
    - **Capture:** “Last time it worked,” OS/app update timing, recent installs/changes.
        
- [ ] **Is the issue isolated or affecting multiple users?**
    - **Purpose:** Decide incident/outage vs single-user/device issue.
    - **Capture:** Scope (how many / which site/team), similar tickets, shared error pattern.
        
- [ ] **Any error message displayed? (Capture screenshot)**
    - **Purpose:** Use exact error to route and reduce back-and-forth.
    - **Capture:** Screenshot, exact error text/code, timestamp, steps to reproduce.
        
---
### 4.2 M365 software (Web & Installed)

> [!IMPORTANT]
> 
> Microsoft Applications: Single user issues are to be solved by ServiceDesk (OSS, GSD, and MCC). Do not transfer to any external team unless directly instructed by a Team-Lead.

#### 4.2.1 Procedure
- [ ] Microsoft standard application? {Outlook, OneDrive, Teams, Office365 (Word, Excel, PowerPoint, OneNote)}
	- **Purpose:** Confirm if one of: 
	- **Capture:** Application name, URL (if web app)
		
- [ ] Is it a Microsoft additional application; and is the user licensed for this application?
	- **Purpose:** Confirm entitlement (SKU/service plan) before deep troubleshooting.
	- **Capture:** License/SKU name, assignment method (direct/group), activation status if available.
		
	- **Purpose:** Route to the correct support team; follow M365 escalation SOP.
	- **Capture:** App name, user UPN, tenant (if available), exact error code, timestamp, screenshots.
		
 
> **Escalation:** For Microsoft apps, engage the **MCC support team** unless a KB directs to another M365 team.

#### 4.2.2 Escalation Matrix

| Application | Level 1   | Level 2 | Level 3 |
| ----------- | --------- | ------- | ------- |
| Outlook     | GSD & OSS | MCC     | *-nil-* |
| Teams       | GSD & OSS | MCC     | Collab  |
| Office365   | GSD & OSS | MCC     | *-nil-* |

### 4.3 Web (Browser) applications
#### 4.3.1 Procedure

- [ ] URL (mandatory)
	- **Purpose:** Ensure we troubleshoot the correct environment/tenant/portal.
	- **Capture:** Full URL (including subdomain/tenant), whether it’s internal/external.
		
- [ ] Which browser is being used? (Chrome, Edge, etc.)
	- **Purpose:** Identify browser-specific issues (policies, profiles, extensions).
	- **Capture:** Browser name + version, work vs personal profile, relevant extensions/VPN.
		
- [ ] Is the browser up to date?
	- **Purpose:** Confirm supported version before escalation.
	- **Capture:** Browser version and update status.
		
- [ ] Can the user reach the login page?
	- **Purpose Separate DNS/network blocking from auth/app issues.
	- **Capture:** What loads/doesn’t load, screenshot, whether it works on another network/device.
		
- [ ] Have you tried an incognito/private window and disabling extensions? (preferred before clearing cache)
	- **Purpose:** Rule out cached tokens/cookies or extension interference quickly.
	- **Capture:** Test results (incognito/extension-off), any change in error.
		
- [ ] Can the user successfully log in?
	- **Purpose:** Identify which step fails (credentials, MFA, redirect, post-login authorization).
	- **Capture:** Failure step + error code + screenshot.
		
- [ ] Who/which team grants access approval? (Which catalog form?)
	- **Purpose Distinguish access request vs break/fix and route accordingly.
	- **Capture:** Required entitlement/role, catalog item name/link, requester’s business justification (if needed).
		
- [ ] Is there an in-app **Support** option on the home page?
	- **Purpose Use the vendor/app support path when required, after collecting diagnostics.
	- **Capture:** Support link/contact, any ticket/reference number created.
		
- [ ] Is MFA required and completed successfully?
	- **Purpose Confirm MFA isn’t the blocker (or identify MFA-specific failure).
	- **Capture:** MFA method used, error prompt/code, whether MFA works for other apps.
		
#### 4.3.2 Escalation Matrix

| Issue   | Level 1   | Level 2 | Level 3 |
| ------- | --------- | ------- | ------- |
| Issue01 | GSD & OSS | -nil-   | -nil-   |

---

### 4.4 Installed Applications
#### 4.4.1 Procedure

- [ ] Was it installed from **Company Portal**?
	- **Purpose Confirm supported/managed install source and packaging.
	- **Capture:** Install source, app display name in Company Portal, version.
		
- [ ] Does Company Portal show **Installed**? (Was installation successful?)
	- **Purpose Verify install state and detect failed deployments.
	- **Capture:** Company Portal status, last install attempt time, error code/log if shown.
		
- [ ] Any error message during launch or login? (Capture screenshot)
	- **Purpose Distinguish crash/launch failure vs auth failure.
	- **Capture:**Screenshot, exact error text/code, when it occurs.
		
- [ ] Any functionality error after launch & login? (Capture screenshot)
	- **Purpose Scope the defect to a feature/workflow (not general access).
	- **Capture:** Steps to reproduce, what works vs fails, sample time/data affected (non-sensitive).
		
- [ ] Is the software dependent on other components (e.g., .NET, Java)?
	- **Purpose Confirm prerequisites and versions aren’t missing/outdated.
	- **Capture:**Dependency versions, recent updates to those components.
		
- [ ] Does the issue occur on another device or user profile?
	- **Purpose Isolate user vs device vs profile corruption.
	- **Capture:** Test matrix results (same user/other device; other user/same device).
		
- [ ] Is there a known KB article or workaround?
	- **Purpose Standardize quick fixes and reduce repeat escalations.
	- **Capture:** KB link/title and outcome (worked/didn’t).
		
#### 4.4.2 Escalation Matrix

| Issue   | Level 1   | Level 2 | Level 3 |
| ------- | --------- | ------- | ------- |
| Issue01 | GSD & OSS |         | -nil-   |

---
---

## 5) Hardware

### 5.1 Computer (End-User)

#### 5.1.1 Procedure

- [ ] Device type: **Physical laptop/desktop**, **CloudPC/VDI**, or **Workstation**?
	- **Purpose:** Determine ownership and correct support lane immediately.
	- **Capture:** Hostname, asset tag, device type, user location.
		
- [ ] Is the device assigned to the user/caller in **Intune/EndpointOps**?
	- **Purpose:** Confirm the correct user-device pairing (avoid shared/loaner confusion).
	- **Capture:**Enrollment/assignment details, primary user (if shown).
		
- [ ] Is the device assigned to the user/caller in **Asset Management**?
	- **Purpose:** Validate inventory and warranty/replace eligibility.
	- **Capture:** Asset record status, model, warranty/coverage (if available).
		
- [ ] Is the device compliant in **Intune/Endpoint Manager**?
	- **Purpose:** Identify compliance blocks causing access restrictions.
	- **Capture:** Compliance state + noncompliance reason/policy name.
		
- [ ] Power status: does the device power on?
	- **Purpose:** Separate no-power vs no-display vs OS boot issues.
	- **Capture:**LED behavior, charger/dock used, any beeps, whether fan/spin occurs.
		
- [ ] Any error messages during boot? (Capture photo/code)
	- **Purpose:** Use boot errors to route (BitLocker/UEFI/boot device/hardware).
	- **Capture:** Photo of screen, exact code/message.
		
- [ ] Can the user reach the login screen?
	- **Purpose:** Identify pre-OS vs OS/user-profile issues.
	- **Capture:** Where it stops (BIOS/logo/spinning/login), screenshot/photo.
		
- [ ] Are peripherals working? (Monitor, keyboard, mouse)
	- **Purpose:** Isolate dock/port/peripheral failures from endpoint failure.
	- **Capture:** What’s connected (dock model), direct-to-laptop test results.
		
- [ ] Is the device connected to the network? (LAN/Wi-Fi indicator)
	- **Purpose:** Confirm connectivity isn’t the root cause of “can’t access” symptoms.
	- **Capture:** Connection type, SSID/port, VPN status.
		
- [ ] Any recent hardware changes (RAM/SSD/docking station)?
	- **Purpose:** Identify unsupported modifications or new faulty components.
	- **Capture:** What changed + when, vendor/model, who performed change.
		
- [ ] Is BIOS/firmware up to date? (only if symptom matches known issue)
	- **Purpose:** Address firmware-related instability when relevant (avoid unnecessary risk).
	- **Capture:** BIOS/firmware version, applicable KB/known issue reference.
		
- [ ] Does the issue persist after reboot?
	- **Purpose:** Confirm it’s reproducible and not a transient state.
	- **Capture:** Reboot time + whether symptoms changed.
		
- [ ] Is the device overheating or making unusual noises?
	- **Purpose:** Identify urgent hardware risk and prioritize On-Site handling.
	- **Capture:** Symptoms (heat/noise/smell), when it happens, any shutdowns.
		
- [ ] If VDI/CloudPC: can the user access the portal and is the session stable?
	- **Purpose:** Separate endpoint connectivity from VDI service/performance.
	- **Capture:** VDI platform, error code, latency symptoms, portal URL, screenshot.
		

> **GSD escalation:** Suspected hardware failure (no power/boot errors/physical damage/repeat BSOD) → Engage **On-Site Support**.


#### 5.1.2 Escalation Matrix

Escalate to **On-Site Support** when any are true:

- No power / intermittent power
- Boot errors (BitLocker prompt, no boot device, repeated BSOD)
- Physical damage / overheating / unusual noises
- External monitor not detected after known-good tests
- Accessory fails on multiple devices and needs replacement

> **Capture:** Photos/screens, asset tag, tests performed, pass/fail outcomes.

  
---

### 5.2 External monitor

#### 5.2.1 Procedure

- [ ] Monitor powered on; LED lit; power cable firmly connected

  - **Purpose:** Confirm basic power state and eliminate outlet/cable issues.
  - **Capture:** Monitor model, power LED state, outlet tested.

- [ ] Correct input source selected (HDMI/DP/USB-C/VGA)

  - **Purpose:** Ensure monitor is listening on the right input.
  - **Capture:** Selected input + cable type.

- [ ] Reseat/replace video cable; try alternate laptop/dock port

  - **Purpose:** Isolate cable vs port vs dock.
  - **Capture:** What combinations were tested and results.

- [ ] If using a dock: power-cycle and reseat connections

  - **Purpose:** Reset dock state and eliminate dock handshake failures.
  - **Capture:** Dock model, direct-to-laptop test result.

- [ ] Windows: **Settings → System → Display → Multiple displays → Detect**

  - **Purpose:** Confirm OS detection and display enumeration.
  - **Capture:** Screenshot of Display settings, whether monitor appears.

- [ ] **Win + P** projection mode; test 60 Hz resolution

  - **Purpose:** Fix projection mode misconfig and unsupported refresh settings.
  - **Capture:** Working mode/resolution/refresh.

- [ ] Test with another monitor/device; inspect ports for damage

  - **Purpose:** Determine whether the monitor, cable, dock, or laptop is faulty.
  - **Capture:** Cross-test results, photos of damage (if any).

#### 5.2.2 Escalation Matrix

| Issue   | Level 1 | Level 2 | Level 3 |
| ------- | ------- | ------- | ------- |
| Issue01 |         |         |         |
| Issue02 |         |         |         |
| Issue03 |         |         |         |


> **Escalation:** Not detected with **known-good** cable/port/monitor tests → Engage **On-Site Support**.


---

### 5.3 Accessories

#### 5.3.1 General

##### 5.3.1.1 Procedure

- [ ] Identify accessory type: keyboard / mouse / headset / webcam / speakerphone

  - **Purpose:** Choose correct troubleshooting path and replacement policy.
  - **Capture:** Type, make/model, connection type, serial (if available).

- [ ] Connection: USB-A / USB-C / Bluetooth / 3.5 mm

  - **Purpose:** Identify driver/pairing vs physical connection issues.
  - **Capture:** Connection method, dongle present (yes/no).

- [ ] Approved model? Record make & model

  - **Purpose:** Confirm it’s supported and eligible for standard support.
  - **Capture:** Model number + whether it’s catalog-approved.

- [ ] Try a different USB port / replace battery / recharge

  - **Purpose:** Eliminate simple power/port failures before escalation.
  - **Capture:** Ports tried, battery status, charging behavior.

[ ] **Cross-device test:** Test the accessory on another device to isolate.

- **Purpose:** Decide accessory replacement vs endpoint troubleshooting.
- **Capture:** Cross-test results (works elsewhere / fails elsewhere).

##### 5.3.1.2 Escalation Matrix

| Issue   | Level 1   | Level 2 | Level 3 |
| ------- | --------- | ------- | ------- |
| Issue01 | GSD & OSS | -nil-   | -nil-   |

#### 5.3.2 Headset (general)

##### 5.3.2.1 Procedure

- [ ] Manufacturer & model; dongle required?

  - **Purpose:** Verify correct hardware path (many enterprise headsets require dongles).
  - **Capture:** Model, connection method, dongle ID (if any).

- [ ] Powered on and charged? Charging LED visible?

  - **Purpose:** Rule out power/charge as root cause.
  - **Capture:** Charge level/LED behavior, cable used.

- [ ] Connection path: USB dongle direct / Bluetooth re-pair / 3.5 mm fully seated

  - **Purpose:** Standardize testing to one clean connection method.
  - **Capture:** Method used + re-pair outcome.

- [ ] Select correct output/input in Sound settings

  - **Purpose:** Confirm audio routing is correct at OS level.
  - **Capture:** Screenshot of Sound settings showing selected devices.

- [ ] Select headset in Teams/Zoom; run a test call

  - **Purpose:** Validate in-app device selection and confirm end-to-end function.
  - **Capture:** Test call outcome, selected devices in app.

- [ ] Check physical/in-line mute controls

  - **Purpose:** Rule out hardware mute/boom position.
  - **Capture:** Mute state indicator behavior.

- [ ] Update headset firmware and audio drivers (per approved method)

  - **Purpose:** Address known firmware/driver issues after basic isolation.
  - **Capture:** Firmware/driver versions before/after, update method used.

##### 5.3.2.2 Escalation

| Issue   | Level 1   | Level 2 | Level 3 |
| ------- | --------- | ------- | ------- |
| Issue01 | GSD & OSS | -nil-   | -nil-   |

### 5.3.3 Headset Specifics (Audio/Microphone)

- [ ] **Verify output/input in Sound settings:**
    
    - **Purpose:** Confirm audio routing is correct at OS level.
    - **Capture:** Screenshot of Sound settings showing selected devices.
        
- [ ] **Run Teams test call:**
    
    - **Purpose:** Validate in-app device selection and confirm end-to-end function.
    - **Capture:** Test call outcome, selected devices in app.
        
- [ ] **Check Privacy settings (Microphone):**
    
    - **Purpose:** Rule out OS privacy blocks.
    - **Capture:** Confirmation of "Allow access" toggles.
        

---
---

## 6) Connectivity / Network

> [!IMPORTANT] VPN (AoVPN) has been replaced by Netskope & ZTNA

### 6.1 Procedure

- [ ] Location: office site or home; Wi-Fi or LAN (SSID/port)

  - **Purpose:** Identify network domain/path and common local issues.
  - **Capture:** SSID / wired port / dock used, site/floor (office), ISP (home if relevant).

- [ ] ~~VPN required for the resource? Connected and authenticated?~~

  - ~~**Purpose:** Confirm internal resource access requirements and VPN health.~~
  - ~~**Capture:** VPN client name, status, error code, split/full tunnel (if known).~~

- [ ] Scope: one user vs group vs entire site

  - **Purpose:** Determine incident severity and escalation path.
  - **Capture:** Affected users/locations, start time, affected apps/services.

- [ ] Internal/external access checks; note error codes

  - **Purpose:** Separate general internet outage from internal routing/DNS issues.
  - **Capture:** What sites work/fail + exact error.

- [ ] Windows: `ipconfig /all` — valid IP/gateway/DNS?

  - **Purpose:** Validate DHCP/DNS configuration (frequent root cause).
  - **Capture:** IP, gateway, DNS servers (paste/redact as needed).

- [ ] Wi-Fi: signal ≥ 3 bars; forget & re-join SSID; toggle adapter

  - **Purpose:** Fix common Wi-Fi auth/roaming issues and confirm signal quality.
  - **Capture:** SSID, signal strength, reconnect outcome.

- [ ] LAN: reseat/replace cable; bypass dock; try another port

  - **Purpose:** Isolate cable/dock/port failure.
  - **Capture:** Direct-to-laptop results and cable/port used.

- [ ] Tests: ping gateway, 1.1.1.1, then FQDN (www.microsoft.com)

  - **Purpose:** Layered diagnosis: local network → internet routing → DNS.
  - **Capture:** Which step fails + output/error.

- [ ] Flush DNS & renew lease; power-cycle home router (when applicable)

  - **Purpose:** Recover from stale DNS/DHCP and consumer router issues.
  - **Capture:** Commands/actions taken and outcome.

- [ ] Check NAC/Intune compliance blocks

  - **Purpose:** Confirm access isn’t blocked by compliance/NAC policy.
  - **Capture:** Compliance/NAC status + reason/policy.

### 6.2 Escalation Matrix

| Issue   | Level 1   | Level 2 | Level 3 |
| ------- | --------- | ------- | ------- |
| Issue01 | GSD & OSS | -nil-   | -nil-   |


> **Escalation:** Refer to **“Connectivity Index KB for ServiceDesk”** and include: ipconfig + ping results + VPN status + error screenshots.

---
---

## Appendix - Common Issues
### A1 No audio (can’t hear)
#### A1.1 Description
Unable to hear any audio from Headset
#### A1.2 Procedure

- [ ] System/app volume not muted; check Volume Mixer

  - **Purpose:** Eliminate simple volume routing/mute.
  - **Capture:** Mixer screenshot if unusual.

- [ ] Correct playback device selected (headset vs speakers)

  - **Purpose:** Confirm output device selection.
  - **Capture:** Selected playback device.

- [ ] Toggle headset profiles (Headset vs Headphones) and retest

  - **Purpose:** Identify profile mismatch (especially Bluetooth).
  - **Capture:** Profile used and outcome.

- [ ] Test another app; disconnect other audio devices

  - **Purpose:** Determine app-specific vs system-wide issue.
  - **Capture:** Which apps tested, results.

- [ ] For Bluetooth: consider disabling Hands-Free Telephony for music; prefer A2DP

  - **Purpose:** Fix common Bluetooth profile behavior differences.
  - **Capture:** Setting changed and outcome.

- [ ] Restart Windows Audio service or reboot

  - **Purpose:** Recover from hung audio stack/driver state.
  - **Capture:** Action taken and result.

### A2 Headset - No microphone (others can’t hear)

#### A2.1 Description
Using Headset with MS-Teams, others cannot hear user speaking even after confirming user is unmuted
#### A2.2 Procedure

- [ ] Correct input device selected; input level meter moves

  - **Purpose:** Prove mic signal is present at OS level.
  - **Capture:** Input device + meter behavior.

- [ ] Privacy & security → Microphone: allow access

  - **Purpose:** Rule out OS privacy blocks.
  - **Capture:** Screenshot or confirmation of toggles.

- [ ] Verify mute state in OS/app/headset

  - **Purpose:** Rule out software or hardware mute.
  - **Capture:** Mute indicator status.

- [ ] Teams: Devices → Make a test call

  - **Purpose:** Validate mic path inside the primary comms app.
  - **Capture:** Test call result + device selection screenshot.

- [ ] For dongles: ensure recording device is enabled and correct profile is used

  - **Purpose:** Fix common dongle/profile selection issues.
  - **Capture:** Device Manager / Sound device list screenshot.

- [ ] Reinstall/refresh audio driver; re-pair/replug device

  - **Purpose:** Reset driver/device stack if corruption suspected.
  - **Capture:** Actions taken, outcome.

- [ ] Test built-in mic to isolate

  - **Purpose:** Confirm whether issue is headset-specific or endpoint-wide.
  - **Capture:** Built-in mic test result.


> **Escalation:** Not detected after above → Engage **Endpoint Engineering** with screenshots (Sound settings + app device settings + Device Manager).

