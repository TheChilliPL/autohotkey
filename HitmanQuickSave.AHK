;===============================================================================
; HitmanQuickSave v1.0 by TheChilliPL
;===============================================================================
; A simple script that lets you quickly save and load the first manual save slot
; in HITMAN: World of Assassination (previously: HITMAN 3).
;-------------------------------------------------------------------------------
; [F5] Quickly save the game to the first manual slot
; [F7] Quickly load the game from the first manual slot
;-------------------------------------------------------------------------------
; WARNINGS
; - If run with administrator privileges, it locks the keyboard and mouse while
;   saving and loading the game to prevent the user from messing with the
;   process.
;   If it ever gets stuck, pressing [Ctrl+Alt+Del] seems to unstuck it.
; - It may not work with resolutions other than 1080p without modifying the
;   code. The button positions for making sure it works are hardcoded.
;   It also won't work with any UI changes that change the color or position of
;   the main menu elements.
;===============================================================================
; Made in 2023 by Chilli.
; GitHub:   TheChilliPL
; Discord:  @Chilli#2077
;===============================================================================

#Requires AutoHotkey v2.0

; Color of the selected UI elements
BrandColor := 0xfb0016
; Position of the main menu header
MenuBrandPos := [400, 100]
; Position of the save button
SaveBtnPos := [400, 250]
; Position of the load button
LoadBtnPos := [400, 325]
; Position of the 1st manual save slot
SlotM1Pos := [750, 460]
; Position of the confirm button
ConfirmPos := [1300, 630]
; Pixel mode used for detecting colors
PixelMode := ""

;
; Checks whether the pixel at the specified coordinates is the brand color.
;
IsBrand(Coordinates) {
    color := PixelGetColor(Coordinates[1], Coordinates[2], PixelMode)

    return color = BrandColor
}

;
; Waits until the specified predicate function returns a truthy value or
; the timeout is reached.
; The predicate is called repeatedly with a delay between each call.
; The delay can be multiplied by a factor after each call, to implement
; exponential backoff.
;
; Parameters:
; - Predicate
;     A function that returns a boolean. This function is called repeatedly
;     until it returns true or the timeout is reached.
; - Timeout (optional)
;     The maximum time to wait, in milliseconds. If the timeout is reached
;     before the predicate function returns true, the function returns false.
;     Default: 0 (no timeout)
; - Delay (optional)
;     The initial delay between calls to the predicate function,
;     in milliseconds.
;     Default: 100 (ms)
; - DelayMult (optional)
;     The factor by which the delay is multiplied after each call
;     to the predicate function.
;     Default: 1 (no exponential backoff)
;
; Returns:
;   True, if the predicate returned a truthy value before the timeout
;   was reached; otherwise, false.
;
WaitUntil(Predicate, Timeout := 0, Delay := 100, DelayMult := 1)
{
    TimeWaited := 0
    while Timeout and (TimeWaited < Timeout) {
        Sleep Delay
        TimeWaited += Delay
        Delay *= DelayMult

        PredRes := Predicate()

        if(PredRes)
            return true
    }
    return false
}

#HotIf WinActive("ahk_exe HITMAN3.exe")

SendMode "Event"
SetKeyDelay 50, 50

IsMenuOpened() => IsBrand(MenuBrandPos)
IsSaveSelected() => IsBrand(SaveBtnPos)
IsLoadSelected() => IsBrand(LoadBtnPos)
IsSlotM1Selected() => IsBrand(SlotM1Pos)
IsConfirmSelected() => IsBrand(ConfirmPos)

SaveGame() {
    if not IsMenuOpened() {
        Send "{Esc}" ; Open menu
        if not WaitUntil(IsMenuOpened, 1000) {
            return "Couldn't open the menu."
        }
    }
    if not IsSaveSelected() {
        return "Saving is unavailable."
    }
    MouseMove 0, 0, 0
    Send "{Enter}" ; Save
    if not WaitUntil(IsSlotM1Selected, 3000) {
        return "Slot 1 is not selected."
    }
    Send "{Enter}" ; Slot 1
    if not WaitUntil(IsConfirmSelected, 1000) {
        return "Confirm is not selected."
    }
    Send "{Enter}" ; Confirm
    if not WaitUntil(IsSaveSelected, 3000) {
        return "Didn't come back to menu."
    }
    Send "{Esc}" ; Exit menu
}

LoadGame() {
    if not IsMenuOpened() {
        Send "{Esc}" ; Open menu
        if not WaitUntil(IsMenuOpened, 1000) {
            return "Couldn't open the menu."
        }
    }
    if IsSaveSelected() {
        Send "{Down}" ; Save -> Load
        if not WaitUntil(IsLoadSelected, 1000) {
            return "Couldn't select load menu item."
        }
    }
    if not IsLoadSelected() {
        return "Unknown menu position."
    }
    MouseMove 0, 0, 0
    Send "{Enter}" ; Load
    if not WaitUntil(IsSlotM1Selected, 3000) {
        return "Slot 1 is not selected."
    }
    Send "{Enter}" ; Slot 1
    if not WaitUntil(IsConfirmSelected, 1000) {
        return "Confirm is not selected."
    }
    Send "{Enter}" ; Confirm
}

F5::
{
    BlockInput true
    Err := SaveGame()
    BlockInput false

    if Err {
        MsgBox Err
    }
}

F7::
{
    BlockInput true
    Err := LoadGame()
    BlockInput false

    if Err {
        MsgBox Err
    }
}