class ActionMenu {

	; === Initial Menu ===
	static Menu_Main() { 
		options := [
			["a", "Applications"],
			["e", "Excel"],
			[":-----  Quick Commands -----"," "],
			["k", "Komorebic"],
			["p", "Clipboard to Paint"],
			[":----- AHK Control -----"," "],
			["r", "Reload"],
			["m", "More"]
		]
		choice := this.WaitForChoice("Main menu", options )

		switch choice, 0 {
			case "p":
				runOrActivate("mspaint.exe", "Untitled - Paint")
				Send("^v")
			case "r":
				ReloadAllScripts()
			default:
				return
			}
	}
	
	; === Sub-Menus ===
	static Menu_Applications() {
		options := [
			["a", "Aware360 Toggle"],
			;["V", "Outlook - VOCA/VIS-VII"] ,
			;["1", "Automated Reporter"]
		]
		choice := this.WaitForChoice("[A]pplications", options)

		switch choice, 0 {
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
			 ;case "1":
			 ;    Run(A_ComSpec ' /c "C:\Users\LUCASFRI\git\SIBA_R_REPORTING\run.bat"')
			default:
				this.Menu_Main()  
		}
	}

	static Menu_Excel() {
		options := [
			["i", "Report Inventory"],
			["t", "Ad Hoc Tracker"]
		]
		choice := this.WaitForChoice("[E]xcel", options)

		switch choice, 0 {
			case "i":
				Run("M:\REPORTS\Report Inventory.xlsx")
			case "t":
				Run("M:\REPORTS\AD HOC\Ad Hoc Request Tracker.xlsx")
			default:
				this.Menu_Main()
			}
		}
	
	
	static Menu_Komorebic() {
		options := [
			["r", "Reload"],
			["k", "Kill"],	
		]
		choice := this.WaitForChoice("[K]omorebic", options)

		switch choice, 0 {
			case "r":
				Komorebic("stop --bar")
				Komorebic("start --bar")
			case "k":
				Komorebic("stop --bar")
			default:
				this.Menu_Main()
			}
		}
	
	static Menu_More() {
		options := [
			["1", "List AHK scripts"],
			["2", "Kill AHK scripts"],
			["3", "Monitor Info"],
			["i", "Image Search"],
			["m", "Macro"],
			["w", "Window Spy"], 
			["d", "AHK Docs"]
			
		]
		choice := this.WaitForChoice("[O]ther AHK", options)

		switch choice, 0 {
			case "w":
				Run('"' . A_Local . '\programs\AutoHotkey\WindowSpy.ahk"')
			case "d":
				Run('"' . A_Local . '\programs\AutoHotkey\v2\AutoHotkey.chm"')
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