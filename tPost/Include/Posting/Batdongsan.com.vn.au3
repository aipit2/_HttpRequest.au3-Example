Func Bds_Posting_Main($data)
	Write_Log("====================")
	Write_Log("+ Bds_Posting_Main")
	_HttpRequest_CookieJarSet($FILE_COOKIE)
	Global $jsonData = _HttpRequest_ParseJSON($data)
	Global $CURRENT_STEP = 1
	Global $CURRENT_POST_NAME = $jsonData.postName
	; Đăng nhập
	Local $privateToken = IniRead($FILE_COOKIE,"batdongsan.com.vn","privateToken","")
	If $privateToken = "" Then
		Return SetError(1)
	Else
		Local $arrayToken = StringRegExp($privateToken,'access_token":"(.*?)"',1)
		If @error Then
			Return SetError(2)
		Else
			Local $oldToken = $arrayToken[0]
		EndIf
	EndIf
	Local $newToken = Bds_RefreshToken($oldToken)
	; Get token Upload
	Local $tokenUpload = Bds_Posting_GetUploadToken($newToken)
	If $tokenUpload == False Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không tìm thấy token upload")')
		$CURRENT_STEP += 1
		Return SetError(2)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"Đã tìm thấy token upload: " & $tokenUpload)
		$CURRENT_STEP += 1
	EndIf
	; Upload
	Local $arrayImage = StringSplit($jsonData.image,"|",2)
	Local $imageTemp = Bds_Posting_Upload($tokenUpload,$arrayImage)
	SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"$imageTemp: " & $imageTemp)
	$CURRENT_STEP += 1
	; Create Post
	Local $jsonCreatePost = _HttpRequest_ParseJSON($BDS_DATA_CREATE_POST)
	Local $productType = $__g_a_Bds_PostTypeId[$jsonData.postTypeIndex]
	Local $categoryID = $__g_a_Bds_EstateTypeId[$jsonData.estateTypeIndex][$jsonData.postTypeIndex - 1]
	$jsonCreatePost.title = $jsonData.title
	$jsonCreatePost.descContent = $jsonData.content
	$jsonCreatePost.draftId = ""
	$jsonCreatePost.productType = $productType
	$jsonCreatePost.categoryId = $categoryID
	$jsonCreatePost.cityCode = $jsonData.cityID
	$jsonCreatePost.districtId = $jsonData.districtID
	$jsonCreatePost.wardId = $jsonData.wardID
	$jsonCreatePost.streetId = $jsonData.streetID
	$jsonCreatePost.projectId = $jsonData.projectID
	$jsonCreatePost.acreage = $jsonData.acr
	$jsonCreatePost.bedroomCount = $jsonData.room
	$jsonCreatePost.toiletCount = $jsonData.wc

	Switch $jsonData.priceType
		Case 0,1
			$jsonCreatePost.price = Null
		Case Else
			$jsonCreatePost.price = $__g_a_Bds_Price[$jsonData.priceType][$jsonData.postTypeIndex - 1] * $jsonData.price
	EndSwitch

	$jsonCreatePost.unitPrice = $__g_a_Bds_PriceId[$jsonData.priceType][$jsonData.postTypeIndex - 1]
	$jsonCreatePost.fileIds = $imageTemp
	Local $dateCalculator = AddDate($jsonData.date,"yyyy-mm-dd")
	$jsonCreatePost.startDate = $dateCalculator[0]
	$jsonCreatePost.endDate = $dateCalculator[1]
	$jsonCreatePost.viptype = $__g_a_Bds_VipId[$jsonData.vipIndex]
	If $jsonData.option1 == 1 Then
		$jsonCreatePost.isAddOn = True
	Else
		$jsonCreatePost.isAddOn = False
	EndIf
	$jsonCreatePost.fileIds = $imageTemp
	; Đoạn này phải chỉnh khi có chức năng đăng tin vip
	$jsonCreatePost.address 		= $jsonData.address
	$jsonCreatePost.contactMobile 	= RegRead($BDS_REG_ACCOUNT,"phone")
	$jsonCreatePost.contactName 	= RegRead($BDS_REG_ACCOUNT,"name")
	Local $header = Bds_Header_Create_Post($newToken)
	Local $dataCratePost = _Utf8ToAnsi($jsonCreatePost.toStr())
	Local $rq = _HttpRequest(2,$BDS_URL_CREATE_POST,$dataCratePost,'','',$header,"POST")
	Local $check = StringRegExp($rq,'Success":true',0)
	Local $draftID = StringRegExp($rq,'ProductDraftId":(.*?),',1)
	If $check == 0 Or IsArray($draftID) = 0 Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không tìm thấy DraftId")')
		$CURRENT_STEP += 1
		Return SetError(3)
	EndIf
	; POST
	; Get token Upload
