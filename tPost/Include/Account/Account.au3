Func AccountSetting_GUI()
	Write_Log("=====================")
	Write_Log("+ OpenGUIAccount")
	Local $style = BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_THICKFRAME)
	Global $__g_h_AccountSettingGUI = GUICreate("Cài đặt tài khoản", 621, 400, -1, -1, $style)
	Global $__g_idDummyStartControlAccount = GUICtrlCreateDummy()
	Global $__g_idList_AccountSetting_Web = GUICtrlCreateList("", 32, 24, 257, 292)
	Local $idLabel_Taikhoan = GUICtrlCreateLabel("Tài khoản", 328, 24, 73, 24)
	Global $__g_idInput_Taikhoan = GUICtrlCreateInput("", 424, 24, 153, 21)
	Local $idLabel_Matkhau = GUICtrlCreateLabel("Mật khẩu", 328, 64, 70, 24)
	Global $__g_idInput_Matkhau = GUICtrlCreateInput("", 424, 64, 153, 21,$ES_PASSWORD + $ES_AUTOHSCROLL)
	Local $idLabel_Cookie = GUICtrlCreateLabel("Cookie", 328, 102, 53, 50)
	Global $__g_idEdit_Cookie = GUICtrlCreateEdit("", 424, 104, 153, 100)
	Local $idButton_ImportFromFile = GUICtrlCreateButton("Thêm từ file", __Center(3,621,147)[1], 340, 147, 33)
	Local $idButton_Import = GUICtrlCreateButton("Tự động thêm", __Center(3,621,147)[2], 340, 147, 33)
	Local $idButton_Login = GUICtrlCreateButton("Đăng nhập", __Center(3,621,147)[3], 340, 147, 33,$BS_DEFPUSHBUTTON)
	Global $__g_idDummyLastControlAccount = GUICtrlCreateDummy()

	Local $aGUI_Size = WinGetClientSize($__g_h_AccountSettingGUI)
	Local $iFontSize = Int(2 * (.25 + (12 * $aGUI_Size[0] / 621))) / 2
	; Reset font size for all controls on main GUI
	For $i = $__g_idDummyStartControlAccount To $__g_idDummyLastControlAccount
		GUICtrlSetFont($i, $iFontSize)
	Next
	AccountSetting_LoadWeb()
	GUICtrlSetResizing($__g_h_AccountSettingGUI,$GUI_DOCKAUTO)
	GUISetBkColor($COLOR_BLUE,$__g_h_AccountSettingGUI)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE,"AccountSetting_GUI_Exit")
	GUICtrlSetOnEvent($__g_idList_AccountSetting_Web,"AccountSetting_ChangeSite")
	GUICtrlSetOnEvent($idButton_Login,"AccountSetting_CheckLogin")
	_CoProc_Resume($pIdServer)
EndFunc

Func AccountSetting_CheckLogin() ; Cập nhật 8/3/2022
	Write_Log("===============================================")
	Write_Log("+AccountSetting_CheckLogin")
	Local $acc = GUICtrlRead($__g_idInput_Taikhoan)
	Local $pass = GUICtrlRead($__g_idInput_Matkhau)
	Local $cookie = GUICtrlRead($__g_idEdit_Cookie)
	Local $currentSite = GUICtrlRead($__g_idList_AccountSetting_Web)
	_HttpRequest_SessionSet(99)
	GUISetCursor(15,1) ; Wait Cursor
	Switch $currentSite
		Case "Batdongsan.com.vn"
			Local $arrayInfor = AccountSetting_Bds_Login_3($acc,$pass)
			If @error Then
				Local $arrayInfor = AccountSetting_Bds_Login_2($cookie)
				If @error Then
					ErrorShow(16,$BDS_URL,"Đăng nhập thất bại")
				Else
					RegWrite($BDS_REG_ACCOUNT,'name','REG_SZ',$arrayInfor[0])
					RegWrite($BDS_REG_ACCOUNT,'phone','REG_SZ',$arrayInfor[1])
					RegWrite($BDS_REG_ACCOUNT,'cookie','REG_SZ',$cookie)
					ErrorShow(64,$BDS_URL,"Đăng nhập thành công")
				EndIf
			Else
				RegWrite($BDS_REG_ACCOUNT,'name','REG_SZ',$arrayInfor[0])
				RegWrite($BDS_REG_ACCOUNT,'phone','REG_SZ',$arrayInfor[1])
				RegWrite($BDS_REG_ACCOUNT,'cookie','REG_SZ',$cookie)
				ErrorShow(64,$BDS_URL,"Đăng nhập thành công")
			EndIf
		Case "Muaban.net"
			AccountSetting_Muaban_Login($cookie,True)
		Case "Bds123.vn"
			AccountSetting_Bds123_Login($acc,$pass,True)
		Case "Dothi.net"
			AccountSetting_Dothi_Login($acc,$pass,True)
