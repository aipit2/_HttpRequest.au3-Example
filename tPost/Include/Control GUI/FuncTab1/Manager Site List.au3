; Hiển thị GUI quản lý các trang web
; Name ..........: ChooseWeb_Manager_GUI
; Description ...: Hiển thị GUI quản lý các trang web
; Syntax ........: ChooseWeb_Manager_GUI()
; Parameters ....: None
; Return values .: None
; Edit Date ......: 10/06/2022
Func ChooseWeb_Manager_GUI()
	Write_Log("=====================")
	Write_Log("+ Include\Control GUI\FuncTab 1.au3")
	Write_Log("+ ChooseWeb_Manager_GUI")
	#Region ### START Koda GUI section ### Form=c:\users\idont\appdata\local\temp\backups\mydocs\form choose web.kxf
	Local $Form2 = GUICreate("ManagerWeb", $GUI_WIDTH, $GUI_HEIGHT, -1, -1,BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_TABSTOP))
	Local $Combo1 = GUICtrlCreateCombo("", 549, 7, 335, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Group1 = GUICtrlCreateGroup("Tat ca trang web", 83, 58, 338, 294)
	GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
	Local $List1 = GUICtrlCreateList("", 103, 92, 304, 254)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $Group2 = GUICtrlCreateGroup("Danh sach hien tai", 546, 58, 338, 294)
	GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
	Local $List2 = GUICtrlCreateList("", 567, 92, 296, 254)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $Button1 = GUICtrlCreateButton("Them", 729, 396, 153, 50)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Button3 = GUICtrlCreateButton("Luu", 524, 396, 153, 50)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Checkbox1 = GUICtrlCreateCheckbox("Danh sach mac dinh", 131, 386, 246, 49)
	GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")

	GUISetBkColor($COLOR_BLUE,$Form2)
	Global $g_idList_ManagerWeb_AllWeb = $List1
	Global $g_idList_ManagerWeb_Current = $List2
	Global $g_idCombo_ManagerWeb_ListName = $Combo1
	Global $g_idButton_ManagerWeb_Save = $Button3
	Global $g_idCheckbox_ManagerWeb_Default = $Checkbox1
	GUICtrlSetBkColor($g_idButton_ManagerWeb_Save,$COLOR_GREEN)
	Local $idDummy_KeyLeft = GUICtrlCreateDummy()
	Local $idDummy_KeyRight = GUICtrlCreateDummy()
	Local $idDummy_AddAll = GUICtrlCreateDummy()
	WinSetTitle("ManagerWeb","","Chọn Web")
	GUICtrlSetData($Group1,"Tất cả trang web")
	GUICtrlSetData($Group2,"Danh sách web hiện tại")
	GUICtrlSetData($Button1,"Thêm")
	GUICtrlSetData($Button3,"Lưu")
	GUICtrlSetData($Checkbox1,"Danh sách mặc định")
	GUICtrlSetFont($List1,15)
	GUICtrlSetFont($List2,15)
	Local $menu = GUICtrlCreateMenu("Danh sách")
	Local $idMenu_newList = GUICtrlCreateMenuItem("Danh sách mới" & @TAB & @TAB & "Ctrl + N", $menu)
	Local $idMenu_removeList = GUICtrlCreateMenuItem("Xóa danh sách", $menu)
	GUISetOnEvent($GUI_EVENT_CLOSE,"ChooseWeb_Manager_Exit",$Form2)
	GUICtrlSetOnEvent($Combo1,"ChooseWeb_Manager_LoadWebFromList")
	GUICtrlSetOnEvent($Button1,"ChooseWeb_Manager_AddOrRemove")
	GUICtrlSetOnEvent($List1,"ChooseWeb_Manager_ClickLeft")
	GUICtrlSetOnEvent($List2,"ChooseWeb_Manager_ClickRight")
	GUICtrlSetOnEvent($idDummy_KeyLeft,"ChooseWeb_Manager_KeyLeft")
	GUICtrlSetOnEvent($idDummy_KeyRight,"ChooseWeb_Manager_KeyRight")
	GUICtrlSetOnEvent($g_idButton_ManagerWeb_Save,"ChooseWeb_Manager_SaveList")
	GUICtrlSetOnEvent($idMenu_newList,"ChooseWeb_Manager_AddList")
	GUICtrlSetOnEvent($idMenu_removeList,"ChooseWeb_Manager_RemoveList")
	GUICtrlSetOnEvent($idDummy_AddAll,"ChooseWeb_Manager_AddOrRemoveAll")
	GUICtrlSetOnEvent($g_idCheckbox_ManagerWeb_Default,"ChooseWeb_Manager_SetDefaultList")
	Local $arrayHotkey = [["{TAB}",$Button1]]
	_ArrayAdd($arrayHotkey,"{Left}|" & $idDummy_KeyLeft)
	_ArrayAdd($arrayHotkey,"{Right}|" & $idDummy_KeyRight)
	_ArrayAdd($arrayHotkey,"^s|" & $g_idButton_ManagerWeb_Save)
	_ArrayAdd($arrayHotkey,"^a|" & $idDummy_AddAll)
	GUISetAccelerators($arrayHotkey,$Form2)
	GUISetState(@SW_SHOW)
	ChooseWeb_Manager_LoadList()
	ChooseWeb_Manager_LoadAllWeb()
	#EndRegion ### END Koda GUI section ###
EndFunc

; Thoát khỏi GUI quản lý trang web
; Name ..........: ChooseWeb_Manager_Exit
; Description ...: Thoát khỏi GUI quản lý trang web
; Syntax ........: ChooseWeb_Manager_Exit()
; Return values .: 1 - Succes
;				 : 0 - Failure
; Author ........: Trần Hùng
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_Exit()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_Exit")
	Return GUIDelete(@GUI_WinHandle)
EndFunc

; Load tên danh sách đã lưu rồi thêm vào Combobox
; Name ..........: ChooseWeb_Manager_LoadList
; Description ...: Load tên danh sách đã lưu rồi thêm vào Combobox
; Syntax ........: ChooseWeb_Manager_LoadList()
; Return values .: Success: $arrayName - Mảng tên các danh sách load được
;				   Fail: 0 - Không tìm thấy danh sách nào
; Author ........: Trần Hùng
; Requires ......: $REG_SITELIST: folder chứa các danh sách đã lưu
;				   $g_idCombo_ManagerWeb_ListName: id combobox để chứa tên các danh sách
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_LoadList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_LoadList")
	Local $i = 1
	Local $arrayName[0]
	While 1
		Local $readReg = RegEnumVal($REG_SITELIST,$i)
		If $readReg = "" Then
			ExitLoop
		Else
			_ArrayAdd($arrayName,_Base64ToString($readReg))
			$i += 1
		EndIf
	WEnd
	If UBound($arrayName) <= 0 Then ; Không tìm thấy danh sách nào
		ErrorShow(48,"","Xin vui lòng thêm danh sách mới")
		GUICtrlSetData($g_idCombo_ManagerWeb_ListName,"|") ; Reset danh sách để khi xóa danh sách cuối cùng thì tên cũng xóa luôn
		Return 0
	EndIf
	GUICtrlSetData($g_idCombo_ManagerWeb_ListName,"|" & _ArrayToString($arrayName))
	_GUICtrlComboBox_SetCurSel($g_idCombo_ManagerWeb_ListName,0)
	ChooseWeb_Manager_LoadWebFromList() ; Load web từ list đầu tiên
	Return $arrayName
EndFunc

; Hiển thị tất cả những web hiện
; Name ..........: ChooseWeb_Manager_LoadAllWeb
; Description ...: Hiển thị tất cả những web hiện
; Syntax ........: ChooseWeb_Manager_LoadAllWeb()
; Return values .: @error - 1 - Không tìm thấy mảng (Lỗi nghiêm trọng cần kiểm tra liền)
;				   @error - 2 - Đã trùng tất cả (Không cần hiển thị gì)
;				   True - Thành công
; Author ........: Trần Hùng
; Require .......: $arrayMain: Mảng website và limit title (Dạng [web,limit])
;                : $g_idList_ManagerWeb_AllWeb: Listbox chứa tất cả trang web
;				 : $g_idList_ManagerWeb_Current: Listbox chứa web của danh sách hiện tại
; Modified ......: 07/10/2022
Func ChooseWeb_Manager_LoadAllWeb()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_LoadAllWeb")
	Local $arrayAdd[0]
	If IsArray($arrayMain) = 0 Then
		ErrorShow(16,"Thông báo lỗi nghiêm trọng","Không tìm thấy giá trị $arrayMain")
		Return SetError(1)
	EndIf
	; Xóa những trang trùng có ở list danh sánh hiện tại
	For $i = 0 To UBound($WEB_LIMIT) - 1
		Local $search = _GUICtrlListBox_FindString($g_idList_ManagerWeb_Current,$WEB_LIMIT[$i][0])
		If $search = -1 Then
			_ArrayAdd($arrayAdd,$WEB_LIMIT[$i][0]) ; 0 is site
		EndIf
	Next
	If UBound($arrayAdd) <= 0 Then
		GUICtrlSetData($g_idList_ManagerWeb_AllWeb,"|") ; Reset tên vì không có web nào
		Return SetError(2)
	EndIf
	GUICtrlSetData($g_idList_ManagerWeb_AllWeb,"|" & _ArrayToString($arrayAdd))
	Return True
EndFunc

; Hiển thị website từ danh sách đã chọn
; Name ..........: ChooseWeb_Manager_LoadWebFromList
; Description ...: Hiển thị website từ danh sách đã chọn
; Syntax ........: ChooseWeb_Manager_LoadWebFromList()
; Return values .: @error = 1: Chưa chọn tên danh sách - Return 1
;				   @error = 2: Danh sách không chưa web - Return 2
;				   Success: $readReg: Danh sách website lấy được từ list (Dạng web1|web2)
; Author ........: Trần Hùng
; Require .......: $g_idCombo_ManagerWeb_ListName: Combobox tên danh sách
;				   $REG_SITELIST: Địa chỉ folder chứa danh sách web
;				   $g_idList_ManagerWeb_Current: Listbox tên các web trong danh sách hiện tại
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_LoadWebFromList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_LoadWebFromList")
	Local $listName = GUICtrlRead($g_idCombo_ManagerWeb_ListName)
	If $listName = "" Then
		ErrorShow(48,"","Xin vui lòng chọn danh sách",3)
		Return SetError(1,"Chưa chọn tên danh sách",1)
	EndIf

	Local $readReg = RegRead($REG_SITELIST,_StringToBase64($listName))
	If $readReg = "" Then
		GUICtrlSetData($g_idList_ManagerWeb_Current,"|") ; Xóa danh sách cũ
		ChooseWeb_Manager_LoadAllWeb() ; Load lại tất cả web
		Return SetError(2,"Danh sách không chưa web",2)
	EndIf
	GUICtrlSetData($g_idList_ManagerWeb_Current,"|" & $readReg)
	ChooseWeb_Manager_LoadAllWeb() ; Load lại danh sách tất cả để xóa những web trùng
	GUICtrlSetState($g_idCheckbox_ManagerWeb_Default,ChooseWeb_Manager_LoadDefaultList())
	Return $readReg
EndFunc

; Cài đặt danh sách mặc định khi mở phần mềm
; Name ..........: ChooseWeb_Manager_LoadDefaultList
; Description ...: Cài đặt danh sách mặc định khi mở phần mềm
; Syntax ........: ChooseWeb_Manager_LoadDefaultList()
; Return values .: 1 - Danh sách hiện tại là danh sách mặc định
;                : 4 - Danh sách hiện tại không phải danh sách mặc định
; Author ........: Trần Hùng
; Global Var     : $g_idCheckbox_ManagerWeb_Default - Checkbox có phải danh sách mặc định không
;                : $g_idCombo_ManagerWeb_ListName - Combobox tên danh sách
;                : $REG_CONFIG - file config
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_LoadDefaultList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_LoadDefaultList")
	Local $listName = GUICtrlRead($g_idCombo_ManagerWeb_ListName)
	Write_Log("$listName: " & $listName)
	Local $defaultListName = RegRead($REG_CONFIG,"DEFAULT_LIST")
	Write_Log("$defaultListName: " & $defaultListName)
	If $defaultListName = $listName Then
		Write_Log('> List "' & $listName & '" là list default')
		Return 1
	Else
		Write_Log('> List "' & $listName & '" không phải list default')
		Return 4
	EndIf
EndFunc

; Cài đặt danh sách mặc định khi mở phần mềm
; Name ..........: ChooseWeb_Manager_SetDefaultList
; Description ...: Cài đặt danh sách mặc định khi mở phần mềm
; Syntax ........: ChooseWeb_Manager_SetDefaultList()
; Return values .: True - Setting thành công
;                : False - Thất bại
; Author ........: Trần Hùng
; Global Var     : $g_idCheckbox_ManagerWeb_Default - Checkbox có phải danh sách mặc định không
;                : $g_idCombo_ManagerWeb_ListName - Combobox tên danh sách
;                : $REG_CONFIG - file config
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_SetDefaultList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_SetDefaultList")
	Local $checkOrNo = GUICtrlRead($g_idCheckbox_ManagerWeb_Default)
	Switch $checkOrNo
		Case 1
			Local $listName = GUICtrlRead($g_idCombo_ManagerWeb_ListName)
			If RegWrite($REG_CONFIG,"DEFAULT_LIST","REG_SZ",$listName) = 1 Then
				Return True
			Else
				ErrorShow(16,"","Gặp lỗi khi cài đặt danh sách mặc định",3)
				Return False
			EndIf
		Case 4
			; Kiểm tra xem đã có Default list chưa
			; Nếu rồi thì xóa
			If RegWrite($REG_CONFIG,"DEFAULT_LIST","REG_SZ","") = 1 Then
				Return True
			Else
				ErrorShow(16,"","Gặp lỗi khi cài đặt danh sách mặc định",3)
				Return False
			EndIf
		Case Else
			ErrorShow(16,"","Gặp lỗi khi cài đặt danh sách mặc định",3)
			Return False
	EndSwitch
EndFunc

; Kiểm tra xem người dùng muốn thêm web hay xóa
; Name ..........: ChooseWeb_Manager_AddOrRemove
; Description ...: Kiểm tra xem người dùng muốn thêm web hay xóa
; Syntax ........: ChooseWeb_Manager_AddOrRemove()
; Return values .: 1 - Thêm web
;                : 2 - Xóa web
;                : 0 - Người dùng không chọn web
; Author ........: Trần Hùng
; Require .......: $g_idList_ManagerWeb_AllWeb: Listbox chứa tất cả trang web
;                : $g_idList_ManagerWeb_Current: Listbox tên các web trong danh sách hiện tại
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_AddOrRemove()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_AddOrRemove")
	Local $checkLeft = GUICtrlRead($g_idList_ManagerWeb_AllWeb)
	Local $checkRight = GUICtrlRead($g_idList_ManagerWeb_Current)
	If $checkLeft <> "" And $checkRight = "" Then
		ChooseWeb_Manager_AddWeb()
		Return 1
	ElseIf $checkLeft = "" And $checkRight <> "" Then
		ChooseWeb_Manager_RemoveWeb()
		Return 2
	Else
		ErrorShow(16,"","Xin vui lòng chọn web")
		Return 0
	EndIf
EndFunc

; Thêm web vào trong danh sách
; Name ..........: ChooseWeb_Manager_AddWeb
; Description ...: Thêm web vào trong danh sách
; Syntax ........: ChooseWeb_Manager_AddWeb()
; Return values .: True - Success
;				   False - Failure
; Author ........: Trần Hùng
; Require .......: $g_idList_ManagerWeb_AllWeb: Listbox chứa tất cả trang web
;                : $g_idList_ManagerWeb_Current: Listbox tên các web trong danh sách hiện tại
;                : $g_idButton_ManagerWeb_Save: Button lưu danh sách
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_AddWeb()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_AddWeb")
	Local $siteName = GUICtrlRead($g_idList_ManagerWeb_AllWeb)
	Local $siteIndex = _GUICtrlListBox_GetCurSel($g_idList_ManagerWeb_AllWeb)
	If $siteIndex = -1 Then
		Return False
	Else
		_GUICtrlListBox_DeleteString($g_idList_ManagerWeb_AllWeb,$siteIndex)
		_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_AllWeb,$siteIndex) ; Click vào item tiếp theo ; Quan trọng vãi lồn m đừng có xóa
		_GUICtrlListBox_ClickItem($g_idList_ManagerWeb_AllWeb,$siteIndex) ; Quan trọng vãi lồn m đừng có xóa
		GUICtrlSetData($g_idList_ManagerWeb_Current,$siteName)
		GUICtrlSetBkColor($g_idButton_ManagerWeb_Save,$COLOR_ORANGE)
		Return True
	EndIf
