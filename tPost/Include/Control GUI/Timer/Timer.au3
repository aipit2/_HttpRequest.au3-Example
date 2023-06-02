#include <TaskScheduler.au3>
; #FUNCTION# ====================================================================================================================
; Name ..........: ConnectTask
; Description ...: Kết nối với Task Scheduler, tạo folder nếu chưa có
; Syntax ........: ConnectTask()
; Return values .: @error = 1 - Không kết nối được với trình hẹn giờ
;                : @error = 2 - Không tạo được thư mục
;                : True - Kết nối thành công
; Author ........: Trần Hùng
; Modified ......: 22/04/2022
; ===============================================================================================================================
Func ConnectTask()
	Write_Log("=================")
	Write_Log("+ ConnectTask")
	Global $__g_o_ConnectTask = _TS_Open()
	If @error <> 0 Then
		ErrorShow(16,"","Không thể kết nối trình hẹn giờ: Code #" & @error)
		Return SetError(1)
	EndIf
	Local $checkFolderExit = _TS_FolderExists($__g_o_ConnectTask,"\TPOST")
	If $checkFolderExit = 0 Then
		Local $createTaskFolder = _TS_FolderCreate($__g_o_ConnectTask,"\TPOST")
		If $createTaskFolder = 0 Then
			ErrorShow(16,"","Không thể tạo thư mục hẹn giờ")
			Return SetError(2)
		EndIf
	EndIf
	Return $__g_o_ConnectTask
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GetTaskName
; Description ...: Load danh sách tên task rồi hiển thị lên GUI
; Activate when .: Khi người dùng mở Tool
;                : Khi người dùng xóa hoặc thêm task
; Syntax ........: GetTaskName()
; Return values .: True - Load danh sách thành công
;                : @error = 1 - Load danh sách thất bại
; Author ........: Trần Hùng
; Modified ......: 22/04/2022
; ===============================================================================================================================
Func GetTaskName()
	Write_Log("=================")
	Write_Log("+ GetTaskName")
	Global $__g_o_ConnectTask = ConnectTask()
	Global $__g_a_TaskName = _TS_TaskList($__g_o_ConnectTask,"\TPOST",0,1,1,1 + 4)
	If IsArray($__g_a_TaskName) = 1 Then
		GUICtrlSetData($__g_idList_Timer_TaskName,"|Tin đăng hiện tại|" & _ArrayToString($__g_a_TaskName,"|",-1,-1,"|",0,0))
		Return True
	Else
		Return SetError(1)
	EndIf
EndFunc

