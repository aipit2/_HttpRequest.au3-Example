; Đếm độ dài nội dung 					- 11/08/2022
; Name ..........: Tab2_CountContent
; Description ...: Đếm độ dài nội dung
; Syntax ........: Tab2_CountContent()
; Author ........: Trần Hùng
; Global var ....: $__g_idEdit_Tab2_Content: Edit nội dung
;                : $__g_idButton_Tab2_Infor: Button thông tin hình ảnh và nội dung
Func Tab2_CountContent()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab2/Content Counter.au3")
	Write_Log("+ Tab2_CountContent")
	Local $currentString = GUICtrlRead($__g_idEdit_Tab2_Content)
	If $currentString = "Điền nội dung vào đây" Then
		GUICtrlSetData($__g_idEdit_Tab2_Content,"")
		Return False
	EndIf
	Local $len = StringLen($currentString)
	GUICtrlSetData($__g_idButton_Tab2_Infor,"Nội dung: " & $len & "/2000")
	Return $len
EndFunc