EndFunc

; Xóa web khỏi danh sách
; Name ..........: ChooseWeb_Manager_RemoveWeb
; Description ...: Xóa web khỏi danh sách
; Syntax ........: ChooseWeb_Manager_RemoveWeb()
; Return values .: 1 - Success
;				   0 - Fail
; Author ........: Trần Hùng
; Require .......: $g_idList_ManagerWeb_AllWeb: Listbox chứa tất cả trang web
;                : $g_idList_ManagerWeb_Current: Listbox tên các web trong danh sách hiện tại
;                : $g_idButton_ManagerWeb_Save: Button lưu danh sách
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_RemoveWeb()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_RemoveWeb")
	Local $siteName = GUICtrlRead($g_idList_ManagerWeb_Current)
	Local $siteIndex = _GUICtrlListBox_GetCurSel($g_idList_ManagerWeb_Current)
	If $siteIndex = -1 Then
		Return 0
	Else
		_GUICtrlListBox_DeleteString($g_idList_ManagerWeb_Current,$siteIndex)
		_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_Current,$siteIndex) ; Click vào item tiếp theo ; Quan trọng vãi lồn m đừng có xóa
		_GUICtrlListBox_ClickItem($g_idList_ManagerWeb_Current,$siteIndex) ; Quan trọng vãi lồn m đừng có xóa
		GUICtrlSetData($g_idList_ManagerWeb_AllWeb,$siteName)
		GUICtrlSetBkColor($g_idButton_ManagerWeb_Save,$COLOR_ORANGE)
		Return 1
	EndIf
