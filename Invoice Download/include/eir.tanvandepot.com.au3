Func Eir_TanVanDepot($eirCode,$containerCode)
	Local $url = "http://eir.tanvandepot.com/Home/SearchEir?SearchCntrno=" & $containerCode & "&SearchCode=" & $eirCode
	Local $rq = _HttpRequest(2,$url)
	Local $arrayLink = StringRegExp($rq,'<a href="(.*?)">DownLoad',3)
	If @error Then
		Return SetError(1,0,"Không tìm thấy hóa đơn")
	EndIf

	Local $url2 = "http://eir.tanvandepot.com" & $arrayLink[0]
	Local $rq2 = _HttpRequest(3,$url2)
	Return $rq2
EndFunc