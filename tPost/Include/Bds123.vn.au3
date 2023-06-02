Func Bds123_LoadAddress_Main($functionName,$siteIndex,$nameGet,$indexGet,$indexSave)
	Write_Log("=====================")
	Write_Log("+ Bds123_LoadAddress_Main")
	Switch $functionName
		Case "Quận"
			Local $cityId = $BDS123_ARRAY_CITY_ID[$indexGet - 1] ; -1 phần tử Tỉnh/thành phố
			$arrayMain[$siteIndex][$eCityName] 	= $nameGet
			$arrayMain[$siteIndex][$eCityId] 	= $cityId
			Local $urlAndData = Bds123_UrlGetDistrict($cityId)
		Case "Dự án"
			Local $cityId 		= $arrayMain[$siteIndex][$eCityId]
			Local $districtId 	= $arrayMain[$siteIndex][$eDistrictId]
			Local $urlAndData 	= Bds123_UrlGetProject($cityId,$districtId)
	EndSwitch
	Local $urlGetArrayName = $urlAndData[0] & "|" & $urlAndData[1] & "|arrayname"
	Local $urlGetArrayId = $urlAndData[0] & "|" & $urlAndData[1] & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId 	= LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $urlAndData[0],$urlAndData[1])
		Local $jsonData = _HttpRequest_ParseJSON($rq)
		Local $filterName, $filterId
		Switch $functionName
			Case "Quận"
				$filterName = $jsonData.filter('$.districts[*].name')
				$filterId 	= $jsonData.filter('$.districts[*].id')
			Case "Dự án"
				$filterName = $jsonData.filter('$.data[*].title')
				$filterId 	= $jsonData.filter('$.data[*].id')
		EndSwitch
		; Convert Json To Array
		Local $arrayName = _HttpRequest_ParseJSON($filterName)
		Local $arrayId = _HttpRequest_ParseJSON($filterId)
		Local $isSaved = False
	EndIf

	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách "&$functionName&" từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$indexSave] 		= $arrayName
	$arrayMain[$siteIndex][$indexSave + 2] 	= $arrayId ; +2 để lưu Mảng ID

	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress($functionName,$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSaved,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc

Func Bds123_LoadWardAndStreet($siteIndex,$districtName,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ Bds123_LoadWardAndStreet")
	; Lưu districtName
	$arrayMain[$siteIndex][$eDistrictName] = $districtName
	Local $arrayDistrictId = $arrayMain[$siteIndex][$eArrayDistrictId]
	; Lưu districtName
	$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrictId[$districtIndex - 1] ; - 1 phần tử Quận/huyện
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $urlAndData = Bds123_UrlGetWardAndStreet($districtId)
	Local $url = $urlAndData[0]
	Local $rq = LoadResponse($url)
	If $rq <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $urlAndData[0],$urlAndData[1])
		Local $jsonData = _HttpRequest_ParseJSON($rq)
		Local $filterWardName 	= $jsonData.filter('$.wards[*].name')
		Local $filterWardId 	= $jsonData.filter('$.wards[*].id')
		Local $filterStreetName = $jsonData.filter('$.streets[*].name')
		Local $filterStreetId 	= $jsonData.filter('$.streets[*].id')
		; Convert Json To Array
		Local $arrayWardName 	= _HttpRequest_ParseJSON($filterWardName)
		Local $arrayWardId 		= _HttpRequest_ParseJSON($filterWardId)
		Local $arrayStreetName 	= _HttpRequest_ParseJSON($filterStreetName)
		Local $arrayStreetId 	= _HttpRequest_ParseJSON($filterStreetId)
		Local $isSaved = False
	EndIf

	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArrayWard = Address_CheckArray($arrayWardName,$arrayWardId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường/xã từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	Local $checkArrayStreet = Address_CheckArray($arrayStreetName,$arrayStreetId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayWardName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayWardId

	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayStreetName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayStreetId

	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress("Phường",$arrayWardName)
	Address_ShowAddress("Đường"	,$arrayStreetName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSaved,$url,$rq)
	Return True
EndFunc

Func Bds123_UrlGetDistrict($cityId)
	Local $array = ['https://bds123.vn/api/get/districts?province=' & $cityId, '']
	Return $array
EndFunc
Func Bds123_UrlGetWardAndStreet($districtId)
	Local $array = ['https://bds123.vn/api/get/street_ward?district=' & $districtId, '']
	Return $array
EndFunc
Func Bds123_UrlGetProject($cityId,$districtId)
	Local $array = ['https://bds123.vn/api/get/projects', '{"province":' & $cityId & ',"district":' & $districtId & '}']
	Return $array
EndFunc

Func Address_SearchCity_Bds123($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ Address_SearchCity_Bds123")
	; Lưu tên thành phố đã lựa chọn
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	; Tìm ID thành phố từ index thành phố trong combobox
	Local $idCity = $BDS123_ARRAY_CITY_ID[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Lưu ID thành phố đã tìm được
	$arrayMain[$siteIndex][$eCityId] = $idCity
	Write_Log("Tên cần tìm: " & $citySearch)
	Write_Log("ID tìm thấy: " & $idCity)
	Return $idCity
EndFunc
Func Address_SearchDistrict_Bds123($siteIndex,$districtSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchDistrict_Bds123")

	Local $urlAndData = Bds123_UrlGetDistrict($arrayMain[$siteIndex][$eCityId])
	Local $urlGetArrayName = $urlAndData[0] & "|" & $urlAndData[1] & "|arrayname"
	Local $urlGetArrayId = $urlAndData[0] & "|" & $urlAndData[1] & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else ; Chưa tìm thấy reg
		Local $rq = _HttpRequest(2, $urlAndData[0])
		Local $jsonData = _HttpRequest_ParseJSON($rq)
		Local $filterName 	= $jsonData.filter('$.districts[*].name')
		Local $filterId 	= $jsonData.filter('$.districts[*].id')
		Local $arrayName = _HttpRequest_ParseJSON($filterName)
		Local $arrayId = _HttpRequest_ParseJSON($filterId)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $urlAndData[0] & "|" & $urlAndData[1] & "|" & $districtSearch & "|name"
	Local $urlGetResultId 	= $urlAndData[0] & "|" & $urlAndData[1] & "|" & $districtSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId 	= LoadResponse($urlGetResultId)

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
			ErrorShow(16,"","Gặp lỗi khi so sánh Quận từ trang Bds123.vn\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eDistrictName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eDistrictId] 	= $arrayId[$index]
		Local $saveResult = False
	EndIf
	Write_Log("DistrictName tìm thấy: " & $arrayMain[$siteIndex][$eDistrictName])
	Write_Log("DistrictId tìm thấy: " & $arrayMain[$siteIndex][$eDistrictId])

	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eDistrictName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eDistrictId])
	Return $arrayMain[$siteIndex][$eDistrictName]
EndFunc
Func Address_SearchWard_Bds123($siteIndex,$wardSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchWard_Bds123")
	Switch $wardSearch
		Case "", "Phường/xã"
			$arrayMain[$siteIndex][$eWardName] 	= ""
			$arrayMain[$siteIndex][$eWardId] 	= ""
			Return SetError(1)
	EndSwitch
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $urlAndData = Bds123_UrlGetWardAndStreet($districtId)
	Local $urlGetArrayName 	= $urlAndData[0] & "|arrayWardName"
	Local $urlGetArrayId 	= $urlAndData[0] & "|arrayWardId"
	Local $loadArrayName 	= LoadResponse($urlGetArrayName)
	Local $loadArrayId 		= LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $urlAndData[0])
		Local $jsonWards = _HttpRequest_ParseJSON($rq)
		Local $filterWardName 	= $jsonWards.filter('$.wards[*].name')
		Local $filterWardId 	= $jsonWards.filter('$.wards[*].id')
		Local $arrayName 	= _HttpRequest_ParseJSON($filterWardName)
		Local $arrayId 		= _HttpRequest_ParseJSON($filterWardId)
		Local $isSave = False
	EndIf

	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArrayWard = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường/xã từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $urlAndData[0] & "|" & $wardSearch & "|name"
	Local $urlGetResultId 	= $urlAndData[0] & "|" & $wardSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang Bds123.vn\n\nXin vui lòng thử lại")
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
Func Address_SearchStreet_Bds123($siteIndex,$streetSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchStreet_Bds123")
	Switch $streetSearch
		Case "", "Đường"
			$arrayMain[$siteIndex][$eStreetName] = ""
			$arrayMain[$siteIndex][$eStreetId] = ""
			Return SetError(1)
	EndSwitch

	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $urlAndData = Bds123_UrlGetWardAndStreet($districtId)
	Local $urlGetArrayName 	= $urlAndData[0] & "|arrayStreetname"
	Local $urlGetArrayId 	= $urlAndData[0] & "|arrayStreetid"
	Local $loadArrayName 	= LoadResponse($urlGetArrayName)
	Local $loadArrayId 		= LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $urlAndData[0])
		Local $jsonStreets = _HttpRequest_ParseJSON($rq)
		Local $filterStreetName = $jsonStreets.filter('$.streets[*].name')
		Local $filterStreetId 	= $jsonStreets.filter('$.streets[*].id')
		Local $arrayName 	= _HttpRequest_ParseJSON($filterStreetName)
		Local $arrayId 		= _HttpRequest_ParseJSON($filterStreetId)
		Local $isSave = False
	EndIf

	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArrayStreet = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường/xã từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $urlAndData[0] & "|" & $streetSearch & "|name"
	Local $urlGetResultId 	= $urlAndData[0] & "|" & $streetSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang Bds123.vn\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID đã tìm thấy
		$arrayMain[$siteIndex][$eStreetName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eStreetId] 		= $arrayId[$index]
		Local $saveResult = False
		Write_Log("StreetName tìm thấy: " & $arrayName[$index])
		Write_Log("StreetId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eStreetName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eStreetId])
	Return $arrayMain[$siteIndex][$eStreetName]
EndFunc
Func Address_SearchProject_Bds123($siteIndex,$projectSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchProject_Bds123")
	Switch $projectSearch
		Case "", "Dự án"
			$arrayMain[$siteIndex][$eProjectName] = ""
			$arrayMain[$siteIndex][$eProjectId] = ""
			Return SetError(1)
	EndSwitch
	Local $cityId 		= $arrayMain[$siteIndex][$eCityId]
	Local $districtId 	= $arrayMain[$siteIndex][$eDistrictId]
	Local $urlAndData 	= Bds123_UrlGetProject($cityId,$districtId)
	Local $urlGetArrayName 	= $urlAndData[0] & "|" & $urlAndData[1] & "|arrayname"
	Local $urlGetArrayId 	= $urlAndData[0] & "|" & $urlAndData[1] & "|arrayid"
	Local $loadArrayName 	= LoadResponse($urlGetArrayName)
	Local $loadArrayId 		= LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName 	= StringSplit($loadArrayName,"|",2)
		Local $arrayId 		= StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $urlAndData[0], $urlAndData[1])
		Local $jsonProject 	= _HttpRequest_ParseJSON($rq)
		Local $filterName 	= $jsonProject.filter('$.data[*].title')
		Local $filterId 	= $jsonProject.filter('$.data[*].id')
		Local $arrayName	= _HttpRequest_ParseJSON($filterName)
		Local $arrayId		= _HttpRequest_ParseJSON($filterId)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Bds123.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayProjectName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $urlAndData[0] & "|" & $urlAndData[1] & "|" & $projectSearch & "|name"
	Local $urlGetResultId 	= $urlAndData[0] & "|" & $urlAndData[1] & "|" & $projectSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId 	= LoadResponse($urlGetResultId)

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
			ErrorShow(16,"","Gặp lỗi khi so sánh Dự án từ trang Bds123.vn\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eProjectName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eProjectId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("ProjectName tìm thấy: " & $arrayName[$index])
		Write_Log("ProjectId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName	,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId	,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName	,$arrayMain[$siteIndex][$eProjectName])
	checkSaveResponse($saveResult,$urlGetResultId	,$arrayMain[$siteIndex][$eProjectId])
	Return $arrayMain[$siteIndex][$eProjectName]
EndFunc