EndFunc

; Lưu danh sách vào Reg
; Name ..........: ChooseWeb_Manager_SaveList
; Description ...: Lưu danh sách vào Reg
; Syntax ........: ChooseWeb_Manager_SaveList()
; Parameters ....: None
; Return values .: True: Lưu dánh sách thành công
;                : @error - 1 - Chưa chọn danh sách muốn lưu
;                : @error - 2 - Không đọc được tổng số item
;                : @error - 3 - Không có item nào trong list
;                : @error - 4 - Gặp lỗi khi ghi dữ liệu vào Reg
; Author ........: Trần Hùng
; Cập nhật ......: 06/10/2022
Func ChooseWeb_Manager_SaveList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_SaveList")
	Local $listName = GUICtrlRead($g_idCombo_ManagerWeb_ListName)
	If $listName = "" Then
		ErrorShow(48,"","Xin vui lòng chọn danh sách muốn lưu",3)
		Return SetError(1)
	EndIf
	; Lấy tổng item
	Local $totalItem = _GUICtrlListBox_GetCount($g_idList_ManagerWeb_Current)
	If $totalItem = -1 Then
		ErrorShow(16,"Gặp lỗi khi lưu danh sách","Xin vui lòng thử lại",3)
		Return SetError(2)
	ElseIf $totalItem = 0 Then
		ErrorShow(48,"","Xin vui lòng thêm web vào danh sách trước khi lưu",3)
		Return SetError(3)
	EndIf
	; Thêm item vào mảng
	Local $arraySave[0]
	For $i = 0 To $totalItem - 1
		_ArrayAdd($arraySave,_GUICtrlListBox_GetText($g_idList_ManagerWeb_Current,$i))
	Next
	; Ghi mảng vào Reg
	If RegWrite($REG_SITELIST,_StringToBase64($listName),"REG_SZ",_ArrayToString($arraySave,"|")) = 1 Then
		GUICtrlSetBkColor($g_idButton_ManagerWeb_Save,$COLOR_GREEN)
		ErrorShow(64,'Thành công',"Lưu danh sách thành công",2)
		Return True
	Else
		ErrorShow(16,'Thất bại',"Lưu danh sách thất bại",3)
		Return SetError(4)
	EndIf
