# AHK

Personal AutoHotkey v2 setup.

## Entry points

| File | Purpose |
| --- | --- |
| `master.ahk` | Bootstrap script. Sets directives, loads imports, and exposes the leader menu. |
| `Imports.ahk` | Central include list for active modules. |

## Active modules

| File | Purpose |
| --- | --- |
| `Imports\Functions.ahk` | Shared helpers and small utilities. |
| `Imports\AppLaunchers.ahk` | Global app-launch and app-activation hotkeys. |
| `Imports\AppContextHotkeys.ahk` | Context-sensitive hotkeys for Horizon/Chrome and Excel. |
| `Imports\ActionMenu.ahk` | Leader-driven action menu. |
| `Imports\komorebi.ahk` | Window-management bindings. |
| `Imports\RemoteWork.ahk` | VPN toggle helpers. |
| `Imports\Shortkeys.ahk` | Text expansions and hotstrings. |
| `Imports\Macros.ahk` | Miscellaneous one-off hotkeys. |

## Notes

- `unused\` holds archived scripts that are not loaded by `master.ahk`.
- `Tasks\` contains standalone helper scripts.
- `^!+Space` opens the action menu.

## Kinesis Advantage 2 quick reference

| What | Key Combination | Notes |
| --- | --- | --- |
| Power User Mode | `progm + shift + esc` | Toggle on/off |
| V Drive | `progm + F1` | Mount/unmount V Drive; Power User Mode must be on |
| Status Report | `progm + esc` | Types a status report |
| Hard Reset | `progm + F9` | Unplug keyboard, hold while plugging back in; not a full factory reset |
| New Layout | `progm + F2 X` | `X` is the target hotkey |
| Activate Layout | `progm + X` | `X` is the target hotkey |
| Key Clicks | `progm + F8` | Toggle clicking sound on/off |
| Macro Speed | `progm + F10 + 3` | Replace `3` with `1`-`9`; `9` works well for most uses |
