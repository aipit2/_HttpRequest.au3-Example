Func Posting_checkSite()
	Local $result
	; Kiểm tra web
	Local $webNumber = UBound($arrayMain)
	Global $__g_i_StepProgress = 100 / $webNumber
	Global $__g_i_CurrentProgress = 0
	If $webNumber = 0 Then
		$result = "Xin vui lòng chọn web muốn đăng tin" & @CRLF
	EndIf

	; Kiểm tra loại tin
	Local $postTypeIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_PostType)
	If $postTypeIndex = 0 Then
		$result &= "Xin vui lòng chọn |Loại tin|" & @CRLF
	EndIf

	; Kiểm tra loại Bds
	Local $estateTypeIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_EstateType)
	If $estateTypeIndex = 0 Then
		$result &= "Xin vui lòng chọn Loại Bds" & @CRLF
	EndIf

	Local $room = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_Room)
	Local $wc 	= _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_Wc)

	Local $acr = GUICtrlRead($__g_idInput_Tab2_Acr)
	If $acr = "" Then
		$acr = 0
	EndIf

	Local $priceValue = GUICtrlRead($__g_idInput_Tab2_Price)
	If $priceValue = "" Then
		$priceValue = 0
	EndIf
	Local $priceEnd 		= Number(StringReplace($priceValue,",","."))
	Local $priceTypeValue 	= _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_PriceType)
	Local $contentValue 	= GUICtrlRead($__g_idEdit_Tab2_Content)

	; Check xem file ảnh có tồn tại không
	If IsArray($__g_a_ImageLink) = 1 Then
		For $i = 0 To UBound($__g_a_ImageLink) - 1
			If FileExists($__g_a_ImageLink[$i]) = 0 Then
				$result &= "Vui lòng chọn lại hình ảnh!" & @CRLF
				Tab2_RemoveImage()
				ExitLoop
			EndIf
		Next
	EndIf

	; Check web nào thiếu địa chỉ không ?
	For $i = 0 To UBound($arrayMain) - 1
		If $arrayMain[$i][$eCityId] = "" Then
			$result &= $arrayMain[$i][0] & " chưa nhập Tỉnh/thành phố" & @CRLF
		ElseIf $arrayMain[$i][$eDistrictId] = "" Then
			$result &= $arrayMain[$i][0] &  " chưa nhập Quận/huyện" & @CRLF
		EndIf
	Next

	If $result <> "" Then
		ErrorShow(16,'', $result)
		Return 0
	EndIf

	Global $__g_a_ResultSuccess[0]
	Global $__g_a_ResultFail[0]

	Local $jsonData = _HttpRequest_ParseJSON($JSON_FORM_POSTING)
	$jsonData.postTypeIndex = $postTypeIndex
	$jsonData.estateTypeIndex = $estateTypeIndex
	$jsonData.room = $room
	$jsonData.wc = $wc
	$jsonData.acr = $acr
	$jsonData.price = $priceEnd
	$jsonData.priceType = $priceTypeValue
	$jsonData.content = $contentValue
	$jsonData.image = _ArrayToString($__g_a_ImageLink)
	$jsonData.address = $__g_s_AddressPost
	$jsonData.postName = $__g_s_CurrentPostName
	GUICtrlSetData($__g_idProgress_Tab6_Process,0)
	GUICtrlSetData($__g_idList_Tab6_Success,"|")
	GUICtrlSetData($__g_idList_Tab6_Fail,"|")
	_GUICtrlTab_ActivateTab($__g_idTab_Main, 5)
	_CoProc_Reciver("showMessage")
	_HttpRequest_MsgBox(64,"Thông báo","Đang đăng tin, chờ xíu nhé...",1)
	For $i = 0 To UBound($arrayMain) - 1
		$jsonData.title = $arrayMain[$i][$eTitle]
		$jsonData.cityID = $arrayMain[$i][$eCityId]
		$jsonData.districtID = $arrayMain[$i][$eDistrictId]
		$jsonData.districtName = $arrayMain[$i][$eDistrictName]
		$jsonData.wardID = $arrayMain[$i][$eWardId]
		$jsonData.wardName = $arrayMain[$i][$eWardName]
		$jsonData.streetID = $arrayMain[$i][$eStreetId]
		$jsonData.streetName = $arrayMain[$i][$eStreetName]
		$jsonData.projectID = $arrayMain[$i][$eProjectId]
		$jsonData.projectName = $arrayMain[$i][$eProjectName]
		$jsonData = GetVipInfor($arrayMain[$i][$eSite],$jsonData)
		Switch $arrayMain[$i][$eSite]
			Case "Muaban.net"
				Write_Log("Chuẩn bị đăng trang: Muaban.net",$CONSOLE_INFO)
				_CoProc_Create("Muaban_Posting_Send_Result",$jsonData.toStr())
			Case "Batdongsan.com.vn"
				_CoProc_Create("Bds_Posting_Send_Result",$jsonData.toStr())
