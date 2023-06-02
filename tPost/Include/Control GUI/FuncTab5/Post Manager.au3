Func Post_Manager_SavePost()
	Write_Log("====================")
	Write_Log("+ SavePost")
	If UBound($arrayMain) = 0 Then
		ErrorShow(16,'',"Bạn phải chọn ít nhất 1 website để lưu tin")
		Return SetError(1)
	EndIf
	; Ask Name
	Local $askName = InputBox("Thông báo","Nhập tên gợi nhớ muốn lưu",$__g_s_CurrentPostName)
	If @error Then
		Return SetError(2)
	ElseIf $askName = "" Then
		ErrorShow(16,'',"Tên không được để trống")
		Return SetError(3)
	EndIf

	Local $base64Name = _StringToBase64($askName)

	RegWrite($REG_SAVEPOST & $base64Name,"postName","REG_SZ",$askName)
	RegWrite($REG_SAVEPOST & $base64Name,"postType","REG_SZ",GUICtrlRead($__g_idCombo_Tab2_PostType))
	RegWrite($REG_SAVEPOST & $base64Name,"postTypeIndex","REG_SZ",_GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_PostType))
	RegWrite($REG_SAVEPOST & $base64Name,"estateType","REG_SZ",GUICtrlRead($__g_idCombo_Tab2_EstateType))
	RegWrite($REG_SAVEPOST & $base64Name,"estateTypeIndex","REG_SZ",_GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_EstateType))
	RegWrite($REG_SAVEPOST & $base64Name,"room","REG_SZ",GUICtrlRead($__g_idCombo_Tab2_Room))
	RegWrite($REG_SAVEPOST & $base64Name,"roomIndex","REG_SZ",_GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_Room))
	RegWrite($REG_SAVEPOST & $base64Name,"wc","REG_SZ",GUICtrlRead($__g_idCombo_Tab2_Wc))
	RegWrite($REG_SAVEPOST & $base64Name,"wcIndex","REG_SZ",_GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_Wc))
	RegWrite($REG_SAVEPOST & $base64Name,"acr","REG_SZ",GUICtrlRead($__g_idInput_Tab2_Acr))
	RegWrite($REG_SAVEPOST & $base64Name,"price","REG_SZ",GUICtrlRead($__g_idInput_Tab2_Price))
	RegWrite($REG_SAVEPOST & $base64Name,"priceType","REG_SZ",GUICtrlRead($__g_idCombo_Tab2_PriceType))
	RegWrite($REG_SAVEPOST & $base64Name,"priceTypeIndex","REG_SZ",_GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_PriceType))
	RegWrite($REG_SAVEPOST & $base64Name,"content","REG_SZ",StringReplace(GUICtrlRead($__g_idEdit_Tab2_Content),@CRLF,"@CRLF"))
	RegWrite($REG_SAVEPOST & $base64Name,"imageLink","REG_SZ",_ArrayToString($__g_a_ImageLink))
	RegWrite($REG_SAVEPOST & $base64Name,"imageName","REG_SZ",StringReplace(GUICtrlRead($__g_idEdit_Tab2_Image),@CRLF,"|"))
	Local $city = GUICtrlRead($__g_idCombo_Address_City)
	If $city = "Tỉnh/thành phố" Then
		$city = ""
	EndIf
	Local $district = GUICtrlRead($__g_idCombo_Address_District)
	If $district = "Quận/huyện" Then
		$district = ""
	EndIf
	Local $ward = GUICtrlRead($__g_idCombo_Address_Ward)
	If $ward = "Phường/xã" Then
		$ward = ""
	EndIf
	Local $street = GUICtrlRead($__g_idCombo_Address_Street)
	If $street = "Đường" Then
		$street = ""
	EndIf
	Local $project = GUICtrlRead($__g_idCombo_Address_Project)
	If $project = "Dự án" Then
		$project = ""
	EndIf
	RegWrite($REG_SAVEPOST & $base64Name,"cityName","REG_SZ",$city)
	RegWrite($REG_SAVEPOST & $base64Name,"districtName","REG_SZ",$district)
	RegWrite($REG_SAVEPOST & $base64Name,"wardName","REG_SZ",$ward)
	RegWrite($REG_SAVEPOST & $base64Name,"streetName","REG_SZ",$street)
	RegWrite($REG_SAVEPOST & $base64Name,"projectName","REG_SZ",$project)
	Local $saveAddress = GUICtrlRead($__g_idCombo_Address_SavedAddress)
	If $saveAddress = "Địa chỉ đã lưu" Then
		$saveAddress = ""
	EndIf
	RegWrite($REG_SAVEPOST & $base64Name,"addressDirect"	,"REG_SZ",$__g_s_AddressPost)
	RegWrite($REG_SAVEPOST & $base64Name,"arrayMain"		,"REG_MULTI_SZ",__ArrayToString($arrayMain,"|",@LF))
	$__g_s_CurrentPostName = $askName
	Post_Manager_LoadSavedPost() ; Cập nhật lại listview