;~ 		Case "Alonhadat.com.vn"
;~ 			AccountSetting_Alonhadat_Login($acc,$pass)
;~ 		Case "i-batdongsan.com"
;~ 			AccountSetting_Ibatdongsan_Login($acc,$pass)
;~ 		Case "123nhadatviet.com"
;~ 			AccountSetting_123nhadatvietcom_Login($acc,$pass)
;~ 		Case "123nhadatviet.net"
;~ 			AccountSetting_123nhadatvietnet_Login($acc,$pass)
;~ 		Case "i-nhadat.com"
;~ 			AccountSetting_inhadat_Login($acc,$pass)
;~ 		Case "Dotproperty.com.vn"
;~ 			AccountSetting_dotproperty_Login($acc,$pass)
;~ 		Case "Nhadatviet247.net"
;~ 			AccountSetting_nhadatviet247_Login($acc,$pass)
;~ 		Case "Batdongsan24h.com.vn"
;~ 			AccountSetting_Batdongsan24h_Login($acc,$pass)
;~ 		Case "Timmuanhadat.com.vn"
;~ 			AccountSetting_Timmuanhadat_Login($acc,$pass)
;~ 		Case "Sosanhnha.com"
;~ 			AccountSetting_Sosanhnha_Login($cookie)
;~ 		Case "Batdongsan.vn"
;~ 			AccountSetting_Batdongsanvn_New($acc,$pass)
;~ 		Case "Tinbatdongsan.com"
;~ 			AccountSetting_Tinbatdongsan($acc,$pass)
		Case $CHOTOT_URL
			AccountSetting_Chotot_Login($acc,$pass,True)
		Case $THUECANHO123_URL
			AccountSetting_Thuecanho123_Login($acc,$pass,True)
		Case $HOMEDY_URL
			AccountSetting_Homdy_Login($acc,$pass,True)
		Case Else
			ErrorShow(48,'',"Trang web bạn chọn chưa được hỗ trợ")
			Return 0
	EndSwitch
	GUISetCursor(2,1) ; Normal Cursor
	_HttpRequest_SessionClear(99)
	_HttpRequest_SessionSet(0)
EndFunc

Func AccountSetting_GUI_Exit()
	_CoProc_Suspend($pIdServer)
	GUIDelete($__g_h_AccountSettingGUI)
EndFunc

Func AccountSetting_LoadWeb()
	Write_Log("=====================")
	Write_Log("+ AccountSetting_LoadWeb")
	Local $currentList = GUICtrlRead($__g_idCombo_ChooseWeb_ListName)
	If $currentList = "" Then
		GUICtrlSetData($__g_idList_AccountSetting_Web,"|" & _ArrayToString($WEB_LIMIT,"|",-1,-1,"|",0,0))
	Else
		Local $arraySite = StringSplit(RegRead($REG_SITELIST,_StringToBase64($currentList)),"|",2)
		If IsArray($arraySite) = 0 Then
			GUICtrlSetData($__g_idList_AccountSetting_Web,"|" & _ArrayToString($WEB_LIMIT,"|",-1,-1,"|",0,0))
		Else
			GUICtrlSetData($__g_idList_AccountSetting_Web,"|" & _ArrayToString($arraySite))
		EndIf
	EndIf
EndFunc

