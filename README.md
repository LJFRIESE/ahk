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
| `Imports\Leader.ahk` | F24 leader mode: toggleable, 3s timeout, tooltip menu tree. |
| `Imports\RemoteWork.ahk` | VPN toggle helpers. |
| `Imports\Macros.ahk` | Context-sensitive shortcuts and one-off hotkeys. |

## Notes

- `Tasks\` contains standalone helper scripts.
- `^!+Space` opens the action menu.
- `F24` (from the ZMK keyboard) toggles leader mode; `b` activates the previous window. Esc or a second F24 cancels; a 3s idle timeout also exits.
- Hyper (Win+Ctrl+Shift+Alt) and `+#Enter` focus/launch Windows Terminal; the bare Hyper chord is swallowed so Windows does not open Office/Copilot.
- Stuck modifier events are logged to `%APPDATA%\ahk\input-guard.log`.
- Syntax check from zsh: `MSYS2_ARG_CONV_EXCL='*' ~/AppData/Local/programs/AutoHotkey/v2/AutoHotkey64.exe /validate master.ahk` (exit 0 = clean). `/validate` is a switch; without the env prefix MSYS2 rewrites it into a path and AHK silently exits 2. A quoted `~` is not expanded by zsh.