;~ Func GetTaskInfor()
;~ 	Write_Log("=================")
;~ 	Write_Log("+ GetTaskInfor")
;~ 	; Get tên task cần get status
;~ 	Local $today = _DateToDayValue(@YEAR,@MON,@MDAY)
;~ 	Local $Y, $M, $D
;~ 	_DayValueToDate($today, $Y, $M, $D)
;~ 	Local $dayStart = $D & "/" & $M & "/" & $Y
;~ 	Local $taskSearch
;~ 	Local $taskName = GUICtrlRead($__g_idList_Timer_TaskName)
;~ 	Switch $taskName
;~ 		Case ""
;~ 			Return 0
;~ 		Case "Tin đăng hiện tại"
;~ 			GUICtrlSetData($__g_idInput_Timer_Date,$dayStart)
;~ 			GUICtrlSetData($__g_idDate_Timer_Time,"2022/04/01 " & _NowTime(5))
;~ 			GUICtrlSetState($__g_idRadio_Timer_Nothing,1)
;~ 			GUICtrlSetData($__g_idLabel_Timer_Status,"Chưa cài đặt")
;~ 			GUICtrlSetColor($__g_idLabel_Timer_Status,0x000000) ; Đen
;~ 			Return 1
;~ 		Case Else
;~ 			$taskSearch = $taskName
;~ 	EndSwitch
;~ 	; Tìm task status
;~ 	Local $indexTaskName = _GUICtrlListBox_GetCurSel($__g_idList_Timer_TaskName)
;~ 	Switch $indexTaskName
;~ 		Case -1,0
;~ 			Return 0
;~ 	EndSwitch
;~ 	If IsArray($__g_a_TaskName) = 0 Then
;~ 		Return 0
;~ 	EndIf
;~ 	Local $status = RegRead($REG_SAVEPOST & $taskName,"status")
;~ 	Switch $status
;~ 		Case "Đã đăng tin"
;~ 			GUICtrlSetColor($__g_idLabel_Timer_Status,0x00ff15) ; Xanh lá
;~ 		Case "Đã hẹn giờ"
;~ 			GUICtrlSetColor($__g_idLabel_Timer_Status,0x0283ed) ; Xanh dương
;~ 		Case Else
;~ 			GUICtrlSetColor($__g_idLabel_Timer_Status,0x000000) ; Đen
;~ 	EndSwitch
;~ 	GUICtrlSetData($__g_idLabel_Timer_Status,$status)
;~ 	; Tìm task
;~ 	Local $date = RegRead($REG_SAVEPOST & $taskName,"date")
;~ 	If $date = "" Then
;~ 		GUICtrlSetData($__g_idInput_Timer_Date,$dayStart)
;~ 	Else
;~ 		GUICtrlSetData($__g_idInput_Timer_Date,$date)
;~ 	EndIf
;~ 	Local $time = RegRead($REG_SAVEPOST & $taskName,"time")
;~ 	If $time = "" Then
;~ 		GUICtrlSetData($__g_idDate_Timer_Time,"2022/04/01 " & _NowTime(5))
;~ 	Else
;~ 		GUICtrlSetData($__g_idDate_Timer_Time,"2022/04/01 " & $time)
;~ 	EndIf
;~ 	; Tìm sau khi đăng tin
;~ 	Local $afterPost = RegRead($REG_SAVEPOST & $taskName,"afterPost")
;~ 	Switch $afterPost
;~ 		Case "Sleep"
;~ 			GUICtrlSetState($__g_idRadio_Timer_Sleep,1)
;~ 		Case "Turn Off"
;~ 			GUICtrlSetState($__g_idRadio_Timer_TurnOff,1)
;~ 		Case Else
;~ 			GUICtrlSetState($__g_idRadio_Timer_Nothing,1)
;~ 	EndSwitch
;~ EndFunc

Func Timer_NewTask()
	Write_Log("====================")
	Write_Log("+ Timer_NewTask")
	Local $postName = GUICtrlRead($__g_idList_Timer_TaskName)
	If $postName = "" Then
		ErrorShow(16,"","Xin vui lòng chọn bài viết muốn lưu")
		Return 0
	ElseIf $postName = "Tin đăng hiện tại" Then
		Local $check = Timer_CheckBeforeSet()
		If $check = 0 Then Return 0
;~ 		Timer_SavePost($check)
	Else
;~ 		Post_Manager_EditPost($postName)
		Local $check = Timer_CheckBeforeSet()
		If $check = 0 Then Return 0
;~ 		Timer_SavePost($check)
	EndIf
EndFunc

