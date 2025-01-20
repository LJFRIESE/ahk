#Requires AutoHotkey v2.0
#SingleInstance
#Warn

; Global variables
global doubleTapTimeout := 250  ; ms
global lastSpacePress := 0

; === The Helper function ===
WaitForChoice(name, options*) {
    ; === Building the Tooltip string, EndKeys parameter, and choices dictionary (for Menu functions) ===
    tooltipStr := name . "`n"
    menuFunctionsDict := Map()
    sendInputDict := Map()
    endKeys := ""
    
    for index, option in options {
        if Type(option) = "String" {
            tooltipStr .= option
            endKeys .= option
            menuFunctionsDict[option] := option
        } else {
            tooltipStr .=  option[1] . ": " . option[2]
            endKeys .= option[1]
            menuFunctionsDict[option[1]] := option[2]
            if option.Length >= 3
                sendInputDict[option[1]] := option[3]
        }
        if index < options.Length
            tooltipStr .= "`n"
        endKeys .= ","
    }

    ; === Tooltip + Wait for input ===
    ToolTip(tooltipStr)
    ih := InputHook("L1", "{Pause}{Esc}{Enter}", endKeys)
    ih.Start()
    ih.Wait()
    ToolTip()
    
    if ih.EndReason = "EndKey" && ih.EndKey = "Escape"
        return

    choice := ih.Input
    if !menuFunctionsDict.Has(choice)
        return

    toSend := sendInputDict.Has(choice) ? sendInputDict[choice] : ""
    menuChoice := menuFunctionsDict[choice]

    if toSend {
        SendInput(toSend)
    } else {
        ; Call the menu function directly based on the choice
        Menu_%menuChoice%()
    }
    return choice
}

; === Menu functions ===
; 3rd option triggers send. If only 2 options, it goes to new submenu
Menu_Config() {
    choice := WaitForChoice("[C]onfig", 
        ["1", "Run runOpenWithConfigurator",true], 
        ["2", "test", true])
    
    switch choice {
        case "1": 
            #Include openWith.ahk 
            runOpenWithConfigurator()
        case "2": 
            SendInput("Test text 2")
    }
}

Menu_Windows() {
    choice := WaitForChoice("w (Window)", 
        ["max", "Maximize"], 
        ["r", "Restore"])
    
    switch choice {
        case "max": WinMaximize("A")
        case "r": WinRestore("A")
    }
}

Menu_Mails() {
    WaitForChoice("m (Mails)",
        ["p", "Pro", "pro@mail.com"],
        ["h", "Hobby", "hobby@mail.com"])
}

; === The Leader Hotkey  ===
TurnOffCapsLock() {
    SetCapsLockState "Off"
}

~!Space:: {
    SetCapsLockState "On"
    SetTimer(TurnOffCapsLock, -1500)  ; Negative value means run only once
}

#HotIf GetKeyState("CapsLock", "T")
Space:: {
    WaitForChoice("Macros",
        ["c", "Config"],
        ["w", "Windows"],
        ["m", "Mails"])
}
#HotIf
