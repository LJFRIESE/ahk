+#n::{
	runOrActivate("notepad++.exe")
}

+#.::{
	explorerTitle := "ahk_exe explorer.exe"
	if WinExist(explorerTitle) {
		WinActivate(explorerTitle)
	} else {
		Run("explorer.exe")
	}
	WinWaitActive(explorerTitle)
}

+#o::{
	runOrActivate("OUTLOOK.EXE")
}

+#t::{
	runOrActivate("ms-teams.exe")
}

+#Enter::{
	runOrActivate("wt.exe")
}

+#b::{
	runOrActivate("chrome.exe")
}

+#s::{
	exe := "SnippingTool.exe"
	if !WinExist("ahk_exe " . exe) {
		Run(exe)
	} else {
		WinActivate("ahk_exe " . exe)
	}
	WinWaitActive("ahk_exe " . exe)
	Send("^n")
}

+#h::{
	runOrActivate("C:\Program Files\Omnissa\Omnissa Horizon Client\horizon-client.exe")
}

+#v::{
	RemoteWork.toggleVPN()
}
