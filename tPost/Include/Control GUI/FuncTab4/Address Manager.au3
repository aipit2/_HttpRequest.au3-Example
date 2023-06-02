; Load danh sách trang web
; Name ..........: Address_LoadSite
; Description ...: Load danh sách trang web
; Kích hoạt khi	 : Người dùng truy cập vào tab địa chỉ
; Syntax ........: Address_LoadSite()
; Return values .: @error = 1 - Giá trị $arrayMain bị lỗi
;                : @error = 2 - $arrayMain không có phần tử nào
;                : @error = 3 - Không thể load tiêu đề từ mảng
;                : True - Thành công
; Author ........: Trần Hùng
; Modified ......: 15/08/2022
Func Address_LoadSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadSite")
	; B1: Load danh sách web
	If IsArray($arrayMain) = 0 Then
		ErrorShow(16, "Lỗi nghiêm trọng", "Không tìm thấy giá trị $arrayMain", 3)
		Return SetError(1, "", "")
	EndIf

	If UBound($arrayMain) = 0 Then ; Nếu người dùng chưa chọn web thì chuyển về lại tab 1
		ErrorShow(48, "", "Xin vui lòng thêm website trước", 3)
		_GUICtrlTab_ActivateTab($__g_idTab_Main, 0)
		GUICtrlSetState($__g_idList_ChooseWeb_Current, $GUI_FOCUS) ; Focus vào danh sách hiện tại để người dùng có thể chọn luôn
		Return SetError(2, "", "")
	EndIf

	Local $stringArrayTitle = _ArrayToString($arrayMain, "|", -1, -1, "|", 0, 0)
	If $stringArrayTitle = -1 Then
		ErrorShow(16, "", "Không thể hiển thị danh sách\n\nXin vui lòng thử lại", 3)
		Return SetError(3, "", "")
	EndIf
	; B2: Hiển thị danh sách web lên GUI
	GUICtrlSetData($__g_idList_Address_Site, "|" & $stringArrayTitle)
	; B3: Ẩn những ID chưa cần nhập
	GUICtrlSetState($__g_idInput_Address_Direct, $GUI_SHOW)
	GUICtrlSetState($__g_idInput_Address_Date, $GUI_HIDE)
	GUICtrlSetState($__g_idLabel_Address_Date, $GUI_HIDE)
	GUICtrlSetState($__g_idCheckbox_Address_Option1, $GUI_HIDE)
	GUICtrlSetState($__g_idCheckbox_Address_Option2, $GUI_HIDE)
	Return True
EndFunc   ;==>Address_LoadSite

; Load danh sách thành phố
; Name ..........: Address_LoadCity
; Description ...: Load danh sách thành phố
; Kích hoạt khi  : Người dùng mở GUI
; Syntax ........: Address_LoadCity()
; Return values .: True - Thành công
; Author ........: Trần Hùng
; Modified ......: 15/08/2022
Func Address_LoadCity()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadCity")
	Write_Log(" Load dánh sách thành phố")

	Local $stringCityName = _ArrayToString($__g_a_CityName)
	If @error Then
		Return SetError(@error, "", "")
	EndIf

	GUICtrlSetData($__g_idCombo_Address_City, "|Tỉnh/thành phố|" & $stringCityName)
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_City, "Tỉnh/thành phố")
	Return True
EndFunc   ;==>Address_LoadCity

Func Address_LoadDistrict_CheckSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadDistrict_CheckSite")
	Write_Log(" Check xem người dùng muốn load danh sách quận của trang nào")

	Local $siteIndex = _GUICtrlListBox_GetCurSel($__g_idList_Address_Site)
	Local $cityName = GUICtrlRead($__g_idCombo_Address_City)
	Local $cityIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_City)
	Local $siteSelected = GUICtrlRead($__g_idList_Address_Site)
	If $cityIndex = 0 Then
		Return SetError(1)
	EndIf
	Switch $siteSelected
		Case "" ; Người dùng muốn load quận từ trang tổng
			Write_Log("> Người dùng muốn load Quận từ trang: TỔNG")
			Address_LoadDistrict($cityIndex)
			Address_EditShowAddress()
;~ 		Case "Dothi.net"
;~ 			Address_LoadDistrict_Dothi($siteIndex,$cityName,$cityIndex)
		Case "Muaban.net"
			Address_LoadDistrict_Muaban($siteIndex,$cityName,$cityIndex)
		Case "Batdongsan.com.vn"
			Address_LoadMain_Bds($siteIndex,"Quận",$cityName,$cityIndex,$eArrayDistrictName)
		Case "Bds123.vn"
			Bds123_LoadAddress_Main("Quận",$siteIndex,$cityName,$cityIndex,$eArrayDistrictName)
		Case "Chotot.com"
			Address_LoadDistrict_Chotot($siteIndex,$cityName,$cityIndex)
		Case "Thuecanho123.com"
			Address_LoadDistrict_Thuecanho123($siteIndex,$cityName,$cityIndex)
		Case "Homedy.com"
			If $HOMEDY_IS_LOGIN = False Then
				Local $login = AccountSetting_Homdy_Login()
				If @error Then
					ErrorShow(16,$HOMEDY_URL,"Xin vui lòng đăng nhập để sử dụng chức năng này")
					Return SetError(1)
				Else
					$HOMEDY_IS_LOGIN = True
					Address_LoadDistrict_Homedy($siteIndex,$cityName,$cityIndex)
				EndIf
			Else
				Address_LoadDistrict_Homedy($siteIndex,$cityName,$cityIndex)
			EndIf
		Case Else
			Write_Log("> Trang: " & $siteSelected & " chưa được hỗ trợ chức năng load danh sách quận")
	EndSwitch

