; Load những danh sách đã lưu vào Combobox
; Name ..........: ChooseWeb_LoadList
; Description ...: Load những danh sách đã lưu vào Combobox
; Syntax ........: ChooseWeb_LoadList()
; Return values .: $arrayName - Mảng tên các danh sách đã lưu trong máy
;                  @error - 1 - Không có danh sách nào được lưu trong máy
; Author ........: Trần Hùng
; Global var     : $REG_SITELIST: địa chỉ reg chứa các danh sách đã lưu
;                : $__g_idCombo_ChooseWeb_ListName: Combobox tên danh sách web hiện tại
; Modified ......: 10/08/2022
Func ChooseWeb_LoadList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_LoadList")
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
		Write_Log("! Không tìm thấy danh sách nào")
		GUICtrlSetData($__g_idCombo_ChooseWeb_ListName,"|") ; Reset danh sách để khi xóa danh sách cuối cùng thì tên cũng xóa luôn
		Return SetError(1)
	EndIf
	GUICtrlSetData($__g_idCombo_ChooseWeb_ListName,"|" & _ArrayToString($arrayName))
	_GUICtrlComboBox_SetCurSel($__g_idCombo_ChooseWeb_ListName,0)
	ChooseWeb_LoadWebFromList() ; Load web từ list đầu tiên
	Return $arrayName
EndFunc

; Hiển thị website từ danh sách đã chọn
; Name ..........: ChooseWeb_LoadWebFromList
; Description ...: Hiển thị website từ danh sách đã chọn
; Syntax ........: ChooseWeb_LoadWebFromList()
; Return values .: 0: Danh sách không có trang nào cả
;				   1: Thành công
; Author ........: Trần Hùng
; Global var.....: $__g_idCombo_ChooseWeb_ListName: Combobox tên danh sách
;				 : $__g_idList_ChooseWeb_Post: Listbox tên các web trong danh sánh cần đăng
;				 : $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;				 : $REG_SITELIST: folder chứa các danh sách đã lưu
; Modified ......: 10/08/2022
Func ChooseWeb_LoadWebFromList()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_LoadWebFromList")
	Local $currentList = GUICtrlRead($__g_idCombo_ChooseWeb_ListName)
	Write_Log("Bạn đã chọn list: " & $currentList)
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,-1) ; Bỏ Focus bên phải
	_GUICtrlListBox_ResetContent($__g_idList_ChooseWeb_Current) ; Reset content Listbox
	Local $loadSite = StringSplit(RegRead($REG_SITELIST,_StringToBase64($currentList)),"|",2)
	If IsArray($loadSite) = 1 Then
		For $i = 0 To UBound($loadSite) - 1
			Local $indexDelete = _GUICtrlListBox_FindString($__g_idList_ChooseWeb_Post,$loadSite[$i]) ; Tìm vị trí trùng cần xóa
			If $indexDelete = -1 Then
				GUICtrlSetData($__g_idList_ChooseWeb_Current,$loadSite[$i]) ; Ghi site vào Listbox
			EndIf
		Next
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,-1) ; Bỏ Focus bên phải
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,0) ; Click item 1 bên trái
		Return 1
	Else
		Return 0
	EndIf
EndFunc

; Kiểm tra xem người dùng muốn thêm web hay xóa
; Name ..........: ChooseWeb_AddOrRemove
; Description ...: Kiểm tra xem người dùng muốn thêm web hay xóa
; Syntax ........: ChooseWeb_AddOrRemove()
; Return values .: 1 - Thêm web
;                : 2 - Xóa web
;                : 0 - Người dùng không chọn web
; Author ........: Trần Hùng
; Global var.....: $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;				   $__g_idList_ChooseWeb_Post: Lixtbox tên các trang web trong danh sách cần đăng
; Modified ......: 10/08/2022
Func ChooseWeb_AddOrRemove()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_AddOrRemove")
	Local $checkLeft = GUICtrlRead($__g_idList_ChooseWeb_Current)
	Local $checkRight = GUICtrlRead($__g_idList_ChooseWeb_Post)
	If $checkLeft <> "" And $checkRight = "" Then
		ChooseWeb_AddWeb()
		Return 1
	ElseIf $checkLeft = "" And $checkRight <> "" Then
		ChooseWeb_RemoveWeb()
		Return 2
	Else
		ErrorShow(16,"","Xin vui lòng chọn web",3)
		Return 0
	EndIf