EndFunc

; Tạo danh sách web mới
; Name ..........: ChooseWeb_Manager_AddList
; Description ...: Tạo danh sách web mới
; Syntax ........: ChooseWeb_Manager_AddList()
; Return values .: 2 - Thêm danh sách thành công
;                : 1 - Người dùng để trống tên
;                : 0 - Gặp lỗi khi lấy tên
; Author ........: Trần Hùng
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_AddList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_AddList")

	Local $msg = "Xin vui lòng nhập tên danh sách muốn thêm"
	Local $name = InputBox("Nhập tên danh sách",$msg)
	If @error Then
		If @error <> 1 Then
			ErrorShow(16,'',"Không thể tạo danh sách",3)
			Return 0
		EndIf
	ElseIf $name = "" Then
		ErrorShow(48,'',"Tên không được để trống",3)
		Return 1
	Else
		RegWrite($REG_SITELIST,_StringToBase64($name),"REG_SZ","")
		GUICtrlSetData($g_idCombo_ManagerWeb_ListName,$name) ; Thêm 1 tên mới vào Combo
		GUICtrlSetData($__g_idCombo_ChooseWeb_ListName,$name) ; Thêm 1 tên mới vào Combo ở tab 1 luôn để k phải load lại phần mềm
		_GUICtrlComboBox_SelectString($g_idCombo_ManagerWeb_ListName,$name)
		GUICtrlSetData($g_idList_ManagerWeb_Current,"|") ; Reset lại list hiện tại
		GUICtrlSetState($g_idCheckbox_ManagerWeb_Default, $GUI_UNCHECKED)
		ChooseWeb_Manager_LoadAllWeb() ; Load lại tất cả web
		Return 2
	EndIf