EndFunc   ;==>Address_LoadDistrict_CheckSite

Func Address_LoadDistrict($cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadDistrict")
	Write_Log(" Load danh sách Quận")
	; Get City ID
	Global $__g_s_CityId = $__g_a_CityId[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	Global $__g_s_CityName = $__g_a_CityName[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	Write_Log("City tìm thấy: " & $__g_s_CityId)
	; Get District
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetDistrict"
	Local $data = "cityCode=" & $__g_s_CityId
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	;=======================================================
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Global $__g_a_DistrictName = StringSplit($loadArrayName, "|", 2)
		Global $__g_a_DistrictId = StringSplit($loadArrayId, "|", 2)
		Local $isSave = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $url, $data)
		Global $__g_a_DistrictName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Global $__g_a_DistrictId = StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($__g_a_DistrictName, $__g_a_DistrictId)
	If @error Then
		ErrorShow(16, "", @extended)
	EndIf
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Quận", $__g_a_DistrictName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave, $urlGetResponseName, $__g_a_DistrictName)
	checkSaveResponse($isSave, $urlGetResponseId, $__g_a_DistrictId)
	Return $__g_a_DistrictName
EndFunc   ;==>Address_LoadDistrict

Func Address_LoadWard_CheckSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadWard_CheckSite")
	Write_Log(" Check xem người dùng muốn load danh sách phường của trang nào")
	Local $districtIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_District) ; Vị trí quận
	Switch $districtIndex
		Case -1
			ErrorShow(16, 'Lỗi nghiêm trọng', "Không thể tải danh sách phường")
			Return SetError(1, "Không thể tải danh sách phường", "")
		Case 0
			ErrorShow(48, '', "Xin vui lòng chọn Quận/huyện", 3)
			Return SetError(2, "Xin vui lòng chọn Quận/huyện", "")
	EndSwitch

	Local $siteIndex = _GUICtrlListBox_GetCurSel($__g_idList_Address_Site)
	Local $districtName = GUICtrlRead($__g_idCombo_Address_District)

	Local $siteSelected = GUICtrlRead($__g_idList_Address_Site)
	Switch $siteSelected
		Case ""
			Write_Log("> Người dùng muốn load quận từ trang: Tổng")
			Global $__g_i_DistrictId = $__g_a_DistrictId[$districtIndex - 1] ; - 1 phần tử Quận/huyện
			Global $__g_s_DistrictName = $__g_a_DistrictName[$districtIndex - 1] ; - 1 phần tử Quận/huyện
			Address_LoadWard()
			Address_LoadStreet()
			Address_LoadProject()
		Case "Dothi.net"
			Address_LoadWard_Dothi($siteIndex,$districtName,$districtIndex)
			Address_LoadStreet_Dothi($siteIndex)
			Address_LoadProject_Dothi($siteIndex)
;~ 			Address_LoadMain_Dothi($siteIndex,"Phường",$districtName, $districtIndex, $eArrayWardName)
;~ 			Address_LoadMain_Dothi($siteIndex,"Đường",$districtName, $districtIndex, $eArrayStreetName)
;~ 			Address_LoadMain_Dothi($siteIndex,"Dự án",$districtName, $districtIndex, $eArrayProjectName)
		Case "Muaban.net"
			Address_LoadWard_Muaban($siteIndex, $districtName, $districtIndex)
			Address_LoadStreet_Muaban($siteIndex)
			Address_LoadProject_Muaban($siteIndex)
		Case "Batdongsan.com.vn"
			Address_LoadMain_Bds($siteIndex,"Phường", $districtName, $districtIndex, $eArrayWardName)
			Address_LoadMain_Bds($siteIndex,"Đường"	, $districtName, $districtIndex, $eArrayStreetName)
			Address_LoadMain_Bds($siteIndex,"Dự án"	, $districtName, $districtIndex, $eArrayProjectName)
		Case "Bds123.vn"
			Bds123_LoadWardAndStreet($siteIndex,$districtName,$districtIndex)
			Bds123_LoadAddress_Main("Dự án",$siteIndex,$districtName,$districtIndex,$eArrayProjectName)
		Case "Chotot.com"
			Address_LoadWard_Chotot($siteIndex,$districtName,$districtIndex)
		Case "Thuecanho123.com"
			Address_LoadWard_Thuecanho123($siteIndex,$districtName,$districtIndex)
			Address_LoadStreet_Thuecanho123($siteIndex)
			Address_LoadProject_Thuecanho123($siteIndex)
		Case "Homedy.com"
			Address_LoadWard_Homedy($siteIndex,$districtName,$districtIndex)
			Address_LoadStreet_Homedy($siteIndex)
			; Trang này chỉ hỗ trợ tìm kiếm dự án theo tên|Cũng không thể dùng chung dữ liệu của trang Bds123.vn
		Case Else
			Write_Log("> Người dùng muốn load quận từ trang: " & $siteSelected)
	EndSwitch
EndFunc   ;==>Address_LoadWard_CheckSite

; Load danh sách phường
; Name ..........: Address_LoadWard
; Description ...: Load danh sách phường
; Syntax ........: Address_LoadWard()
; Return values .: $__g_a_WardName
; Author ........: Trần Hùng
; Modified ......: 22/09/2022
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
Func Address_LoadWard()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadWard")
	; Vì ví dụ người dùng chọn xong hết rồi, xong lại chọn lại từ City, District thì giá trị dưới vẫn còn ở đó
	; Reset các ID dưới (Ward,Street,Project)
	Global $__g_s_WardName = ""
	Global $__g_i_WardId = ""
	Global $__g_s_StreetName = ""
	Global $__g_i_StreetId = ""
	Global $__g_s_ProjectName = ""
	Global $__g_i_ProjectId = ""
	; Get Ward
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetWard"
	Local $data = "distId=" & $__g_i_DistrictId
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Global $__g_a_WardName = StringSplit($loadArrayName, "|", 2)
		Global $__g_a_WardId = StringSplit($loadArrayId, "|", 2)
		Local $isSave = True
	Else ; Không tìm thấy response nên phải thực hiện lại request
		Local $rq = _HttpRequest(2, $url, $data)
		Global $__g_a_WardName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Global $__g_a_WardId = StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($__g_a_WardName, $__g_a_WardId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường", $__g_a_WardName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave, $urlGetResponseName, $__g_a_WardName)
	checkSaveResponse($isSave, $urlGetResponseId, $__g_a_WardId)
	Return $__g_a_WardName
EndFunc   ;==>Address_LoadWard

; Load danh sách đường
; Name ..........: Address_LoadStreet
; Description ...: Load danh sách đường
; Syntax ........: Address_LoadStreet()
; Parameters ....: None
; Return values .: $__g_a_StreetName: Mảng chưa tên đường
; Author ........: Trần Hùng
; Modified ......: 22/09/2022
Func Address_LoadStreet()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadStreet")
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetStreet"
	Local $data = "distId=" & $__g_i_DistrictId
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Global $__g_a_StreetName = StringSplit($loadArrayName, "|", 2)
		Global $__g_a_StreetId = StringSplit($loadArrayId, "|", 2)
		Local $isSave = True
	Else ; Không tìm thấy response nên phải thực hiện lại request
		Local $rq = _HttpRequest(2, $url, $data)
		Global $__g_a_StreetName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Global $__g_a_StreetId = StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($__g_a_StreetName, $__g_a_StreetId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Đường", $__g_a_StreetName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave, $urlGetResponseName, $__g_a_StreetName)
	checkSaveResponse($isSave, $urlGetResponseId, $__g_a_StreetId)
	Return $__g_a_StreetName
EndFunc   ;==>Address_LoadStreet

; Load danh sách dự án
; Name ..........: Address_LoadProject
; Description ...: Load danh sách đường
; Syntax ........: Address_LoadProject()
; Parameters ....: None
; Return values .: $__g_a_ProjectName: Mảng chưa tên dự án
; Author ........: Trần Hùng
; Modified ......: 22/09/2022
Func Address_LoadProject()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_LoadProject")
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetProject"
	Local $data = "distId=" & $__g_i_DistrictId
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Global $__g_a_ProjectName = StringSplit($loadArrayName, "|", 2)
		Global $__g_a_ProjectId = StringSplit($loadArrayId, "|", 2)
		Local $isSave = True
	Else ; Không tìm thấy response nên phải thực hiện lại request
		Local $rq = _HttpRequest(2, $url, $data)
		Global $__g_a_ProjectName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Global $__g_a_ProjectId = StringRegExp($rq, '"Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($__g_a_ProjectName, $__g_a_ProjectId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Dự án", $__g_a_ProjectName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave, $urlGetResponseName, $__g_a_ProjectName)
	checkSaveResponse($isSave, $urlGetResponseId, $__g_a_ProjectId)
	Return $__g_a_ProjectName
EndFunc   ;==>Address_LoadProject

Func LoadResponse($url)
	Write_Log("===")
;~ 	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
;~ 	Write_Log("+ LoadResponse")
	Local $read = RegRead("HKEY_CURRENT_USER\Software\TPOST\RESPONSE", $url)
	Write_Log("> Tìm: " & $url)
	Write_Log("> Kết quả: " & $read)
	Return $read
EndFunc   ;==>LoadResponse

Func SaveResponse($url, $data)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ SaveResponse")
	Local $write = RegWrite($REG_RESPONSE, $url, "REG_MULTI_SZ", $data)
	If @error Then
		ErrorShow(16, "Lỗi nghiêm trọng", "Lưu dữ liệu thất bại Code: " & @error)
		Return SetError(@error, "", "")
	EndIf
EndFunc   ;==>SaveResponse

Func checkSaveResponse($isSave, $url, $arraySave)
;~ 	Write_Log("=====================")
;~ 	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
;~ 	Write_Log("+ checkSaveResponse")
	; Nếu lưu rồi thì không cần lưu nữa
	If $isSave = True Then Return False
	; Nếu chưa lưu thì lưu vào
	If IsArray($arraySave) = 1 Then
		SaveResponse($url, _ArrayToString($arraySave, "|"))
	Else
		SaveResponse($url, $arraySave)
	EndIf
	Return True
EndFunc   ;==>checkSaveResponse

; Check xem 2 mảng tìm được có phần tử nào không
; Name ..........: Address_CheckArray
; Description ...: Dùng để check xem 2 mảng tìm được có phần tử nào không
; Syntax ........: Address_CheckArray($arrayName, $arrayId)
; Parameters ....: $arrayName           - an array of unknowns.
;                  $arrayId             - an array of unknowns.
;                  $errorName           - Tên đặt trước lỗi VD: Phường, Quận, Thành phố.
; Return values .: True - 2 mảng đúng và có số phần tử bằng nhau
;                : @error = 1: Mảng tên sai
;                : @error = 2: Mảng ID sai
;                : @error = 3: 2 mảng có số phần tử khác nhau
; Author ........: Trần Hùng
; Modified ......: 24/08/2022
Func Address_CheckArray($arrayName, $arrayId)
	If IsArray($arrayName) = 0 Then
		Return SetError(1)
	ElseIf IsArray($arrayId) = 0 Then
		Return SetError(2)
	ElseIf UBound($arrayName) <> UBound($arrayId) Then
		Return SetError(3)
	Else
		Return True
	EndIf
EndFunc   ;==>Address_CheckArray

; Hiển thị mảng tìm được lên id combobox
; Name ..........: Address_ShowAddress
; Description ...: Hiển thị mảng tìm được lên id combobox
; Syntax ........: Address_ShowAddress($idCombo, $arrayName)
; Parameters ....: $idCombo             - id của Combobox muốn hiển thị.
;                  $arrayName           - Mảng muốn hiển thị.
; Return values .: False - idCombo sai
;                : True - Hiển thị thành công
; Author ........: Trần Hùng
; Modified ......: 24/08/2022
Func Address_ShowAddress($idName, $arrayName)
	Local $stringAdd
	If IsArray($arrayName) = 1 Then
		$stringAdd = _ArrayToString($arrayName)
	Else
		$stringAdd = $arrayName
	EndIf
	Switch $idName
		Case "Thành phố"
			GUICtrlSetData($__g_idCombo_Address_City, "|Tỉnh/thành phố|" & $stringAdd)
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_City, 0)
			Return True
		Case "Quận"
			GUICtrlSetData($__g_idCombo_Address_District, "|Quận/huyện|" & $stringAdd)
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_District, 0)
			Return True
		Case "Phường"
			GUICtrlSetData($__g_idCombo_Address_Ward, "|Phường/xã|" & $stringAdd)
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_Ward, 0)
			Return True
		Case "Đường"
			GUICtrlSetData($__g_idCombo_Address_Street, "|Đường|" & $stringAdd)
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_Street, 0)
			Return True
		Case "Dự án"
			GUICtrlSetData($__g_idCombo_Address_Project, "|Dự án|" & $stringAdd)
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_Project, 0)
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>Address_ShowAddress

