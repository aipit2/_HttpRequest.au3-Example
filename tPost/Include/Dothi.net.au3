Func Address_LoadMain_Dothi($siteIndex,$functionName,$nameGet,$indexGet,$indexSave)
	Switch $functionName
		Case "Quận"
			Local $cityId = $__g_a_CityId[$indexGet - 1] ; -1 phần tử Tỉnh/thành phố
			$arrayMain[$siteIndex][$eCityName] = $nameGet
			$arrayMain[$siteIndex][$eCityId] = $cityId
			Local $url = Dothi_UrlGetDistrict($cityId)
		Case "Phường"
			; Lưu DistrictName
			$arrayMain[$siteIndex][$eDistrictName] = $nameGet
			Write_Log("$nameGet: " & $nameGet)
			; Load ArrayDistrictId
			Local $arrayDistrictId = $arrayMain[$siteIndex][$eArrayDistrictId]
			; Lưu DistrictId
			Local $districtIndex = $indexGet
			$arrayMain[$siteIndex][$eDistrictId] = $arrayDistrictId[$districtIndex - 1] ; - 1 phần tử Quận/huyện
			Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
			Local $arrayUrl = Dothi_UrlGetWard($districtId)
		Case "Đường"
			Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
			Local $arrayUrl = Dothi_UrlGetStreet($districtId)
		Case "Dự án"
			Local $districtId = $arrayMain[$siteIndex][$eDistrictId]
			Local $arrayUrl = Dothi_UrlGetProject($districtId)
	EndSwitch

	Local $urlGetArrayName = $arrayUrl[0] & "|" & $arrayUrl[1] & "|arrayname"
	Local $urlGetArrayId = $arrayUrl[0] & "|" & $arrayUrl[1] & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then
		Write_Log("> Đã tìm thấy Reg")
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Write_Log("Không tìm thấy Reg")
		Local $rq = _HttpRequest(2, $url[0], $url[1])
		Local $arrayName = StringRegExp($rq, $DOTHI_REGEX_GET_NAME, 3)
		Local $arrayId = StringRegExp($rq, $DOTHI_REGEX_GET_ID, 3)
		Local $isSave = False
	EndIf

	; Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách "&$functionName&" từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$indexSave] 		= $arrayName
	$arrayMain[$siteIndex][$indexSave + 2] 	= $arrayId ; +2 để lưu Mảng ID

	; Hiển thị mảng tìm được lên GUI
	Address_ShowAddress($functionName,$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	Return $arrayName
EndFunc
Func Dothi_UrlGetDistrict($cityId)
	Local $array = ['https://dothi.net/Handler/SearchHandler.ashx?module=GetDistrict', "cityCode=" & $cityId]
	Return $array
EndFunc
Func Dothi_UrlGetWard($districtId)
	Local $array = ['https://dothi.net/Handler/SearchHandler.ashx?module=GetWard', "distId=" & $districtId]
	Return $array
EndFunc
Func Dothi_UrlGetStreet($districtId)
	Local $array = ['https://dothi.net/Handler/SearchHandler.ashx?module=GetStreet', "distId=" & $districtId]
	Return $array
EndFunc
Func Dothi_UrlGetProject($districtId)
	Local $array = ['https://dothi.net/Handler/SearchHandler.ashx?module=GetProject', "distId=" & $districtId]
	Return $array
EndFunc

Func Address_LoadDistrict_Dothi($siteIndex,$citySearch,$cityIndex)
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
Func Address_LoadWard_Dothi($siteIndex,$districtName,$districtIndex)
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
Func Address_LoadStreet_Dothi($siteIndex)
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
Func Address_LoadProject_Dothi($siteIndex)
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
	Address_ShowAddress("Dự án",$arrayName)
	; Nếu response chưa lưu trong reg thì lưu lại
	checkSaveResponse($isSave,$urlGetResponseName,$arrayName)
	checkSaveResponse($isSave,$urlGetResponseId,$arrayId)
	Return $arrayName
EndFunc

Func Address_SearchCity_Dothi($siteIndex,$citySearch,$cityIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchCity_Dothi")
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
Func Address_SearchDistrict_Dothi($siteIndex,$districtSearch,$districtIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchDistrict_Dothi")

	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetDistrict"
	Local $data = "cityCode=" & $arrayMain[$siteIndex][$eCityId]
	Local $urlGetArrayName = $url & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName = StringSplit($loadArrayName,"|",2)
		Local $arrayId = StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else ; Chưa tìm thấy reg
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

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $data & "|" & $districtSearch & "|name"
	Local $urlGetResultId = $url & "|" & $data & "|" & $districtSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Quận từ trang Dothi.net\n\nXin vui lòng thử lại")
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
Func Address_SearchWard_Dothi($siteIndex,$wardSearch,$wardIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchWard_Dothi")
	Switch $wardSearch
		Case "", "Phường/xã"
			$arrayMain[$siteIndex][$eWardName] = ""
			$arrayMain[$siteIndex][$eWardId] = ""
			Return SetError(1)
	EndSwitch

	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetWard"
	Local $data = "distId=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetArrayName = $url & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
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
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Phường từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayWardName] = $arrayName
	$arrayMain[$siteIndex][$eArrayWardId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $data & "|" & $wardSearch & "|name"
	Local $urlGetResultId = $url & "|" & $data & "|" & $wardSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Phường từ trang Dothi.net\n\nXin vui lòng thử lại")
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
Func Address_SearchStreet_Dothi($siteIndex,$streetSearch,$streetIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchStreet_Dothi")

	Switch $streetSearch
		Case "", "Đường"
			$arrayMain[$siteIndex][$eStreetName] = ""
			$arrayMain[$siteIndex][$eStreetId] = ""
			Return SetError(1)
	EndSwitch

	Local $url = "https://dothi.net/Handler/SearchHandler.ashx?module=GetStreet"
	Local $data = "distId=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetArrayName = $url & "|" & $data & "|arrayname"
	Local $urlGetArrayId = $url & "|" & $data & "|arrayid"
	Local $loadArrayName = LoadResponse($urlGetArrayName)
	Local $loadArrayId = LoadResponse($urlGetArrayId)
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
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Đường từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayStreetName] = $arrayName
	$arrayMain[$siteIndex][$eArrayStreetId] = $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $data & "|" & $streetSearch & "|name"
	Local $urlGetResultId = $url & "|" & $data & "|" & $streetSearch & "|id"
	Local $loadName = LoadResponse($urlGetResultName)
	Local $loadId = LoadResponse($urlGetResultId)

	; Nếu đã lưu rồi thì lấy ra xài thôi
	If $loadName <> "" And $loadId <> "" Then
		Write_Log("> Đã tìm thấy result trong Reg")
		$arrayMain[$siteIndex][$eStreetName] 	= $loadName
		$arrayMain[$siteIndex][$eStreetId] 	= $loadId
		Local $saveResult = True
	Else
		; So sánh xem quận đang tìm giống với quận nào trong danh sách quận đã lấy được
		Local $index = Compare2($streetSearch, $arrayName, 0)
		If @error Then
			ErrorShow(16,"","Gặp lỗi khi so sánh Đường từ trang Dothi.net\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eStreetName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eStreetId] 		= $arrayId[$index]
		Local $saveResult = False
		Write_Log("Street tìm thấy: " & $arrayName[$index])
		Write_Log("Street tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eStreetName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eStreetId])
	Return $arrayMain[$siteIndex][$eStreetName]
EndFunc
Func Address_SearchProject_Dothi($siteIndex,$projectSearch,$projectIndex)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab4/Search Address.au3")
	Write_Log("+ Address_SearchProject_Dothi")

	Switch $projectSearch
		Case "", "Dự án"
			$arrayMain[$siteIndex][$eProjectName] = ""
			$arrayMain[$siteIndex][$eProjectId] = ""
			Return SetError(1)
	EndSwitch

	Local $url 	= "https://dothi.net/Handler/SearchHandler.ashx?module=GetProject"
	Local $data = "distId=" & $arrayMain[$siteIndex][$eDistrictId]
	Local $urlGetArrayName 	= $url & "|" & $data & "|arrayname"
	Local $urlGetArrayId 	= $url & "|" & $data & "|arrayid"
	Local $loadArrayName 	= LoadResponse($urlGetArrayName)
	Local $loadArrayId 		= LoadResponse($urlGetArrayId)
	If $loadArrayName <> "" And $loadArrayId <> "" Then ; Đã tìm thấy response
		Local $arrayName 	= StringSplit($loadArrayName,"|",2)
		Local $arrayId 		= StringSplit($loadArrayId,"|",2)
		Local $isSave = True
	Else
		Local $rq = _HttpRequest(2, $url, $data)
		Local $arrayName 	= StringRegExp($rq, 'Text":"(.*?)"', 3)
		Local $arrayId 		= StringRegExp($rq, 'Id":"(.*?)"', 3)
		Local $isSave = False
	EndIf

	; B3: Kiểm tra mảng Name và ID có phù hợp không
	Local $checkArray = Address_CheckArray($arrayName,$arrayId)
	If @error Then
		ErrorShow(16,"Thông báo","Gặp lỗi khi tải danh sách Dự án từ web: Dothi.net #" & @error)
		Return SetError(@error)
	EndIf

	; B4: Lưu mảng tên và ID
	$arrayMain[$siteIndex][$eArrayProjectName] 	= $arrayName
	$arrayMain[$siteIndex][$eArrayProjectId] 	= $arrayId

	; Tìm trong Regedit xem có lưu kết quả tìm kiếm chưa?
	Local $urlGetResultName = $url & "|" & $data & "|" & $projectSearch & "|name"
	Local $urlGetResultId 	= $url & "|" & $data & "|" & $projectSearch & "|id"
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
			ErrorShow(16,"","Gặp lỗi khi so sánh Dự án từ trang Dothi.net\n\nXin vui lòng thử lại")
			Return SetError(4)
		EndIf
		; Lưu vị trí tên và ID quận đã tìm thấy
		$arrayMain[$siteIndex][$eProjectName] 	= $arrayName[$index]
		$arrayMain[$siteIndex][$eProjectId] 		= $arrayId[$index]
		Local $saveResult = False
		Write_Log("ProjectName tìm thấy: " & $arrayName[$index])
		Write_Log("ProjectId tìm thấy: " & $arrayId[$index])
	EndIf
	checkSaveResponse($isSave,$urlGetArrayName,$arrayName)
	checkSaveResponse($isSave,$urlGetArrayId,$arrayId)
	checkSaveResponse($saveResult,$urlGetResultName,$arrayMain[$siteIndex][$eProjectName])
	checkSaveResponse($saveResult,$urlGetResultId,$arrayMain[$siteIndex][$eProjectId])
	Return $arrayMain[$siteIndex][$eProjectName]
EndFunc