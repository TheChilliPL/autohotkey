;===============================================================================
; VolumeBtns v1.0 by Chilli
;===============================================================================
; A script that modifies how much the volume is changed by the volume media
; buttons on your keyboard.
;===============================================================================
; Made in 2024 by Chilli.
; GitHub:   TheChilliPL
; Discord:  @chilli2077
;===============================================================================

#Requires AutoHotkey v2.0

; Amount by which the volume is changed.
volumeAmount := 1
; Whether to show the volume flyout when changing the volume.
showFlyout := true

;===============================================================================

Volume_Down:: {
  SoundSetVolume("-" volumeAmount)
  if showFlyout
    ShowVolumeFlyout()
}

Volume_Up:: {
  SoundSetVolume("+" volumeAmount)
  if showFlyout
    ShowVolumeFlyout()
}

; Source: https://www.reddit.com/r/AutoHotkey/comments/xn2x65/autohotkey_2_volume_up_and_down/
ShowVolumeFlyout() {
  try if shellProvider := ComObject("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
    try if flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}")
      ComCall(3, flyoutDisp, "int", 0, "uint", 0)
}
