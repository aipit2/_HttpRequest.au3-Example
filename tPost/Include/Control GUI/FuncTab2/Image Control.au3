; Thêm ảnh vào tin 						- 11/08/2022
; Name ..........: Tab2_AddImage
; Description ...: Thêm ảnh vào tin
; Syntax ........: Tab2_AddImage()
; Return values .: 0 - Thất bại
;                : $__g_a_ImageLink: Mảng chứa link hình ảnh
; Author ........: Trần Hùng
; Global var ....: $__g_a_ImageLink: Mảng chứa link hình hình ảnh
;                : $__g_idEdit_Tab2_Image: Edit chứa tên hình ảnh
;                : $__g_idButton_Tab2_Infor: Button thông tin hình ảnh và nội dung
Func Tab2_AddImage()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab2/Image Control.au3")
	Write_Log("+ Tab2_AddImage")
	Local $Files
	If $__g_b_TestingMode = True Then

	EndIf
	Local $Files = FileOpenDialog("Chọn ảnh","","Hình ảnh (*.jpg;*.jpeg)",7); 1,2,4
	If @error Then
		Return 0
	Else
		Local $array = StringSplit($Files,"|",2)
		If UBound($array) = 1 Then
			_ArrayAdd($__g_a_ImageLink,$array[0])
		ElseIf UBound($array) > 1 Then
			For $i = 1 To UBound($array) - 1
				_ArrayAdd($__g_a_ImageLink,$array[0] & "\" & $array[$i])
			Next
		EndIf
		Local $Unique = _ArrayUnique($__g_a_ImageLink,0,0,0,0) ; Xóa những phần tử lặp lại
		Local $arrayShow[0]
		For $i = 0 To UBound($Unique) - 1
			_ArrayAdd($arrayShow,StringRegExpReplace($Unique[$i], "^.*\\", ""))
		Next
		$__g_a_ImageLink = $Unique
		GUICtrlSetData($__g_idEdit_Tab2_Image,_ArrayToString($arrayShow,@CRLF))
		GUICtrlSetData($__g_idButton_Tab2_Infor,"Hình ảnh: " & UBound($arrayShow))
		Return $__g_a_ImageLink
	EndIf
EndFunc

; Xóa tất cả hình ảnh hiện tại 			- 11/08/2022
; Name ..........: Tab2_RemoveImage
; Description ...: Xóa tất cả hình ảnh hiện tại
; Syntax ........: Tab2_RemoveImage()
; Author ........: Trần Hùng
; Global var ....: $__g_a_ImageLink: Mảng chứa link hình hình ảnh
;                : $__g_idEdit_Tab2_Image: Edit chứa tên hình ảnh
;                : $__g_idButton_Tab2_Infor: Button thông tin hình ảnh và nội dung
Func Tab2_RemoveImage()
	Write_Log("=====================")
	Write_Log("+ include/Control GUI/FuncTab2/Image Control.au3")
	Write_Log("+ Tab2_RemoveImage")
	Global $__g_a_ImageLink[0]
	GUICtrlSetData($__g_idEdit_Tab2_Image,"Hình ảnh")
	GUICtrlSetData($__g_idButton_Tab2_Infor,"Hình ảnh: 0")
EndFunc