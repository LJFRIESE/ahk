#NoTrayIcon
#SingleInstance Force

; Using Keyboard Numpad as a Mouse (based on the v1 script by deguix)
; https://www.autohotkey.com
; This script makes mousing with your keyboard almost as easy
; as using a real mouse (maybe even easier for some tasks).
; It supports up to five mouse buttons and the turning of the
; mouse wheel.  It also features customizable movement speed,
; acceleration, and "axis inversion".

/*
o------------------------------------------------------------o
|Using Keyboard Numpad as a Mouse                            |
(------------------------------------------------------------)
|                     / A Script file for AutoHotkey         |
|                    ----------------------------------------|
|                                                            |
|    This script is an example of use of AutoHotkey. It uses |
| the remapping of numpad keys of a keyboard to transform it |
| into a mouse. Some features are the acceleration which     |
| enables you to increase the mouse movement when holding    |
| a key for a long time, and the rotation which makes the    |
| numpad mouse to "turn". I.e. NumpadDown as NumpadUp        |
| and vice-versa. See the list of keys used below:           |
|                                                            |
|------------------------------------------------------------|
| Keys                  | Description                        |
|------------------------------------------------------------|
| ScrollLock (toggle on)| Activates numpad mouse mode.       |
|-----------------------|------------------------------------|
| Numpad0               | Left mouse button click.           |
| Numpad5               | Middle mouse button click.         |
| NumpadDot             | Right mouse button click.          |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click.          |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.     |
|                       |                                    |
|-----------------------|------------------------------------|
| NumLock (toggled off) | Activates mouse movement mode.     |
|-----------------------|------------------------------------|
| NumpadEnd/Down/PgDn/  | Mouse movement.                    |
| /Left/Right/Home/Up/  |                                    |
| /PgUp                 |                                    |
|                       |                                    |
|-----------------------|------------------------------------|
| NumLock (toggled on)  | Activates mouse speed adj. mode.   |
|-----------------------|------------------------------------|
| Numpad7/Numpad1       | Inc./dec. acceleration per         |
|                       | button press.                      |
| Numpad8/Numpad2       | Inc./dec. initial speed per        |
|                       | button press.                      |
| Numpad9/Numpad3       | Inc./dec. maximum speed per        |
|                       | button press.                      |
| !Numpad7/!Numpad1     | Inc./dec. wheel acceleration per   |
|                       | button press*.                     |
| !Numpad8/!Numpad2     | Inc./dec. wheel initial speed per  |
|                       | button press*.                     |
| !Numpad9/!Numpad3     | Inc./dec. wheel maximum speed per  |
|                       | button press*.                     |
| Numpad4/Numpad6       | Inc./dec. rotation angle to        |
|                       | right in degrees. (i.e. 180°=      |
|                       | = inversed controls).              |
|------------------------------------------------------------|
| * = These options are affected by the mouse wheel speed    |
| adjusted on Control Panel. If you don't have a mouse with  |
| wheel, the default is 3 +/- lines per option button press. |
o------------------------------------------------------------o
*/

;START OF CONFIG SECTION

A_MaxHotkeysPerInterval := 500

; Using the keyboard hook to implement the Numpad hotkeys prevents
; them from interfering with the generation of ANSI characters such
; as à.  This is because AutoHotkey generates such characters
; by holding down ALT and sending a series of Numpad keystrokes.
; Hook hotkeys are smart enough to ignore such keystrokes.
#UseHook

g_MouseSpeed := 1
g_MouseAccelerationSpeed := 30
g_MouseMaxSpeed := 40

;Mouse wheel speed is also set on Control Panel. As that
;will affect the normal mouse behavior, the real speed of
;these three below are times the normal mouse wheel speed.
g_MouseWheelSpeed := 1
g_MouseWheelAccelerationSpeed := 1
g_MouseWheelMaxSpeed := 5

g_MouseRotationAngle := 0