;~ 	Local $tokenUpload = Bds_Posting_GetUploadToken($accessToken)
;~ 	If $tokenUpload == False Then
;~ 		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không tìm thấy token upload")')
;~ 		$CURRENT_STEP += 1
;~ 		Return SetError(2)
;~ 	Else
;~ 		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"Đã tìm thấy token upload: " & $tokenUpload)
;~ 		$CURRENT_STEP += 1
;~ 	EndIf
	; Upload
;~ 	Local $imageTemp = Bds_Posting_Upload($tokenUpload,$arrayImage)
;~ 	SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"$imageTemp: " & $imageTemp)
;~ 	$CURRENT_STEP += 1
;~ 	Exit
;~ 	Local $check = StringRegExp($rq,'Success":true',0)
;~ 	Local $draftID = StringRegExp($rq,'ProductDraftId":(.*?),',1)
;~ 	If $check == 0 Or IsArray($draftID) = 0 Then
;~ 		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không tìm thấy DraftId")')
;~ 		$CURRENT_STEP += 1
;~ 		Return SetError(3)
;~ 	EndIf

	; Update Post
	$jsonCreatePost.draftId = $draftID[0]
	$jsonCreatePost.set("skipValidatePhoneNumber",True)
	Local $headerUpdatePost = Bds_Header_Update_Post($newToken)
	Local $dataUpdatePost = _Utf8ToAnsi($jsonCreatePost.toStr())
	Local $rq = _HttpRequest(2,$BDS_URL_UPDATE_POST,$dataUpdatePost,'','',$headerUpdatePost)
	Local $check = StringRegExp($rq,'"Success":true',0)
	If $check == 1 Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,"Result",'ShellExecute("https://batdongsan.com.vn/sellernet/quan-ly-tin-rao-ban-cho-thue")')
		Return True
	Else
		Local $jsonError = _HttpRequest_ParseJSON($rq)
		Local $error = $jsonError.Error.Message
		If @error Then
			SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,"Result","@error",'_HttpRequest_Test("' & $jsonCreatePost.toStr() & '")_HttpRequest_Test("' & $rq & '")')
			Return SetError(4)
		Else
			SaveLogPosting($CURRENT_POST_NAME,$BDS_URL,"Result","@error",'ErrorShow($CONSOLE_ERROR,"",'&$error&')')
			Return SetError(5)
		EndIf
	EndIf
	; Đoạn này nên chỉnh thành khi mỗi trang đăng xong thì sẽ edit registry result của bài viết đó
	; để tránh xung đột với nhau
	; Nếu bài viết chưa được lưu thì tạo 1 registry bài viết hiện tại
EndFunc

Func Bds_Posting_GetUploadToken($accessToken)
	Local $header = Bds_Header_Upload($accessToken)
	Local $rq = _HttpRequest(2,$BDS_URL_GET_UPLOAD_TOKEN,'',-1,'',$header,'GET')
	Local $token
	Local $searchTokenUpload = StringRegExp($rq,'Result":"(.*?)"."Success":true',1)
	If @error Then
		$token = False
	Else
		$token = $searchTokenUpload[0]
	EndIf
	Return $token
