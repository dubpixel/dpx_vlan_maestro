<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!--  *** Thanks for checking out the Best-README-Template. If you have a suggestion that would make this better, please fork the repo and create a pull request or simply open an issue with the tag "enhancement". Don't forget to give the project a star! Thanks again! Now go create something AMAZING! :D -->



<!-- /// d   u   b   p   i   x   e   l  ---  f   o   r   k   ////--v0.5.7 -->
<!--this has additionally been modifed by @dubpixel for hardware use -->
<!--search dpx_vlan_maestro.. search & replace is COMMAND OPTION F -->

<!--this is the version for software -->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
***
-->
<div align="center">

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
[![Latest Release](https://img.shields.io/github/v/release/dubpixel/dpx_vlan_maestro?label=dpx_vlan_maestro&color=blue&style=flat-square)](https://github.com/dubpixel/dpx_vlan_maestro/releases/latest)
</div>
<div align="center">
<a href="https://github.com/dubpixel/dpx_vlan_maestro"><img src="images/logo.png" alt="dpx logo" height="80"></a>
<h1 align="center">dpx_vlan_maestro</h1>
<h3 align="center"><i>Hyper-V Network Configuration Automation</i></h3>
  <p align="center">
    PowerShell script that creates virtual switches and VLAN-tagged network adapters for different facility configurations
    <br />
     »  
     <a href="https://github.com/dubpixel/dpx_vlan_maestro"><strong>Project Here!</strong></a>
     »  
     <br />
    <a href="https://github.com/dubpixel/dpx_vlan_maestro/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/dubpixel/dpx_vlan_maestro/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
    </p>
</div>
   <br />
<!-- TABLE OF CONTENTS -->
<details>
  <summary><h3>Table of Contents</h3></summary>
<ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>    
    <li><a href="#reflection">Reflection</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
</ol>
</details>
<!-- ABOUT THE PROJECT -->
<details>
<summary><h3>About The Project</h3></summary>
DPX_VLAN_MAESTRO is a comprehensive PowerShell automation script for Windows Hyper-V environments. It simplifies the complex process of setting up virtual network infrastructure by creating virtual switches, VLAN-tagged network adapters, and assigning static IP addresses according to facility-specific configurations.

The script supports multiple facility types (4Wall, Dapper, Desert, HIVE, and custom configurations) with dynamic VLAN set loading from external JSON files. It includes robust validation, safety features, and multiple operation modes to handle different network management scenarios.

**Key Capabilities:**
- **Dynamic Configuration**: Load VLAN sets from external JSON files without code changes
- **Subnet-Aware Validation**: Comprehensive IP validation against subnet constraints
- **Multiple Modes**: Normal setup, IP-only updates, and complete cleanup (nuke all)
- **Safety Features**: Deep cleanup, adapter reset, and explicit confirmations
- **Configuration Summary**: Detailed output showing all network settings

*author(s): // www.dubpixel.tv  - i@dubpixel.tv* 
</details>

## Features

### 🔧 **Dynamic VLAN Configuration**
- Load facility-specific VLAN sets from external JSON files
- Support for multiple facility types (4Wall, Dapper, Desert, HIVE, custom)
- No code changes required to add new configurations

### 🛡️ **Advanced IP Management**
- Subnet-aware IP validation with network/broadcast address checking
- Dynamic IP prompting based on configuration templates
- Default value support for common octets
- Comprehensive validation with detailed error messages
- **DHCP or Static IP configuration choice**

### ⚙️ **Multiple Operation Modes**
- **Normal Mode**: Complete setup (switch + adapters + IPs)
- **IP Only Mode**: Update IP addresses on existing adapters
- **Nuke All Mode**: Complete cleanup of all virtual switches

### 🔍 **Safety & Validation**
- Deep cleanup of existing configurations
- Adapter binding reset and verification
- Explicit confirmation for destructive operations
- Comprehensive error handling and retry logic

### 📊 **Configuration Summary**
- Detailed output showing all network settings
- VLAN assignments with IP addresses and broadcast ranges
- Selected NIC and subnet information

### 🏗️ **Built With**
 
 * PowerShell 5.1+
 * Windows Hyper-V
 * GitHub Copilot (AI-assisted development)

<!--
 * [![KiCad][KiCad.org]][KiCad-url]
 * [![Fusion360][Fusion-360]][Autodesk-url]
 * [![FastLed][FastLed.io]][FastLed-url]
 * [![Fusion360][Fusion-360]][Autodesk-url]
 * [![Next][Next.js]][Next-url]
 * [![React][React.js]][React-url]
 * [![Vue][Vue.js]][Vue-url]
 * [![Angular][Angular.io]][Angular-url]
 * [![Svelte][Svelte.dev]][Svelte-url]
 * [![Laravel][Laravel.com]][Laravel-url]
 * [![Bootstrap][Bootstrap.com]][Bootstrap-url]
 * [![JQuery][JQuery.com]][JQuery-url]
 
-->
<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- GETTING STARTED -->

## Getting Started

  ### Prerequisites
  
  #### System Requirements
  * **Operating System**: Windows 10/11 Pro, Enterprise, or Education (Home edition does not support Hyper-V)
  * **PowerShell**: Version 5.1 or higher (included with Windows)
  * **Hardware**: At least one physical network adapter
  * **Permissions**: Administrative privileges required
  
  #### Hyper-V Setup
  
  1. **Enable Hyper-V Feature**
     - Open Control Panel → Programs → Turn Windows features on or off
     - Check "Hyper-V" and "Hyper-V Management Tools"
     - Restart computer when prompted
     
  2. **Verify Hyper-V Installation**
     ```powershell
     # Run in PowerShell as Administrator
     Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
     ```
     
  3. **Check Hyper-V Services**
     ```powershell
     # Verify Hyper-V services are running
     Get-Service -Name vmms, vmicvss, vmicguestinterface, vmicheartbeat
     ```

  ### Installation

  1. Clone the repository
     ```bash
     git clone https://github.com/dubpixel/dpx_vlan_maestro.git
     ```
  2. Navigate to the PowerShell script directory
     ```bash
     cd dpx_vlan_maestro/src
     ```
  3. Ensure you have administrative privileges
  4. Run PowerShell as Administrator

## Running the Script

There are three ways to run the script. **Method 1 is recommended** as it handles PowerShell execution policies automatically.

### Method 1: Using the Batch File (Recommended)
The easiest way to run the script:

1. Navigate to the `src` folder
2. Right-click on `vlan_maestro.bat`
3. Select **"Run as Administrator"**

The batch file automatically bypasses PowerShell execution policy restrictions.

### Method 2: PowerShell with Bypass
If you prefer running PowerShell directly:

```powershell
# Open PowerShell as Administrator, then:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\vlan_maestro.ps1
```

This temporarily bypasses execution policy for the current session only.

### Method 3: One-Line Execution
Run directly from any command prompt (as Administrator):

```powershell
powershell -ExecutionPolicy Bypass -File ".\vlan_maestro.ps1"
```

### Execution Policy Notes
- Windows restricts PowerShell script execution by default for security
- The `-ExecutionPolicy Bypass` flag allows the script to run without changing system-wide settings
- Administrative privileges are required for Hyper-V operations
- The batch file handles this automatically

## Testing

Before running the tool against a real Hyper-V host, you can catch obvious
regressions locally — no admin rights or Hyper-V required, since these are
static/data checks only (they never call `New-VMSwitch` or touch networking):

```powershell
# From the repo root, in PowerShell:

# 1. Syntax check
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile("src/vlan_maestro.ps1", [ref]$null, [ref]$errors)
$errors

# 2. Lint (install once: Install-Module PSScriptAnalyzer -Scope CurrentUser)
Invoke-ScriptAnalyzer -Path src -Recurse

# 3. Config/regression tests — checks vlan_sets.json structure and that the
#    in-script hardcoded fallback hasn't drifted from vlan_sets.json
#    (install/upgrade once: Install-Module Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.0.0
#    — Windows PowerShell 5.1's bundled Pester 3.4 is too old for this test file)
Invoke-Pester -Path test
```

The same three checks run automatically in GitHub Actions CI (`.github/workflows/ci.yml`)
on every push/PR. **CI cannot test actual Hyper-V behavior** — GitHub-hosted
runners don't support nested virtualization, so `New-VMSwitch`/`Add-VMNetworkAdapter`/etc.
are never exercised there. Only a real Windows host with Hyper-V enabled (or a
self-hosted runner on one) can verify that part.

## Configuration

<details>
<summary><strong>⚙️ Click to expand configuration guide</strong></summary>

### VLAN Sets Configuration

VLAN configurations are stored in `src/vlan_sets.json`. The script automatically loads all facility configurations from this file.

#### Adding a New Facility

```json
{
  "vlanSets": {
    "YourFacilityName": {
      "vlans": [
        {"Name": "Server_VLAN", "VlanId": 100},
        {"Name": "Client_VLAN", "VlanId": 200},
        {"Name": "Management", "VlanId": 999}
      ],
      "ipBase": "10.{vlan}.{third}.{fourth}",
      "ipPrompts": ["third", "fourth"],
      "ipDefaults": {"third": 10},
      "subnet": "255.255.255.0"
    }
  }
}
```

#### Subnet Notation Examples

The script supports both dotted decimal and CIDR notation for subnet masks:

```json
// Dotted decimal notation
"subnet": "255.252.0.0"    // /14 subnet

// CIDR notation  
"subnet": "/14"            // Equivalent to 255.252.0.0

// Other common examples
"subnet": "255.255.255.0"  // /24 (Class C)
"subnet": "255.255.252.0"  // /22 
"subnet": "255.254.0.0"    // /15
```

#### Configuration Parameters

- **`vlans`**: Array of VLAN objects with `Name` and `VlanId` properties
- **`ipBase`**: IP address template using placeholders:
  - `{vlan}` - Replaced with the VLAN ID
  - `{third}` - Third octet (user prompted)
  - `{fourth}` - Fourth octet (user prompted)
- **`ipPrompts`**: Array of octets the user will be prompted to enter
- **`ipDefaults`**: Optional default values for prompted octets
- **`subnet`**: Subnet mask - supports both formats:
  - Dotted decimal: `"255.252.0.0"` (recommended)
  - CIDR notation: `"/14"` (automatically converted)

#### IP Configuration Examples

| Facility | IP Template | Result (vlan=100, third=5, fourth=10) |
|----------|-------------|--------------------------------------|
| Standard | `10.{vlan}.{third}.{fourth}` | `10.100.5.10` |
| Desert | `192.168.{vlan}.{fourth}` | `192.168.100.10` |
| Custom | `172.16.{third}.{vlan}` | `172.16.5.100` |

</details>

<!-- USAGE EXAMPLES -->
## Usage

### Prerequisites
- Windows 10/11 with Hyper-V enabled
- PowerShell with administrative privileges
- Network adapter(s) available for virtual switch creation

### Script Features

#### Subnet-Aware IP Validation
The script validates all IP addresses against subnet constraints:
- Checks for network and broadcast address conflicts
- Displays detailed validation results
- Shows network and broadcast ranges for each IP
- Prevents invalid configurations before applying changes

#### Configuration Summary
At completion, the script displays:
- Selected network adapter
- Subnet mask information
- All VLAN assignments with IP addresses
- Broadcast address ranges

#### Safety Features
- Comprehensive warnings about network disruption
- Deep cleanup of existing configurations
- Adapter binding reset and verification
- Explicit confirmation for destructive operations

### Script Workflow

1. **Select VLAN Set**
   - Script automatically loads all available VLAN sets from `vlan_sets.json`
   - Choose from any configured facility (4Wall, Dapper, Desert, HIVE, or custom sets)
   - Each set contains predefined VLAN configurations

2. **Select Mode**
   - **Normal Mode**: Creates virtual switch, adapters, and assigns IPs
   - **IP Only Mode**: Skips creation, only assigns IP addresses to existing adapters
   - **Nuke All Mode**: Removes all virtual switches except default/built-in ones (with confirmation)

3. **Normal Mode Steps**
   - Select physical network adapter from list
   - Enter virtual switch name (defaults to "vLanSwitch")
   - Script creates virtual switch and VLAN adapters with delays

5. **IP Configuration**
   - Script prompts for IP method: **DHCP** (automatic) or **Static IP** (manual octet entry)
   - For Static IP: Script prompts for required IP octets based on VLAN set configuration
   - For DHCP: All virtual adapters are configured for automatic IP assignment
   - Defaults are shown if defined in `vlan_sets.json`
   - IP addresses are built from the `ipBase` template (e.g., `10.{vlan}.{third}.{fourth}`)
   - Common patterns:
     - Standard: `10.<vlan_id>.<3rd_octet>.<4th_octet>`
     - Desert: `192.168.<vlan_id>.<4th_octet>`
     - Custom: Any combination defined in JSON

5. **Nuke All Mode**
   - Removes all user-created virtual switches and their VLAN adapters
   - Preserves default/built-in switches (like "Default Switch")
   - Requires explicit confirmation by typing "YES"

6. **Completion**
   - Script assigns static IPs to all virtual adapters (in Normal/IP-only modes)
   - Displays progress and completion status



<details>
<summary><strong>📋 Click to expand usage examples</strong></summary>

#### **Scenario 1: Complete Setup (Normal Mode)**
Setting up a new Hyper-V host with Dapper VLAN configuration:

```powershell
PS C:\DPX_VLAN_MAESTRO\src> .\vlan_maestro.ps1

# ASCII art title and warning messages display...

Available VLAN sets:
1. 4Wall (7 VLANs)
2. Dapper (10 VLANs)
3. Desert (13 VLANs)
4. HIVE (17 VLANs)
5. ExampleFacility (3 VLANs)
Enter choice (1-5): 2
Using Dapper VLAN set (10 VLANs).

Select mode:
1. Normal (create switch and adapters, then IP)
2. IP only (skip creation, only assign IPs)
3. Nuke all (remove all virtual switches except default)
Enter choice (1, 2, or 3, press Enter for Normal): 1

Listing available network adapters:
1. Ethernet - Intel(R) I350 Gigabit Network Connection
2. Ethernet 2 - Realtek PCIe GbE Family Controller
Select the NIC by number (1-2): 1
Selected NIC: Ethernet

Enter virtual switch name (press Enter for default: vLanSwitch):
Using switch name: vLanSwitch

Checking for existing virtual switches bound to 'Ethernet'...
Creating virtual switch 'vLanSwitch'...
Adding virtual adapter '10_Server_A'...
Setting VLAN ID 10 for '10_Server_A'...
# ... continues for all VLANs ...

Enter the third octet for IP addresses (press Enter for default: 13): 20
Enter the fourth octet for IP addresses: 100

Setting IP 192.168.101.100 for '101_Server_A'...
✓ Successfully set IP 192.168.101.100 for '101_Server_A'
# ... continues for all adapters ...

Script completed.
```

**Result:** All Desert VLANs configured with static IPs like `192.168.101.100`, `192.168.102.100`, etc.

---

#### **Scenario 1.5: DHCP Configuration**
Using DHCP for automatic IP assignment instead of static IPs:

```powershell
PS C:\DPX_VLAN_MAESTRO\src> .\vlan_maestro.ps1

# ... VLAN set and mode selection ...

IP Configuration Method:
1. Static IP (configure custom IP addresses)
2. DHCP (use automatic IP assignment)

Choose IP method (1 for Static, 2 for DHCP, press Enter for Static): 2
Using DHCP for IP configuration.

Setting DHCP for '101_Server_A'...
Enabling DHCP for '101_Server_A'...
✓ Successfully enabled DHCP for '101_Server_A'
# ... continues for all adapters ...

Script completed.
```

**Result:** All VLAN adapters configured for DHCP - network will assign IPs automatically.

---

#### **Scenario 2: IP Address Update Only**
Changing IP addresses on existing VLAN adapters without recreating them:

```powershell
PS C:\DPX_VLAN_MAESTRO\src> .\vlan_maestro.ps1

Available VLAN sets:
1. 4Wall (7 VLANs)
2. Dapper (10 VLANs)
3. Desert (13 VLANs)
4. HIVE (17 VLANs)
Enter choice (1-5): 3
Using Desert VLAN set (13 VLANs).

Select mode:
1. Normal (create switch and adapters, then IP)
2. IP only (skip creation, only assign IPs)
3. Nuke all (remove all virtual switches except default)
Enter choice (1, 2, or 3, press Enter for Normal): 2

Enter the fourth octet for IP addresses: 50

Setting IP 192.168.101.50 for '101_Server_A'...
✓ Successfully set IP 192.168.101.50 for '101_Server_A'
# ... continues for all adapters ...

Script completed.
```

**Result:** IPs updated to `192.168.101.50`, `192.168.102.50`, etc. without recreating switches.

---

#### **Scenario 3: Complete Cleanup (Nuke All)**
Removing all virtual switches before decommissioning or rebuilding:

```powershell
PS C:\DPX_VLAN_MAESTRO\src> .\vlan_maestro.ps1

Available VLAN sets:
1. 4Wall (7 VLANs)
2. Dapper (10 VLANs)
3. Desert (13 VLANs)
4. HIVE (17 VLANs)
Enter choice (1-5): 1

Select mode:
1. Normal (create switch and adapters, then IP)
2. IP only (skip creation, only assign IPs)
3. Nuke all (remove all virtual switches except default)
Enter choice (1, 2, or 3, press Enter for Normal): 3

NUKE ALL MODE: Removing all virtual switches except default switches...
WARNING: This will remove ALL user-created virtual switches and their VLAN adapters!
Are you sure you want to continue? Type 'YES' to confirm: YES

Removing switch 'vLanSwitch' and all its adapters...
Removing adapter '10_Server_A'...
# ... continues for all adapters and switches ...
Skipping default/built-in switch 'Default Switch'

Nuke all operation completed.
```

**Result:** All user-created switches removed, system returned to clean state.

---

#### **Scenario 4: Custom Facility Setup**
Using a custom VLAN set defined in `vlan_sets.json`:

```json
// Added to vlan_sets.json:
"StudioB": {
  "vlans": [
    {"Name": "15_Control", "VlanId": 15},
    {"Name": "25_Audio_Dante", "VlanId": 25},
    {"Name": "35_Video_NDI", "VlanId": 35}
  ],
  "ipBase": "10.{vlan}.5.{fourth}",
  "ipPrompts": ["fourth"],
  "ipDefaults": {},
  "subnet": "255.255.255.0"
}
```

```powershell
PS C:\DPX_VLAN_MAESTRO\src> .\vlan_maestro.ps1

Available VLAN sets:
1. 4Wall (7 VLANs)
2. Dapper (10 VLANs)
3. Desert (13 VLANs)
4. HIVE (17 VLANs)
5. ExampleFacility (3 VLANs)
6. StudioB (3 VLANs)
Enter choice (1-6): 6
Using StudioB VLAN set (3 VLANs).

# ... select mode, NIC, switch name ...

Enter the fourth octet for IP addresses: 10

Setting IP 10.15.5.10 for '15_Control'...
Setting IP 10.25.5.10 for '25_Audio_Dante'...
Setting IP 10.35.5.10 for '35_Video_NDI'...

Script completed.
```

**Result:** Custom facility configured with fixed third octet (5) as defined in JSON.

</details>

## Troubleshooting

<details>
<summary><strong>🔧 Click to expand troubleshooting guide</strong></summary>

### Common Issues and Solutions

#### **"Failed while adding virtual Ethernet switch connections"**
**Problem:** The selected network adapter is already bound to another virtual switch.
**Solution:**
1. Run the script in "Nuke All" mode first to clean up existing switches
2. Or manually remove conflicting switches using Hyper-V Manager
3. Ensure no other virtual switches are using the selected adapter

#### **"Inconsistent parameters PolicyStore PersistentStore and Dhcp Enabled"**
**Problem:** DHCP settings conflict during IP assignment.
**Solution:** The script handles this automatically, but if it persists:
1. Manually disable DHCP on the adapter first
2. Run the script in IP-only mode
3. Check that the adapter isn't in a transitional state

#### **"Adapter not found after creation"**
**Problem:** Hyper-V adapters take time to appear in the system.
**Solution:** The script includes retry logic, but if it fails:
1. Wait 30-60 seconds after switch creation
2. Check Hyper-V Manager to verify adapters were created
3. Run in IP-only mode to assign IPs to existing adapters

#### **"Permission denied" or "Access denied"**
**Problem:** Script not run with administrative privileges.
**Solution:**
1. Right-click PowerShell and select "Run as Administrator"
2. Verify you're in an elevated prompt (should show "Administrator:" in title)

#### **Hyper-V Not Available**
**Problem:** Hyper-V features not enabled or not supported.
**Solution:**
1. Verify you're using Windows 10/11 Pro/Enterprise/Education
2. Enable Hyper-V in Windows Features
3. Restart computer
4. Run: `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All`

#### **"Cannot bind to adapter"**
**Problem:** Network adapter is in use by another application or service.
**Solution:**
1. Close applications using the adapter
2. Disable VPN clients temporarily
3. Check for conflicting virtual switches
4. Use "Nuke All" mode to clean up

#### **IP Validation Errors**
**Problem:** IP addresses conflict with network or broadcast addresses.
**Solution:** The script will show detailed validation errors. Choose different IP octets that don't match:
- Network address (first usable IP in subnet)
- Broadcast address (last IP in subnet)

#### **Script Hangs or Freezes**
**Problem:** Long delays during adapter creation.
**Solution:** This is normal behavior. The script includes intentional delays to ensure proper Hyper-V operation. Wait for completion - it may take 2-3 minutes for full setup.

### Debug Mode
For additional troubleshooting, you can add debug output by modifying the script to show more verbose information about each step.

### Getting Help
If you encounter issues not covered here:
1. Check the [Issues](https://github.com/dubpixel/dpx_vlan_maestro/issues) page
2. Create a new issue with your error messages and system details
3. Include your Windows version, Hyper-V status, and script output

</details>

<!-- REFLECTION -->
## Reflection

### What We Learned
- **Deep cleanup is essential**: Removing existing VLAN configurations before creating new ones prevents conflicts and ensures clean setups
- **Hyper-V timing matters**: Network adapters need time to initialize properly - delays are crucial for reliability
- **JSON configuration is powerful**: External configuration files allow facility-specific setups without code changes
- **Validation prevents disasters**: Subnet-aware IP checking catches configuration errors before they cause network issues
- **Safety features build trust**: Comprehensive warnings and confirmations prevent accidental network disruption

### What We Like
- **Dynamic configuration loading**: No code changes needed for new facilities
- **Comprehensive validation**: Prevents invalid network configurations
- **Multiple operation modes**: Normal, IP-only, and nuke-all cover all use cases
- **Detailed progress feedback**: Users know exactly what's happening
- **Configuration summary**: Clear overview of all network settings

### What We Could Do Differently
- **GUI interface**: Python/Tkinter wrapper to avoid PowerShell execution issues
- **Configuration validation**: Pre-flight checks on JSON configuration files
- **Backup/restore**: Save existing configurations before making changes
- **Network testing**: Automated connectivity verification after setup
- **Logging**: Comprehensive logging for troubleshooting and auditing

### Current Version
**v1.94** - Latest stable release with DHCP/Static IP choice and subnet-aware validation features.

<!-- ROADMAP -->
## Roadmap

### ✅ **Completed Features**
- [x] Virtual switch and VLAN adapter creation with delays
- [x] Static IP assignment with validation
- [x] External JSON configuration loading
- [x] Deep cleanup of existing configurations
- [x] Nuke All mode with safety confirmations
- [x] Subnet-aware IP validation
- [x] Configuration summary output
- [x] Dynamic IP prompting with defaults
- [x] Multiple facility support (4Wall, Dapper, Desert, HIVE, custom)
- [x] DHCP vs Static IP configuration choice

### 🔄 **In Progress**
- [ ] Python/Tkinter GUI wrapper for PowerShell execution
- [ ] Configuration file validation
- [ ] Automated network connectivity testing


### 📋 **Planned Features**
- [ ] Export Powershell script for re-use later w/o utility
- [ ] Backup/restore functionality for network configurations
- [ ] Comprehensive logging and audit trails
- [ ] Dry-run mode for testing configurations
- [ ] Network performance monitoring
- [ ] Integration with network management tools

See the [open issues](https://github.com/dubpixel/dpx_vlan_maestro/issues) for a full list of proposed features (and known issues).



See the [open issues](https://github.com/dubpixel/dpx_vlan_maestro/issues) for a full list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## Contributing

_Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**._

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Top contributors:
<a href="https://github.com/dubpixel/dpx_vlan_maestro/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=dubpixel/dpx_vlan_maestro" alt="contrib.rocks image" />
</a>

<!-- LICENSE -->
## License

  Distributed under the UNLICENSE License. See `LICENSE.txt` for more information.
<!-- CONTACT -->
## Contact

  ### Joshua Fleitell - i@dubpixel.tv

  Project Link: [https://github.com/dubpixel/dpx_vlan_maestro](https://github.com/dubpixel/dpx_vlan_maestro)

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

- **Everyone on the Coachella Screens Team that helped & contributed to the original notion document & scripts (tim sean & ben)

<!--
  * [ ]() - the best !
-->

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/dubpixel/dpx_vlan_maestro.svg?style=flat-square
[contributors-url]: https://github.com/dubpixel/dpx_vlan_maestro/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/dubpixel/dpx_vlan_maestro.svg?style=flat-square
[forks-url]: https://github.com/dubpixel/dpx_vlan_maestro/network/members
[stars-shield]: https://img.shields.io/github/stars/dubpixel/dpx_vlan_maestro.svg?style=flat-square
[stars-url]: https://github.com/dubpixel/dpx_vlan_maestro/stargazers
[issues-shield]: https://img.shields.io/github/issues/dubpixel/dpx_vlan_maestro.svg?style=flat-square
[issues-url]: https://github.com/dubpixel/dpx_vlan_maestro/issues
[license-shield]: https://img.shields.io/github/license/dubpixel/dpx_vlan_maestro.svg?style=flat-square
[license-url]: https://github.com/dubpixel/dpx_vlan_maestro/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/jfleitell
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
[KiCad.org]: https://img.shields.io/badge/KiCad-v8.0.6-blue
[KiCad-url]: https://kicad.org 
[Fusion-360]: https://img.shields.io/badge/Fusion360-v4.2.0-green
[Autodesk-url]: https://autodesk.com 
[FastLed.io]: https://img.shields.io/badge/FastLED-v3.9.9-red
[FastLed-url]: https://fastled.io 