;END OF CONFIG SECTION

;This is needed or key presses would faulty send their natural
;actions. Like NumpadDiv would send sometimes "/" to the
;screen.
InstallKeybdHook

g_Temp1 := 0
g_Temp2 := 0

;Divide by 45° because MouseMove only supports whole numbers,
;and changing the mouse rotation to a number lesser than 45°
;could make strange movements.
;
;For example: 22.5° when pressing NumpadUp:
;  First it would move upwards until the speed
;  to the side reaches 1.
g_MouseRotationAnglePart := g_MouseRotationAngle / 45

g_MouseCurrentAccelerationSpeed := 0
g_MouseCurrentSpeed := 0
g_MouseCurrentSpeedToY := 0
g_MouseCurrentSpeedToX := 0

g_MouseWheelCurrentAccelerationSpeed := 0
g_MouseWheelCurrentSpeed := 0
g_MouseWheelAccelerationSpeedReal := 0
g_MouseWheelMaxSpeedReal := 0
g_MouseWheelSpeedReal := 0

g_Button := 0
g_Button2 := 0

SetKeyDelay -1
SetMouseDelay -1

Hotkey "*Numpad0", ButtonLeftClick
Hotkey "*NumpadIns", ButtonLeftClickIns
Hotkey "*Numpad5", ButtonMiddleClick
Hotkey "*NumpadClear", ButtonMiddleClickClear
Hotkey "*NumpadDot", ButtonRightClick
Hotkey "*NumpadDel", ButtonRightClickDel
Hotkey "*NumpadDiv", ButtonX1Click
Hotkey "*NumpadMult", ButtonX2Click

Hotkey "*NumpadAdd", ButtonWheelAcceleration
Hotkey "*NumpadEnter", ButtonWheelAcceleration

Hotkey "*NumpadUp", ButtonAcceleration
Hotkey "*NumpadDown", ButtonAcceleration
Hotkey "*NumpadLeft", ButtonAcceleration
Hotkey "*NumpadRight", ButtonAcceleration
Hotkey "*NumpadHome", ButtonAcceleration
Hotkey "*NumpadEnd", ButtonAcceleration
Hotkey "*NumpadPgUp", ButtonAcceleration
Hotkey "*NumpadPgDn", ButtonAcceleration

;Hotkey "Numpad8", ButtonSpeedUp
;Hotkey "Numpad2", ButtonSpeedDown
;Hotkey "Numpad7", ButtonAccelerationSpeedUp
;Hotkey "Numpad1", ButtonAccelerationSpeedDown
;Hotkey "Numpad9", ButtonMaxSpeedUp
;Hotkey "Numpad3", ButtonMaxSpeedDown
;
;Hotkey "Numpad6", ButtonRotationAngleUp
;Hotkey "Numpad4", ButtonRotationAngleDown
;
;Hotkey "!Numpad8", ButtonWheelSpeedUp
;Hotkey "!Numpad2", ButtonWheelSpeedDown
;Hotkey "!Numpad7", ButtonWheelAccelerationSpeedUp
;Hotkey "!Numpad1", ButtonWheelAccelerationSpeedDown
;Hotkey "!Numpad9", ButtonWheelMaxSpeedUp
;Hotkey "!Numpad3", ButtonWheelMaxSpeedDown

ToggleKeyActivationSupport  ; Initialize based on current ScrollLock state.

;Key activation support

