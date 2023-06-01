#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Yasuo.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; #AutoIt3Wrapper_res_requestedExecutionLevel dòng này để có thể ConsoleWrite

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
#include-once
#include <ConsoleWriteVi.au3> 	; Tạo GUI
#include <File.au3> 			; Đọc file để tìm port và pass
#include <ButtonConstants.au3> 	; Tạo GUI
#include <ComboConstants.au3> 	; Tạo GUI
#include <GUIConstantsEx.au3> 	; Tạo GUI
#include <WindowsConstants.au3> ; Tạo GUI
#include <EditConstants.au3> 	; Tạo GUI
#include <GuiComboBoxEx.au3> 	; Tạo GUI
#include <_HttpRequest.au3> 	; UDF thực hiện Request
; Check quyền Admin
If (Not IsAdmin()) Then
	MsgBox(48 + 4096 + 262144, "Code By Trần Hùng", "Vui lòng mở tool bằng quyền Administrator!")
	Exit
EndIf

; Biến toàn cục
Global $RUNNING 	= False ; Biến này dùng để dừng chạy khi ấn Dừng
Global $PICKED 		= False ; Thể hiện giá trị của Combobox Auto Pick
Global $ACCEPT 		= False ; Thể hiện giá trị của Combobox Auto Accept
Global $PICK_LOCK 	= False ; Nếu True là đã pick xong đang chờ check lại xem vô trận chưa, False là chưa có Pick
Global $CHAMP_ID	; ID của tướng cần Pick
Global $__g_a_Champ[0] ; Mảng chứa tên tướng và ID
Global Const $Url = "https://127.0.0.1:" ; IP của API
Global $PORT
Global $PASS

Global $API[6]
$API[0] = "/lol-champions/v1/owned-champions-minimal"       ; Xem những tướng hiện có
$API[1] = "/lol-matchmaking/v1/ready-check/accept"          ; Chấp nhận trận
$API[2] = "/lol-champ-select/v1/session"                    ; Tìm Session Pick
$API[3] = "/lol-champ-select/v1/session/actions/"           ; Thực hiện hành động (Pick or Lock)
$API[4] = "/lol-summoner/v1/current-summoner"            	; Lấy tên người dùng hiện tại
$API[5] = "/lol-gameflow/v1/gameflow-phase"            	 	; Kiểm tra xem đang ở đâu


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

GUICtrlSetOnEvent($__g_idButton_Start,"Switch_Run")
GUICtrlSetOnEvent($__g_idButton_Stop,"Stop")
GUICtrlSetOnEvent($__g_idCombo_Champ,"GetChampionId")
GUICtrlSetOnEvent($__g_idCheckbox_Accept,"SetAcceptFunc")
GUICtrlSetOnEvent($__g_idCheckbox_Pick,"SetAcceptFunc")
GUICtrlSetOnEvent($__g_idDummy_Enter, "SelectSearchResult")
GUICtrlSetOnEvent($__g_idDummy_Up	, "Combobox_MoveUp")
GUICtrlSetOnEvent($__g_idDummy_Down	, "Combobox_MoveDown")

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND") ; Để check khi nhập vào ô tìm kiếm

Local $arrayHotkey = [["{Enter}", $__g_idDummy_Enter], ["{UP}", $__g_idDummy_Up], ["{DOWN}", $__g_idDummy_Down]]
GUISetAccelerators($arrayHotkey,$__g_idMainGUI)

GUISetState(@SW_SHOW ,$__g_idMainGUI)
#EndRegion ### END Koda GUI section ###

GetPortAndPass()

While 1
	Sleep(100)
	If $RUNNING = True Then
		Start()
	EndIf
WEnd