Func AccountSetting_ChangeSite()
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_ChangeSite")
	Local $currentSite = GUICtrlRead($__g_idList_AccountSetting_Web)
	Write_Log("Trang đã chọn: " & $currentSite)
	If $currentSite = "" Then
		Return SetError(1)
	EndIf
	Local $user = RegRead($REG_ACCOUNT & $currentSite,"user")
	Local $pass = RegRead($REG_ACCOUNT & $currentSite,"pass")
	Local $cookie = RegRead($REG_ACCOUNT & $currentSite,"cookie")
	GUICtrlSetData($__g_idInput_Taikhoan,$user)
	GUICtrlSetData($__g_idInput_Matkhau,$pass)
	GUICtrlSetData($__g_idEdit_Cookie,$cookie)

	Switch $currentSite
		Case "Muaban.net","Sosanhnha.com"
			GUICtrlSetState($__g_idInput_Taikhoan,128)
			GUICtrlSetState($__g_idInput_Matkhau,128)
			GUICtrlSetState($__g_idEdit_Cookie,64) ; Enable
		Case "Batdongsan.com.vn"
			GUICtrlSetState($__g_idInput_Taikhoan,64)
			GUICtrlSetState($__g_idInput_Matkhau,64)
			GUICtrlSetState($__g_idEdit_Cookie,64) ; Enable
			If $user = "" Then
				GUICtrlSetData($__g_idInput_Taikhoan,RegRead($BDS_REG_ACCOUNT,"phone"))
			EndIf
		Case Else
			GUICtrlSetState($__g_idInput_Taikhoan,64)
			GUICtrlSetState($__g_idInput_Matkhau,64)
			GUICtrlSetState($__g_idEdit_Cookie,128) ; Disable
	EndSwitch
EndFunc

Func AccountSetting_Bds_Login_Old($user = "",$pass = "",$alert = False)
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_Bds_Login_Old")
	If $user = "" Then
		$user = RegRead($BDS_REG_ACCOUNT,"user")
		If $user = "" Then
			If $alert = True Then
				ErrorShow($CONSOLE_ERROR,$BDS_URL,"Xin vui lòng đăng nhập trước")
			EndIf
			Return SetError(1)
		EndIf
	EndIf

	If $pass = "" Then
		$pass = RegRead($BDS_REG_ACCOUNT,"pass")
		If $pass = "" Then
			If $alert = True Then
				ErrorShow($CONSOLE_ERROR,$BDS_URL,"Xin vui lòng đăng nhập trước")
			EndIf
			Return SetError(2)
		EndIf
	EndIf

	Local $data = '{"input":"'&$user&'","password":"'&$pass&'","isRemember":1}'
	Local $rq = _HttpRequest(2,$BDS_URL_LOGIN,_Utf8ToAnsi($data))
	Local $arrayAccessToken = StringRegExp($rq,'access_token":"(.*?)"',1)
	If @error Then
		If $alert = True Then
			ErrorShow($CONSOLE_ERROR,$BDS_URL,"Đăng nhập thất bại\nXin vui lòng kiểm tra lại thông tin")
		EndIf
		Return SetError(3)
	EndIf
	AccountSetting_Bds_GetUserInfor_OPTIONS()
	Local $arrayInfor = AccountSetting_Bds_GetUserInfor_GET($arrayAccessToken[0])
	If $arrayInfor <> 0 Then
		RegWrite($BDS_REG_ACCOUNT,"user","REG_SZ",$user)
		RegWrite($BDS_REG_ACCOUNT,"pass","REG_SZ",$pass)
		RegWrite($BDS_REG_ACCOUNT,"name","REG_SZ",$arrayInfor[0])
		RegWrite($BDS_REG_ACCOUNT,"phone","REG_SZ",$arrayInfor[1])
		If $alert = True Then
			ErrorShow($CONSOLE_INFO,$BDS_URL,"Đăng nhập thành công")
		EndIf
		Return $arrayAccessToken[0]
	Else
		If $alert = True Then
			ErrorShow($CONSOLE_ERROR,$BDS_URL,"Đăng nhập thất bại")
		EndIf
		Return SetError(4)
	EndIf
