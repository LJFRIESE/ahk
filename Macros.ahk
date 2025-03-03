#SingleInstance

; Move cursor inside paired brackets
~}::
~]:: {
	if A_PriorKey="[" {
		Send("{Left}")
	}
}

~):: {
	if A_PriorKey="9" {
		Send("{Left}")
	}
}

; When creating newline after brackets, move cursor up and tab
~Enter:: {
	if A_PriorKey="0" || A_PriorKey="]" {
		Send("{Enter}{Up}{Tab}")
	}
}


+^!Up::Tabber.CycleClasses("prev")    
+^!Down::Tabber.CycleClasses("next")
+^!Left::Tabber.CycleWindows("prev")
+^!Right::Tabber.CycleWindows("next")



