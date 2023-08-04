Func minvoice_DownloadInvoice($invoiceCode,$taxCode)
	Local $url = "https://tracuuhoadon.minvoice.com.vn/api/Search/SearchInvoice?masothue="&$taxCode&"&sobaomat="&$invoiceCode&"&type=PDF&inchuyendoi=false"
	Local $rq = _HttpRequest(3,$url)
	Return $rq
EndFunc