;~ 			Case "Dothi.net"
;~ 				Dothi_Posting_Main($jsonData)
			Case "Bds123.vn"
				_CoProc_Create("Bds123_Posting_Send_Result",$jsonData.toStr())
			Case "Chotot.com"
				_CoProc_Create("Chotot_Posting_Send_Result",$jsonData.toStr())
			Case "Thuecanho123.com"
				_CoProc_Create("Thuecanho123_Posting_Send_Result",$jsonData.toStr())
			Case "Homedy.com"
				_CoProc_Create("Homedy_Posting_Send_Result",$jsonData.toStr())
		EndSwitch
	Next
EndFunc

Func showMessage($message)
	Local $split = StringSplit($message,":::",3) ; 3 để split theo cụm
	If @error Then Return 0
	Switch $split[0]
		Case "True"
			GUICtrlSetData($__g_idList_Tab6_Success,$split[1])
			_ArrayAdd($__g_a_ResultSuccess,$split[1])
			showProgress()
		Case "False"
			GUICtrlSetData($__g_idList_Tab6_Fail,$split[1])
			_ArrayAdd($__g_a_ResultFail,$split[1])
			showProgress()
	EndSwitch
	ProcessClose($split[2])
EndFunc   ;==>showMessage

; #FUNCTION# ====================================================================================================================
; Name ..........: SaveConsolePosting
; Description ...: Lưu log vào reg để dễ debug hơn
; Syntax ........: SaveConsolePosting($postId, $siteName, $step, $result)
; Parameters ....: $postId              - a pointer value.
;                  $siteName            - a string value.
;                  $step                - a string value.
;                  $result              - an unknown value.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func SaveLogPosting($postName,$siteName,$step,$result,$advanced = "")
	Local $REG_DIR = $REG_RESULT_POSTING & _StringToBase64($postName) & "\" & $siteName & "\" & $step
	RegWrite($REG_DIR,"Default","REG_MULTI_SZ",$result)
	If $advanced <> "" Then
		RegWrite($REG_DIR,"Advanced","REG_MULTI_SZ",$advanced)
	EndIf
EndFunc