EndFunc

; Xóa danh sách đang chọn
; Name ..........: ChooseWeb_Manager_RemoveList
; Description ...: Xóa danh sách đang chọn
; Syntax ........: ChooseWeb_Manager_RemoveList()
; Return values .: True - Xóa danh sách thành công
;                : 0 - Người dùng không chọn danh sách nào để xóa
;                : 1 - Gặp lỗi khi xóa danh sách bằng RegDelete
; Author ........: Trần Hùng
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_RemoveList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_RemoveList")

	Local $listName = GUICtrlRead($g_idCombo_ManagerWeb_ListName)
	If $listName = "" Then
		ErrorShow(48,"","Xin vui lòng chọn danh sách cần xóa",3)
		Return 0
	EndIf

	If RegDelete($REG_SITELIST,_StringToBase64($listName)) = 1 Then
		If $listName = RegRead($REG_CONFIG,"DEFAULT_LIST") Then ; Nếu list muốn xóa là list default thì xóa list default
			RegWrite($REG_CONFIG,"DEFAULT_LIST","REG_SZ","")
		EndIf
		GUICtrlSetData($g_idList_ManagerWeb_Current,"|") ; Reset danh sách hiện tại
		ChooseWeb_Manager_LoadList()
		ChooseWeb_Manager_LoadAllWeb()
		ErrorShow(64,"Thành công","Xóa danh sách thành công",2)
		Return True
	Else
		ErrorShow(16,"","Xóa danh sách thất bại",3)
		Return 1
	EndIf
