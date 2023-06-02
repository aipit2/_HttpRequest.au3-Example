Func _TrayTip($sTitle,$sMsg,$iTimeout = 5,$iOption = 0)
    Opt("TrayIconHide", 0);Re-enables AutoIt Tray Icon.
    Local $hwnd_timer

    TrayTip($sTitle, $sMsg, $iTimeout, $iOption)

    $hwnd_timer = TimerInit()
    While (($iTimeout * 1000) - TimerDiff($hwnd_timer) > 0)
        Sleep(10)
    WEnd

    Opt("TrayIconHide", 1);Momentarily hides AutoIt Tray Icon as TrayTip cannot function without a tray icon.
EndFunc