Func Address_ChangeSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_ChangeSite")

	Local $siteIndex = _GUICtrlListBox_GetCurSel($__g_idList_Address_Site)
	If $siteIndex = -1 Then ; Không chọn web nào thì sẽ load từ web chính
		; Load Thành phố
		If $__g_s_CityName = "" Then ; Nếu người dùng chưa từng chọn thì sẽ reset về ban đầu
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_City,0)
		Else ; Nếu chọn rồi thì chọn lại
			_GUICtrlComboBox_SelectString($__g_idCombo_Address_City,$__g_s_CityName)
		EndIf
		; Load Quận
		If IsArray($__g_a_DistrictName) = 1 Then ; Nếu có mảng quận thì load ra
			Address_ShowAddress("Quận", $__g_a_DistrictName)
			If $__g_s_DistrictName <> "" Then
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_District,$__g_s_DistrictName)
			EndIf
		Else ; Nếu chưa thì reset
			GUICtrlSetData($__g_idCombo_Address_District, "|Quận/huyện")
		EndIf

		; Load Phường
		If IsArray($__g_a_WardName) = 1 Then ; Nếu có mảng quận thì load ra
			Address_ShowAddress("Phường", $__g_a_WardName)
			If $__g_s_WardName <> "" Then
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_Ward,$__g_s_WardName)
			EndIf
		Else ; Nếu chưa thì reset
			GUICtrlSetData($__g_idCombo_Address_Ward, "|Phường/xã")
		EndIf

		; Load Đường
		If IsArray($__g_a_StreetName) = 1 Then ; Nếu có mảng quận thì load ra
			Address_ShowAddress("Đường", $__g_a_StreetName)
			If $__g_s_StreetName <> "" Then
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_Street,$__g_s_StreetName)
			EndIf
		Else ; Nếu chưa thì reset
			GUICtrlSetData($__g_idCombo_Address_Street, "|Đường")
		EndIf

		; Load Dự án
		If IsArray($__g_a_ProjectName) = 1 Then ; Nếu có mảng quận thì load ra
			Address_ShowAddress("Dự án", $__g_a_ProjectName)
			If $__g_s_ProjectName <> "" Then
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_Project,$__g_s_ProjectName)
			EndIf
		Else ; Nếu chưa thì reset
			GUICtrlSetData($__g_idCombo_Address_Project, "|Dự án")
		EndIf

	Else ; Nếu người dùng muốn load địa chỉ từ 1 trang cụ thể nào đó
		; Load Thành phố
		Local $cityName = $arrayMain[$siteIndex][$eCityName]
		If $cityName = "" Then ; Nếu người dùng chưa chọn thì trở về index 0
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Address_City, 0)
		Else
			_GUICtrlComboBox_SelectString($__g_idCombo_Address_City, $cityName)
		EndIf

		; Load Quận
		Local $arrayDistrictName = $arrayMain[$siteIndex][$eArrayDistrictName]
		Local $districtName = $arrayMain[$siteIndex][$eDistrictName]
		Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
		If IsArray($arrayDistrictName) = 1 Then ; Nếu có mảng thì load ra
			Address_ShowAddress("Quận", $arrayDistrictName)
			Local $districtName = $arrayMain[$siteIndex][$eDistrictName]
			If $districtName <> "" Then ; Nếu người dùng đã chọn từ trước thì chọn lại
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_District, $districtName)
			EndIf
		ElseIf $districtName <> "" And $districtId <> "" Then ; Vì người dùng load địa chỉ đã lưu nên chỉ có 1 phần tử
			Address_ShowAddress("Quận", $districtName)
			_GUICtrlComboBox_SelectString($__g_idCombo_Address_District, $districtName)
		Else ; Nếu chưa có mảng thì reset
			GUICtrlSetData($__g_idCombo_Address_District, "|Quận/huyện")
		EndIf

		; Load Phường
		Local $arrayWardName = $arrayMain[$siteIndex][$eArrayWardName]
		Local $wardName = $arrayMain[$siteIndex][$eWardName]
		Local $wardId = $arrayMain[$siteIndex][$eWardId]
		If IsArray($arrayWardName) = 1 Then ; Nếu có mảng thì load ra
			Address_ShowAddress("Phường", $arrayWardName)
			Local $WardName = $arrayMain[$siteIndex][$eWardName]
			If $WardName <> "" Then ; Nếu người dùng đã chọn từ trước thì chọn lại
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_Ward, $WardName)
			EndIf
		ElseIf $wardName <> "" And $wardId <> "" Then ; Vì người dùng load địa chỉ đã lưu nên chỉ có 1 phần tử
			Address_ShowAddress("Phường", $wardName)
			_GUICtrlComboBox_SelectString($__g_idCombo_Address_Ward, $wardName)
		Else ; Nếu chưa có mảng thì reset
			GUICtrlSetData($__g_idCombo_Address_Ward, "|Phường/xã")
		EndIf

		; Load Đường
		Local $arrayStreetName = $arrayMain[$siteIndex][$eArrayStreetName]
		Local $streetName = $arrayMain[$siteIndex][$eStreetName]
		Local $streetId = $arrayMain[$siteIndex][$eStreetId]
		If IsArray($arrayStreetName) = 1 Then ; Nếu có mảng thì load ra
			Address_ShowAddress("Đường", $arrayStreetName)
			Local $streetName = $arrayMain[$siteIndex][$eStreetName]
			If $streetName <> "" And $streetId <> "" Then ; Nếu người dùng đã chọn từ trước thì chọn lại
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_Street, $StreetName)
			EndIf
		ElseIf $streetName <> "" And $streetId <> "" Then ; Vì người dùng load địa chỉ đã lưu nên chỉ có 1 phần tử
			Address_ShowAddress("Đường", $streetName)
			_GUICtrlComboBox_SelectString($__g_idCombo_Address_Street, $streetName)
		Else ; Nếu chưa có mảng thì reset
			GUICtrlSetData($__g_idCombo_Address_Street, "|Đường")
		EndIf

		; Load dự án
		Local $arrayProjectName = $arrayMain[$siteIndex][$eArrayProjectName]
		Local $projectName = $arrayMain[$siteIndex][$eProjectName]
		Local $projectId = $arrayMain[$siteIndex][$eProjectId]
		If IsArray($arrayProjectName) = 1 Then ; Nếu có mảng thì load ra
			Address_ShowAddress("Dự án", $arrayProjectName)
			Local $projectName = $arrayMain[$siteIndex][$eProjectName]
			If $projectName <> "" Then ; Nếu người dùng đã chọn từ trước thì chọn lại
				_GUICtrlComboBox_SelectString($__g_idCombo_Address_Project, $ProjectName)
			EndIf
		ElseIf $projectName <> "" And $projectId <> "" Then ; Vì người dùng load địa chỉ đã lưu nên chỉ có 1 phần tử
			Address_ShowAddress("Dự án", $projectName)
			_GUICtrlComboBox_SelectString($__g_idCombo_Address_Project, $projectName)
		Else ; Nếu chưa có mảng thì reset
			GUICtrlSetData($__g_idCombo_Address_Project, "|Dự án")
		EndIf
	EndIf