EndFunc

; Thêm web vào trong danh sách
; Name ..........: ChooseWeb_AddWeb
; Description ...: Thêm web vào trong danh sách
; Syntax ........: ChooseWeb_AddWeb()
; Return values .: 2 - Success
;				   1 - Người dùng không chọn web nào để thêm hoặc lỗi
;				   0 - Biến $arrayMain gặp lỗi không có giá trị
; Author ........: Trần Hùng
; Require .......: $__g_idList_ChooseWeb_Post: Lixtbox tên các trang web trong danh sách cần đăng
;                : $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;                : $arrayMain: Mảng chưa danh sách website và tiêu đề
; Edit date ......: 10/08/2022
Func ChooseWeb_AddWeb()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_AddWeb")
	Local $webName = GUICtrlRead($__g_idList_ChooseWeb_Current) ; Get tên site ở list bên trái
	Write_Log("Bạn đã chọn: " & $webName)
	If IsArray($arrayMain) = 0 Then
		Global $arrayMain[0][23]
		Return 0
	EndIf
	Local $seletedIndex = _GUICtrlListBox_GetCurSel($__g_idList_ChooseWeb_Current) ; Vị trí site hiện tại
	If $seletedIndex = -1 Then
		ErrorShow(16,'',"Xin vui lòng chọn 1 website")
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,0)
		Return 1
	Else
		_GUICtrlListBox_DeleteString($__g_idList_ChooseWeb_Current,$seletedIndex) ; Xóa tên
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,$seletedIndex) ; Click vào item tiếp theo
		GUICtrlSetData($__g_idList_ChooseWeb_Post,$webName) ; Thêm tên mới vào list phải
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,-1) ; Bỏ Focus bên phải
		_ArrayAdd($arrayMain,$webName)
		_PrintFromArray($arrayMain)
		TitleManager_SortTitle() ; Sắp xếp lại tiêu đề
		Return 2
	EndIf
EndFunc

; Thêm web vào trong danh sách
; Name ..........: ChooseWeb_RemoveWeb
; Description ...: Thêm web vào trong danh sách
; Syntax ........: ChooseWeb_RemoveWeb()
; Return values .: 1 - Success
;				   0 - Người dùng không chọn web nào để thêm hoặc lỗi
; Author ........: Trần Hùng
; Require .......: $__g_idList_ChooseWeb_Post: Lixtbox tên các trang web trong danh sách cần đăng
;                : $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;                : $arrayMain: Mảng chưa danh sách website và tiêu đề
; Modified ......: 10/08/2022
Func ChooseWeb_RemoveWeb()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_RemoveWeb")
	Local $webName = GUICtrlRead($__g_idList_ChooseWeb_Post) ; Get tên site ở list bên phải
	Write_Log("Bạn đã chọn: " & $webName)
	Local $seletedIndex = _GUICtrlListBox_GetCurSel($__g_idList_ChooseWeb_Post) ; Vị trí site hiện tại
	If $seletedIndex = -1 Then
		ErrorShow(16,'',"Xin vui lòng chọn 1 website")
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,0)
		Return 0
	Else
		_GUICtrlListBox_DeleteString($__g_idList_ChooseWeb_Post,$seletedIndex) ; Xóa tên
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,$seletedIndex) ; Click vào item tiếp theo
		GUICtrlSetData($__g_idList_ChooseWeb_Current,$webName) ; Thêm tên mới vào list trái
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,-1) ; Bỏ Focus bên trái
		Local $indexDelete = _ArraySearch($arrayMain,$webName)
		_ArrayDelete($arrayMain,$indexDelete)
		_PrintFromArray($arrayMain)
		Return 1
	EndIf
EndFunc