~ScrollLock::
ToggleKeyActivationSupport(*)
{
    ; Wait for it to be released because otherwise the hook state gets reset
    ; while the key is down, which causes the up-event to get suppressed,
    ; which in turn prevents toggling of the ScrollLock state/light:
    KeyWait "ScrollLock"
    if GetKeyState("ScrollLock", "T")
    {
        Hotkey "*Numpad0", "On"
        Hotkey "*NumpadIns", "On"
        Hotkey "*Numpad5", "On"
        Hotkey "*NumpadDot", "On"
        Hotkey "*NumpadDel", "On"
        Hotkey "*NumpadDiv", "On"
        Hotkey "*NumpadMult", "On"

        Hotkey "*NumpadAdd", "On"
        Hotkey "*NumpadEnter", "On"

        Hotkey "*NumpadUp", "On"
        Hotkey "*NumpadDown", "On"
        Hotkey "*NumpadLeft", "On"
        Hotkey "*NumpadRight", "On"
        Hotkey "*NumpadHome", "On"
        Hotkey "*NumpadEnd", "On"
        Hotkey "*NumpadPgUp", "On"
        Hotkey "*NumpadPgDn", "On"

;        Hotkey "Numpad8", "On"
;        Hotkey "Numpad2", "On"
;        Hotkey "Numpad7", "On"
;        Hotkey "Numpad1", "On"
;        Hotkey "Numpad9", "On"
;        Hotkey "Numpad3", "On"
;
;        Hotkey "Numpad6", "On"
;        Hotkey "Numpad4", "On"
;
;        Hotkey "!Numpad8", "On"
;        Hotkey "!Numpad2", "On"
;        Hotkey "!Numpad7", "On"
;        Hotkey "!Numpad1", "On"
;        Hotkey "!Numpad9", "On"
;        Hotkey "!Numpad3", "On"
    }
    else
    {
        Hotkey "*Numpad0", "Off"
        Hotkey "*NumpadIns", "Off"
        Hotkey "*Numpad5", "Off"
        Hotkey "*NumpadDot", "Off"
        Hotkey "*NumpadDel", "Off"
        Hotkey "*NumpadDiv", "Off"
        Hotkey "*NumpadMult", "Off"

        Hotkey "*NumpadAdd", "Off"
        Hotkey "*NumpadEnter", "Off"

        Hotkey "*NumpadUp", "Off"
        Hotkey "*NumpadDown", "Off"
        Hotkey "*NumpadLeft", "Off"
        Hotkey "*NumpadRight", "Off"
        Hotkey "*NumpadHome", "Off"
        Hotkey "*NumpadEnd", "Off"
        Hotkey "*NumpadPgUp", "Off"
        Hotkey "*NumpadPgDn", "Off"

;        Hotkey "Numpad8", "Off"
;        Hotkey "Numpad2", "Off"
;        Hotkey "Numpad7", "Off"
;        Hotkey "Numpad1", "Off"
;        Hotkey "Numpad9", "Off"
;        Hotkey "Numpad3", "Off"
;
;        Hotkey "Numpad6", "Off"
;        Hotkey "Numpad4", "Off"
;
;        Hotkey "!Numpad8", "Off"
;        Hotkey "!Numpad2", "Off"
;        Hotkey "!Numpad7", "Off"
;        Hotkey "!Numpad1", "Off"
;        Hotkey "!Numpad9", "Off"
;        Hotkey "!Numpad3", "Off"
    }
}

;Mouse click support

ButtonLeftClick(*)
{
    if GetKeyState("LButton")
        return
    Button2 := "Numpad0"
    ButtonClick := "Left"
    ButtonClickStart Button2, ButtonClick
}

ButtonLeftClickIns(*)
{
    if GetKeyState("LButton")
        return
    Button2 := "NumpadIns"
    ButtonClick := "Left"
    ButtonClickStart Button2, ButtonClick
}

ButtonMiddleClick(*)
{
    if GetKeyState("MButton")
        return
    Button2 := "Numpad5"
    ButtonClick := "Middle"
    ButtonClickStart Button2, ButtonClick
}

ButtonMiddleClickClear(*)
{
    if GetKeyState("MButton")
        return
    Button2 := "NumpadClear"
    ButtonClick := "Middle"
    ButtonClickStart Button2, ButtonClick
}