EndFunc
Func Bds_Posting_Upload($tokenUpload,$arrayImage,$vipIndex = 0)
	Local $arrayTemp[0]
	For $i = 0 To UBound($arrayImage) - 1
		Switch $vipIndex
			Case 0
				If $i >= 8 Then
					ExitLoop
				EndIf
			Case 1
				If $i >= 16 Then
					ExitLoop
				EndIf
			Case 2,3
				If $i >= 18 Then
					ExitLoop
				EndIf
			Case 4
				If $i >= 20 Then
					ExitLoop
				EndIf
			Case 5
				If $i >= 24 Then
					ExitLoop
				EndIf
		EndSwitch
		Local $data = [["project","bds"]]
		_ArrayAdd($data,"WaterMark|" & "false")
		_ArrayAdd($data,"UploadType|" & "upload")
		_ArrayAdd($data,"submit|" & "1")
		_ArrayAdd($data,"StringDecypt|" & $tokenUpload)
		_ArrayAdd($data,"$fileToUpload|" & $arrayImage[$i])
		Local $rq = _HttpRequest(2,$BDS_URL_UPLOAD,$data)
		Local $check = StringRegExp($rq,'success":true',0)
		Local $check2 = StringRegExp($rq,'newUuid":"(.*?)"',1)
		If $check = 1 And $check2 <> @error Then
			_ArrayAdd($arrayTemp,"3temp." & $check2[0])
		EndIf
	Next
	Return _ArrayToString($arrayTemp,"||")
EndFunc
Func Bds_Posting_Upload2($tokenUpload,$arrayImage,$vipIndex = 0)
	Local $arrayTemp = "[]"
	Local $jsonResult = _HttpRequest_ParseJSON($arrayTemp)
	For $i = 0 To UBound($arrayImage) - 1
		Switch $vipIndex
			Case 0
				If $i >= 8 Then
					ExitLoop
				EndIf
			Case 1
				If $i >= 16 Then
					ExitLoop
				EndIf
			Case 2,3
				If $i >= 18 Then
					ExitLoop
				EndIf
			Case 4
				If $i >= 20 Then
					ExitLoop
				EndIf
			Case 5
				If $i >= 24 Then
					ExitLoop
				EndIf
		EndSwitch
		Local $data = [["project","bds"]]
		_ArrayAdd($data,"WaterMark|" & "false")
		_ArrayAdd($data,"UploadType|" & "upload")
		_ArrayAdd($data,"submit|" & "1")
		_ArrayAdd($data,"StringDecypt|" & $tokenUpload)
		_ArrayAdd($data,"$fileToUpload|" & $arrayImage[$i])
		Local $rq = _HttpRequest(2,$BDS_URL_UPLOAD,$data)
		Local $check = StringRegExp($rq,'success":true',0)
		Local $check2 = StringRegExp($rq,'newUuid":"(.*?)"',1)
		Local $check3 = StringRegExp($rq,'data":"(.*?)"',1)
		If $check = 1 And IsArray($check2) = 1 And IsArray($check3) = 1 Then
			$jsonResult.set('index('&$i&')','{"fileName": "'&$check2[0]&'", "imageUrl": "'&$check3[0]&'", "existed":false,"is360":false,"description":"","rotation":0}')
		EndIf
	Next
	Return $jsonResult.toStr()
EndFunc
Func Bds_Header_Upload($accessToken)
	Local $header = 'Host: sellernetapi.batdongsan.com.vn'
	$header &= '|UniqueId: deviceidfromweb'
	$header &= '|Access-Control-Allow-Origin: *'
	$header &= '|Access-Control-Allow-Credentials: true'
	$header &= '|Access-Control-Allow-Methods: GET,HEAD,OPTIONS,POST,PUT'
	$header &= '|Access-Control-Allow-Headers: Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers'
	$header &= '|APIVersion: 2020-02-28 18:30'
	$header &= '|Authorization: ' & $accessToken
	$header &= '|Auth: 1'
	$header &= '|Referer: https://batdongsan.com.vn/sellernet/dang-tin'
	$header &= '|Origin: https://batdongsan.com.vn'
	Return $header
EndFunc
Func Bds_Header_Create_Post($accessToken)
	Local $header = "authority: sellernetapi.batdongsan.com.vn"
	$header &= "|method: POST"
	$header &= "|path: /api/ProductDraft/UpdateProductDraft"
	$header &= "|scheme: https"
	$header &= "|access-control-allow-credentials: true"
	$header &= "|access-control-allow-headers: Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers"
	$header &= "|access-control-allow-methods: GET,HEAD,OPTIONS,POST,PUT"
	$header &= "|access-control-allow-origin: *"
	$header &= "|apiversion: 2020-02-28 18:30"
	$header &= "|auth: 1"
	$header &= "|authorization: " & $accessToken
	$header &= "|origin: https://batdongsan.com.vn"
	$header &= "|referer: https://batdongsan.com.vn/"
	$header &= '|sec-ch-ua: "Microsoft Edge";v="107", "Chromium";v="107", "Not=A?Brand";v="24"'
	$header &= '|sec-ch-ua-mobile: ?0'
	$header &= '|sec-ch-ua-platform: "Windows"'
	$header &= '|sec-fetch-dest: empty'
	$header &= '|sec-fetch-mode: cors'
	$header &= '|sec-fetch-site: same-site'
	$header &= '|sellernet-origin: tablet'
	$header &= '|uniqueid: deviceidfromweb'
	Return $header
