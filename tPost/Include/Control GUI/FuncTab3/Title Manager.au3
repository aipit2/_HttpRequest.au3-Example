; Load danh sách web để nhập tiêu đề
; Name ..........: TitleManager_LoadSite
; Description ...: Load danh sách web để nhập tiêu đề
; Kích hoạt khi  : Người dùng chuyển sang tab tiêu đề
; Syntax ........: TitleManager_LoadSite()
; Return values .: 1 - Không tìm thấy giá trị $arrayMain
;                : 2 - Người dùng chưa chọn website
;                : True - Load danh sách web
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $__g_idTab_Main - id Tab chính
;                : $__g_idList_ChooseWeb_Current - Listbox tên các web trong danh sách hiện tại
;                : $__g_idList_Tab3_Post - Listbox tên các web trong danh sách cần đăng
; Chỉnh sửa ......: 07/10/2022
Func TitleManager_LoadSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_LoadSite")
	If IsArray($arrayMain) = 0 Then ; Nếu lỗi thì return
		ErrorShow(16,"Lỗi nghiêm trọng","Không tìm thấy giá trị $arrayMain",3)
		Return SetError(1)
	EndIf
	If UBound($arrayMain) = 0 Then ; Nếu người dùng chưa chọn web
		ErrorShow(48,"","Xin vui lòng thêm website trước",3)
		_GUICtrlTab_ActivateTab($__g_idTab_Main,0)
		GUICtrlSetState($__g_idList_ChooseWeb_Current,256) ; Focus vào danh sách hiện tại để người dùng có thể chọn luôn
		Return SetError(2)
	EndIf
	TitleManager_SortTitle() ; Sắp xếp lại tiêu đề
	GUICtrlSetData($__g_idList_Tab3_Post,"|" & _ArrayToString($arrayMain,"|",-1,-1,"|",0,0))
	_GUICtrlListBox_ClickItem($__g_idList_Tab3_Post,0) ; Click vào trang đầu tiên
	Return True
EndFunc

; Sắp xếp lại trang web (Tiêu đề ngắn lên trên)
; Name ..........: TitleManager_SortTitle
; Description ...: Sắp xếp lại trang web (Tiêu đề ngắn lên trên)
; Kích hoạt khi  : Người dùng chuyển sang tab tiêu đề
; Syntax ........: TitleManager_SortTitle()
; Return values .: True - Sắp xếp thành công
;                : @error - 1 - Không tìm thấy giá trị $arrayMain
;                : @error - 2 - Người dùng chưa chọn web
;                : @error - 3 - _ArraySort() bị lỗi
;                : @error - 4 - _ArrayToString() bị lỗi
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $arrayMain - Mảng danh sách website và giới hạn tiêu đề
;                : $__g_idList_Tab3_Post - Listbox tên các web trong danh sách cần đăng
; Modified		 : 12/08/2022
Func TitleManager_SortTitle()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_SortTitle")
	If IsArray($arrayMain) = 0 Then
		ErrorShow(16,"Lỗi nghiêm trọng","Không tìm thấy giá trị $arrayMain",3)
		Return SetError(1)
	EndIf
	If UBound($arrayMain) = 0 Then ; Nếu người dùng chưa chọn web
		Return SetError(2)
	EndIf
	; Thêm limit vào dánh sách web $site|$limit|$title
	; So sánh từng web ở mảng chính với từng web ở mảng limit
	; Nếu thấy giống thì copy limit sang mảng chính
	For $i = 0 To UBound($WEB_LIMIT) - 1
		For $i2 = 0 To UBound($arrayMain) - 1
			If $WEB_LIMIT[$i][$eSite] = $arrayMain[$i2][$eSite] Then
				$arrayMain[$i2][$eLimit] = Number($WEB_LIMIT[$i][$eLimit]) ; Đoạn này phải chuyển thành number thì mới Sort được
				ExitLoop
			EndIf
		Next
	Next
	; Sắp xếp lại array theo limit từ nhỏ đến lớn
	Local $sort = _ArraySort($arrayMain,0,0,0,1)
	If $sort = 0 Then
		ErrorShow(16,"Lỗi nghiêm trọng","Không thể sắp xếp tiêu đề",3)
		Return SetError(3)
	EndIf
	; Hiển thị danh sách lên GUI
	Local $arrayWeb = _ArrayToString($arrayMain,"|",-1,-1,"|",0,0)
	If $arrayWeb = -1 Then
		ErrorShow(16,"Lỗi nghiêm trọng","Không thể hiển thị danh sách web",3)
		Return SetError(4)
	EndIf
	GUICtrlSetData($__g_idList_Tab3_Post,"|" & $arrayWeb)
	Return True
