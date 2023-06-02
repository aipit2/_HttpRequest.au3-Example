Global Const $ARRAY_WEB_VIP = FileReadToArray($FOLDER_MAIN_DATA & "ARRAY_WEB_VIP.data")
Global $__g_a_dataVipCurrentSite
Func VIP_Manager_GUI()
	Write_Log("=====================")
	Write_Log("+ VIP_Manager_GUI")
	Local $Form2 = GUICreate("Cài đặt tin VIP", 961, 541, -1, -1,BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_TABSTOP,$WM_SIZE))
	Local $Group1 = GUICtrlCreateGroup("Danh sách web", 83, 58, 338, 294)
	GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
	Global $__g_idList_Vip_Web = GUICtrlCreateList("", 103, 92, 304, 254)
	GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $Button1 = GUICtrlCreateButton("Mặc định", 729, 396, 153, 50)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Button3 = GUICtrlCreateButton("Lưu", 524, 396, 153, 50)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	GUIStartGroup()
	Global $__g_idLabel_VIP = GUICtrlCreateLabel("Số ngày VIP:", 523, 94, 113, 29)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Input1 = GUICtrlCreateInput("", 651, 94, 175, 24)
	GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
	Global $__g_idCombo_Vip_Type = GUICtrlCreateCombo("Combo1", 651, 134, 175, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
	GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
	Local $Label2 = GUICtrlCreateLabel("Loại VIP:", 523, 134, 77, 29)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Checkbox1 = GUICtrlCreateCheckbox("Checkbox1", 523, 182, 350, 40)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Checkbox2 = GUICtrlCreateCheckbox("Checkbox2", 523, 225, 350, 40)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Checkbox3 = GUICtrlCreateCheckbox("Checkbox3", 523, 267, 350, 40)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Local $Checkbox4 = GUICtrlCreateCheckbox("Checkbox4", 523, 310, 350, 40)
	GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
	Global $__g_a_Checkbox_Option_Vip = [$Checkbox1,$Checkbox2,$Checkbox3,$Checkbox4]
	GUIStartGroup()

	GUISetBkColor($COLOR_BLUE,$Form2)

	GUISetOnEvent($GUI_EVENT_CLOSE,"_Exit_GUI_Manager")
	GUICtrlSetOnEvent($__g_idList_Vip_Web,"VIP_Manager_ChangeSite")

	Global $__g_idInput_VIP_Date = $Input1
	GUICtrlSetOnEvent($__g_idInput_VIP_Date,"VIP_Manager_SaveDefault_Selected")
	GUICtrlSetOnEvent($__g_idCombo_Vip_Type,"VIP_Manager_ChangeType")

	Global $__g_idButton_VIP_Save = $Button3
	GUICtrlSetOnEvent($__g_idButton_VIP_Save,"VIP_Manager_SaveDefault_Selected")

	GUICtrlSetOnEvent($__g_a_Checkbox_Option_Vip[0],"VIP_Manager_SaveDefault_Selected")
	GUICtrlSetOnEvent($__g_a_Checkbox_Option_Vip[1],"VIP_Manager_SaveDefault_Selected")
	GUICtrlSetOnEvent($__g_a_Checkbox_Option_Vip[2],"VIP_Manager_SaveDefault_Selected")
	GUICtrlSetOnEvent($__g_a_Checkbox_Option_Vip[3],"VIP_Manager_SaveDefault_Selected")
	Write_Log("B1: Hiển thị GUI thành công",$CONSOLE_SUCCESS)

	VIP_Manager_LoadWeb() ; Load danh sách web vip

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND_VIP")

	GUISetState(@SW_SHOW,$Form2)
EndFunc

Func VIP_Manager_LoadWeb()
	Write_Log("=====================")
	Write_Log("+ VIP_Manager_LoadWeb")
	GUICtrlSetData($__g_idList_Vip_Web, "|" & _ArrayToString($ARRAY_WEB_VIP))
	Write_Log("B2: Load trang web thành công",$CONSOLE_SUCCESS)
EndFunc

Func VIP_Manager_ChangeSite()
	Write_Log("=====================")
	Write_Log("+ VIP_Manager_ChangeSite")
	; Lấy tên web hiện tại
	Local $currentSite = GUICtrlRead($__g_idList_Vip_Web)
	Write_Log("B3: Người dùng đang chọn web: " & $currentSite,$CONSOLE_INFO)
	; Load thông tin combobox
	$__g_a_dataVipCurrentSite = IniReadSection($FOLDER_MAIN_DATA & 'DEFAULT_VIP_DATA.data', $currentSite)
	If @error Then ; Nếu không load được data có nghĩa là trang web chưa được hỗ trợ
		Write_Log("B3: Trang web người dùng chọn chưa được hỗ trợ",$CONSOLE_ERROR)
		GUICtrlSetData($__g_idInput_VIP_Date,"")
		GUICtrlSetData($__g_idCombo_Vip_Type,"|")
		VIP_MANAGER_Hide_Options()
		Return SetError(1)
	EndIf

	Write_Log("B3: Data load được từ trang hiện tại: ",$CONSOLE_INFO)
	_PrintFromArray($__g_a_dataVipCurrentSite)

	GUICtrlSetData($__g_idCombo_Vip_Type, "|" & StringReplace($__g_a_dataVipCurrentSite[1][1],",","|"))

	; Load option
	Local $dataOption = $__g_a_dataVipCurrentSite[5][1]
	If $dataOption = "" Then
		VIP_MANAGER_Hide_Options(0) ; Xóa hết 4 options
	Else
		Write_Log("B3: Data option load được từ trang hiện tại: " & $dataOption,$CONSOLE_INFO)
		Local $arrayOptionName = StringSplit($dataOption, ",",2)
		Write_Log("B3: $arrayOptionName: ",$CONSOLE_INFO)
		_PrintFromArray($arrayOptionName)
		If IsArray($arrayOptionName) = 1 Then
			Write_Log("B3: Trang mà người dùng có : " & UBound($arrayOptionName) & " options",$CONSOLE_INFO)
			For $i = 0 To UBound($arrayOptionName) - 1
				GUICtrlSetData($__g_a_Checkbox_Option_Vip[$i],$arrayOptionName[$i])
				GUICtrlSetState($__g_a_Checkbox_Option_Vip[$i],$GUI_SHOW) ; Hiển thị những options đang có
			Next
			VIP_MANAGER_Hide_Options(UBound($arrayOptionName)) ; Xóa những vị trí không có
		Else
			VIP_MANAGER_Hide_Options(0) ; Xóa hết 4 options
		EndIf
	EndIf
	; Load lựa chọn mà người dùng đã lưu
	VIP_Manager_LoadDefault_Selected()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: VIP_Manager_LoadDefault_Selected
; Description ...: Load lựa chọn mà người dùng đã lưu
; Syntax ........: VIP_Manager_LoadDefault_Selected()
; ===============================================================================================================================
Func VIP_Manager_LoadDefault_Selected()
	Write_Log("=====================")
	Write_Log("+ VIP_Manager_LoadDefault_Selected")
	Local $site = GUICtrlRead($__g_idList_Vip_Web)
	; Load loại vip người dùng đã chọn
	Local $defaultIndex = RegRead($REG_VIP_SETTING & $site, "vipIndex")
	If @error Then ; Nếu người dùng chưa lưu thì chọn vị trí mặc định: 0
		$defaultIndex = 0
		ControlCommand("","",$__g_idCombo_Vip_Type,"SetCurrentSelection",0)
	Else
		ControlCommand("","",$__g_idCombo_Vip_Type,"SetCurrentSelection",$defaultIndex)
	EndIf
	; Load số ngày vip người dùng đã chọn
	Local $defaultDate = RegRead($REG_VIP_SETTING & $site, "vipDate")
	If @error Then ; Nếu người dùng chưa có lưu thì phải lấy số ngày mặc định ra
		Local $dateMin = IniRead($FOLDER_MAIN_DATA & 'DEFAULT_VIP_DATA.data',$site,"dateMin","")
		Local $arrayDateMin = StringSplit($dateMin,",",2)
		GUICtrlSetData($__g_idInput_VIP_Date,$arrayDateMin[$defaultIndex])
	Else
		GUICtrlSetData($__g_idInput_VIP_Date,$defaultDate)
	EndIf

	; Load lựa chọn option người dùng đã chọn
	Local $defaultOption = RegRead($REG_VIP_SETTING & $site, "vipOptions") ; Dữ liệu nhận được sẽ có dạng 1|4|4|4 là state của 4 options
	If @error Then
		For $i = 0 To 3 ; Số lượng options luôn là 4
			GUICtrlSetState($__g_a_Checkbox_Option_Vip[$i],$GUI_UNCHECKED)
		Next
	Else
		Local $arrayStates = StringSplit($defaultOption,"|",2) ; Chuyển dữ liệu thành dạng mảng để loop
		For $i = 0 To UBound($arrayStates) - 1
			GUICtrlSetState($__g_a_Checkbox_Option_Vip[$i],$arrayStates[$i])
		Next
	EndIf
EndFunc

Func VIP_Manager_ChangeType() ; Kích hoạt khi người dùng thay đổi combobox
	Write_Log("=====================")
	Write_Log("+ VIP_Manager_ChangeType")
	Local $currentSite = GUICtrlRead($__g_idList_Vip_Web)
	Local $arrayEditOn = StringSplit($__g_a_dataVipCurrentSite[2][1],",",2); Mảng cho phép thay đổi ngày của tin đăng không
	; Chuyển dateMin thành dạng array
	Local $arrayDateMin = StringSplit($__g_a_dataVipCurrentSite[3][1],",",2) ; $data[3][1] là số ngày nhỏ nhất có thể set dạng 1,2,3,4,5
	Local $currentIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Vip_Type)
	; Lấy số ngày nhỏ nhất từ index vip
	Local $currentDateMin = $arrayDateMin[$currentIndex]
	GUICtrlSetData($__g_idInput_VIP_Date,$currentDateMin)
	GUICtrlSetBkColor($__g_idButton_VIP_Save,$COLOR_ORANGE)
	If $arrayEditOn[$currentIndex] = "False" Then
		Write_Log("Disable Input",$CONSOLE_INFO)
		GUICtrlSetState($__g_idInput_VIP_Date,$GUI_DISABLE)
	Else
		Write_Log("Enable Input",$CONSOLE_INFO)
		GUICtrlSetState($__g_idInput_VIP_Date,$GUI_ENABLE)
	EndIf
	; Setting tên thành Ngày, tháng, năm
	Local $arrayDateLabel = StringSplit($__g_a_dataVipCurrentSite[4][1],",",2) ; $data[4][1] là dateLabel ngày,tháng,năm
	If IsArray($arrayDateLabel) = 1 Then
		GUICtrlSetData($__g_idLabel_VIP,"Số " & StringLower($arrayDateLabel[$currentIndex]) & " vip")
	EndIf
	Return $currentDateMin
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: VIP_Manager_SaveDefault_Selected
; Description ...: Lưu những lựa chọn vip mà người dùng đã chọn
; Syntax ........: VIP_Manager_SaveDefault_Selected()
; Parameters ....: None
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func VIP_Manager_SaveDefault_Selected()
	Write_Log("=====================")
	Write_Log("+ VIP_Manager_SaveDefault_Selected")
	; Lấy tên trang web cần lưu
	Local $siteName = GUICtrlRead($__g_idList_Vip_Web)
	; Lấy loại vip cần lưu
	Local $vipIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Vip_Type)
	; Lấy số ngày vip cần lưu
	Local $vipDate = Number(GUICtrlRead($__g_idInput_VIP_Date))
	; So sánh thêm ngày người dùng có nhỏ hơn số ngày nhỏ nhất có thể lưu hay không
	; Chuyển vipDate thành dạng array
	Local $arrayDateMin = StringSplit($__g_a_dataVipCurrentSite[3][1],",",2) ; $data[3][1] là số ngày nhỏ nhất có thể set dạng 1,2,3,4,5
	Write_Log("Số ngày muốn lưu: " & $vipDate,$CONSOLE_INFO)
	Local $dateMin
	If $siteName = $HOMEDY_URL Then ; Nếu người dùng chọn web homedy
		$dateMin = StringLeft($arrayDateMin[$vipIndex],1)
	Else
		$dateMin = $arrayDateMin[$vipIndex]
	EndIf
	Write_Log("Số ngày nhỏ nhất có thể lưu: " & $dateMin,$CONSOLE_INFO)
	If $vipDate < $dateMin Then
		ErrorShow(48,"","Số ngày đăng tin phải lớn hơn hoặc bằng số ngày nhỏ nhất")
		$vipDate = $dateMin
		GUICtrlSetData($__g_idInput_VIP_Date,$vipDate)
		Return SetError(2)
	EndIf
	; Lấy thông số options cần lưu
	Local $aSaveOption[0]
	For $id In $__g_a_Checkbox_Option_Vip
		_ArrayAdd($aSaveOption,GUICtrlRead($id))
	Next
	; Lưu nào
	RegWrite($REG_VIP_SETTING & $siteName,"vipIndex","REG_SZ",$vipIndex)
	RegWrite($REG_VIP_SETTING & $siteName,"vipDate","REG_SZ",$vipDate)
	RegWrite($REG_VIP_SETTING & $siteName,"vipOptions","REG_SZ",_ArrayToString($aSaveOption)) ; Chuyển mảng options state về dạng string để lưu
	GUICtrlSetBkColor($__g_idButton_VIP_Save,$COLOR_GREEN)
	ErrorShow($CONSOLE_SUCCESS,"Thông báo","Lưu thành công")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: VIP_MANAGER_Hide_Options
