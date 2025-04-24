/*
o------------------------------------------------------------o
| Keys                  | Description                        |
|------------------------------------------------------------|
| F24					| Activates numpad mouse mode.       |
|-----------------------|------------------------------------|
| NumpadIns             | Left mouse button click.           |
| NumpadClear           | Middle mouse button click.         |
| NumpadDel             | Right mouse button click.          |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click.          |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.     |
|                       |                                    |
|-----------------------|------------------------------------|
| NumLock (toggled off) | Activates mouse movement mode.     |
o------------------------------------------------------------o
*/


class NumpadMouse {
    static __New() {
        InstallKeybdHook
        SetKeyDelay -1
        SetMouseDelay -1
        A_MaxHotkeysPerInterval := 500

        ;START OF CONFIG SECTION
        ;This is needed or key presses would faulty send their natural
        ;actions. Like NumpadDiv would send sometimes "/" to the
        ;screen.

        ; Using the keyboard hook to implement the Numpad hotkeys prevents
        ; them from interfering with the generation of ANSI characters such
        ; as à.  This is because AutoHotkey generates such characters
        ; by holding down ALT and sending a series of Numpad keystrokes.
        ; Hook hotkeys are smart enough to ignore such keystrokes.
        #UseHook

        Hotkey("*NumpadIns", NumpadMouse.ButtonLeftClickIns)
        Hotkey("*NumpadClear", NumpadMouse.ButtonMiddleClickClear)
        Hotkey("*NumpadSub", NumpadMouse.ButtonRightClick)
        Hotkey("*NumpadDiv", NumpadMouse.ButtonX1Click)
        Hotkey("*NumpadMult", NumpadMouse.ButtonX2Click)

        Hotkey("*NumpadUp", NumpadMouse.ButtonAcceleration)
        Hotkey("*NumpadDown", NumpadMouse.ButtonAcceleration)
        Hotkey("*NumpadLeft", NumpadMouse.ButtonAcceleration)
        Hotkey("*NumpadRight", NumpadMouse.ButtonAcceleration)
        Hotkey("*NumpadHome", NumpadMouse.ButtonJump)
        Hotkey("*NumpadEnd", NumpadMouse.ButtonJump)
        Hotkey("*NumpadPgUp", NumpadMouse.ButtonJump)
        Hotkey("*NumpadPgDn", NumpadMouse.ButtonJump)
    }


    ; Speed is in pixels/tick
    ; This means speed is relative to resolution
    static g_MouseSpeed := 5
    static g_MouseAccelerationSpeed := 70
    static g_MouseMaxSpeed := 45

    ;Mouse wheel speed is also set on Control Panel. As that
    ;will affect the normal mouse behavior, the real speed of
    ;these three below are times the normal mouse wheel speed.
    static g_MouseWheelSpeed := 1
    static g_MouseWheelAccelerationSpeed := 1
    static g_MouseWheelMaxSpeed := 5
    ;END OF CONFIG SECTION

    ; Holding variables
    static g_Temp1 := 0
    static g_Temp2 := 0

    static g_MouseRotationAngle := 0
    ;Divide by 45° because MouseMove only supports whole numbers,
    ;and changing the mouse rotation to a number lesser than 45°
    ;could make strange movements.
    ;
    ;For example: 22.5° when pressing NumpadUp:
    ;  First it would move upwards until the speed
    ;  to the side reaches 1.
    static g_MouseRotationAnglePart := this.g_MouseRotationAngle / 45

    static g_MouseCurrentAccelerationSpeed := 0
    static g_MouseCurrentSpeed := 0
    static g_MouseCurrentSpeedToY := 0
    static g_MouseCurrentSpeedToX := 0

    static g_MouseWheelCurrentAccelerationSpeed := 0
    static g_MouseWheelCurrentSpeed := 0
    static g_MouseWheelAccelerationSpeedReal := 0
    static g_MouseWheelMaxSpeedReal := 0
    static g_MouseWheelSpeedReal := 0

    static g_NumpadKeyPress1 := 0
    static g_NumpadKeyPress2 := 0

    ; ==========================================
    ; Mouse click support
    ; ==========================================
    static ButtonLeftClickIns(*) {
        if GetKeyState("LButton") {
            return
        }
        this.NumpadKeyPress2 := "NumpadIns"
        this.Mouse := "Left"
        this.MouseStart(this.NumpadKeyPress2, this.Mouse)
    }

    static ButtonMiddleClickClear(*) {
        if GetKeyState("MButton") {
            return
        }
        this.NumpadKeyPress2 := "NumpadClear"
        this.Mouse := "Middle"
        this.MouseStart(this.NumpadKeyPress2, this.Mouse)
    }

    static ButtonRightClick(*) {
        if GetKeyState("RButton") {
            return
        }
        this.NumpadKeyPress2 := "NumpadSub"
        this.Mouse := "Right"
        this.MouseStart(this.NumpadKeyPress2, this.Mouse)
    }

