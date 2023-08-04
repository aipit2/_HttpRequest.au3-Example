Global Const $DATA_DIR = @ScriptDir & "\data"
Global Const $FILE_SITELIST = $DATA_DIR & "\site.data"
Global Const $BILL_DIR = @ScriptDir & "\Bill-" & @MDAY & "-" & @MON
Global Const $CAPTCHA_DIR = $DATA_DIR & "\captcha.bmp"

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <GuiComboBox.au3>

#include <include/_HttpRequest/_HttpRequest.au3>
#include <include/Image Convert/png2bmp.au3>
Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=F:\Tai hoa don\Version 2\Form1.kxf
Global $Form1_1 = GUICreate("Download E-Invoice - Code By Tran Hung - v2.0", 1643, 823, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_TABSTOP))
Global $Group1 = GUICtrlCreateGroup("Website", 40, 32, 633, 745)
GUICtrlSetFont(-1, 14, 400, 0, "Arial")
Global $List1 = GUICtrlCreateList("", 64, 64, 585, 678, BitOR($LBS_NOTIFY,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetFont(-1, 20, 400, 0, "Arial")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button1 = GUICtrlCreateButton("Chon trang", 744, 664, 369, 113)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Button2 = GUICtrlCreateButton("Tai hoa don", 1209, 664, 369, 113)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Label1 = GUICtrlCreateLabel("Ma chinh: ", 704, 48, 183, 49)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Label2 = GUICtrlCreateLabel("Ma phu: ", 704, 105, 156, 49)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Input1 = GUICtrlCreateInput("Input1", 920, 36, 657, 53)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Input2 = GUICtrlCreateInput("Input2", 920, 101, 657, 53)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Label4 = GUICtrlCreateLabel("Lua chon: ", 704, 170, 186, 49)
GUICtrlSetFont(-1, 30, 400, 0, "Arial")
Global $Combo1 = GUICtrlCreateCombo("", 920, 176, 657, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 20, 400, 0, "Arial")
Global $Pic1 = GUICtrlCreatePic("", 704, 232, 193, 81)
Global $Input3 = GUICtrlCreateInput("Input3", 920, 230, 657, 83)
GUICtrlSetFont(-1, 50, 400, 0, "Arial")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUICtrlSetOnEvent($List1	,"changeSite")
GUICtrlSetOnEvent($Button2	,"downloadInvoice")
GUICtrlSetOnEvent($Combo1	,"changeOption")
GUICtrlSetOnEvent($Pic1		,"changeCaptcha")

GUICtrlSetData($Button1, "Chọn trang")
GUICtrlSetData($Button2, "Tải hóa đơn")
GUICtrlSetData($Label1, "Mã chính")
GUICtrlSetData($Label2, "Mã phụ")
GUICtrlSetData($Label4, "Lựa chọn")
GUICtrlSetData($Input1, "")
GUICtrlSetData($Input2, "")
GUICtrlSetData($Input3, "")
GUICtrlSendMsg($Input3, $EM_SETCUEBANNER, False, "Captcha...")

GUICtrlSetState($Button1,$GUI_HIDE)

GUICtrlSetCursor($Button2,$MCID_HAND)

GUISetBkColor(0x6BAAF8,$Form1_1)

Local $loadSite = loadSite()
If @error Then
	MsgBox(16 + 8192 + 262144, "Thông báo lỗi", $loadSite)
	_Exit()
EndIf
checkBillDir()
hideControl()

#include <include/centroport.au3>
#include <include/eir.tanvandepot.com.au3>
#include <include/5deir.centroport.com.vn.au3>
#include <include/meinvoice.vn.au3>
#include <include/tctdeir.centroport.vn.au3>
#include <include/cbceir.tcol.vn.au3>
#include <include/ehoadon.vn.au3>
#include <include/tracuuhoadon.minvoice.com.vn.au3>
#include <include/vnpt-invoice.com.vn.au3>
#include <include/eticket.pmh.com.vn.au3>

While 1
	Sleep(100)
WEnd

Func _Exit()
	Exit
EndFunc   ;==>_Exit

; #FUNCTION# ====================================================================================================================
; Name ..........: checkBillDir
; Description ...: Kiểm tra xem thư mục chứa hóa đơn ngày hôm nay đã được tạo chưa, nếu chưa thì tạo
; Syntax ........: checkBillDir()
; Parameters ....: None
; Return values .: None
; ===============================================================================================================================
Func checkBillDir()
	If FileExists($BILL_DIR) == 0 Then
		Return DirCreate($BILL_DIR)
	EndIf
EndFunc   ;==>checkBillDir


; #FUNCTION# ====================================================================================================================
; Name ..........: loadSite
; Description ...: Load dánh sách trang web
; Syntax ........: loadSite()
; Parameters ....: None
; Return values .: @error - 1: Không tìm thấy file site.data
;				.: True - Load thành công
; ===============================================================================================================================
Func loadSite()
	Local $arraySite = FileReadToArray($FILE_SITELIST)
	If @error Then
		Return SetError(1, 0, "Không thể load danh sách website")
	EndIf
	GUICtrlSetData($List1, _ArrayToString($arraySite))
	Return True
EndFunc   ;==>loadSite

; #FUNCTION# ====================================================================================================================
; Name ..........: changeSite
; Description ...: Kích hoạt khi chuyển sang trang web khác
; Syntax ........: changeSite()
; Parameters ....: None
; Return values .: None
; ===============================================================================================================================
Func changeSite()
	clearContent()
	hideControl()
	Local $currentSite = GUICtrlRead($List1)
	Switch $currentSite
		Case "eir.tanvandepot.com"
			showControl("Mã chính|Mã phụ")
			changeLabelName("Eir Code","Container Code")
		Case "5deir.centroport.com.vn","tctdeir.centroport.vn","cbceir.tcol.vn"
			showControl("Mã chính|Captcha|Options")
			changeLabelName("Mã tra cứu")
			GUICtrlSetData($Combo1,"|Tải Eir|Tải hóa đơn")
			_GUICtrlComboBox_SetCurSel($Combo1,0)
		Case "meinvoice.vn"
			showControl("Mã chính|Options")
			ChangeLabelName("Mã khách hàng: ")
			GUICtrlSetData($Combo1,"|Tiếp Vận Tâm Cảng Cát Lái|Tâm Cảng Thủ Đức|SINOVNL Cát Lái")
			_GUICtrlComboBox_SetCurSel($Combo1,0)
		Case "ehoadon.vn"
			showControl("Mã chính")
			ChangeLabelName("Mã tra cứu: ")
		Case "tracuuhoadon.minvoice.com.vn"
			showControl("Mã chính|Mã phụ")
			ChangeLabelName("Số bảo mật: ","Mã số thuế: ")
		Case StringRegExp($currentSite,"tt78",0) == 1
			showControl("Mã chính|Captcha")
			ChangeLabelName("Mã tra cứu...")
		Case "eticket.pmh.com.vn"
			showControl("Mã chính|Captcha")
			ChangeLabelName("Mã bí mật...")
	EndSwitch

	loadCaptcha($currentSite)
EndFunc   ;==>changeSite

Func clearContent()
	GUICtrlSetData($Input1,"")
	GUICtrlSetData($Input2,"")
	GUICtrlSetData($Combo1,"")
	GUICtrlSetData($Input3,"")
EndFunc

Func changeOption()
	Local $currentSite = GUICtrlRead($List1)
	Local $currentOption = GUICtrlRead($Combo1)
	Switch $currentSite
		Case "5deir.centroport.com.vn","tctdeir.centroport.vn","cbceir.tcol.vn"
			If $currentOption == "Tải hóa đơn" Then
				GUICtrlSetState($Pic1,$GUI_HIDE)
				GUICtrlSetState($Input3,$GUI_HIDE)
			EndIf
	EndSwitch
EndFunc

Func loadCaptcha($site)
	Switch $site
		Case "5deir.centroport.com.vn"
			$5deir_HiddenValue = CentroPort_GetCaptcha($5deir_HOME)
		Case "tctdeir.centroport.vn"
			$tctdeir_HiddenValue = CentroPort_GetCaptcha($tctdeir_HOME)
		Case "cbceir.tcol.vn"
			$cbceir_HiddenValue = CentroPort_GetCaptcha($cbceir_HOME)
		Case "tt78.icdphuclong.com.vn"
			vnptGetCaptcha("cangicdphuclong-tt78.vnpt-invoice.com.vn")
		Case StringRegExp($site,"tt78",0) == 1
			vnptGetCaptcha($site)
		Case "eticket.pmh.com.vn"
			pmh_getCaptcha()
	EndSwitch
	If @error Then
		MsgBox(16 + 8192 + 262144,$site,"Load captcha thất bại")
		Return SetError(1)
	EndIf
	GUICtrlSetImage($Pic1,$CAPTCHA_DIR)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: showControl
; Description ...: Hiện thị các control cần hiện
; Syntax ........: showControl($input)
; Parameters ....: $input               - Control cần hiện.
; Return values .: None
; Example .......: showControl("Mã chính|Mã phụ|Captcha")
; ===============================================================================================================================
Func showControl($input)
	Local $split = StringSplit($input, "|", 2)

	For $i = 0 To UBound($split) - 1
		Switch $split[$i]
			Case "Mã chính"
				GUICtrlSetState($Label1, $GUI_SHOW)
				GUICtrlSetState($Input1, $GUI_SHOW)
			Case "Mã phụ"
				GUICtrlSetState($Label2, $GUI_SHOW)
				GUICtrlSetState($Input2, $GUI_SHOW)
			Case "Options"
				GUICtrlSetState($Label4, $GUI_SHOW)
				GUICtrlSetState($Combo1, $GUI_SHOW)
			Case "Captcha"
				GUICtrlSetState($Pic1, $GUI_SHOW)
				GUICtrlSetState($Input3, $GUI_SHOW)
		EndSwitch
	Next
EndFunc   ;==>showControl

; #FUNCTION# ====================================================================================================================
; Name ..........: hideControl
; Description ...: Ẩn hết tất cả các control
; Syntax ........: hideControl()
; Parameters ....: None
; Return values .: None
; ===============================================================================================================================
Func hideControl()
	For $i = $Label1 To $Input3
		GUICtrlSetState($i, $GUI_HIDE)
	Next
EndFunc   ;==>hideControl

; #FUNCTION# ====================================================================================================================
; Name ..........: changeLabelName
; Description ...: Thay đổi banner của 2 input mã chính, mã phụ
; Syntax ........: changeLabelName([$name1 = ""[, $name2 = ""]])
; Parameters ....: $name1               - giá trị của banner mã chính
;                  $name2               - giá trị của banner mã phụ
; Return values .: None
; Example .......: changeLabelName("Mã tra cứu", "Số container")
; ===============================================================================================================================
Func changeLabelName($name1 = "", $name2 = "")
	GUICtrlSendMsg($Input1, $EM_SETCUEBANNER, False, $name1)
	GUICtrlSendMsg($Input2, $EM_SETCUEBANNER, False, $name2)
EndFunc   ;==>changeLabelName

Func downloadInvoice()
	Local $currentSite 	= GUICtrlRead($List1)
	Local $code1 		= GUICtrlRead($Input1)
	Local $code2 		= GUICtrlRead($Input2)
	Local $captchaInput = GUICtrlRead($Input3)
	Local $option 		= GUICtrlRead($Combo1)
	Local $return
	Switch $currentSite
		Case "eir.tanvandepot.com"
			$return = Eir_TanVanDepot($code1,$code2)
		Case "5deir.centroport.com.vn"
			If $option == "Tải Eir" Then
				$return = CentroPort_CatLai_EirDownload($code1,$captchaInput)
			Else
				$return = meInvoice_BillDownload($code1,'Tiếp Vận Tâm Cảng Cát Lái')
			EndIf
		Case "tctdeir.centroport.vn"
			If $option == "Tải Eir" Then
				$return = CentroPort_ThuDuc_EirDownload($code1,$captchaInput)
			Else
				$return = meInvoice_BillDownload($code1,'Tâm Cảng Thủ Đức')
			EndIf
		Case "cbceir.tcol.vn"
			If $option == "Tải Eir" Then
				$return = cbceir_EirDownload($code1,$captchaInput)
			Else
				$return = meInvoice_BillDownload($code1,'SINOVNL Cát Lái')
			EndIf
		Case "ehoadon.vn"
			$return = ehoadon_DownloadInvoice($code1)
		Case "tracuuhoadon.minvoice.com.vn"
			$return = minvoice_DownloadInvoice($code1,$code2)
		Case StringRegExp($currentSite,"tt78",0) == 1
			$return = vnptDownloadInvoice($code1,$captchaInput,$currentSite)
		Case "eticket.pmh.com.vn"
			$return = pmh_TicketDownload($code1,$captchaInput)
	EndSwitch

	If @error Then
		MsgBox(16 + 8192 + 262144,"Thông báo lỗi: " & $currentSite,$return)
		Return SetError(1,0,"")
	EndIf

	_HttpRequest_Test($return,$BILL_DIR & "/" & $code1 & ".pdf")
	loadCaptcha($currentSite) ; load lại captcha mới
	Return True
EndFunc   ;==>downloadInvoice

Func searchHiddenValues($source,$aValues)
	If IsArray($aValues) = 0 Then
		Return SetError(1,0,"$aValues phải là 1 mảng 1 chiều")
	EndIf

	Local $aReturn[UBound($aValues)]

	For $i = 0 To UBound($aValues) - 1
		Local $searchValue = StringRegExp($source,'<input type="hidden" name="'&$aValues[$i]&'" id=".*" value="(.*?)"',3)
		If @error Then
			Return SetError(2,0,"Không tìm thấy giá trị: " & $aValues[$i])
		EndIf

		$aReturn[$i] = $searchValue[0]
	Next

	Return $aReturn
EndFunc

Func changeCaptcha()
	Local $currentSite = GUICtrlRead($List1)
	loadCaptcha($currentSite)
EndFunc

Func checkProtocol($url)
	_HttpRequest_SetTimeout(100)
	Local $rq = _HttpRequest(1,"https://" & $url)
	If @error Then
		Return "http://" & $url
	EndIf
	Return "https://" & $url
	_HttpRequest_SetTimeout(Default)
EndFunc