; Description ...: Ẩn những options đi
; Syntax ........: VIP_MANAGER_Hide_Options($indexStart)
; Parameters ....: $indexStart          - Vị trí bắt đầu - Mặc định là 0.
; ===============================================================================================================================
Func VIP_MANAGER_Hide_Options($indexStart = 0)
	For $i = $indexStart To 3 ; 3 là độ dài của mảng $__g_a_Checkbox_Option_Vip: vì nó luôn là 3 nên ghi này cho lẹ
		GUICtrlSetState($__g_a_Checkbox_Option_Vip[$i],$GUI_HIDE)
	Next
EndFunc

Func _Exit_GUI_Manager()
	Write_Log("=====================")
	Write_Log("+ _Exit_GUI_Manager")
	GUIDelete(@GUI_WinHandle)
EndFunc

Func WM_COMMAND_VIP($hWnd, $imsg, $iwParam, $ilParam)
	Local $setHK = False
	Local $nNotifyCode = BitShift($iwParam, 16)
	Local $nID = BitAND($iwParam, 0x0000FFFF)
	Local $hCtrl = $ilParam

	Local $handle_Date = GUICtrlGetHandle($__g_idInput_VIP_Date)
	If $nNotifyCode = $EN_CHANGE Then
		Switch $hCtrl
			Case $handle_Date
				GUICtrlSetBkColor($__g_idButton_VIP_Save,$COLOR_ORANGE)
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND_VIP