; Kiểm tra xem người dùng muốn thêm web hay xóa tất cả
; Name ..........: ChooseWeb_AddOrRemoveAll
; Description ...: Kiểm tra xem người dùng muốn thêm web hay xóa tất cả
; Syntax ........: ChooseWeb_AddOrRemoveAll()
; Return values .: 1 - Thêm tất cả
;                : 2 - Xóa tất cả
;                : 0 - Người dùng không chọn web
; Author ........: Trần Hùng
; Global var.....: $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;				 : $__g_idList_ChooseWeb_Post: Lixtbox tên các trang web trong danh sách cần đăng
; Modified ......: 10/08/2022
Func ChooseWeb_AddOrRemoveAll()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_AddOrRemoveAll")
	Local $checkLeft = GUICtrlRead($__g_idList_ChooseWeb_Current)
	Local $checkRight = GUICtrlRead($__g_idList_ChooseWeb_Post)
	If $checkLeft <> "" And $checkRight = "" Then
		ChooseWeb_AddAll()
		GUICtrlSetData($__g_idButton_ChooseWeb_Move,"Xóa")
		GUICtrlSetData($__g_idButton_ChooseWeb_MoveAll,"Xóa tất cả")
		Return 1
	ElseIf $checkLeft = "" And $checkRight <> "" Then
		ChooseWeb_RemoveAll()
		GUICtrlSetData($__g_idButton_ChooseWeb_Move,"Thêm")
		GUICtrlSetData($__g_idButton_ChooseWeb_MoveAll,"Thêm tất cả")
		Return 2
	Else
		ErrorShow(48,"","Xin vui lòng chọn web",3)
		Return 0
	EndIf
EndFunc

; Thêm tất cả web từ danh sách hiện tại sang danh sách cần đăng
; Name ..........: ChooseWeb_AddAll
; Description ...: Thêm tất cả web từ danh sách hiện tại sang danh sách cần đăng
; Syntax ........: ChooseWeb_AddAll()
; Return values .: 2 - Thêm thành công
;                : 1 - Mảng $arrayMain không có giá trị (Lỗi nghiêm trọng)
;                : 0 - Không xác định được số web trong danh sách
; Author ........: Trần Hùng
; Global var.....: $__g_idList_ChooseWeb_Post: Lixtbox tên các trang web trong danh sách cần đăng
;				 : $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;				 : $arrayMain: Mảng chưa danh sách website và tiêu đề
; Modified ......: 10/08/2022
Func ChooseWeb_AddAll()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_AddAll")
	Local $totalItem = _GUICtrlListBox_GetCount($__g_idList_ChooseWeb_Current)
	If $totalItem = -1 Then
		Return 0
	Else
		If IsArray($arrayMain) = 0 Then
			Global $arrayMain[0][23]
			Return 1
		EndIf
		For $i = 0 To $totalItem - 1
			Local $currentSite = _GUICtrlListBox_GetText($__g_idList_ChooseWeb_Current,0)
			GUICtrlSetData($__g_idList_ChooseWeb_Post,$currentSite)
			_ArrayAdd($arrayMain,$currentSite)
			_GUICtrlListBox_DeleteString($__g_idList_ChooseWeb_Current,0)
		Next
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,0) ; Click item 1 bên phải
;~ 		TitleSort()
		Return 2
	EndIf
EndFunc

; Xóa tất cả web khỏi danh sách web cần đăng
; Name ..........: ChooseWeb_RemoveAll
; Description ...: Xóa tất cả web khỏi danh sách web cần đăng
; Syntax ........: ChooseWeb_RemoveAll()
; Return values .: 1 - Xóa thành công
;                : 0 - Không xác định được số website trong danh sách muốn thêm
; Author ........: Trần Hùng
; Global var.....: $__g_idList_ChooseWeb_Post: Lixtbox tên các trang web trong danh sách cần đăng
;				 : $__g_idList_ChooseWeb_Current: Listbox tên các web trong danh sách hiện tại
;				 : $arrayMain: Mảng chưa danh sách website và tiêu đề
; Modified ......: 10/08/2022
Func ChooseWeb_RemoveAll()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_RemoveAll")
	Local $totalItem = _GUICtrlListBox_GetCount($__g_idList_ChooseWeb_Post)
	If $totalItem = -1 Then
		Return 0
	Else
		For $i = 0 To $totalItem - 1
			Local $siteName = _GUICtrlListBox_GetText($__g_idList_ChooseWeb_Post,0)
			GUICtrlSetData($__g_idList_ChooseWeb_Current,$siteName)
			Global $arrayMain[0][23] ; Xóa tất cả các site
			_GUICtrlListBox_DeleteString($__g_idList_ChooseWeb_Post,0)
		Next
		GUICtrlSetData($__g_idList_ChooseWeb_Post,"|")
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,0) ; Click item 1 bên phải
;~ 		TitleSort()
		Return 1
	EndIf
EndFunc

