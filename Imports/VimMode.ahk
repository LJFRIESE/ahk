global gVimMode := false
global gVimNormal := true
global gVimVisual := false
global gVimOp := ""
global gVimMod := ""
global gVimFind := ""
global gVimFindKind := ""
global gVimFindChar := ""
global gVimAwait := ""
global gVimRec := ""
global gVimMacros := Map()
global gVimLastMacro := ""
global gVimPlaying := false
global gVimLastEsc := 0
global gActionMenuDepth := 0

class VimMode {
	static InsHook := false

	static Active() {
		return gVimMode && gVimNormal && !gActionMenuDepth && !WinActive("ahk_exe WindowsTerminal.exe")
	}

	static InsertActive() {
		return gVimMode && !gVimNormal && !gActionMenuDepth && !WinActive("ahk_exe WindowsTerminal.exe")
	}

	static Host() {
		if WinActive("ahk_exe excel.exe")
			return "excel"
		if WinActive("ahk_exe winword.exe") || WinActive("ahk_class _WwG")
			return "word"
		if WinActive("ahk_exe notepad++.exe")
			return "npp"
		return "text"
	}

	static Toggle() {
		global gVimMode, gVimNormal, gVimVisual, gVimOp, gVimMod, gVimFind, gVimAwait, gVimRec, gVimLastEsc
		gVimMode := !gVimMode
		gVimNormal := true
		gVimVisual := false
		gVimOp := ""
		gVimMod := ""
		gVimFind := ""
		gVimAwait := ""
		gVimRec := ""
		gVimLastEsc := 0
		this.StopInsHook()
		this.Status()
	}

	static Insert() {
		global gVimNormal, gVimVisual, gVimOp, gVimMod
		gVimNormal := false
		gVimVisual := false
		gVimOp := ""
		gVimMod := ""
		this.Status()
		this.StartInsHook()
	}

	static Normal() {
		global gVimNormal, gVimVisual, gVimOp, gVimMod
		this.StopInsHook()
		gVimNormal := true
		gVimVisual := false
		gVimOp := ""
		gVimMod := ""
		this.Status()
	}

	static Visual() {
		global gVimVisual, gVimOp, gVimMod
		gVimVisual := true
		gVimOp := ""
		gVimMod := ""
		Send("{Shift down}{Right}{Shift up}")
		this.Status()
	}

	static VisualLine() {
		global gVimVisual, gVimOp, gVimMod
		gVimVisual := true
		gVimOp := ""
		gVimMod := ""
		this.SelectLine()
		this.Status()
	}

	static CancelOp() {
		global gVimOp, gVimMod
		gVimOp := ""
		gVimMod := ""
	}

	static HandleEsc() {
		global gVimLastEsc, gVimMode, gVimNormal, gVimVisual, gVimFind, gVimAwait
		if gVimMode && (A_TickCount - gVimLastEsc < 400) {
			gVimLastEsc := 0
			if gVimMode
				this.Toggle()
			return
		}
		gVimLastEsc := A_TickCount
		if !gVimNormal {
			this.RecPush("Esc")
			if this.Host() = "excel"
				Send("^{Enter}")
			this.Normal()
			return
		}
		if gVimFind != "" || gVimAwait != "" {
			gVimFind := ""
			gVimAwait := ""
			this.CancelOp()
			return
		}
		if gVimVisual {
			Send(this.Host() = "excel" ? "{Esc}" : "{Right}")
			this.Normal()
			return
		}
		this.CancelOp()
	}

	static Status() {
		global gVimMode, gVimNormal, gVimVisual, gVimRec
		msg := !gVimMode ? "Vim OFF" : (!gVimNormal ? "Vim INSERT" : (gVimVisual ? "Vim VISUAL" : "Vim NORMAL"))
		if gVimRec != ""
			msg .= " REC " gVimRec
		g := ScriptStatusGui(msg)
		SetTimer(() => g.Destroy(), -1500)
	}