EndFunc

; Kiểm tra người dùng muốn thêm tất cả hay xóa
; Name ..........: ChooseWeb_Manager_AddOrRemoveAll
; Description ...: Kiểm tra người dùng muốn thêm tất cả hay xóa
; Syntax ........: ChooseWeb_Manager_AddOrRemoveAll()
; Return values .: 1 - Thêm tất cả
;                : 2 - Xóa tất cả
;                : 0 - Người dùng không chọn bên nào cả
; Author ........: Trần Hùng
; Require .......: $g_idList_ManagerWeb_AllWeb: Listbox chứa tất cả trang web
;                : $g_idList_ManagerWeb_Current: Listbox tên các web trong danh sách hiện tại
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_AddOrRemoveAll()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_ManagerAddOrRemoveAll")
	Local $checkLeft = GUICtrlRead($g_idList_ManagerWeb_AllWeb)
	Local $checkRight = GUICtrlRead($g_idList_ManagerWeb_Current)
	If $checkLeft <> "" And $checkRight = "" Then
		ChooseWeb_Manager_AddAll()
		Return 1
	ElseIf $checkLeft = "" And $checkRight <> "" Then
		ChooseWeb_Manager_RemoveAll()
		Return 2
	Else
		ErrorShow(16,"","Xin vui lòng chọn web",3)
		Return 0
	EndIf