Func Timer_CheckBeforeSet()
	Write_Log("====================")
	Write_Log("+ Timer_CheckBeforeSet")
	Local $result
	Local $webNumber = UBound($arrayMain)
	If $webNumber = 0 Then
		$result &= "Xin vui lòng chọn web muốn đăng tin" & @CRLF
	EndIf
	; Kiểm tra loại tin
	Local $postTypeIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_PostType)
	If $postTypeIndex = 0 Then
		$result &= "Xin vui lòng chọn |Loại tin|" & @CRLF
	EndIf
	; Kiểm tra loại Bds
	Local $estateTypeIndex = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_EstateType)
	If $estateTypeIndex = 0 Then
		$result &= "Xin vui lòng chọn Loại Bds" & @CRLF
	EndIf
	Local $room = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_Room)
	Local $wc = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_Wc)
	Local $acr = GUICtrlRead($__g_idInput_Tab2_Acr)
	If $acr = "" Then
		$acr = 0
	EndIf
	Local $priceValue = GUICtrlRead($__g_idInput_Tab2_Price)
	If $priceValue = "" Then
		$priceValue = 0
	EndIf
	Local $priceTypeValue = _GUICtrlComboBox_GetCurSel($__g_idCombo_Tab2_PriceType)
	Local $contentValue = GUICtrlRead($__g_idEdit_Tab2_Content)

	; Check xem file ảnh có tồn tại không
	If IsArray($__g_a_ImageLink) = 1 Then
		For $i = 0 To UBound($__g_a_ImageLink) - 1
			If FileExists($__g_a_ImageLink[$i]) = 0 Then
				$result &= "Vui lòng chọn lại hình ảnh!" & @CRLF
				Tab2_RemoveImage()
				ExitLoop
			EndIf
		Next
	EndIf
	; Check web nào thiếu địa chỉ không ?
	For $i = 0 To UBound($arrayMain) - 1
		If $arrayMain[$i][$eCityId] = "" Then
			$result &= $arrayMain[$i][$eSite] & " chưa nhập Tỉnh/thành phố" & @CRLF
		ElseIf $arrayMain[$i][$eDistrictId] = "" Then
			$result &= $arrayMain[$i][$eSite] &  " chưa nhập Quận/huyện" & @CRLF
		EndIf
	Next
	; Check sau khi đăng thì làm gì
	Local $checkSleep 	= GUICtrlRead($__g_idRadio_Timer_Sleep)
	Local $checkTurnOff = GUICtrlRead($__g_idRadio_Timer_TurnOff)
	Local $checkNothing = GUICtrlRead($__g_idRadio_Timer_Nothing)
	Local $afterPost
	If $checkSleep = 1 Then
		$afterPost = "Sleep"
	ElseIf $checkTurnOff = 1 Then
		$afterPost = "Turn Off"
	Else
		$afterPost = "Nothing"
	EndIf
	Local $arrayCheck[13]
	$arrayCheck[0] = $postTypeIndex
	$arrayCheck[1] = $estateTypeIndex
	$arrayCheck[2] = $room
	$arrayCheck[3] = $wc
	$arrayCheck[4] = $acr
	$arrayCheck[5] = $priceValue
	$arrayCheck[6] = $priceTypeValue
	$arrayCheck[7] = $contentValue
	$arrayCheck[8] = $__g_a_ImageLink
	$arrayCheck[9] = GUICtrlRead($__g_idInput_Timer_Date)
	$arrayCheck[10] = GUICtrlRead($__g_idDate_Timer_Time)
	$arrayCheck[11] = $afterPost
	$arrayCheck[12] = $webNumber
	If $result = "" Then
		Return $arrayCheck
	Else
		ErrorShow(16,'', $result)
		Return 0
	EndIf
EndFunc