	static Paste() {
		Send("^v")
	}

	static Undo() {
		Send("^z")
	}

	static Redo() {
		Send("^y")
	}

	static RecPush(k) {
		global gVimRec, gVimPlaying, gVimMacros
		if gVimPlaying || gVimRec = ""
			return
		gVimMacros[gVimRec].Push(k)
	}

	static RecStart(reg) {
		global gVimRec, gVimMacros
		gVimRec := reg
		gVimMacros[reg] := []
		this.Status()
	}

	static RecStop() {
		global gVimRec, gVimLastMacro
		gVimLastMacro := gVimRec
		gVimRec := ""
		this.StopInsHook()
		this.Status()
	}

	static StartInsHook() {
		global gVimRec, gVimPlaying
		this.StopInsHook()
		if gVimRec = "" || gVimPlaying
			return
		ih := InputHook("V")
		ih.OnChar := (ih, ch) => VimMode.RecPush(ch)
		ih.OnKeyDown := (ih, vk, sc) => VimMode.OnInsKey(vk)
		ih.Start()
		this.InsHook := ih
	}

	static StopInsHook() {
		if this.InsHook {
			try this.InsHook.Stop()
			this.InsHook := false
		}
	}

	static OnInsKey(vk) {
		switch vk {
			case 8:
				this.RecPush("BS")
			case 9:
				this.RecPush("Tab")
			case 13:
				this.RecPush("Enter")
		}
	}

	static Play(reg) {
		global gVimMacros, gVimLastMacro, gVimPlaying
		if reg = "" || !gVimMacros.Has(reg) || gVimPlaying
			return
		gVimLastMacro := reg
		gVimPlaying := true
		try {
			for k in gVimMacros[reg]
				this.PlayKey(k)
		} finally {
			gVimPlaying := false
		}
	}

	static PlayKey(k) {
		global gVimNormal
		if !gVimNormal {
			switch k {
				case "Esc":
					this.HandleEsc()
				case "BS":
					Send("{BS}")
				case "Tab":
					Send("{Tab}")
				case "Enter":
					Send("{Enter}")
				default:
					SendText(k)
			}
			return
		}
		this.NormalKey(k)
	}

	static HotToChar(hk) {
		static shifted := Map(
			"1", "!", "2", "@", "3", "#", "4", "$", "5", "%",
			"6", "^", "7", "&", "8", "*", "9", "(", "0", ")",
			"-", "_", "=", "+", "[", "{", "]", "}", "\", "|",
			";", ":", "'", '"', ",", "<", ".", ">", "/", "?",
			"``", "~")
		switch hk {
			case "Space":
				return " "
			case "Tab":
				return "`t"
			case "Enter":
				return "`n"
			case "`;":
				return ";"
			case "``":
				return "``"
		}
		if SubStr(hk, 1, 1) = "+" && StrLen(hk) >= 2 {
			rest := SubStr(hk, 2)
			if rest = "`;"
				rest := ";"
			if shifted.Has(rest)
				return shifted[rest]
			if StrLen(rest) = 1
				return StrUpper(rest)
		}
		return hk
	}

	static Swallow(hk) {
		global gVimFind, gVimAwait
		if gVimFind = "" && gVimAwait = ""
			return
		this.NormalKey(this.HotToChar(hk))
	}

	static IsFind(key) {
		switch key {
			case "f", "F", "t", "T":
				return true
		}
		return false
	}

	static FlipFind(kind) {
		switch kind {
			case "f":
				return "F"
			case "F":
				return "f"
			case "t":
				return "T"
			case "T":
				return "t"
		}
		return kind
	}

	static DoFind(kind, char, save := true) {
		global gVimOp, gVimFindKind, gVimFindChar, gVimVisual
		if save {
			gVimFindKind := kind
			gVimFindChar := char
		}
		vis := gVimVisual || gVimOp != ""
		this.FindChar(kind, char, vis)
		if gVimOp != "" && !gVimVisual {
			op := gVimOp
			this.CancelOp()
			this.DoOp(op)
		}
	}

