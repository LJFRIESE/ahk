# AHK

Personal AutoHotkey v2 setup.

## Entry points

| File | Purpose |
| --- | --- |
| `master.ahk` | Bootstrap script. Sets directives, loads imports, and exposes the leader menu. |

## Active modules

| File | Purpose |
| --- | --- |
| `Imports\Functions.ahk` | Shared helpers and small utilities. |
| `Imports\InputGuard.ahk` | Releases modifier keys left logically down and logs the event. |
| `Imports\VimMode.ahk` | Vim-style navigation, operators and macro recording. |
| `Imports\AppLaunchers.ahk` | Global app-launch and app-activation hotkeys. |
| `Imports\ActionMenu.ahk` | Leader-driven action menu. |
| `Imports\RemoteWork.ahk` | VPN toggle helpers. |
| `Imports\Macros.ahk` | Context-sensitive shortcuts and one-off hotkeys. |

## Notes

- `Tasks\` contains standalone helper scripts.
- `^!+Space` opens the action menu.
- Stuck modifier events are logged to `%APPDATA%\ahk\input-guard.log`.
