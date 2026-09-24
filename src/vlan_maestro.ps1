###############################################################################
# ================================================================================
# POWERSHELL - VLAN MAESTRO OPERATING DIRECTIVES
# ================================================================================
#
# This project includes AI-generated code assistance provided by GitHub Copilot.
#
# GitHub Copilot is an AI programming assistant that helps developers write code
# more efficiently by providing suggestions and completing code patterns.
#
# Ground Rules for AI Assistance:
# - No modifications to working code without explicit request
# - Comprehensive commenting of all code and preservation of existing comments
# - Small, incremental changes to maintain code stability
# - Verification before implementation of any suggestions
# - Stay focused on the current task - do not jump ahead or suggest next steps
# - Answer only what is asked - do not anticipate or propose additional work
# - ALL user prompts and AI solutions must be documented verbatim in the change log
#   Format: User prompt as single line, followed by itemized solution with → bullet
# - INCREMENT VERSION by 0.01 for ANY code changes (e.g., 1.8 → 1.81)
#
# File Header Standard and CHANGE LOG (below):
# - Use consistent separator lines (80 characters of =)
# - Include AI assistance rules in every file header
# - Maintain change log with verbatim user prompt and solution
#
# ================================================================================
# PROJECT: DPX_VLAN_MAESTRO
# VERSION: 2.3.0
# ================================================================================
#
# [File-specific information]
# File: vlan_maestro.powershell
# Purpose: Interactive script to create a virtual switch and VLAN network adapters
#          on Windows Hyper-V host, with cleanup of existing configurations and
#          robust IP assignment with delays for proper execution.
# Dependencies: Windows PowerShell Hyper-V module, administrative privileges.
#
# TODO LIST:
# 1. COMPLETED: Test "nuke all" feature thoroughly on Hyper-V host with real network adapters
# 2. Test actual network connectivity and VLAN functionality with physical network
# 3. COMPLETED: Add input validation for IP octets and VLAN selections
# 4. COMPLETED: Consider making delay timing configurable via command line parameter
# 5. COMPLETED: Add progress indicators for long-running operations
# 6. Add logging capabilities for troubleshooting and audit trails
# 7. Add dry-run mode for testing without making actual changes
# 8. Add backup/restore functionality for existing network configurations
# 9. Consider adding GUI interface using Windows Forms or WPF - i was thining python OG
#

#

#
# ================================================================================
################################################################################
# Original commented commands for reference:
#--------------------------------------------------------------------------------
# Create a bew virtual switch named vLanSwitch bound to the physical NIC
# Replace [PHYSICALNICNAME] with the name of the physical NIC you want to bind
# New-VMSwitch -name vLanSwitch -NetAdapterName [PHYSICALNICNAME] -AllowManagementOs $true

# Add virtual network adapters to the management OS and assign them to VLANs
# These are a set of common vlans used in the 4Wall NY facility
# Add-VMNetworkAdapter -ManagementOS -Name 196_Engineering -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 196_Engineering -VlanId 196 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 200_d3Net -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 200_d3Net -VlanId 200 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 210_sACN -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 210_sACN -VlanId 210 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 214_10gMedia -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 214_10gMedia -VlanId 214 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 216_10gMedia2 -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 216_10gMedia2 -VlanId 216 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 206_LED -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 206_LED -VlanId 206 -Access -ManagementOS
################################################################################
# Interactive PowerShell script to create virtual switch and VLAN adapters

# ASCII Art Title
# Function to show countdown during delays
function Start-Countdown {
    param([int]$seconds)
    for ($i = 1; $i -le $seconds; $i++) {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 1
    }
    Write-Host ""
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           ██████╗ ██████╗ ██╗  ██╗                           ║" -ForegroundColor Cyan
Write-Host "║                           ██╔══██╗██╔══██╗╚██╗██╔╝                           ║" -ForegroundColor Cyan
Write-Host "║                           ██║  ██║██████╔╝ ╚███╔╝                            ║" -ForegroundColor Cyan
Write-Host "║                           ██║  ██║██╔═══╝  ██╔██╗                            ║" -ForegroundColor Cyan
Write-Host "║                           ██████╔╝██║     ██╔╝ ██╗                           ║" -ForegroundColor Cyan
Write-Host "║                           ╚═════╝ ╚═╝     ╚═╝  ╚═╝                           ║" -ForegroundColor Cyan
Write-Host "║                                                                              ║" -ForegroundColor Cyan
Write-Host "║                             VLAN MAESTRO v2.3.0                              ║" -ForegroundColor Yellow
Write-Host "║                      Hyper-V Network Configuration Tool                      ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Start-Countdown -seconds 2

Clear-Host

# Warning Message
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                             VLAN MAESTRO v2.3.0                              ║" -ForegroundColor Yellow
Write-Host "║                      Hyper-V Network Configuration Tool                      ║" -ForegroundColor Yellow
Write-Host "╠══════════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Red
Write-Host "║                              ⚠️  WARNING ⚠️                                    ║" -ForegroundColor Red
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  This tool will MODIFY your network configuration!                           ║" -ForegroundColor Yellow
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  • Selected network interfaces will have their virtual switches REMOVED      ║" -ForegroundColor White
Write-Host "║  • All VLAN adapters on those interfaces will be DELETED                     ║" -ForegroundColor White
Write-Host "║  • New virtual switches and VLAN configurations will be CREATED              ║" -ForegroundColor White
Write-Host "║  • IP addresses will be reassigned (static, not DHCP)                        ║" -ForegroundColor White
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  This may DISCONNECT network services temporarily!                           ║" -ForegroundColor Yellow
Write-Host "║  Ensure you have console/physical access before proceeding.                  ║" -ForegroundColor Yellow
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  Press Ctrl+C at any time to cancel.                                         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator to modify Hyper-V network settings."
    Write-Host "Please restart PowerShell as Administrator (right-click PowerShell, 'Run as administrator') and try again."
    exit
}

