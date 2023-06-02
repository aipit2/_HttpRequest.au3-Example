Func Bds123_Posting_Main($data)
	Write_Log("====================")
	Write_Log("+ Bds123_Posting_Main")
	Global $jsonData = _HttpRequest_ParseJSON($data)
	Global $CURRENT_STEP = 1
	Global $CURRENT_POST_NAME = $jsonData.postName
	; Đăng nhập
	Local $login = AccountSetting_Bds123_Login()
	If @error Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Đăng nhập thất bại")')
		$CURRENT_STEP += 1
		Return SetError(1)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"Đăng nhập thành công")
		$CURRENT_STEP += 1
	EndIf

	; Tìm Upload Token
	Local $uploadToken = Bds123_GetUploadToken()
	If @error Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không tìm thấy token upload")')
		$CURRENT_STEP += 1
		Return SetError(2)
	Else
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"Token Upload: " & $uploadToken)
		$CURRENT_STEP += 1
	EndIf
	; Upload
	Local $userID = RegRead($BDS123_REG_ACCOUNT,"userID")
	Local $dataPosting = FileRead($BDS123_FOLDER_DATA & 'JSON_DATA_POSTING.data')
	Local $jsonPosting = _HttpRequest_ParseJSON($dataPosting)
	Local $dataPostingJson
	If $jsonData.image <> "" Then
		Local $arrayImage = StringSplit($jsonData.image,"|",2)
		$dataPostingJson = Bds123_Upload($uploadToken,$arrayImage,$userID,$jsonPosting)
	Else
		$dataPostingJson = $jsonPosting
	EndIf
	; Add value
	$dataPostingJson.post_data.title 	= $jsonData.title
	$dataPostingJson.post_data.content 	= $jsonData.content

	Local $indexEstateType = $jsonData.estateTypeIndex
	Local $indexPostType = $jsonData.postTypeIndex - 1 ; Vị trí loại tin
	Local $Estate = $BDS123_ARRAY_ESTATE_ID[$indexEstateType][$indexPostType] ; ID:ParentID
	Local $arrayEstateId = StringSplit($Estate,":",2) ; Mảng ID và Parent ID
	; Tìm kiếm thông tin về loại bds điền theo form của Bds123.vn (Không thể điền mỗi ID và ID parent được)
	$dataPostingJson.post_data.estate.id = Number($arrayEstateId[0])
	$dataPostingJson.post_data.estate.parent_id = Number($arrayEstateId[1])
	Local $filterEstate = $BDS123_JSON_ESTATE_ID.filter('$.[?(@.id == '&$arrayEstateId[0]&')]')
	$dataPostingJson.post_data.estate.title = $filterEstate.index(0).title
	$dataPostingJson.post_data.estate.title_make_page = $filterEstate.index(0).title_make_page
	$dataPostingJson.post_data.estate.template_type = $filterEstate.index(0).template_type
	$dataPostingJson.post_data.estate.slug = $filterEstate.index(0).slug
	$dataPostingJson.post_data.estate.url = $filterEstate.index(0).url

	Local $postTypeName = Bds123_PostType_Name($jsonData.postTypeIndex) ; Return 'thue' hoặc 'ban'
	$dataPostingJson.post_data.post_type 		= $postTypeName
	$dataPostingJson.post_data.estate.post_type = $postTypeName
	$dataPostingJson.post_data.province.id = $jsonData.cityID
	$dataPostingJson.post_data.district.id = $jsonData.districtID
	Switch $jsonData.wardID
		Case 0
			$dataPostingJson.post_data.ward.id = Null
		Case Else
			$dataPostingJson.post_data.ward.id = $jsonData.wardID
	EndSwitch

	Switch $jsonData.streetID
		Case 0
			$dataPostingJson.post_data.street.id = Null
		Case Else
			$dataPostingJson.post_data.street.id = $jsonData.streetID
	EndSwitch

	Switch $jsonData.projectID
		Case 0
			$dataPostingJson.post_data.project = Null
		Case Else
			Local $urlGetProject = 'https://bds123.vn/api/get/projects'
			Local $getProjectInfor = _HttpRequest(2,$urlGetProject)
			Local $dataProject = '{"province":'&$jsonData.cityID&',"district":'&$jsonData.districtID&'}'
			Local $rq = _HttpRequest(2,$urlGetProject,$dataProject)
			Local $jsonProject = _HttpRequest_ParseJSON($rq)
			If $jsonProject == False Then
				ContinueCase
			EndIf
			Local $filterProject = $jsonProject.filter('$.data[?(@.id == '&$jsonData.projectID&')]')
			If $filterProject == False Then
				ContinueCase
			EndIf
			$dataPostingJson.post_data.project = $filterProject.index(0)
	EndSwitch

	$dataPostingJson.post_data.address = $jsonData.address ; Để Null nó sẽ k tự động lấy địa chỉ từ ID đâu
	$dataPostingJson.post_data.price = $jsonData.price * $BDS123_ARRAY_PRICE[$jsonData.priceType]
	$dataPostingJson.post_data.dien_tich = $jsonData.acr
	$dataPostingJson.post_data.infomation.acreage = $jsonData.acr
	$dataPostingJson.post_data.infomation.bedroom = $jsonData.room
	$dataPostingJson.post_data.infomation.toilet = $jsonData.wc
	$dataPostingJson.post_data.unit.id = $Bds123_ARRAY_PRICE_TYPE[$jsonData.postTypeIndex - 1][$jsonData.priceType]
	$dataPostingJson.post_data.contact_name = RegRead($BDS123_REG_ACCOUNT,"name")
	$dataPostingJson.post_data.contact_phone = RegRead($BDS123_REG_ACCOUNT,"phone")
	; VIP : Phần này phải chỉnh sửa lại để cho người dùng chọn
	Local $rqGetVipId = _HttpRequest(2,"https://bds123.vn/api/get/packages?estate_id=" & $arrayEstateId[0])
	Local $json = _HttpRequest_ParseJSON($rqGetVipId)
	If $json = False Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không thể kết nối đến server Bds123.vn")')
		$CURRENT_STEP += 1
		Return SetError(3)
	EndIf
	Local $vipIndexInpPackage
	Switch $jsonData.vipIndex
		Case 0 To 5
			$vipIndexInpPackage = $jsonData.vipIndex + 1
		Case 6 To 11
			$vipIndexInpPackage = $jsonData.vipIndex - 5
		Case 12 To 7
			$vipIndexInpPackage = $jsonData.vipIndex - 11
	EndSwitch
	Local $filterVip = $json.filter("$.packages["&$vipIndexInpPackage&"].id")
	If $filterVip = False Then
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,$CURRENT_STEP,"@error",'ErrorShow(16,"Không tìm thấy VIP ID")')
		$CURRENT_STEP += 1
		Return SetError(4)
	EndIf
	$dataPostingJson.post_data.vip.package.id = $filterVip.index(0)
	$dataPostingJson.post_data.vip.time = $jsonData.date
	Local $timeType = "day"
	Switch $jsonData.vipIndex
		Case 0 To 5
			$timeType = "day"
		Case 6 To 11
			$timeType = "week"
		Case 12 To 17
			$timeType = "month"
	EndSwitch
	$dataPostingJson.post_data.vip.time_type = $timeType
	Local $label
	Switch $jsonData.option1
		Case 1
			$label = 1
			$dataPostingJson.post_data.vip.label = $label
		Case Else
			$label = 0
			$dataPostingJson.post_data.vip.label = $label
	EndSwitch

	; Posting
	Local $rqPosting = _HttpRequest(2,"https://bds123.vn/api/create/post",_Utf8ToAnsi($dataPostingJson.toStr()))
	Local $decodeResponse = _HTMLDecode($rqPosting)
	Local $idPost = StringRegExp($decodeResponse,'thanh-toan-tin\/(\d+)"',1)
	If @error Then ; Đăng tin thất bại
		Local $errorMess = StringRegExp($decodeResponse,'message":"(.*?)"',1)
		If @error Then ; Không tìm thấy lỗi, show hết
			SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,"Result","@error",'_HttpRequest_Test("'&$decodeResponse&'")')
			Return SetError(5)
		Else
			SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,"Result","@error",'ErrorShow($CONSOLE_ERROR,"","'&$errorMess[0]&'")')
			Return SetError(6)
		EndIf
	Else ; Đăng tin thành công
		; Giờ thanh toán tin
		Local $dataPay = Bds123_Data_Pay($idPost[0],$filterVip.index(0),$jsonData.date,$timeType,$label)
		Local $rqPay = _HttpRequest(2,$BDS123_URL_PAY,$dataPay)
		Local $decodeRqPay = _HTMLDecode($rqPay)
		SaveLogPosting($CURRENT_POST_NAME,$BDS123_URL,"Result","@error",'_HttpRequest_Test("'&$decodeRqPay&'")')
	EndIf
