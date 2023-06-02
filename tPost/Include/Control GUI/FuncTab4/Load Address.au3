Func Address_LoadDistrict_Dothi_Old($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab/Load Address.au3")
	Write_Log("+ Address_LoadDistrict_Dothi")
	Local $cityId = $__g_a_CityId[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Bước 1: Lưu tên thành phố
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	$arrayMain[$siteIndex][$eCityId] = $cityId

	; Bước 2: Lấy danh sách quận từ id thành phố đã lấy được
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetDistrict"
	Local $data = "cityCode=" & $cityId
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url, $data)
		Local $arrayName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Local $arrayId = StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Quận",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadWard_Dothi_Old($siteIndex,$districtName,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadWard_Dothi")
	; Save District Name
	$arrayMain[$siteIndex][$eDistrictName] = $districtName
	; Get arrayDistrictId
	Local $arrayDistrict = $arrayMain[$siteIndex][$eArrayDistrictId]
	; Save DistrictId
	$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrict[$districtIndex - 1] ; - 1 phần tử Quận/huyện
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetWard"
	Local $data = "distId=" & $arrayDistrict[$districtIndex - 1]
	Local $urlGetArrayName = $url & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $url & "|" & $data & "|arrayid"
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $url, $data)
		Local $arrayName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Local $arrayId = StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf
	; Save
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadStreet_Dothi_Old($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadStreet_Dothi")
	; Không cần tìm lại District ID vì đã tìm ở Batdongsan_LoadWard
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetStreet"
	Local $data = "distId=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $url, $data)
		Local $arrayName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Local $arrayId = StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf
	; Save
	$arrayMain[$siteIndex][$eArrayStreetName] = $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Đường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadProject_Dothi_Old($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadProject_Dothi")
	; Không cần tìm lại District ID vì đã tìm ở Batdongsan_LoadWard
	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetProject"
	Local $data = "distId=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetResponseName = $url & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $url, $data)
		Local $arrayName = StringRegExp($rq, 'Text":"(.*?)"', 3)
		Local $arrayId = StringRegExp($rq, '"Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf
	; Save
	$arrayMain[$siteIndex][$eArrayProjectName] = $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] = $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Đường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc

Func Address_LoadDistrict_Thuecanho123($siteIndex,$cityName,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadDistrict_Thuecanho123")
	; Save City Name
	$arrayMain[$siteIndex][$eCityName] = $cityName
	; Save CityId
	$arrayMain[$siteIndex][$eCityId] = $THUECANHO123_ARRAY_CITY_ID[$cityIndex - 1] ; Save City Id
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
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Quận",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadWard_Thuecanho123($siteIndex,$districtName,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadWard_Thuecanho123")
	; Save District Name
	$arrayMain[$siteIndex][$eDistrictName] = $districtName
	; Get arrayDistrictId
	Local $arrayDistrict = $arrayMain[$siteIndex][$eArrayDistrictId]
	; Save DistrictId
	$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrict[$districtIndex - 1] ; - 1 phần tử Quận/huyện
	Local $data = "district=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetArrayName = $THUECANHO123_URL_GET_WARD & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $THUECANHO123_URL_GET_WARD & "|" & $data & "|arrayid"
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
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
		Local $arrayName = StringRegExp($decode,$THUECANHO123_REGEX_GET_NAME, 3)
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
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadStreet_Thuecanho123($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadStreet_Thuecanho123")
	; Không cần tìm lại District ID vì đã tìm ở Batdongsan_LoadWard
	Local $data = "district=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetResponseName = $THUECANHO123_URL_GET_STREET & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $THUECANHO123_URL_GET_STREET & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$THUECANHO123_URL_GET_STREET,$data)
		Local $decode = _HTMLDecode($rq)
		Local $arrayName = StringRegExp($decode,$THUECANHO123_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($decode,$THUECANHO123_REGEX_GET_ID, 3)
		Local $isSaved = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: " & $THUECANHO123_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; Save
	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Đường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSaved,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadProject_Thuecanho123($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadProject_Thuecanho123")
	; Không cần tìm lại District ID vì đã tìm ở Batdongsan_LoadWard
	Local $data = '{"province":' & $arrayMain[$siteIndex][$eCityId] & ',"district":' & $arrayMain[$siteIndex][$eDistrictId] & '}'
	Local $urlGetResponseName = $THUECANHO123_URL_GET_PROJECT & "|" & $data & "|arrayname"
	Local $urlGetResponseId = $THUECANHO123_URL_GET_PROJECT & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)
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
			ErrorShow($CONSOLE_ERROR,"","Gặp lỗi khi tải danh sách dự án từ trang " & $THUECANHO123_URL & " #1")
			Return SetError(1)
		EndIf
		Local $filter_ProjectName = $jsonProject.filter('$.data[*].title')
		Local $filter_ProjectId = $jsonProject.filter('$.data[*].id')
		Local $arrayName = _HttpRequest_ParseJSON($filter_ProjectName)
		Local $arrayId = _HttpRequest_ParseJSON($filter_ProjectId)
		Local $isSaved = False
	EndIf
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: " & $THUECANHO123_URL & " #" & @error)
		Return SetError(@error)
	EndIf
	; Save
	$arrayMain[$siteIndex][$eArrayProjectName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] 	= $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Dự án",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSaved,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc

Func Address_LoadDistrict_Homedy($siteIndex,$cityName,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadDistrict_Homedy")
	; Save City Name
	$arrayMain[$siteIndex][$eCityName] = $cityName
	; Save CityId
	Local $cityId = $HOMEDY_ARRAY_CITY_ID[$cityIndex - 1] ; Save City Id
	$arrayMain[$siteIndex][$eCityId] = $cityId
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
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Quận",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadWard_Homedy($siteIndex,$districtName,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadWard_Homedy")
	; Save District Name
	$arrayMain[$siteIndex][$eDistrictName] = $districtName
	; Get arrayDistrictId
	Local $arrayDistrict = $arrayMain[$siteIndex][$eArrayDistrictId]
	; Save DistrictId
	Local $districtId = $arrayDistrict[$districtIndex - 1] ; - 1 phần tử Quận/huyện
	$arrayMain[$siteIndex][$eDistrictId] = $districtId
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
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc
Func Address_LoadStreet_Homedy($siteIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Load Address.au3")
	Write_Log("+ Address_LoadStreet_Homedy")
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
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
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Đường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc

Func Address_LoadDistrict_Chotot($siteIndex,$cityName,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ Address_LoadDistrict_Chotot")
	; Save City Name
	$arrayMain[$siteIndex][$eCityName] 	= $cityName
	; Save CityId
	$arrayMain[$siteIndex][$eCityId] 	= $CHOTOT_ARRAY_CITY_ID[$cityIndex - 1] ; Save City Id

	; Tìm arrayDistrict
	Local $jsonDistrict = $CHOTOT_JSON_DATA_ADDRESS.filter('$.regions.[?(@.name == "' & $cityName & '")].area').toStr()
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: Chotot.com #" & @error)
		Return SetError(@error)
	EndIf
	Local $arrayName 	= StringRegExp($jsonDistrict,'"\d+":"(.*?)"',3)
	Local $arrayId 		= StringRegExp($jsonDistrict,'{"(.*?)"',3)
	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: Chotot.com #" & @error)
		Return SetError(@error)
	EndIf

	; Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] 	= $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Quận",$arrayName)
	Return $arrayName
EndFunc
Func Address_LoadWard_Chotot($siteIndex,$districtName,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ Address_LoadWard_Chotot")
	; Lưu districtName
	$arrayMain[$siteIndex][$eDistrictName] = $districtName
	Local $arrayDistrictId = $arrayMain[$siteIndex][$eArrayDistrictId]
	; Lưu districtId từ vị trí đã có
	$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrictId[$districtIndex - 1]
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Chotot_UrlGetWard($districtId)
	Local $urlGetResponseName = $url & "|arrayname"
	Local $urlGetResponseId = $url & "|arrayid"
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $loadArrayName = LoadResponse($urlGetResponseName)
	Local $loadArrayId = LoadResponse($urlGetResponseId)

	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName 	= StringSplit($loadArrayName,"|",2)
		Local $arrayId 		= StringSplit($loadArrayId,"|",2)
		Local $isSaved 		= True
	Else
		Local $rq = _HttpRequest(2, $url)
		Local $arrayName 	= StringRegExp($rq,'name":"(.*?)"', 3)
		Local $arrayId 		= StringRegExp($rq,'id":(.*?)}', 3)
		Local $isSaved 		= False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo lỗi","Gặp lỗi khi tải danh sách Phường từ web: Chotot.com #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetResponseName	,$arrayName)
	checkSaveResponse($isSaved,$urlGetResponseId		,$arrayId)
	Return $arrayName
EndFunc