EndFunc

Func Bds_RefreshToken($oldToken)
	Local $url = "https://batdongsan.com.vn/HandlerWeb/UserHandler.ashx?type=RefreshToken"
	Local $rq = _HttpRequest(2,$url,'',-1)
	Local $arrayToken = StringRegExp($rq,'access_token":"(.*?)"',1)
	If @error Then
		Return False
	Else
		Return $arrayToken[0] ; new token
	EndIf
EndFunc

Func Bds_Posting_Send_Result($data)
	Local $mainThread = _CoProc_ParentPID()
	Local $result
	Local $posting = Bds_Posting_Main($data)
	If @error Then
		$result = False
	Else
		$result = True
	EndIf
	For $i = 1 To 20
		_CoProc_Send($mainThread,$result & ":::" & $BDS_URL & ":::" & @AutoItPID)
		Sleep(3000)
	Next
EndFunc


Func Bds_Posting($token)
	Local $url 	= $BDS_URL_CREATE_POST
	Local $data = '{"productType":49,"productId":null,"draftId":0,"categoryId":326,"projectId":2065,"title":"Căn hộ the sun avenue 56m 1pn full lung linh","address":"Dự án The Sun Avenue,  Quận 2, Hồ Chí Minh","descContent":"Cần cho thuê căn hộ The Sun Avenue 1 phòng ngủ, full nội thất đẹp, 14tr/tháng.\n\n- Địa chỉ: 28 Mai Chí Thọ, Phường An Phú, Quận 2\n\n- Diện tích: 56m2\n\n- 1 phòng ngủ, 1WC.\n\n- Nhà full nội thất đẹp, đầy đủ tiện nghi.\n\n+ View trực diện Landmark 81, từ phòng khách có thể ngắm pháo bông thoải mái, mỗi tầng chỉ có 1 căn view này.\n\n+ Máy lạnh Panasonic Inverter, bếp từ & hồng ngoại, máy hút nhập khẩu từ Đức, tủ lạnh Sharp 428L, máy giặt Panasonic, giường, tủ quần áo, bàn ăn, sofa...\n\n+ Tiện ích: Gym, hồ bơi, BBQ, công viên, sân chơi cho trẻ (free), hầm giữ xe rộng rãi...\n\n- Giá thuê: 14 triệu/tháng.\n\nLiên hệ NGAY ( tư vấn hỗ trợ nhiệt tình vui vẻ )","cityCode":"SG","districtId":54,"streetId":4163,"wardId":118,"acreage":56,"wayInWidth":null,"bedroomCount":0,"price":0.00014,"unitPrice":1,"facadeWidth":null,"houseDirection":null,"startDate":"2023-01-01","endDate":"2023-01-11","viptype":5,"isAddOn":false,"isReceiEmail":false,"discount":0,"addDay":0,"furniture":null,"legality":null,"toiletCount":0,"floorCount":null,"balconyDirection":null,"promotionId":0,"promotionType":0,"transAccountId":0,"promotionChecksum":"","fileIds":"[]","contactAddress":"Quận 2, Hồ Chí Minh, Việt Nam","contactMobile":"0843524010","contactName":"Trần Hùng","contactPhone":null,"contactEmail":"idontknow94615321@gmail.com","latitude":10.788448,"longtitude":106.75197,"videoUrl":null,"period":-1,"autoRenewConfigUpdateModel":{"totalCount":1,"actionType":0}}'
	Local $header = Bds_Header_Create_Post($token)
	Local $rq 	= _HttpRequest(2,$url,_Utf8ToAnsi($data),-1,'',$header)
	_HttpRequest_Test($rq)
EndFunc