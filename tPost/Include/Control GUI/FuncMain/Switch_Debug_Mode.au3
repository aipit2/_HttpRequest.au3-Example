Global $DEBUG_MODE = False
Func Switch_Debug_Mode()
	Local $currentState = GUICtrlRead($__g_idMenu_Debug_Mode)
	If $currentState = 68 Then
		GUICtrlSetState($__g_idMenu_Debug_Mode,$GUI_CHECKED)
		$DEBUG_MODE = TRUE
	Else
		GUICtrlSetState($__g_idMenu_Debug_Mode,$GUI_UNCHECKED)
		$DEBUG_MODE = FALSE
	EndIf
EndFunc