    static ButtonX1Click(*) {
        if GetKeyState("XButton1") {
            return
        }
        this.NumpadKeyPress2 := "NumpadDiv"
        this.Mouse := "X1"
        this.MouseStart(this.NumpadKeyPress2, this.Mouse)
    }

    static ButtonX2Click(*) {
        if GetKeyState("XNumpadKeyPress2") {
            return
        }
        this.NumpadKeyPress2 := "NumpadMult"
        this.Mouse := "X2"
        this.MouseStart(this.NumpadKeyPress2, this.Mouse)
    }

    static MouseStart(NumpadKeyPress2, Mouse) {
        MouseClick Mouse, , , 1, 0, "D"
        SetTimer(this.MouseEnd.Bind(this.NumpadKeyPress2, this.Mouse), 10)
    }

    static MouseEnd(NumpadKeyPress2, Mouse) {
        if GetKeyState(this.NumpadKeyPress2, "P") {
            return
        }

        SetTimer , 0
        MouseClick Mouse, , , 1, 0, "U"
    }

    ;Mouse movement support

    static ButtonAcceleration(ThisHotkey*) {
        if this.g_NumpadKeyPress1 != 0 {
            if !InStr(ThisHotkey, this.g_NumpadKeyPress1) {
                this.g_NumpadKeyPress2 := StrReplace(ThisHotkey, "*")
            }
        }

        if this.g_NumpadKeyPress1 == 0 {
            this.g_NumpadKeyPress1 := StrReplace(ThisHotkey, "*")
        }
        this.ButtonAccelerationStart()
    }

    static ButtonJump(ThisHotkey*) {
        if this.g_NumpadKeyPress1 == 0 {
            this.g_NumpadKeyPress1 := StrReplace(ThisHotkey, "*")
        }
        ; Diagonal jumps
        if this.g_NumpadKeyPress1 = "NumpadHome" {
            MouseMove -15, -15, 0, "R"
        } else if this.g_NumpadKeyPress1 = "NumpadPgUp" {
            MouseMove 15, -15, 0, "R"
        } else if this.g_NumpadKeyPress1 = "NumpadEnd" {
            MouseMove -15, 15, 0, "R"
        } else if this.g_NumpadKeyPress1 = "NumpadPgDn" {
            MouseMove 15, 15, 0, "R"
        }
        ; Cardinal jumps
        if this.g_NumpadKeyPress1 = "Up" {
            MouseMove 0, 15, 0, "R"
        } else if this.g_NumpadKeyPress1 = "Down" {
            MouseMove 0, -15, 0, "R"
        } else if this.g_NumpadKeyPress1 = "Left" {
            MouseMove -15, 0, 0, "R"
        } else if this.g_NumpadKeyPress1 = "Right" {
            MouseMove 155, 15, 0, "R"
        }
        this.g_NumpadKeyPress1 := 0
    }

    static SecondaryButton()
    {
        this.g_MouseRotationAngle := 0

        turn := 0

        east := 45
        west := 315

        if this.g_NumpadKeyPress1 = "NumpadUp" {
            if this.g_NumpadKeyPress2 = "NumpadDown" {
                this.g_NumpadKeyPress1 := this.g_NumpadKeyPress2
                this.g_NumpadKeyPress2 := 0
            }

            if this.g_NumpadKeyPress2 = "NumpadRight" {
                turn := east
            }
            if this.g_NumpadKeyPress2 = "NumpadLeft" {
                turn := west
            }
        }

        if this.g_NumpadKeyPress1 = "NumpadLeft" {
            if this.g_NumpadKeyPress2 = "NumpadRight" {
                this.g_NumpadKeyPress1 := this.g_NumpadKeyPress2
                this.g_NumpadKeyPress2 := 0
            }

            if this.g_NumpadKeyPress2 = "NumpadUp" {
                turn := east
            }
            if this.g_NumpadKeyPress2 = "NumpadDown" {
                turn := west
            }
        }

        if this.g_NumpadKeyPress1 = "NumpadRight" {
            if this.g_NumpadKeyPress2 = "NumpadLeft" {
                this.g_NumpadKeyPress1 := this.g_NumpadKeyPress2
                this.g_NumpadKeyPress2 := 0
            }

            if this.g_NumpadKeyPress2 = "NumpadUp" {
                turn := west
            }
            if this.g_NumpadKeyPress2 = "NumpadDown" {
                turn := east
            }
        }

        if this.g_NumpadKeyPress1 = "NumpadDown" {
            if this.g_NumpadKeyPress2 = "NumpadUp" {
                this.g_NumpadKeyPress1 := this.g_NumpadKeyPress2
                this.g_NumpadKeyPress2 := 0
            }

            if this.g_NumpadKeyPress2 = "NumpadRight" {
                turn := west
            }
            if this.g_NumpadKeyPress2 = "NumpadLeft" {
                turn := east
            }
        }

        if GetKeyState(this.g_NumpadKeyPress2, "P") {
            this.g_MouseRotationAngle := turn
            return
        }

    }

