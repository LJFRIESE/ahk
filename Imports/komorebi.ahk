#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Resize
!Right::Komorebic("resize-axis horizontal increase")
!Left::Komorebic("resize-axis horizontal decrease")
!Up::Komorebic("resize-axis vertical increase")
!Down::Komorebic("resize-axis vertical decrease")
		
; Gui : Focus
#Left::Komorebic("focus left")
#Right::Komorebic("focus right")

#Up::Komorebic("cycle-workspace next")
#Down::Komorebic("cycle-workspace previous")

; Shift + Gui : Move
+#Left::Komorebic("cycle-move-to-monitor previous")
+#Right::Komorebic("cycle-move-to-monitor next")

#+Up::Komorebic("cycle-move-to-workspace next")
#+Down::Komorebic("cycle-move-to-workspace previous")


+!^Up::Komorebic("stack-all")
+!^Down::Komorebic("unstack-all")
+!^Left::Komorebic("cycle-stack previous")
+!^Right::Komorebic("cycle-stack next")

; Manipulate windows
#t::Komorebic("toggle-float")
#Tab::Komorebic("toggle-workspace-layer")

#s::Komorebic("focus-workspace 7")
+#s:: {
    Komorebic("move-to-workspace 7")
}

#f::Komorebic("toggle-monocle")
#w::Komorebic("close")

; Window manager options
#p::Komorebic("toggle-pause")

#m::Komorebic("manage")
#+m::Komorebic("unmanage")

#b::Komorebic("focus-last-workspace")

#1::Komorebic("focus-workspace 0")
#2::Komorebic("focus-workspace 1")
#3::Komorebic("focus-workspace 2")
#4::Komorebic("focus-workspace 3")
#5::Komorebic("focus-workspace 4")
#6::Komorebic("focus-workspace 5")
#7::Komorebic("focus-workspace 7")


; Move windows across workspaces
; Monitor
+#1::Komorebic("move-to-workspace 0")
+#2::Komorebic("move-to-workspace 1")
+#3::Komorebic("move-to-workspace 2")
+#4::Komorebic("move-to-workspace 3")
+#5::Komorebic("move-to-workspace 4")
+#6::Komorebic("move-to-workspace 5")
#+7::Komorebic("send-to-workspace 7")

#NumPad1::Komorebic("focus-workspace 0")
#NumPad2::Komorebic("focus-workspace 1")
#NumPad3::Komorebic("focus-workspace 2")
#NumPad4::Komorebic("focus-workspace 3")
#NumPad5::Komorebic("focus-workspace 4")
#NumPad6::Komorebic("focus-workspace 5")
#NumPad7::Komorebic("focus-workspace 7")


; Move windows across workspaces•
; Monitor
+#NumPad1::Komorebic("move-to-workspace 0")
+#NumPad2::Komorebic("move-to-workspace 1")
+#NumPad3::Komorebic("move-to-workspace 2")
+#NumPad4::Komorebic("move-to-workspace 3")
+#NumPad5::Komorebic("move-to-workspace 4")
+#NumPad6::Komorebic("move-to-workspace 5")
#+NumPad7::Komorebic("send-to-workspace 7")

