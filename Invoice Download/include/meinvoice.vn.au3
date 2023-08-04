Global $MEINVOICE_URL_SEARCH = "https://meinvoice.vn/tra-cuu/GetListEinvoiceByAccountObjectCode"

Func meInvoice_BillDownload($billNumber,$portName)
	Local $taxCode = meInvoice_TaxCode($portName)
	Local $data = meInvoice_CreateSearchData($taxCode,$billNumber)
	Local $rq = _HttpRequest(2,$MEINVOICE_URL_SEARCH,$data)
	Local $decode = _HTMLDecode($rq)
	Local $regEx = StringRegExp($decode,'TransactionID":"(.*?)"',3)
	If @error Then
		Return SetError(1,0,"Không tìm thấy hóa đơn")
	EndIf
	Local $urlDownload = meInvoice_UrlDownload($regEx[0])
	; Thiếu header không chạy
	Local $header = 'Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
	Local $rqDownload = _HttpRequest(3,$urlDownload,'','','',$header)
	Return $rqDownload
EndFunc

Func meInvoice_CreateSearchData($taxCode,$billNumber)
	Return "taxCode="&$taxCode&"&accountObjectCode="&$billNumber&"&skip=0&take=1000"
EndFunc

Func meInvoice_UrlDownload($code)
	Return "https://meinvoice.vn/tra-cuu/DownloadHandler.ashx?Type=pdf&Code=" & $code
EndFunc

Func meInvoice_TaxCode($portName)
	Switch $portName
		Case "Tiếp Vận Tâm Cảng Cát Lái"
			Return "0313611455"
		Case "Tâm Cảng Thủ Đức"
			Return "0304418649"
		Case "SINOVNL Cát Lái"
			Return "0314618728"
	EndSwitch
EndFunc