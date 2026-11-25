; F24 leader mode. The menu tree and input handling live in MenuEngine.

class Leader {
    static Timeout := 3

    static Toggle() {
        if MenuEngine.Active && MenuEngine.Id = "Leader"
            MenuEngine.Close()
        else
            this.Open()
    }

    static Open() {
        MenuEngine.Open(this.Root(), {
            id: "Leader",
            timeout: this.Timeout,
            exitKeys: "{Esc}{vk87}",
            footer: "Backspace: back · F24/Esc: exit"
        })
    }

    static Root() {
        return {
            label: "Leader",
            entries: [
                {label: "^w: Window"},
                {key: "f", label: "Find", children: this.Find()},
                {key: "b", label: "Previous window", action: ActivatePreviousWindow}
            ]
        }
    }

    static Window() {
        return {
            label: "Window",
            entries: [
                {key: "h", label: "Snap left", action: () => SnapActiveWindow(-1)},
                {key: "l", label: "Snap right", action: () => SnapActiveWindow(1)},
                {key: "k", label: "Snap top", action: () => SnapActiveWindowVertical(-1)},
                {key: "j", label: "Snap bottom", action: () => SnapActiveWindowVertical(1)},
                {key: "f", label: "Fill monitor", action: MaximizeActiveWindow},
                {key: "c", label: "Close window", action: CloseActiveWindow},
                {key: "b", label: "Previous window", action: ActivatePreviousWindow},
                {key: "p", label: "Next window", action: ActivateNextWindow},
                {key: "<", label: "Move to previous monitor", action: () => MoveActiveWindowToMonitor(-1)},
                {key: ">", label: "Move to next monitor", action: () => MoveActiveWindowToMonitor(1)},
                {key: "o", label: "Minimize other windows", action: MinimizeOtherWindows},
                {key: "d", label: "Monitor info", action: GetMonitorInfo}
            ]
        }
    }

    static Find() {
        return {
            label: "Find",
            entries: [
                {key: "f", label: "Files (~)", action: () => RunFind()},
                {key: "g", label: "Git repos", action: () => RunFind("~/git")},
                {key: "p", label: "Projects", action: () => RunFind("~/agent_projects")},
                {key: "a", label: "Ad hoc reports", action: () => RunFind("/m/REPORTS/AD HOC")},
                {key: "r", label: "Recent files", action: () => RunFind("/c/Users/" . A_UserName . "/AppData/Roaming/Microsoft/Windows/Recent")}
            ]
        }
    }
}