	static RepeatFind(rev) {
		global gVimFindKind, gVimFindChar
		if gVimFindChar = ""
			return
		kind := rev ? this.FlipFind(gVimFindKind) : gVimFindKind
		this.DoFind(kind, gVimFindChar, false)
	}

	static FindChar(kind, char, vis) {
		if char = "" || this.Host() = "excel"
			return
		fwd := (kind = "f" || kind = "t")
		till := (kind = "t" || kind = "T")
		host := this.Host()
		if host = "npp"
			this.NppFind(char, fwd, till, vis)
		else if host = "word"
			this.WordFind(char, fwd, till, vis)
		else
			this.TextFind(char, fwd, till, vis)
	}

	static NppCtrl() {
		return ControlGetFocus("A")
	}

	static NppMsg(msg, w := 0, l := 0) {
		return SendMessage(msg, w, l, this.NppCtrl(), "A")
	}

	static NppFind(char, fwd, till, vis) {
		try {
			pos := this.NppMsg(2008)
			line := this.NppMsg(2166, pos)
			start := this.NppMsg(2167, line)
			end := this.NppMsg(2136, line)
			code := Ord(char)
			found := -1
			if fwd {
				i := pos + 1
				while i < end {
					if this.NppMsg(2007, i) = code {
						found := i
						break
					}
					i++
				}
			} else {
				i := pos - 1
				while i >= start {
					if this.NppMsg(2007, i) = code {
						found := i
						break
					}
					i--
				}
			}
			if found < 0
				return
			dest := found
			if till
				dest := fwd ? found - 1 : found + 1
			if dest = pos
				return
			if dest < start || dest > end
				return
			if vis {
				anchor := this.NppMsg(2009)
				this.NppMsg(2160, anchor, dest)
			} else
				this.NppMsg(2025, dest)
		} catch {
			this.TextFind(char, fwd, till, vis)
		}
	}

	static WordFind(char, fwd, till, vis) {
		try wd := ComObjActive("Word.Application")
		catch {
			this.TextFind(char, fwd, till, vis)
			return
		}
		try {
			sel := wd.Selection
			orig := sel.Start
			line := sel.Range.Duplicate
			line.Expand(5)
			lineStart := line.Start
			lineEnd := line.End
			if fwd {
				if orig >= lineEnd - 1
					return
				sel.SetRange(orig + 1, orig + 1)
			} else {
				if orig <= lineStart
					return
				sel.SetRange(orig - 1, orig - 1)
			}
			f := sel.Find
			f.ClearFormatting
			f.Text := char
			f.Forward := fwd
			f.Wrap := 0
			f.MatchCase := true
			f.MatchWildcards := false
			if !f.Execute() {
				sel.SetRange(orig, orig)
				return
			}
			if (fwd && sel.Start >= lineEnd) || (!fwd && sel.Start < lineStart) {
				sel.SetRange(orig, orig)
				return
			}
			dest := sel.Start
			if till
				dest := fwd ? dest - 1 : sel.End
			if dest = orig
				return
			if vis
				sel.SetRange(orig, dest)
			else
				sel.SetRange(dest, dest)
		} catch {
			this.TextFind(char, fwd, till, vis)
		}
	}