EndFunc
Func AccountSetting_Bds_Login($accessToken,$alert = False)
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_Bds_Login")
;~ 	If $accessToken <> "" Then
;~ 		AccountSetting_Bds_GetUserInfor_OPTIONS()
;~ 		Local $arrayInfor = AccountSetting_Bds_GetUserInfor_GET($accessToken,"123")
;~ 		If $arrayInfor <> 0 Then
;~ 			RegWrite($REG_ACCOUNT & "Batdongsan.com.vn","accessToken","REG_SZ",$accessToken)
;~ 			RegWrite($REG_ACCOUNT & "Batdongsan.com.vn","name","REG_SZ",$arrayInfor[0])
;~ 			RegWrite($REG_ACCOUNT & "Batdongsan.com.vn","phone","REG_SZ",$arrayInfor[1])
;~ 			If $alert = True Then
;~ 				ErrorShow(64,"Batdongsan.com.vn","Đăng nhập thành công",2)
;~ 			EndIf
;~ 			Return $accessToken
;~ 		Else
;~ 			If $alert = True Then
;~ 				ErrorShow(16,"Batdongsan.com.vn","Đăng nhập thất bại [#2]")
;~ 			EndIf
;~ 			Return SetError(2)
;~ 		EndIf
;~ 	Else
;~ 		If $alert = True Then
;~ 			ErrorShow(16,"Batdongsan.com.vn","Xin vui lòng nhập dữ liệu lấy từ extension",2)
;~ 		EndIf
;~ 		Return SetError(3)
;~ 	EndIf
EndFunc
Func AccountSetting_Bds_GetUserInfor_OPTIONS()
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_Bds_GetUserInfor_OPTIONS")
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
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_Bds_GetUserInfor_GET")
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
	_HttpRequest_Test($rqGetInfor)
	Local $check 	= StringRegExp($rqGetInfor,'"Success":true',0)
	Local $check2 	= StringRegExp($rqGetInfor,'ContactName":"(.*?)"',1)
	Local $check3 	= StringRegExp($rqGetInfor,'ContactMobile":"(.*?)"',1)
	Local $a_Infor[0]

	If $check == 1 And IsArray($check2) == 1 And IsArray($check3) == 1 Then
		_ArrayAdd($a_Infor,$check2[0])
		_ArrayAdd($a_Infor,$check3[0])
		Return $a_Infor
	Else
		Return SetError(1)
	EndIf
EndFunc

Func AccountSetting_Bds_Login_2($cookie)
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_Bds_Login_2")
	If $cookie = "" Then
		Return SetError(1)
	EndIf
	Local $url = "https://batdongsan.com.vn/HandlerWeb/UserHandler.ashx?type=getuserid"
	Local $rq = _HttpRequest(2,$url,'',$cookie)
	Local $userId = StringRegExp($rq,'userId":(\d+)',1)
	If @error Then
		Return SetError(2)
	Else
		Local $accessToken = StringRegExp($cookie,'access_token":"(.*?)"',1)
		If @error Then
			Return SetError(3)
		Else
			Local $arrayInfor = AccountSetting_Bds_GetUserInfor_GET($accessToken[0])
			If @error Then
				Return SetError(4)
			Else
				Return $arrayInfor
			EndIf
		EndIf
	EndIf
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: AccountSetting_Bds_Login_3
; Description ...: Đăng nhập trang Batdongsan.com.vn bằng user và pass
; Syntax ........: AccountSetting_Bds_Login_3($user, $pass)
; Parameters ....: $user                - email at Batdongsan.com.vn
;                  $pass                - password at Batdongsan.com.vn
; Return values .: $arrayInfor	- Mảng chứa thông tin về tài khoản [Tên,Số điện thoại]
;				 : @error 		- Lỗi
; Author ........: Trần Hùng
; Date ..........: 31/12/2022
; ===============================================================================================================================
Func AccountSetting_Bds_Login_3($user,$pass)
	Write_Log("===============================================")
	Write_Log("+AccountSetting.au3")
	Write_Log("+ AccountSetting_Bds_Login_3")
	If $user = "" Then
		Return SetError(1)
	ElseIf $pass = "" Then
		Return SetError(2)
	EndIf
	Local $data = '{"input":"'&$user&'","password":"'&$pass&'","isRemember":1}'
	Local $rq = _HttpRequest(2,$BDS_URL_LOGIN,_Utf8ToAnsi($data))
	Local $arrayAccessToken = StringRegExp($rq,'access_token":"(.*?)"',1)
	If @error Then
		Return SetError(3)
	EndIf
	Local $cookie = _GetCookie()
	AccountSetting_Bds_GetUserInfor_OPTIONS()
	Local $arrayInfor = AccountSetting_Bds_GetUserInfor_GET($arrayAccessToken[0])
	If @error Then
		Return $arrayInfor
	Else
		Return SetError(4)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: AccountSetting_Dothi_Login
