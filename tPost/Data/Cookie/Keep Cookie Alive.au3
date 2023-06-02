#include <_HttpRequest.au3>
#include <Date.au3>
Global Const $BDS_URL_CREATE_POST = 'https://sellernetapi.batdongsan.com.vn/api/ProductDraft/UpdateProductDraft'
Global Const $BDS_URL_UPDATE_POST = 'https://sellernetapi.batdongsan.com.vn/api/product/saveProduct'
_HttpRequest_CookieJarSet("cookie.txt")
Local $url = "https://batdongsan.com.vn/HandlerWeb/UserHandler.ashx?type=getuserid"
Local $privateToken = IniRead(@ScriptDir & "\cookie.txt","batdongsan.com.vn","privateToken","")
If $privateToken = "" Then
	ConsoleWrite("!@error PritvateToken is not found" & @CRLF)
	Exit
Else
	Local $accessToken = StringRegExp($privateToken,'access_token":"(.*?)"',1)
	If @error Then
		ConsoleWrite("!@error $accessToken is not found" & @CRLF)
		Exit
	Else
		Global $accessTokenEnd = $accessToken[0]
	EndIf
EndIf
If _Keep_AccessToken_Alive() = True Then
	Bds_Posting()
EndIf
;~ While _Keep_AccessToken_Alive() = True
;~ 	Sleep(60000)
;~ WEnd
Func _Keep_AccessToken_Alive()
	Local $rq = _HttpRequest(2,$url,'',-1)
	Local $userId = StringRegExp($rq,'userId":(\d+)',1)
	If @error Or $userId[0] = 0 Then
		Return False
	Else
		If AccountSetting_Bds_Login($accessTokenEnd) = True Then
			ConsoleWrite('"' & _NowTime(5) & '"' & @CRLF)
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc

; https://batdongsan.com.vn/HandlerWeb/UserHandler.ashx?type=RefreshToken

Func AccountSetting_Bds_Login($accessToken)
	ConsoleWrite("===============================================" & @CRLF)
	ConsoleWrite("+AccountSetting.au3" & @CRLF)
	ConsoleWrite("+ AccountSetting_Bds_Login" & @CRLF)
	If $accessToken <> "" Then
		Local $arrayInfor = AccountSetting_Bds_GetUserInfor_GET($accessToken)
		If $arrayInfor <> 0 Then
			Return True
		Else
			Return SetError(2)
		EndIf
	Else
		Return SetError(3)
	EndIf
EndFunc

Func AccountSetting_Bds_GetUserInfor_OPTIONS()
	ConsoleWrite("===============================================" & @CRLF)
	ConsoleWrite("+AccountSetting.au3" & @CRLF)
	ConsoleWrite("+ AccountSetting_Bds_GetUserInfor_OPTIONS" & @CRLF)
	Local $urlGetInfor = "https://sellernetapi.batdongsan.com.vn/api/user/fetchContact"
	Local $header = "authority: sellernetapi.batdongsan.com.vn"
	$header &= "|method: OPTIONS"
	$header &= "|path: /api/user/fetchContact"
	$header &= "|scheme: https"
	$header &= "|access-control-request-headers: access-control-allow-credentials,"
	$header &= "access-control-allow-headers,access-control-allow-methods,access-control-allow-origin,apiversion,auth,authorization,cache-control,sellernet-origin,uniqueid"
	$header &= "|access-control-request-method: GET"
	$header &= "|origin: https://batdongsan.com.vn"
	$header &= "|referer: https://batdongsan.com.vn/"
	Local $rqGetInfor = _HttpRequest(1,$urlGetInfor,'','','',$header,"OPTIONS")
EndFunc
Func AccountSetting_Bds_GetUserInfor_GET($accessToken)
	ConsoleWrite("===============================================" & @CRLF)
	ConsoleWrite("+AccountSetting.au3" & @CRLF)
	ConsoleWrite("+ AccountSetting_Bds_GetUserInfor_GET" & @CRLF)
	Local $urlGetInfor = "https://sellernetapi.batdongsan.com.vn/api/user/fetchContact"
	Local $header = "authority: sellernetapi.batdongsan.com.vn"
	$header &= "|path: /api/user/fetchContact"
	$header &= "|scheme: https"
	$header &= "|access-control-allow-credentials: true"
	$header &= "|access-control-allow-headers: Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers"
	$header &= "|access-control-allow-methods: GET,HEAD,OPTIONS,POST,PUT"
	$header &= "|access-control-allow-origin: *"
	$header &= "|apiversion: 2020-02-28 18:30"
	$header &= "|auth: 1"
	$header &= "|authorization: " & $accessToken
	$header &= "|cache-control: no-cache"
	$header &= "|origin: https://batdongsan.com.vn"
	$header &= "|referer: https://batdongsan.com.vn/"
	$header &= "|sellernet-origin: mobile"
	$header &= "|uniqueid: deviceidfromweb"
	Local $rqGetInfor = _HttpRequest(2,$urlGetInfor,'','','',$header,'GET')
	Local $check 	= StringRegExp($rqGetInfor,'"Success":true',0)
	Local $check2 	= StringRegExp($rqGetInfor,'ContactName":"(.*?)"',1)
	Local $check3 	= StringRegExp($rqGetInfor,'ContactMobile":"(.*?)"',1)
	Local $a_Infor[0]

	If $check == 1 And IsArray($check2) = 1 And IsArray($check3) = 1 Then
		_ArrayAdd($a_Infor,$check2[0])
		_ArrayAdd($a_Infor,$check3[0])
		Return $a_Infor
	Else
		Return 0
	EndIf
