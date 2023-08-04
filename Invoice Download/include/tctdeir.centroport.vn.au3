Global $tctdeir_HOME = "https://tctdeir.centroport.vn/"
Global $tctdeir_HiddenValue[3] ; Phải tạo biến global vì function getcaptcha sẽ chạy trước r

Func CentroPort_ThuDuc_EirDownload($eirNumber,$captcha)
	Local $postData = FileRead($CentroPort_DataPosting_DIR)
	Local $replace = StringReplace($postData,"${VIEWSTATE}",$tctdeir_HiddenValue[0])
	Local $replace2 = StringReplace($replace,"${VIEWSTATEGENERATOR}",$tctdeir_HiddenValue[1])
	Local $replace3 = StringReplace($replace2,"${EVENTVALIDATION}",$tctdeir_HiddenValue[2])
	Local $replace4 = StringReplace($replace3,"${EIRNUMBER}",$eirNumber)
	Local $replace5 = StringReplace($replace4,"${CAPTCHA}",$captcha)
	Local $replace6 = StringReplace($replace5,@CRLF,"&")
	Local $rq = _HttpRequest(2,$tctdeir_HOME,_Data2SendEncode($replace6)) ; Phải endcode mới được
	Local $decode = _HTMLDecode($rq)
	Local $check = StringRegExp($decode,'btnDownLoad',0)
	If $check = 0 Then
		Local $alertText = StringRegExp($decode,'alert alert-warning">(.*?)</div>',3)
		If @error Then
			Return SetError(1,0,"Lỗi không xác định")
		EndIf
		Return SetError(2,0,$alertText[0])
	EndIf

	Local $checkCaptcha = StringRegExp($decode,"Mã xác thực không đúng...",0)
	If $checkCaptcha = 1 Then
		Return SetError(3,0,"Sai captcha")
	EndIf

	Local $aSearch = ["__VIEWSTATE","__VIEWSTATEGENERATOR","__EVENTVALIDATION"]
	Local $tctdeir_HiddenValue = searchHiddenValues($decode,$aSearch)
	If @error Then
		Return SetError(4,0,$tctdeir_HiddenValue)
	EndIf

	Local $postData = FileRead($CentroPort_DataPosting_DIR_2)
	Local $replace = StringReplace($postData,"${VIEWSTATE}",$tctdeir_HiddenValue[0])
	Local $replace2 = StringReplace($replace,"${VIEWSTATEGENERATOR}",$tctdeir_HiddenValue[1])
	Local $replace3 = StringReplace($replace2,"${EVENTVALIDATION}",$tctdeir_HiddenValue[2])
	Local $replace4 = StringReplace($replace3,"${EIRNUMBER}",$eirNumber)
	Local $replace5 = StringReplace($replace4,@CRLF,"&")
	Local $rqDownload = _HttpRequest(3,$tctdeir_HOME,_Data2SendEncode($replace5))
	Return $rqDownload
EndFunc