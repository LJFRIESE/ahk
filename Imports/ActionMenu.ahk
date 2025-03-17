; === Choice Selection ===
WaitForChoice(name, options*) {
    ; === Building the Tooltip string, EndKeys parameter, and choices dictionary (for Menu functions) ===
    tooltipStr := name . "`n"
    menuFunctionsDict := Map()
    sendInputDict := Map()
    endKeys := ""

    for index, option in options {
            tooltipStr .=  option[1] . ": " . option[2]
            endKeys .= option[1]
            menuFunctionsDict[option[1]] := option[2]
        if index < options.Length
            tooltipStr .= "`n"
        endKeys .= ","
    }

    ; === Tooltip + Wait for input ===
    ttGui := ScriptStatusGui(tooltipStr,"center")
	SetTimer(() => ttGui.Destroy(), -5000)
    
    ih := InputHook("L1", "{Pause}{Esc}{Enter}", endKeys)
    ih.Start()
    ih.Wait()
    ttGui.Destroy()

    SetScrollLockState 0

    if ih.EndReason = "EndKey" && ih.EndKey = "Escape"
        return

    choice := ih.Input
    if !menuFunctionsDict.Has(choice)
        return

    menuChoice := menuFunctionsDict[choice]

    ; if there is a menu matched by the input, call the menu function directly
    try {
        Menu_%menuChoice%()
    }
    ; No menu, try options
    catch {
        return choice
    }
}

; === Menus ===
Menu_Applications() {
    choice := WaitForChoice("[A]pplications",
        ["v", "VPN Toggle"],
		["s", "[SAG] VMWare"],
        ["0", "Outlook - VOCA/VIS-VII"] ;,
		;["1", "Automated Reporter"]
        )

    switch choice, 0 {
        case "v":
            #Include Cisco.ahk
            CiscoConnectToggle()
        case "o":
            if (!ProcessExist("outlook.exe"))
                {
                Run("outlook.exe")
                ; Sleep 15000  ;can change this is want
                }
            outlookApp := ComObjActive("Outlook.Application")

            MailItem := outlookApp.CreateItem(0)
			MailItem.Subject :=  "Weekly Report | VOCA/VIS-VII"    
            MailItem.Display   
         case "s":
             runOrActivate("vmware-view.exe")
         ;case "1":
         ;    Run(A_ComSpec ' /c "C:\Users\LUCASFRI\git\SIBA_R_REPORTING\run.bat"')
        default:
            Menu_Main()  
    }
}

Menu_Files() {
    choice := WaitForChoice("[F]iles",
        ["1", "Report Inventory"],
        ["2", "Ad Hoc Tracker"])

    switch choice, 0 {
        case "1":
            Run("M:\\REPORTS\\Report Inventory.xlsx")
        case "2":
            Run("M:\\REPORTS\\AD HOC\\Ad Hoc Request Tracker.xlsx")
        default:
            Menu_Main()
        }
	}

Menu_Other() {
    choice := WaitForChoice("[F]iles",
        ["1", "List"],
		["2", "Info"],
        ["k", "Kill"]
		)

    switch choice, 0 {
	    case "1":
            ListActiveScripts()
	    case "2":
            GetMonitorInfo()
        case "k":
             KillActiveScripts()
        default:
            Menu_Main()
        }
	}


Menu_Main() {
    choice := WaitForChoice("Main menu",
        ["a", "Applications"],
        ["f", "Files"],
        [":-----  Quick Commands -----"," "],
        ["t", "Terminal"],
        ["s", "Snipping Tool"],
		[":----- AHK Control -----"," "],
        ["r", "Reload"],
		["o", "Other"]
       )

    switch choice, 0 {
        case "t":
            if WinExist("ahk_exe WindowsTerminal.exe") {
                WinActivate("ahk_exe WindowsTerminal.exe")
            } else {
                Run("wt.exe")
            }
        case "s":
            runOrActivate("SnippingTool.exe")
        case "r":
            ReloadAllScripts()
        default:
            return
        }
}
