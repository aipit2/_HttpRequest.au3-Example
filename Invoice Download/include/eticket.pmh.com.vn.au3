Func pmh_TicketDownload($maTraCuu,$captcha)
	ConsoleWrite("Func: pmh_TicketDownload" & @CRLF)
	Local $url = "https://eticket.pmh.com.vn:8088/vepmh_ssl/tracuuhoadon.html?ma_bi_mat="&$maTraCuu&"&captcha="&$captcha
	Local $rq = _HttpRequest(2,$url)
	Local $regEx = StringRegExp($rq,'getpdf" idrd="(\d+)"',3)
	If @error Then
		Return SetError(1,0,"Không tìm thấy vé")
	EndIf

	Local $id = $regEx[0]
	Local $urlDownload = "https://eticket.pmh.com.vn:8088/vepmh_ssl/tracuuhoadon/getPdfZip.html"
	Local $data = "id="&$id&"&type=PDF"
	Local $rqDownload = _HttpRequest(2,$urlDownload,$data)
	Local $regExBase64 = StringRegExp($rqDownload,'pdf;base64.(.*?)"',3)
	If @error Then
		Return SetError(2,0,"Gặp lỗi khi tải vé")
	EndIf
	Local $decode = _B64Decode($regExBase64[0])
	Return $decode
EndFunc

Func pmh_getCaptcha()
	ConsoleWrite("Func: pmh_getCaptcha" & @CRLF)
	Local $url = "https://eticket.pmh.com.vn:8088/vepmh_ssl/tracuuhoadon/refresh"
	Local $rq = _HttpRequest(2,$url)
	Local $regEx = StringRegExp($rq,'<img \s+src="(.*?)"',3)
	If @error Then
		Return SetError(1,0,"Không tìm thấy captcha")
	EndIf
	Local $rqDownloadCaptcha = _HttpRequest(3,$regEx[0])
	_HttpRequest_Test($rqDownloadCaptcha,$CAPTCHA_DIR,Default,False)
EndFunc