Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
#RequireAdmin ; Phải có dòng này để có quyền đọc
#include <_HttpRequest.au3> 	; UDF thực hiện Request
#include <File.au3> 			; Đọc file để tìm port và pass
#include <ButtonConstants.au3> 	; Tạo GUI
#include <ComboConstants.au3> 	; Tạo GUI
#include <GUIConstantsEx.au3> 	; Tạo GUI
#include <WindowsConstants.au3> ; Tạo GUI
#include <EditConstants.au3> 	; Tạo GUI
#include <GuiComboBoxEx.au3> 	; Tạo GUI

; Check quyền Admin
If (Not IsAdmin()) Then
	MsgBox(48 + 4096 + 262144, "Code By Trần Hùng", "Vui lòng mở tool bằng quyền Administrator!")
	Exit
EndIf

; Biến toàn cục
Global $isRunning = False
Global $__g_a_Champ[0] ; Mảng chứa tên tướng và ID
Global Const $Url = "https://127.0.0.1:" ; IP của API
Global $API[5]
$API[0] = "/lol-champions/v1/owned-champions-minimal"        ; Xem những tướng hiện có
$API[1] = "/lol-matchmaking/v1/ready-check/accept"           ; Chấp nhận trận
$API[2] = "/lol-champ-select/v1/session"                     ; Tìm Session Pick
$API[3] = "/lol-champ-select/v1/session/actions/"            ; Thực hiện hành động (Pick or Lock)
$API[4] = "/lol-summoner/v1/current-summoner"            	 ; Lấy tên người dùng hiện tại