Func CheckResultPosting()
	Write_Log("===============================================")
	Write_Log("+ CheckResultPosting")
	Local $currentSite = GUICtrlRead($__g_idList_Tab6_Success) ; Đoạn này code ngu vãi cả l
	If $currentSite = "" Then
		$currentSite = GUICtrlRead($__g_idList_Tab6_Fail)
		If $currentSite = "" Then
			Return SetError(1)
		EndIf
	EndIf
	Local $PostNameBase64 = _StringToBase64($__g_s_CurrentPostName)
	Local $checkError = RegRead($REG_RESULT_POSTING & $PostNameBase64 & "\" & $currentSite & "\Result","Default")
	Write_Log($checkError,$CONSOLE_INFO)
	If $checkError = "@error" Then
		Local $dataAdvanced = RegRead($REG_RESULT_POSTING & $PostNameBase64 & "\" & $currentSite & "\Result","Advanced")
		Write_Log($dataAdvanced,$CONSOLE_INFO)
		Execute($dataAdvanced)
	Else
		Execute($checkError)
	EndIf
EndFunc

Func CheckResultPosting_Debug_GUI()
	Write_Log("===============================================")
	Write_Log("+ CheckResultPosting_Debug_GUI")
	Global $__g_idGUI_Debug = GUICreate("Chắc bạn bất lực lắm mới phải cần tới tôi :D", 774, 513, -1, -1)
	Global $__g_idListview_Debug = GUICtrlCreateListView("Bước|Kết quả", 32, 20, 713, 385)
	Global $__id_idButton_Debug = GUICtrlCreateButton("Kiểm tra", 295, 428, 187, 65)
	GUICtrlSetFont(-1, 15)
	GUISetOnEvent($GUI_EVENT_CLOSE,"CheckResultPosting_Debug_GUI_Exit",$__g_idGUI_Debug)
	GUICtrlSetOnEvent($__id_idButton_Debug,"CheckResultPosting_Debug_Load_Advanced")
	GUISetState(@SW_SHOW)
	CheckResultPosting_Debug_Load($__g_s_CurrentPostName,"Batdongsan.com.vn")
EndFunc
Func CheckResultPosting_Debug_Load($postName,$siteName)
	Write_Log("===============================================")
	Write_Log("+ CheckResultPosting_Debug_Load")
	If $postName = "" Then ; Nếu người dùng muốn load từ tin đăng không lưu
		ErrorShow(16,"","Xin vui lòng chọn tin đăng muốn kiểm tra")
		Return SetError(1)
	EndIf
	Local $REG_DIR = $REG_RESULT_POSTING & _StringToBase64($postName)
	Local $REG_STEP_DIR = $REG_DIR & "\" & $siteName
	Local $arrayStep = LoadArrayKeyFromReg($REG_STEP_DIR)
	If UBound($arrayStep) = 0 Then
		Return SetError(2)
	EndIf
	Local $arrayShow[0][2]
	For $currentStep In $arrayStep
		Local $readStep = RegRead($REG_STEP_DIR & "\" & $currentStep,"Default")
		If $readStep <> "" Then
			_ArrayAdd($arrayShow,$currentStep & "|" & $readStep)
		EndIf
	Next
	_GUICtrlListView_AddArray($__g_idListview_Debug,$arrayShow)
	For $i = 0 To 1
		_GUICtrlListView_SetColumnWidth($__g_idListview_Debug, $i, $LVSCW_AUTOSIZE)
		_GUICtrlListView_SetColumnWidth($__g_idListview_Debug, $i, $LVSCW_AUTOSIZE_USEHEADER)
	Next

	Global $__g_s_SiteName_Debug = $siteName
EndFunc
Func CheckResultPosting_Debug_Load_Advanced()
	Write_Log("===============================================")
	Write_Log("+ CheckResultPosting_Debug_Load_Advanced")
	If $__g_s_CurrentPostName = "" Then
		ErrorShow($CONSOLE_ERROR,"","Xin vui lòng chọn tin để kiểm tra")
		Return SetError(1)
	EndIf
	Local $currentStep = _GUICtrlListView_GetSelectedIndices($__g_idListview_Debug)
	If $currentStep = "" Then
		ErrorShow($CONSOLE_ERROR,"","Xin vui lòng chọn bước để kiểm tra")
		Return SetError(2)
	EndIf
	Write_Log($REG_RESULT_POSTING & $__g_s_CurrentPostName & "\" & $__g_s_SiteName_Debug & "\" & ($currentStep + 1),$CONSOLE_INFO)
	Local $readStepAdvanced = RegRead($REG_RESULT_POSTING & _StringToBase64($__g_s_CurrentPostName) & "\" & $__g_s_SiteName_Debug & "\" & ($currentStep + 1),"Advanced")
	Write_Log($readStepAdvanced,$CONSOLE_INFO)
	Execute($readStepAdvanced)
EndFunc
Func CheckResultPosting_Debug_GUI_Exit()
	GUIDelete($__g_idGUI_Debug)
EndFunc

Func showProgress()
	Write_Log("===============================================")
	Write_Log("+ showProgress")
	$__g_i_CurrentProgress = $__g_i_CurrentProgress + $__g_i_StepProgress
	GUICtrlSetData($__g_idProgress_Tab6_Process,$__g_i_CurrentProgress)
	If $__g_i_CurrentProgress = 100 Then
		_TrayTip("Thông báo","Đăng tin thành công",5,1)
		If $__g_s_CurrentPostName = "" Then
			Return SetError(1)
		Else
			Return True
		EndIf
	EndIf
EndFunc   ;==>showProgress

Func Tab6_ClickLeft()
	Write_Log("=====================")
	Write_Log("+ Tab6_ClickLeft")
	_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Fail,-1) ; Bỏ Focus bên phải
	Local $currentSite = GUICtrlRead($__g_idList_Tab6_Success)
	If $currentSite = "" Then ; Nếu không chọn web nào thì sẽ chọn web đầu tiên
		_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Success,0)
	EndIf
EndFunc

Func Tab6_ClickRight()
	Write_Log("=====================")
	Write_Log("+ Tab6_ClickRight")
	_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Success,-1) ; Bỏ Focus bên phải
	Local $currentSite = GUICtrlRead($__g_idList_Tab6_Fail)
	If $currentSite = "" Then ; Nếu không chọn web nào thì sẽ chọn web đầu tiên
		_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Fail,0)
	EndIf
EndFunc

Func Tab6_KeyLeft()
	Write_Log("=====================")
	Write_Log("+ Tab6_KeyLeft")
	_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Fail,-1) ; Bỏ focus bên phải
	_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Success,0) ; Focus bên trái
	GUICtrlSetState($__g_idList_Tab6_Success,$GUI_FOCUS) ; Phải set focus thì mới ấn lên xuống được