	static TextFind(char, fwd, till, vis) {
		Send("{Blind}{Shift up}{Ctrl up}{Alt up}")
		clip := ClipboardAll()
		A_Clipboard := ""
		try {
			Send(fwd ? "+{End}" : "+{Home}")
			Send("^c")
			if !ClipWait(0.2) {
				Send(fwd ? "{Left}" : "{Right}")
				return
			}
			text := A_Clipboard
			Send(fwd ? "{Left}" : "{Right}")
			if text = ""
				return
			found := 0
			if fwd {
				found := InStr(text, char, true, 2)
			} else {
				pos := 0
				loop {
					p := InStr(text, char, true, pos + 1)
					if !p
						break
					found := p
					pos := p
				}
			}
			if !found
				return
			if fwd
				steps := till ? found - 2 : found - 1
			else
				steps := till ? StrLen(text) - found : StrLen(text) - found + 1
			if steps <= 0
				return
			dir := fwd ? "Right" : "Left"
			if vis {
				Send("{Shift down}")
				try Send("{" dir " " steps "}")
				finally Send("{Shift up}")
			} else {
				Send("{" dir " " steps "}")
			}
		} finally {
			A_Clipboard := clip
		}
	}

	static IsMotion(key) {
		switch key {
			case "h", "j", "k", "l", "w", "W", "b", "B", "e", "E":
				return true
			case "0", "$", "^", "_", "G", "{", "}", "+", "-":
				return true
		}
		return false
	}

	static SendNav(seq, vis := false) {
		if vis
			Send("{Blind}{Shift down}" seq "{Shift up}")
		else
			Send("{Blind}{Shift up}{Ctrl up}{Alt up}" seq)
	}

	static NppPara(down, vis) {
		if !vis
			Send("{Blind}{Shift up}{Ctrl up}{Alt up}")
		msg := down ? (vis ? 2419 : 2418) : (vis ? 2417 : 2416)
		try {
			this.NppMsg(msg)
		} catch {
			this.SendNav(down ? "^{Down}" : "^{Up}", vis)
		}
	}

	static Move(key, vis := unset) {
		global gVimVisual
		if !IsSet(vis)
			vis := gVimVisual
		host := this.Host()
		switch key {
			case "h":
				this.SendNav("{Left}", vis)
			case "j":
				this.SendNav("{Down}", vis)
			case "k":
				this.SendNav("{Up}", vis)
			case "l":
				this.SendNav("{Right}", vis)
			case "w", "W":
				this.SendNav("^{Right}", vis)
			case "b", "B":
				this.SendNav("^{Left}", vis)
			case "e", "E":
				if vis || host = "excel"
					this.SendNav("^{Right}", vis)
				else
					this.SendNav("^{Right}{Left}")
			case "0":
				if host = "npp"
					this.SendNav("{Home}{Home}", vis)
				else
					this.SendNav("{Home}", vis)
			case "^", "_":
				this.SendNav("{Home}", vis)
			case "$":
				if host = "excel"
					this.SendNav(vis ? "^{Right}" : "{End}{Right}", vis)
				else
					this.SendNav("{End}", vis)
			case "gg":
				this.SendNav("^{Home}", vis)
			case "G":
				this.SendNav("^{End}", vis)
			case "{":
				if host = "npp"
					this.NppPara(false, vis)
				else
					this.SendNav("^{Up}", vis)
			case "}":
				if host = "npp"
					this.NppPara(true, vis)
				else
					this.SendNav("^{Down}", vis)
			case "-":
				if vis
					this.SendNav("{Up}", true)
				else
					this.SendNav("{Up}{Home}")
			case "+":
				if vis
					this.SendNav("{Down}", true)
				else
					this.SendNav("{Down}{Home}")
		}
	}

	static Select(obj) {
		switch obj {
			case "iw":
				Send("^{Left}^+{Right}")
			case "aw":
				Send("^{Left}^+{Right}{Shift down}{Right}{Shift up}")
			case "ip":
				Send("^{Up}^+{Down}")
			case "ap":
				Send("^{Up}{Up}^+{Down}{Down}")
			default:
				return false
		}
		return true
	}

	static SelectLine() {
		if this.Host() = "excel"
			Send("+{Space}")
		else
			Send("{Home}+{Down}")
	}

