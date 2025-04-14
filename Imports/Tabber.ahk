; Show tooltip with class info and window titles
; The gui setup needs to be fixed. It just works without a gui atm.
class Tabber {
    ; Global variables
    static currentWindowIndex := Map()
    static windows := Map()
	static winClassList := []
	;static gui := ScriptStatusGui(" ", "cursor", false)

    static ShowInfo(currentClass) {
		this.gui.Text := ""
		text := ""
		
        ; Build tooltip text
        for _class in this.windows {
            hwndList := this.windows[_class]
            if (_class = currentClass) {
                text .= ">> " _class " [" hwndList.Length "]`n"
                ; Show titles for current class
                for hwnd in hwndList {
                    active := false
                    title := WinGetTitle(hwnd)
                    if (title = WinGetTitle("A"))
                        active := true
                    if StrLen(title) > 60
                        title := SubStr(title, 1, 57) . "..."
                    if active
                        text .= "      → " title "`n"
                    else
                        text .= "          " title "`n"
                }
            } else {
                text .= "      " _class " [" hwndList.Length "]`n"
            }
        }
		
		this.gui.Add("Text",, text)
		CoordMode "Mouse", "Screen"
        MouseGetPos(&xpos, &ypos)
		this.gui.Show(" x" . xpos . " y" . ypos . " w450")
		
		SetTimer(() => this.gui.Hide(), 2000)
    }


    ; Get windows grouped by class
    static GetWindowsByClass() { 
		;winClasses := WinGetList()
		;if this.winClassList == winClasses {
		;	SoundBeep()
		;	return
		;} else {
		;	this.winClassList := winClasses.Clone()
		;}
		
		this.winClassList := WinGetList()
		
		this.windows := Map()
		
        for hwnd in this.winClassList {
            ; Skip AutoHotkey windows
            procName := WinGetProcessName(hwnd)
            if (procName = "AutoHotkey64.exe") {
                continue
			}
			
			; Skip if no title
            ; Nil = irrelevant, the other two are temp windows related to the setting of the popup itself
            title := WinGetTitle(hwnd)
			if  (!title || title = "Program Manager" || title = "PopupHost" || title = "Zebar - config/glazewm" || title = "com.glzr.zebar-siw") {
                continue
			}				

            ; initialize a blank string instead of array
            if !this.windows.Has(procName)
               this.windows[procName] := ''

            ; hwnd is no longer an Integer, so it needs winTitle criteria
            ; newline is the default delimiter for Sort
            this.windows[procName] .= 'ahk_id ' . hwnd . '`n'
        }
        ; sort the strings, trim the final newline, and split into array
        for procName, hwnds in this.windows {
            this.windows[procName] := StrSplit(Trim(Sort(hwnds),'`n'), '`n')
        }
		    
    }

    ; Cycle between classes
    static CycleClasses(direction) {
		this.GetWindowsByClass()

        ; Get sorted list of classes
        classes := []
        for _class in this.windows {
            classes.Push(_class)
        }

        ; Find current class index
        currentClass := WinGetProcessName("A")
        currentIdx := 1
        for i, _class in classes {
            if (_class = currentClass) {
                currentIdx := i
                break
            }
        }

        ; Calculate next class
        if (direction = "next")
            nextIdx := currentIdx = classes.Length ? 1 : currentIdx + 1
        else
            nextIdx := currentIdx = 1 ? classes.Length : currentIdx - 1

        ; Switch to first window of next class
        nextClass := classes[nextIdx]
        WinActivate this.windows[nextClass][1]
        ;this.ShowInfo(nextClass)
    }

    ; Cycle windows within current class
    static CycleWindows(direction) {
        currentClass := WinGetProcessName("A")
        if !this.windows.Has(currentClass)
            return

        if !this.currentWindowIndex.Has(currentClass)
            this.currentWindowIndex[currentClass] := 1

        classWindows := this.windows[currentClass]
        currentIdx := this.currentWindowIndex[currentClass]

        if (direction = "next")
            this.currentWindowIndex[currentClass] := currentIdx = classWindows.Length ? 1 : currentIdx + 1
        else
            this.currentWindowIndex[currentClass] := currentIdx = 1 ? classWindows.Length : currentIdx - 1

        WinActivate classWindows[this.currentWindowIndex[currentClass]]
        ;this.ShowInfo(currentClass)
    }
}
