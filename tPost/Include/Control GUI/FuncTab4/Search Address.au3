Func Address_Search_GUI()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_Search_GUI")
	; Tắt button tìm kiếm để khi người dùng nhấn nhầm thêm lần nữa thì không hiện thêm GUI search
	GUICtrlSetState($__g_idButton_Address_Search,$GUI_DISABLE)
	Global $__g_s_CitySearch = GUICtrlRead($__g_idCombo_Address_City)
	Global $__g_s_DistrictSearch = GUICtrlRead($__g_idCombo_Address_District)
	If $__g_s_CitySearch = "Tỉnh/thành phố" Then
		ErrorShow(16,'',"Xin vui lòng chọn Tỉnh/thành phố")
		Return 2
	EndIf
	If $__g_s_DistrictSearch = "Quận/huyện" Then
		ErrorShow(16,'',"Xin vui lòng chọn Quận/huyện")
		Return 3
	EndIf
	Local $hFont = _WinAPI_CreateFont(20, 0, 0, 0, 400,False,False,False,Default,Default,Default,Default,0,"Times New Roman")
	Global $__g_h_GUISearch = GUICreate("Tìm kiếm địa chỉ", 928, 485,-1,-1)
	Local $header = "Tên trang|Thành phố|Quận|Phường|Đường|Dự án"
	Global $__g_idListview_SearchAddress = _GUICtrlListView_Create($__g_h_GUISearch,$header, 3, 6, 920, 370)
	_WinAPI_SetFont($__g_idListview_SearchAddress, $hFont, True)
	_GUICtrlListView_SetExtendedListViewStyle($__g_idListview_SearchAddress, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES))
	Global $__g_idLabel_SearchAddress = GUICtrlCreateLabel("Đang tìm kiếm địa chỉ, xin vui lòng chờ trong giây lát", 2, 417, 928, 75, $SS_CENTER)
	GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
	GUISetState(@SW_SHOW,$__g_h_GUISearch)
	Address_Search_CheckSite()
	GUICtrlSetData($__g_idLabel_SearchAddress,"Tìm địa chỉ thành công")
	GUISetOnEvent($GUI_EVENT_CLOSE,"Address_Search_GUI_Exit",$__g_h_GUISearch)
;~ 	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
EndFunc

Func Address_Search_GUI_Exit()
	GUIDelete($__g_h_GUISearch)
	GUICtrlSetState($__g_idButton_Address_Search,$GUI_ENABLE) ; Bật lại nút tìm kiếm
EndFunc

