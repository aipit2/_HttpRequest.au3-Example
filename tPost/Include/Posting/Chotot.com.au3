Func Chotot_Posting_Main($data)
	Global $jsonData = _HttpRequest_ParseJSON($data)
	Global $CURRENT_STEP = 1
	Global $CURRENT_POST_NAME = $jsonData.postName
	; Đăng nhập
	Local $accessToken = AccountSetting_Chotot_Login("","",False)
	If @error Then
		SaveLogPosting($CURRENT_POST_NAME,$CHOTOT_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Đăng nhập thất bại")')
		$CURRENT_STEP += 1
		Return SetError(1)
	EndIf
	; Tạo header bearer từ accessToken
	Local $header = 'Authorization: Bearer ' & $accessToken ; header này dùng cho mọi request luôn
	Local $arrayImage = StringSplit($jsonData.image,"|",2)
	; Upload ảnh
	Local $arrayImageUploaded = Chotot_Posting_Upload($arrayImage,$header)
	; Thêm thông tin
	Local $jsonPosting = _HttpRequest_ParseJSON($CHOTOT_FORM_POSTING)
	; 0) Đoạn này phải điển dạng apartment_type:house_type:commercial_type cũng đ biết giải thích làm sao
	For $i = 1 To UBound($CHOTOT_ARRAY_ESTATE_ID,2) - 1
		If $CHOTOT_ARRAY_ESTATE_ID[$jsonData.estateTypeIndex][$i] <> "" Then
			$jsonPosting.set($CHOTOT_ARRAY_ESTATE_NAME[$i],'"' & $CHOTOT_ARRAY_ESTATE_ID[$jsonData.estateTypeIndex][$i] & '"')
			ExitLoop
		EndIf
	Next
	; 1) type: Loại tin (Sẽ có giá trị là "s": Bán hoặc "u": Thuê)
	$jsonPosting.type = $CHOTOT_ARRAY_POST_TYPE[$jsonData.postTypeIndex]
	; 2) category: Loại bất động sản
	Local $esateId = $CHOTOT_ARRAY_ESTATE_ID[$jsonData.estateTypeIndex][0]
	$jsonPosting.category = $esateId
	$jsonPosting.subCategory = $esateId
	; 3) region_v2: ID Thành phố
	$jsonPosting.region_v2 = $jsonData.cityID
	; 4) area_v2: ID Quận
	$jsonPosting.area_v2 = $jsonData.districtID
	; 5) ward: ID Phường
	$jsonPosting.ward = $jsonData.wardID
	; 6) projectid: ID Dự án (Nếu có)
	If $jsonData.projectID <> "" Then ; Cần phải check lại xem nó có thêm vào không
		$jsonPosting.set("projectid",$jsonData.projectID)
	EndIf
	; 6+) streetName: Tên đường
	If $jsonData.streetName <> "" Then
		$jsonPosting.set("detail_address",'"' & $jsonData.streetName & '"')
	EndIf
	; 6++) streetID: ID đường
	If $jsonData.streetID <> "" Then
		$jsonPosting.set("street_id",$jsonData.streetID)
	EndIf
	; 7) size: Diện tích
	$jsonPosting.size = $jsonData.acr
	; 8) price: Giá
	Local $arrayPrice = [0,0,10^6,10^9,10^5 * $jsonData.acr,10^6 * $jsonData.acr]
	$jsonPosting.price = $jsonData.price * $arrayPrice[$jsonData.priceType]
	; 9) subject: Tiêu đề
	$jsonPosting.subject = $jsonData.title
	; 10) body: Nội dung
	$jsonPosting.body = $jsonData.content
	; 11) room: Số phòng ngủ
	If $jsonData.room <> 0 Then
		$jsonPosting.set("rooms",$jsonData.room)
	EndIf
	; 12) wc: Số nhà vệ sinh
	If $jsonData.wc <> 0 Then
		$jsonPosting.set("toilets",$jsonData.wc)
	EndIf
	; 13) image_id: Link ảnh sau khi upload
	For $i = 0 To UBound($arrayImageUploaded) - 1
		$jsonPosting.set("image_id" & $i,'"' & $arrayImageUploaded[$i] & '"')
	Next
	; 14) Endcode dataPosting
	Local $dataPosting = _Utf8ToAnsi($jsonPosting.toStr())
	Local $responsePosting = _HttpRequest(2,$CHOTOT_URL_POSTING,$dataPosting,'','',$header)
	Local $error = StringRegExp($responsePosting,'message":"(.*?)"',1)
	If StringRegExp($responsePosting,'TRANS_OK',0) = 1 Then
		SaveLogPosting($CURRENT_POST_NAME,$CHOTOT_URL,"Result",'ShellExecute("https://www.chotot.com/dashboard/ads/unpaid")')
		Return True
	ElseIf IsArray($error) = 1 Then
		SaveLogPosting($CURRENT_POST_NAME,$CHOTOT_URL,"Result","@error",'ErrorShow($CONSOLE_ERROR,"",'&$error[0]&')')
		Return SetError(2)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$CHOTOT_URL,"Result","@error",'_HttpRequest_Test("' & $jsonPosting.toStr() & '")_HttpRequest_Test("' & $responsePosting & '")')
		Return SetError(3)
	EndIf
EndFunc

Func Chotot_Posting_Upload($arrayImage,$header)
	Local $arrayResult[0]
	For $i = 0 To UBound($arrayImage) - 1
		If $i = 12 Then
			ExitLoop
		EndIf
		Local $data = [["$image",$arrayImage[$i]]]
		Local $rq = _HttpRequest(2,$CHOTOT_URL_UPLOAD,$data,'','',$header)
		Local $idimage = StringRegExp($rq, '"image_id": "(.*?)"',1)
		If IsArray($idimage) = 1 Then
			SaveLogPosting($CURRENT_POST_NAME,$CHOTOT_URL,$CURRENT_STEP,"Đăng ảnh: " & $i & " thành công")
			$CURRENT_STEP += 1
			_ArrayAdd($arrayResult,$idimage[0])
		Else
			SaveLogPosting($CURRENT_POST_NAME,$CHOTOT_URL,$CURRENT_STEP,"Đăng ảnh: " & $i & " thất bại")
			$CURRENT_STEP += 1
		EndIf
	Next
	Return $arrayResult
EndFunc

Func Chotot_Posting_Send_Result($data)
	Local $mainThread = _CoProc_ParentPID()
	Local $result
	Local $posting = Chotot_Posting_Main($data)
	If @error Then
		$result = False
	Else
		$result = True
	EndIf
	For $i = 1 To 20
		_CoProc_Send($mainThread,$result & ":::" & $CHOTOT_URL & ":::" & @AutoItPID)
		Sleep(1000)
	Next
EndFunc

Func Chotot_Posting_Pay($postId)

EndFunc