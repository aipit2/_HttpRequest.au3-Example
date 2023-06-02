Func NextTab()
	Local $TongTab = _GUICtrlTab_GetItemCount($__g_idTab_Main)
	Local $TabHienTai = GUICtrlRead($__g_idTab_Main)
	If $TabHienTai = ($TongTab-1) Then
		_GUICtrlTab_SetCurFocus($__g_idTab_Main,0)
	Else
		_GUICtrlTab_SetCurFocus($__g_idTab_Main,$TabHienTai+1)
	EndIf
EndFunc