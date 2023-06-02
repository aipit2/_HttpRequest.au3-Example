Func Thuecanho123_Posting_Main($data)
	Global $jsonData = _HttpRequest_ParseJSON($data)
	Global $CURRENT_STEP = 1
	Global $CURRENT_POST_NAME = $jsonData.postName
	; Đăng nhập
	Local $accessToken = AccountSetting_Thuecanho123_Login("","",False)
	If @error Then
		SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Đăng nhập thất bại")')
		$CURRENT_STEP += 1
		Return SetError(1)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,$CURRENT_STEP,"Đăng nhập thành công")
		$CURRENT_STEP += 1
	EndIf
	; Upload
	Local $arrayImage = StringSplit($jsonData.image,"|",2)
	Local $arrayImageUploaded = Thuecanho123_Upload($arrayImage)
	; Thay đổi thông số
	Local $formData = ["project_id=" & $jsonData.projectID]
	_ArrayAdd($formData,"province_id=" & $jsonData.cityID)
	_ArrayAdd($formData,"district_id=" & $jsonData.districtID)
	_ArrayAdd($formData,"ward_id=" & $jsonData.wardID)
	_ArrayAdd($formData,"street_id=" & $jsonData.streetID)
	_ArrayAdd($formData,"~address=" & $jsonData.address)
	_ArrayAdd($formData,"~title=" & $jsonData.title)
	_ArrayAdd($formData,"~content=" & $jsonData.content,0,"|","@CRLF")
	_ArrayAdd($formData,"price=" & $jsonData.price * $BDS123_ARRAY_PRICE[$jsonData.priceType])
	_ArrayAdd($formData,"dien_tich=" & $jsonData.acr)
	_ArrayAdd($formData,"so_phong_ngu=" & $jsonData.room)
	_ArrayAdd($formData,"so_toilet=" & $jsonData.wc)
	_ArrayAdd($formData,"huong_cua_chinh=0")
	_ArrayAdd($formData,"youtube_url=")
	_ArrayAdd($formData,"action=add_new_post")
	_ArrayAdd($formData,"payment_method=wait_payment")
	If UBound($arrayImageUploaded) > 0 Then
		For $i = 0 To UBound($arrayImageUploaded) - 1
			_ArrayAdd($formData,"image_linked[" & $arrayImageUploaded[$i][0] & "]=" & $arrayImageUploaded[$i][1])
		Next
	EndIf
	Local $header = "x-csrf-token: " & $accessToken
	Local $rqPosting = _HttpRequest(2,$THUECANHO123_URL_POSTING,$formData,'','',$header)
	Local $decodePosting = _HTMLDecode($rqPosting)
	Local $idPost = StringRegExp($decodePosting,'thanh-toan-tin\/(\d+)"',1)
	If @error Then
		SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,"Result","@error",'_HttpRequest_Test("' & _ArrayToString($formData) & '")_HttpRequest_Test("' & $decodePosting & '")')
		Return SetError(2)
	EndIf

	If $jsonData.option1 = 1 Then
		Local $label = 1
	Else
		Local $label = 0
	EndIf

	Local $package_type = $THUECANHO123_ARRAY_VIP_2[$jsonData.vipIndex]

	Local $dataPayment = "action=re_pay&post_id=" & $idPost[0] &"&package_id=" & $THUECANHO123_ARRAY_VIP[$jsonData.vipIndex] & "&total_date_vip=" & $jsonData.date
	$dataPayment &= "&package_type=" & $package_type & "&label=" & $label & "&total_time=" & $jsonData.date & "&payment_method=account"
	Local $rqPayment = _HttpRequest(2,"https://thuecanho123.com/api/post/repay",$dataPayment)
	Local $check = StringRegExp($rqPayment,'{"code":200,"error":0',0)
	If $check = 1 Then
		SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,"Result",'ShellExecute("https://thuecanho123.com/dashboard/posts.html?status=all")')
		Return True
	Else
		SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,"Result","@error",'_HttpRequest_Test("' & $dataPayment & '")')
		Return SetError(3)
	EndIf
EndFunc

Func Thuecanho123_Upload($arrayImage)
	Local $arrayResult[0][2]
	For $image In $arrayImage
		Local $data = Thuecanho123_Upload_Data($image)
		Local $rq = _HttpRequest(2,$THUECANHO123_URL_UPLOAD,$data)
		Local $remove = StringReplace($rq,'\',"") ; Xóa \ để nó không phải dạng \/
		Local $id = StringRegExp($remove,'"id":(\d+)',3)
		If @error Then
			SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,$CURRENT_STEP,"Upload ảnh: " & $image & " thất bại")
			$CURRENT_STEP += 1
			ContinueLoop
		EndIf
		Local $path = StringRegExp($remove,'image_path":"(.*?)"',3)
		If @error Then
			SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,$CURRENT_STEP,"Upload ảnh: " & $image & " thất bại")
			$CURRENT_STEP += 1
			ContinueLoop
		EndIf
		SaveLogPosting($CURRENT_POST_NAME,$THUECANHO123_URL,$CURRENT_STEP,"Upload ảnh: " & $image & " thành công")
		$CURRENT_STEP += 1
		_ArrayAdd($arrayResult,$id[0] & "|" & $path[0])
	Next
	Return $arrayResult
EndFunc

Func Thuecanho123_Upload_Data($image)
	Local $data = ["source=thuecanho123","source_url=window.location.href","from=dangtin","$file=" & $image]
	Return $data
EndFunc

Func Thuecanho123_Posting_Send_Result($data)
	Local $mainThread = _CoProc_ParentPID()
	Local $result
	Local $posting = Thuecanho123_Posting_Main($data)
	If @error Then
		$result = False
	Else
		$result = True
	EndIf
	For $i = 1 To 20
		_CoProc_Send($mainThread,$result & ":::" & $THUECANHO123_URL & ":::" & @AutoItPID)
		Sleep(1000)
	Next
EndFunc