EndFunc

Func LoadTotalSavedPost()
	Local $i = 1
	Global $__g_a_PostName[0]
	While 1
		Local $read = RegEnumKey($REG_SAVEPOST,$i)
		If $read = "" Then
			ExitLoop
		Else
			_ArrayAdd($__g_a_PostName,_Base64ToString($read))
			$i += 1
		EndIf
	WEnd
	Return $__g_a_PostName
EndFunc

Func Post_Manager_LoadSavedPost()
	Write_Log("====================")
	Write_Log("+ Post_Manager_LoadSavedPost")
	_GUICtrlListView_DeleteAllItems($__g_idListview_Tab5_SavedPost)
	Global $__g_a_PostName = LoadTotalSavedPost()

	For $header In $__g_a_UserHeader
		_GUICtrlListView_InsertColumn($__g_idListview_Tab5_SavedPost,$i,$header)
	Next

	Local $arrayShow[0][20]
	For $i = 0 To UBound($__g_a_PostName) - 1
		Local $base64Name = _StringToBase64($__g_a_PostName[$i])
		Local $id = $i
		Local $name = $__g_a_PostName[$i]
		Write_Log("$base64Name: " & $base64Name)
		Write_Log("$id: " & $id)
		Write_Log("$Name: " & $name)
		Local $postType = RegRead($REG_SAVEPOST & $base64Name,"postType")
		Local $estateType = RegRead($REG_SAVEPOST & $base64Name,"estateType")
		Local $room = RegRead($REG_SAVEPOST & $base64Name,"room")
		Local $wc = RegRead($REG_SAVEPOST & $base64Name,"wc")
		Local $acr = RegRead($REG_SAVEPOST & $base64Name,"acr")
		Local $price = RegRead($REG_SAVEPOST & $base64Name,"price")
		Local $priceType = RegRead($REG_SAVEPOST & $base64Name,"priceType")
		Local $cityName = RegRead($REG_SAVEPOST & $base64Name,"cityName")
		Local $districtName = RegRead($REG_SAVEPOST & $base64Name,"districtName")
		Local $wardName = RegRead($REG_SAVEPOST & $base64Name,"wardName")
		Local $streetName = RegRead($REG_SAVEPOST & $base64Name,"streetName")
		Local $projectName = RegRead($REG_SAVEPOST & $base64Name,"projectName")

		Local $stringAdd = $id & "|" & $name & "|" & $postType & "|" & $estateType & "|" & $streetName
		$stringAdd &= "|" & $projectName & "|" & $room & "|" & $wc & "|" & $acr & "|" & $price & "|" & $priceType
		_ArrayAdd($arrayShow,$stringAdd)
	Next

	_GUICtrlListView_AddArray($__g_idListview_Tab5_SavedPost,$arrayShow)
	For $i = 0 To UBound($__g_a_UserHeader) - 1
		_GUICtrlListView_SetColumnWidth($__g_idListview_Tab5_SavedPost, $i, $LVSCW_AUTOSIZE)
		_GUICtrlListView_SetColumnWidth($__g_idListview_Tab5_SavedPost, $i, $LVSCW_AUTOSIZE_USEHEADER)
	Next
EndFunc