    static ButtonAccelerationStart() {
        if GetKeyState("Backspace", "P") {
            this.g_MouseCurrentSpeed := 5
            this.g_MouseCurrentAccelerationSpeed := 1
        }

        this.SecondaryButton()

        if this.g_MouseAccelerationSpeed >= 1 {
            if this.g_MouseMaxSpeed > this.g_MouseCurrentSpeed {
                this.g_Temp1 := 0.001
                this.g_Temp1 *= this.g_MouseAccelerationSpeed
                this.g_MouseCurrentAccelerationSpeed += this.g_Temp1
                this.g_MouseCurrentSpeed += this.g_MouseCurrentAccelerationSpeed
            }
        }

        ;g_MouseRotationAngle convertion to speed of button direction
        this.g_MouseCurrentSpeedToY := this.g_MouseRotationAngle
        this.g_MouseCurrentSpeedToY /= 90.0
        this.g_Temp1 := this.g_MouseCurrentSpeedToY

        if this.g_Temp1 >= 0 {
            if this.g_Temp1 < 1 {
                this.g_MouseCurrentSpeedToY := 1
                this.g_MouseCurrentSpeedToY -= this.g_Temp1
                this.EndMouseCurrentSpeedToYCalculation()
                return
            }
        }
        if this.g_Temp1 >= 1 {
            if this.g_Temp1 < 2 {
                this.g_MouseCurrentSpeedToY := 0
                this.g_Temp1 -= 1
                this.g_MouseCurrentSpeedToY -= this.g_Temp1
                this.EndMouseCurrentSpeedToYCalculation()
                return
            }
        }
        if this.g_Temp1 >= 2 {
            if this.g_Temp1 < 3 {
                this.g_MouseCurrentSpeedToY := -1
                this.g_Temp1 -= 2
                this.g_MouseCurrentSpeedToY += this.g_Temp1
                this.EndMouseCurrentSpeedToYCalculation()
                return
            }
        }
        if this.g_Temp1 >= 3 {
            if this.g_Temp1 < 4 {
                this.g_MouseCurrentSpeedToY := 0
                this.g_Temp1 -= 3
                this.g_MouseCurrentSpeedToY += this.g_Temp1
                this.EndMouseCurrentSpeedToYCalculation()
                return
            }
        }
        this.EndMouseCurrentSpeedToYCalculation()
    }

    static EndMouseCurrentSpeedToYCalculation() {


        ;g_MouseRotationAngle convertion to speed of 90 degrees to right
        this.g_MouseCurrentSpeedToX := this.g_MouseRotationAngle
        this.g_MouseCurrentSpeedToX /= 90.0
        this.g_Temp1 := Mod(this.g_MouseCurrentSpeedToX, 4)

        if this.g_Temp1 >= 0 {
            if this.g_Temp1 < 1 {
                this.g_MouseCurrentSpeedToX := 0
                this.g_MouseCurrentSpeedToX += this.g_Temp1
                this.EndMouseCurrentSpeedToXCalculation()
                return
            }
        }

        if this.g_Temp1 >= 1 {
            if this.g_Temp1 < 2 {
                this.g_MouseCurrentSpeedToX := 1
                this.g_Temp1 -= 1
                this.g_MouseCurrentSpeedToX -= this.g_Temp1
                this.EndMouseCurrentSpeedToXCalculation()
                return
            }
        }
        if this.g_Temp1 >= 2 {
            if this.g_Temp1 < 3 {
                this.g_MouseCurrentSpeedToX := 0
                this.g_Temp1 -= 2
                this.g_MouseCurrentSpeedToX -= this.g_Temp1
                this.EndMouseCurrentSpeedToXCalculation()
                return
            }
        }
        if this.g_Temp1 >= 3 {
            if this.g_Temp1 < 4 {
                this.g_MouseCurrentSpeedToX := -1
                this.g_Temp1 -= 3
                this.g_MouseCurrentSpeedToX += this.g_Temp1
                this.EndMouseCurrentSpeedToXCalculation()
                return
            }
        }
        this.EndMouseCurrentSpeedToXCalculation()
    }