# Prompt for delay timing
$delayInput = Read-Host "Enter delay between operations in seconds (press Enter for default: 8)"
if ([string]::IsNullOrWhiteSpace($delayInput)) {
    $delay = 8
} else {
    try {
        $delay = [int]$delayInput
        if ($delay -lt 0) {
            Write-Host "Delay cannot be negative, using default of 8 seconds." -ForegroundColor Yellow
            $delay = 8
        }
    } catch {
        Write-Host "Invalid delay value, using default of 8 seconds." -ForegroundColor Yellow
        $delay = 8
    }
}

# Warning about delay timing
if ($delay -ne 8) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                              ⚠️  WARNING ⚠️                                    ║" -ForegroundColor Red
    Write-Host "║                                                                              ║" -ForegroundColor Red
    Write-Host "║  💀 CUSTOM DELAY SETTING DETECTED - CHANGE AT YOUR OWN RISK! 💀              ║" -ForegroundColor Red
    Write-Host "║                                                                              ║" -ForegroundColor Red
    Write-Host "║  You have set delay to $delay seconds (default is 8).                            ║" -ForegroundColor Yellow
    Write-Host "║                                                                              ║" -ForegroundColor Red
    Write-Host "║  ⚠️ Setting delay too low may cause:                                          ║" -ForegroundColor Yellow
    Write-Host "║     • Hyper-V operations to fail                                             ║" -ForegroundColor White
    Write-Host "║     • Network adapter binding issues                                         ║" -ForegroundColor White
    Write-Host "║     • Incomplete VLAN configurations                                         ║" -ForegroundColor White
    Write-Host "║     • System instability                                                     ║" -ForegroundColor White
    Write-Host "║     • Besides the fact it's the WHOLE reason we wrote this..derp.            ║" -ForegroundColor White
    Write-Host "║                                                                              ║" -ForegroundColor Red
    Write-Host "║  💀 Only change if you know what you're doing! 💀                            ║" -ForegroundColor Red
    Write-Host "║                                                                              ║" -ForegroundColor Red
    Write-Host "║  Press Ctrl+C now to cancel if unsure.                                       ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to continue with custom delay, or Ctrl+C to cancel"
}

Write-Host "Using delay of $delay seconds between operations."
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Red


# Function to check whether a VLAN ID falls in the valid tag range
function Test-VlanIdInRange {
    param([int]$VlanId)
    return ($VlanId -ge 1 -and $VlanId -le 4094)
}

# Function to check whether a VLAN ID collides with one already in use
function Test-VlanIdCollision {
    param([int]$VlanId, [array]$ExistingVlanIds)
    return ($ExistingVlanIds -contains $VlanId)
}

# Function to append a new VLAN entry to a facility's saved config in
# vlan_sets.json. Returns $true on success, $false if the facility wasn't
# found or the write failed (errors are written to the error stream, not
# thrown, so callers can decide how to report them).
function Add-VlanToFacilityConfig {
    param(
        [string]$JsonPath,
        [string]$FacilityName,
        [string]$VlanName,
        [int]$VlanId
    )
    try {
        $rawJson = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $facilityNode = $rawJson.vlanSets.$FacilityName
        if (!$facilityNode) {
            Write-Warning "Facility '$FacilityName' not found in $JsonPath"
            return $false
        }
        $newVlanEntry = [PSCustomObject]@{ Name = $VlanName; VlanId = $VlanId }
        $facilityNode.vlans = @($facilityNode.vlans) + $newVlanEntry
        $rawJson | ConvertTo-Json -Depth 10 | Set-Content $JsonPath
        return $true
    } catch {
        Write-Warning "Error saving to $($JsonPath): $($_.Exception.Message)"
        return $false
    }
}

# Function to convert CIDR notation to subnet mask
function Convert-CidrToSubnetMask {
    param([int]$cidr)
    $mask = [uint32]::MaxValue -shl (32 - $cidr)
    $bytes = [BitConverter]::GetBytes([IPAddress]::NetworkToHostOrder($mask))
    return "{0}.{1}.{2}.{3}" -f $bytes[0], $bytes[1], $bytes[2], $bytes[3]
}

# Input validation functions
function Test-ModeChoice {
    param([string]$input)
    return ([string]::IsNullOrWhiteSpace($input) -or $input -eq "1" -or $input -eq "2" -or $input -eq "3" -or $input -eq "4")
}

# Function to validate IP address against subnet mask
function Test-IPAgainstSubnet {
    param([string]$ipAddress, [string]$subnetMask)
    
    try {
        # Parse IP and subnet strings into byte arrays
        $ipParts = $ipAddress -split '\.'
        $subnetParts = $subnetMask -split '\.'
        
        if ($ipParts.Length -ne 4 -or $subnetParts.Length -ne 4) {
            throw "Invalid IP or subnet format"
        }
        
        # Calculate network address (IP AND subnet for each octet)
        $networkParts = @()
        for ($i = 0; $i -lt 4; $i++) {
            $networkParts += ([int]$ipParts[$i] -band [int]$subnetParts[$i])
        }
        
        # Calculate broadcast address (network OR ~subnet for each octet)
        $broadcastParts = @()
        for ($i = 0; $i -lt 4; $i++) {
            $broadcastParts += ($networkParts[$i] -bor ([int]$subnetParts[$i] -bxor 255))
        }
        
        # Format addresses
        $networkAddress = "$($networkParts[0]).$($networkParts[1]).$($networkParts[2]).$($networkParts[3])"
        $broadcastAddress = "$($broadcastParts[0]).$($broadcastParts[1]).$($broadcastParts[2]).$($broadcastParts[3])"
        
        # Check if IP is network or broadcast address
        $isNetworkAddress = ($ipParts -join '.') -eq $networkAddress
        $isBroadcastAddress = ($ipParts -join '.') -eq $broadcastAddress
        
        return @{
            IsValid = (-not $isNetworkAddress -and -not $isBroadcastAddress)
            NetworkAddress = $networkAddress
            BroadcastAddress = $broadcastAddress
        }
    }
    catch {
        Write-Host "DEBUG: Exception in Test-IPAgainstSubnet: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            IsValid = $false
            NetworkAddress = "ERROR: $($_.Exception.Message)"
            BroadcastAddress = "ERROR"
        }
    }
}