; Chuyển focus sang list bên trái khi bấm nút mũi tên trái
; Name ..........: ChooseWeb_KeyLeft
; Description ...: Chuyển focus sang list bên trái khi bấm nút mũi tên trái
; Syntax ........: ChooseWeb_KeyLeft()
; Author ........: Trần Hùng
; Global Var	 : $_g_idList_ManagerWeb_Current: Listbox chứa web của danh sách hiện tại
;				 : $__g_idList_ChooseWeb_Post: Listbox tên các web trong danh sánh cần đăng
; Modified ......: 10/08/2022
Func ChooseWeb_KeyLeft()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_KeyLeft")
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,-1)
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,0)
	GUICtrlSetState($__g_idList_ChooseWeb_Current,$GUI_FOCUS) ; Phải set focus thì mới ấn lên xuống được
	GUICtrlSetData($__g_idButton_ChooseWeb_Move,"Thêm")
	GUICtrlSetData($__g_idButton_ChooseWeb_MoveAll,"Thêm tất cả")
EndFunc

; Chuyển focus sang list bên phải khi bấm nút mũi tên phải
; Name ..........: ChooseWeb_KeyRight
; Description ...: Chuyển focus sang list bên phải khi bấm nút mũi tên phải
; Syntax ........: ChooseWeb_KeyRight()
; Author ........: Trần Hùng
; Global Var	 : $_g_idList_ManagerWeb_Current: Listbox chứa web của danh sách hiện tại
;				 : $__g_idList_ChooseWeb_Post: Listbox tên các web trong danh sánh cần đăng
; Modified ......: 11/08/2022
Func ChooseWeb_KeyRight()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_KeyRight")
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,-1)
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,0)
	GUICtrlSetState($__g_idList_ChooseWeb_Post,$GUI_FOCUS) ; Phải set focus thì mới ấn lên xuống được
	GUICtrlSetData($__g_idButton_ChooseWeb_Move,"Xóa")
	GUICtrlSetData($__g_idButton_ChooseWeb_MoveAll,"Xóa tất cả")
EndFunc

; Chuyển focus sang list bên trái
; Name ..........: ChooseWeb_ClickLeft
; Description ...: Chuyển focus sang list bên trái
; Syntax ........: ChooseWeb_ClickLeft()
; Author ........: Trần Hùng
; Global Var	 : $__g_idList_ChooseWeb_Current: Listbox chứa web của danh sách hiện tại
;				 : $__g_idList_ChooseWeb_Post: Listbox tên các web trong danh sánh cần đăng
; Modified ......: 10/08/2022
Func ChooseWeb_ClickLeft()
	Write_Log("=====================")
	Write_Log("+ ChooseWeb_ClickLeft")
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,-1) ; Bỏ Focus bên phải
	Local $currentSite = GUICtrlRead($__g_idList_ChooseWeb_Current)
	If $currentSite = "" Then ; Nếu không chọn web nào thì sẽ chọn web đầu tiên
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,0)
	EndIf
	GUICtrlSetData($__g_idButton_ChooseWeb_Move,"Thêm")
	GUICtrlSetData($__g_idButton_ChooseWeb_MoveAll,"Thêm tất cả")
EndFunc

; Chuyển focus sang list bên phải
; Name ..........: ChooseWeb_ClickRight
; Description ...: Chuyển focus sang list bên phải
; Syntax ........: ChooseWeb_ClickRight()
; Author ........: Trần Hùng
; Global Var	 : $__g_idList_ChooseWeb_Current: Listbox chứa web của danh sách hiện tại
;				 : $__g_idList_ChooseWeb_Post: Listbox tên các web trong danh sánh cần đăng
; Modified ......: 10/08/2022
Func ChooseWeb_ClickRight()
	Write_Log("=====================")
	Write_Log("+ FuncTab1.au3")
	Write_Log("+ ChooseWeb_ClickRight")
	_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Current,-1) ; Bỏ Focus bên trái
	Local $currentSite = GUICtrlRead($__g_idList_ChooseWeb_Post)
	If $currentSite = "" Then ; Nếu không chọn web nào thì sẽ chọn web đầu tiên
		_GUICtrlListBox_SetCurSel($__g_idList_ChooseWeb_Post,0)
	EndIf
	GUICtrlSetData($__g_idButton_ChooseWeb_Move,"Xóa")
	GUICtrlSetData($__g_idButton_ChooseWeb_MoveAll,"Xóa tất cả")
EndFunc