EndFunc

Func Bds_Posting()
	Local $url 	= $BDS_URL_CREATE_POST
	Local $data = '{"productType":49,"productId":null,"draftId":0,"categoryId":326,"projectId":2065,"title":"Căn hộ the sun avenue 56m 1pn full lung linh","address":"Dự án The Sun Avenue,  Quận 2, Hồ Chí Minh","descContent":"Cần cho thuê căn hộ The Sun Avenue 1 phòng ngủ, full nội thất đẹp, 14tr/tháng.\n\n- Địa chỉ: 28 Mai Chí Thọ, Phường An Phú, Quận 2\n\n- Diện tích: 56m2\n\n- 1 phòng ngủ, 1WC.\n\n- Nhà full nội thất đẹp, đầy đủ tiện nghi.\n\n+ View trực diện Landmark 81, từ phòng khách có thể ngắm pháo bông thoải mái, mỗi tầng chỉ có 1 căn view này.\n\n+ Máy lạnh Panasonic Inverter, bếp từ & hồng ngoại, máy hút nhập khẩu từ Đức, tủ lạnh Sharp 428L, máy giặt Panasonic, giường, tủ quần áo, bàn ăn, sofa...\n\n+ Tiện ích: Gym, hồ bơi, BBQ, công viên, sân chơi cho trẻ (free), hầm giữ xe rộng rãi...\n\n- Giá thuê: 14 triệu/tháng.\n\nLiên hệ NGAY ( tư vấn hỗ trợ nhiệt tình vui vẻ )","cityCode":"SG","districtId":54,"streetId":4163,"wardId":118,"acreage":56,"wayInWidth":null,"bedroomCount":0,"price":0.00014,"unitPrice":1,"facadeWidth":null,"houseDirection":null,"startDate":"2023-01-01","endDate":"2023-01-11","viptype":5,"isAddOn":false,"isReceiEmail":false,"discount":0,"addDay":0,"furniture":null,"legality":null,"toiletCount":0,"floorCount":null,"balconyDirection":null,"promotionId":0,"promotionType":0,"transAccountId":0,"promotionChecksum":"","fileIds":"[]","contactAddress":"Quận 2, Hồ Chí Minh, Việt Nam","contactMobile":"0843524010","contactName":"Trần Hùng","contactPhone":null,"contactEmail":"idontknow94615321@gmail.com","latitude":10.788448,"longtitude":106.75197,"videoUrl":null,"period":-1,"autoRenewConfigUpdateModel":{"totalCount":1,"actionType":0}}'
	Local $header = Bds_Header_Create_Post($accessTokenEnd)
	Local $rq 	= _HttpRequest(2,$url,_Utf8ToAnsi($data),-1,'',$header)
	_HttpRequest_Test($rq)
EndFunc

Func Bds_Header_Create_Post($accessToken)
	Local $header = "authority: sellernetapi.batdongsan.com.vn"
	$header &= "|method: POST"
	$header &= "|path: /api/ProductDraft/UpdateProductDraft"
	$header &= "|scheme: https"
	$header &= "|access-control-allow-credentials: true"
	$header &= "|access-control-allow-headers: Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers"
	$header &= "|access-control-allow-methods: GET,HEAD,OPTIONS,POST,PUT"
	$header &= "|access-control-allow-origin: *"
	$header &= "|apiversion: 2020-02-28 18:30"
	$header &= "|auth: 1"
	$header &= "|authorization: " & $accessToken
	$header &= "|origin: https://batdongsan.com.vn"
	$header &= "|referer: https://batdongsan.com.vn/"
	$header &= '|sec-ch-ua: "Microsoft Edge";v="107", "Chromium";v="107", "Not=A?Brand";v="24"'
	$header &= '|sec-ch-ua-mobile: ?0'
	$header &= '|sec-ch-ua-platform: "Windows"'
	$header &= '|sec-fetch-dest: empty'
	$header &= '|sec-fetch-mode: cors'
	$header &= '|sec-fetch-site: same-site'
	$header &= '|sellernet-origin: tablet'
	$header &= '|uniqueid: deviceidfromweb'
	Return $header
EndFunc