Func Address_Search_CheckSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_Search_CheckSite")

	Local $idCitySearch, $idDistrictSearch, $idWardSearch, $idStreetSearch, $idProjectSearch

	Local $citySearch = GUICtrlRead($__g_idCombo_Address_City)
	Local $districtSearch = GUICtrlRead($__g_idCombo_Address_District)
	Local $wardSearch = GUICtrlRead($__g_idCombo_Address_Ward)
	Local $streetSearch = GUICtrlRead($__g_idCombo_Address_Street)
	Local $projectSearch = GUICtrlRead($__g_idCombo_Address_Project)

	Local $cityIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_City)
	Local $districtIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_District)
	Local $wardIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_Ward)
	Local $streetIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_Street)
	Local $projectIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Address_Project)

	If $__g_s_CitySearch = "Tỉnh/thành phố" Then
		ErrorShow(48,'',"Xin vui lòng chọn Tỉnh/thành phố")
		Return 0
	EndIf
	If $__g_s_DistrictSearch = "Quận/huyện" Then
		ErrorShow(48,'',"Xin vui lòng chọn Quận/huyện")
		Return 0
	EndIf

	Local $arrayShow[0][6]

	; Lặp mảng web xem có web nào thì tìm địa chỉ ở web đó
	For $i = 0 To UBound($arrayMain) - 1
		Switch $arrayMain[$i][$eSite]
			Case "Dothi.net"
				$idCitySearch = Address_SearchCity_Dothi($i,$citySearch,$cityIndex) ; Function sẽ luôn ra kết quả đúng vì đã loại bỏ trường hợp người dùng không chọn
				$idDistrictSearch = Address_SearchDistrict_Dothi($i,$districtSearch,$districtIndex)
				If @error Then ContinueLoop
				$idWardSearch = Address_SearchWard_Dothi($i,$wardSearch,$wardIndex)
				$idStreetSearch = Address_SearchStreet_Dothi($i,$streetSearch,$streetIndex)
				$idProjectSearch = Address_SearchProject_Dothi($i,$projectSearch,$projectIndex)
			Case "Muaban.net"
				$idCitySearch = Address_SearchCity_Muaban($i,$citySearch,$cityIndex)
				$idDistrictSearch = Address_SearchDistrict_Muaban($i,$districtSearch,$districtIndex)
				If @error Then ContinueLoop
				$idWardSearch = Address_SearchWard_Muaban($i,$wardSearch,$wardIndex)
				$idStreetSearch = Address_SearchStreet_Muaban($i,$streetSearch,$streetIndex)
				$idProjectSearch = Address_SearchProject_Muaban($i,$projectSearch,$projectIndex)
			Case "Batdongsan.com.vn"
				$idCitySearch = Address_SearchCity_Bds($i,$citySearch,$cityIndex)
				$idDistrictSearch = Address_SearchDistrict_Bds($i,$districtSearch)
				If @error Then ContinueLoop
				$idWardSearch = Address_SearchWard_Bds($i,$wardSearch,$wardIndex)
				$idStreetSearch = Address_SearchStreet_Bds($i,$streetSearch,$streetIndex)
				$idProjectSearch = Address_SearchProject_Bds($i,$projectSearch,$projectIndex)
			Case "Bds123.vn"
				$idCitySearch 		= Address_SearchCity_Bds123($i,$citySearch,$cityIndex)
				$idDistrictSearch 	= Address_SearchDistrict_Bds123($i,$districtSearch)
				If @error Then ContinueLoop
				$idWardSearch = Address_SearchWard_Bds123($i,$wardSearch)
				$idStreetSearch = Address_SearchStreet_Bds123($i,$streetSearch)
				$idProjectSearch = Address_SearchProject_Bds123($i,$projectSearch)
			Case "Chotot.com"
				$idCitySearch		= Address_SearchCity_Chotot($i,$citySearch,$cityIndex)
				$idDistrictSearch 	= Address_SearchDistrict_Chotot($i,$districtSearch)
				If @error Then ContinueLoop
				$idWardSearch 		= Address_SearchWard_Chotot($i,$wardSearch)
				$idProjectSearch 	= Address_SearchProject_Chotot($i,$projectSearch)
			Case $THUECANHO123_URL
				$idCitySearch		= Address_SearchCity_Thuecanho123($i,$citySearch,$cityIndex)
				$idDistrictSearch	= Address_SearchDistrict_Thuecanho123($i,$districtSearch)
				If @error Then ContinueLoop
				$idWardSearch		= Address_SearchWard_Thuecanho123($i,$wardSearch)
				$idStreetSearch		= Address_SearchStreet_Thuecanho123($i,$streetSearch)
				$idProjectSearch	= Address_SearchProject_Thuecanho123($i,$projectSearch)
			Case $HOMEDY_URL
				If $HOMEDY_IS_LOGIN = False Then
					Local $login = AccountSetting_Homdy_Login()
					If @error Then
						ErrorShow(16,$HOMEDY_URL,"Xin vui lòng đăng nhập để sử dụng chức năng này")
						Return SetError(1)
					Else
						$HOMEDY_IS_LOGIN = True
						$idCitySearch		= Address_SearchCity_Homedy($i,$citySearch,$cityIndex)
					EndIf
				Else
					$idCitySearch		= Address_SearchCity_Homedy($i,$citySearch,$cityIndex)
				EndIf
				$idDistrictSearch	= Address_SearchDistrict_Homedy($i,$districtSearch)
				If @error Then ContinueLoop
				$idWardSearch		= Address_SearchWard_Homedy($i,$wardSearch)
				$idStreetSearch		= Address_SearchStreet_Homedy($i,$streetSearch)
				$idProjectSearch	= Address_SearchProject_Homedy($i,$projectSearch)
		EndSwitch
		_ArrayAdd($arrayShow,Address_Search_RefreshArraySearch($i))
	Next
	_GUICtrlListView_DeleteAllItems($__g_idListview_SearchAddress) ; Phải xóa phần tử cũ trước
	_GUICtrlListView_AddArray($__g_idListview_SearchAddress, $arrayShow)
	For $i = 0 To 5
		_GUICtrlListView_SetColumnWidth($__g_idListview_SearchAddress, $i, $LVSCW_AUTOSIZE)
		_GUICtrlListView_SetColumnWidth($__g_idListview_SearchAddress, $i, $LVSCW_AUTOSIZE_USEHEADER)
	Next