EndFunc

; Thêm tất cả web vào danh sách hiện tại
; Name ..........: ChooseWeb_Manager_AddAll
; Description ...: Thêm tất cả web vào danh sách hiện tại
; Syntax ........: ChooseWeb_Manager_AddAll()
; Return values .: 1 - Thêm thành công
;                : 0 - Không có web nào trong danh sách để thêm
; Author ........: Trần Hùng
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_AddAll()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_AddAll")
	Local $totalItem = _GUICtrlListBox_GetCount($g_idList_ManagerWeb_AllWeb)
	If $totalItem <= 0 Then
		Return 0
	EndIf
	For $i = 0 To $totalItem - 1
		GUICtrlSetData($g_idList_ManagerWeb_Current,_GUICtrlListBox_GetText($g_idList_ManagerWeb_AllWeb,$i))
	Next
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_Current,0)
	GUICtrlSetData($g_idList_ManagerWeb_AllWeb,"|")
	Return 1
EndFunc

; Xóa tất cả web khỏi danh sách hiện tại
; Name ..........: ChooseWeb_Manager_RemoveAll
; Description ...: Xóa tất cả web khỏi danh sách hiện tại
; Syntax ........: ChooseWeb_Manager_RemoveAll()
; Return values .: 1 - Xóa thành công
;                : 0 - Không có web nào trong danh sách để xóa
; Author ........: Trần Hùng
; Modified ......: 09/08/2022
Func ChooseWeb_Manager_RemoveAll()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_Manager_RemoveAll")
	Local $totalItem = _GUICtrlListBox_GetCount($g_idList_ManagerWeb_Current)
	If $totalItem <= 0 Then
		Return 0
	EndIf
	For $i = 0 To $totalItem - 1
		GUICtrlSetData($g_idList_ManagerWeb_AllWeb,_GUICtrlListBox_GetText($g_idList_ManagerWeb_Current,$i))
	Next
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_AllWeb,0)
	GUICtrlSetData($g_idList_ManagerWeb_Current,"|")
	Return 1
