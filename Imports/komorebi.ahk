#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Resize
!^+Right::Komorebic("resize-axis horizontal increase")
!^+Left::Komorebic("resize-axis horizontal decrease")
!^+Up::Komorebic("resize-axis vertical increase")
!^+Down::Komorebic("resize-axis vertical decrease")
		
; Stack windows
#Right::Komorebic("cycle-stack next")
#Left::Komorebic("cycle-stack previous")

; Move stacked windows
+#Up::Komorebic("stack-all")
+#Down::Komorebic("unstack")

+#Left::Komorebic("cycle-stack-index previous")
+#Right::Komorebic("cycle-stack-index next")

; Normal focus
#Home::Komorebic("focus left") 
#End::Komorebic("focus right")

#PgUp::Komorebic("cycle-workspace next")
#PgDn::Komorebic("cycle-workspace previous")

; Manipulate windows
#Tab::Komorebic("toggle-float")
#s::Komorebic("toggle-workspace-layer") 
#t::Komorebic("toggle-tiling") 
#f::Komorebic("toggle-monocle")
#w::Komorebic("close")
#y::Komorebic("toggle-lock")


; Window manager options
#p::Komorebic("toggle-pause")
#u::Komorebic("unmanage")
#m::Komorebic("manage")
#b::Komorebic("focus-last-workspace")


#1:: {
Komorebic("focus-workspace 0")
}

#2:: { 
Komorebic("focus-workspace 1")
}

#3:: {
Komorebic("focus-workspace 2")
}

#4:: {
Komorebic("focus-workspace 3")
}

#5:: {
	Komorebic("focus-workspace 4")
}

#6:: {
Komorebic("focus-workspace 5")
}

#7:: {
	Komorebic("focus-workspace 6")
}

; Move windows across workspaces
; Monitor
+#1:: {
     Komorebic("move-to-workspace 0")
}

+#2:: {
    Komorebic("move-to-workspace 1")
}

+#3:: {
    Komorebic("move-to-workspace 2")
}

+#4:: {
    Komorebic("move-to-workspace 3")
}

+#5:: {
    Komorebic("move-to-workspace 4")
}

+#6:: {
    Komorebic("move-to-workspace 5")
}

+#7:: {
    Komorebic("move-to-workspace 6")
}