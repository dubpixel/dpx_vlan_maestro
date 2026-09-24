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

    It "defines facility '<_>'" -ForEach @('4Wall', 'Dapper', 'Desert', 'HIVE', 'ExampleFacility') {
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

Describe 'Add single VLAN mode helper functions (issue #11)' {
    BeforeAll {
        $scriptPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'src/vlan_maestro.ps1'

        # Dot-source only the function definitions, not the whole script —
        # the script body itself prompts for input and exits if not
        # elevated, neither of which we want during a test run. Function
        # definitions are pure text before the first executable statement,
        # so extracting them via the AST is safe.
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$parseErrors)
        $functionAsts = $ast.FindAll({
            param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $true)
        foreach ($fn in $functionAsts) {
            . ([scriptblock]::Create($fn.Extent.Text))
        }
    }

    Context 'Test-VlanIdInRange' {
        It 'accepts the boundary values 1 and 4094' {
            Test-VlanIdInRange -VlanId 1 | Should -BeTrue
            Test-VlanIdInRange -VlanId 4094 | Should -BeTrue
        }
        It 'rejects 0 and 4095' {
            Test-VlanIdInRange -VlanId 0 | Should -BeFalse
            Test-VlanIdInRange -VlanId 4095 | Should -BeFalse
        }
    }

    Context 'Test-VlanIdCollision' {
        It 'detects a VLAN ID already in the existing list' {
            Test-VlanIdCollision -VlanId 60 -ExistingVlanIds @(10, 60, 99) | Should -BeTrue
        }
        It 'returns false when the VLAN ID is not in use' {
            Test-VlanIdCollision -VlanId 61 -ExistingVlanIds @(10, 60, 99) | Should -BeFalse
        }
        It 'returns false against an empty list' {
            Test-VlanIdCollision -VlanId 61 -ExistingVlanIds @() | Should -BeFalse
        }
    }

    Context 'Add-VlanToFacilityConfig' {
        BeforeEach {
            $script:tempJsonPath = Join-Path ([System.IO.Path]::GetTempPath()) "vlan_sets_test_$([guid]::NewGuid()).json"
            @{
                vlanSets = @{
                    TestFacility = @{
                        vlans      = @(@{ Name = "10_Existing"; VlanId = 10 })
                        ipBase     = "192.168.{vlan}.{fourth}"
                        ipPrompts  = @("fourth")
                        ipDefaults = @{}
                        subnet     = "255.255.255.0"
                    }
                }
            } | ConvertTo-Json -Depth 10 | Set-Content $script:tempJsonPath
        }
        AfterEach {
            Remove-Item $script:tempJsonPath -ErrorAction SilentlyContinue
        }

        It 'appends a new VLAN to the named facility without disturbing the existing one' {
            $result = Add-VlanToFacilityConfig -JsonPath $script:tempJsonPath -FacilityName 'TestFacility' -VlanName '220_Temp_Record' -VlanId 220
            $result | Should -BeTrue

            $reloaded = Get-Content $script:tempJsonPath -Raw | ConvertFrom-Json
            $vlans = $reloaded.vlanSets.TestFacility.vlans
            $vlans.Count | Should -Be 2
            ($vlans | Where-Object { $_.VlanId -eq 10 }).Name | Should -Be '10_Existing'
            ($vlans | Where-Object { $_.VlanId -eq 220 }).Name | Should -Be '220_Temp_Record'
        }

        It 'returns false and leaves the file untouched when the facility does not exist' {
            $before = Get-Content $script:tempJsonPath -Raw
            $result = Add-VlanToFacilityConfig -JsonPath $script:tempJsonPath -FacilityName 'NoSuchFacility' -VlanName 'x' -VlanId 999 3>$null
            $result | Should -BeFalse
            (Get-Content $script:tempJsonPath -Raw) | Should -Be $before
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