EndFunc

; Đếm độ dài tiêu đề và lưu đang chỉnh sửa
; Name ..........: TitleManager_CountTitle
; Description ...: Đếm độ dài tiêu đề và lưu đang chỉnh sửa
; Kích hoạt khi	 : Người dùng sử dụng bàn phím để chỉnh sửa tiêu đề
; Syntax ........: TitleManager_CountTitle()
; Return values .: 1 - Đếm và lưu thành công
;                : 0 - _GUICtrlListBox_GetCurSel() bị lỗi
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $__g_idList_Tab3_Post - Listbox tên các web trong danh sách cần đăng
;                : $__g_idEdit_Tab3_Title - Edit tiêu đề
;                : $__g_idButton_Tab3_TitleLen - Button hiển thị độ dài tiêu đề
; Modified		 : 12/08/2022
Func TitleManager_CountTitle()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_CountTitle")
	; Lấy vị trang hiện tại
	Local $currentIndexSite = _GUICtrlListBox_GetCurSel($__g_idList_Tab3_Post)
	If $currentIndexSite = -1 Then ; Nếu lỗi thì thôi
		GUICtrlSetData($__g_idEdit_Tab3_Title,"")
		ErrorShow(48,'',"Không tìm thấy vị trí trang tin" & @CRLF & "Xin vui lòng thử lại")
		Return 0
	EndIf
	Local $titleInGUI = StringReplace(GUICtrlRead($__g_idEdit_Tab3_Title),@CRLF,"")
	Local $titleLength = StringLen($titleInGUI)
	GUICtrlSetData($__g_idButton_Tab3_TitleLen,"Độ dài tiêu đề: " & $titleLength & "/" & $arrayMain[$currentIndexSite][$eLimit])
	Write_Log("Trang bạn chọn: " & $arrayMain[$currentIndexSite][$eSite])
	Write_Log("Độ dài tiêu đề: " & $titleLength)
	Write_Log("Giới hạn tiêu đề: " & $arrayMain[$currentIndexSite][$eLimit])
	; Lưu tiêu đề vào biến
	$arrayMain[$currentIndexSite][$eTitle] = $titleInGUI
	Return 1
EndFunc

; Load tiêu đề đã lưu tra GUI
; Name ..........: TitleManger_LoadTitle
; Description ...: Load tiêu đề đã lưu tra GUI
; Kích hoạt khi	 : Người dùng chuyển sang tab tiêu đề
; Được gọi khi   : Người dùng click vào danh sách trang web tại tab tiêu đề
; Syntax ........: TitleManger_LoadTitle()
; Return values .: 1 - Load tiêu đề thành công
;                : 0 - _GUICtrlListBox_GetCurSel() Bị lỗi
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $__g_idList_Tab3_Post - Listbox tên các web trong danh sách cần đăng
;                : $__g_idEdit_Tab3_Title - Edit tiêu đề
;                : $__g_idButton_Tab3_TitleLen - Button hiển thị độ dài tiêu đề
;                : $__g_h_MainGUI - handle GUI chính
; Modified		 : 12/08/2022
Func TitleManager_LoadTitle()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManger_LoadTitle")
	Local $indexWeb = _GUICtrlListBox_GetCurSel($__g_idList_Tab3_Post)
	If $indexWeb = -1 Then
		ErrorShow(16,"Thông báo lỗi nghiêm trọng","Không tìm thấy vị trí trang web" & @CRLF & "Xin vui lòng thử lại",3)
		Return 0
	EndIf
	GUICtrlSetData($__g_idEdit_Tab3_Title,$arrayMain[$indexWeb][2])
	GUICtrlSetData($__g_idButton_Tab3_TitleLen,"Độ dài tiêu đề: " & StringLen($arrayMain[$indexWeb][2]) & "/" & $arrayMain[$indexWeb][1])
	GUICtrlSetLimit($__g_idEdit_Tab3_Title,$arrayMain[$indexWeb][1])
	GUICtrlSetState($__g_idEdit_Tab3_Title,256) ; Focus
	ControlSend($__g_h_MainGUI, "", $__g_idEdit_Tab3_Title, "{END}")
	Return 1
