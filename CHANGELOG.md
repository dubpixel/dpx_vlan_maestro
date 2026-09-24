# Changelog

## v2.3.0

> ⚠️ **Hyper-V behavior untested on real hardware.** The Hyper-V cmdlet
> calls in the new mode (`Add-VMNetworkAdapter`, `Set-VMNetworkAdapterVlan`,
> IP assignment) have only been validated statically (syntax/lint/CI) —
> not yet run against a real host. The new mode's actual decision logic
> (VLAN ID range/collision checks, JSON persistence) is unit-tested
> directly, see below. Treat the Hyper-V side as unverified pending
> real-world testing (issue #11).

### Added
- New "Add a single VLAN" mode (issue #11) — guided prompts to add one ad-hoc VLAN adapter to an already-existing virtual switch, independent of any facility's saved `vlan_sets.json` schema:
  - Prompts for adapter name and VLAN ID (1–4094), warning (not blocking, with confirmation) on collision with a VLAN tag already in use elsewhere on the host
  - Lets the user pick from existing virtual switches (this mode never creates a new switch/NIC binding)
  - Offers the same DHCP-vs-Static choice as Normal/IP-only modes; Static prompts for a full IP + subnet mask, validated with the existing `Test-IPAgainstSubnet` helper
  - Shows a confirmation summary before touching Hyper-V
  - Optionally offers to also persist the new VLAN into the currently-selected facility's entry in `vlan_sets.json` (defaults to no) — a lightweight bridge toward the interactive schema-editor ticket (#7) without requiring it
- Extracted the new mode's core decision logic into three standalone, testable functions — `Test-VlanIdInRange`, `Test-VlanIdCollision`, `Add-VlanToFacilityConfig` — and added direct Pester unit tests for each in `test/VlanConfig.Tests.ps1` (boundary values, collision detection, and JSON read-modify-write correctness against a temp file). This is real script logic that doesn't require Hyper-V, elevation, or mocking the whole monolithic script to exercise, unlike the Hyper-V cmdlet calls themselves
- Updated version to 2.3.0 and ASCII art title accordingly

## v2.2.2 — HIVE hotfix

> ⚠️ **HIVE facility is untested on real hardware.** This release is
> functionally identical to v2.0 (already verified on real Hyper-V
> hosts) with one JSON facility definition added — the app logic itself
> is unchanged. The `HIVE` entry has only been validated statically
> (JSON structure, VLAN ID ranges, CI checks), not yet run against a
> live switch or Hyper-V host. Treat HIVE specifically as unverified
> pending real-world testing.

### Added
- Added the `HIVE` facility to `src/vlan_sets.json` — 17 VLANs (5_LED, 10_Control, 15_Projection, 18_Truck, 20_sACN, 25_Artnet, 30_Media, 35_Content_Team, 40_Automation, 50_KVM, 55_NDI, 60_Dante_Primary, 65_Dante_Secondary, 67_Yellowtec, 70_WEB, 98_Proxmox, 99_MGMT), sourced from a switch's `show vlan brief` output. Uses the Desert-style IP scheme (`192.168.{vlan}.{fourth}`, /24, no third-octet prompt) since it's not carved from a shared 10.x block like 4Wall/Dapper
- HIVE picked up automatically in the app's facility menu — the script builds its VLAN-set list dynamically from `vlan_sets.json` keys, no code change needed beyond the JSON entry
- Added `HIVE` to the required-facilities Pester check in `test/VlanConfig.Tests.ps1`; no in-script hardcoded fallback was added for HIVE (matches existing precedent for `ExampleFacility`, which is JSON-only too)
- Updated version to 2.2.2 and ASCII art title accordingly (versioned separately from v2.02 to flag this as an untested hotfix, not a hardware-verified release like v2.0)

## v2.01

### Removed
- Removed stale duplicate `src/vlan_mesitro.ps1` (pre-rename "Mesitro"→"Maestro" leftover, out of sync with `vlan_maestro.ps1` since v2.0)
- Removed unused `dpx_release_note_template.md` stub, never filled in for this project
- Removed leftover hardware-template product images (`front.png`, `rear.png`, `front_render.png`, `rear_render.png`, `pcb_front.png`, `pcb_rear.png`, `logo_HF.png`, `dubpixel_identicon.png`) and the README's "### FRONT" product-photo section — this is a pure PowerShell tool with no physical hardware to photograph
- Removed empty/incomplete `v0.0.0` and `v1.85` changelog stub entries (no recoverable content, not backed by version-tagged git history)

### Changed
- Updated README header to the current slim template style (logo inline in the title, GitHub release badge) matching newer dubpixel software projects (e.g. dpx_buttonode)
- Updated version to 2.01 and ASCII art title accordingly

## v2.0

### Added or Changed
- Added `218_Dante` VLAN to the 4Wall facility set (previously had no Dante VLAN) — updated in both `src/vlan_sets.json` and the in-script hardcoded fallback
- Renamed the "AeonPoint" facility to its correct name, "Dapper", across `src/vlan_sets.json`, `src/vlan_maestro.ps1` (variable names and fallback config), README.md, and AGENTS.md
- Fixed a mismatch in the Dapper facility's hardcoded IP default: the in-script fallback had `third=13` while `vlan_sets.json` (the actively-used source of truth) had `third=3` — fallback corrected to `third=3`
- Removed "**CURRENTLY IN TESTING**" label from the Nuke-all mode menu description and closed out the corresponding TODO — confirmed working on real Hyper-V hosts
- Brought the project up to the current dpx template: added `AGENTS.md`/`CLAUDE.md`, refreshed `.github/` (PR template, Pages workflow, updated issue templates), fixed `_config.yml` kramdown rendering, archived the old `.github/copilot-instructions.md` to `docs/archive/` (untracked)
- Added static regression testing: `test/VlanConfig.Tests.ps1` (Pester — syntax check, `vlan_sets.json` structure validation, and a drift check between the in-script hardcoded fallback and `vlan_sets.json`, the exact bug class fixed above) plus `.github/workflows/ci.yml` running syntax check + PSScriptAnalyzer + the Pester suite on every push/PR. Note: CI runs on hosted GitHub runners, which don't support nested virtualization — it cannot exercise real Hyper-V cmdlets, only static/data checks
- Updated version to 2.0 and ASCII art title accordingly — bumped past the usual +0.01 patch increment given the scope of this pass (facility rename + data fix + full docs/template overhaul)

## v1.94

### Added or Changed
- Added DHCP vs Static IP configuration choice at the beginning of IP assignment section
- Users can now choose between DHCP (automatic IP assignment) or Static IP (manual octet entry)
- DHCP option skips octet collection and validation, enabling DHCP on all virtual adapters
- Static IP option continues with existing subnet-aware validation and IP assignment logic
- Updated configuration summary to display IP method and handle DHCP configurations appropriately
- Updated version to 1.94 and ASCII art title accordingly

## v1.93

### Added or Changed
- Reorganized README.md with collapsible sections using HTML details/summary tags
- Made Configuration, Usage Examples, and Troubleshooting sections collapsible for better user experience
- Removed duplicate Quick Start and Script Workflow sections to eliminate redundancy
- Added prominent BAT file instructions at the top of the Usage section
- Improved overall documentation organization and accessibility
- Updated version to 1.93 and ASCII art title accordingly

## v1.87

### Added or Changed
- Fixed IP prompt default values not displaying by changing `$ipDefaults[$promptName]` to `$ipDefaults.$promptName` to properly access PSCustomObject properties from JSON data
- Updated version to 1.87 and ASCII art title accordingly

## v1.86

### Added or Changed
- Implemented comprehensive subnet-aware IP validation that checks complete IP addresses against subnet constraints instead of dumb 0-255 octet validation
- Added configuration summary at script end showing selected NIC, subnet, and all VLAN IPs with broadcast addresses
- Updated IP input prompts to display subnet information for better user guidance
- Added Test-IPAgainstSubnet function for proper IP/subnet validation with network/broadcast calculation
- Updated version to 1.86 and ASCII art title accordingly

## v1.83

### Added or Changed
- Refactored hardcoded VLAN configurations to be defined as variables ($hardcoded4Wall, $hardcodedAeonPoint, $hardcodedDesert) at the top of the script for better maintainability
- Simplified the else block in VLAN set building to assign these pre-defined variables instead of inline definitions
- Updated version to 1.83 and ASCII art title accordingly