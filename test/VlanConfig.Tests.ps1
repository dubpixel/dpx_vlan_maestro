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
# NOTE: top-level code in this file runs during Pester's discovery pass, which
# is a separate scope from the run pass that BeforeAll/It execute in. Every
# variable shared across that boundary MUST use the $script: scope modifier
# explicitly, or it will read back as $null when a Describe block runs.
# ================================================================================

$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:ScriptPath = Join-Path $script:RepoRoot 'src/vlan_maestro.ps1'
$script:JsonPath = Join-Path $script:RepoRoot 'src/vlan_sets.json'

Describe 'vlan_maestro.ps1 syntax' {
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
        $script:Json = Get-Content $script:JsonPath -Raw | ConvertFrom-Json
        $script:FacilityNames = $script:Json.vlanSets.PSObject.Properties.Name
    }

    It 'is valid JSON' {
        $script:Json | Should -Not -BeNullOrEmpty
    }

    It 'has at least one facility' {
        $script:FacilityNames.Count | Should -BeGreaterThan 0
    }

    foreach ($name in @('4Wall', 'Dapper', 'Desert', 'ExampleFacility')) {
        It "defines facility '$name'" {
            $script:FacilityNames | Should -Contain $name
        }
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
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ScriptPath, [ref]$tokens, [ref]$parseErrors)

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

        $script:Json = Get-Content $script:JsonPath -Raw | ConvertFrom-Json

        function script:Normalize($vlanSetData) {
            $vlans = $vlanSetData.vlans | ForEach-Object {
                [PSCustomObject]@{ Name = $_.Name; VlanId = [int]$_.VlanId }
            } | Sort-Object VlanId

            $ipDefaults = @{}
            if ($vlanSetData.ipDefaults) {
                foreach ($prop in $vlanSetData.ipDefaults.PSObject.Properties) {
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
