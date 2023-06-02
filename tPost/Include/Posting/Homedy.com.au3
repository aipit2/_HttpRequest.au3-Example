Func Homdy_Posting_Main($data)
	Global $jsonData = _HttpRequest_ParseJSON($data)
	Global $CURRENT_STEP = 1
	Global $CURRENT_POST_NAME = $jsonData.postName
	Global $jsonPosting = $HOMEDY_JSON_DATA_POSTING
	Local $isLogin = AccountSetting_Homdy_Login()
	If @error Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Đăng nhập thất bại")')
		$CURRENT_STEP += 1
		Return SetError(1)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"Đăng nhập thành công")
		$CURRENT_STEP += 1
	EndIf

	; Upload
	Local $arrayImage = StringSplit($jsonData.image,"|",2)
	Homedy_Upload($arrayImage)
	; Thêm thắt các thứ
	$jsonPosting.ProjectId 	= $jsonData.projectID
	$jsonPosting.CategoryId = $HOMEDY_ARRAY_ESTATE_ID[$jsonData.estateTypeIndex]
	$jsonPosting.TypeId 	= $HOMEDY_ARRAY_POST_ID[$jsonData.postTypeIndex]
	$jsonPosting.CityId 	= $jsonData.cityID
	$jsonPosting.DistrictId = $jsonData.districtID
	$jsonPosting.WardId = $jsonData.wardID
	$jsonPosting.StreetId = $jsonData.streetID
	$jsonPosting.Address = $jsonData.address
	$jsonPosting.Name = $jsonData.title
	$jsonPosting.Description = Homedy_Content_Endcode($jsonData.content)
	Local $arrayPrice = [0,0,10^6,10^9,10^5 * $jsonData.acr,10^6 * $jsonData.acr]
	$jsonPosting.MinPrice = $jsonData.price * $arrayPrice[$jsonData.priceType]
	$jsonPosting.Acreage = $jsonData.acr
	Switch $jsonData.vipIndex
		Case 0 ; HDY Basic
			Switch $jsonData.date
				Case 4
					$jsonPosting.PackageId = 1
				Case Else
					$jsonPosting.PackageId = 3
			EndSwitch
		Case 1 ; HDY Silver
			Switch $jsonData.date
				Case 4
					$jsonPosting.PackageId = 4
				Case 2
					$jsonPosting.PackageId = 2
				Case Else
					$jsonPosting.PackageId = 33
			EndSwitch
		Case 2 ; HDY Gold
			Switch $jsonData.date
				Case 4
					$jsonPosting.PackageId = 6
				Case 2
					$jsonPosting.PackageId = 5
				Case Else
					$jsonPosting.PackageId = 34
			EndSwitch
		Case 3 ; HDY Diamond
			Switch $jsonData.date
				Case 4
					$jsonPosting.PackageId = 8
				Case 2
					$jsonPosting.PackageId = 7
				Case Else
					$jsonPosting.PackageId = 35
			EndSwitch
		Case Else
			$jsonPosting.PackageId = 3
	EndSwitch

	$jsonPosting.StartDate = Homedy_Get_Date()

	Local $rq = _HttpRequest(2,$HOMEDY_URL_POSTING,_Utf8ToAnsi($jsonPosting.toStr()))
	Local $json = _HttpRequest_ParseJSON($rq)
	If $json = False Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"@error",'_HttpRequest_Test("'&$jsonPosting.toStr()&'")_HttpRequest_Test("'&$rq&'")')
		$CURRENT_STEP += 1
		Return SetError(3)
	Else
		If $json.Message = False Then
			SaveLogPosting($CURRENT_POST_NAME,$HOMEDY_URL,"Result","@error",'_HttpRequest_Test("' & $jsonPosting.toStr() & '")_HttpRequest_Test("' & $rq & '")')
			Return SetError(5)
		EndIf
		Switch $json.Message
			Case "Lưu dữ liệu thành công!"
				SaveLogPosting($CURRENT_POST_NAME,$HOMEDY_URL,"Result",'ShellExecute("https://agent.homedy.com/")ErrorShow(64,"Đăng tin thành công","Mã tin đăng: "'&$json.ObjectReturn.Id&')')
				Return True
			Case "Tài khoản không đủ tiền để thanh toán!"
				Local $code1 = 'ShellExecute("https://agent.homedy.com/")'
				SaveLogPosting($CURRENT_POST_NAME,$HOMEDY_URL,"Result",$code1 & 'ErrorShow(64,"Tài khoản không đủ","Tin đã được lưu nháp\nMã tin đăng: '&$json.ObjectReturn.Id&'")')
				Return True
			Case Else
				SaveLogPosting($CURRENT_POST_NAME,$HOMEDY_URL,"Result","@error",'ErrorShow($CONSOLE_ERROR,"",'&$json.Message&')')
				Return SetError(4)
		EndSwitch
	EndIf
EndFunc

Func Homedy_Get_Date()
	Return @YEAR & "-" & @MON & "-" & @MDAY & "T" & _NowTime(5) & "+07:00"
EndFunc

Func Homedy_Content_Endcode($content)
	Local $result
	Local $arrayContent = StringSplit($content,@CRLF,2)
	If IsArray($arrayContent) = 0 Then
		Return SetError(2)
	Else
		For $i = 0 To UBound($arrayContent) - 1
			$result &= "<p>" & $arrayContent[$i] & "</p>"
		Next
	EndIf
	Return $result
EndFunc

Func Homedy_Upload($arrayImage)
	For $i = 0 To UBound($arrayImage) - 1
		Local $data = Homedy_Data_Upload($arrayImage[$i])
		Local $rq = _HttpRequest(2,$HOMEDY_URL_UPLOAD,$data)
		Local $json = _HttpRequest_ParseJSON($rq)
		If $json = False Or $json.success = False Then
			SaveLogPosting($CURRENT_POST_NAME,$HOMEDY_URL,$CURRENT_STEP,"Đăng ảnh: " & $i & "thất bại")
			$CURRENT_STEP += 1
			ContinueLoop
		Else
			$jsonPosting.SavedMediaModels.set("index(" & $i & ")",$json.medias.index(0).toStr())
			$jsonPosting.SavedMediaModels.index($i).DisplayOrder = $i
			SaveLogPosting($CURRENT_POST_NAME,$HOMEDY_URL,$CURRENT_STEP,"Đăng ảnh: " & $i & " thành công")
			$CURRENT_STEP += 1
		EndIf
	Next
EndFunc

Func Homedy_Posting_Send_Result($data)
	Local $mainThread = _CoProc_ParentPID()
	Local $result
	Local $posting = Homdy_Posting_Main($data)
	If @error Then
		$result = False
	Else
		$result = True
	EndIf
	For $i = 1 To 20
		_CoProc_Send($mainThread,$result & ":::" & $HOMEDY_URL & ":::" & @AutoItPID)
		Sleep(3000)
	Next
EndFunc
