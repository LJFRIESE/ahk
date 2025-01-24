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
| NumpadDel             | Right mouse button click.          |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click.          |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.     |
|                       |                                    |
|-----------------------|------------------------------------|
| NumLock (toggled off) | Activates mouse movement mode.     |
|-----------------------|------------------------------------|
| NumpadEnd/Down/PgDn/  | Mouse movement.                    |
| /Left/Right/Home/Up/  |                                    |
| /PgUp                 |                                    |
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

; Speed is in pixels/tick
; This means speed is relative to resolution
g_MouseSpeed := 5
g_MouseAccelerationSpeed := 70
g_MouseMaxSpeed := 45

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
Hotkey "*NumpadDel", ButtonRightClick
Hotkey "*NumpadDiv", ButtonX1Click
Hotkey "*NumpadMult", ButtonX2Click

Hotkey "*NumpadAdd", ButtonWheelAcceleration
Hotkey "*NumpadEnter", ButtonWheelAcceleration

Hotkey "*NumpadUp", ButtonAcceleration
Hotkey "*NumpadDown", ButtonAcceleration
Hotkey "*NumpadLeft", ButtonAcceleration
Hotkey "*NumpadRight", ButtonAcceleration
Hotkey "*NumpadHome", ButtonJump ;ButtonAcceleration
Hotkey "*NumpadEnd", ButtonJump ;ButtonAcceleration
Hotkey "*NumpadPgUp", ButtonJump ;ButtonAcceleration
Hotkey "*NumpadPgDn", ButtonJump ;ButtonAcceleration

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
    }
    else
    {
        Hotkey "*Numpad0", "Off"
        Hotkey "*NumpadIns", "Off"
        Hotkey "*Numpad5", "Off"
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
    MouseClick ButtonClick, , , 1, 0, "D"
    SetTimer ButtonClickEnd.Bind(Button2, ButtonClick), 10
}

ButtonClickEnd(Button2, ButtonClick)
{
    if GetKeyState(Button2, "P")
        return

    SetTimer , 0
    MouseClick ButtonClick, , , 1, 0, "U"
}

;Mouse movement support

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

ButtonJump(ThisHotkey)
{
    global

    if g_Button == 0
    {
        g_Button := StrReplace(ThisHotkey, "*")
    }
    ; Diagonal jumps
    if g_Button = "NumpadHome"
    {
        MouseMove -15, -15, 0, "R"
    }
    else if g_Button = "NumpadPgUp"
    {
        MouseMove 15, -15, 0, "R"
    } else if g_Button = "NumpadEnd"
    {
        MouseMove -15, 15, 0, "R"
    }
    else if g_Button = "NumpadPgDn"
    {
        MouseMove 15, 15, 0, "R"
    }
    ; Cardinal jumps
    if g_Button = "Up"
    {
        MouseMove 0, 15, 0, "R"
    }
    else if g_Button = "Down"
    {
        MouseMove 0, -15, 0, "R"
    } else if g_Button = "Left"
    {
        MouseMove -15, 0, 0, "R"
    }
    else if g_Button = "Right"
    {
        MouseMove 155, 15, 0, "R"
    }
    g_button := 0
}

SecondaryButton()
{
    global

    g_MouseRotationAngle := 0

    turn := 0

    east := 45
    west := 315

    if g_button = "NumpadUp" {
        if g_Button2 = "NumpadDown" {
            g_Button := g_Button2
            g_Button2 := 0
        }

        if g_Button2 = "NumpadRight" {
            turn := east
        }
        if g_Button2 = "NumpadLeft" {
            turn := west
        }
    }

    if g_button = "NumpadLeft" {
        if g_Button2 = "NumpadRight" {
            g_Button := g_Button2
            g_Button2 := 0
        }

        if g_Button2 = "NumpadUp" {
            turn := east
        }
        if g_Button2 = "NumpadDown" {
            turn := west
        }
    }

    if g_button = "NumpadRight" {
        if g_Button2 = "NumpadLeft" {
            g_Button := g_Button2
            g_Button2 := 0
        }

        if g_Button2 = "NumpadUp" {
            turn := west
        }
        if g_Button2 = "NumpadDown" {
            turn := east
        }
    }

    if g_button = "NumpadDown" {
        if g_Button2 = "NumpadUp" {
            g_Button := g_Button2
            g_Button2 := 0
        }

        if g_Button2 = "NumpadRight" {
            turn := west
        }
        if g_Button2 = "NumpadLeft" {
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

    if GetKeyState("Backspace", "P")
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

    SetTimer , 0
    g_MouseCurrentAccelerationSpeed := 0
    g_MouseCurrentSpeed := g_MouseSpeed
    g_Button := 0
}

;Mouse wheel movement support

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
        MouseClick "WheelUp", , , g_MouseWheelCurrentSpeed, 0, "D"
    else if g_Button = "NumpadEnter"
        MouseClick "WheelDown", , , g_MouseWheelCurrentSpeed, 0, "D"

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