EndFunc

; Load tiêu đề trên tiêu đề hiện tại
; Name ..........: TitleManager_LastTitle
; Description ...: Load tiêu đề trên tiêu đề hiện tại
; Syntax ........: TitleManager_LastTitle()
; Return values .: True - Load tiêu đề thành công
;                : 0 - _GUICtrlListBox_GetCurSel() bị lỗi
;                : 1 - Người dùng đang chọn trang đầu tiên
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $__g_idList_Tab3_Post - Listbox tên các web trong danh sách cần đăng
;                : $__g_idEdit_Tab3_Title - Edit tiêu đề
;                : CountTitle() - Dùng để lưu tiêu đề sau khi load
;~ Func TitleManager_LastTitle()
;~ 	Write_Log("=====================")
;~ 	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
;~ 	Write_Log("+ TitleManager_LastTitle")
;~ 	Local $indexWeb = _GUICtrlListBox_GetCurSel($__g_idList_Tab3_Post)
;~ 	If $indexWeb = -1 Then
;~ 		ErrorShow(16,"Thông báo lỗi nghiêm trọng","Không tìm thấy vị trí trang hiện tại" & @CRLF & "Xin vui lòng thử lại")
;~ 		Return 0
;~ 	ElseIf $indexWeb = 0 Then
;~ 		Return 1
;~ 	EndIf
;~ 	Local $lastTitle = $arrayMain[$indexWeb - 1][2]
;~ 	$arrayMain[$indexWeb][2] = $lastTitle
;~ 	GUICtrlSetData($__g_idEdit_Tab3_Title,$lastTitle)
;~ 	TitleManager_CountTitle() ; Đếm và lưu tiêu đề
;~ 	Return True
;~ EndFunc

; Điền tiêu đề tất cả những trang bên dưới giống với trang hiện tại
; Name ..........: TitleManager_CompleteTitle
; Description ...: Điền tiêu đề tất cả những trang bên dưới giống với trang hiện tại
; Syntax ........: TitleManager_CompleteTitle()
; Return values .: 1 - Điền thành công
;                : 0 - _GUICtrlListBox_GetCurSel() bị lỗi
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $__g_idList_Tab3_Post - Listbox tên các web trong danh sách cần đăng
;                : $__g_idEdit_Tab3_Title - Edit tiêu đề
;                : $__g_h_MainGUI - handle GUI chính
;                : LoadTitle() - Dùng để đếm độ dài tiêu đề và hiển thị giới hạn
; Modified		 : 13/08/2022
Func TitleManager_CompleteTitle()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_CompleteTitle")
	Local $webIndex = _GUICtrlListBox_GetCurSel($__g_idList_Tab3_Post)
	Switch $webIndex
		Case -1
			ErrorShow(16,'',"Gặp lỗi khi tự động nhập" & @CRLF & "Xin vui lòng thử lại",3)
			Return 0
		Case Else
			Local $currentTitle = $arrayMain[$webIndex][$eTitle]
			For $i = $webIndex To UBound($arrayMain) - 1
				$arrayMain[$i][$eTitle] = $currentTitle
			Next
			ControlSend($__g_h_MainGUI, "", $__g_idEdit_Tab3_Title, "{END}")
			Local $totalSite = UBound($arrayMain) - 1
			Local $selectedTitle = $arrayMain[$totalSite][$eSite]
			_GUICtrlListBox_SelectString($__g_idList_Tab3_Post,$selectedTitle)
			TitleManager_LoadTitle() ; Đếm độ dài tiêu đề và hiển thị giới hạn
			Return 1
	EndSwitch