ButtonRightClick(*)
{
    if GetKeyState("RButton")
        return
    Button2 := "NumpadDot"
    ButtonClick := "Right"
    ButtonClickStart Button2, ButtonClick
}

ButtonRightClickDel(*)
{
    if GetKeyState("RButton")
        return
    Button2 := "NumpadDel"
    ButtonClick := "Right"
    ButtonClickStart Button2, ButtonClick
}

ButtonX1Click(*)
{
    if GetKeyState("XButton1")
        return
    Button2 := "NumpadDiv"
    ButtonClick := "X1"
    ButtonClickStart Button2, ButtonClick
}

ButtonX2Click(*)
{
    if GetKeyState("XButton2")
        return
    Button2 := "NumpadMult"
    ButtonClick := "X2"
    ButtonClickStart Button2, ButtonClick
}

ButtonClickStart(Button2, ButtonClick)
{
    MouseClick ButtonClick,,, 1, 0, "D"
    SetTimer ButtonClickEnd.Bind(Button2, ButtonClick), 10
}

ButtonClickEnd(Button2, ButtonClick)
{
    if GetKeyState(Button2, "P")
        return

    SetTimer , 0
    MouseClick ButtonClick,,, 1, 0, "U"
}

;Mouse movement support

ButtonSpeedUp(*)
{
    global
    g_MouseSpeed++
    ToolTip "Mouse speed: " g_MouseSpeed " pixels"
    SetTimer ToolTip, -1000
}

ButtonSpeedDown(*)
{
    global
    if g_MouseSpeed > 1
        g_MouseSpeed--
    if g_MouseSpeed = 1
        ToolTip "Mouse speed: " g_MouseSpeed " pixel"
    else
        ToolTip "Mouse speed: " g_MouseSpeed " pixels"
    SetTimer ToolTip, -1000
}

ButtonAccelerationSpeedUp(*)
{
    global
    g_MouseAccelerationSpeed++
    ToolTip "Mouse acceleration speed: " g_MouseAccelerationSpeed " pixels"
    SetTimer ToolTip, -1000
}

ButtonAccelerationSpeedDown(*)
{
    global
    if g_MouseAccelerationSpeed > 1
        g_MouseAccelerationSpeed--
    if g_MouseAccelerationSpeed = 1
        ToolTip "Mouse acceleration speed: " g_MouseAccelerationSpeed " pixel"
    else
        ToolTip "Mouse acceleration speed: " g_MouseAccelerationSpeed " pixels"
    SetTimer ToolTip, -1000
}

ButtonMaxSpeedUp(*)
{
    global
    g_MouseMaxSpeed++
    ToolTip "Mouse maximum speed: " g_MouseMaxSpeed " pixels"
    SetTimer ToolTip, -1000
}

ButtonMaxSpeedDown(*)
{
    global
    if g_MouseMaxSpeed > 1
        g_MouseMaxSpeed--
    if g_MouseMaxSpeed = 1
        ToolTip "Mouse maximum speed: " g_MouseMaxSpeed " pixel"
    else
        ToolTip "Mouse maximum speed: " g_MouseMaxSpeed " pixels"
    SetTimer ToolTip, -1000
}

ButtonRotationAngleUp(*)
{
    global
    g_MouseRotationAnglePart++
    if g_MouseRotationAnglePart >= 8
        g_MouseRotationAnglePart := 0
    g_MouseRotationAngle := g_MouseRotationAnglePart
    g_MouseRotationAngle *= 45
    ToolTip "Mouse rotation angle: " g_MouseRotationAngle "°"
    SetTimer ToolTip, -1000
}

ButtonRotationAngleDown(*)
{
    global
    g_MouseRotationAnglePart--
    if g_MouseRotationAnglePart < 0
        g_MouseRotationAnglePart := 7
    g_MouseRotationAngle := g_MouseRotationAnglePart
    g_MouseRotationAngle *= 45
    ToolTip "Mouse rotation angle: " g_MouseRotationAngle "°"
    SetTimer ToolTip, -1000
}

