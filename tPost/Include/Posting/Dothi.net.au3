Func Dothi_Posting_Main($jsonData)
	Write_Log("====================")
	Write_Log("+ Dothi_Posting_Main")
	Local $siteName = "Dothi.net"
	;~ 	Login
	Local $login = AccountSetting_Dothi_Login('','',False)
	If $login = False Then
		SaveLogPosting(False,$siteName,$DOTHI_URL,"Đăng nhập thất bại","MESSAGE")
		Return SetError(1)
	EndIf
	; Get Token Upload
	Local $arrayToken = Dothi_GetTokenUpload()
	If @error Then
		SaveLogPosting(False,$siteName,$DOTHI_URL,"Không tìm thấy token upload #" & @error,"MESSAGE")
		Return SetError(2)
	EndIf
	Local $tokenUpload = $arrayToken[0]
	; Upload
	Local $arrayImage = StringSplit($jsonData.image,"|",2)
	Local $arrayImageUploaded = Dothi_Upload($arrayImage,$tokenUpload,0) ;  Cần chỉnh lại phần này cho người dùng đăng tin vip
	; Add Value
	Local $priceEnd
	Switch $jsonData.priceType
		Case 0,1
			$priceEnd = 0
		Case Else
			$priceEnd = $__g_a_Dothi_Price[$jsonData.priceType][$jsonData.postTypeIndex - 1] * $jsonData.price
	EndSwitch

	Local $vipType = $__g_a_Dothi_VipId[$jsonData.vipIndex]

	Local $name 	= RegRead($REG_ACCOUNT & $siteName,"name")
	Local $phone 	= RegRead($REG_ACCOUNT & $siteName,"phone")

	Local $highlight
	If $jsonData.option1 = 1 Then
		$highlight = 1
	Else
		$highlight = 0
	EndIf
	Local $dateCalculator = AddDate($jsonData.dateVip,"dd/mm/yyyy")
	Local $FormPosting = [["__EVENTTARGET","ctl00$ContentPlaceHolder1$ctl00$lbtPost"]]
	_ArrayAdd($FormPosting,'__EVENTARGUMENT|')
	_ArrayAdd($FormPosting,'__VIEWSTATE|' & $arrayToken[1])
	_ArrayAdd($FormPosting,'__VIEWSTATEGENERATOR|' & $arrayToken[2])
	_ArrayAdd($FormPosting,'__EVENTVALIDATION|' & $arrayToken[3])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$BoxMenu1$hdUserType|' & 0)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddCanBan|' & $__g_a_Dothi_PostTypeId[$jsonData.postTypeIndex])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboCateP|' & $__g_a_Dothi_EstateTypeId[$jsonData.estateTypeIndex][$jsonData.postTypeIndex])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboCityP|' & $jsonData.cityID)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboDistP|' & $jsonData.districtID)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboWardP|' & $jsonData.wardID)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddWardPrefix|')
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboStreetP|' & $jsonData.streetID)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddStreetPrefix|')
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboProjectP|' & $jsonData.projectID)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtGia|' & $priceEnd)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboPriceP|' & $__g_a_Dothi_PriceId[$jsonData.priceType][$jsonData.postTypeIndex - 1])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtDientich|' & $jsonData.acr)
	_ArrayAdd($FormPosting,'~ctl00$ContentPlaceHolder1$ctl00$hddDiadiem|' & $jsonData.address)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtSophong|' & $jsonData.room)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddcboDirectionP|-1')
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtSotoilet|' & $jsonData.wc)
	_ArrayAdd($FormPosting,'~ctl00$ContentPlaceHolder1$ctl00$txtTieude|' & $jsonData.title)
	_ArrayAdd($FormPosting,'~ctl00$ContentPlaceHolder1$ctl00$tarNoidung|' & $jsonData.content,0,"|","@CRLF")
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$BDSGuestUploadNonFlash|' & _ArrayToString($arrayImageUploaded,","))
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtSotang|')
	_ArrayAdd($FormPosting,'~ctl00$ContentPlaceHolder1$ctl00$txtHovaten|' & $name)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtDidong|' & $phone)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddVipType|' & $vipType)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtTungay|' & $dateCalculator[0])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtDenngay|' & $dateCalculator[1])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hdDenNgayBan|' & $arrayToken[4])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hdDenNgayThue|' & $arrayToken[5])
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddPaymentBalanceMethod|' & 1)
	If $jsonData.option2 = 1 Then
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$ckbAutoUpNews|' & "on")
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddAutoUpNews|' & "true")
	Else
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddAutoUpNews|' & "false")
	EndIf
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddAutoReNews|' & "false")
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddHighlight|' & $highlight)
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtMattien|')
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$txtDuongtruocnha|')
	_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddAutoAction|1')
	; Dành cho người dùng đã đăng kí gói tin miễn phí tháng
	If $jsonData.vipIndex = 1 Then
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddRegisterProductFree|1')
		_ArrayAdd($FormPosting,'bundles|19')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddSelectedBundles|')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddSelectedPromotion|19')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddSelectedPromotionId|49')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddCusPhone|')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddDiscount|0')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddIsCanRedeemPoints|0')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddPointType|0')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddPointStatus|0')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddQuantity|0')
		_ArrayAdd($FormPosting,'ctl00$ContentPlaceHolder1$ctl00$hddOrderOfPayment|')
	EndIf

	Local $responsePosting = _HttpRequest(2,$DOTHI_URL_POSTING,$FormPosting)
	Local $isSuccess = Dothi_CheckPosting($responsePosting)
	If $isSuccess = True Then
		Local $urlResult = Dothi_GetResultUrl($responsePosting)
		SaveLogPosting(True,$siteName,"Đăng tin thành công",$urlResult,"URL")
		Return True
	Else
		Local $errorPosting = Dothi_GetErrorPosting($responsePosting)
		If $errorPosting = "Lỗi chưa xác định" Then
			SaveLogPosting(False,$siteName,$FormPosting,$responsePosting,"HTML")
		Else
			SaveLogPosting(False,$siteName,$DOTHI_URL,$errorPosting,"MESSAGE")
		EndIf
		Return False
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Dothi_GetTokenUpload
; Description ...:
; Syntax ........: Dothi_GetTokenUpload()
; Parameters ....: None
; Return values .: $arrayRerult - Success
;                : @error - Failure
; ===============================================================================================================================
Func Dothi_GetTokenUpload()
	Local $getTokenUpload = _HttpRequest(2,"https://dothi.net/thanh-vien/dang-tin-ban-cho-thue-nha-dat.htm")
	Local $Token = StringRegExp($getTokenUpload,"wvtupload\(\{ token: '(.*?)'",1)
	If @error Then Return SetError(1)
	Local $viewState = StringRegExp($getTokenUpload,'__VIEWSTATE" value="(.*?)"',1)
	If @error Then Return SetError(2)
	Local $viewStateGenerator = StringRegExp($getTokenUpload,'__VIEWSTATEGENERATOR" value="(.*?)"',1)
	If @error Then Return SetError(3)
	Local $evenValidation = StringRegExp($getTokenUpload,'__EVENTVALIDATION" value="(.*?)"',1)
	If @error Then Return SetError(4)
	Local $denNgayBan = StringRegExp($getTokenUpload,'hdDenNgayBan" value="(.*?)"',1)
	If @error Then Return SetError(5)
	Local $denNgayThue = StringRegExp($getTokenUpload,'hdDenNgayThue" value="(.*?)"',1)
	If @error Then Return SetError(6)
	Local $arrayResult = [$Token[0],$viewState[0],$viewStateGenerator[0],$evenValidation[0],$denNgayBan[0],$denNgayThue[0]]
	Return $arrayResult