# Define hardcoded VLAN configurations (used as fallbacks)
$hardcoded4Wall = @{
    vlans = @(
        @{Name="196_Engineering"; VlanId=196},
        @{Name="200_d3Net"; VlanId=200},
        @{Name="210_sACN"; VlanId=210},
        @{Name="214_10gMedia"; VlanId=214},
        @{Name="216_10gMedia2"; VlanId=216},
        @{Name="206_LED"; VlanId=206},
        @{Name="218_Dante"; VlanId=218}
    )
    ipBase = "10.{vlan}.{third}.{fourth}"
    ipPrompts = @("third", "fourth")
    ipDefaults = @{third=13}
    subnet = "255.254.0.0"
}
$hardcodedDapper = @{
    vlans = @(
        @{Name="10_Server_A"; VlanId=10},
        @{Name="20_Server_B"; VlanId=20},
        @{Name="30_Server_C"; VlanId=30},
        @{Name="40_Server_D"; VlanId=40},
        @{Name="50_System"; VlanId=50},
        @{Name="60_Dante_Primary"; VlanId=60},
        @{Name="65_Dante_Secondary"; VlanId=65},
        @{Name="70_KVM"; VlanId=70},
        @{Name="80_NDI"; VlanId=80},
        @{Name="90_Internet"; VlanId=90}
    )
    ipBase = "10.{vlan}.{third}.{fourth}"
    ipPrompts = @("third", "fourth")
    ipDefaults = @{third=3}
    subnet = "255.255.252.0"
}
$hardcodedDesert = @{
    vlans = @(
        @{Name="101_Server_A"; VlanId=101},
        @{Name="102_Server_B"; VlanId=102},
        @{Name="103_Server_C"; VlanId=103},
        @{Name="104_Server_D"; VlanId=104},
        @{Name="105_System"; VlanId=105},
        @{Name="106_Dante_Primary"; VlanId=106},
        @{Name="116_Dante_Secondary"; VlanId=116},
        @{Name="107_KVM"; VlanId=107},
        @{Name="108_NDI"; VlanId=108},
        @{Name="109_Internet"; VlanId=109},
        @{Name="110_Omneo"; VlanId=110},
        @{Name="111_LED"; VlanId=111},
        @{Name="112_MERGE"; VlanId=112}
    )
    ipBase = "192.168.{vlan}.{fourth}"
    ipPrompts = @("fourth")
    ipDefaults = @{}
    subnet = "255.255.255.0"
}

# Load VLAN sets from external JSON file
$vlanConfigPath = Join-Path $PSScriptRoot "vlan_sets.json"
if (Test-Path $vlanConfigPath) {
    try {
        $vlanConfig = Get-Content $vlanConfigPath -Raw | ConvertFrom-Json
        $vlans4Wall = $vlanConfig.vlanSets."4Wall"
        $vlansDapper = $vlanConfig.vlanSets.Dapper
        $vlansDesert = $vlanConfig.vlanSets.Desert
        Write-Host "Loaded VLAN configurations from $vlanConfigPath"
    }
    catch {
        Write-Host "Error loading VLAN configuration file: $($_.Exception.Message)"
        Write-Host "Falling back to built-in configurations..."
    }
} else {
    Write-Host "Warning: VLAN configuration file not found at $vlanConfigPath"
    Write-Host "Using built-in configurations..."
}

# Build dynamic VLAN set selection
$vlanSets = @{}
$vlanSetNames = @()

# Add loaded sets to the dynamic collection
if ($vlanConfig -and $vlanConfig.vlanSets) {
    foreach ($setName in $vlanConfig.vlanSets.PSObject.Properties.Name) {
        $setData = $vlanConfig.vlanSets.$setName
        $vlanSets[$setName] = @{
            vlans = $setData.vlans
            ipBase = $setData.ipBase
            ipPrompts = $setData.ipPrompts
            ipDefaults = $setData.ipDefaults
            subnet = $setData.subnet
        }
        $vlanSetNames += $setName
    }
} else {
    # Fallback to hardcoded sets
    $vlanSets["4Wall"] = $hardcoded4Wall
    $vlanSets["Dapper"] = $hardcodedDapper
    $vlanSets["Desert"] = $hardcodedDesert
    $vlanSetNames = @("4Wall", "Dapper", "Desert")
}

# Prompt for VLAN set dynamically
Write-Host "══════════════════════════════════════════════════════════════════════════════"
Write-Host "Available VLAN sets:"
for ($i = 0; $i -lt $vlanSetNames.Count; $i++) {
    $setName = $vlanSetNames[$i]
    $vlanCount = $vlanSets[$setName].vlans.Count
    Write-Host ('{0}. {1} ({2} VLANs)' -f ($i+1), $setName, $vlanCount)
}

# Validate VLAN choice input
do {
    $vlanChoice = Read-Host "Enter choice (1-$($vlanSetNames.Count)):"
    $isValidChoice = $false
    if (![string]::IsNullOrWhiteSpace($vlanChoice)) {
        try {
            $num = [int]$vlanChoice
            if ($num -ge 1 -and $num -le $vlanSetNames.Count) {
                $isValidChoice = $true
            }
        } catch {
            $isValidChoice = $false
        }
    }
    if (!$isValidChoice) {
        Write-Host "Invalid choice. Please enter a number between 1 and $($vlanSetNames.Count)." -ForegroundColor Red
    }
} while (!$isValidChoice)