ButtonAcceleration(ThisHotkey)
{
    global
    


    if g_Button != 0
    {
	if !InStr(ThisHotkey, g_Button) 
        {
	    g_Button2 := StrReplace(ThisHotkey, "*")
        }   
    }

    if g_Button == 0
    {
        g_Button := StrReplace(ThisHotkey, "*")
    }
    ButtonAccelerationStart         
}

SecondaryButton()
{
    global

    g_MouseRotationAngle := 0

    turn := 0

    east := 45
    west := 315

    if g_button = "NumpadUp"{
        if  g_Button2 = "NumpadDown"{
            g_Button := g_Button2
            g_Button2 := 0
        }
        
        if g_Button2 = "NumpadRight"{
            turn := east
        }
        if g_Button2 = "NumpadLeft"{
        turn := west
        }
    }

    if g_button = "NumpadLeft"{
        if  g_Button2 = "NumpadRight"{
            g_Button := g_Button2
            g_Button2 := 0
        }

        if g_Button2 = "NumpadUp"{
            turn := east
        }
        if  g_Button2 = "NumpadDown"{
            turn := west
        }
    }

    if g_button = "NumpadRight"{
        if  g_Button2 = "NumpadLeft"{
            g_Button := g_Button2
            g_Button2 := 0
        }
        
        if g_Button2 = "NumpadUp"{
        turn := west
        }
        if g_Button2 = "NumpadDown"{
        turn := east
        }
    }

    if g_button = "NumpadDown"{
        if  g_Button2 = "NumpadUp"{
            g_Button := g_Button2
            g_Button2 := 0
        }
        
        if g_Button2 = "NumpadRight"{
        turn := west
        }
        if  g_Button2 = "NumpadLeft"{
        turn := east
        }
    }

    if GetKeyState(g_Button2, "P") 
    {
        g_MouseRotationAngle := turn
        return
    }
    
}

ButtonAccelerationStart()
{
    global

    if GetKeyState("LCtrl","P")
    {
        g_MouseCurrentSpeed := 5
        g_MouseCurrentAccelerationSpeed := 1 
    } 

    SecondaryButton

    if g_MouseAccelerationSpeed >= 1
    {
        if g_MouseMaxSpeed > g_MouseCurrentSpeed
        {
            g_Temp1 := 0.001
            g_Temp1 *= g_MouseAccelerationSpeed
            g_MouseCurrentAccelerationSpeed += g_Temp1
            g_MouseCurrentSpeed += g_MouseCurrentAccelerationSpeed
        }
    }

    ;g_MouseRotationAngle convertion to speed of button direction
    g_MouseCurrentSpeedToY := g_MouseRotationAngle
    g_MouseCurrentSpeedToY /= 90.0
    g_Temp1 := g_MouseCurrentSpeedToY

    if g_Temp1 >= 0
    {
        if g_Temp1 < 1
        {
            g_MouseCurrentSpeedToY := 1
            g_MouseCurrentSpeedToY -= g_Temp1
            EndMouseCurrentSpeedToYCalculation
            return
        }
    }
    if g_Temp1 >= 1
    {
        if g_Temp1 < 2
        {
            g_MouseCurrentSpeedToY := 0
            g_Temp1 -= 1
            g_MouseCurrentSpeedToY -= g_Temp1
            EndMouseCurrentSpeedToYCalculation
            return
        }
    }
    if g_Temp1 >= 2
    {
        if g_Temp1 < 3
        {
            g_MouseCurrentSpeedToY := -1
            g_Temp1 -= 2
            g_MouseCurrentSpeedToY += g_Temp1
            EndMouseCurrentSpeedToYCalculation
            return
        }
    }
    if g_Temp1 >= 3
    {
        if g_Temp1 < 4
        {
            g_MouseCurrentSpeedToY := 0
            g_Temp1 -= 3
            g_MouseCurrentSpeedToY += g_Temp1
            EndMouseCurrentSpeedToYCalculation
            return
        }
    }
    EndMouseCurrentSpeedToYCalculation
}