    static EndMouseCurrentSpeedToXCalculation() {
        this.g_MouseCurrentSpeedToY *= this.g_MouseCurrentSpeed
        this.g_MouseCurrentSpeedToX *= this.g_MouseCurrentSpeed

        this.g_Temp1 := Mod(this.g_MouseRotationAnglePart, 2)

        if this.g_NumpadKeyPress1 = "NumpadUp" {
            if this.g_Temp1 = 1 {
                this.g_MouseCurrentSpeedToX *= 2
                this.g_MouseCurrentSpeedToY *= 2
            }

            this.g_MouseCurrentSpeedToY *= -1
            MouseMove this.g_MouseCurrentSpeedToX, this.g_MouseCurrentSpeedToY, 0, "R"
        } else if this.g_NumpadKeyPress1 = "NumpadDown" {
            if this.g_Temp1 = 1 {
                this.g_MouseCurrentSpeedToX *= 2
                this.g_MouseCurrentSpeedToY *= 2
            }

            this.g_MouseCurrentSpeedToX *= -1
            MouseMove this.g_MouseCurrentSpeedToX, this.g_MouseCurrentSpeedToY, 0, "R"
        } else if this.g_NumpadKeyPress1 = "NumpadLeft" {
            if this.g_Temp1 = 1 {
                this.g_MouseCurrentSpeedToX *= 2
                this.g_MouseCurrentSpeedToY *= 2
            }

            this.g_MouseCurrentSpeedToX *= -1
            this.g_MouseCurrentSpeedToY *= -1

            MouseMove this.g_MouseCurrentSpeedToY, this.g_MouseCurrentSpeedToX, 0, "R"
        } else if this.g_NumpadKeyPress1 = "NumpadRight" {
            if this.g_Temp1 = 1 {
                this.g_MouseCurrentSpeedToX *= 2
                this.g_MouseCurrentSpeedToY *= 2
            }

            MouseMove this.g_MouseCurrentSpeedToY, this.g_MouseCurrentSpeedToX, 0, "R"
        }
        SetTimer(this.ButtonAccelerationEnd, 10)
    }

    static ButtonAccelerationEnd() {
        if GetKeyState(this.g_NumpadKeyPress2, "P") and !GetKeyState(this.g_NumpadKeyPress1, "P") {
            this.g_NumpadKeyPress1 := this.g_NumpadKeyPress2
            return
        }

        if GetKeyState(this.g_NumpadKeyPress1, "P") {
            this.ButtonAccelerationStart()
            return
        }

        SetTimer , 0
        this.g_MouseCurrentAccelerationSpeed := 0
        this.g_MouseCurrentSpeed := this.g_MouseSpeed
        this.g_NumpadKeyPress1 := 0
    }

    ;Mouse wheel movement support

    static ButtonWheelAcceleration(ThisHotkey) {
        if this.g_NumpadKeyPress1 != 0 {
            if this.g_NumpadKeyPress1 != ThisHotkey {
                this.g_MouseWheelCurrentAccelerationSpeed := 0
                this.g_MouseWheelCurrentSpeed := this.g_MouseWheelSpeed
            }
        }
        this.g_NumpadKeyPress1 := StrReplace(ThisHotkey, "*")
        this.ButtonWheelAccelerationStart()
    }

    static ButtonWheelAccelerationStart() {
        if this.g_MouseWheelAccelerationSpeed >= 1 {
            if this.g_MouseWheelMaxSpeed > this.g_MouseWheelCurrentSpeed {
                this.g_Temp1 := 0.001
                this.g_Temp1 *= this.g_MouseWheelAccelerationSpeed
                this.g_MouseWheelCurrentAccelerationSpeed += this.g_Temp1
                this.g_MouseWheelCurrentSpeed += this.g_MouseWheelCurrentAccelerationSpeed
            }
        }

        SetTimer(this.ButtonWheelAccelerationEnd, 100)
    }

    static ButtonWheelAccelerationEnd() {
        if GetKeyState(this.g_NumpadKeyPress1, "P") {
            this.ButtonWheelAccelerationStart()
            return
        }

        this.g_MouseWheelCurrentAccelerationSpeed := 0
        this.g_MouseWheelCurrentSpeed := this.g_MouseWheelSpeed
        this.g_NumpadKeyPress1 := 0
    }
}

; Should just take the
HotkeyGuide.RegisterHotkey("Layer 2 - Misc", "F24 (w/ NumLock OFF)", "Toggle Numpad Mouse")
~F24:: {
    Hotkey("*NumpadIns", "Toggle")
    Hotkey("*NumpadClear", "Toggle")
    Hotkey("*NumpadSub", "Toggle")
    Hotkey("*NumpadDiv", "Toggle")
    Hotkey("*NumpadMult", "Toggle")
    Hotkey("*NumpadUp", "Toggle")
    Hotkey("*NumpadDown", "Toggle")
    Hotkey("*NumpadLeft", "Toggle")
    Hotkey("*NumpadRight", "Toggle")
    Hotkey("*NumpadHome", "Toggle")
    Hotkey("*NumpadEnd", "Toggle")
    Hotkey("*NumpadPgUp", "Toggle")
    Hotkey("*NumpadPgDn", "Toggle")
}
