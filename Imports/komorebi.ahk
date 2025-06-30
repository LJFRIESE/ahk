#Requires AutoHotkey v2.0.2
#SingleInstance Force

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

KomorebicNoWait(cmd) {
    Run(format("komorebic.exe {}", cmd), , "Hide")
}

; Focus windows
!Left::Komorebic("focus left")
!Down::Komorebic("focus down")
!Up::Komorebic("focus up")
!Right::Komorebic("focus right")

; Resize
!+Right::Komorebic("resize-axis horizontal increase")
!+Left::Komorebic("resize-axis horizontal decrease")
!+Up::Komorebic("resize-axis vertical increase")
!+Down::Komorebic("resize-axis vertical decrease")

; Move windows
!+^Down::Komorebic("move down")
!+^Up::Komorebic("move up")
!+^Right::Komorebic("move right")
!+^Left::Komorebic("move left")

; Stack windows

; !^+#Down::Komorebic("stack down")
; !^+#Up::Komorebic("stack up")
; !^+#Right::Komorebic("stack right")
; !^+#Left::Komorebic("stack left")

!PgDn::Komorebic("cycle-stack previous")
!PgUp::Komorebic("cycle-stack next")
!^+Home::Komorebic("cycle-workspace previous")
!^+End::Komorebic("cycle-workspace next")

;!^+Space::Komorebic("focus-last-workspace")


#HotIf GetKeyState("ScrollLock", "T")	
	Up::Komorebic("stack-all")
	Down::Komorebic("unstack")


	^+r::{
		Komorebic("stop --bar")
		Komorebic("start --bar")
	}
	
	^+k::{
		Komorebic("stop --bar")
	}
#HotIf


; Manipulate windows
!f::Komorebic("toggle-float")
!^f::Komorebic("toggle-workspace-layer") 
!+^f::Komorebic("toggle-tiling")
!m::Komorebic("toggle-monocle")

!q::Komorebic("close")
;~!m::Komorebic("minimize")

; Window manager options
!+r::Komorebic("retile")
!+p::Komorebic("toggle-pause")

; Layouts
!+^y::Komorebic("flip-layout horizontal-and-vertical")
!+^l::Komorebic("cycle-layout next")
	

; Workspaces

~F13:: {
    Komorebic("focus-workspace 0")
}

F14:: {
    Komorebic("focus-workspace 1")
}

F15:: {
    Komorebic("focus-workspace 2")
}

F16:: {
    Komorebic("focus-workspace 3")
}

F17:: {
    Komorebic("focus-workspace 4")
}

F18:: {
    Komorebic("focus-workspace 5")
}

F19:: {
    Komorebic("focus-workspace 6")
}

F20:: {
    Komorebic("focus-workspace 7")
}

F21:: {
    Komorebic("focus-workspace 8")
}

F22:: {
    Komorebic("focus-workspace 9")
}

; Move windows across workspaces
^!+1:: {
    KomorebicNoWait("move-to-workspace 0")
}

^!+2:: {
    KomorebicNoWait("move-to-workspace 1")
}

^!+3:: {
    KomorebicNoWait("move-to-workspace 2")
}

^!+4:: {
    KomorebicNoWait("move-to-workspace 3")
}

^!+5:: {
    KomorebicNoWait("move-to-workspace 4")
}

^!+6:: {
    KomorebicNoWait("move-to-workspace 5")
}

^!+7:: {
    KomorebicNoWait("move-to-workspace 6")
}

^!+8:: {
    KomorebicNoWait("move-to-workspace 7")
}

^!+9:: {
    KomorebicNoWait("move-to-workspace 8")
}

^!+0:: {
    KomorebicNoWait("move-to-workspace 9")
}


