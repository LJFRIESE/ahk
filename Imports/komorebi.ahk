#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Resize
;!+Right::Komorebic("resize-axis horizontal increase")
;!+Left::Komorebic("resize-axis horizontal decrease")
;!+Up::Komorebic("resize-axis vertical increase")
;!+Down::Komorebic("resize-axis vertical decrease")

; Focus windows
;!Left::Komorebic("focus left")
;!Down::Komorebic("cycle-workspace previous")
;!Up::Komorebic("cycle-workspace next")
;!Right::Komorebic("focus right")

NumpadEnd::Komorebic("focus left") 
NumpadDown::Komorebic("focus right")
F24::Komorebic("cycle-workspace next")
F23::Komorebic("cycle-workspace previous")

!+^Home::Komorebic("focus left") 
!+^End::Komorebic("focus right")
!+^PgUp::Komorebic("cycle-workspace next")
!+^PgDn::Komorebic("cycle-workspace previous")

; Move windows

!+^Right::Komorebic("move right")
!+^Left::Komorebic("move left")

!+^Up::Komorebic("cycle-move-to-workspace next")
!+^Down::Komorebic("cycle-move-to-workspace previous")


; Stack windows

!^+#Right::Komorebic("cycle-stack previous")
!^+#Left::Komorebic("cycle-stack next")

!^+#Up::Komorebic("stack-all") 
!+^#Down::Komorebic("unstack")

; Manipulate windows
!+^f::Komorebic("toggle-float")
!+^Tab::Komorebic("toggle-workspace-layer") 
NumpadPgDn::Komorebic("toggle-workspace-layer") 
!+^t::Komorebic("toggle-tiling") 
!+^=::Komorebic("toggle-monocle")

!+^q::Komorebic("close")

; Window manager options
!+^r::Komorebic("retile")
!+^p::Komorebic("toggle-pause")
!+^u::Komorebic("unmanage")
!+^m::Komorebic("manage")
!+^n::Komorebic("new-workspace")


; Focus Workspaces
; Monitor
F13:: {
Komorebic("focus-workspace 0")
;    Komorebic("focus-monitor-workspace 1 0")
}

F14:: { 
Komorebic("focus-workspace 1")
;    Komorebic("focus-monitor-workspace 1 1")
}

F15:: {
Komorebic("focus-workspace 2")
;    Komorebic("focus-monitor-workspace 1 2")
}

F16:: {
Komorebic("focus-workspace 3")
;    Komorebic("focus-monitor-workspace 1 3")
}

F17:: {
	Komorebic("focus-workspace 4")
;    Komorebic("focus-monitor-workspace 1 4")
}

; Move windows across workspaces
; Monitor
F18:: {
     KomorebicNoWait("move-to-workspace 0")
    ;KomorebicNoWait("move-to-monitor-workspace 1 0")
}

F19:: {
    KomorebicNoWait("move-to-workspace 1")
	;KomorebicNoWait("move-to-monitor-workspace 1 1")
}

F20:: {
    KomorebicNoWait("move-to-workspace 2")
	;KomorebicNoWait("move-to-monitor-workspace 1 2")
}

F21:: {
    KomorebicNoWait("move-to-workspace 3")
	;KomorebicNoWait("move-to-monitor-workspace 1 3")
}

F22:: {
    KomorebicNoWait("move-to-workspace 4")
	;KomorebicNoWait("move-to-monitor-workspace 1 4")
}



; Laptop
;~+F13:: {
;    Komorebic("focus-monitor-workspace 0 0")
;}

;~+F14:: { 
;    Komorebic("focus-monitor-workspace 0 1")
;}

;~+F15:: {
;    Komorebic("focus-monitor-workspace 0 2")
;}

;~+F16:: {
;    Komorebic("focus-monitor-workspace 0 3")
;}

;~+F17:: {
;    Komorebic("focus-monitor-workspace 0 4")
;}


; Laptop
;~+F18:: {
;    KomorebicNoWait("move-to-monitor-workspace 0 0")
;}

;~+F19:: {
;    KomorebicNoWait("move-to-monitor-workspace 0 1")
;}

;~+F20:: {
;    KomorebicNoWait("move-to-monitor-workspace 0 2")
;}

;~+F21:: {
;    KomorebicNoWait("move-to-monitor-workspace 0 3")
;}

;~+F22:: {
;    KomorebicNoWait("move-to-monitor-workspace 0 4")
;}
