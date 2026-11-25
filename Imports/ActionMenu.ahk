; Action menu nodes. Driven by MenuEngine; entry point is !+^Space in master.ahk.
; Key labels are preserved from the previous WaitForChoice implementation.

class ActionMenu {
    static Menu_Main() {
        MenuEngine.Open(this.Root(), {
            id: "ActionMenu",
            timeout: 0,
            exitKeys: "{Esc}{Enter}{Pause}",
            footer: "Backspace: back · Esc/Enter: exit"
        })
    }

    static Root() {
        return {
            label: "Actions",
            entries: [
                {key: "r", label: "Reporting", children: this.Reporting()},
                {key: "w", label: "Web", children: this.Web()},
                {separator: true, label: "----- Quick Commands -----"},
                {key: "f", label: "Find", action: () => RunMSYS2("ff")},
                {key: "t", label: "Teams fix", action: teamsRestore},
                {separator: true, label: "----- AHK Control -----"},
                {key: "v", label: "Vim", action: () => VimMode.Toggle()},
                {key: "z", label: "Reload", action: ReloadAllScripts},
                {key: "m", label: "More", children: this.More()}
            ]
        }
    }

    static Reporting() {
        return {
            label: "Reporting",
            entries: [
                {key: "a", label: "AdHoc", children: this.AdHoc()},
                {key: "o", label: "Ongoing", children: this.Ongoing()},
                {key: "r", label: "Reports", action: () => OpenFolderInExplorerTab("M:\REPORTS")}
            ]
        }
    }

    static Ongoing() {
        return {
            label: "Ongoing Reports",
            entries: [
                {key: "d", label: "Ongoing Reports Directory", action: () => OpenFolderInExplorerTab("M:\REPORTS\ONGOING")}
            ]
        }
    }

    static AdHoc() {
        return {
            label: "Ad hoc Reports",
            entries: [
                {key: "n", label: "New Ad Hoc", action: () => Run("python C:\Users\LUCASFRI\agent_projects\ad-hocs\create_adhoc_folder.py")},
                {key: "d", label: "Ad Hoc Directory", action: () => OpenFolderInExplorerTab("M:\REPORTS\AD HOC")},
                {key: "f", label: "Find Ad Hoc Reports", action: () => RunMSYS2("cd /m/REPORTS/'AD HOC' && ff")},
                {key: "t", label: "Tracker", action: () => Run('"M:\REPORTS\AD HOC\Ad Hoc Request Tracker.url"')}
            ]
        }
    }

    static Web() {
        return {
            label: "Web",
            entries: [
                {key: "c", label: "Confluence", action: () => Run("https://wiki.justice.gov.bc.ca/wiki/spaces/BCPSSR/overview")},
                {key: "b", label: "Power BI", action: () => Run("https://app.powerbi.com/groups/b168f00d-89db-489c-b5d0-e902b88fc65a/list?tenant=6fdb5200-3d0d-4a8a-b036-d3685e359adc&experience=power-bi")},
                {key: "t", label: "Tidal", action: () => this.OpenTidal()},
                {key: "p", label: "Pin tab", action: () => this.PinTab()}
            ]
        }
    }

    static OpenTidal() {
        Run("https://tidal.com/")
        Sleep(500)
        if WinActive("ahk_exe chrome.exe")
            this.PinTab()
    }

    static PinTab() {
        ; Send the menu key while the tab has focus; p pins, u unpins.
        if WinActive("ahk_exe chrome.exe") {
            Send("{F6}{F6}")
            Send("{AppsKey}{p}")
        }
    }

    static More() {
        return {
            label: "Other AHK",
            entries: [
                {key: "2", label: "Kill AHK scripts", action: KillActiveScripts},
                {key: "3", label: "Monitor Info", action: GetMonitorInfo},
                {key: "w", label: "Window Spy", action: () => Run('"' . A_Local . '\programs\AutoHotkey\WindowSpy.ahk"')},
                {key: "d", label: "AHK Docs", action: () => Run('"' . A_Local . '\programs\AutoHotkey\v2\AutoHotkey.chm"')},
                {key: "r", label: "Redraw Window", action: () => WinRedraw("A")}
            ]
        }
    }
}

;	static Menu_Komorebic() {
;		options := [
;			["r", "Reload"],
;			["k", "Kill"],
;			["s", "Start"],
;			["t", "Tile"]
;		]
;		choice := this.WaitForChoice("[K]omorebic", options)
;
;		switch choice, 0 {
;			case "r":
;				Komorebic("stop --bar")
;				Komorebic("start --bar")
;			case "k":
;				Komorebic("stop --bar")
;			case "s":
;				Komorebic("start --bar")
;			case "t":
;				Komorebic("retile")
;			default:
;				this.Menu_Main()
;		}
;	}
