# ================================================================================
# PESTER TESTS - Static/data regression checks for VLAN Maestro
# ================================================================================
# Requires Pester 5+. Windows PowerShell 5.1 ships an old Pester 3.4 by default;
# if `Invoke-Pester` errors on Describe/It syntax here, run:
#   Install-Module Pester -Force -SkipPublisherCheck -Scope CurrentUser
#
# These are STATIC checks only — they parse the script and JSON as text/data.
# They do NOT create switches, adapters, or touch Hyper-V in any way, and are
# safe to run on any machine (no admin rights, no Windows required).
#
# NOTE: Pester runs top-level file code during a separate "discovery" pass
# from the "run" pass that executes BeforeAll/It — values computed at the
# very top of this file (even with $script:) are NOT reliably visible inside
# BeforeAll/It. Every path/value each Describe block needs is therefore
# recomputed independently inside that block's own BeforeAll.
# ================================================================================

Describe 'vlan_maestro.ps1 syntax' {
    BeforeAll {
        $script:ScriptPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'src/vlan_maestro.ps1'
    }

    It 'parses without syntax errors' {
        $tokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($script:ScriptPath, [ref]$tokens, [ref]$parseErrors)
        if ($parseErrors.Count -gt 0) {
            $parseErrors | ForEach-Object { Write-Host "PARSE ERROR: $($_.Message) at line $($_.Extent.StartLineNumber)" }
        }
        $parseErrors.Count | Should -Be 0
    }
}

Describe 'vlan_sets.json structure' {
    BeforeAll {
        $jsonPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'src/vlan_sets.json'
        $script:Json = Get-Content $jsonPath -Raw | ConvertFrom-Json
        $script:FacilityNames = $script:Json.vlanSets.PSObject.Properties.Name
    }

    It 'is valid JSON' {
        $script:Json | Should -Not -BeNullOrEmpty
    }

    It 'has at least one facility' {
        $script:FacilityNames.Count | Should -BeGreaterThan 0
    }

    It "defines facility '<_>'" -ForEach @('4Wall', 'Dapper', 'Desert', 'ExampleFacility') {
        $script:FacilityNames | Should -Contain $_
    }

    It 'gives every facility the required keys' {
        foreach ($name in $script:FacilityNames) {
            $facility = $script:Json.vlanSets.$name
            foreach ($key in @('vlans', 'ipBase', 'ipPrompts', 'ipDefaults', 'subnet')) {
                $facility.PSObject.Properties.Name | Should -Contain $key -Because "facility '$name' is missing '$key'"
            }
        }
    }

    It 'has unique, in-range VLAN IDs within each facility' {
        foreach ($name in $script:FacilityNames) {
            $vlans = $script:Json.vlanSets.$name.vlans
            $ids = $vlans | ForEach-Object { $_.VlanId }
            ($ids | Select-Object -Unique).Count | Should -Be $ids.Count -Because "facility '$name' has duplicate VlanIds"
            foreach ($id in $ids) {
                $id | Should -BeGreaterOrEqual 1 -Because "facility '$name' has an out-of-range VlanId ($id)"
                $id | Should -BeLessOrEqual 4094 -Because "facility '$name' has an out-of-range VlanId ($id)"
            }
        }
    }
}

Describe 'hardcoded fallback matches vlan_sets.json (regression: catches drift like the AeonPoint->Dapper ipDefaults mismatch)' {
    BeforeAll {
        $repoRoot = Split-Path -Parent $PSScriptRoot
        $scriptPath = Join-Path $repoRoot 'src/vlan_maestro.ps1'
        $jsonPath = Join-Path $repoRoot 'src/vlan_sets.json'

        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$parseErrors)

        $assignments = $ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
            $node.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
            $node.Left.VariablePath.UserPath -like 'hardcoded*'
        }, $true)

        $script:HardcodedSets = @{}
        foreach ($a in $assignments) {
            $varName = $a.Left.VariablePath.UserPath
            $facilityName = $varName -replace '^hardcoded', ''
            # The assignment text is a pure data literal (hashtable/array of strings and
            # numbers) — no cmdlet calls — so evaluating it in isolation is safe.
            $value = Invoke-Expression "$($a.Extent.Text)`n`$$varName"
            $script:HardcodedSets[$facilityName] = $value
        }

        $script:Json = Get-Content $jsonPath -Raw | ConvertFrom-Json

        function script:Normalize($vlanSetData) {
            $vlans = $vlanSetData.vlans | ForEach-Object {
                [PSCustomObject]@{ Name = $_.Name; VlanId = [int]$_.VlanId }
            } | Sort-Object VlanId

            # ipDefaults arrives as a [hashtable] from the PowerShell-literal
            # fallback but a [PSCustomObject] from ConvertFrom-Json — .PSObject.Properties
            # on a Hashtable reflects the .NET Hashtable class members (Count, Keys, ...),
            # NOT its entries, so the two types need separate handling here.
            $ipDefaults = @{}
            $rawDefaults = $vlanSetData.ipDefaults
            if ($rawDefaults -is [System.Collections.IDictionary]) {
                foreach ($key in $rawDefaults.Keys) {
                    $ipDefaults[$key] = $rawDefaults[$key]
                }
            } elseif ($rawDefaults) {
                foreach ($prop in $rawDefaults.PSObject.Properties) {
                    $ipDefaults[$prop.Name] = $prop.Value
                }
            }

            [PSCustomObject]@{
                vlans      = @($vlans)
                ipBase     = $vlanSetData.ipBase
                ipPrompts  = @($vlanSetData.ipPrompts)
                ipDefaults = $ipDefaults
                subnet     = $vlanSetData.subnet
            } | ConvertTo-Json -Depth 10 -Compress
        }
    }

    It 'found at least one hardcoded fallback set to check' {
        $script:HardcodedSets.Count | Should -BeGreaterThan 0
    }

    It '<_> hardcoded fallback matches vlan_sets.json' -ForEach @('4Wall', 'Dapper', 'Desert') {
        $facilityName = $_
        $script:HardcodedSets.ContainsKey($facilityName) | Should -BeTrue -Because "no `$hardcoded$facilityName variable found in vlan_maestro.ps1"

        $jsonEntry = $script:Json.vlanSets.$facilityName
        $jsonEntry | Should -Not -BeNullOrEmpty -Because "vlan_sets.json has no '$facilityName' facility"

        $hardcodedNormalized = script:Normalize $script:HardcodedSets[$facilityName]
        $jsonNormalized = script:Normalize $jsonEntry

        $hardcodedNormalized | Should -Be $jsonNormalized -Because "the in-script fallback for '$facilityName' has drifted from vlan_sets.json — these must stay in sync or the tool behaves differently when the JSON file is missing/corrupt"
    }
}
