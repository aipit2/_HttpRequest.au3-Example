Func Hotkey_Setting()
	Write_Log("====================")
	Write_Log("+ include/Control GUI/Hotkey Setting.au3")
	Write_Log("+ Hotkey_Setting")
	Local $currentTab = GUICtrlRead($__g_idTab_Main)
	Switch $currentTab
		Case 3
			Address_LoadSite()
			Address_ChangeSite() ; Load danh sách địa chỉ đã lưu
	EndSwitch
EndFunc

Func Hotkey_Ctrl_A()
	Local $currentTab = GUICtrlRead($__g_idTab_Main)
	Switch $currentTab
		Case 0	; Tab chọn web
			ChooseWeb_AddOrRemoveAll()
		Case Else
			StringSelectAll()
	EndSwitch
EndFunc

Func Hotkey_Ctrl_S()
	Post_Manager_SavePost()
EndFunc

Func Hotkey_Ctrl_N()
	Post_Manager_NewPost()
EndFunc

Func Hotkey_Ctrl_Z()
	Local $currentTab = GUICtrlRead($__g_idTab_Main)
	Switch $currentTab
		Case 2
			TitleManager_LastTitle()
	EndSwitch
EndFunc

Func Hotkey_Ctrl_Tab()
	NextTab()
EndFunc

Func Hotkey_Tab()
	Local $currentTab = GUICtrlRead($__g_idTab_Main)
	Switch $currentTab
		Case 0
			ChooseWeb_AddOrRemove()
		Case 2
			TitleManager_NextSite()
	EndSwitch
EndFunc

Func Hotkey_Left()
	Local $currentTab = GUICtrlRead($__g_idTab_Main)
	Switch $currentTab
		Case 0
			ChooseWeb_KeyLeft()
		Case 5
			Tab6_KeyLeft()
	EndSwitch
EndFunc

Func Hotkey_Right()
	Local $currentTab = GUICtrlRead($__g_idTab_Main)
	Switch $currentTab
		Case 0
			ChooseWeb_KeyRight()
		Case 5
			Tab6_KeyRight()
	EndSwitch
EndFunc