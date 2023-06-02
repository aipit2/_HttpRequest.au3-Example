Func Muaban_Posting_Main($data)
	Write_Log("====================")
	Write_Log("+ Muaban_Posting_Main")
	Global $jsonData = _HttpRequest_ParseJSON($data)
	Global $CURRENT_POST_NAME = $jsonData.postName
	Global $CURRENT_STEP = 1
	; Đăng nhập
	Local $accessToken = RegRead($MUABAN_REG_ACCOUNT,'accessToken')
	If $accessToken = '' Then
		SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,$CURRENT_STEP,"Xin vui lòng đăng nhập trước")
		$CURRENT_STEP += 1
		Return SetError(1)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,$CURRENT_STEP,"Đăng nhập thành công")
		$CURRENT_STEP += 1
	EndIf
	; Lấy header upload
	Local $headerUpload = Muaban_Header_Upload($accessToken)
	SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,$CURRENT_STEP,"Header Upload = " & $headerUpload)
	$CURRENT_STEP += 1
	; Upload
	Local $arrayImage = StringSplit($jsonData.image,"|",2)
	Local $arrayImageEnd = Muaban_Posting_Upload($arrayImage,$headerUpload)
	; Điền thông tin
	Local $dataPosting = $MUABAN_JSON_DATA_POSTING
	Local $position
	If $jsonData.postTypeIndex = 1 Then
		$position = $jsonData.estateTypeIndex * 2 - 1
	Else
		$position = $jsonData.estateTypeIndex * 2
	EndIf
	$dataPosting.flow_id = 4
	$dataPosting.subcategory_id = $MUABAN_ARRAY_PROPERTY[$position][2]
	$dataPosting.phone = RegRead($MUABAN_REG_ACCOUNT, 'phone')
	$dataPosting.contact_name = RegRead($MUABAN_REG_ACCOUNT, 'name')
	$dataPosting.property_type = $MUABAN_ARRAY_PROPERTY[$position][3]
	$dataPosting.property_subtype = $MUABAN_ARRAY_PROPERTY[$position][4]
	$dataPosting.legal_id = $MUABAN_ARRAY_PROPERTY[$position][5]
	$dataPosting.city_id = $jsonData.cityID
	$dataPosting.district_id = $jsonData.districtID
	$dataPosting.ward_id = $jsonData.wardID
	$dataPosting.street_id = $jsonData.streetID
	$dataPosting.project_id = $jsonData.projectID
	$dataPosting.living_area = $jsonData.acr
	$dataPosting.price = $jsonData.price * $MUABAN_ARRAY_PRICE[$jsonData.priceType]
	$dataPosting.bedroom = $jsonData.room
	$dataPosting.bathroom = $jsonData.wc
	$dataPosting.title = $jsonData.title
	$dataPosting.body = $jsonData.content
	For $i = 0 To UBound($arrayImageEnd) - 1
		$dataPosting.images.set('index(' & $i & ')', '{"id": ' & $arrayImageEnd[$i][0] & ', "url": "' & $arrayImageEnd[$i][1] & '", "thumb_url": "' & $arrayImageEnd[$i][2] & '"}')
	Next
	Local $sUrlPosting = "https://api-v6.muaban.net/listing/v1/classifieds"
	Local $header = "Authorization: Bearer " & $accessToken
	Local $sRequestPosting = _HttpRequest(2,$sUrlPosting,_Utf8ToAnsi($dataPosting.toStr()),'','',$header)
	Local $urlPostResult = Muaban_CheckPosting($sRequestPosting)
	If @error = 1 Then
		SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,"Result","@error",'_HttpRequest_Test("' & $dataPosting.toStr() & '")_HttpRequest_Test("' & $sRequestPosting & '")')
		Return SetError(2)
	ElseIf @error = 2 Then
		SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,"Result","@error",'ErrorShow($CONSOLE_ERROR,"",'&$urlPostResult&')')
		Return SetError(3)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,"Result",'ShellExecute("'&$urlPostResult&'")')
		Return $urlPostResult
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Muaban_Posting_Upload
; Description ...: Đăng ảnh lên trang Muaban.net
; Syntax ........: Muaban_Posting_Upload($arrayImage, $header)
; Parameters ....: $arrayImage          - Mảng địa chỉ ảnh
;                : $header				- Header upload
; Return values .: $arrayImageEnd		- Mảng chứa các link ảnh sau khi upload
; Author ........: Trần Hùng
; ===============================================================================================================================
Func Muaban_Posting_Upload($arrayImage, $header)
	Local $aImageEnd[0][3]
	Local $urlUploadImage = 'https://cloud.muaban.net/images'
	For $i = 0 To UBound($arrayImage) - 1
		If $i >= 30 Then
			ExitLoop
		EndIf
		Local $aForm = [['$file',$arrayImage[$i]]]
		Local $rqUP = _HttpRequest(2,$urlUploadImage,$aForm)
		Local $jsonUp = _HttpRequest_ParseJSON($rqUP)
		If @error Or $jsonUp = False Then
			SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,$CURRENT_STEP,"Đăng ảnh " & $i & " thất bại","Link ảnh: " & $arrayImage[$i])
			$CURRENT_STEP += 1
			ContinueLoop
		EndIf
		Local $dataGetInfor = '{"path":"'&$jsonUp.path&'","url":"'&$jsonUp.url&'","mac":"'&$jsonUp.mac&'","success":true,"refer_type_id":1,"media_type":1}'
		Local $rqGetInfor = _HttpRequest(2,'https://api-v6.muaban.net/media/v1/medias',$dataGetInfor,'','',$header)
		Local $jsonGetInfor = _HttpRequest_ParseJSON($rqGetInfor)
		If @error Or $jsonGetInfor = False Then
			SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,$CURRENT_STEP,"Đăng ảnh " & $i & " thất bại","Link ảnh: " & $arrayImage[$i])
			$CURRENT_STEP += 1
			ContinueLoop
		EndIf
		SaveLogPosting($CURRENT_POST_NAME,$MUABAN_URL,$CURRENT_STEP,"Đăng ảnh " & $i & " thành công","Link ảnh: " & $arrayImage[$i])
		$CURRENT_STEP += 1
		_ArrayAdd($aImageEnd,$jsonGetInfor.id & "|" & $jsonGetInfor.url & "|" & $jsonGetInfor.thumb_url)
	Next
	Return $aImageEnd
EndFunc

Func Muaban_Header_Upload($accessToken)
	Write_Log("====================")
	Write_Log("+ Muaban_Header_Upload")
	Return StringReplace($MUABAN_HEADER_UPLOAD,'${accessToken}', $accessToken)
EndFunc

Func Muaban_CheckPosting($response)
	Local $arrayId = StringRegExp($response,'id":(\d+),',1)
	If @error Then
		Local $arrayError = StringRegExp($response,'message":"(.*?)"',1)
		If @error Then
			Return SetError(1,0,$response)
		Else
			Return SetError(2,0,$arrayError[0])
		EndIf
	Else
		Return "https://muaban.net/dashboard/manage-listing"
	EndIf
EndFunc

Func Muaban_Posting_Send_Result($data)
	Local $mainThread = _CoProc_ParentPID()
	Local $result
	Local $posting = Muaban_Posting_Main($data)
	If @error Then
		$result = False
	Else
		$result = True
	EndIf
	For $i = 1 To 20
		_CoProc_Send($mainThread,$result & ":::" & $MUABAN_URL & ":::" & @AutoItPID)
		Sleep(1000)
	Next
EndFunc