EndFunc

Func Dothi_Upload($arrayImage,$tokenUpload,$vipIndex = 0)
	Local $arrayImageUploaded[0]
	Local $urlUploadDothi = 'https://upload.dothi.net/UploadHandler.php'
	For $i = 0 To UBound($arrayImage) - 1
		Switch $vipIndex
			Case 0
				If $i >= 8 Then
					ExitLoop
				EndIf
			Case Else
				If $i >= 16 Then
					ExitLoop
				EndIf
		EndSwitch
		Local $FormUpload = [["id","TTR"], _
			['$fileToUpload', $arrayImage[$i]], _
			['UploadType'	, 'upload'], _
			['project'		, 'dothidiaoc'], _
			['StringDecypt'	, $tokenUpload], _
			['submit'		, 'Upload Image']]
		Local $rqUpload = _HttpRequest(2,$urlUploadDothi,$FormUpload)
		If StringRegExp($rqUpload,"OK",0) = 1 Then
			Local $Link = _HttpRequest_ParseJSON($rqUpload)
			Local $Linkcuoi = $Link.OK
			_ArrayAdd($arrayImageUploaded,$Linkcuoi)
		EndIf
	Next
	Return $arrayImageUploaded
EndFunc

Func Dothi_CheckPosting($response)
	Local $isSuccess = StringRegExp($response,'dang\-tin\-thanh\-cong\.htm',0)
	If $isSuccess = 1 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func Dothi_GetResultUrl($response)
	Local $arrayUrl = StringRegExp($response, 'Link xem tin</div>\s+<div class="column2">\s+<a target="_blank" class="text-blue" href="(.*?)"', 3)
	If IsArray($arrayUrl) = 1 Then
		Return "https://dothi.net" & $arrayUrl[0]
	Else
		Return "https://dothi.net/thanh-vien/quan-ly-tin-rao.htm"
	EndIf
EndFunc

Func Dothi_GetErrorPosting($response)
	Local $arrayError = StringRegExp($response,"<script>alert\('(.*?)'\)<\/script>",3)
	If IsArray($arrayError) = 1 Then
		Return $arrayError[0]
	Else
		Return "Lỗi chưa xác định"
	EndIf
EndFunc