	static DoOp(op) {
		switch op {
			case "d":
				Send("^x")
			case "y":
				Send("^c{Right}")
			case "c":
				Send("^x")
				this.Insert()
			case ">":
				Send("{Tab}")
			case "<":
				Send("+{Tab}")
		}
	}

	static LineOp(op) {
		this.SelectLine()
		switch op {
			case "d":
				Send("^x")
			case "y":
				Send("^c")
				if this.Host() = "excel"
					Send("{Esc}")
				else
					Send("{Home}")
			case "c":
				Send("^x")
				this.Insert()
			case ">":
				Send("{Tab}")
			case "<":
				Send("+{Tab}")
		}
	}

	static RunOp(op, obj) {
		if !this.Select(obj)
			return
		this.DoOp(op)
	}

	static EnterInsert(kind) {
		host := this.Host()
		switch kind {
			case "i":
				if host = "excel"
					Send("{F2}")
			case "a":
				if host = "excel"
					Send("{F2}{End}")
				else
					Send("{Right}")
			case "I":
				if host = "excel"
					Send("{F2}{Home}")
				else
					Send("{Home}")
			case "A":
				if host = "excel"
					Send("{F2}{End}")
				else
					Send("{End}")
			case "o":
				if host = "excel"
					Send("{Down}{F2}")
				else
					Send("{End}{Enter}")
			case "O":
				if host = "excel"
					Send("{Up}{F2}")
				else
					Send("{Home}{Enter}{Up}")
			case "s":
				if host = "excel"
					Send("{F2}+{End}{Delete}")
				else
					Send("+{Right}^x")
			case "S":
				this.SelectLine()
				Send("^x")
		}
		this.Insert()
	}

	static VisualKey(key) {
		global gVimMod, gVimOp, gVimFind
		if gVimOp = "g" {
			if key = "g"
				this.Move("gg")
			this.CancelOp()
			return
		}
		if gVimMod != "" {
			obj := gVimMod . key
			gVimMod := ""
			this.Select(obj)
			return
		}
		switch key {
			case "i", "a":
				gVimMod := key
			case "d", "x":
				this.DoOp("d")
			case "y":
				Send("^c")
			case "c", "s", "S":
				this.DoOp("c")
			case "C":
				this.Move("$", true)
				this.DoOp("c")
			case "I", "A", "o", "O":
				this.EnterInsert(key)
			case "p", "P":
				this.Paste()
			case "u":
				this.Undo()
			case "U":
				this.Redo()
			case "v":
				Send(this.Host() = "excel" ? "{Esc}" : "{Right}")
				this.Normal()
			case "V":
				this.SelectLine()
			case "g":
				gVimOp := "g"
			case "J":
				if this.Host() != "excel"
					Send("{End}{Delete}")
			case "D":
				this.Move("$", true)
				this.DoOp("d")
			case ">":
				Send("{Tab}")
			case "<":
				Send("+{Tab}")
			case "f", "F", "t", "T":
				gVimFind := key
			case ";":
				this.RepeatFind(false)
			case ",":
				this.RepeatFind(true)
			default:
				if this.IsMotion(key)
					this.Move(key)
		}
	}