Func Post_Manager_ViewImage()
	Write_Log("====================")
	Write_Log("+ Post_Manager_ViewImage")
	Local $currentIndex = _GUICtrlListView_GetSelectedIndices($__g_idListview_Tab5_SavedPost)
	If $currentIndex = "" Then
		ErrorShow(16,'',"Xin vui lòng chọn tin để hiện ảnh")
		Return SetError(1)
	Else
		Local $postName = $__g_a_PostName[$currentIndex]
		Local $loadImage = RegRead($REG_SAVEPOST & _StringToBase64($postName),"imageLink")
		Local $aImage = StringSplit($loadImage,"|",2)
		Write_Log("Số lượng ảnh: " & UBound($aImage))
		Local $currentImageSize = ControlGetPos("","",$Pic1)
		If @error Then
			Return SetError(2)
		EndIf
		If IsArray($aImage) = 1 And $loadImage <> "" Then
			Switch UBound($aImage)
				Case 0
					GUICtrlSetImage($Pic1,$ICON_Black)
					GUICtrlSetImage($Pic2,$ICON_Black)
					GUICtrlSetImage($Pic3,$ICON_Black)
					GUICtrlSetImage($Pic4,$ICON_Black)
					ErrorShow(48,"","Tin đăng không có ảnh",2)
					Return SetError(3)
				Case 1
					_Image_SetGUI($aImage[0],$Pic1,$currentImageSize[2],$currentImageSize[3])
					GUICtrlSetImage($Pic2,$ICON_Black)
					GUICtrlSetImage($Pic3,$ICON_Black)
					GUICtrlSetImage($Pic4,$ICON_Black)
				Case 2
					_Image_SetGUI($aImage[0],$Pic1,$currentImageSize[2],$currentImageSize[3])
					_Image_SetGUI($aImage[1],$Pic2,$currentImageSize[2],$currentImageSize[3])
					GUICtrlSetImage($Pic3,$ICON_Black)
					GUICtrlSetImage($Pic4,$ICON_Black)
				Case 3
					_Image_SetGUI($aImage[0],$Pic1,$currentImageSize[2],$currentImageSize[3])
					_Image_SetGUI($aImage[1],$Pic2,$currentImageSize[2],$currentImageSize[3])
					_Image_SetGUI($aImage[2],$Pic3,$currentImageSize[2],$currentImageSize[3])
					GUICtrlSetImage($Pic4,$ICON_Black)
				Case Else
					_Image_SetGUI($aImage[0],$Pic1,$currentImageSize[2],$currentImageSize[3])
					_Image_SetGUI($aImage[1],$Pic2,$currentImageSize[2],$currentImageSize[3])
					_Image_SetGUI($aImage[2],$Pic3,$currentImageSize[2],$currentImageSize[3])
					_Image_SetGUI($aImage[3],$Pic4,$currentImageSize[2],$currentImageSize[3])
			EndSwitch
		Else ; Khi post không có ảnh
			GUICtrlSetImage($Pic1,$ICON_Black)
			GUICtrlSetImage($Pic2,$ICON_Black)
			GUICtrlSetImage($Pic3,$ICON_Black)
			GUICtrlSetImage($Pic4,$ICON_Black)
			ErrorShow(48,"","Tin đăng không có ảnh",2)
			Return SetError(4)
		EndIf
	EndIf
EndFunc