Func Timer_SaveTask($arrayCheck)
;~ 	Write_Log("====================")
;~ 	Write_Log("+ Timer_SavePost")
;~ 	Local $taskName
;~ 	; Sửa định dạng ngày
;~ 	Local $checkDate = StringSplit($arrayCheck[9],"/",2)
;~ 	If @error Then
;~ 		Local $checkDate = StringSplit($arrayCheck[9],"-",2)
;~ 		If @error Then
;~ 			ErrorShow(16,"Thông báo lỗi","Xin vui lòng nhập ngày theo định dạng ngày/tháng/năm hoặc ngày-tháng-năm")
;~ 			Return 0
;~ 		EndIf
;~ 	EndIf
;~ 	For $i = 0 To 2
;~ 		If StringLen($checkDate[$i]) = 1 Then
;~ 			$checkDate[$i] = 0 & $checkDate[$i]
;~ 		EndIf
;~ 	Next
;~ 	Local $dateEnd = $checkDate[2] & "-" & $checkDate[1] & "-" & $checkDate[0]
;~ 	; Sửa định dạng giờ
;~ 	Local $checkPM = StringRegExp($arrayCheck[10]," PM",0)
;~ 	Local $time = StringSplit($arrayCheck[10],":",2)
;~ 	If $checkPM = 1 And $time[0] < 12 Then
;~ 		$time[0] += 12
;~ 	ElseIf $checkPM = 0 And $time[0] = 12 Then
;~ 		$time[0] = "00"
;~ 	EndIf
;~ 	For $i = 0 To UBound($time) - 1
;~ 		If StringLen($time[$i]) = 1 Then
;~ 			$time[$i] = 0 & $time[$i]
;~ 		EndIf
;~ 	Next
;~ 	Local $postName = GUICtrlRead($__g_idList_Timer_TaskName)
;~ 	Local $timeEnd = StringRegExpReplace(_ArrayToString($time,":")," AM| PM","")
;~ 	Local $timeTask = $dateEnd & "T" & $timeEnd
;~ 	If $postName = "Tin đăng hiện tại" Then
;~ 		If $__g_s_CurrentPostName = "" Then
;~ 			Post_Manager_SavePost()
;~ 		EndIf
;~ 		$taskName = _StringToBase64($__g_s_CurrentPostName)
;~ 	Else
;~ 		$taskName = _StringToBase64($postName)
;~ 	EndIf
;~ 	_TS_TaskDelete($__g_o_ConnectTask, $__g_folder_TaskName & "\" & $taskName)
;~ 	Global $oTaskDefinition = _TS_TaskCreate($__g_o_ConnectTask)
;~ 	If @error Then
;~ 		ErrorShow(16,"","Hẹn giờ thất bại #1")
;~ 		RegWrite($REG_SAVEPOST & $taskName,"status","REG_SZ","Chưa hẹn giờ")
;~ 		Return 0
;~ 	EndIf

;~ 	Local $import = '<?xml version="1.0" encoding="UTF-16"?>|<Task version="1.3" xmlns="http://schema'
;~ 	$import &= 's.microsoft.com/windows/2004/02/mit/task">|  <RegistrationInfo>|    <URI>'
;~ 	$import &= $__g_folder_TaskName & "\" & $taskName & '</URI>|  </RegistrationInfo>|  <Triggers>|    <TimeTrigger>|      <StartBoun'
;~ 	$import &= 'dary>'&$timeTask&'</StartBoundary>|      <ExecutionTimeLimit>PT30M</Execut'
;~ 	$import &= 'ionTimeLimit>|      <Enabled>true</Enabled>|    </TimeTrigger>|  </Triggers>|  <'
;~ 	$import &= 'Principals>|    <Principal id="Author">|      <LogonType>InteractiveToken</LogonType>|  '
;~ 	$import &= '    <RunLevel>LeastPrivilege</RunLevel>|    </Principal>|  </Principals>|  <Sett'
;~ 	$import &= 'ings>|    <MultipleInstancesPolicy>Queue</MultipleInstancesPolicy>|    <Disallow'
;~ 	$import &= 'StartIfOnBatteries>false</DisallowStartIfOnBatteries>|    <StopIfGoingOnBatterie'
;~ 	$import &= 's>false</StopIfGoingOnBatteries>|    <AllowHardTerminate>true</AllowHardTerminat'
;~ 	$import &= 'e>|    <StartWhenAvailable>false</StartWhenAvailable>|    <RunOnlyIfNetworkAvail'
;~ 	$import &= 'able>true</RunOnlyIfNetworkAvailable>|    <IdleSettings>|      <StopOnIdleEnd>tr'
;~ 	$import &= 'ue</StopOnIdleEnd>|      <RestartOnIdle>false</RestartOnIdle>|    </IdleSettings'
;~ 	$import &= '>|    <AllowStartOnDemand>true</AllowStartOnDemand>|    <Enabled>true</Enabled>|'
;~ 	$import &= '    <Hidden>false</Hidden>|    <RunOnlyIfIdle>false</RunOnlyIfIdle>|    <Disallo'
;~ 	$import &= 'wStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>|    <UseUnified'
;~ 	$import &= 'SchedulingEngine>true</UseUnifiedSchedulingEngine>|    <WakeToRun>true</WakeToRu'
;~ 	$import &= 'n>|    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>|    <Priority>7</Priority>|'
;~ 	$import &= '  </Settings>|  <Actions Context="Author">|    <Exec>|      <Command>"'
;~ 	$import &= @ScriptFullPath '"</Command>|      <Arguments>'
;~ 	$import &= '</Arguments>|    </Exec>|  </Actions>|</Task>'

;~ 	Local $aResult = _TS_TaskImportXML($__g_o_ConnectTask,2,StringReplace($import,"|",@CRLF))
;~ 	If @error Then
;~ 		ErrorShow(16,"","Hẹn giờ thất bại #2",3)
;~ 		RegWrite($REG_SAVEPOST & $taskName,"status","REG_SZ","Chưa hẹn giờ")
;~ 		Return 0
;~ 	EndIf
;~ 	Local $password = GUICtrlRead($__g_idInput_Timer_Password)
;~ 	Local $taskRegister = _TS_TaskRegister($__g_o_ConnectTask,$__g_folder_TaskName,$taskName,$aResult,Default,Default,3)
;~ 	If @error Then
;~ 		ErrorShow(16,"","Hẹn giờ thất bại #3",3)
;~ 		RegWrite($REG_SAVEPOST & $taskName,"status","REG_SZ","Chưa hẹn giờ")
;~ 		Return 0
;~ 	EndIf
;~ 	RegWrite($REG_SAVEPOST & $taskName,"afterPost","REG_SZ",$arrayCheck[11])
;~ 	RegWrite($REG_SAVEPOST & $taskName,"webNumber","REG_SZ",$arrayCheck[12])
;~ 	RegWrite($REG_SAVEPOST & $taskName,"status","REG_SZ","Đã hẹn giờ")
;~ 	RegWrite($REG_SAVEPOST & $taskName,"date","REG_SZ",$checkDate[0] & "/" & $checkDate[1] & "/" & $checkDate[2])
;~ 	RegWrite($REG_SAVEPOST & $taskName,"time","REG_SZ",$timeEnd)
	; Xóa kết quả của lần chạy trước
;~ 	RegDelete($REG_SAVEPOST & $taskName,"$__g_a_ErrorPosting")
;~ 	RegDelete($REG_SAVEPOST & $taskName,"$__g_a_PostLink")
;~ 	RegDelete($REG_SAVEPOST & $taskName,"resultTask")
;~ 	GetTaskName() ; Load lại danh sách task
;~ 	ErrorShow(64,"Thành công","Hẹn giờ thành công",2)
;~ 	; Tạo file .bat để chạy
;~ 	Local $openFile = FileOpen(@ScriptDir & "\Data\Main Data\" & $taskName & ".bat",2 + 8)
;~ 	Local $content = 'start "" "' & @ScriptDir & '\Data\Main Data\Install.sys" "' & @ScriptFullPath & '" /post "' & $taskName & '"'
;~ 	$content &= @CRLF & 'DEL "' & '%~f0' & '"' & ' & exit'
;~ 	FileWrite($openFile,$content)
;~ 	FileClose($openFile)
;~ 	Timer_SavePassword()
EndFunc

;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name ..........: Timer_SavePassword
;~ ; Description ...: Lưu mật khẩu máy tính của người dùng
;~ ; Syntax ........: Timer_SavePassword()
;~ ; Parameters ....: None
;~ ; Return values .: None
;~ ; Author ........: Your Name
;~ ; Modified ......:
;~ ; Remarks .......:
;~ ; Related .......:
;~ ; Link ..........:
;~ ; Example .......: No
;~ ; ===============================================================================================================================
;~ Func Timer_SavePassword()
;~ 	Write_Log("====================")
;~ 	Write_Log("+ Timer_SavePassword")
;~ 	RegWrite($__g_folder_config,"secret_key","REG_SZ",GUICtrlRead($__g_idInput_Timer_Password))
;~ EndFunc

;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name ..........: Timer_CheckParam
;~ ; Description ...: Check người dùng có phải đang muốn đăng tin param không?
;~ ; Activate when .: Khi người dùng mở Tool
;~ ; Syntax ........: Timer_CheckParam()
;~ ; Return values .: None
;~ ; Author ........: Trần Hùng
;~ ; Modified ......: 22/04/2022
;~ ; ===============================================================================================================================
;~ Func Timer_CheckParam()
;~ 	Write_Log("====================")
;~ 	Write_Log("+ Timer_CheckParam")
;~ 	If $CmdLine[0] > 0 Then
;~ 		If $CmdLine[1] = "/post" Then
;~ 			_TrayTip("Thông báo","Chuẩn bị đăng tin: " & $CmdLine[2],5)
;~ 			RegWrite($REG_SAVEPOST & $CmdLine[2],"resultTask","REG_SZ","Bước 1: Chuẩn bị đăng tin")
;~ 			Timer_Post($CmdLine[2])
;~ 			Exit
;~ 		EndIf
;~ 	EndIf
;~ EndFunc

;~ Func Timer_Post($postName)
;~ 	Write_Log("====================")
;~ 	Write_Log("+ Timer_Post")
;~ 	RegWrite($REG_SAVEPOST & $postName,"resultTask","REG_SZ",Timer_GetTaskResult($postName) & "|Bước 2: Kiểm tra thông tin")
;~ 	; Lấy số lượng website (Để hiển thị khi người dùng kiểm tra)
;~ 	Local $webNumber = RegRead($REG_SAVEPOST & $postName,"webNumber")
;~ 	; Làm gì sau khi đăng tin xong
;~ 	Local $afterPost = RegRead($REG_SAVEPOST & $postName,"afterPost")
;~ 	; Đọc website And Title
;~ 	Local $readWebAndTitle = RegRead($REG_SAVEPOST & $postName,"webAndTitle")
;~ 	If $readWebAndTitle = "" Then
;~ 		RegWrite($REG_SAVEPOST & $postName,"resultTask","REG_SZ",Timer_GetTaskResult($postName) & "|Không tìm thấy website để đăng tin")
;~ 		Return 0
;~ 	Else
;~ 		Global $arrayMain = StringSplit2D($readWebAndTitle,"|",@LF)
;~ 	EndIf
;~ 	; Lấy thông tin cơ bản
;~ 	Local $postType = RegRead($REG_SAVEPOST & $postName,"postTypeIndex")
;~ 	Local $estateType = RegRead($REG_SAVEPOST & $postName,"estateTypeIndex")
;~ 	Local $room = RegRead($REG_SAVEPOST & $postName,"roomIndex")
;~ 	Local $wc = RegRead($REG_SAVEPOST & $postName,"wcIndex")
;~ 	Local $acr = RegRead($REG_SAVEPOST & $postName,"acr")
;~ 	Local $price = RegRead($REG_SAVEPOST & $postName,"price")
;~ 	Local $priceType = RegRead($REG_SAVEPOST & $postName,"priceTypeIndex")
;~ 	Local $content = StringReplace(RegRead($REG_SAVEPOST & $postName,"content"),"|",@CRLF)
;~ 	Local $readImage = RegRead($REG_SAVEPOST & $postName,"imageLink")
;~ 	Local $directAdrress = RegRead($REG_SAVEPOST & $postName,"addressDirect")
;~ 	Local $webAndDateVip = RegRead($REG_SAVEPOST & $postName,"webAndDateVip")
;~ 	If $webAndDateVip = "" Then
;~ 		RegWrite($REG_SAVEPOST & $postName,"resultTask","REG_SZ",Timer_GetTaskResult($postName) & "|Không thể load webAndDateVip từ bài viết đã lưu")
;~ 		Return 0
;~ 	Else
;~ 		Global $__g_a_WebAndDateVip = StringSplit2D($webAndDateVip,"|",@LF)
;~ 	EndIf

;~ 	If IsArray($__g_a_WebAndDateVip) = 0 Then
;~ 		RegWrite($REG_SAVEPOST & $postName,"resultTask","REG_SZ",Timer_GetTaskResult($postName) & "|$__g_a_WebAndDateVip không có giá trị")
;~ 		Return 0
;~ 	EndIf

;~ 	Local $jsonFile = '{"postTypeIndex":"","estateTypeIndex":"","room":"","wc":"","acr":"","price":0,"priceType":"","content":"","image":"","title":"","cityID":"","cityName":"","districtID":"","districtName":"","wardID":"","wardName":"","streetID":"","streetName":"","projectID":"","projectName":"","address":"","vipIndex":"","option1":"","option2":"","date":""}'
;~ 	Local $jsonCheck = _HttpRequest_ParseJSON($jsonFile)
;~ 	If @error Then
;~ 		RegWrite($REG_SAVEPOST & $postName,"resultTask","REG_SZ",Timer_GetTaskResult($postName) & "|Gặp lỗi khi tạo biến JSON")
;~ 		Return 0
;~ 	EndIf

;~ 	$jsonCheck.postTypeIndex = $postType
;~ 	$jsonCheck.estateTypeIndex = $estateType
;~ 	$jsonCheck.room = $room
;~ 	$jsonCheck.wc = $wc
;~ 	$jsonCheck.acr = $acr
;~ 	Local $price2 = StringReplace($price, ",", ".")
;~ 	$jsonCheck.price = $price2
;~ 	$jsonCheck.priceType = $priceType
;~ 	$jsonCheck.content = $content
;~ 	$jsonCheck.image = $readImage
;~ 	$jsonCheck.address = $directAdrress
;~ 	Global $__g_a_PostLink[0][2]
;~ 	Global $__g_a_ErrorPosting[0][2]
;~ 	For $i = 0 To UBound($arrayMain) - 1
;~ 		Local $indexWebVip = _ArraySearch($__g_a_WebAndDateVip,$arrayMain[$i][0])
;~ 		If $indexWebVip <> -1 Then
;~ 			$jsonCheck.title = $arrayMain[$i][2]
;~ 			$jsonCheck.cityName = $arrayMain[$i][3]
;~ 			$jsonCheck.cityID = $arrayMain[$i][5]
;~ 			$jsonCheck.districtName = $arrayMain[$i][7]
;~ 			$jsonCheck.districtID = $arrayMain[$i][9]
;~ 			$jsonCheck.wardName = $arrayMain[$i][11]
;~ 			$jsonCheck.wardID = $arrayMain[$i][13]
;~ 			$jsonCheck.streetName = $arrayMain[$i][15]
;~ 			$jsonCheck.streetID = $arrayMain[$i][17]
;~ 			$jsonCheck.projectName = $arrayMain[$i][19]
;~ 			$jsonCheck.projectID = $arrayMain[$i][21]
;~ 			$jsonCheck.vipIndex = $__g_a_WebAndDateVip[$indexWebVip][1]
;~ 			$jsonCheck.option1 = $__g_a_WebAndDateVip[$indexWebVip][2]
;~ 			$jsonCheck.option2 = $__g_a_WebAndDateVip[$indexWebVip][3]
;~ 			$jsonCheck.date = $__g_a_WebAndDateVip[$indexWebVip][4]
;~ 			Switch $arrayMain[$i][0]
;~ 				Case "Batdongsan.com.vn"
;~ 					Local $resultPost = PostingBatdongsan($jsonCheck.toStr())
;~ 				Case "Dothi.net"
;~ 					Local $resultPost = PostingDothi($jsonCheck.toStr())
;~ 				Case "Muaban.net"
;~ 					Local $resultPost = PostingMuaban($jsonCheck.toStr())
;~ 				Case "Bds123.vn"
;~ 					Local $resultPost = PostingBds123($jsonCheck.toStr())
;~ 				Case "Alonhadat.com.vn"
;~ 					Local $resultPost = PostingAlonhadat($jsonCheck.toStr())
;~ 				Case "i-batdongsan.com"
;~ 					Local $resultPost = PostingIbatdongsan($jsonCheck.toStr())
;~ 				Case "123nhadatviet.com"
;~ 					Local $resultPost = Posting123nhadatvietcom($jsonCheck.toStr())
;~ 				Case "123nhadatviet.net"
;~ 					Local $resultPost = Posting123nhadatvietnet($jsonCheck.toStr())
;~ 				Case "i-nhadat.com"
;~ 					Local $resultPost = PostingInhadat($jsonCheck.toStr())
;~ 				Case "Nhadatviet247.net"
;~ 					Local $resultPost = PostingNhadatviet247($jsonCheck.toStr())
;~ 				Case "Batdongsan24h.com.vn"
;~ 					Local $resultPost = PostingBatdongsan24h($jsonCheck.toStr())
;~ 				Case "Timmuanhadat.com.vn"
;~ 					Local $resultPost = PostingTimmuanhadat($jsonCheck.toStr())
;~ 				Case "Sosanhnha.com"
;~ 					Local $resultPost = PostingSosanhnha($jsonCheck.toStr())
;~ 				Case "Batdongsan.vn"
;~ 					Local $resultPost = PostingBatdongsanvn($jsonCheck.toStr())
;~ 				Case "Tinbatdongsan.com"
;~ 					Local $resultPost = PostingTinbatdongsan($jsonCheck.toStr())
;~ 				Case "Chotot.com"
;~ 					Local $resultPost = PostingChotot($jsonCheck.toStr())
;~ 				Case "Thuecanho123.com"
;~ 					Local $resultPost = PostingThuecanho123($jsonCheck.toStr())
;~ 				Case "Dotproperty.com.vn"
;~ 					Local $resultPost = PostingDotproperty_Main($jsonCheck.toStr())
;~ 			EndSwitch
;~ 			If $resultPost <> "" Then
;~ 				Local $arraySplit = StringSplit($resultPost,":::",3)
;~ 				If UBound($arraySplit) < 3 Then
;~ 					ContinueLoop
;~ 				EndIf
;~ 				Switch $arraySplit[0]
;~ 					Case "True"
;~ 						_ArrayAdd($__g_a_PostLink,$arraySplit[1] & "|" & $arraySplit[2])
;~ 					Case "False"
;~ 						_ArrayAdd($__g_a_ErrorPosting,$arraySplit[1] & "|" & $arraySplit[2])
;~ 				EndSwitch
;~ 			EndIf
;~ 		EndIf
;~ 	Next
;~ 	RegWrite($REG_SAVEPOST & $postName,"$__g_a_PostLink","REG_MULTI_SZ",_ArrayToString($__g_a_PostLink,"|",-1,-1,@LF))
;~ 	RegWrite($REG_SAVEPOST & $postName,"$__g_a_ErrorPosting","REG_MULTI_SZ",_ArrayToString($__g_a_ErrorPosting,"|",-1,-1,@LF))
;~ 	RegWrite($REG_SAVEPOST & $postName,"status","REG_SZ","Đã đăng tin")
;~ 	_TrayTip("Thông báo","Đăng tin thành công",5,1)
;~ 	; Phần sau sẽ check xem người dùng sẽ sleep hay là tắt máy
;~ 	Local $checkSleep = RegRead($REG_SAVEPOST & $postName,"afterPost")
;~ 	If $checkSleep = "Sleep" Then
;~ 		Shutdown($SD_STANDBY)
;~ 		Exit
;~ 	ElseIf $checkSleep = "Turn Off" Then
;~ 		Local $alert = MsgBox_CountDown("Thông báo","Máy tính sẽ được tắt sau:",20)
;~ 		Switch $alert
;~ 			Case $__g_i_Timeout,$__g_i_CancelButton ; Hết giờ hoặc người dùng ấn Cancel
;~ 				Exit
;~ 			Case Else
;~ 				Shutdown($SD_SHUTDOWN)
;~ 		EndSwitch
;~ 		Exit
;~ 	Else
;~ 		Exit
;~ 	EndIf
;~ EndFunc

;~ Func Timer_GetTaskResult($postName)
;~ 	Write_Log("====================")
;~ 	Write_Log("+ Timer_GetTaskResult")
;~ 	Return RegRead($REG_SAVEPOST & $postName,"resultTask")
;~ EndFunc

;~ Func Timer_DeleteTask()
;~ 	Local $taskName = GUICtrlRead($__g_idList_Timer_TaskName)
;~ 	Switch $taskName
;~ 		Case "","Tin đăng hiện tại"
;~ 			Return SetError(1)
;~ 		Case Else
;~ 			If _TS_TaskDelete($__g_o_ConnectTask,$__g_folder_TaskName & "\" & $taskName) = 1 Then
;~ 				GetTaskName()
;~ 				ErrorShow(64,"Xóa tác vụ","Xóa tác vụ thành công",2)
;~ 				Return True
;~ 			Else
;~ 				ErrorShow(16,"Xóa tác vụ","Xóa tác vụ thất bại")
;~ 				Return SetError(2)
;~ 			EndIf
;~ 	EndSwitch
;~ EndFunc

;~ Func Timer_CheckResult()
;~ 	Write_Log("====================")
;~ 	Write_Log("+ Timer_CheckResult")
;~ 	Local $taskName = GUICtrlRead($__g_idList_Timer_TaskName)
;~ 	Switch $taskName
;~ 		Case "","Tin đăng hiện tại"
;~ 			Return SetError(1)
;~ 		Case Else
;~ 			Post_Manager_EditPost($taskName)
;~ 			_GUICtrlTab_ActivateTab($__g_idTab_Main,5)
;~ 	EndSwitch
;~ EndFunc