EndFunc

Func Address_SaveWard()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_SaveWard")
	Local $siteName = GUICtrlRead($__g_idList_Address_Site)
	Local $siteIndex = GUICtrlRead($__g_idList_Address_Site)
	Local $wardName = GUICtrlRead($__g_idCombo_Address_Ward)
	Local $indexWard = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_Ward)
	Switch $siteName
		Case ""
			Switch $indexWard
				Case -1,0
					$__g_s_WardName = ""
				Case Else
					$__g_s_WardName = $wardName
					$__g_s_WardId = $__g_a_WardId[$indexWard - 1] ; - 1 phần tử Phường/xã
					Address_EditShowAddress() ; Cập nhật lại địa chỉ hiển thị trên trang
			EndSwitch
		Case Else
			Switch $indexWard
				Case -1,0
					$arrayMain[$siteIndex][$eWardName] = ""
					$arrayMain[$siteIndex][$eWardId] = ""
				Case Else
					$arrayMain[$siteIndex][$eWardName] = $WardName
					Local $arrayWardId = $arrayMain[$siteIndex][$eArrayWardId]
					If IsArray($arrayWardId) = 1 Then
						$arrayMain[$siteIndex][$eWardId] = $arrayWardId[$indexWard - 1]
					EndIf
			EndSwitch
