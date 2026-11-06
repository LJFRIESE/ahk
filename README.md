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

- `Tasks\` contains standalone helper scripts.
- `^!+Space` opens the action menu.