Func Post_Manager_EditPost() ; Chỉnh sửa bài viết
	Write_Log("====================")
	Write_Log("+ Post_Manager_EditPost")
	Local $postNameBase64
	; Lấy index post
	Local $indexSelected = _GUICtrlListView_GetSelectedIndices($__g_idListview_Tab5_SavedPost)
	Write_Log("> $indexSelected = " & $indexSelected)
	; Nếu không chọn phải return error
	If $indexSelected = "" Then
		ErrorShow(48,"Thông báo","Xin vui lòng chọn tin để sửa")
		Return SetError(1)
	EndIf
	; Tìm postName từ index đã chọn
	Local $postNameSelected = $__g_a_PostName[$indexSelected]
	$postNameBase64 = _StringToBase64($postNameSelected)
	Local $loadArrayMain = RegRead($REG_SAVEPOST & "\" & $postNameBase64,"arrayMain")
	Write_Log("> $loadArrayMain = " & $loadArrayMain)
	If $loadArrayMain = "" Then ; Nếu người dùng không lưu gì return lỗi
		Return SetError(2)
	Else
		Global $arrayMain = StringSplit2D($loadArrayMain,"|",@LF,False) ; Nhớ phải có False
	EndIf

	_GUICtrlListBox_ResetContent($__g_idList_ChooseWeb_Current) ; Xóa những site cũ (Quên mất tại sao phải xóa rồi :))
	GUICtrlSetData($__g_idList_ChooseWeb_Post,"|" & _ArrayToString($arrayMain,"|",-1,-1,"|",-1,0))
	ChooseWeb_LoadWebFromList() ; Load web từ list đầu tiên
	Local $postType 		= RegRead($REG_SAVEPOST & $postNameBase64,"postType")
	Local $estateType 		= RegRead($REG_SAVEPOST & $postNameBase64,"estateType")
	Local $room 			= RegRead($REG_SAVEPOST & $postNameBase64,"room")
	Local $wc 				= RegRead($REG_SAVEPOST & $postNameBase64,"wc")
	Local $acr 				= RegRead($REG_SAVEPOST & $postNameBase64,"acr")
	Local $price 			= RegRead($REG_SAVEPOST & $postNameBase64,"price")
	Local $priceTypeIndex 	= RegRead($REG_SAVEPOST & $postNameBase64,"priceType")
	Local $content 			= RegRead($REG_SAVEPOST & $postNameBase64,"content")
	Local $readImage 		= RegRead($REG_SAVEPOST & $postNameBase64,"imageLink")
	Local $imageName		= RegRead($REG_SAVEPOST & $postNameBase64,"imageName")
	Local $addressDirect 	= RegRead($REG_SAVEPOST & $postNameBase64,"addressDirect")
	_GUICtrlComboBox_SelectString($__g_idCombo_Tab2_PostType	,$postType)
	_GUICtrlComboBox_SelectString($__g_idCombo_Tab2_EstateType	,$estateType)
	_GUICtrlComboBox_SelectString($__g_idCombo_Tab2_Room		,$room)
	_GUICtrlComboBox_SelectString($__g_idCombo_Tab2_Wc			,$wc)
	_GUICtrlComboBox_SelectString($__g_idCombo_Tab2_PriceType	,$priceTypeIndex)
	GUICtrlSetData($__g_idInput_Tab2_Acr		,$acr)
	GUICtrlSetData($__g_idInput_Tab2_Price		,$price)
	GUICtrlSetData($__g_idInput_Address_Direct	,$addressDirect)
	GUICtrlSetData($__g_idEdit_Tab2_Content		,StringReplace($content		,"@CRLF",@CRLF))
	GUICtrlSetData($__g_idEdit_Tab2_Image		,StringReplace($imageName	,"|",@CRLF))

	If $readImage = "" Then
		Global $__g_a_ImageLink[0]
	Else
		$__g_a_ImageLink = StringSplit($readImage,"|",2)
	EndIf
	_GUICtrlTab_ActivateTab($__g_idTab_Main, 5)

	$__g_s_CurrentPostName = $postNameSelected
	Post_Manager_LoadResult()
EndFunc

Func Post_Manager_RemovePost()
	Write_Log("====================")
	Write_Log("+ Post_Manager_RemovePost")
	; Tìm ID post cần edit
		; Lấy index post
		Local $indexSelected = _GUICtrlListView_GetSelectedIndices($__g_idListview_Tab5_SavedPost)
		Write_Log("> $indexSelected = " & $indexSelected)
		If $indexSelected = "" Then
			Write_Log("! Người dùng không chọn tin nào để xóa cả")
			Return SetError(1)
		EndIf
	; Tìm ID post từ index đã chọn
	Local $postNameSelected = $__g_a_PostName[$indexSelected]
	; Xóa post từ ID post tìm được
	Local $arrayDelete = _ArrayDelete($__g_a_PostName,$indexSelected) ; Xóa khỏi mảng ID post
	; Xóa khỏi regedit
	Local $regDelete = RegDelete($REG_SAVEPOST & _StringToBase64($postNameSelected))
	; Xóa khỏi listview
	Local $listviewDelete = _GUICtrlListView_DeleteItem($__g_idListview_Tab5_SavedPost,$indexSelected)
	If $arrayDelete <> -1 And $regDelete = 1 And $listviewDelete = True Then
		ErrorShow(64,'Xóa tin',"Xóa tin thành công",2)
		Return True
	Else
		ErrorShow(16,'Thông báo lỗi',"Xóa tin thất bại #1")
		Return SetError(2)
	EndIf