; Description ...: Đăng nhập Dothi.net
; Syntax ........: AccountSetting_Dothi_Login([$user = ""[, $pass = ""[, $alert = False]]])
; Parameters ....: $user                - [optional] username. Default is "".
;                  $pass                - [optional] password. Default is "".
;                  $alert               - [optional] Có thông báo hay không. Default is False.
; Return values .: True - Đăng nhập thành công
;				 ; False - Đăng nhập thất bại
; ===============================================================================================================================
Func AccountSetting_Dothi_Login($user = "",$pass = "",$alert = False)
	Write_Log("================")
	Write_Log("+ AccountSetting_Dothi_Login")
	If $user = "" Then
		$user = RegRead($REG_ACCOUNT_DOTHI, "user")
	EndIf

	If $pass = "" Then
		$pass = RegRead($REG_ACCOUNT_DOTHI, "pass")
	EndIf

	Local $form = "act=LoginSystem&UserName="&$user&"&PassWord="&$pass&"&IsBranchUser=false&IsRemember=true"
	Local $urlLogin = "https://dothi.net/Handler/UserHandler.ashx"
	Local $rqLogin = _HttpRequest(2,$urlLogin,$form)
	Local $check = StringRegExp($rqLogin,'isSuccess":true',0)
	If $alert = True Then
		Local $responseInfor = _HttpRequest(2,"https://dothi.net/thanh-vien/thay-doi-thong-tin.htm")
		Local $arrayName = StringRegExp($responseInfor,'value="(.*?)" id="txtFullName"',3)
		If @error Then
			ErrorShow(16,"","Không tìm thấy tên người dùng từ tài khoản")
			Return SetError(1)
		EndIf
		Local $arrayPhone = StringRegExp($responseInfor,'hddPhoneNumber" value="(.*?)"',3)
		If @error Then
			ErrorShow(16,"","Không tìm thấy số điện thoại từ tài khoản")
			Return SetError(2)
		EndIf
		If $check = 1 Then
			RegWrite($REG_ACCOUNT_DOTHI,"user","REG_SZ",$user)
			RegWrite($REG_ACCOUNT_DOTHI,"pass","REG_SZ",$pass)
			RegWrite($REG_ACCOUNT_DOTHI,"name","REG_SZ",$arrayName[0])
			RegWrite($REG_ACCOUNT_DOTHI,"phone","REG_SZ",$arrayPhone[0])
			ErrorShow(64,$DOTHI_URL,"Đăng nhập thành công")
			Return True
		Else
			ErrorShow(16,$DOTHI_URL,"Đăng nhập thất bại")
			Return SetError(3)
		EndIf

	Else ; Nếu người dùng không cần thông báo
		If $check = 1 Then
			Return True
		Else
			Return SetError(3)
		EndIf
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: AccountSetting_Bds123_Login
; Description ...: Đăng nhập trang Bds123.vn
; Syntax ........: AccountSetting_Bds123_Login([$user = ""[, $pass = ""]])
; Parameters ....: $phone	- [optional] Số điện thoại.
;                  $pass	- [optional] Mật khẩu.
;				 : Nếu không điền số điện thoại và mật khẩu thì mặc định sẽ đọc trong REGEDIT
; Return values .: Thành công - Mảng [Số điện thoại, Tên , UserId]
;				 : Thất bại - @error - 1: Không tìm thấy userId
;				 : 			- @error - 2: Không tìm thấy số điện thoại
;				 : 			- @error - 3: Không tìm thấy tên
; ===============================================================================================================================
Func AccountSetting_Bds123_Login($phone = "",$pass = "",$alert = False)
	Write_Log("================")
	Write_Log("+ AccountSetting_Bds123_Login")
	If $phone = "" Then
		$phone = RegRead($BDS123_REG_ACCOUNT, "user")
	EndIf

	If $pass = "" Then
		$pass = RegRead($BDS123_REG_ACCOUNT, "pass")
	EndIf

	Local $data = "loginname="&$phone&"&password="&$pass&"&redirect="
	Local $rq = _HttpRequest(2,$BDS123_URL_LOGIN,$data)
	Local $regexUserID = StringRegExp($rq,'user":{"id":(.*?),',1)
	If @error Then
		If $alert = True Then
			ErrorShow(16,$BDS123_URL,"Không tìm thấy UserId")
		EndIf
		Return SetError(1)
	EndIf
	Local $regexPhone = StringRegExp($rq,'phone":"(.*?)"',1)
	If @error Then
		ErrorShow(16,$BDS123_URL,"Không tìm thấy số điện thoại")
		Return SetError(2)
	EndIf
	Local $regexName = StringRegExp($rq,'name":"(.*?)"',1)
	If @error Then
		ErrorShow(16,$BDS123_URL,"Không tìm thấy Tên người dùng")
		Return SetError(3)
	EndIf
	If $alert = True Then
		RegWrite($BDS123_REG_ACCOUNT,"user"		,"REG_SZ",$phone)
		RegWrite($BDS123_REG_ACCOUNT,"pass"		,"REG_SZ",$pass)
		RegWrite($BDS123_REG_ACCOUNT,"phone"	,"REG_SZ",$regexPhone[0])
		RegWrite($BDS123_REG_ACCOUNT,"name"		,"REG_SZ",_HTMLDecode($regexName[0]))
		RegWrite($BDS123_REG_ACCOUNT,"userID"	,"REG_SZ",$regexUserID[0])
		ErrorShow(64,$BDS123_URL,"Đăng nhập thành công")
		Return True
	EndIf
