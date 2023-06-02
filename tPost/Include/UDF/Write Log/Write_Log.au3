Global Const $CONSOLE_ERROR = 16
Global Const $CONSOLE_SUCCESS = 32
Global Const $CONSOLE_WARNING = 48
Global Const $CONSOLE_INFO = 64
Global Const $CONSOLE_NONE = 0
; #FUNCTION# ====================================================================================================================
; Name ..........: Write_Log
; Description ...: Hiển trị Console - Hỗ trợ tiếng Việt
; Syntax ........: Write_Log($data)
; Parameters ....: $data                - a binary variant value.
; Author ........: Trần Hùng
; Remarks .......: Phải include dưới ConsoleWriteVi
; ===============================================================================================================================
Func Write_Log($data,$type = $CONSOLE_NONE)
	Switch $type
		Case $CONSOLE_ERROR
			ConsoleWriteVi("! " & $data & " ❌" & @CRLF)
		Case $CONSOLE_SUCCESS
			ConsoleWriteVi("> " & $data & " ✅" & @CRLF)
		Case $CONSOLE_WARNING
			ConsoleWriteVi("! " & $data & " ⚠" & @CRLF)
		Case $CONSOLE_INFO
			ConsoleWriteVi("> " & $data & " ℹ" & @CRLF)
		Case $CONSOLE_NONE
			ConsoleWriteVi($data & @CRLF)
	EndSwitch
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: ErrorShow
; Description ...: Hiển thị thông báo
; Syntax ........: ErrorShow($type, $title, $value[, $timeout = 0])
; Parameters ....: $type                - Loại Msgbox.
;                  $title               - Tiêu đề.
;                  $value               - Nội dung.
;                  $timeout             - Thời gian tắt Msgbox(tính bằng s). Default is 0.
; Author ........: Trần Hùng
; ===============================================================================================================================
Func ErrorShow($type,$title = "",$value = "",$timeout = 0)
	If $title == "" Then
		$title = "Khoan, dừng khoảng chừng là 2s"
	EndIf
	Local $valueEnd = StringReplace($value,"\n", @CRLF)
	Return MsgBox($type + 8192 + 262144,$title,$valueEnd,$timeout)
EndFunc