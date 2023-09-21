#include <Google Sheet API.au3>

Global Const $GGSHEET_SPREADSHEET_ID = "1osWWyExpTIVztzYOVgnXA9cYGhV5kt6Ge0A0djq3YbI" ; Thay thể bằng spreadsheetid của bạn
Global Const $SERVICE_ACCOUNT_DIR = @ScriptDir & "\key.json" ; Thế bằng đường dẫn tới file serivce account của các bác hoặc nội dung file
Global $GGSHEET_ACCESS_TOKEN = Google_Sheet_Create_Access_Token($SERVICE_ACCOUNT_DIR) ; Tạo Access Token ; Hạn dùng 60 phút
; Example đọc dữ liệu 1 ô
Local $value = Google_Sheet_Read($GGSHEET_SPREADSHEET_ID,$GGSHEET_ACCESS_TOKEN,"Sheet1!A1")
If @error Then
	Switch @error
		Case 1 ; Access đã hết hạn chỉ cần tạo lại rồi dùng tiếp
			MsgBox(16,"Thông báo",$value)
			Exit
	EndSwitch
EndIf
MsgBox(0,0,$value.index(0).index(0))

; Example đọc dữ liệu nhiều ô
Local $value = Google_Sheet_Read($GGSHEET_SPREADSHEET_ID,$GGSHEET_ACCESS_TOKEN,"Sheet1!A1:B2")
If @error Then
	Switch @error
		Case 1 ; Access đã hết hạn chỉ cần tạo lại rồi dùng tiếp
			MsgBox(16,"Thông báo",$value)
			Exit
	EndSwitch
EndIf
MsgBox(0,0,$value.toStr())

; Example ghi dữ liệu
Local $value = [["A1 nè!","B1 nè!","C1 nè!"]] ; Dữ liệu cần ghi phải được bỏ vào 1 mảng 2 chiều
Local $write = Google_Sheet_Write($GGSHEET_SPREADSHEET_ID,$GGSHEET_ACCESS_TOKEN,"Sheet1!A1:C1",$value)
If @error Then
	Switch @error
		Case 1 ; Access đã hết hạn chỉ cần tạo lại rồi dùng tiếp
			MsgBox(16,"Thông báo",$write)
			Exit
	EndSwitch
Else
	MsgBox(0,0,"Ghi thành công")
EndIf