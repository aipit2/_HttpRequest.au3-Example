Func vnptGetCaptcha($siteName)
	ConsoleWrite("Func: vnptGetCaptcha" & @CRLF)
	Local $urlCaptcha = checkProtocol($siteName & "/Captcha/Show")
	Local $rq = _HttpRequest(3,$urlCaptcha)
	_HttpRequest_Test($rq,$DATA_DIR & "\captcha.png",Default,False)
	png2bmp($DATA_DIR & "\captcha.png",$DATA_DIR & "\captcha.bmp")
	Return True
EndFunc

Func vnptDownloadInvoice($invoiceCode,$captcha,$site)
	Local $url = $site & "/HomeNoLogin/SearchByFkey"
	Local $urlDownloadInvoice = checkProtocol($url)
	Local $token = vnptGetToken($urlDownloadInvoice)
	If @error Then
		Return SetError(1,0,"Không tìm thấy token")
	EndIf

	Local $data = [["__RequestVerificationToken", $token], _
	["isHomepage", "true"], _
	["strFkey", $invoiceCode], _
	["captch", $captcha], _
	["submit", ""]]

	Local $rq = _HttpRequest(2,$urlDownloadInvoice,$data)
	Local $regExLinkDownload = StringRegExp($rq,'file pdf" href="(.*?)"',3)
	If @error Then
		Return SetError(2,0,"Không tìm thấy link Download")
	EndIf

	Local $mainUrl = StringRegExp($urlDownloadInvoice,'(https?://[^/]+)',3)
	If @error Then
		Return SetError(3,0,"Không thể tách main URL")
	EndIf
	Local $linkDownload = $mainUrl[0] & $regExLinkDownload[0]
	Local $rqDownload = _HttpRequest(3,$linkDownload)
	Return $rqDownload
EndFunc

Func vnptGetToken($url)
	Local $rq = _HttpRequest(2,$url)
	Local $regEx = StringRegExp($rq,'__RequestVerificationToken" type="hidden" value="(.*?)"',3)
	If @error Then
		Return SetError(1)
	EndIf
	Return $regEx[0]
EndFunc