EndFunc

; Xóa tất cả tiêu đề đã lưu
; Name ..........: TitleManager_RemoveAllTitle
; Description ...: Xóa tất cả tiêu đề đã lưu
; Kích hoạt khi  : Người dùng bấm vào nút "Nhập lại" tại TAB tiêu đề
; Syntax ........: TitleManager_RemoveAllTitle()
; Return values .: 1 - Xóa thành công
;                : 0 - $arrayMain bị lỗi
; Author ........: Trần Hùng
; Global var ....: $arrayMain - Mảng danh sách website và tiêu đề
;                : $__g_idEdit_Tab3_Title - Edit tiêu đề
; Modified ......: 12/08/2022
Func TitleManager_RemoveAllTitle()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_RemoveAllTitle")
	If IsArray($arrayMain) = 0 Then
		ErrorShow(16,"Lỗi nghiêm trọng","Không tìm thấy giá trị $arrayMain")
		Return 0
	EndIf
	; Reset tất cả tiêu đề
	For $i = 0 To UBound($arrayMain) - 1
		$arrayMain[$i][2] = ""
	Next
	; Xóa tiêu đề đã nhập
	GUICtrlSetData($__g_idEdit_Tab3_Title,"")
	GUICtrlSetState($__g_idEdit_Tab3_Title,256) ; Focus
	Return 1
EndFunc

; Chuyển trang trang tiếp theo khi người dùng ấn TAB
; Name ..........: TitleManager_NextSite
; Description ...: Chuyển trang trang tiếp theo khi người dùng ấn TAB
; Syntax ........: TitleManager_NextSite()
; Return values .: None
; Author ........: Trần Hùng
; Modified ......: 13/08/2022
Func TitleManager_NextSite()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_NextSite")
	; Get tổng site
	Local $totalSite = UBound($arrayMain)
	; Get vị trí hiện tại
	Local $currentIndexSite = _GUICtrlListBox_GetCurSel($__g_idList_Tab3_Post)
	; Click vị trí tiếp theo, nếu ở cuối cùng thì click vị trí đầu tiên
	Switch $currentIndexSite
		Case $totalSite - 1 ; Vị trí cuối cùng
			_GUICtrlListBox_ClickItem($__g_idList_Tab3_Post,0)
		Case Else
			_GUICtrlListBox_ClickItem($__g_idList_Tab3_Post,$currentIndexSite + 1)
	EndSwitch
EndFunc

; Điền tiêu đề cuối cùng được lưu vào tiêu đề hiện tại
; Name ..........: TitleManager_LastTitle
; Description ...: Điền tiêu đề cuối cùng được lưu vào tiêu đề hiện tại
; Syntax ........: TitleManager_LastTitle()
; Return values .: None
; Author ........: Trần Hùng
; Modified ......: 15/08/2022
Func TitleManager_LastTitle()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_LastTitle")

	Local $currentIndexSite = _GUICtrlListBox_GetCurSel($__g_idList_Tab3_Post)
	Switch $currentIndexSite
		Case -1,0
			Return 0
		Case Else
			Local $lastTitle = $arrayMain[$currentIndexSite - 1][$eTitle]
			If $lastTitle <> "" Then
				GUICtrlSetData($__g_idEdit_Tab3_Title,$lastTitle)
				TitleManager_SaveTitle($currentIndexSite,$lastTitle)
			EndIf
	EndSwitch
EndFunc

; Lưu tiêu đề vào mảng
; Name ..........: TitleManager_SaveTitle
; Description ...: Lưu tiêu đề vào mảng
; Syntax ........: TitleManager_SaveTitle($index, $value)
; Parameters ....: $index               - vị trí muốn lưu tiêu đề trong mảng.
;                  $value               - giá trị muốn lưu.
; Author ........: Trần Hùng
; Modified ......: 15/08/2022
Func TitleManager_SaveTitle($index,$value)
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab3/Title Manager.au3")
	Write_Log("+ TitleManager_SaveTitle")
	$arrayMain[$index][$eTitle] = $value
EndFunc
