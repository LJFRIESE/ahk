
#+b::{
	ActivatePreviousWindow()
}


#+w::{
	WinKill("A")
}

GroupAdd("notepad", "ahk_exe notepad++.exe")
+#n::{
	found := runOrActivateGroup("notepad")
	if !found {
		RunWait("notepad++.exe")
	}
}

GroupAdd("powerBI", "ahk_exe PBIDesktop.exe")
+#p::{
	found := runOrActivateGroup("powerBI")
}

GroupAdd("explorer", "ahk_class CabinetWClass")
+#.::{
	found := runOrActivateGroup("explorer")
	if !found {
		RunWait("explorer.exe")
	}
}

GroupAdd("outlook", "ahk_class rctrl_renwnd32")
GroupAdd("outlook", "Outlook", ,"Social|Receive|FbThread|Microsoft Outlook")
GroupAdd("outlook", " - Message")
+#o::{
	found := runOrActivateGroup("outlook")
	if !found {
		RunWait("outlook.exe")
	}
}

GroupAdd("teams", "ahk_exe ms-teams.exe")
+#t::{
	found := runOrActivateGroup("teams")
	if !found {
		RunWait("ms-teams.exe")
	}
	
}

GroupAdd("terminal", "ahk_exe WindowsTerminal.exe")
GroupAdd("terminal", "ahk_exe wt.exe")
+#Enter::{
	found := runOrActivateGroup("terminal")
	if !found {
		RunWait("wt.exe")
	}
}

GroupAdd("chrome", "ahk_exe chrome.exe",,"Omnissa Horizon")
+#c::{
	found := runOrActivateGroup("chrome")
	if !found {
		RunWait("chrome.exe")
	}
}
;Superceded by PowerToys Zoomit 
;+!^s::{
;	exe := "SnippingTool.exe"
;	if !WinExist("ahk_exe " . exe) {
;		Run(exe)
;	} else {
;		WinActivate("ahk_exe " . exe)
;	}
;	WinWaitActive("ahk_exe " . exe)
;	Send("^n")
;}

GroupAdd("SAG", "Omnissa Horizon")
+#h::{
	found := runOrActivateGroup("SAG")
	if found {
		sleep(500)
		Send("{Enter}")
	} else {
		RunWait("C:\Program Files\Google\Chrome\Application\chrome_proxy.exe  --profile-directory=Default --app-id=kkpceakhdmoajifgjbeifhehjfighpma")
	}
}


+#v::{
	RemoteWork.toggleVPN()
}