$choiceIndex = [int]$vlanChoice - 1

if ($choiceIndex -ge 0 -and $choiceIndex -lt $vlanSetNames.Count) {
    $selectedVlanSet = $vlanSetNames[$choiceIndex]
    $selectedSetData = $vlanSets[$selectedVlanSet]
    $vlans = $selectedSetData.vlans
    $ipBase = $selectedSetData.ipBase
    $ipPrompts = $selectedSetData.ipPrompts
    $ipDefaults = $selectedSetData.ipDefaults
    $subnetMask = $selectedSetData.subnet

    # Convert CIDR to subnet mask if needed
    if ($subnetMask.StartsWith('/')) {
        $cidr = [int]$subnetMask.Substring(1)
        $subnetMask = Convert-CidrToSubnetMask -cidr $cidr
    }
    Write-Host ('Using {0} VLAN set ({1} VLANs).' -f $selectedVlanSet, $vlans.Count)
} else {
    Write-Host "Invalid choice, defaulting to $($vlanSetNames[0])."
    $selectedVlanSet = $vlanSetNames[0]
    $selectedSetData = $vlanSets[$selectedVlanSet]
    $vlans = $selectedSetData.vlans
    $ipBase = $selectedSetData.ipBase
    $ipPrompts = $selectedSetData.ipPrompts
    $ipDefaults = $selectedSetData.ipDefaults
    $subnetMask = $selectedSetData.subnet

    # Convert CIDR to subnet mask if needed
    if ($subnetMask.StartsWith('/')) {
        $cidr = [int]$subnetMask.Substring(1)
        $subnetMask = Convert-CidrToSubnetMask -cidr $cidr
    }
}

# No longer need special case logic - using dynamic IP configuration from JSON

# Define valid modes for maintainable mode selection
$validModes = @{
    "1" = @{ name = "Normal"; description = "Normal (create switch and adapters, then IP)"; ipOnly = $false; nukeAll = $false; addSingle = $false }
    "2" = @{ name = "IP only"; description = "IP only (skip creation, only assign IPs)"; ipOnly = $true; nukeAll = $false; addSingle = $false }
    "3" = @{ name = "Nuke all"; description = "Nuke all (remove all virtual switches except default)"; ipOnly = $false; nukeAll = $true; addSingle = $false }
    "4" = @{ name = "Add single VLAN"; description = "Add a single ad-hoc VLAN (guided prompts, no facility config needed)"; ipOnly = $false; nukeAll = $false; addSingle = $true }
}
Write-Host "═══════════════════════════════════════"
# Prompt for mode
Write-Host "Select mode:"
foreach ($key in $validModes.Keys | Sort-Object) {
    Write-Host "$key. $($validModes[$key].description)"
}

# Validate mode choice input
do {
    $modeChoice = Read-Host 'Enter choice (1, 2, 3, or 4, press Enter for Normal):'
    $isValidMode = ([string]::IsNullOrWhiteSpace($modeChoice) -or $validModes.ContainsKey($modeChoice))
    if (!$isValidMode) {
        Write-Host "Invalid choice. Please enter 1, 2, 3, 4, or press Enter for Normal." -ForegroundColor Red
    }
} while (!$isValidMode)

if ([string]::IsNullOrWhiteSpace($modeChoice)) {
    $selectedMode = $validModes["1"]  # Default to Normal
} else {
    $selectedMode = $validModes[$modeChoice]
}

$ipOnly = $selectedMode.ipOnly
$nukeAll = $selectedMode.nukeAll
$addSingle = $selectedMode.addSingle
Write-Host "══════════════════════════════════════════════════════════════════════════════"
# Handle nuke all mode
if ($nukeAll) {
    Write-Host "NUKE ALL MODE: Removing all virtual switches except default switches..."
    Write-Host "WARNING: This will remove ALL user-created virtual switches and their VLAN adapters!"

    $confirm = Read-Host "Are you sure you want to continue? Type 'YES' to confirm"
    if ($confirm -ne "YES") {
        Write-Host "Operation cancelled."
        exit
    }

    # Get unique virtual switch names (excluding default/built-in switches)
    $allSwitches = Get-VMSwitch
    $switchesToRemove = $allSwitches | Where-Object { 
        $_.Name -notlike "*Default*" -and 
        $_.Name -notlike "vEthernet*" -and 
        $_.SwitchType -ne "Internal" 
    } | Select-Object -ExpandProperty Name -Unique
    
    foreach ($switchName in $switchesToRemove) {
        Write-Host "Removing switch '$switchName' and all its adapters..."

        # Remove all VLAN adapters associated with this switch
        Write-Host "Removing all adapters bound to switch '$switchName'..."
        Get-VMNetworkAdapter -ManagementOS | Where-Object { $_.SwitchName -eq $switchName } | Remove-VMNetworkAdapter
        Start-Countdown -seconds $delay

        # Remove the switch
        Write-Host "Removing switch '$switchName'..."
        Remove-VMSwitch -Name $switchName -Force
        Start-Countdown -seconds $delay
    }

    Write-Host "Nuke all operation completed."
    exit
}