;~ 			Search_UpdateGUISearch() ; Cập nhật lại địa chỉ của GUI Search
	EndSwitch
EndFunc
Func Address_SaveStreet()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_SaveStreet")
	Local $siteName = GUICtrlRead($__g_idList_Address_Site)
	Local $siteIndex = GUICtrlRead($__g_idList_Address_Site)
	Local $streetName = GUICtrlRead($__g_idCombo_Address_Street)
	Local $indexStreet = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_Street)
	Switch $siteName
		Case ""
			Switch $indexStreet
				Case -1,0
					$__g_s_StreetName = ""
				Case Else
					$__g_s_StreetName = $streetName
					$__g_s_StreetId = $__g_a_StreetId[$indexStreet - 1] ; - 1 phần tử Đường
					Address_EditShowAddress() ; Cập nhật lại địa chỉ hiển thị trên trang
			EndSwitch
		Case Else
			Switch $indexStreet
				Case -1,0
					$arrayMain[$siteIndex][$eStreetName] = ""
					$arrayMain[$siteIndex][$eStreetId] = ""
				Case Else
					$arrayMain[$siteIndex][$eStreetName] = $StreetName
					Local $arrayStreetId = $arrayMain[$siteIndex][$eArrayStreetId]
					If IsArray($arrayStreetId) = 1 Then
						$arrayMain[$siteIndex][$eStreetId] = $arrayStreetId[$indexStreet - 1]
					EndIf
			EndSwitch
