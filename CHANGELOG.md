# Changelog

## v2.5.0

> ⚠️ **Untested on real hardware.** The diff logic (`Compare-FacilityVlansToSwitch`) is unit-tested directly, but the actual `Add-VMNetworkAdapter`/`Set-VMNetworkAdapterVlan` reconciliation flow has only been validated statically (syntax/lint/CI), not run against a real switch with real drift/missing-VLAN scenarios.

### Added
- New "Update existing" mode (issue #10) — reconciles an already-configured switch against the selected facility's current VLAN list, adding only what's missing:
  - Diffs by adapter name; a facility VLAN with no matching adapter is added, one whose name matches but whose live VLAN ID differs is **flagged and skipped** (never auto-corrected — per the ticket's explicit scope decision), and exact matches are left alone
  - Shows a preview (already-present count, drifted entries with configured-vs-live VLAN ID, and the list of VLANs that would be added) and requires confirmation before creating anything
  - Never touches or removes existing adapters; doesn't assign IPs to newly added ones either — the note in the mode's own output says to run IP-only mode afterward for that, keeping this mode purely additive/topology-only
  - Solves the exact gap that motivated this ticket: a host already running the pre-v2.0 4Wall set had no supported way to pick up the new `218_Dante` VLAN without a full teardown/rebuild
- Added `Compare-FacilityVlansToSwitch` as a standalone, pure diff function with direct Pester unit tests (missing VLAN, drift detection, exact-match, and empty-switch cases)
- Extended the `$validModes` sanity test to cover the new `updateExisting` flag
- Updated version to 2.5.0 and ASCII art title accordingly

## v2.4.0

> ⚠️ **Untested on real hardware for anything Hyper-V-touching.** This
> release is JSON-only — it never calls a Hyper-V cmdlet — so there's no
> new Hyper-V-side risk, but the interactive flow itself (prompts,
> validation, confirmation) hasn't been run end-to-end on a real Windows
> host yet, only the extracted logic functions are unit-tested.

### Added
- New "Manage facility schemas" mode (issue #7) — add a new facility or edit an existing one's VLANs/IP config directly in `vlan_sets.json`, no more hand-editing JSON:
  - **Add new facility**: name (validated unique), one or more VLANs (name + ID, range/uniqueness validated), `ipBase` template with per-token prompt-vs-default choice, and subnet — confirmed with a preview before writing
  - **Edit existing facility**: add/remove/rename a VLAN, or update `ipBase`/`ipPrompts`/`ipDefaults`/subnet — each write confirmed first
  - Deliberately JSON-only per explicit decision — never touches the in-script `$hardcoded4Wall`/`$hardcodedDapper`/`$hardcodedDesert` fallback variables, avoiding the far riskier problem of rewriting PowerShell source from PowerShell at runtime. JSON already always wins over the hardcoded fallback whenever the file is present and valid, so this fully solves the schema-drift problem the ticket was filed over
  - Facility deletion intentionally out of scope (higher risk, left as a possible follow-up)
- Added six new standalone, testable functions backing the above: `Test-FacilityNameAvailable`, `Add-FacilityToConfig`, `Remove-VlanFromFacilityConfig`, `Rename-VlanInFacilityConfig`, `Set-FacilityIpConfig`, `Get-IpBaseTokens` — each with direct Pester unit tests against temp JSON files in `test/VlanConfig.Tests.ps1`
- Added a `$validModes` sanity-check test that AST-extracts the mode table and asserts each mode's flags are mutually exclusive — this is a regression test for a real bug caught during this pass, where mode 4's `addSingle` flag got accidentally flipped to `$false` while adding mode 5's `schemaEdit` flag
- Updated version to 2.4.0 and ASCII art title accordingly

## v2.3.1

> ⚠️ **Hyper-V behavior untested on real hardware**, same caveat as v2.3.0
> below — this release only restructures the Add-single-VLAN mode's
> prompt flow, doesn't change what the Hyper-V cmdlets do.

### Changed
- Add single VLAN mode (issue #18, follow-up to #11) now asks up front where the VLAN should be applied — **System only** (Hyper-V, not saved to `vlan_sets.json` — previous default behavior), **JSON only** (saved to the current facility's config, Hyper-V untouched), or **Both**. Replaces the old flow where the VLAN was always applied live and only optionally saved afterward
- JSON-only runs now skip the switch-selection and DHCP/IP prompts entirely, since neither is relevant to a config-only save
- Updated version to 2.3.1 and ASCII art title accordingly

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