EndFunc

Func Bds123_Upload($token,$arrayImage,$userID,$jsonPost)
	Local $header = Bds123_Header_Upload($token)
	For $i = 0 To UBound($arrayImage) - 1
		Local $data = Bds123_Data_Upload($userID,$arrayImage[$i])
		Local $rq = _HttpRequest(2,$BDS123_URL_UPLOAD,$data,'','',$header)
		Local $check = StringRegExp($rq,'success":true',0)
		Local $json = _HttpRequest_ParseJSON($rq)
		If $check = 1 And Not @error Then
			Local $jsonAdd = '{"id":'&$json.id&','
			$jsonAdd &= '"extension":"'&$json.extension&'",'
			$jsonAdd &= '"filename":"'&$json.filename&'",'
			$jsonAdd &= '"orginal_filename":"",'
			$jsonAdd &= '"width":'&$json.width&','
			$jsonAdd &= '"height":'&$json.height&','
			$jsonAdd &= '"size":'&$json.size&','
			$jsonAdd &= '"image_full_url":"'&$json.image_full_url&'",'
			$jsonAdd &= '"image_path":"'&$json.image_path&'"}'
			$jsonPost.set('post_data.images['&$i&']',$jsonAdd)
		EndIf
	Next
	Return $jsonPost
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Bds123_GetUploadToken
; Description ...: Tìm upload token từ trang Bds123.vn
; Syntax ........: Bds123_GetUploadToken()
; Return values .: Thành công - Token Upload
;                : Thất bại - @error = 1
; ===============================================================================================================================
Func Bds123_GetUploadToken()
	Write_Log("====================")
	Write_Log("+ Bds123_GetTokenUpload")
	Local $rq = _HttpRequest(2,$BDS123_URL_GET_UPLOAD_TOKEN)
	Local $arrayToken = StringRegExp($rq,'<meta name="_token" content="(.*?)">',1)
	If @error Then Return SetError(1)
	Return $arrayToken[0]