;~ 			Search_UpdateGUISearch() ; Cập nhật lại địa chỉ của GUI Search
	EndSwitch
EndFunc
Func Address_SaveProject()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Address Manager.au3")
	Write_Log("+ Address_SaveProject")
	Local $siteName = GUICtrlRead($__g_idList_Address_Site)
	Local $siteIndex = GUICtrlRead($__g_idList_Address_Site)
	Local $projectName = GUICtrlRead($__g_idCombo_Address_Project)
	Local $indexProject = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_Project)
	Switch $siteName
		Case ""
			Switch $indexProject
				Case -1,0
					$__g_s_ProjectName = ""
				Case Else
					$__g_s_ProjectName = $projectName
					$__g_s_ProjectId = $__g_a_ProjectId[$indexProject - 1] ; - 1 phần tử Đường
					Address_EditShowAddress() ; Cập nhật lại địa chỉ hiển thị trên trang
			EndSwitch
		Case Else
			Switch $indexProject
				Case -1,0
					$arrayMain[$siteIndex][$eProjectName] = ""
					$arrayMain[$siteIndex][$eProjectId] = ""
				Case Else
					$arrayMain[$siteIndex][$eProjectName] = $ProjectName
					Local $arrayProjectId = $arrayMain[$siteIndex][$eArrayProjectId]
					If IsArray($arrayProjectId) = 1 Then
						$arrayMain[$siteIndex][$eProjectId] = $arrayProjectId[$indexProject - 1]
					EndIf
			EndSwitch
;~ 			Search_UpdateGUISearch() ; Cập nhật lại địa chỉ của GUI Search
	EndSwitch
EndFunc

Func Address_EditShowAddress()
	Write_Log("=====================")
	Write_Log("+ Address_EditShowAddress")
	Local $cityName = GUICtrlRead($__g_idCombo_Address_City)
	Local $districtName = GUICtrlRead($__g_idCombo_Address_District)
	Local $wardName = GUICtrlRead($__g_idCombo_Address_Ward)
	Local $streetName = GUICtrlRead($__g_idCombo_Address_Street)
	Local $projectName = GUICtrlRead($__g_idCombo_Address_Project)
	Local $arrayAddress[0]
	If $projectName <> "Dự án" And $projectName <> "" Then
		_ArrayAdd($arrayAddress,$projectName)
	EndIf
	If $streetName <> "Đường" And $streetName <> "" Then
		_ArrayAdd($arrayAddress,$streetName)
	EndIf
	If $wardName <> "Phường/xã" And $wardName <> "" Then
		_ArrayAdd($arrayAddress,$wardName)
	EndIf
	If $districtName <> "Quận/huyện" Then
		_ArrayAdd($arrayAddress,$districtName)
	EndIf
	If $cityName <> "Tỉnh/thành phố" Then
		_ArrayAdd($arrayAddress,$cityName)
	EndIf
	Local $address2 = StringRegExpReplace(_ArrayToString($arrayAddress, ", "), "\, +$", "") ; Xóa "," cuối
	Global $__g_s_AddressPost = StringRegExpReplace($address2, "\, {2,10}", ", ") ; Xóa ",,"
	GUICtrlSetData($__g_idInput_Address_Direct,$__g_s_AddressPost)