EndFunc

Func Post_Manager_NewPost()
	Write_Log("====================")
	Write_Log("+ Post_Manager_NewPost")
	; Reset Tab 1
	GUICtrlSetData($__g_idList_ChooseWeb_Post,"|")
	GUICtrlSetData($__g_idList_ChooseWeb_Current,"|")
	ChooseWeb_LoadWebFromList()
	Global $arrayMain[0][23]
	; Reset Tab 2
	_GUICtrlComboBox_SetCurSel($__g_idCombo_Tab2_PostType,0)
	_GUICtrlComboBox_SetCurSel($__g_idCombo_Tab2_EstateType,0)
	_GUICtrlComboBox_SetCurSel($__g_idCombo_Tab2_Room,0)
	_GUICtrlComboBox_SetCurSel($__g_idCombo_Tab2_Wc,0)
	GUICtrlSetData($__g_idInput_Tab2_Acr,"")
	GUICtrlSetData($__g_idInput_Tab2_Price,"")
	_GUICtrlComboBox_SetCurSel($__g_idCombo_Tab2_PriceType,0)
	GUICtrlSetData($__g_idEdit_Tab2_Content,"Điền nội dung vào đây")
	Tab2_RemoveImage() ; Reset hình ảnh
	; Reset Tab 3
	GUICtrlSetData($__g_idList_Tab3_Post,"|")
	GUICtrlSetData($__g_idEdit_Tab3_Title,"Tiêu đề")
	GUICtrlSetData($__g_idButton_Tab3_TitleLen,"Độ dài tiêu đề")
	; Reset Tab 4
	GUICtrlSetData($__g_idList_Address_Site,"|")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_City,"Tỉnh/Thành Phố")
	GUICtrlSetData($__g_idCombo_Address_District,"|Quận/Huyện")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_District,"Quận/Huyện")
	GUICtrlSetData($__g_idCombo_Address_Ward,"|Phường/Xã")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_Ward,"Phường/Xã")
	GUICtrlSetData($__g_idCombo_Address_Street,"|Đường")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_Street,"Đường")
	GUICtrlSetData($__g_idCombo_Address_Project,"|Dự án")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_Project,"Dự án")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_SavedAddress,"Địa chỉ đã lưu")
	GUICtrlSetData($__g_idList_Tab6_Success,"")
	GUICtrlSetData($__g_idList_Tab6_Fail,"")
	GUICtrlSetData($__g_idProgress_Tab6_Process,0)
	Global $__g_s_CurrentPostName = ""
	Global $__g_s_AddressPost = ""
	GUICtrlSetData($__g_idInput_Address_Direct,"")
	Global $__g_i_CityIndex
	Global $__g_s_CityName, $__g_s_CityId
	Global $__g_a_DistrictName, $__g_a_DistrictId, $__g_s_DistrictName, $__g_s_DistrictId
	Global $__g_a_WardName, $__g_a_WardId, $__g_s_WardName, $__g_s_WardId
	Global $__g_a_StreetName, $__g_a_StreetId, $__g_s_StreetName, $__g_s_StreetId
	Global $__g_a_ProjectName, $__g_a_ProjectId, $__g_s_ProjectName, $__g_s_ProjectId
	Global $__g_s_AddressPost
	_GUICtrlTab_ActivateTab($__g_idTab_Main,0)
EndFunc

Func Post_Manager_LoadResult()
	Write_Log("====================")
	Write_Log("+ Post_Manager_LoadResult")
	GUICtrlSetData($__g_idList_Tab6_Success,"|")
	GUICtrlSetData($__g_idList_Tab6_Fail,"|")
	For $i = 0 To UBound($arrayMain) - 1
		Local $data = RegRead($REG_RESULT_POSTING & _StringToBase64($__g_s_CurrentPostName) & "\" & $arrayMain[$i][0] & "\Result","Default")
		If @error Then
			ContinueLoop
		ElseIf $data = "@error" Then
			GUICtrlSetData($__g_idList_Tab6_Fail,$arrayMain[$i][0])
		ElseIf StringLen($data > 1) Then
			GUICtrlSetData($__g_idList_Tab6_Success,$arrayMain[$i][0])
		EndIf
	Next
EndFunc