	static NormalKey(key) {
		global gVimOp, gVimMod, gVimVisual, gVimFind, gVimAwait, gVimRec, gVimLastMacro
		if gVimFind != "" {
			this.RecPush(key)
			kind := gVimFind
			gVimFind := ""
			this.DoFind(kind, key)
			return
		}
		if gVimAwait = "q" {
			gVimAwait := ""
			if StrLen(key) = 1 && (key ~= "^[a-zA-Z]$")
				this.RecStart(StrLower(key))
			return
		}
		if gVimAwait = "@" {
			gVimAwait := ""
			if key = "@"
				this.Play(gVimLastMacro)
			else if StrLen(key) = 1 && (key ~= "^[a-zA-Z]$")
				this.Play(StrLower(key))
			return
		}
		if key = "q" {
			if gVimRec != ""
				this.RecStop()
			else
				gVimAwait := "q"
			return
		}
		if key = "@" {
			if gVimRec = ""
				gVimAwait := "@"
			return
		}
		this.RecPush(key)
		if gVimVisual {
			this.VisualKey(key)
			return
		}
		if gVimOp = "" {
			if this.IsMotion(key) {
				this.Move(key)
				return
			}
			switch key {
				case "d", "y", "c", ">", "<":
					gVimOp := key
					gVimMod := ""
				case "g":
					gVimOp := "g"
				case "f", "F", "t", "T":
					gVimFind := key
				case ";":
					this.RepeatFind(false)
				case ",":
					this.RepeatFind(true)
				case "v":
					this.Visual()
				case "V":
					this.VisualLine()
				case "p", "P":
					this.Paste()
				case "i", "a", "I", "A", "o", "O", "s", "S":
					this.EnterInsert(key)
				case "u":
					this.Undo()
				case "U":
					this.Redo()
				case "x":
					if this.Host() = "excel"
						Send("{Delete}")
					else
						Send("+{Right}^x")
				case "X":
					if this.Host() = "excel"
						Send("{Left}{Delete}")
					else
						Send("+{Left}^x")
				case "D":
					this.Move("$", true)
					this.DoOp("d")
				case "C":
					this.Move("$", true)
					this.DoOp("c")
				case "J":
					if this.Host() != "excel"
						Send("{End}{Delete}")
			}
			return
		}
		if gVimOp = "g" {
			if key = "g"
				this.Move("gg")
			this.CancelOp()
			return
		}
		if (gVimOp = "d" || gVimOp = "y" || gVimOp = "c" || gVimOp = ">" || gVimOp = "<") && key = gVimOp {
			op := gVimOp
			this.CancelOp()
			this.LineOp(op)
			return
		}
		if gVimMod = "" {
			if key = "i" || key = "a" {
				gVimMod := key
				return
			}
			if this.IsFind(key) {
				gVimFind := key
				return
			}
			if this.IsMotion(key) {
				op := gVimOp
				this.CancelOp()
				this.Move(key, true)
				this.DoOp(op)
				return
			}
			this.CancelOp()
			return
		}
		obj := gVimMod . key
		op := gVimOp
		this.CancelOp()
		this.RunOp(op, obj)
	}
}

#HotIf VimMode.Active()
a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
m::
n::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::
{
	VimMode.NormalKey(ThisHotkey)
}
+a::
+b::
+c::
+d::
+e::
+f::
+g::
+h::
+i::
+j::
+k::
+l::
+m::
+n::
+o::
+p::
+q::
+r::
+s::
+t::
+u::
+v::
+w::
+x::
+y::
+z::
{
	VimMode.NormalKey(StrUpper(SubStr(ThisHotkey, 2)))
}
0:: VimMode.NormalKey("0")
-:: VimMode.NormalKey("-")
+-:: VimMode.NormalKey("_")
+4:: VimMode.NormalKey("$")
+6:: VimMode.NormalKey("^")
+=:: VimMode.NormalKey("+")
+.:: VimMode.NormalKey(">")
+,:: VimMode.NormalKey("<")
+[:: VimMode.NormalKey("{")
+]:: VimMode.NormalKey("}")
+2:: VimMode.NormalKey("@")
`;:: VimMode.NormalKey(";")
,:: VimMode.NormalKey(",")
Esc:: VimMode.HandleEsc()
1::
2::
3::
4::
5::
6::
7::
8::
9::
=::
[::
]::
\::
'::
.::
/::
`::
+1::
+3::
+5::
+7::
+8::
+9::
+0::
+;::
+'::
+/::
+\::
+`::
Space::
Tab::
Enter::
BS::
Delete::
{
	VimMode.Swallow(ThisHotkey)
}
#HotIf

#HotIf VimMode.InsertActive()
Esc:: VimMode.HandleEsc()
#HotIf
