Global Const $EHOADON_HOME = "https://van.ehoadon.vn/TCHD"
Global Const $EHOADON_POST_DATA_DIR = $DATA_DIR & "/ehoadon.vn/DATA POSTING.data"
Func ehoadon_DownloadInvoice($invoiceCode)
	; Tìm hidden values
	Local $rq = _HttpRequest(2,$EHOADON_HOME)
	Local $aSearch = ["__VIEWSTATE","__VIEWSTATEGENERATOR"]
	Local $aHidden = searchHiddenValues($rq,$aSearch)
	If @error Then
		Return SetError(1,0,$aHidden)
	EndIf

	Local $readFile = FileRead($EHOADON_POST_DATA_DIR)
	Local $replace = StringReplace($readFile,"{$VIEWSTATE}",$aHidden[0])
	Local $replace2 = StringReplace($replace,"{$VIEWSTATEGENERATOR}",$aHidden[1])
	Local $replace3 = StringReplace($replace2,"{$INVOICECODE}",$invoiceCode)
	Local $data = StringReplace($replace3,@CRLF,"&")
	Local $rq2 = _HttpRequest(2,$EHOADON_HOME,_Data2SendEncode($data))
	Local $regEx3 = StringRegExp($rq2,"ViewInvoice\('(.*?)'\)",3)
	If @error Then
		Return SetError(2,0,"Không tìm thấy hóa đơn")
	EndIf

	Local $url2 = "https://van.ehoadon.vn/Lookup?InvoiceGUID=" & $regEx3[0]
	Local $rq3 = _HttpRequest(2,$url2)
	Local $decode = _HTMLDecode($rq3)
	Local $regEx3 = StringRegExp($decode,'LinkDownPDF" onclick="DownloadFile\(' & "'(.*?)'",3)
	If @error Then
		Return SetError(3,0,"Gặp lỗi khi tải hóa đơn")
	EndIf

	Local $url3 = "https://van.ehoadon.vn/DownloadFile?FilePath=" & $regEx3[0] & "&BFType=1"
	Local $rq4 = _HttpRequest(3,$url3)
	Return $rq4
EndFunc