Func GetPortAndPass()
	Local $sProc = "LeagueClientUx.exe"
	; Get LCU process ID
	Local $iPID = ProcessExists($sProc)
	; Wait if it is not opended
	If ($iPID == 0) Then
		MsgBox(48 + 8192 + 262144, "Thông báo", "Vui lòng mở Liên Minh trước!", 2)
		$iPID = ProcessWait($sProc) ;
		Sleep(1000) ; Chờ mở Client Liên Minh
	EndIf
	; Get LCU path
	Local $sDir = StringTrimRight(_WinAPI_GetProcessFileName($iPID), StringLen($sProc))
	; Read the lockfile and get port + password
	Local $sLockfile = FileReadLine($sDir & 'lockfile')
	Local $arrayToken = StringSplit($sLockfile, ':', 2)
	$PORT = $arrayToken[2]
	$PASS = $arrayToken[3]
	ConsoleWrite("Pass: " & $PASS & @CRLF)
	ConsoleWrite("Port: " & $PORT & @CRLF)
	_HttpRequest_SetAuthorization("riot", $PASS)
	WinSetTitle($__g_idMainGUI,"",GetSummonerName()) ; Đổi tên GUI để người dùng biết phần mềm đã sử dụng được hoặc khi người dùng đổi acc khác
	GetChampionsList() ; Lấy danh sách tướng của người dùng hiện có bỏ vào combobox
	If @error Then
		MsgBox(48 + 8192 + 262144,"Thông báo lỗi","Gặp lỗi khi load danh sách tướng" & @CRLF & "Xin vui lòng khởi động lại phần mềm")
		_Exit()
	EndIf
EndFunc

Func API($index)
	Return $Url & $PORT & $API[$index]
EndFunc

Func GetSummonerName() ; Lấy tên người dùng hiện tại
	Local $rqGetName = _HttpRequest(2,API(4))
	Local $arrayName = StringRegExp($rqGetName,'displayName":"(.*?)"',3)
	If @error Then
		Return SetError(1)
	Else
		Return $arrayName[0]
	EndIf
EndFunc

Func GetChampionsList() ; Lấy danh sách tướng hiện tại có nick đang đăng nhập rồi hiển thị lên GUI
	ConsoleWrite("+ GetChampionsList Func" & @CRLF)
	Local $rq = _HttpRequest(2,API(0))
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

Func whereAmI() ; Check xem đã trong trận chưa
	ConsoleWrite("+ whereAmI Function" & @CRLF)
	Local $rq = _HttpRequest(2,API(5))
	Switch $rq
		Case '"InProgress"' 	; Đang trong trận
			ConsoleWriteVi("Đang trong trận" & @CRLF)
			Stop()
			Return 1
		Case '"Matchmaking"' 	; Đang tìm trận
			ConsoleWriteVi("Đang tìm trận" & @CRLF)
			Sleep(2000)
			Return 2
		Case '"Lobby"' 			; Chưa tìm trận
			ConsoleWriteVi("Đang trong phòng chờ" & @CRLF)
			Sleep(2000)
			Return 3
		Case '"ChampSelect"' 	; Đang trong phần chọn tướng
			ConsoleWriteVi("Đang chọn tướng" & @CRLF)
			If $PICKED = True Then ; Nếu đã pick rồi thì chờ 2s sau mới kiểm tra lại
				Sleep(2000)
				Return 4
			EndIf
			Return 4
		Case '"None"' 			; Đang ở ngoài Menu chính
			ConsoleWriteVi("Đang ở ngoài menu chính" & @CRLF)
			Sleep(2000)
			Return 5
		Case '"ReadyCheck"'
			ConsoleWriteVi("Đang ở phần chấp thuận trận đấu" & @CRLF)
			$PICKED = False
			Return 6
		Case Else 				; Không biết đang ở đâu luôn
			ConsoleWriteVi("Không biết đang ở đâu luôn: " & $rq & @CRLF)
			Sleep(2000)
			Return 7
	EndSwitch
EndFunc

Func accept()
	ConsoleWrite("+ accept Func" & @CRLF)
	_HttpRequest(2,API(1),'','','','','POST')
EndFunc

Func GetChampionId()
	ConsoleWrite("+ GetChampionId Func" & @CRLF)
	Local $Check_Champ 		= GUICtrlRead($__g_idCombo_Champ)
	Local $idChamp 			= StringRegExp($Check_Champ, '\d+', 1)
	If @error Then
		MsgBox(16 + 262144,"Thông báo lỗi", "Không tìm thấy ID tướng")
		Return SetError(1)
	EndIf
	$CHAMP_ID = $idChamp[0]
	ConsoleWrite("$CHAMP_ID = " & $CHAMP_ID & @CRLF)
	Return $CHAMP_ID
EndFunc

