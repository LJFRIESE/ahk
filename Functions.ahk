#Requires AutoHotkey v2.0
#SingleInstance
#Warn
#NoTrayIcon

; Utility function
Join(arr, delimiter := ",") {
    result := ""
    for index, value in arr {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

; Create GUI for status popup
class ScriptStatusGui {
    static Show(message, duration := 2000) {
        statusGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        statusGui.SetFont("s10", "Segoe UI")
        statusGui.Add("Text",, message)
        statusGui.BackColor := "F0F0F0"
        
        ; Position at bottom right of primary monitor
        MonitorGetWorkArea(1, &left, &top, &right, &bottom)
        statusGui.Show("NoActivate x" . (right - 300) . " y" . (bottom - 100) . " w280")
        
        SetTimer(() => statusGui.Destroy(), -duration)
    }
}