EndMouseCurrentSpeedToYCalculation()
{
    global

    ;g_MouseRotationAngle convertion to speed of 90 degrees to right
    g_MouseCurrentSpeedToX := g_MouseRotationAngle
    g_MouseCurrentSpeedToX /= 90.0
    g_Temp1 := Mod(g_MouseCurrentSpeedToX, 4)

    if g_Temp1 >= 0
    {
        if g_Temp1 < 1
        {
            g_MouseCurrentSpeedToX := 0
            g_MouseCurrentSpeedToX += g_Temp1
            EndMouseCurrentSpeedToXCalculation
            return
        }
    }
    if g_Temp1 >= 1
    {
        if g_Temp1 < 2
        {
            g_MouseCurrentSpeedToX := 1
            g_Temp1 -= 1
            g_MouseCurrentSpeedToX -= g_Temp1
            EndMouseCurrentSpeedToXCalculation
            return
        }
    }
    if g_Temp1 >= 2
    {
        if g_Temp1 < 3
        {
            g_MouseCurrentSpeedToX := 0
            g_Temp1 -= 2
            g_MouseCurrentSpeedToX -= g_Temp1
            EndMouseCurrentSpeedToXCalculation
            return
        }
    }
    if g_Temp1 >= 3
    {
        if g_Temp1 < 4
        {
            g_MouseCurrentSpeedToX := -1
            g_Temp1 -= 3
            g_MouseCurrentSpeedToX += g_Temp1
            EndMouseCurrentSpeedToXCalculation
            return
        }
    }
    EndMouseCurrentSpeedToXCalculation
}

EndMouseCurrentSpeedToXCalculation()
{
    global

    g_MouseCurrentSpeedToY *= g_MouseCurrentSpeed
    g_MouseCurrentSpeedToX *= g_MouseCurrentSpeed

    g_Temp1 := Mod(g_MouseRotationAnglePart, 2)

    if g_Button = "NumpadUp"
    {
        if g_Temp1 = 1
        {
            g_MouseCurrentSpeedToX *= 2
            g_MouseCurrentSpeedToY *= 2
        }

        g_MouseCurrentSpeedToY *= -1
        MouseMove g_MouseCurrentSpeedToX, g_MouseCurrentSpeedToY, 0, "R"
    }
    else if g_Button = "NumpadDown"
    {
        if g_Temp1 = 1
        {
            g_MouseCurrentSpeedToX *= 2
            g_MouseCurrentSpeedToY *= 2
        }

        g_MouseCurrentSpeedToX *= -1
        MouseMove g_MouseCurrentSpeedToX, g_MouseCurrentSpeedToY, 0, "R"
    }
    else if g_Button = "NumpadLeft"
    {
        if g_Temp1 = 1
        {
            g_MouseCurrentSpeedToX *= 2
            g_MouseCurrentSpeedToY *= 2
        }

        g_MouseCurrentSpeedToX *= -1
        g_MouseCurrentSpeedToY *= -1

        MouseMove g_MouseCurrentSpeedToY, g_MouseCurrentSpeedToX, 0, "R"
    }
    else if g_Button = "NumpadRight"
    {
        if g_Temp1 = 1
        {
            g_MouseCurrentSpeedToX *= 2
            g_MouseCurrentSpeedToY *= 2
        }

        MouseMove g_MouseCurrentSpeedToY, g_MouseCurrentSpeedToX, 0, "R"
    }
    else if g_Button = "NumpadHome"
    {
        g_Temp1 := g_MouseCurrentSpeedToY
        g_Temp1 -= g_MouseCurrentSpeedToX
        g_Temp1 *= -1
        g_Temp2 := g_MouseCurrentSpeedToY
        g_Temp2 += g_MouseCurrentSpeedToX
        g_Temp2 *= -1
        MouseMove g_Temp1, g_Temp2, 0, "R"
    }
    else if g_Button = "NumpadPgUp"
    {
        g_Temp1 := g_MouseCurrentSpeedToY
        g_Temp1 += g_MouseCurrentSpeedToX
        g_Temp2 := g_MouseCurrentSpeedToY
        g_Temp2 -= g_MouseCurrentSpeedToX
        g_Temp2 *= -1
        MouseMove g_Temp1, g_Temp2, 0, "R"
    }
    else if g_Button = "NumpadEnd"
    {
        g_Temp1 := g_MouseCurrentSpeedToY
        g_Temp1 += g_MouseCurrentSpeedToX
        g_Temp1 *= -1
        g_Temp2 := g_MouseCurrentSpeedToY
        g_Temp2 -= g_MouseCurrentSpeedToX
        MouseMove g_Temp1, g_Temp2, 0, "R"
    }
    else if g_Button = "NumpadPgDn"
    {
        g_Temp1 := g_MouseCurrentSpeedToY
        g_Temp1 -= g_MouseCurrentSpeedToX
        g_Temp2 *= -1
        g_Temp2 := g_MouseCurrentSpeedToY
        g_Temp2 += g_MouseCurrentSpeedToX
        MouseMove g_Temp1, g_Temp2, 0, "R"
    }

    SetTimer ButtonAccelerationEnd, 10
}

