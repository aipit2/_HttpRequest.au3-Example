Global Const $5deir_HOME = "https://5deir.centroport.com.vn/"
Global $5deir_HiddenValue[3]

Func CentroPort_CatLai_EirDownload($eirNumber,$captcha)
	Local $postData = FileRead($CentroPort_DataPosting_DIR)
	Local $replace = StringReplace($postData,"${VIEWSTATE}",$5deir_HiddenValue[0])
	Local $replace2 = StringReplace($replace,"${VIEWSTATEGENERATOR}",$5deir_HiddenValue[1])
	Local $replace3 = StringReplace($replace2,"${EVENTVALIDATION}",$5deir_HiddenValue[2])
	Local $replace4 = StringReplace($replace3,"${EIRNUMBER}",$eirNumber)
	Local $replace5 = StringReplace($replace4,"${CAPTCHA}",$captcha)
	Local $replace6 = StringReplace($replace5,@CRLF,"&")
	Local $rq2 = _HttpRequest(2,$5deir_HOME,_Data2SendEncode($replace6)) ; Phải endcode mới được
	Local $decode = _HTMLDecode($rq2)
	Local $check = StringRegExp($decode,'btnDownLoad',0)
	If $check = 0 Then
		Local $alertText = StringRegExp($decode,'alert alert-warning">(.*?)</div>',3)
		If @error Then
			Return SetError(1,0,"Lỗi không xác định")
		EndIf
		Return SetError(2,0,$alertText[0])
	EndIf

	Local $checkCaptcha = StringRegExp($rq2,"Mã xác thực không đúng...",0)
	If $checkCaptcha = 1 Then
		Return SetError(3,0,"Sai captcha")
	EndIf

	Local $aSearch = ["__VIEWSTATE","__VIEWSTATEGENERATOR","__EVENTVALIDATION"]
	Local $5deir_HiddenValue = searchHiddenValues($decode,$aSearch)
	If @error Then
		Return SetError(4,0,$5deir_HiddenValue)
	EndIf

	Local $postData = FileRead($CentroPort_DataPosting_DIR_2)
	Local $replace = StringReplace($postData,"${VIEWSTATE}",$5deir_HiddenValue[0])
	Local $replace2 = StringReplace($replace,"${VIEWSTATEGENERATOR}",$5deir_HiddenValue[1])
	Local $replace3 = StringReplace($replace2,"${EVENTVALIDATION}",$5deir_HiddenValue[2])
	Local $replace4 = StringReplace($replace3,"${EIRNUMBER}",$eirNumber)
	Local $replace5 = StringReplace($replace4,@CRLF,"&")
	Local $rq2 = _HttpRequest(3,$5deir_HOME,_Data2SendEncode($replace5))
	Return $rq2
EndFunc

;~ Func CentroPort_CatLai_SolveCaptcha($base64)
;~ 	Local $hSession = Tess_NewSession()
;~ 	If @error Then
;~ 		Return SetError(1)
;~ 	EndIf
;~ 	Tess_SetVar($hSession, $TESSVAR_ONLYRETURN_NUMBER, 1)
;~ 	Local $ret = StringLeft(Tess_Recognize($hSession,$base64,3,3),4)
;~ 	Tess_ClearSession($hSession)
;~ 	Return $ret
;~ EndFunc