# Handle "Add a single VLAN" mode: one ad-hoc VLAN adapter on an existing
# switch, independent of any facility's saved vlan_sets.json schema.
if ($addSingle) {
    Write-Host "ADD SINGLE VLAN MODE: Adding one ad-hoc VLAN adapter to an existing switch."
    Write-Host "══════════════════════════════════════════════════════════════════════════════"

    # Step 1: adapter name
    do {
        $adhocName = Read-Host "Enter the VLAN adapter name (e.g. 220_Temp_Record)"
        $isValidName = ![string]::IsNullOrWhiteSpace($adhocName)
        if (!$isValidName) {
            Write-Host "Adapter name cannot be empty." -ForegroundColor Red
        }
    } while (!$isValidName)

    # Step 2: VLAN ID, range-checked and warned on collision with adapters
    # already configured on the management OS (any switch).
    $existingVlanTags = @()
    try {
        $existingVlanTags = Get-VMNetworkAdapterVlan -ManagementOS -ErrorAction Stop |
            Where-Object { $_.OperationMode -eq "Access" } |
            ForEach-Object { $_.AccessVlanId }
    } catch {
        Write-Host "Warning: could not query existing VLAN tags for collision check ($($_.Exception.Message))." -ForegroundColor Yellow
    }

    do {
        $vlanIdInput = Read-Host "Enter the VLAN tag/ID (1-4094)"
        $isValidVlanId = $false
        try {
            $adhocVlanId = [int]$vlanIdInput
            $isValidVlanId = Test-VlanIdInRange -VlanId $adhocVlanId
        } catch {
            $isValidVlanId = $false
        }
        if (!$isValidVlanId) {
            Write-Host "Invalid VLAN ID. Please enter a number between 1 and 4094." -ForegroundColor Red
        } elseif (Test-VlanIdCollision -VlanId $adhocVlanId -ExistingVlanIds $existingVlanTags) {
            Write-Host "⚠ Warning: VLAN ID $adhocVlanId is already in use on an existing adapter." -ForegroundColor Yellow
            $collisionConfirm = Read-Host "Continue anyway? (y/N)"
            if ($collisionConfirm -notmatch '^[Yy]') {
                $isValidVlanId = $false
            }
        }
    } while (!$isValidVlanId)

    # Step 3: target switch (must already exist — this mode doesn't create one)
    $existingSwitches = Get-VMSwitch | Select-Object -ExpandProperty Name
    if (!$existingSwitches -or $existingSwitches.Count -eq 0) {
        Write-Host "No virtual switches found. Run Normal mode first to create one." -ForegroundColor Red
        exit
    }
    Write-Host "Existing virtual switches:"
    for ($i = 0; $i -lt $existingSwitches.Count; $i++) {
        Write-Host "$($i+1). $($existingSwitches[$i])"
    }
    do {
        $switchChoice = Read-Host "Select the target switch by number (1-$($existingSwitches.Count))"
        $isValidSwitch = $false
        try {
            $num = [int]$switchChoice
            if ($num -ge 1 -and $num -le $existingSwitches.Count) {
                $isValidSwitch = $true
            }
        } catch {
            $isValidSwitch = $false
        }
        if (!$isValidSwitch) {
            Write-Host "Invalid choice. Please enter a number between 1 and $($existingSwitches.Count)." -ForegroundColor Red
        }
    } while (!$isValidSwitch)
    $adhocSwitchName = $existingSwitches[$switchChoice - 1]

    # Step 4: DHCP vs static (same choice offered in Normal/IP-only modes)
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    Write-Host "IP Configuration Method:"
    Write-Host "1. Static IP (configure a custom IP address)"
    Write-Host "2. DHCP (use automatic IP assignment)"
    do {
        $adhocIpMethod = Read-Host "Choose IP method (1 for Static, 2 for DHCP, press Enter for Static)"
        $isValidAdhocMethod = ([string]::IsNullOrWhiteSpace($adhocIpMethod) -or $adhocIpMethod -eq "1" -or $adhocIpMethod -eq "2")
        if (!$isValidAdhocMethod) {
            Write-Host "Invalid choice. Please enter 1 for Static, 2 for DHCP, or press Enter for Static." -ForegroundColor Red
        }
    } while (!$isValidAdhocMethod)
    $adhocUseDHCP = ($adhocIpMethod -eq "2")

    $adhocIp = $null
    $adhocSubnet = $null
    if (!$adhocUseDHCP) {
        # Step 5: IP address + subnet, validated with the same subnet-math
        # helper used everywhere else in the script. Defaults the subnet to
        # whichever facility was selected above, since that's the closest
        # thing to ambient context for an ad-hoc VLAN.
        do {
            $adhocIp = Read-Host "Enter the full IP address for this VLAN (e.g. 192.168.220.10)"
            $adhocSubnetInput = Read-Host "Enter the subnet mask (press Enter for default: $subnetMask)"
            $adhocSubnet = if ([string]::IsNullOrWhiteSpace($adhocSubnetInput)) { $subnetMask } else { $adhocSubnetInput }

            $adhocValidation = Test-IPAgainstSubnet -ipAddress $adhocIp -subnetMask $adhocSubnet
            $isValidAdhocIp = $adhocValidation.IsValid
            if (!$isValidAdhocIp) {
                Write-Host "Invalid IP for subnet $adhocSubnet (network: $($adhocValidation.NetworkAddress), broadcast: $($adhocValidation.BroadcastAddress)). Please re-enter." -ForegroundColor Red
            }
        } while (!$isValidAdhocIp)
    }

    # Step 6: confirmation summary before touching Hyper-V
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    Write-Host "Confirm ad-hoc VLAN configuration:" -ForegroundColor Cyan
    Write-Host "  Adapter name: $adhocName"
    Write-Host "  VLAN ID:      $adhocVlanId"
    Write-Host "  Switch:       $adhocSwitchName"
    if ($adhocUseDHCP) {
        Write-Host "  IP method:    DHCP"
    } else {
        Write-Host "  IP method:    Static ($adhocIp / $adhocSubnet)"
    }
    $applyConfirm = Read-Host "Apply this configuration? (y/N)"
    if ($applyConfirm -notmatch '^[Yy]') {
        Write-Host "Operation cancelled."
        exit
    }

    Write-Host "Adding virtual adapter '$adhocName' to switch '$adhocSwitchName'..."
    Add-VMNetworkAdapter -ManagementOS -Name $adhocName -SwitchName $adhocSwitchName
    Start-Countdown -seconds $delay
    Write-Host "Setting VLAN ID $adhocVlanId for '$adhocName'..."
    Set-VMNetworkAdapterVlan -VMNetworkAdapterName $adhocName -VlanId $adhocVlanId -Access -ManagementOS
    Start-Countdown -seconds $delay

    # Wait for the adapter to be available, same retry pattern used for the
    # facility-driven modes below.
    $maxRetries = 10
    $retryCount = 0
    $adapter = $null
    while ($retryCount -lt $maxRetries -and $adapter -eq $null) {
        $adapter = Get-NetAdapter | Where-Object { $_.Name -eq "vEthernet ($adhocName)" }
        if ($adapter -eq $null) {
            Write-Host "Waiting for adapter 'vEthernet ($adhocName)' to be available... ($($retryCount + 1)/$maxRetries)"
            Start-Sleep -Seconds 3
            $retryCount++
        }
    }

    if ($adapter) {
        if ($adhocUseDHCP) {
            try {
                Write-Host "Enabling DHCP for '$adhocName'..."
                Set-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -Dhcp Enabled
                $existingIPs = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
                if ($existingIPs) {
                    foreach ($existingIP in $existingIPs) {
                        Remove-NetIPAddress -IPAddress $existingIP.IPAddress -Confirm:$false
                    }
                }
                Write-Host "✓ Successfully enabled DHCP for '$adhocName'"
            } catch {
                Write-Host "✗ Error enabling DHCP for '$adhocName': $($_.Exception.Message)"
            }
        } else {
            try {
                Write-Host "Configuring IP $adhocIp for '$adhocName' using netsh..."
                $netshCommand = "netsh interface ip set address ""$($adapter.Name)"" static $adhocIp $adhocSubnet"
                Write-Host "Running: $netshCommand"
                $result = cmd /c $netshCommand 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ Successfully set IP $adhocIp for '$adhocName'"
                } else {
                    Write-Host "✗ Netsh failed: $result"
                    throw "Netsh IP configuration failed"
                }
            } catch {
                Write-Host "✗ Error setting IP for '$adhocName': $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "✗ Error: Adapter '$adhocName' not found after $maxRetries attempts"
    }

    # Step 7 (optional): persist this VLAN into the currently selected
    # facility's saved config in vlan_sets.json, bridging toward the
    # interactive schema-editor ticket without requiring it. Default: no.
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    if (Test-Path $vlanConfigPath) {
        $saveChoice = Read-Host "Add this VLAN to the '$selectedVlanSet' facility's saved config in vlan_sets.json too? (y/N)"
        if ($saveChoice -match '^[Yy]') {
            $saved = Add-VlanToFacilityConfig -JsonPath $vlanConfigPath -FacilityName $selectedVlanSet -VlanName $adhocName -VlanId $adhocVlanId
            if ($saved) {
                Write-Host "✓ Saved '$adhocName' (VLAN $adhocVlanId) to the '$selectedVlanSet' facility in $vlanConfigPath" -ForegroundColor Green
            } else {
                Write-Host "✗ Could not save '$adhocName' to the '$selectedVlanSet' facility in $vlanConfigPath — see error above." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No vlan_sets.json file found at $vlanConfigPath — skipping optional save-to-config step."
    }

    Write-Host "Add single VLAN operation completed."
    exit
}
Write-Host "══════════════════════════════════════════════════════════════════════════════"
if (!$ipOnly) {
    # List current NICs
    Write-Host "Listing available network adapters:"
    $adapters = Get-NetAdapter | Where-Object { $_.Name -notlike "vEthernet*" -and $_.InterfaceDescription -notlike "*Hyper-V*" } | Sort-Object Name
    for ($i = 0; $i -lt $adapters.Count; $i++) {
        $status = if ($adapters[$i].Status -eq "Up") { "Up" } else { "Down" }
        Write-Host "$($i+1). $($adapters[$i].Name) - $($adapters[$i].InterfaceDescription) [Status: $status]"
    }
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    # Validate NIC choice input
    do {
        $choice = Read-Host "Select the NIC by number (1-$($adapters.Count))"
        $isValidNic = $false
        if (![string]::IsNullOrWhiteSpace($choice)) {
            try {
                $num = [int]$choice
                if ($num -ge 1 -and $num -le $adapters.Count) {
                    $isValidNic = $true
                }
            } catch {
                $isValidNic = $false
            }
        }
        if (!$isValidNic) {
            Write-Host "Invalid choice. Please enter a number between 1 and $($adapters.Count)." -ForegroundColor Red
        }
    } while (!$isValidNic)

    $selectedNic = $adapters[$choice-1].Name
    Write-Host "Selected NIC: $selectedNic"
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    # Prompt for virtual switch name
    $switchName = Read-Host "Enter virtual switch name (press Enter for default: vLanSwitch)"
    if ([string]::IsNullOrWhiteSpace($switchName)) { $switchName = "vLanSwitch" }
    Write-Host "Using switch name: $switchName"

    # Deep cleanup: Remove ALL virtual switches bound to the selected physical NIC
    Write-Host "Checking for existing virtual switches bound to '$selectedNic'..."
    $selectedAdapter = Get-NetAdapter -Name $selectedNic
    $switchesOnNic = Get-VMSwitch | Where-Object { $_.NetAdapterInterfaceDescription -eq $selectedAdapter.InterfaceDescription }
    Write-Host "Found $($switchesOnNic.Count) switches bound to '$selectedNic'."
    foreach ($switch in $switchesOnNic) {
        Write-Host "Found existing switch '$($switch.Name)' bound to '$selectedNic'. Cleaning up..."

        # Remove all VLAN adapters associated with this switch
        Write-Host "Removing all adapters bound to switch '$($switch.Name)'..."
        Get-VMNetworkAdapter -ManagementOS | Where-Object { $_.SwitchName -eq $switch.Name } | Remove-VMNetworkAdapter
        Start-Countdown -seconds $delay

        # Remove the switch itself
        Write-Host "Removing virtual switch '$($switch.Name)'..."
        Remove-VMSwitch -Name $switch.Name -Force
        Start-Countdown -seconds $delay
    }

    # Create virtual switch
    Write-Host "Creating virtual switch '$switchName'..."
    # Reset adapter bindings by disabling and re-enabling the adapter
    Write-Host "Disabling and re-enabling adapter '$selectedNic' to reset bindings..."
    Disable-NetAdapter -Name $selectedNic -Confirm:$false
    Start-Sleep -Seconds 2
    Enable-NetAdapter -Name $selectedNic
    Start-Countdown -seconds $delay
    New-VMSwitch -Name $switchName -NetAdapterName $selectedNic -AllowManagementOS $true
    Start-Countdown -seconds $delay

    # Add virtual network adapters with delays
    foreach ($vlan in $vlans) {
        Write-Host "Adding virtual adapter '$($vlan.Name)'..."
        Add-VMNetworkAdapter -ManagementOS -Name $vlan.Name -SwitchName $switchName
        Start-Countdown -seconds $delay
        Write-Host "Setting VLAN ID $($vlan.VlanId) for '$($vlan.Name)'..."
        Set-VMNetworkAdapterVlan -VMNetworkAdapterName $vlan.Name -VlanId $vlan.VlanId -Access -ManagementOS
        Start-Countdown -seconds $delay
    }
}

# Prompt for IP configuration method (DHCP vs Static)
Write-Host "══════════════════════════════════════════════════════════════════════════════"
Write-Host "IP Configuration Method:"
Write-Host "1. Static IP (configure custom IP addresses)"
Write-Host "2. DHCP (use automatic IP assignment)"
Write-Host ""

do {
    $ipMethodChoice = Read-Host "Choose IP method (1 for Static, 2 for DHCP, press Enter for Static)"
    $isValidMethod = ([string]::IsNullOrWhiteSpace($ipMethodChoice) -or $ipMethodChoice -eq "1" -or $ipMethodChoice -eq "2")
    if (!$isValidMethod) {
        Write-Host "Invalid choice. Please enter 1 for Static, 2 for DHCP, or press Enter for Static." -ForegroundColor Red
    }
} while (!$isValidMethod)

$useDHCP = $false
if ($ipMethodChoice -eq "2") {
    $useDHCP = $true
    Write-Host "Using DHCP for IP configuration." -ForegroundColor Green
} else {
    Write-Host "Using Static IP configuration." -ForegroundColor Green
}
Write-Host "══════════════════════════════════════════════════════════════════════════════"

if (!$useDHCP) {
    # Prompt for IP octets dynamically based on VLAN set configuration
    $allIPsValid = $false
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    do {
        $ipOctets = @{}
        foreach ($promptName in $ipPrompts) {
            $defaultValue = $ipDefaults.$promptName
            if ($defaultValue) {
                $promptText = "Enter the $promptName octet for IP addresses (subnet: $subnetMask, press Enter for default: $defaultValue)"
                do {
                    $userInput = Read-Host $promptText
                    $isValidOctet = $false
                    if ([string]::IsNullOrWhiteSpace($userInput)) {
                        $isValidOctet = $true
                        $ipOctets[$promptName] = $defaultValue
                    } else {
                        try {
                            $num = [int]$userInput
                            if ($num -ge 0 -and $num -le 255) {
                                $isValidOctet = $true
                                $ipOctets[$promptName] = $userInput
                            }
                        } catch {
                            $isValidOctet = $false
                        }
                    }
                    if (!$isValidOctet) {
                        Write-Host "Invalid octet. Please enter a number between 0 and 255." -ForegroundColor Red
                    }
                } while (!$isValidOctet)
            } else {
                $promptText = "Enter the $promptName octet for IP addresses (subnet: $subnetMask)"
                do {
                    $userInput = Read-Host $promptText
                    $isValidOctet = $false
                    try {
                        $num = [int]$userInput
                        if ($num -ge 0 -and $num -le 255) {
                            $isValidOctet = $true
                            $ipOctets[$promptName] = $userInput
                        }
                    } catch {
                        $isValidOctet = $false
                    }
                    if (!$isValidOctet) {
                        Write-Host "Invalid octet. Please enter a number between 0 and 255." -ForegroundColor Red
                    }
                } while (!$isValidOctet)
            }
        }
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
        # Validate all assembled IP addresses against subnet
        Write-Host "Validating IP addresses against subnet $subnetMask..." -ForegroundColor Yellow

        $validationResults = @()
        $allIPsValid = $true

        foreach ($vlan in $vlans) {
            # Build IP address from template
            $ip = $ipBase
            $ip = $ip -replace '\{vlan\}', $vlan.VlanId
            foreach ($octetName in $ipOctets.Keys) {
                $ip = $ip -replace "`{$octetName`}", $ipOctets[$octetName]
            }
            
            # Validate IP against subnet
            $validation = Test-IPAgainstSubnet -ipAddress $ip -subnetMask $subnetMask
            
            $result = @{
                VLAN = $vlan
                IP = $ip
                IsValid = $validation.IsValid
                Network = $validation.NetworkAddress
                Broadcast = $validation.BroadcastAddress
            }
            $validationResults += $result
            
            if (!$validation.IsValid) {
                $allIPsValid = $false
            }
        }

        # Display validation results
        if (!$allIPsValid) {
            Write-Host "Invalid IP configuration for $subnetMask subnet:" -ForegroundColor Red
            Write-Host ""
            
            foreach ($result in $validationResults) {
                $status = if ($result.IsValid) { "✅" } else { "❌" }
                $message = if ($result.IsValid) { "Valid" } else { "Invalid (not in $($result.Network) network)" }
                Write-Host "$status $($result.IP) - $message"
            }
            
            Write-Host ""
            Write-Host "Please re-enter octet values." -ForegroundColor Yellow
        } else {
            Write-Host "All IP addresses are valid for $subnetMask subnet." -ForegroundColor Green
            foreach ($result in $validationResults) {
                Write-Host "✅ $($result.IP) - Valid"
            }
            Write-Host ""
        }
    Write-Host "══════════════════════════════════════════════════════════════════════════════"
    } while (!$allIPsValid)
}

if (!$ipOnly) {
    # Wait 10 seconds after last adapter creation
    Start-Countdown -seconds 10
}

# Assign IP addresses to virtual adapters using template from JSON
foreach ($vlan in $vlans) {
    if ($useDHCP) {
        # DHCP configuration
        Write-Host "Setting DHCP for '$($vlan.Name)'..."
        
        # Wait for adapter to be available and get fresh adapter info
        $maxRetries = 10
        $retryCount = 0
        $adapter = $null

        while ($retryCount -lt $maxRetries -and $adapter -eq $null) {
            $adapter = Get-NetAdapter | Where-Object { $_.Name -eq "vEthernet ($($vlan.Name))" }
            if ($adapter -eq $null) {
                Write-Host "Waiting for adapter 'vEthernet ($($vlan.Name))' to be available... ($($retryCount + 1)/$maxRetries)"
                Start-Sleep -Seconds 3
                $retryCount++
            }
        }

        if ($adapter) {
            try {
                # Enable DHCP for this adapter
                Write-Host "Enabling DHCP for '$($vlan.Name)'..."
                Set-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -Dhcp Enabled
                
                # Remove any existing static IP addresses (only if they exist)
                $existingIPs = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
                if ($existingIPs) {
                    foreach ($existingIP in $existingIPs) {
                        Remove-NetIPAddress -IPAddress $existingIP.IPAddress -Confirm:$false
                    }
                }
                
                Write-Host "✓ Successfully enabled DHCP for '$($vlan.Name)'"
            }
            catch {
                Write-Host "✗ Error enabling DHCP for '$($vlan.Name)': $($_.Exception.Message)"
            }
        } else {
            Write-Host "✗ Error: Adapter '$($vlan.Name)' not found after $maxRetries attempts"
        }
    } else {
        # Static IP configuration (existing logic)
        # Build IP address from template
        $ip = $ipBase
        $ip = $ip -replace '\{vlan\}', $vlan.VlanId
        foreach ($octetName in $ipOctets.Keys) {
            $ip = $ip -replace "`{$octetName`}", $ipOctets[$octetName]
        }
        
        Write-Host "Setting IP $ip for '$($vlan.Name)'..."

        # Wait for adapter to be available and get fresh adapter info
        $maxRetries = 10
        $retryCount = 0
        $adapter = $null

        while ($retryCount -lt $maxRetries -and $adapter -eq $null) {
            $adapter = Get-NetAdapter | Where-Object { $_.Name -eq "vEthernet ($($vlan.Name))" }
            if ($adapter -eq $null) {
                Write-Host "Waiting for adapter 'vEthernet ($($vlan.Name))' to be available... ($($retryCount + 1)/$maxRetries)"
                Start-Sleep -Seconds 3
                $retryCount++
            }
        }

        if ($adapter) {
            try {
                # Use netsh for IP configuration instead of PowerShell cmdlets
                Write-Host "Configuring IP $ip for '$($vlan.Name)' using netsh..."
                
                # Get adapter name for netsh
                $adapterName = $adapter.Name
                
                # Use netsh to set static IP (this automatically handles DHCP disable)
                $netshCommand = "netsh interface ip set address ""$adapterName"" static $ip $subnetMask"
                Write-Host "Running: $netshCommand"
                $result = cmd /c $netshCommand 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ Successfully set IP $ip for '$($vlan.Name)'"
                } else {
                    Write-Host "✗ Netsh failed: $result"
                    throw "Netsh IP configuration failed"
                }

                # Verify the IP was set correctly
                $verifyIP = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex | Where-Object { $_.IPAddress -eq $ip }
                if ($verifyIP) {
                    Write-Host "✓ Successfully set IP $ip for '$($vlan.Name)'"
                } else {
                    Write-Host "⚠ Warning: IP $ip may not have been set correctly for '$($vlan.Name)'"
                }
            }
            catch {
                Write-Host "✗ Error setting IP for '$($vlan.Name)': $($_.Exception.Message)"
            }
        } else {
            Write-Host "✗ Error: Adapter '$($vlan.Name)' not found after $maxRetries attempts"
        }
    }
}

# Configuration Summary
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           CONFIGURATION SUMMARY                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if (!$ipOnly) {
    Write-Host "Selected NIC: $selectedNic" -ForegroundColor White
}
if (!$useDHCP) {
    Write-Host "Subnet: $subnetMask" -ForegroundColor White
    Write-Host "IP Method: Static" -ForegroundColor White
} else {
    Write-Host "IP Method: DHCP" -ForegroundColor White
}
Write-Host ""
Write-Host "Configured VLANs:" -ForegroundColor White

if ($useDHCP) {
    foreach ($vlan in $vlans) {
        Write-Host "  VLAN $($vlan.VlanId) ($($vlan.Name)): DHCP enabled" -ForegroundColor Green
    }
} else {
    foreach ($result in $validationResults) {
        Write-Host "  VLAN $($result.VLAN.VlanId) ($($result.VLAN.Name)): $($result.IP) - Broadcast: $($result.Broadcast)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Script completed successfully." -ForegroundColor Green