EndFunc

Func AccountSetting_Muaban_Login($accessToken = Default,$alert = False)
	Write_Log("================")
	Write_Log("+ AccountSetting_Muaban_Login")
	Local $accessTokenEnd
	If $accessToken = Default Then
		$accessTokenEnd = RegRead($MUABAN_REG_ACCOUNT, 'accessToken')
	Else
		$accessTokenEnd = StringReplace($accessToken,'"', "")
	EndIf

	If $accessTokenEnd = '' Then
		If $alert = True Then
			ErrorShow(16,'','Xin vui lòng đăng nhập tài khoản Muaban.net trước')
		EndIf
		Return SetError(1)
	EndIf

	Local $url = 'https://api-v6.muaban.net/identity/v1/users/self'
	Local $header = ':authority: api-v6.muaban.net'
	$header &= '|:path: /identity/v1/users/self'
	$header &= '|:scheme: https'
	$header &= '|authorization: Bearer ' & $accessTokenEnd
	Local $rq = _HttpRequest(2,$url,'','','',$header)
	If $rq = '' Then
		If $alert = False Then
			ErrorShow(16,"Muaban.net","Đăng nhập thất bại, xin vui lòng kiểm tra lại")
		EndIf
		Return SetError(2)
	EndIf

	Local $arrayName = StringRegExp($rq,'full_name":"(.*?)"',1)
	If @error Then
		If $alert = False Then
			ErrorShow(16,"Muaban.net","Đăng nhập thất bại, xin vui lòng kiểm tra lại")
		EndIf
		Return SetError(3)
	EndIf
	Local $arrayPhone = StringRegExp($rq,'phone":"(\d+)"',1)
	If @error Then
		If $alert = False Then
			ErrorShow(16,"Muaban.net","Đăng nhập thất bại, xin vui lòng kiểm tra lại")
		EndIf
		Return SetError(4)
	EndIf
	; Lưu thông tin
	If $accessToken <> Default Then
		RegWrite($MUABAN_REG_ACCOUNT,'accessToken'	,'REG_SZ',$accessTokenEnd)
		RegWrite($MUABAN_REG_ACCOUNT,'phone'		,'REG_SZ',$arrayPhone[0])
		RegWrite($MUABAN_REG_ACCOUNT,'name'			,'REG_SZ',$arrayName[0])
		RegWrite($MUABAN_REG_ACCOUNT,'cookie'		,'REG_SZ',$accessToken)
	EndIf
	If $alert = True Then
		ErrorShow(64,"Muaban.net","Đăng nhập thành công")
	EndIf
	Return $accessTokenEnd
EndFunc

