#Requires AutoHotkey v2.0
#SingleInstance force
#Warn
#NoTrayIcon
/*
 Function Documentation: http://ahkscript.org/docs/Functions.htm

 Examples:

 Add(x, y)
 {
     return x + y
 }

 Add(2, 3) ; Simply calls the function
 MyNumber := Add(2, 3) ; Stores the value

*/

Edit(file)
{
	global
    Run A_ComSpec "vscode " . file
}

FlashMessage(msg){
MsgBox msg, "AHK Reload", "T2"
}