EndFunc

Func Address_Search_RefreshArraySearch($indexSite)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_Search_RefreshArraySearch")
	Local $web = $arrayMain[$indexSite][$eSite] & "|"
	Local $cityName = $arrayMain[$indexSite][$eCityName] & "|"
	Local $districtName = $arrayMain[$indexSite][$eDistrictName] & "|"
	Local $wardName = $arrayMain[$indexSite][$eWardName] & "|"
	Local $streetName = $arrayMain[$indexSite][$eStreetName] & "|"
	Local $projectName = $arrayMain[$indexSite][$eProjectName]
	Return $web & $cityName & $districtName & $wardName & $streetName & $projectName
EndFunc

Func Address_SearchCity_Thuecanho123($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchCity_Thuecanho123")
	; Lưu tên thành phố đã lựa chọn
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	; Tìm ID thành phố từ index thành phố trong combobox
	Local $idCity = $THUECANHO123_ARRAY_CITY_ID[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Lưu ID thành phố đã tìm được
	$arrayMain[$siteIndex][$eCityId] = $idCity
	Write_Log("Tên cần tìm: " & $citySearch)
	Write_Log("ID tìm thấy: " & $idCity)
	Return $idCity
EndFunc
Func Address_SearchDistrict_Thuecanho123($siteIndex,$districtSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchDistrict_Thuecanho123")
	Local $data = "province=" & $arrayMain[$siteIndex][$eCityId]
	Local $urlGetArrayName = $THUECANHO123_URL_GET_DISTRICT & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $THUECANHO123_URL_GET_DISTRICT & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$THUECANHO123_URL_GET_DISTRICT, $data)
		Local $decode = _HTMLDecode($rq)
		Local $arrayName = StringRegExp($decode, $THUECANHO123_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($decode,$THUECANHO123_REGEX_GET_ID, 3)
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: " & $THUECANHO123_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] 	= $arrayId
	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $THUECANHO123_URL_GET_DISTRICT & "|" & $data & "|" & $districtSearch & "|name"
	Local $urlGetResultId = $THUECANHO123_URL_GET_DISTRICT & "|" & $data & "|" & $districtSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eDistrictName] 	= $loadName
		$arrayMain[$siteIndex][$eDistrictId] 	= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($districtSearch, $arrayName, 0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Quận từ trang "&$THUECANHO123_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eDistrictName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eDistrictId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("DistrictName tìm thấy: " & $arrayName[$index])
		Write_Log("DistrictId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eDistrictName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eDistrictId])
	Return $arrayMain[$siteIndex][$eDistrictName]
EndFunc
Func Address_SearchWard_Thuecanho123($siteIndex,$wardSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchWard_Thuecanho123")
	Local $data = "district=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetArrayName = $THUECANHO123_URL_GET_WARD & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $THUECANHO123_URL_GET_WARD & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$THUECANHO123_URL_GET_WARD, $data)
		Local $decode = _HTMLDecode($rq)
		Local $arrayName = StringRegExp($decode, $THUECANHO123_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($decode,$THUECANHO123_REGEX_GET_ID, 3)
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: " & $THUECANHO123_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId
	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $THUECANHO123_URL_GET_WARD & "|" & $data & "|" & $wardSearch & "|name"
	Local $urlGetResultId = $THUECANHO123_URL_GET_WARD & "|" & $data & "|" & $wardSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eWardName] 	= $loadName
		$arrayMain[$siteIndex][$eWardId] 	= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($wardSearch, $arrayName, 0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang "&$THUECANHO123_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eWardName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eWardId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("WardName tìm thấy: " & $arrayName[$index])
		Write_Log("WardId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eWardName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eWardId])
	Return $arrayMain[$siteIndex][$eWardName]
EndFunc
Func Address_SearchStreet_Thuecanho123($siteIndex,$streetSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchStreet_Thuecanho123")
	Local $data = "district=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetArrayName = $THUECANHO123_URL_GET_STREET & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $THUECANHO123_URL_GET_STREET & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$THUECANHO123_URL_GET_STREET, $data)
		Local $decode = _HTMLDecode($rq)
		Local $arrayName = StringRegExp($decode,$THUECANHO123_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($decode,$THUECANHO123_REGEX_GET_ID, 3)
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: " & $THUECANHO123_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayId
	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $THUECANHO123_URL_GET_STREET & "|" & $data & "|" & $streetSearch & "|name"
	Local $urlGetResultId = $THUECANHO123_URL_GET_STREET & "|" & $data & "|" & $streetSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eStreetName] 	= $loadName
		$arrayMain[$siteIndex][$eStreetId] 		= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($streetSearch, $arrayName, 0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Đường từ trang "&$THUECANHO123_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eStreetName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eStreetId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("StreetName tìm thấy: " & $arrayName[$index])
		Write_Log("StreetId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eStreetName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eStreetId])
	Return $arrayMain[$siteIndex][$eStreetName]
EndFunc
Func Address_SearchProject_Thuecanho123($siteIndex,$projectSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchProject_Thuecanho123")
	Local $data = '{"province":' & $arrayMain[$siteIndex][$eCityId] & ',"district":' & $arrayMain[$siteIndex][$eDistrictId] & '}'
	Local $urlGetArrayName = $THUECANHO123_URL_GET_PROJECT & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $THUECANHO123_URL_GET_PROJECT & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$THUECANHO123_URL_GET_PROJECT,$data)
		Local $jsonProject = _HttpRequest_ParseJSON($rq)
		If $jsonProject = "" Then
			Return SetError(1)
		EndIf
		Local $filter_ProjectName = $jsonProject.filter('$.data[*].title')
		Local $filter_ProjectId = $jsonProject.filter('$.data[*].id')
		Local $arrayName = _HttpRequest_ParseJSON($filter_ProjectName)
		Local $arrayId = _HttpRequest_ParseJSON($filter_ProjectId)
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		Return SetError(@error)
	EndIf
	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayProjectName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] 	= $arrayId
	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $THUECANHO123_URL_GET_PROJECT & "|" & $data & "|" & $projectSearch & "|name"
	Local $urlGetResultId = $THUECANHO123_URL_GET_PROJECT & "|" & $data & "|" & $projectSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eProjectName] 	= $loadName
		$arrayMain[$siteIndex][$eProjectId] 		= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($projectSearch, $arrayName, 0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Dự án từ trang "&$THUECANHO123_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eProjectName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eProjectId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("ProjectName tìm thấy: " & $arrayName[$index])
		Write_Log("ProjectId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eProjectName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eProjectId])
	Return $arrayMain[$siteIndex][$eProjectName]
EndFunc

Func Address_SearchCity_Homedy($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchCity_Homedy")
	; Lưu tên thành phố đã lựa chọn
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	; Tìm ID thành phố từ index thành phố trong combobox
	Local $idCity = $HOMEDY_ARRAY_CITY_ID[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Lưu ID thành phố đã tìm được
	$arrayMain[$siteIndex][$eCityId] = $idCity
	Write_Log("Tên cần tìm: " & $citySearch)
	Write_Log("ID tìm thấy: " & $idCity)
	Return $idCity
EndFunc
Func Address_SearchDistrict_Homedy($siteIndex,$districtSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchDistrict_Homedy")
	Local $cityId = $arraymain[$siteIndex][$eCityId]
	Local $url = Homedy_Url_Get_District($cityId)
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$url)
		Local $arrayPre = StringRegExp($rq,'"Pre":"(.*?)"', 3)
		If @error Then
			ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: " & $HOMEDY_URL & " #1")
			Return SetError(1)
		EndIf
		Local $arrayName = StringRegExp($rq,'"Name":"(.*?)"',3)
		If @error Then
			ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: " & $HOMEDY_URL & " #2")
			Return SetError(2)
		EndIf
		Local $arrayId = StringRegExp($rq,'"Id":(\d+),',3)
		If @error Then
			ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: " & $HOMEDY_URL & " #3")
			Return SetError(3)
		EndIf
		For $i = 0 To UBound($arrayName) - 1
			$arrayName[$i] = $arrayPre[$i] & " " & $arrayName[$i]
		Next
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: " & $HOMEDY_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] 	= $arrayId
	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $HOMEDY_URL & "|" & $districtSearch & "|name"
	Local $urlGetResultId = $HOMEDY_URL & "|" & $districtSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eDistrictName] 	= $loadName
		$arrayMain[$siteIndex][$eDistrictId] 	= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($districtSearch,$arrayName,0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Quận từ trang "&$HOMEDY_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eDistrictName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eDistrictId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("DistrictName tìm thấy: " & $arrayName[$index])
		Write_Log("DistrictId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eDistrictName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eDistrictId])
	Return $arrayMain[$siteIndex][$eDistrictName]
EndFunc
Func Address_SearchWard_Homedy($siteIndex,$wardSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchWard_Homedy")
	Local $districtId = $arraymain[$siteIndex][$eDistrictId]
	Local $url = Homedy_Url_Get_Ward($districtId)
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$url)
		Local $arrayPre = StringRegExp($rq,'"Pre":"(.*?)"', 3)
		If @error Then
			ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: " & $HOMEDY_URL & " #1")
			Return SetError(1)
		EndIf
		Local $arrayName = StringRegExp($rq,'"Name":"(.*?)"',3)
		If @error Then
			ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: " & $HOMEDY_URL & " #2")
			Return SetError(2)
		EndIf
		Local $arrayId = StringRegExp($rq,'"Id":(\d+),',3)
		If @error Then
			ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: " & $HOMEDY_URL & " #3")
			Return SetError(3)
		EndIf
		For $i = 0 To UBound($arrayName) - 1
			$arrayName[$i] = $arrayPre[$i] & " " & $arrayName[$i]
		Next
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: " & $HOMEDY_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId
	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $HOMEDY_URL & "|" & $wardSearch & "|name"
	Local $urlGetResultId = $HOMEDY_URL & "|" & $wardSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eWardName] 	= $loadName
		$arrayMain[$siteIndex][$eWardId] 	= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($wardSearch,$arrayName,0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang "&$HOMEDY_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eWardName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eWardId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("WardName tìm thấy: " & $arrayName[$index])
		Write_Log("WardId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eWardName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eWardId])
	Return $arrayMain[$siteIndex][$eWardName]
EndFunc
Func Address_SearchStreet_Homedy($siteIndex,$streetSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchStreet_Homedy")
	Local $districtId = $arraymain[$siteIndex][$eDistrictId]
	Local $url = Homedy_Url_Get_Street($districtId)
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$url)
		Local $arrayName = StringRegExp($rq,'"Name":"(.*?)"',3)
		Local $arrayId = StringRegExp($rq,'"Id":(\d+),',3)
		Local $isSaved = False
	EndIf
	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: " & $HOMEDY_URL & " #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $HOMEDY_URL & "|" & $streetSearch & "|name"
	Local $urlGetResultId = $HOMEDY_URL & "|" & $streetSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eStreetName] 	= $loadName
		$arrayMain[$siteIndex][$eStreetId] 		= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($streetSearch,$arrayName,0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Đường từ trang "&$HOMEDY_URL&"\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eStreetName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eStreetId] 		= $arrayId[$index]
		Local $saveResult = False
		Write_Log("StreetName tìm thấy: " & $arrayName[$index])
		Write_Log("StreetId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eStreetName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eStreetId])
	Return $arrayMain[$siteIndex][$eStreetName]
EndFunc
Func Address_SearchProject_Homedy($siteIndex,$projectSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchProject_Homedy")
	Local $url = Homedy_Url_Get_Project($projectSearch)
	Local $loadResponse = LoadResponse($url)
	Local $loadResponseId = LoadResponse($url)
	If $loadResponse <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $rq = $loadResponse
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$url)
		Local $isSaved = False
	EndIf
	Local $arrayName = StringRegExp($rq,'"Name":"(.*?)"',3)
	Local $arrayId = StringRegExp($rq,'"Id":(\d+),',3)

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: " & $HOMEDY_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; Lưu vị trí tên và ID quận đã tìm thấy (Lấy vị trí đầu luôn vì web đã tìm sẵn rồi)
	$arrayMain[$siteIndex][$eProjectName] 	= $arrayName[0]
	$arrayMain[$siteIndex][$eProjectId] 	= $arrayId[0]
	Write_Log("ProjectName tìm thấy: " & $arrayName[0])
	Write_Log("ProjectId tìm thấy: " & $arrayName[0])
	checkSaveResponse($isSaved,$url,$rq)
	Return $arrayMain[$siteIndex][$eProjectName]
EndFunc