Func AccountSetting_Chotot_Login($user = "",$pass = "",$alert = False)
	Write_Log("================")
	Write_Log("+ AccountSetting_Chotot_Login")
	Local $isSaved
	If $user = "" Then
		$user = RegRead($REG_ACCOUNT & $CHOTOT_URL,"user")
		If $user = "" Then
			If $alert = False Then
				Return SetError(1)
			Else
				ErrorShow($CONSOLE_ERROR,"","Vui lòng đăng nhập Chotot.com trước")
				Return SetError(1)
			EndIf
		EndIf
	Else
		$isSaved = False
	EndIf
	If $pass = "" Then
		$pass = RegRead($REG_ACCOUNT & $CHOTOT_URL,"pass")
		If $pass = "" Then
			If $alert = False Then
				Return SetError(2)
			Else
				ErrorShow($CONSOLE_ERROR,"","Vui lòng đăng nhập Chotot.com trước")
				Return SetError(2)
			EndIf
		EndIf
	Else
		$isSaved = False
	EndIf
	Local $dataLogin = Chotot_Data_Login($user,$pass)
	Local $response = _HttpRequest(2,$CHOTOT_URL_LOGIN,$dataLogin)
	Local $aAccess_token = StringRegExp($response,'access_token":"(.*?)"',1)
	If IsArray($aAccess_token) = 1 Then
		If $alert = True Then
			ErrorShow($CONSOLE_INFO,"Đăng nhập Chotot.com","Đăng nhập thành công")
		EndIf
		If $isSaved = False Then
			RegWrite($REG_ACCOUNT_CHOTOT,"user","REG_SZ",$user)
			RegWrite($REG_ACCOUNT_CHOTOT,"pass","REG_SZ",$pass)
		EndIf
		Return $aAccess_token[0]
	Else
		If $alert = True Then
			ErrorShow($CONSOLE_ERROR,"Đăng nhập Chotot.com","Đăng nhập thất bại")
			_HttpRequest_Test($response)
		EndIf
		Return SetError(3)
	EndIf
EndFunc

Func AccountSetting_Thuecanho123_Login($user = "",$pass = "",$alert = False)
	Write_Log("================")
	Write_Log("+ AccountSetting_Thuecanho123_Login")
	Local $isSaved
	If $user = "" Then
		$user = RegRead($REG_ACCOUNT & $THUECANHO123_URL,"user")
		If $user = "" Then
			If $alert = False Then
				Return SetError(1)
			Else
				ErrorShow($CONSOLE_ERROR,"","Vui lòng đăng nhập "&$THUECANHO123_URL&" trước")
				Return SetError(1)
			EndIf
		EndIf
	Else
		$isSaved = False
	EndIf
	If $pass = "" Then
		$pass = RegRead($REG_ACCOUNT & $THUECANHO123_URL,"pass")
		If $pass = "" Then
			If $alert = False Then
				Return SetError(2)
			Else
				ErrorShow($CONSOLE_ERROR,"","Vui lòng đăng nhập "&$THUECANHO123_URL&" trước")
				Return SetError(2)
			EndIf
		EndIf
	Else
		$isSaved = False
	EndIf

	Local $rqGetToken = _HttpRequest(2,$THUECANHO123_URL_GET_TOKEN_LOGIN)
	Local $arrayToken = StringRegExp($rqGetToken,'name="_token" content="(.*?)"',3)
	If @error Then
		If $alert = True Then
			ErrorShow($CONSOLE_ERROR,"Thuecanho123.com","Không tìm thấy token login")
		EndIf
		Return SetError(3)
	EndIf
	Local $data = "loginname=" & $user & "&password=" & $pass
	Local $header = "x-csrf-token: " & $arrayToken[0]
	Local $rq = _HttpRequest(2,$THUECANHO123_URL_LOGIN,$data,'','',$header,"POST")
	Local $check = StringRegExp($rq,'access_token":"(.*?)"',3)
	If @error Then
		If $alert = True Then
			ErrorShow(16,"Thuecanho123.com","Đăng nhập thất bại")
		EndIf
		Return SetError(4)
	Else
		If $isSaved = False Then
			RegWrite($REG_ACCOUNT_THUECANHO123,"user","REG_SZ",$user)
			RegWrite($REG_ACCOUNT_THUECANHO123,"pass","REG_SZ",$pass)
		EndIf
		If $alert = True Then
			ErrorShow($CONSOLE_INFO,"Thuecanho123.com","Đăng nhập thành công")
		EndIf
		Return $arrayToken[0]
	EndIf
