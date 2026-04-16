class ActionMenu {

	; === Initial Menu ===
	static Menu_Main() { 
		options := [
			["r", "Reporting"],
			["w", "Web"],
			[":-----  Quick Commands -----"," "],
			["k", "Komorebic"],
			["p", "Pin tab"],
			[":----- AHK Control -----"," "],
			["z", "Reload"],
			["m", "More"]
		]
		choice := this.WaitForChoice("Main menu", options )

		switch choice, 0 {
			case "p":
			if WinActive("ahk_exe chrome.exe")
			{
				; Send the menu key (context menu key) while focused on the tab, hit p for pin. u is unpin
				Send "{F6}{F6}"
				Send "{AppsKey}{p}"
			}		
			case "z":
				ReloadAllScripts()
			default:
				return
			}
	}
	
	static Menu_Reporting() {
		options := [
			["a", "Ad Hoc"],
			["r", "Reports"],
			["d", "Ad Hoc Directory"]
		]
		choice := this.WaitForChoice("[S]cripts", options)

		switch choice, 0 {
			case "a":
				Run("python C:\Users\LUCASFRI\copilot\ad-hocs\create_adhoc_folder.py")
			case "r":
				Run("M:\REPORTS\ONGOING")
			case "d":
				Run("M:\REPORTS\AD HOC")
			default:
				this.Menu_Main()
			}
		}
	
	
	static Menu_Web() {
		options := [
			["c", "Confluence"],
			["p", "Power BI"],
			["t", "Tidal"]
		]
		choice := this.WaitForChoice("[W]eb", options)

		switch choice, 0 {
			case "c":
				Run("https://wiki.justice.gov.bc.ca/wiki/spaces/BCPSSR/overview")
			case "p":
				Run("https://app.powerbi.com/groups/b168f00d-89db-489c-b5d0-e902b88fc65a/list?tenant=6fdb5200-3d0d-4a8a-b036-d3685e359adc&experience=power-bi")
			case "t":
				Run("https://tidal.com/")
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
			["2", "Kill AHK scripts"],
			["3", "Monitor Info"],
			["i", "Image Search"],
			["w", "Window Spy"], 
			["d", "AHK Docs"]
			
		]
		choice := this.WaitForChoice("[O]ther AHK", options)

		switch choice, 0 {
			case "w":
				Run('"' . A_Local . '\programs\AutoHotkey\WindowSpy.ahk"')
			case "d":
				Run('"' . A_Local . '\programs\AutoHotkey\v2\AutoHotkey.chm"')
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
