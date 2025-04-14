class ActionMenu {

	; === Initial Menu ===
	static Menu_Main() {
		options := [
			["a", "Applications"],
			["e", "Excel"],
			[":-----  Quick Commands -----"," "],
			["s", "Snipping Tool"],
			["p", "Clipboard to Paint"],
			[":----- AHK Control -----"," "],
			["r", "Reload"],
			["w", "Window Spy"], 
			["d", "AHK Docs"],
			["o", "Other"]
		]
		choice := this.WaitForChoice("Main menu", options )

		switch choice, 0 {
			case "s":
				runOrActivate("SnippingTool.exe", "Snipping Tool")
				Send("^n")
			case "p":
				runOrActivate("mspaint.exe", "Untitled - Paint")
				Send("^v")
			case "r":
				ReloadAllScripts()
			case "w":
				Run('"' . A_Local . '\programs\AutoHotkey\WindowSpy.ahk"')
			case "d":
				Run('"' . A_Local . '\programs\AutoHotkey\v2\AutoHotkey.chm"')
			default:
				return
			}
	}
	
	; === Sub-Menus ===
	static Menu_Applications() {
		options := [
			["a", "Aware360 Toggle"],
			["v", "VPN Toggle"],
			["s", "[SAG] VMWare"],
			;["V", "Outlook - VOCA/VIS-VII"] ,
			;["1", "Automated Reporter"]
		]
		choice := this.WaitForChoice("[A]pplications", options)

		switch choice, 0 {
			case "v":
				RemoteWork.toggleVPN()
			 case "a":
				RemoteWork.toggleAware360()
			;case "V":
			;	if (!ProcessExist("outlook.exe"))
			;		{
			;		Run("outlook.exe")
			;		; Sleep 15000  ;can change this is want
			;		}
			;	outlookApp := ComObjActive("Outlook.Application")
			;
			;	MailItem := outlookApp.CreateItem(0)
			;	MailItem.Subject :=  "Weekly Report | VOCA/VIS-VII"    
			;	MailItem.Display   
			 case "s":
				 runOrActivate("C:\Program Files (x86)\VMware\VMware Horizon View Client\vmware-view.exe")
			 ;case "1":
			 ;    Run(A_ComSpec ' /c "C:\Users\LUCASFRI\git\SIBA_R_REPORTING\run.bat"')
			default:
				this.Menu_Main()  
		}
	}

	static Menu_Excel() {
		options := [
			["1", "Report Inventory"],
			["2", "Ad Hoc Tracker"]
		]
		choice := this.WaitForChoice("[E]xcel", options)

		switch choice, 0 {
			case "1":
				Run("M:\REPORTS\Report Inventory.xlsx")
			case "2":
				Run("M:\REPORTS\AD HOC\Ad Hoc Request Tracker.xlsx")
			default:
				this.Menu_Main()
			}
		}
	
	static Menu_Other() {
		options := [
			["1", "List AHK scripts"],
			["2", "Kill AHK scripts"],
			["3", "Monitor Info"],
			["i", "Image Search"],
			["m", "Macro"]
		]
		choice := this.WaitForChoice("[O]ther AHK", options)

		switch choice, 0 {
			case "m": 
				Run("MacroRecorder.ahk")
			case "1":
				ListActiveScripts()
			case "3":
				GetMonitorInfo()
			case "2":
				 KillActiveScripts()
			case "i":
				findImage()
			default:
				this.Menu_Main()
			}
		}
	
	; === Choice Selection ===
	static WaitForChoice(name, options := []) {
		; === Building the Tooltip string, EndKeys parameter, and choices dictionary (for Menu functions) ===
		tooltipStr := name . "`n"
		menuFunctionsDict := Map()
		endKeys := ""
		
		if options.Length > 0 {
			for index, option in options {
					tooltipStr .=  option[1] . ": " . option[2]
					endKeys .= option[1]
					menuFunctionsDict[option[1]] := option[2]
				if index < options.Length
					tooltipStr .= "`n"
				endKeys .= ","
			}
		}

		; === Tooltip + Wait for input ===
		ttGui := ScriptStatusGui(tooltipStr,"center")
		SetTimer(() => ttGui.Destroy(), -5000)
		
		ih := InputHook("L1", "{Pause}{Esc}{Enter}", endKeys)
		ih.Start()
		ih.Wait()
		SetScrollLockState 0
		ttGui.Destroy()

		if ih.EndReason = "EndKey" && ih.EndKey = "Escape" {
			return
		}

		choice := ih.Input
		if !menuFunctionsDict.Has(choice) {
			return
		}

		menuChoice := menuFunctionsDict[choice]

		; if there is a menu matched by the input, call the menu function directly
		try {
			this.Menu_%menuChoice%()
		}
		; No menu, try options
		catch {
			return choice
		}
	}
}	