EndFunc
Func Address_LoadSavedAddressName()
	; Lưu địa chỉ vào reg để lần sau dùng lại
	; Name ..........: Address_SaveAddress
	; Description ...: Lưu địa chỉ vào reg để lần sau dùng lại
	;                : Kích hoạt khi người dùng bấm vào nút lưu địa chỉ
	; Syntax ........: Address_SaveAddress()
	; Return values .: @error = 1 - Người dùng bấm Cancel thông báo nhập tên gợi nhớ
	;                : @error = 2 - Người dùng không nhập tên
	;                : @error = 3,4,5 - Gặp lỗi khi lưu địa chỉ bằng hàm RegWrite
	;                : True - Thành công
	Write_Log("=====================")
	Write_Log("+ Address_LoadSavedAddress")
	Local $arrayName[0]
	Local $arraySavedAddress = Address_LoadTotalSavedAddress()
	If UBound($arraySavedAddress) = 0 Then ; Nếu không có địa chỉ thì phải reset lại như ban đầu
		GUICtrlSetData($__g_idCombo_Address_SavedAddress, "|Địa chỉ đã lưu")
		_GUICtrlComboBox_SelectString($__g_idCombo_Address_SavedAddress, "Địa chỉ đã lưu")
		Return False
	EndIf
	GUICtrlSetData($__g_idCombo_Address_SavedAddress, "|Địa chỉ đã lưu|" & _ArrayToString($arraySavedAddress))
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_SavedAddress, "Địa chỉ đã lưu")
	GUICtrlSetState($__g_idCombo_Address_SavedAddress,$GUI_SHOW + $GUI_ENABLE)
	Return True
EndFunc
Func Address_SaveAddress()	; Lưu địa chỉ vào reg để lần sau dùng lại
	Write_Log("=====================")
	Write_Log("+ Address_SaveAddress")
	Local $currentAddress = GUICtrlRead($__g_idCombo_Address_SavedAddress)
	If $currentAddress = "Địa chỉ đã lưu" Then
		$currentAddress = ""
	EndIf
	; B1: Hiển thị dialog hỏi người dùng tên địa chỉ muốn lưu
	Local $fileSaveName = InputBox("Thông báo", "Nhập tên gợi nhớ muốn lưu", $currentAddress)
	If @error = 1 Then
		Return SetError(1)
	ElseIf $fileSaveName = "" Then
		ErrorShow(16,'',"Tên không được để trống")
		Return SetError(2)
	EndIf

	Local $stringSave
	For $i = 0 To UBound($arrayMain) - 1
		$stringSave &= $arrayMain[$i][0]
		For $i2 = 3 To 21 Step 2
			$stringSave &= "|" & $arrayMain[$i][$i2]
		Next
		If $i <> UBound($arrayMain) - 1 Then
			$stringSave &= @LF
		EndIf
	Next
	Local $base64Name = _StringToBase64($fileSaveName)

	; Lưu tên của địa chỉ
	Local $saveName = RegWrite($REG_SAVEADDRESS & $base64Name,"name","REG_SZ",$fileSaveName)
	If $saveName = 0 Then
		ErrorShow(16,"","Lưu địa chỉ thất bại #1")
		Return SetError(3)
	EndIf

	; Lưu tên của địa chỉ
	Local $saveValue = RegWrite($REG_SAVEADDRESS & $base64Name,"value","REG_MULTI_SZ",$stringSave)
	If $saveValue = 0 Then
		ErrorShow(16,"","Lưu địa chỉ thất bại #2")
		Return SetError(4)
	EndIf

	Local $saveDirect = RegWrite($REG_SAVEADDRESS & $base64Name,"direct","REG_SZ",$__g_s_AddressPost)
	If $saveDirect = 0 Then
		ErrorShow(16,"","Lưu địa chỉ thất bại #3")
		Return SetError(5)
	EndIf

	ErrorShow(64,"Thành công","Lưu địa chỉ thành công",2)
	GUICtrlSetData($__g_idCombo_Address_SavedAddress,$fileSaveName)
	Return True
EndFunc
Func Address_LoadTotalSavedAddress()
	Write_Log("=====================")
	Write_Log("+ Address_LoadTotalSavedAddress")
	Local $i = 1
	Local $arrayAddressName[0]
	While 1
		Local $read = RegEnumKey($REG_SAVEADDRESS,$i)
		If $read = "" Then
			ExitLoop
		Else
			_ArrayAdd($arrayAddressName,_Base64ToString($read))
			$i += 1
		EndIf
	WEnd
	Return $arrayAddressName