EndFunc

; Chuyển focus sang list bên trái
; Name ..........: ChooseWeb_Manager_ClickLeft
; Description ...: Chuyển focus sang list bên trái
; Syntax ........: ChooseWeb_Manager_ClickLeft()
; Author ........: Trần Hùng
Func ChooseWeb_Manager_ClickLeft()
	Write_Log("=====================")
	Write_Log("+ ChooseWeb_Manager_ClickLeft")
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_Current,-1) ; Bỏ Focus bên phải
	Local $currentSite = GUICtrlRead($g_idList_ManagerWeb_AllWeb)
	If $currentSite = "" Then ; Nếu không chọn web nào thì sẽ chọn web đầu tiên
		_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_AllWeb,0)
	EndIf
EndFunc

; Chuyển focus sang list bên phải
; Name ..........: ChooseWeb_Manager_ClickRight
; Description ...: Chuyển focus sang list bên phải
; Syntax ........: ChooseWeb_Manager_ClickRight()
; Author ........: Trần Hùng
Func ChooseWeb_Manager_ClickRight()
	Write_Log("=====================")
	Write_Log("+ ChooseWeb_Manager_ClickRight")
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_AllWeb,-1) ; Bỏ Focus bên trái
	Local $currentSite = GUICtrlRead($g_idList_ManagerWeb_Current)
	If $currentSite = "" Then ; Nếu không chọn web nào thì sẽ chọn web đầu tiên
		_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_Current,0)
	EndIf
EndFunc

; Chuyển focus sang list bên trái khi bấm nút mũi tên trái
; Name ..........: ChooseWeb_Manager_KeyLeft
; Description ...: Chuyển focus sang list bên trái khi bấm nút mũi tên trái
; Syntax ........: ChooseWeb_Manager_KeyLeft()
; Author ........: Trần Hùng
; Global Var	 : $g_idList_ManagerWeb_Current: Listbox chứa tất cả trang web
;				 : $g_idList_ManagerWeb_AllWeb: Listbox tên các web trong danh sách hiện tại
Func ChooseWeb_Manager_KeyLeft()
	Write_Log("=====================")
	Write_Log("+ ChooseWeb_Manager_KeyLeft")
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_Current,-1)
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_AllWeb,0)
	GUICtrlSetState($g_idList_ManagerWeb_AllWeb,$GUI_FOCUS)
EndFunc

; Chuyển focus sang list bên phải khi bấm nút mũi tên phải
; Name ..........: ChooseWeb_Manager_KeyLeft
; Description ...: Chuyển focus sang list bên phải khi bấm nút mũi tên phải
; Syntax ........: ChooseWeb_Manager_KeyLeft()
; Author ........: Trần Hùng
; Global Var	 : $g_idList_ManagerWeb_Current: Listbox chứa tất cả trang web
;				 : $g_idList_ManagerWeb_AllWeb: Listbox tên các web trong danh sách hiện tại
Func ChooseWeb_Manager_KeyRight()
	Write_Log("=====================")
	Write_Log("+ ChooseWeb_Manager_KeyRight")
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_AllWeb,-1)
	_GUICtrlListBox_SetCurSel($g_idList_ManagerWeb_Current,0)
	GUICtrlSetState($g_idList_ManagerWeb_Current,$GUI_FOCUS)
EndFunc