ButtonAccelerationEnd()
{
    global
    if GetKeyState(g_Button2, "P") and !GetKeyState(g_Button, "P")
    {
        g_Button := g_Button2
        return
    }
    
    if GetKeyState(g_Button, "P")
    {
        ButtonAccelerationStart
        return
    }

    g_MouseRotationAngle := 0
    g_Button2 := 0
    g_Button := 0

    SetTimer , 0
}

;Mouse wheel movement support

ButtonWheelSpeedUp(*)
{
    global
    g_MouseWheelSpeed++
    local MouseWheelSpeedMultiplier := RegRead("HKCU\Control Panel\Desktop", "WheelScrollLines")
    if MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier := 1
    g_MouseWheelSpeedReal := g_MouseWheelSpeed
    g_MouseWheelSpeedReal *= MouseWheelSpeedMultiplier
    ToolTip "Mouse wheel speed: " g_MouseWheelSpeedReal " lines"
    SetTimer ToolTip, -1000
}

ButtonWheelSpeedDown(*)
{
    global
    local MouseWheelSpeedMultiplier := RegRead("HKCU\Control Panel\Desktop", "WheelScrollLines")
    if MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier := 1
    if g_MouseWheelSpeedReal > MouseWheelSpeedMultiplier
    {
        g_MouseWheelSpeed--
        g_MouseWheelSpeedReal := g_MouseWheelSpeed
        g_MouseWheelSpeedReal *= MouseWheelSpeedMultiplier
    }
    if g_MouseWheelSpeedReal = 1
        ToolTip "Mouse wheel speed: " g_MouseWheelSpeedReal " line"
    else
        ToolTip "Mouse wheel speed: " g_MouseWheelSpeedReal " lines"
    SetTimer ToolTip, -1000
}

ButtonWheelAccelerationSpeedUp(*)
{
    global
    g_MouseWheelAccelerationSpeed++
    local MouseWheelSpeedMultiplier := RegRead("HKCU\Control Panel\Desktop", "WheelScrollLines")
    if MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier := 1
    g_MouseWheelAccelerationSpeedReal := g_MouseWheelAccelerationSpeed
    g_MouseWheelAccelerationSpeedReal *= MouseWheelSpeedMultiplier
    ToolTip "Mouse wheel acceleration speed: " g_MouseWheelAccelerationSpeedReal " lines"
    SetTimer ToolTip, -1000
}