Func SetAcceptFunc() ; Set lại 2 biến $ACCEPT và $PICK_LOCK khi người dùng bấm vào checkbox
	ConsoleWrite("+ SetAcceptFunc Func" & @CRLF)
	Global $ACCEPT 		= GUICtrlRead($__g_idCheckbox_Accept) == 1
	Global $PICK_LOCK 	= GUICtrlRead($__g_idCheckbox_Pick) == 1
	ConsoleWrite("$ACCEPT = " & $ACCEPT & @CRLF)
	ConsoleWrite("$PICK_LOCK = " & $PICK_LOCK & @CRLF)
EndFunc

Func pickLock()
	ConsoleWrite("+ pickLock Func" & @CRLF)
	If $CHAMP_ID = "" Then
		MsgBox(16 + 8192+ 262144,"Thông báo lỗi","Xin vui lòng chọn tướng")
		Return SetError(1)
	EndIf
	Local $rq = _HttpRequest(2,API(2))
	Local $json = _HttpRequest_ParseJSON($rq)
	Local $cellIdFilter = $json.filter('$.actions.0[?(@.actorCellId == ' & $json.localPlayerCellId & ')].id')
	Local $cellIdArray = _HttpRequest_ParseJSON($cellIdFilter)
	If $cellIdArray = False Then
		Sleep(1000)
	Else
		Local $Pick = _HttpRequest(2,API(3) & $cellIdArray[0], '{"championId": ' & $CHAMP_ID & '}', '', '', '', 'PATCH')
		Local $Lock = _HttpRequest(2,API(3) & $cellIdArray[0] & "/complete", '', '', '', '', 'POST')
	EndIf
	$PICKED = True ; Set biến này thành True, để sleep lâu hơn đỡ spam lên server
EndFunc

Func Start()
	ConsoleWriteVi("+ Func Start" & @CRLF)
	GUICtrlSetData($__g_idButton_Start, "Đang chạy")
	GUICtrlSetState($__g_idButton_Start, $GUI_DISABLE)
	If $ACCEPT And $PICK_LOCK And $CHAMP_ID Then
		ConsoleWriteVi("Auto Accept + Auto Pick" & @CRLF)
		While 1
			If $RUNNING = False Then
				ExitLoop
			EndIf
			Switch whereAmI()
				Case 4
					pickLock()
				Case 6
					accept()
			EndSwitch
		WEnd
	ElseIf $PICK_LOCK = False Then
		ConsoleWriteVi("Auto Accept" & @CRLF)
		If $ACCEPT = False Then ; Nếu người dùng bấm chạy mà chưa tick vô ô nào thì sẽ tự tick vào ô Accept
			GUICtrlSetState($__g_idCheckbox_Accept,1)
		EndIf
		While 1
			If $RUNNING = False Then
				ExitLoop
			EndIf
			If whereAmI() = 6 Then
				accept()
			EndIf
		WEnd
	ElseIf $PICK_LOCK And $CHAMP_ID Then
		ConsoleWriteVi("Auto Pick" & @CRLF)
		While 1
			If $RUNNING = False Then
				ExitLoop
			EndIf
			If whereAmI() = 4 Then
				pickLock()
			EndIf
		WEnd
	Else
		MsgBox(16 + 8192 + 262144,"Thông báo","Xin vui lòng chọn tướng")
		Stop()
	EndIf
EndFunc

Func Stop()
	ConsoleWrite("Stop Func" & @CRLF)
	$RUNNING = False
	GUICtrlSetData($__g_idButton_Start, "Chạy")
	GUICtrlSetState($__g_idButton_Start, $GUI_ENABLE)
EndFunc   ;==>Stop

Func Switch_Run()
	$RUNNING = True
EndFunc   ;==>Switch_Run

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
		GetChampionId()
	EndFunc

	Func Combobox_MoveDown() ; Di chuyển tới kết quả tìm kiếm ở dưới
		Local $currentIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Champ)
		_GUICtrlComboBox_SetCurSel($__g_idCombo_Champ,$currentIndex + 1)
		GetChampionId()
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
		GetChampionId() ; Tìm ID sau khi nhấn Enter
	EndFunc
	Func _Exit() ; Thoát khỏi TOOL
		$RUNNING = False
		Exit
	EndFunc
#EndRegion