#Region ### START Koda GUI section ### Form=
; Tạo GUI
Global $__g_idMainGUI 			= GUICreate("Auto pick tướng | Ver 5.0", 301, 133, 192, 150)
Global $__g_idCombo_Champ 		= GUICtrlCreateCombo("Chọn tướng", 8, 8, 153, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
Global $__g_idInput_Search 		= GUICtrlCreateInput("", 170, 8, 100, 21)
Global $__g_idCheckbox_Accept 	= GUICtrlCreateCheckbox("Auto Chấp Nhận", 8, 40, 105, 17)
Global $__g_idCheckbox_Pick 	= GUICtrlCreateCheckbox("Auto Pick", 8, 64, 105, 17)
Global $__g_idLabel_Donate 		= GUICtrlCreateLabel("Code By Trần Hùng" & @CRLF & "MOMO: 0971253369", 140, 40, 200, 50)
Global $__g_idButton_Start 		= GUICtrlCreateButton("Bắt đầu", 8, 88, 123, 25)
Global $__g_idButton_Stop 		= GUICtrlCreateButton("Dừng", 168, 88, 123, 25)

Global $__g_idDummy_Enter 	= GUICtrlCreateDummy()
Global $__g_idDummy_Up 		= GUICtrlCreateDummy()
Global $__g_idDummy_Down 	= GUICtrlCreateDummy()

GUICtrlSetCursor($__g_idCombo_Champ,0)
GUICtrlSetCursor($__g_idCheckbox_Accept,0)
GUICtrlSetCursor($__g_idCheckbox_Pick,0)
GUICtrlSetCursor($__g_idButton_Start,0)
GUICtrlSetCursor($__g_idButton_Stop,0)

GUICtrlSetFont($__g_idLabel_Donate	, 12)
GUICtrlSetColor($__g_idLabel_Donate	, 0xeb0000)

GUICtrlSendMsg($__g_idInput_Search	, $EM_SETCUEBANNER, False, "Tìm kiếm")
GUICtrlSetTip($__g_idInput_Search	, "Tìm kiếm")

GUICtrlSetOnEvent($__g_idButton_Start,"Switch_Run_Stop")
GUICtrlSetOnEvent($__g_idButton_Stop,"Stop")

GUICtrlSetOnEvent($__g_idDummy_Enter, "SelectSearchResult")
GUICtrlSetOnEvent($__g_idDummy_Up	, "Combobox_MoveUp")
GUICtrlSetOnEvent($__g_idDummy_Down	, "Combobox_MoveDown")

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND") ; Để check khi nhập vào ô tìm kiếm

Local $arrayHotkey = [["{Enter}", $__g_idDummy_Enter], ["{UP}", $__g_idDummy_Up], ["{DOWN}", $__g_idDummy_Down]]
GUISetAccelerators($arrayHotkey,$__g_idMainGUI)

GUISetState()
#EndRegion ### END Koda GUI section ###

GetPortAndPass()

While 1
	If $isRunning = True Then
		Start()
	EndIf
	Sleep(200)
WEnd

Func GetPortAndPass()
	Local $sProc = "LeagueClientUx.exe"
	; Get LCU process ID
	Local $iPID = ProcessExists($sProc)
	; Wait if it is not opended
	If ($iPID == 0) Then
		MsgBox(48 + 8192 + 262144, "Thông báo", "Vui lòng mở Liên Minh trước!", 2000)
		$iPID = ProcessWait($sProc) ;
		Sleep(1000) ; Chờ mở Client Liên Minh
	EndIf
	; Get LCU path
	Local $sDir = StringTrimRight(_WinAPI_GetProcessFileName($iPID), StringLen($sProc))
	; Read the lockfile and get port + password
	Local $sLockfile = FileReadLine($sDir & 'lockfile')
	Local $arrayToken = StringSplit($sLockfile, ':', 2)
	Global $Port = $arrayToken[2]
	Global $Pass = $arrayToken[3]
	ConsoleWrite("Pass: " & $Pass & @CRLF)
	ConsoleWrite("Port: " & $Port & @CRLF)
	_HttpRequest_SetAuthorization("riot", $Pass)
	WinSetTitle($__g_idMainGUI,"",GetSummonerName()) ; Đổi tên GUI để người dùng biết phần mềm đã sử dụng được hoặc khi người dùng đổi acc khác
	GetChampions()
	If @error Then
		MsgBox(48 + 8192 + 262144,"Thông báo lỗi","Gặp lỗi khi load danh sách tướng" & @CRLF & "Xin vui lòng khởi động lại phần mềm")
		_Exit()
	EndIf
EndFunc

Func GetSummonerName() ; Lấy tên người dùng hiện tại
	Local $rqGetName = _HttpRequest(2,$Url & $Port & $API[4])
	Local $arrayName = StringRegExp($rqGetName,'displayName":"(.*?)"',3)
	If @error Then
		Return SetError(1,0,"")
	Else
		Return $arrayName[0]
	EndIf
EndFunc

Func GetChampions() ; Lấy danh sách tướng hiện tại có nick đang đăng nhập rồi hiển thị lên GUI
	Local $rq = _HttpRequest(2, $Url & $Port & $API[0])
	Local $arrayName = StringRegExp($rq, '\"name\"\:"(.*?)\"', 3)
	Local $arrayId = StringRegExp($rq, '\"id\"\:(.*?)\,', 3)
	If IsArray($arrayName) = 1 And IsArray($arrayId) = 1 Then
		For $i = 0 To UBound($arrayName) - 1
			_ArrayAdd($__g_a_Champ, $arrayName[$i] & " - " & $arrayId[$i]) ; Thêm vào mảng để tìm ID của tướng khi đã chọn tướng
		Next
		GUICtrlSetData($__g_idCombo_Champ,_ArrayToString($__g_a_Champ)) ; Hiển thị mảng lên GUI bằng cách này cho lẹ
		Return $__g_a_Champ
	Else
		Return SetError(1)
	EndIf
EndFunc

Func Accept()
	ConsoleWrite("Accept Func" & @CRLF)
	_HttpRequest(".2", $Url & $Port & $API[1], '', '', '', '', 'POST') ; ".2" để không cần chờ response từ server
EndFunc

Func PickLock($championId)
	ConsoleWrite("PickLock Func" & @CRLF)
	Local $Check_Session = _HttpRequest(2, $Url & $Port & $API[2])
	Local $Json = _HttpRequest_ParseJSON($Check_Session)
	Local $Session = $Json.filter('$.actions.0[?(@.actorCellId == ' & $Json.localPlayerCellId & ')].id')
	Local $Session_Cuoi = _HttpRequest_ParseJSON($Session)
	If @error Then
		Sleep(1000) ; Nếu không tìm thấy có nghĩa là trận chưa vô trận nên chờ thêm 1s rồi check lại
	Else
		$Pick = _HttpRequest(".0", $Url & $Port & $API[3] & $Session_Cuoi[0], '{"championId": ' & $championId & '}', '', '', '', 'PATCH')
		$Lock = _HttpRequest(".0", $Url & $Port & $API[3] & $Session_Cuoi[0] & "/complete", '', '', '', '', 'POST')
	EndIf
EndFunc

Func Start()
	ConsoleWrite("Func Start" & @CRLF)
	GUICtrlSetData($__g_idButton_Start, "Đang chạy")
	GUICtrlSetState($__g_idButton_Start, $GUI_DISABLE)
	Local $Check_Accept 	= GUICtrlRead($__g_idCheckbox_Accept)
	Local $Check_Picklock 	= GUICtrlRead($__g_idCheckbox_Pick)
	Local $Check_Champ 		= GUICtrlRead($__g_idCombo_Champ)
	Local $idChamp = StringRegExp($Check_Champ, '\d+', 1)
	If @error Then
		MsgBox(16 + 262144,"Thông báo lỗi", "Không tìm thấy ID tướng")
		Return SetError(1)
	EndIf
	Local $idChampEnd = $idChamp[0]
;~ 	4 == "Không chọn"
;~ 	1 == "Chọn"
	If $Check_Accept = 1 And $Check_Picklock = 1 And $Check_Champ <> "Chọn tướng" Then ; Nếu người dùng muốn auto accept + pick lock 1 tướng
		While $isRunning = True
			Accept()
			PickLock($idChampEnd)
			Sleep(100)
		WEnd
	ElseIf $Check_Accept = 4 And $Check_Picklock = 1 And $Check_Champ <> "Chọn tướng" Then ; Nếu người dùng chỉ muốn auto pick lock 1 tướng
		While $isRunning = True
			PickLock($idChampEnd)
			Sleep(100)
		WEnd
	ElseIf $Check_Accept = 4 And $Check_Picklock = 1 And $Check_Champ = "Chọn tướng" Then ; Nếu người dùng muốn auto pick lock nhưng không chọn tướng thì sẽ bật auto accept thôi
		While $isRunning = True
			Accept()
			Sleep(1500)
		WEnd
	ElseIf $Check_Accept = 1 And $Check_Picklock = 1 And $Check_Champ = "Chọn tướng" Then ; Nếu người dùng bật auto accept + pick lock nhưng không chọn tướng thì bật auto accept
		GUICtrlSetState($__g_idCheckbox_Pick, 4)
		While $isRunning = True
			Accept()
			Sleep(1500)
		WEnd
	ElseIf $Check_Accept = 4 And $Check_Picklock = 4 Then ; Nếu người dùng không chọn gì hết thì bật auto accept
		GUICtrlSetState($__g_idCheckbox_Accept, 1)
		While $isRunning = True
			Accept()
			Sleep(1500)
		WEnd
	ElseIf $Check_Accept = 1 Then ; Nếu người dùng chỉ bật auto accept
		While $isRunning = True
			Accept()
			Sleep(1500)
		WEnd
	EndIf
EndFunc

Func Stop()
	ConsoleWrite("Stop Func" & @CRLF)
	$isRunning = False
	GUICtrlSetData($__g_idButton_Start, "Chạy")
	GUICtrlSetState($__g_idButton_Start, $GUI_ENABLE)
	GUICtrlSetData($__g_idButton_Stop, "Đã dừng")
	Sleep(200)
	GUICtrlSetData($__g_idButton_Stop, "Dừng")
EndFunc   ;==>Stop

Func Switch_Run_Stop()
	$isRunning = True
EndFunc   ;==>Switch_Run_Stop

Func SearchChampion()
	Local $arrayMatch[0] ; Mảng chứa danh sách các tướng tìm được
	Local $searchContent = GUICtrlRead($__g_idInput_Search) ; Nội dung muốn tìm

	; Nếu người dùng xóa hết nội dung tìm kiếm thì reset lại tất cả các tướng
	If $searchContent = "" Then
		GUICtrlSetData($__g_idCombo_Champ,"|Chọn tướng|" & _ArrayToString($__g_a_Champ))
		_GUICtrlComboBox_ShowDropDown($__g_idCombo_Champ, True)
		_GUICtrlComboBox_SetCurSel($__g_idCombo_Champ,0)
		_GUICtrlComboBox_SetMinVisible($__g_idCombo_Champ, 20)
		Return False
	EndIf

	For $i = 0 To UBound($__g_a_Champ) - 1 ; Lặp để tìm từng tướng xem có giống với nội dung bên ô tìm kiếm không
		Local $isMatch = StringInStr($__g_a_Champ[$i],$searchContent)
		If $isMatch <> 0 Then
			_ArrayAdd($arrayMatch, $__g_a_Champ[$i])
		EndIf
	Next
	GUICtrlSetData($__g_idCombo_Champ,"|" & _ArrayToString($arrayMatch))
	_GUICtrlComboBox_ShowDropDown($__g_idCombo_Champ, True)
	_GUICtrlComboBox_SetCurSel($__g_idCombo_Champ,0)
	_GUICtrlComboBox_SetMinVisible($__g_idCombo_Champ, 10)
EndFunc

Func CheckChangeAccount() ; Check xem nếu người dùng đổi acc thì tool cũng cần phải khởi động lại, cái này ae tự code nhé dễ mà :D

EndFunc

#Region	Điều khiển GUI

	Func Combobox_MoveUp() ; Di chuyển tới kết quả tìm kiếm ở trên
		Local $currentIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Champ)
		If $currentIndex > 0 Then
			_GUICtrlComboBox_SetCurSel($__g_idCombo_Champ,$currentIndex - 1)
		EndIf
	EndFunc

	Func Combobox_MoveDown() ; Di chuyển tới kết quả tìm kiếm ở dưới
		Local $currentIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Champ)
		_GUICtrlComboBox_SetCurSel($__g_idCombo_Champ,$currentIndex + 1)
	EndFunc

	Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam) ; Dùng để kích hoạt Func tìm kiếm khi người dùng nhập vào ô tìm kiếm
		Local $hdlWindowFrom, $intMessageCode, $intControlID_From
		$intControlID_From = BitAND($wParam, 0xFFFF)
		$intMessageCode = BitShift($wParam, 16)

		Switch $intControlID_From
			Case $__g_idInput_Search
				Switch $intMessageCode
					Case $EN_CHANGE
						SearchChampion() ; Khi người dùng nhập vào ô tìm kiếm thì sẽ khởi động Func
				EndSwitch
		EndSwitch

		Return $GUI_RUNDEFMSG
	EndFunc   ;==>WM_COMMAND

	Func SelectSearchResult() ; Khi bấm Enter thì sẽ khóa tướng đang được chọn
		Local $currentIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Champ)
		_GUICtrlComboBox_SetCurSel($__g_idCombo_Champ, $currentIndex)
		_GUICtrlComboBox_ShowDropDown($__g_idCombo_Champ, False)
	EndFunc
	Func _Exit() ; Thoát khỏi TOOL
		Exit
	EndFunc
#EndRegion