ButtonWheelAccelerationSpeedDown(*)
{
    global
    local MouseWheelSpeedMultiplier := RegRead("HKCU\Control Panel\Desktop", "WheelScrollLines")
    if MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier := 1
    if g_MouseWheelAccelerationSpeed > 1
    {
        g_MouseWheelAccelerationSpeed--
        g_MouseWheelAccelerationSpeedReal := g_MouseWheelAccelerationSpeed
        g_MouseWheelAccelerationSpeedReal *= MouseWheelSpeedMultiplier
    }
    if g_MouseWheelAccelerationSpeedReal = 1
        ToolTip "Mouse wheel acceleration speed: " g_MouseWheelAccelerationSpeedReal " line"
    else
        ToolTip "Mouse wheel acceleration speed: " g_MouseWheelAccelerationSpeedReal " lines"
    SetTimer ToolTip, -1000
}

ButtonWheelMaxSpeedUp(*)
{
    global
    g_MouseWheelMaxSpeed++
    local MouseWheelSpeedMultiplier := RegRead("HKCU\Control Panel\Desktop", "WheelScrollLines")
    if MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier := 1
    g_MouseWheelMaxSpeedReal := g_MouseWheelMaxSpeed
    g_MouseWheelMaxSpeedReal *= MouseWheelSpeedMultiplier
    ToolTip "Mouse wheel maximum speed: " g_MouseWheelMaxSpeedReal " lines"
    SetTimer ToolTip, -1000
}

ButtonWheelMaxSpeedDown(*)
{
    global
    local MouseWheelSpeedMultiplier := RegRead("HKCU\Control Panel\Desktop", "WheelScrollLines")
    if MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier := 1
    if g_MouseWheelMaxSpeed > 1
    {
        g_MouseWheelMaxSpeed--
        g_MouseWheelMaxSpeedReal := g_MouseWheelMaxSpeed
        g_MouseWheelMaxSpeedReal *= MouseWheelSpeedMultiplier
    }
    if g_MouseWheelMaxSpeedReal = 1
        ToolTip "Mouse wheel maximum speed: " g_MouseWheelMaxSpeedReal " line"
    else
        ToolTip "Mouse wheel maximum speed: " g_MouseWheelMaxSpeedReal " lines"
    SetTimer ToolTip, -1000
}

ButtonWheelAcceleration(ThisHotkey)
{
    global
    if g_Button != 0
    {
        if g_Button != ThisHotkey
        {
            g_MouseWheelCurrentAccelerationSpeed := 0
            g_MouseWheelCurrentSpeed := g_MouseWheelSpeed
        }
    }
    g_Button := StrReplace(ThisHotkey, "*")
    ButtonWheelAccelerationStart
}

ButtonWheelAccelerationStart()
{
    global

    if g_MouseWheelAccelerationSpeed >= 1
    {
        if g_MouseWheelMaxSpeed > g_MouseWheelCurrentSpeed
        {
            g_Temp1 := 0.001
            g_Temp1 *= g_MouseWheelAccelerationSpeed
            g_MouseWheelCurrentAccelerationSpeed += g_Temp1
            g_MouseWheelCurrentSpeed += g_MouseWheelCurrentAccelerationSpeed
        }
    }

    if g_Button = "NumpadAdd"
        MouseClick "WheelUp",,, g_MouseWheelCurrentSpeed, 0, "D"
    else if g_Button = "NumpadEnter"
        MouseClick "WheelDown",,, g_MouseWheelCurrentSpeed, 0, "D"

    SetTimer ButtonWheelAccelerationEnd, 100
}

ButtonWheelAccelerationEnd()
{
    global

    if GetKeyState(g_Button, "P")
    {
        ButtonWheelAccelerationStart
        return
    }

    g_MouseWheelCurrentAccelerationSpeed := 0
    g_MouseWheelCurrentSpeed := g_MouseWheelSpeed
    g_Button := 0
}