EndFunc
Func Address_LoadSavedAddress()
	Write_Log("=====================")
	Write_Log("+ Address_LoadSavedAddress")
	Local $currentId
	Local $currentName
	Local $nameSearch
	; B1: Lấy tên địa chỉ cần load thông tin
	Local $nameSearch = GUICtrlRead(@GUI_CtrlId)
	If $nameSearch = "Địa chỉ đã lưu" Then
		Address_ResetAddress()
		Return SetError(1)
	EndIf
	Local $base64Name = _StringToBase64($nameSearch)
	; B2: Đọc Reg load thông tin
	Local $readReg = RegRead($REG_SAVEADDRESS & "\" & $base64Name,"value")
	If $readReg = "" Then
		Return SetError(2)
	EndIf
	; B3: Tạo mảng 2 chiều từ dữ liệu đọc được
	Local $arrayReturn = StringSplit2D($readReg,"|",@LF)
	If UBound($arrayReturn) = 0 Then
		Return SetError(3)
	EndIf
	Local $arrayMiss[0]
	For $i = 0 To UBound($arrayMain) - 1
		For $i2 = 0 To UBound($arrayReturn) - 1
			If $arrayMain[$i][0] = $arrayReturn[$i2][0] Then ; Đã tìm thấy
				Write_Log("Đã tìm thấy: " & $arrayMain[$i][0])
				Local $next = 1
				For $i3 = 3 To 21 Step 2
					$arrayMain[$i][$i3] = $arrayReturn[$i2][$next]
					Write_Log(">" & $arrayReturn[$i2][$next])
					$next += 1
				Next
				ExitLoop
			ElseIf $arrayMain[$i][0] <> $arrayReturn[$i2][0] And $i2 = UBound($arrayReturn) - 1 Then ; Không tìm thấy web
				_ArrayAdd($arrayMiss, $arrayMain[$i][0]) ; Phải thêm vào array vì có thể người dùng không chỉ thiếu địa chỉ ở 1 trang
				Write_Log("Không tìm thấy: " & $arrayMain[$i][0])
			EndIf
		Next
	Next

	If UBound($arrayMiss) > 0 Then
		Local $msg = "Trang web: " & _ArrayToString($arrayMiss) & " bị thiếu địa chỉ"
		$msg &= '\nBạn nên cập nhật lại địa chỉ rồi ấn |Lưu địa chỉ| để sử dụng cho lần sau'
		ErrorShow(48,"Thông báo",$msg)
	EndIf

	Local $indexSite = _GUICtrlListBox_GetCurSel($__g_idList_Address_Site)
	If $indexSite = -1 Then
		$indexSite = 0
	EndIf
	If UBound($arrayMain) > 0 Then
		Local $cityName = $arrayMain[$indexSite][$eCityName]
		Local $districtName = $arrayMain[$indexSite][$eDistrictName]
		Local $wardName = $arrayMain[$indexSite][$eWardName]
		Local $streetName = $arrayMain[$indexSite][$eStreetName]
		Local $projectName = $arrayMain[$indexSite][$eProjectName]

		_GUICtrlComboBox_SelectString($__g_idCombo_Address_City, $cityName)

		GUICtrlSetData($__g_idCombo_Address_District, "|Quận/huyện|" & $districtName)
		_GUICtrlComboBox_SelectString($__g_idCombo_Address_District, $districtName)

		GUICtrlSetData($__g_idCombo_Address_Ward, "|Phường/xã|" & $wardName)
		_GUICtrlComboBox_SelectString($__g_idCombo_Address_Ward, $wardName)

		GUICtrlSetData($__g_idCombo_Address_Street, "|Đường|" & $streetName)
		_GUICtrlComboBox_SelectString($__g_idCombo_Address_Street, $streetName)

		GUICtrlSetData($__g_idCombo_Address_Project, "|Dự án|" & $projectName)
		_GUICtrlComboBox_SelectString($__g_idCombo_Address_Project, $projectName)
	EndIf

	; Load địa chỉ hiển thị trên website
	Local $directAddress = RegRead($REG_SAVEADDRESS & "\" & $base64Name,"direct")
	GUICtrlSetData($__g_idInput_Address_Direct,$directAddress)
EndFunc
Func Address_ResetAddress()
	Write_Log("=====================")
	Write_Log("+ Address_ResetAddress")
	For $i = 0 To UBound($arrayMain) - 1
		For $i2 = 3 To UBound($arrayMain, 2) - 1
			$arrayMain[$i][$i2] = ""
		Next
	Next

	_GUICtrlComboBox_SelectString($__g_idCombo_Address_City, "Tỉnh/thành phố")

	GUICtrlSetData($__g_idCombo_Address_District, "|Quận/huyện")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_District, "Quận/huyện")

	GUICtrlSetData($__g_idCombo_Address_Ward, "|Phường/xã")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_Ward, "Phường/xã")

	GUICtrlSetData($__g_idCombo_Address_Street, "|Đường")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_Street, "Đường")

	GUICtrlSetData($__g_idCombo_Address_Project, "|Dự án")
	_GUICtrlComboBox_SelectString($__g_idCombo_Address_Project, "Dự án")

	GUICtrlSetData($__g_idInput_Address_Direct,"")

	$__g_s_AddressPost = ""

	_GUICtrlComboBox_SelectString($__g_idCombo_Address_SavedAddress, "Địa chỉ đã lưu")
EndFunc
Func Address_RemoveAddress()
	Write_Log("=====================")
	Write_Log("+ Address_RemoveAddress")
	; Lấy tên địa chỉ cần xóa
	Local $currentAddress = GUICtrlRead($__g_idCombo_Address_SavedAddress)
	RegDelete($REG_SAVEADDRESS & _StringToBase64($currentAddress)) ; Xóa key trong reg
	Address_LoadSavedAddressName() ; Load lại danh sách tên địa chỉ đã lưu
EndFunc

Func LoadArrayKeyFromReg($regAddress)
	Local $i = 1
	Local $arrayKey[0]
	While 1
		Local $read = RegEnumKey($regAddress,$i)
		If $read = "" Then
			ExitLoop
		Else
			_ArrayAdd($arrayKey,$read)
			$i += 1
		EndIf
	WEnd
	Return $arrayKey
EndFunc

Func Address_SaveDirect()
	Write_Log("=====================")
	Write_Log("+ Address_SaveDirect")
	$__g_s_AddressPost = GUICtrlRead($__g_idInput_Address_Direct)
	Return $__g_s_AddressPost
EndFunc
