Func Chotot_UrlGetWard($districtId)
	Return "https://gateway.chotot.com/v2/public/chapy-pro/wards?area=" & $districtId
EndFunc
Func Chotot_UrlGetProject($projectSearch)
	Return "https://gateway.chotot.com/v1/public/api-pty/project?project_name="&$projectSearch&"&status=active&limit=20"
EndFunc

Func Address_SearchCity_Chotot($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ Address_SearchCity_Chotot")
	; Lưu tên thành phố đã lựa chọn
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	; Tìm ID thành phố từ index thành phố trong combobox
	Local $idCity = $CHOTOT_ARRAY_CITY_ID[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Lưu ID thành phố đã tìm được
	$arrayMain[$siteIndex][$eCityId] = $idCity
	Write_Log("Tìm ID thành phố")
	Write_Log("Tên cần tìm: " & $citySearch)
	Write_Log("ID tìm thấy: " & $idCity)
	Return $idCity
EndFunc
Func Address_SearchDistrict_Chotot($siteIndex,$districtSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchDistrict_Chotot")
	Local $index ; Vị trí tìm được trong mảng của Quận được tìm
	; Lấy ra cityId từ siteIndex
	Local $cityName 	= $arrayMain[$siteIndex][$eCityName]
	Local $jsonDistrict = $CHOTOT_JSON_DATA_ADDRESS.filter('$.regions.[?(@.name == "' & $cityName & '")].area').toStr()
	Local $arrayDistrictName 	= StringRegExp($jsonDistrict,'"\d+":"(.*?)"',3)
	Local $arrayDistrictId 		= StringRegExp($jsonDistrict,'{"(.*?)"',3)
	Local $checkArray = Address_CheckArray($arrayDistrictName,$arrayDistrictId)
	If @error Then
		Return SetError(@error)
	EndIf
	; Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayDistrictName
	$arrayMain[$siteIndex][$eArrayDistrictId] 	= $arrayDistrictId
	; Không thể lấy kết quả từ trước vì không có URL để lưu, vì vậy luôn phải so sánh lại
	Switch $districtSearch
		Case "Quận 2", "Quận 9"
			$index = _ArraySearch($arrayDistrictName, "Thành phố Thủ Đức")
		Case Else
			$index = Compare2($districtSearch, $arrayDistrictName, 0)
	EndSwitch
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
Func Address_SearchWard_Chotot($siteIndex,$wardSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchWard_Chotot")
	Switch $wardSearch
		Case "", "Phường/xã"
			$arrayMain[$siteIndex][$eWardName] 	= ""
			$arrayMain[$siteIndex][$eWardId] 	= ""
			Return SetError(1)
	EndSwitch

	Local $districtId 		= $arrayMain[$siteIndex][$eDistrictId]
	Local $urlLoadWard 		= Chotot_UrlGetWard($districtId)
	Local $urlGetArrayName 	= $urlLoadWard & "|arrayName"
	Local $urlGetArrayId 	= $urlLoadWard & "|arrayId"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName 	= StringSplit($loadArrayName,"|",2)
		Local $arrayId 		= StringSplit($loadArrayId,"|",2)
		Local $isSaved = True
	Else ; Chưa tìm thấy reg
		Local $rq = _HttpRequest(2, $urlLoadWard)
		Local $arrayName 	= StringRegExp($rq, 'name":"(.*?)"', 3)
		Local $arrayId 		= StringRegExp($rq, 'id":(.*?)}', 3)
		Local $isSaved = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: Chotot.com #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $urlLoadWard & "|" & $wardSearch & "|name"
	Local $urlGetResultId 	= $urlLoadWard & "|" & $wardSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId 	= LoadResponse($urlGetResultId)
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang Chotot.com\n\nXin vui lòng thử lại")
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
Func Address_SearchStreet_Chotot($siteIndex,$streetSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchStreet_Chotot")
	$arrayMain[$siteIndex][$eStreetName] = ""
	$arrayMain[$siteIndex][$eStreetId] = ""
EndFunc
Func Address_SearchProject_Chotot($siteIndex,$projectSearch)
	Write_Log("=====================")
	Write_Log("+ Address_SearchProject_Chotot")
	Switch $projectSearch
		Case "", "Dự án"
			$arrayMain[$siteIndex][$eProjectName] 	= ""
			$arrayMain[$siteIndex][$eProjectId] 	= ""
			Return SetError(1)
	EndSwitch
	Local $url = Chotot_UrlGetProject($projectSearch)
	Local $rq = LoadResponse($url)
	If $rq <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $isSaved = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2,$url)
		Local $isSaved = False
	EndIf

	Local $arrayProjectName = StringRegExp($rq,'project_name":"(.*?)"',3)
	Local $arrayProjectId = StringRegExp($rq,'"id":(.*?),"project_name"',3)
	Local $arrayStreetName = StringRegExp($rq,'street_name":"(.*?)"',3)
	Local $arrayStreetId = StringRegExp($rq,'street_id":(\d+)',3)

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayStreetName,$arrayStreetId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Chotot.com #" & @error)
		Return SetError(@error)
	EndIf

	Local $checkArray = Address_CheckArray($arrayProjectName,$arrayProjectId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Chotot.com #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayStreetName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayStreetId

	$arrayMain[$siteIndex][$eArrayProjectName] 	= $arrayProjectName
	$arrayMain[$siteIndex][$eArrayProjectId] 	= $arrayProjectId

	$arrayMain[$siteIndex][$eStreetName] 	= $arrayStreetName	[0]
	$arrayMain[$siteIndex][$eStreetId] 		= $arrayStreetId	[0]
	$arrayMain[$siteIndex][$eProjectName] 	= $arrayProjectName	[0]
	$arrayMain[$siteIndex][$eProjectId] 	= $arrayProjectId	[0]
	checkSaveResponse($isSaved,$url,$rq)
	Return True
EndFunc

