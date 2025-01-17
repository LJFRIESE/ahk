#Requires AutoHotkey v2.0
#SingleInstance
#Warn

; Global variables
global doubleTapTimeout := 400  ; ms
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
            tooltipStr .= "+ " . option
            endKeys .= option
            menuFunctionsDict[option] := option
        } else {
            tooltipStr .= "+ " . option[1] . " => " . option[2]
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
    menuFunc := "Menu_" . menuFunctionsDict[choice]

    if toSend {
        SendInput(toSend)
    } else {
        try {
            funcObj := %menuFunc%
            if funcObj is Func
                funcObj()
        }
    }

    return choice
}

; === The Leader Hotkey (Double-tap Space) ===
~Space:: {
    global lastSpacePress, doubleTapTimeout
    timeNow := A_TickCount
    if (timeNow - lastSpacePress < doubleTapTimeout) {
        ; Double-tap detected
        WaitForChoice("Macros"
            , ["t", "Tests"]
            , ["w", "Windows"]
            , ["m", "Mails"])
        lastSpacePress := 0  ; Reset the timer
    } else {
        lastSpacePress := timeNow
    }
}

; === Menu functions ===
Menu_Tests() {
    choice := WaitForChoice("t (Tests)", "1", "2")
    switch choice {
        case "1": SendInput("Test text 1")
        case "2": SendInput("Test text 2")
    }
}

Menu_Windows() {
    choice := WaitForChoice("w (Window)", ["max", "Maximize"], ["r", "Restore"])
    switch choice {
        case "max": WinMaximize("A")
        case "r": WinRestore("A")
    }
}

Menu_Mails() {
    WaitForChoice("m (Mails)"
        , ["p", "Pro", "pro@mail.com"]
        , ["h", "Hobby", "hobby@mail.com"])
}
