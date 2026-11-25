# AHK

Personal AutoHotkey v2 setup.

## Entry points

| File | Purpose |
| --- | --- |
| `master.ahk` | Bootstrap script. Sets directives, loads imports, and exposes the leader menu. |

## Active modules

| File | Purpose |
| --- | --- |
| `Imports\Functions.ahk` | Shared helpers, window history and small utilities. |
| `Imports\WindowManagement.ahk` | Snapping, monitor moves and window cycle helpers for the leader menu. |
| `Imports\InputGuard.ahk` | Releases modifier keys left logically down and logs the event. |
| `Imports\VimMode.ahk` | Vim-style navigation, operators and macro recording. |
| `Imports\AppLaunchers.ahk` | Global app-launch and app-activation hotkeys. |
| `Imports\MenuEngine.ahk` | Shared menu input engine: tooltip, key suppression, nesting, timeout. |
| `Imports\ActionMenu.ahk` | Action menu tree (`!+^Space`), driven by MenuEngine. |
| `Imports\Leader.ahk` | F24 leader mode: toggleable, 3s timeout, driven by MenuEngine. |
| `Imports\RemoteWork.ahk` | VPN toggle helpers. |
| `Imports\Macros.ahk` | Context-sensitive shortcuts and one-off hotkeys. |

## Notes

- `Tasks\` contains standalone helper scripts. `leader-rollover-test.ahk` is the regression check for keys pressed before F24 is released; it uses F23 so it can run alongside `master.ahk` and writes its result to `leader-rollover-test.log`.
- `^!+Space` opens the action menu.
- `F24` (from the ZMK keyboard) toggles leader mode; `b` activates the previous window, `w` opens window management and `f` opens the `ff` file browser. Esc or a second F24 cancels; a 3s idle timeout also exits.
- Leader `w` uses vim mnemonics: `h`/`l` snap left/right, `k`/`j` snap top/bottom, `f` fills the monitor, `c` closes, `b`/`p` cycle windows, `<`/`>` move between monitors, `o` minimises other windows and `d` shows monitor info. Snapping uses explicit work-area geometry so Windows Snap Assist never steals focus.
- Leader `f` runs the zsh `ff` browser in `~` (`f`), `~/git` (`g`), `~/agent_projects` (`p`), the ad hoc reports share (`a`) or Windows Recent files (`r`). The old action-menu `Find` entry is gone; ad hoc Find still lives under Reporting → AdHoc.
- Both menus use the same engine: Backspace goes up one level, Esc closes, and unrecognised keys are swallowed. The `!+^Space` action menu waits indefinitely; the leader times out after 3s.
- Hyper (Win+Ctrl+Shift+Alt) and `+#Enter` focus/launch Windows Terminal; the bare Hyper chord is swallowed so Windows does not open Office/Copilot.
- Stuck modifier events are logged to `%APPDATA%\ahk\input-guard.log`.
- Syntax check from zsh: `MSYS2_ARG_CONV_EXCL='*' ~/AppData/Local/programs/AutoHotkey/v2/AutoHotkey64.exe /validate master.ahk` (exit 0 = clean). `/validate` is a switch; without the env prefix MSYS2 rewrites it into a path and AHK silently exits 2. A quoted `~` is not expanded by zsh.
