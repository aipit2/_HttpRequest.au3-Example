; #FUNCTION# ====================================================================================================================
; Name ..........: Address_LoadMain_Bds
; Description ...:
; Syntax ........: Address_LoadMain_Bds($siteIndex, $functionName, $nameGet, $indexGet, $indexSave)
; Parameters ....: $siteIndex           - index trang trong mảng chính.
;                  $functionName        - Quận, Phường, Đường, Dự án
;                  $nameGet             - Tên Thành phố hoặc Quận muốn lấy dữ liệu.
;                  $indexGet            - index của tên trong combobox địa chỉ.
;                  $indexSave           - index muốn lưu $eDistrictName, $eWardName, $eStreetName, $eProject.
; Return values .: $arrayName - Mảng tên đã tìm thấy được
; ===============================================================================================================================
Func Address_LoadMain_Bds($siteIndex,$functionName,$nameGet,$indexGet,$indexSave)
	Switch $functionName
		Case "Quận"
			Local $cityId = $__g_a_CityId[$indexGet - 1] ; -1 phần tử Tỉnh/thành phố
			$arrayMain[$siteIndex][$eCityName] = $nameGet
			$arrayMain[$siteIndex][$eCityId] = $cityId
			Local $url = Bds_UrlGetDistrict($cityId)
		Case "Phường"
			$arrayMain[$siteIndex][$eDistrictName] = $nameGet
			Local $arrayDistrictId = $arrayMain[$siteIndex][$eArrayDistrictId]
			$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrictId[$indexGet - 1] ; - 1 phần tử Quận/huyện
			Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
			Local $url = Bds_UrlGetWard($districtId)
		Case "Đường"
			Local $cityId = $arrayMain[$siteIndex][$eCityId]
			Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
			Local $url = Bds_UrlGetStreet($cityId,$districtId)
		Case "Dự án"
			Local $cityId = $arrayMain[$siteIndex][$eCityId]
			Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
			Local $url = Bds_UrlGetProject($cityId,$districtId)
	EndSwitch
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	; Kiểm tra xem request đã được lưu chưa thì lấy ra xài liền
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url,'','','',$BDS_HEADER_GET_ADDRESS)
		Local $arrayName = StringRegExp($rq, $BDS_REGEX_GET_Name, 3)
		Local $arrayId = StringRegExp($rq, $BDS_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách "&$functionName&" từ web: Batdongsan.com.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$indexSave] = $arrayName
	$arrayMain[$siteIndex][$indexSave + 2] = $arrayId ; +2 để lưu mảng ID
	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress($functionName,$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc

Func Address_SearchCity_Bds($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchCity_Bds")
	; Lưu tên thành phố đã lựa chọn
	$arrayMain[$siteIndex][$eCityName] = $citySearch
	; Tìm ID thành phố từ index thành phố trong combobox
	Local $idCity = $__g_a_CityId[$cityIndex - 1] ; -1 phần tử Tỉnh/thành phố
	; Lưu ID thành phố đã tìm được
	$arrayMain[$siteIndex][$eCityId] = $idCity
	Write_Log("Tên cần tìm: " & $citySearch)
	Write_Log("ID tìm thấy: " & $idCity)
	Return $idCity
EndFunc
Func Address_SearchDistrict_Bds($siteIndex,$districtSearch)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchDistrict_Bds")
	Local $url = Bds_UrlGetDistrict($arrayMain[$siteIndex][$eCityId])
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else ; Chưa tìm thấy reg
		Local $rq = _HttpRequest(2, $url,'','','',$BDS_HEADER_GET_ADDRESS)
		Local $arrayName = StringRegExp($rq, $BDS_REGEX_GET_Name, 3)
		Local $arrayId = StringRegExp($rq, $BDS_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Quận từ web: Batdongsan.com.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayDistrictName] = $arrayName
	$arrayMain[$siteIndex][$eArrayDistrictId] = $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $districtSearch & "|name"
	Local $urlGetResultId = $url & "|" & $districtSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Quận từ trang Batdongsan.com.vn\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eDistrictName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eDistrictId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("DistrictName tìm thấy: " & $arrayName[$index])
		Write_Log("DistrictId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eDistrictName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eDistrictId])
	Return $arrayMain[$siteIndex][$eDistrictName]
EndFunc
Func Address_SearchWard_Bds($siteIndex,$wardSearch,$wardIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchWard_Bds")
	Switch $wardSearch
		Case "", "Phường/xã"
			$arrayMain[$siteIndex][$eWardName] = ""
			$arrayMain[$siteIndex][$eWardId] = ""
			Return SetError(1)
	EndSwitch
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Bds_UrlGetWard($districtId)
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else ; Chưa tìm thấy reg
		Local $rq = _HttpRequest(2, $url,'','','',$BDS_HEADER_GET_ADDRESS)
		Local $arrayName = StringRegExp($rq, $BDS_REGEX_GET_Name, 3)
		Local $arrayId = StringRegExp($rq, $BDS_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: Batdongsan.com.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $wardSearch & "|name"
	Local $urlGetResultId 	= $url & "|" & $wardSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang Batdongsan.com.vn\n\nXin vui lòng thử lại")
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
Func Address_SearchStreet_Bds($siteIndex,$streetSearch,$streetIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchStreet_Bds")
	Switch $streetSearch
		Case "", "Đường"
			$arrayMain[$siteIndex][$eStreetName] = ""
			$arrayMain[$siteIndex][$eStreetId] = ""
			Return SetError(1)
	EndSwitch
	Local $cityId = $arrayMain[$siteIndex][$eCityId]
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Bds_UrlGetStreet($cityId,$districtId)
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else ; Chưa tìm thấy reg
		Local $rq = _HttpRequest(2, $url,'','','',$BDS_HEADER_GET_ADDRESS)
		Local $arrayName = StringRegExp($rq, $BDS_REGEX_GET_Name, 3)
		Local $arrayId = StringRegExp($rq, $BDS_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: Batdongsan.com.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] 	= $arrayId

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
			ErrorShow(16,"","Gặp lỗi khi so sánh Đường từ trang Batdongsan.com.vn\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
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
Func Address_SearchProject_Bds($siteIndex,$projectSearch,$projectIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchProject_Bds")
	Switch $projectSearch
		Case "", "Dự án"
			$arrayMain[$siteIndex][$eProjectName] = ""
			$arrayMain[$siteIndex][$eProjectId] = ""
			Return SetError(1)
	EndSwitch
	Local $cityId = $arrayMain[$siteIndex][$eCityId]
	Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
	Local $url = Bds_UrlGetProject($cityId,$districtId)
	Local $urlGetArrayName = $url & "|arrayname"
	Local $urlGetArrayId = $url & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else ; Chưa tìm thấy reg
		Local $rq = _HttpRequest(2, $url,'','','',$BDS_HEADER_GET_ADDRESS)
		Local $arrayName = StringRegExp($rq, $BDS_REGEX_GET_Name, 3)
		Local $arrayId = StringRegExp($rq, $BDS_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Batdongsan.com.vn #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayProjectName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $projectSearch & "|name"
	Local $urlGetResultId 	= $url & "|" & $projectSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Dự án từ trang Batdongsan.com.vn\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eProjectName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eProjectId] 	= $arrayId[$index]
		Local $saveResult = False
		Write_Log("ProjectName tìm thấy: " 	& $arrayName[$index])
		Write_Log("ProjectId tìm thấy: " 	& $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eProjectName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eProjectId])
	Return $arrayMain[$siteIndex][$eProjectName]
EndFunc

Func Bds_UrlGetDistrict($cityId)
	Return "https://sellernetapi.batdongsan.com.vn/api/common/fetchDistrictList?cityCode=" & $cityId
EndFunc
Func Bds_UrlGetWard($districtId)
	Return "https://sellernetapi.batdongsan.com.vn/api/common/fetchWardList?districtId=" & $districtId
EndFunc
Func Bds_UrlGetStreet($cityId,$districtId)
	Return "https://sellernetapi.batdongsan.com.vn/api/common/fetchStreetList?cityCode="& $cityId &"&districtId=" & $districtId
EndFunc
Func Bds_UrlGetProject($cityId,$districtId)
	Return "https://sellernetapi.batdongsan.com.vn/api/project/fetchProjectList?cityCode=" & $cityId & "&districtId=" & $districtId
EndFunc