EndFunc

Func Bds123_Header_Upload($token)
	Local $header = 'authority: static123.com'
	$header &= '|path: /api/upload'
	$header &= '|scheme: https'
	$header &= '|origin: https://bds123.vn'
	$header &= '|referer: https://bds123.vn/'
	$header &= '|x-csrf-token:' & $token
	Return $header
EndFunc

Func Bds123_Data_Upload($userId,$imageDir)
	Local $arrayForm = [['user_id',$userId], _
	['source'		,'bds123.vn'], _
	['estate_type'	,'apartment'], _
	['source_url'	,'https://bds123.vn/dashboard/dang-tin'], _
	['from'			,'dangtin'], _
	['$file'		, $imageDir]]
	Return $arrayForm
EndFunc

Func Bds123_Data_Pay($postId,$vipId,$date,$dateType,$label)
	Return "action=re_pay&post_id="&$postId&"&package_id="&$vipId&"&total_day_vip="&$date & _
	"&package_type="&$dateType&"&label="&$label&"&total_time="&$date&"&payment_method=account"
EndFunc

Func Bds123_PostType_Name($postTypeIndex)
	Switch $postTypeIndex
		Case 1
			Return 'ban'
		Case Else
			Return 'thue'
	EndSwitch
EndFunc

Func Bds123_SearchUrlPost($arrayId)
	If IsArray($arrayId) = 0 Then
		Return "https://bds123.vn/dashboard/posts.html"
	EndIf
	Local $url = "https://bds123.vn/dashboard/posts.html"
	Local $rq = _HttpRequest(2,$url)
	Local $search = StringRegExp($rq,'href="(.*?'&$arrayId[0]&'.html)',3)
	If IsArray($search) = 1 Then
		Return $search[0]
	Else
		Return "https://bds123.vn/dashboard/posts.html"
	EndIf
EndFunc

Func Bds123_Posting_Send_Result($data)
	Local $mainThread = _CoProc_ParentPID()
	Local $result
	Local $posting = Bds123_Posting_Main($data)
	If @error Then
		$result = False
	Else
		$result = True
	EndIf
	For $i = 1 To 20
		_CoProc_Send($mainThread,$result & ":::" & $BDS123_URL & ":::" & @AutoItPID)
		Sleep(1000)
	Next
EndFunc