EndFunc

Func AccountSetting_Homdy_Login($user = "",$pass = "",$alert = False)

	If $user = "" Then
		$user = RegRead($REG_ACCOUNT & $HOMEDY_URL,"user")
		If $user = "" Then
			If $alert = False Then
				Return SetError(1)
			Else
				ErrorShow($CONSOLE_ERROR,"","Vui lòng đăng nhập "&$HOMEDY_URL&" trước")
				Return SetError(1)
			EndIf
		EndIf
	EndIf
	If $pass = "" Then
		$pass = RegRead($REG_ACCOUNT & $HOMEDY_URL,"pass")
		If $pass = "" Then
			If $alert = False Then
				Return SetError(2)
			Else
				ErrorShow($CONSOLE_ERROR,"","Vui lòng đăng nhập "&$HOMEDY_URL&" trước")
				Return SetError(2)
			EndIf
		EndIf
	EndIf

	Local $data = '{"Email":"'&$user&'","Password":"'&$pass&'"}'
	Local $rq = _HttpRequest(2,$HOMEDY_URL_LOGIN,$data,"","",$HOMEDY_HEADER_LOGIN)
	Local $check = StringRegExp($rq,'IsSuccess":true',0)
	If $check = 1 Then
		If $alert = True Then
			RegWrite($HOMEDY_REG_ACCOUNT,"user","REG_SZ",$user)
			RegWrite($HOMEDY_REG_ACCOUNT,"pass","REG_SZ",$pass)
			ErrorShow(64,$HOMEDY_URL,"Đăng nhập thành công")
		EndIf
		Return True
	Else
		Local $error = StringRegExp($rq,'"Message":"(.*?)"',1)
		If @error Then
			If $alert = True Then
				ErrorShow(16,$HOMEDY_URL,"Đăng nhập thất bại")
			EndIf
			Return SetError(1)
		Else
			If $alert = True Then
				ErrorShow(16,$HOMEDY_URL,$error[0])
			EndIf
			Return SetError(2)
		EndIf
	EndIf
EndFunc

Func AccountSetting_Server_Login_TurnOn()
	Global $socketId = _API_MGR_Init(3000)
	If @error Then
		MsgBox(16 + 262144,"Gặp lỗi khi khởi tạo server","Xin vui lòng thử lại hoặc liên hệ fanpage")
	EndIf
	_API_MGR_ROUTER_POST('/LOGIN', AccountSetting_Server_Login_Process)
	While 1
		_API_MGR_ROUTER_HANDLE($socketId)
	WEnd
EndFunc

Func AccountSetting_Server_Login_Process(Const $oRequest)
;~ 	_API_RES_SET_CONTENT_TYPE($API_CONTENT_TYPE_TEXTJSON)
	Local $object = ObjCreate("Scripting.Dictionary")
	Local $checkSite = $oRequest.exists('site') ? True : False
	Local $checkData = $oRequest.exists('data') ? True : False
	If $checkSite = False Then
		Return 'MISSING INFORMATION - SITE'
	ElseIf $checkData = False Then
		Return 'MISSING INFORMATION - DATA'
	Else
		Local $currentSite = $oRequest.item('site')
		Local $currentData = $oRequest.item('data')
		Switch $currentSite
			Case "Batdongsan.com.vn"
				Local $cookieDecode = _URIDecode($currentData)
				Local $arrayInfor = AccountSetting_Bds_Login_2($cookieDecode)
				If @error Then
					ErrorShow(16,$BDS_URL,"Đăng nhập thất bại")
					Return "BATDONGSAN.COM.VN - LOGIN FAIL"
				Else
					RegWrite($BDS_REG_ACCOUNT,'name','REG_SZ',$arrayInfor[0])
					RegWrite($BDS_REG_ACCOUNT,'phone','REG_SZ',$arrayInfor[1])
					RegWrite($BDS_REG_ACCOUNT,'cookie','REG_SZ',$cookieDecode)
					ErrorShow(64,$BDS_URL,"Đăng nhập thành công")
					Return "BATDONGSAN.COM.VN - LOGIN SUCCESS"
				EndIf
		EndSwitch
	EndIf
EndFunc