EndFunc

Func Tab6_KeyRight()
	Write_Log("=====================")
	Write_Log("+ Tab6_KeyRight")
	_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Success,-1) ; Bỏ focus bên trái
	_GUICtrlListBox_SetCurSel($__g_idList_Tab6_Fail,0) ; Focus bên phải
	GUICtrlSetState($__g_idList_Tab6_Fail,$GUI_FOCUS) ; Phải set focus thì mới ấn lên xuống được
EndFunc

Func GetVipInfor($site,$jsonData)
	Local $arrayResult[6]
	Local $vipIndex = RegRead($REG_VIP_SETTING & $site,"vipIndex")
	If $vipIndex = "" Then
		$jsonData.vipIndex = 0
	Else
		$jsonData.vipIndex = $vipIndex
	EndIf
	Local $dateVip = RegRead($REG_VIP_SETTING & $site,"vipDate")
	If $dateVip = "" Then
		Local $dataDateVip = IniRead($FOLDER_MAIN_DATA & "DEFAULT_VIP_DATA.data",$site,"dateMin","")
		If $dataDateVip = "" Then
			$jsonData.date = 0
		Else
			$dateVip = StringRegExp($dataDateVip,"(\d+),",1)[0]
			$jsonData.date = $dateVip
		EndIf
	Else
		$jsonData.date = $dateVip
	EndIf

	Local $dataOption = RegRead($REG_VIP_SETTING & $site,"vipOptions")
	If $dataOption = "" Then
		$jsonData.option1 = 4
		$jsonData.option2 = 4
	Else
		Local $arrayOption = StringSplit($dataOption,"|",2)
		$jsonData.option1 = $arrayOption[0]
		$jsonData.option2 = $arrayOption[1]
	EndIf
	Return $jsonData
EndFunc