Global $__g_a_ResultSuccess[0]
Global $__g_a_ResultFail[0]
; #FUNCTION# ====================================================================================================================
; Name ..........: Re_Posting_Error
; Description ...: Đăng lại những trang bị lỗi
; Syntax ........: Re_Posting_Error()
; Parameters ....: None
; Return values .: None
; ===============================================================================================================================
Func Re_Posting_Error()
	If UBound($__g_a_ResultFail) = 0 Then
		ErrorShow($CONSOLE_ERROR,"","Không có trang nào để đăng cả")
		Return SetError(1)
	EndIf

	For $i = 0 To UBound($__g_a_ResultSuccess) - 1
		Local $indexDelete = _ArraySearch($arrayMain,$__g_a_ResultSuccess[$i])
		If $indexDelete <> -1 Then
			Write_Log("Đã xóa vị trí: " & $indexDelete)
			_ArrayDelete($arrayMain,$indexDelete)
		EndIf
	Next
	; Reset Tab 1
	GUICtrlSetData($__g_idList_ChooseWeb_Post,"|")
	GUICtrlSetData($__g_idList_ChooseWeb_Current,"|")
	ChooseWeb_LoadWebFromList()
	; Reset Tab 3
	GUICtrlSetData($__g_idList_Tab3_Post,"|")
	GUICtrlSetData($__g_idEdit_Tab3_Title,"Tiêu đề")
	GUICtrlSetData($__g_idButton_Tab3_TitleLen,"Độ dài tiêu đề")
	; Reset Tab 4
	GUICtrlSetData($__g_idList_Tab3_Post,"|")
	; Điền lại
	For $i = 0 To UBound($arrayMain) - 1
		GUICtrlSetData($__g_idList_ChooseWeb_Post,$arrayMain[$i][0])
		GUICtrlSetData($__g_idList_Tab3_Post,$arrayMain[$i][0])
		GUICtrlSetData($__g_idList_Address_Site,$arrayMain[$i][0])
	Next
	_GUICtrlTab_ActivateTab($__g_idTab_Main,3)
EndFunc