Func Address_LoadDistrict_Muaban($siteIndex,$cityName,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab/Load Address.au3")
	Write_Log("+ Address_LoadDistrict_Muaban")
	; Save City Name
	$arrayMain[$siteIndex][$eCityName] = $cityName
	; Save CityId
	$arrayMain[$siteIndex][$eCityId] = $MUABAN_ARRAY_CITY_ID[$cityIndex - 1] ; Save City Id
	; Filter District
	Local $filterDistrictName = $MUABAN_JSON_DATA_ADDRESS.filter('$.[?(@.parent == ' & $arrayMain[$siteIndex][$eCityId] & ')].name')
	Local $filterDistrictId = $MUABAN_JSON_DATA_ADDRESS.filter('$.[?(@.parent == ' & $arrayMain[$siteIndex][$eCityId] & ')].id')
	; Convert to json to Array
	Local $arrayName = _HttpRequest_ParseJSON($filterDistrictName)
	Local $arrayId = _HttpRequest_ParseJSON($filterDistrictId)
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: Muaban.net #" & @error)
		Return SetError(@error)
	EndIf
	; Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Quận",$arrayName)
	Return $arrayName
EndFunc
Func Address_LoadWard_Muaban($siteIndex,$districtName,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab/Load Address.au3")
	Write_Log("+ Address_LoadWard_Muaban")
	; Lưu districtName
	$arrayMain[$siteIndex][$eDistrictName] = $districtName
	Local $arrayId = $arrayMain[$siteIndex][$eArrayDistrictId]
	; Lưu districtId từ vị trí đã có
	$arrayMain[$siteIndex][$eDistrictId] = $arrayId[$districtIndex - 1]
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Muaban_UrlGetWard($districtId)
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetResponseName = $url & "|arrayname"
	Local $urlGetResponseId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName = StringRegExp($rq,$MUABAN_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq,$MUABAN_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo lỗi","Gặp lỗi khi tải danh sách Phường từ web: Muaban.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadStreet_Muaban($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab/Load Address.au3")
	Write_Log("+ Address_LoadStreet_Muaban")
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Muaban_UrlGetStreet($districtId)
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetResponseName = $url & "|arrayname"
	Local $urlGetResponseId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName = StringRegExp($rq,$MUABAN_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq,$MUABAN_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf


	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo lỗi","Gặp lỗi khi tải danh sách Đường từ web: Muaban.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] = $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Đường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadProject_Muaban($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab/Load Address.au3")
	Write_Log("+ Address_LoadProject_Muaban")
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Muaban_UrlGetProject($districtId)
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetResponseName = $url & "|arrayname"
	Local $urlGetResponseId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName = StringRegExp($rq,$MUABAN_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq,$MUABAN_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf


	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo lỗi","Gặp lỗi khi tải danh sách Dự án từ web: Muaban.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayProjectName] = $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Dự án",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc

Func Muaban_UrlGetWard($districtId)
	Return "https://api-v6.muaban.net/listing/v1/wards/" & $districtId & "/by-parent"
EndFunc
Func Muaban_UrlGetStreet($districtId)
	Return "https://api-v6.muaban.net/listing/v1/streets/" & $districtId & "/by-parent"
EndFunc
Func Muaban_UrlGetProject($districtId)
	Return "https://api-v6.muaban.net/listing/v1/projects/" & $districtId & "/by-parent"
EndFunc

Func Address_SearchCity_Muaban($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchCity_Muaban")
	; Lưu tên thành phố đã lựa chọn
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	; Tìm ID thành phố từ index thành phố trong combobox
	Local $idCity = $MUABAN_ARRAY_CITY_ID[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Lưu ID thành phố đã tìm được
	$arrayMain[$siteIndex][$eCityId] = $idCity
	Write_Log("Tìm ID thành phố")
	Write_Log("Tên cần tìm: " & $citySearch)
	Write_Log("ID tìm thấy: " & $idCity)
	Return $idCity
EndFunc
Func Address_SearchDistrict_Muaban($siteIndex,$districtSearch,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ Address_SearchDistrict_Muaban")
	; Lấy ra cityId từ siteIndex
	Local $cityId = $arrayMain[$siteIndex][$eCityId]
	Local $filterDistrictName 	= $MUABAN_JSON_DATA_ADDRESS.filter('$.[?(@.parent == ' & $cityId & ')].name')
	Local $filterDistrictId 	= $MUABAN_JSON_DATA_ADDRESS.filter('$.[?(@.parent == ' & $cityId & ')].id')
	; Convert to json to Array
	Local $arrayDistrictName = _HttpRequest_ParseJSON($filterDistrictName)
	Local $arrayDistrictId = _HttpRequest_ParseJSON($filterDistrictId)
	Local $checkArray = Address_CheckArray($arrayDistrictName,$arrayDistrictId)
	If @error Then
		Return SetError(@error)
	EndIf
	; Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayDistrictName
	$arrayMain[$siteIndex][$eArrayDistrictId] = $arrayDistrictId
	; Không thể lấy kết quả từ trước vì không có URL để lưu, vì vậy luôn phải so sánh lại
	Local $index = Compare2($districtSearch, $arrayDistrictName, 0)
	If $index = -1 Then
		$arrayMain[$siteIndex][$eDistrictName] = ""
		$arrayMain[$siteIndex][$eDistrictId] = ""
		Return SetError(4)
	Else
		; Save DistrictName
		$arrayMain[$siteIndex][$eDistrictName] = $arrayDistrictName[$index]
		Write_Log("DistrictName tìm thấy: " & $arrayDistrictName[$index])
		; Save DistrictId
		$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrictId[$index]
		Write_Log("DistrictId tìm thấy: " & $arrayDistrictId[$index])
	EndIf
EndFunc
Func Address_SearchWard_Muaban($siteIndex,$wardSearch,$wardIndex)
	Write_Log("=====================")
	Write_Log("+ Address_SearchWard_Muaban")
	Switch $wardSearch
		Case "", "Phường/xã"
			$arrayMain[$siteIndex][$eWardName] = ""
			$arrayMain[$siteIndex][$eWardId] = ""
			Return SetError(1)
	EndSwitch

	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Muaban_UrlGetWard($districtId)
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName = StringRegExp($rq,$MUABAN_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq,$MUABAN_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo lỗi","Gặp lỗi khi tải danh sách Phường từ web: Muaban.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] = $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $wardSearch & "|name"
	Local $urlGetResultId = $url & "|" & $wardSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang Muaban.net\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eWardName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eWardId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("WardName tìm thấy: " & $arrayName[$index])
		Write_Log("WardId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eWardName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eWardId])
	Return $arrayMain[$siteIndex][$eWardName]
EndFunc
Func Address_SearchStreet_Muaban($siteIndex,$streetSearch,$streetIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchStreet_Muaban")
	Switch $streetSearch
		Case "", "Đường"
			$arrayMain[$siteIndex][$eStreetName] = ""
			$arrayMain[$siteIndex][$eStreetId] = ""
			Return SetError(1)
	EndSwitch

	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Muaban_UrlGetStreet($districtId)
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName = StringRegExp($rq,$MUABAN_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq,$MUABAN_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] = $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] = $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $streetSearch & "|name"
	Local $urlGetResultId = $url & "|" & $streetSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Đường từ trang Muaban.net\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eStreetName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eStreetId] 		= $arrayId[$index]
		Local $saveResult = False
		Write_Log("DistrictName tìm thấy: " & $arrayName[$index])
		Write_Log("DistrictId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eStreetName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eStreetId])
	Return $arrayMain[$siteIndex][$eStreetName]
EndFunc
Func Address_SearchProject_Muaban($siteIndex,$projectSearch,$projectIndex)
	Write_Log("=====================")
	Write_Log("+ Address_SearchProject_Muaban")
	Switch $projectSearch
		Case "", "Dự án"
			$arrayMain[$siteIndex][$eProjectName] = ""
			$arrayMain[$siteIndex][$eProjectId] = ""
			Return SetError(1)
	EndSwitch

	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Muaban_UrlGetProject($districtId)
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName = StringRegExp($rq,$MUABAN_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq,$MUABAN_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayProjectName] = $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] = $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $projectSearch & "|name"
	Local $urlGetResultId = $url & "|" & $projectSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)
	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eProjectName] 	= $loadName
		$arrayMain[$siteIndex][$eProjectId] 	= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($projectSearch, $arrayName, 0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Dự án từ trang Muaban.net\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eProjectName] 		= $arrayName[$index]
		$arrayMain[$siteIndex][$eProjectId] 		= $arrayId[$index]
		Local $saveResult = False
		Write_Log("DistrictName tìm thấy: " & $arrayName[$index])
		Write_Log("DistrictId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eProjectName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eProjectId])
	Return $arrayMain[$siteIndex][$eProjectName]
EndFunc
