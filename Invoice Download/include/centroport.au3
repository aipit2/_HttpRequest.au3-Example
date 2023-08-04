Global Const $CentroPort_DataPosting_DIR = $DATA_DIR & "\5deir.centroport.com.vn\DATA POSTING.data"
Global Const $CentroPort_DataPosting_DIR_2 = $DATA_DIR & "\5deir.centroport.com.vn\DATA POSTING 2.data"

Func CentroPort_GetCaptcha($url)
	Local $rq = _HttpRequest(2,$url)
	Local $regExCaptcha = StringRegExp($rq,'Captcha image" src="data:image/png;base64.(.*?)"',3)
	If @error Then
		Return SetError(1,0,"Không tìm thấy Captcha")
	Else
		Local $data =  _B64Decode($regExCaptcha[0])
		_HttpRequest_Test($data,$CAPTCHA_DIR,Default,False)
	EndIf

	Local $aSearch = ["__VIEWSTATE","__VIEWSTATEGENERATOR","__EVENTVALIDATION"]
	Local $aHiddenValues = searchHiddenValues($rq,$aSearch)
	If @error Then
		Return SetError(2,0,$aHiddenValues)
	EndIf

	Return $aHiddenValues
EndFunc

