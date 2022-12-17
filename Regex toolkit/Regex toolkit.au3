#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Naamloos.ico
#AutoIt3Wrapper_Res_Comment=Regex toolkit
#AutoIt3Wrapper_Res_Description=Regex toolkit
#AutoIt3Wrapper_Res_Fileversion=1.4.2
#AutoIt3Wrapper_Res_LegalCopyright=Nend Software
#AutoIt3Wrapper_Res_Language=1043
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include <GuiTab.au3>
#include <GuiListView.au3>
#include <TabConstants.au3>
#include <Include\GUIExtender.au3>

Global $input_file_open, $input_website, $input_website_post, $tab_select
Global $input_regex, $input_replace, $edit_textToCheck, $edit_matches, $label_offset
Global $tab, $radio_state, $tabstate, $radio[3], $webinput, $input_offset
Global $dummy_listview_dclick, $listview_help
Global $program_name = "Regex toolkit"

Global $scale = _GetScale()

DllCall("User32.dll", "bool", "SetProcessDPIAware")

_Main()

Func _Main()
	Local $resultHolder, $check_www, $check_regex, $check_replace, $check_offset
	Local $postinput, $radio_state_check, $msgbox, $checktextToCheck

	$gui_handle = GUICreate($program_name & " V1.4.3 is made by Nend Software", 1280 * $scale, 545 * $scale, Default, Default, Default, $WS_EX_ACCEPTFILES)
	_GUIExtender_Init($gui_handle, 1)

	_GUIExtender_Section_Start(0, 700 * $scale)
	GUICtrlCreateGroup("", 10 * $scale, 5 * $scale, 160 * $scale, 90 * $scale)
	$radio[0] = GUICtrlCreateRadio("Match", 15 * $scale, 18 * $scale, 150 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetTip(-1, "Returns True (match) or False (no match)")
	$radio[1] = GUICtrlCreateRadio("Array of matches", 15 * $scale, 43 * $scale, 150 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetTip(-1, "Return array of global matches")
	$radio[2] = GUICtrlCreateRadio("Match and replace", 15 * $scale, 68 * $scale, 150 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetTip(-1, "Returns an updated string based on regular expressions")

	_GUIExtender_Section_Action(2, "", "", 904 * $scale, 12 * $scale, 20 * $scale, 15 * $scale)
	GUICtrlSetCursor(-1, 0)

	$tab = GUICtrlCreateTab(180 * $scale, 10 * $scale, 745 * $scale, 85 * $scale, $TCS_SINGLELINE)

	Local $tab_website = GUICtrlCreateTabitem("Insert website data")
	GUICtrlSetImage(-1, "shell32.dll", -14, 0)
	Local $label_website = GUICtrlCreateLabel("Website URL", 190 * $scale, 42 * $scale, 70 * $scale, 17 * $scale)
	$input_website = GUICtrlCreateInput("", 270 * $scale, 40 * $scale, 646 * $scale, 20 * $scale)

	Local $label_website_post = GUICtrlCreateLabel("POST", 190 * $scale, 67 * $scale, 60 * $scale, 17 * $scale)
	$input_website_post = GUICtrlCreateInput("", 270 * $scale, 65 * $scale, 646 * $scale, 20 * $scale)

	Local $tab_file = GUICtrlCreateTabitem("Insert file data")
	GUICtrlSetImage(-1, "shell32.dll", -55, 0)
	Local $label_file_open = GUICtrlCreateLabel("File open", 190 * $scale, 42 * $scale, 65 * $scale, 17 * $scale)
	$input_file_open = GUICtrlCreateInput("", 270 * $scale, 40 * $scale, 511 * $scale, 20 * $scale)
	Local $Button_file_open = GUICtrlCreateButton("Browse", 785 * $scale, 40 * $scale, 130 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)

	Local $tab_clear = GUICtrlCreateTabitem("Clear fields")
	GUICtrlSetImage(-1, "shell32.dll", -110, 0)
	Local $button_clear_all = GUICtrlCreateButton("Clear all fields", 190 * $scale, 40 * $scale, 130 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)
	Local $button_clear_website = GUICtrlCreateButton("Clear website fields", 190 * $scale, 65 * $scale, 130 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)
	Local $button_clear_file = GUICtrlCreateButton("Clear file fields", 325 * $scale, 40 * $scale, 130 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)

	Local $tab_export = GUICtrlCreateTabitem("Export/Import settings")
	GUICtrlSetImage(-1, "shell32.dll", -4, 0)
	Local $button_export = GUICtrlCreateButton("Export settings", 190 * $scale, 40 * $scale, 130 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)
	Local $button_import = GUICtrlCreateButton("Import settings", 190 * $scale, 65 * $scale, 130 * $scale, 20 * $scale)
	GUICtrlSetCursor(-1, 0)

	Local $label_draganddrop = GUICtrlCreateLabel("Ini file can be drag and droped to import settings", 380 * $scale, 40 * $scale, 490 * $scale, 20 * $scale)

	Local $tab_code = GUICtrlCreateTabitem("Create AutoIt code"); Create AutoIt Code
	GUICtrlSetImage(-1, "shell32.dll", -71, 0)

	GUICtrlCreateTabitem("")

	GUICtrlCreateGroup("", 10 * $scale, 95 * $scale, 913 * $scale, 70 * $scale)
	Local $label_regex = GUICtrlCreateLabel("Regex", 15 * $scale, 112 * $scale, 50 * $scale, 17 * $scale)
	$input_regex = GUICtrlCreateInput("", 80 * $scale, 110 * $scale, 726 * $scale, 21 * $scale)

	$label_offset = GUICtrlCreateLabel("Offset", 820 * $scale, 112 * $scale, 50 * $scale, 17 * $scale)
	$input_offset = GUICtrlCreateInput("1", 861 * $scale, 110 * $scale, 55 * $scale, 21 * $scale, $ES_NUMBER)
	GUICtrlSetTip($input_offset, "The string position to start the match (starts at 1)." & @CRLF & " The default is 1.")

	Local $label_replace = GUICtrlCreateLabel("Replace", 15 * $scale, 137 * $scale, 50 * $scale, 17 * $scale)
	$input_replace = GUICtrlCreateInput("", 80 * $scale, 135 * $scale, 836 * $scale, 21 * $scale)

	Local $label_Output = GUICtrlCreateLabel("Text data", 10 * $scale, 175 * $scale, 415 * $scale, 17 * $scale)
	Local $label_gevonden = GUICtrlCreateLabel("Regular expression output data", 535 * $scale, 175 * $scale, 288 * $scale, 17 * $scale)

	$edit_textToCheck = GUICtrlCreateEdit("", 10 * $scale, 195 * $scale, 515 * $scale, 339 * $scale)
	$edit_matches = GUICtrlCreateEdit("", 535 * $scale, 195 * $scale, 388 * $scale, 339 * $scale)

	_GUIExtender_Section_End()

	_GUIExtender_Section_Start(700 * $scale, 345 * $scale)
	Local $label_madeby = GUICtrlCreatelabel("CheatSheet --> double click to insert function", 935 * $scale, 10 * $scale, 335 * $scale, 20 * $scale, $SS_CENTER)

	$listview_help = GUICtrlCreateListView("||", 935 * $scale, 32 * $scale, 335 * $scale, 379 * $scale, $LVS_NOCOLUMNHEADER)

	_GUICtrlListView_SetColumnWidth($listview_help, 0, 80)
	_GUICtrlListView_SetColumnWidth($listview_help, 1, 230)

	$listview_help_array = _Cheatsheet()

	For $i = 0 To UBound($listview_help_array) -1
		_GUICtrlListView_AddItem($listview_help, $listview_help_array[$i][0], $i)
		_GUICtrlListView_AddSubItem($listview_help, $i, $listview_help_array[$i][1], 1)
	Next

	GUICtrlCreateGroup("", 935 * $scale, 415 * $scale, 335 * $scale, 121 * $scale)
	Local $label_websites = GUICtrlCreateLabel("Useful Regular Expressions websites and helpfile:", 945 * $scale, 425 * $scale, 315 * $scale, 20 * $scale)
	Local $weblink_1 = _GuiCtrlCreateHyperlink("https://regexone.com", 945 * $scale, 451 * $scale, 125 * $scale, 20 * $scale, 0x132B80, "Learn Regular Expressions with simple, interactive exercises")
	Local $weblink_2 = _GuiCtrlCreateHyperlink("https://regex101.com", 945 * $scale, 471 * $scale, 125 * $scale, 20 * $scale, 0x132B80, "Online Regular Expresions creator")
	Local $weblink_3 = _GuiCtrlCreateHyperlink("http://www.regular-expressions.info", 945 * $scale, 491 * $scale, 208 * $scale, 20 * $scale, 0x132B80, "The Premier website about Regular Expressions")
	Local $weblink_4 = _GuiCtrlCreateHyperlink("Start AutoIt help file", 945 * $scale, 511 * $scale, 208 * $scale, 20 * $scale, 0x132B80, "Start AutoIt help file")

	_GUIExtender_Section_End()

	GUICtrlSetState($radio[1], $GUI_CHECKED)
	$radio_state = 1
	GUICtrlSetState($input_replace, $GUI_DISABLE)

	$dummy_listview_dclick = GUICtrlCreateDummy()

	GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
	GUIRegisterMsg($WM_DROPFILES, "_WM_DROPFILES_FUNC")
	GUISetState(@SW_SHOW)

	While 1
		$msg = GUIGetMsg()
		_GUIExtender_Action($msg)
		Switch $msg
			Case $weblink_1
				ShellExecute("https://regexone.com")
			Case $weblink_2
				ShellExecute("https://regex101.com")
			Case $weblink_3
				ShellExecute("http://www.regular-expressions.info")
			Case $weblink_4
				_Start_helpfile()
			Case $tab
				Switch GUICtrlRead($tab)
					Case 0
						$webinput = ""
						$tab_select = 0
					Case 1
						If GUICtrlRead($input_file_open) <> "" Then
							If FileExists(GUICtrlRead($input_file_open)) Then
								GUICtrlSetData($edit_textToCheck, FileRead(GUICtrlRead($input_file_open)))
							EndIf
						EndIf
						$tab_select = 1
					Case 2
						$tab_select = 2
					Case 3
						$tab_select = 3
					Case 4
						_GUICtrlTab_ActivateTab($tab, $tab_select)
						_Generate_code()
				EndSwitch
			Case $button_clear_all
				$msg = MsgBox(1, $program_name, "This will clear all fields" & @CRLF & "Do you wish to continue?", Default, $gui_handle)
				If $msg = 1 Then
					GUICtrlSetData($input_website, "")
					GUICtrlSetData($input_website_post, "")
					GUICtrlSetData($input_regex, "")
					GUICtrlSetData($input_offset, 1)
					GUICtrlSetData($input_file_open, "")
					GUICtrlSetData($input_replace, "")
					GUICtrlSetData($edit_matches, "")
					GUICtrlSetData($edit_textToCheck, "")
				EndIf
			Case $button_clear_website
				$msg = MsgBox(1, $program_name, "This will clear all website fields" & @CRLF & "Do you wish to continue?", Default, $gui_handle)
				If $msg = 1 Then
					GUICtrlSetData($input_website, "")
					GUICtrlSetData($input_website_post, "")
					GUICtrlSetData($edit_matches, "")
					GUICtrlSetData($edit_textToCheck, "")
				EndIf
			Case $button_clear_file
				$msg = MsgBox(1, $program_name, "This will clear the file open fields" & @CRLF & "Do you wish to continue?", Default, $gui_handle)
				If $msg = 1 Then
					GUICtrlSetData($input_file_open, "")
					GUICtrlSetData($edit_matches, "")
					GUICtrlSetData($edit_textToCheck, "")
				EndIf
			Case $Button_file_open
				$file_data = FileOpenDialog("Choose file", @ScriptDir, "All text files (*.*)")
				If $file_data <> "" Then
					GUICtrlSetData($input_file_open, $file_data)
					GUICtrlSetData($edit_textToCheck, FileRead($file_data))
					$tabstate = 1
				EndIf
			Case $radio[0]
				GUICtrlSetState($input_replace, $GUI_DISABLE)
				GUICtrlSetData($input_replace, "")
				If GUICtrlRead($input_offset) = "" Or GUICtrlRead($input_offset) = 0 Then
					GUICtrlSetData($input_offset, 1)
				EndIf
				GUICtrlSetData($label_offset, "Offset")
				GUICtrlSetTip($input_offset, "The string position to start the match (starts at 1)." & @CRLF & "The default is 1.")
				$radio_state = 0
			Case $radio[1]
				GUICtrlSetState($input_replace, $GUI_DISABLE)
				GUICtrlSetData($input_replace, "")
				If GUICtrlRead($input_offset) = "" Or GUICtrlRead($input_offset) = 0 Then
					GUICtrlSetData($input_offset, 1)
				EndIf
				GUICtrlSetData($label_offset, "Offset")
				GUICtrlSetTip($input_offset, "The string position to start the match (starts at 1)." & @CRLF & "The default is 1.")
				$radio_state = 1
			Case $radio[2]
				GUICtrlSetState($input_replace, $GUI_ENABLE)
				GUICtrlSetData($input_offset, 0)
				GUICtrlSetData($label_offset, "Count")
				GUICtrlSetTip($input_offset, "The number of times to execute the replacement in the string." & @CRLF & "The default is 0." & @CRLF & "Use 0 for global replacement.")
				$radio_state = 2
			Case $button_export
				$save_file = FileSaveDialog("Regex toolkit export file", @DesktopDir, "Regex toolkit file (*.inx)")
				If $save_file <> "" Then
					If FileExists($save_file) Then
						$msgbox = MsgBox(0, $program_name, "This file already exits" & @CRLF & "File is not saved", Default, $gui_handle)
					Else
						IniWrite($save_file, "Website", "URL", GUICtrlRead($input_website))
						IniWrite($save_file, "Website", "POST", GUICtrlRead($input_website_post))

						IniWrite($save_file, "File", "File name", GUICtrlRead($input_file_open))

						IniWrite($save_file, "Regular expression", "Regex", GUICtrlRead($input_regex))
						IniWrite($save_file, "Regular expression", "Replace", GUICtrlRead($input_replace))
						IniWrite($save_file, "Regular expression", "Choice", $radio_state)
						If GUICtrlRead($radio[2]) = $GUI_UNCHECKED Then
							IniWrite($save_file, "Regular expression", "Count", GUICtrlRead($input_offset))
						Else
							IniWrite($save_file, "Regular expression", "Offset", GUICtrlRead($input_offset))
						EndIf
						If GUICtrlRead($input_website) = "" Then
							IniWrite($save_file, "Text", "text", GUICtrlRead($edit_textToCheck))
						EndIf
						MsgBox(0, $program_name, "Settings are saved", 2, $gui_handle)
					EndIf
				EndIf
			Case $dummy_listview_dclick
				If _GUICtrlListView_GetSelectedCount($listview_help) Then
					$return_array = _GUICtrlListView_GetItemTextArray($listview_help, Number(_GUICtrlListView_GetSelectedIndices($listview_help)))
					GUICtrlSetData($input_regex, GUICtrlRead($input_regex) & $return_array[1])
				EndIf
			Case $button_import
				$open_file = FileOpenDialog("Regex toolkit import file", @DesktopDir, "Regex toolkit file (*.inx)")
				If $open_file <> "" Then
					_Import($open_file, $gui_handle)
				EndIf
			Case $GUI_EVENT_CLOSE
				Exit
		EndSwitch

		If GUICtrlRead($input_regex) <> $check_regex _
			Or GUICtrlRead($input_website) <> $check_www _
			Or GUICtrlRead($edit_textToCheck) <> $ChecktextToCheck _
			Or $radio_state <> $radio_state_check _
			Or GUICtrlRead($input_replace) <> $check_replace _
			Or GUICtrlRead($input_offset) <> $check_offset Then

			GUICtrlSetData($edit_matches, "")
			If GUICtrlRead($input_regex) <> "" Then
				If GUICtrlRead($input_offset) = "" And GUICtrlRead($radio[2]) = $GUI_UNCHECKED Then
					GUICtrlSetData($input_offset, 1)
				EndIf

				_GUICtrlEdit_BeginUpdate($edit_matches)
				Switch $radio_state
					Case 0
						$resultHolder = StringRegExp(GUICtrlRead($edit_textToCheck), GUICtrlRead($input_regex), $STR_REGEXPMATCH, GUICtrlRead($input_offset))
						If @error = 2 Then
							GUICtrlSetColor($input_regex, 0xFF0000)
						Else
							GUICtrlSetColor($input_regex, 0x000000)
						EndIf
						If $resultHolder = 1 Then
							_GUICtrlEdit_AppendText($edit_matches, True)
						Else
							_GUICtrlEdit_AppendText($edit_matches, False)
						EndIf
					Case 1
						$resultHolder = StringRegExp(GUICtrlRead($edit_textToCheck), GUICtrlRead($input_regex), $STR_REGEXPARRAYGLOBALMATCH, GUICtrlRead($input_offset))
						If @error = 2 Then
							GUICtrlSetColor($input_regex, 0xFF0000)
						Else
							GUICtrlSetColor($input_regex, 0x000000)
						EndIf
						For $i = 0 To UBound($resultHolder) - 1
							_GUICtrlEdit_AppendText($edit_matches, $resultHolder[$i] & @CRLF)
						Next
						GUICtrlSetData($label_gevonden, "Regular expression output data (" & $i & ")")
					Case 2
						_GUICtrlEdit_AppendText($edit_matches, StringRegExpReplace(GUICtrlRead($edit_textToCheck), GUICtrlRead($input_regex), GUICtrlRead($input_replace), GUICtrlRead($input_offset)))
				EndSwitch
				_GUICtrlEdit_EndUpdate($edit_matches)
			EndIf
			If GUICtrlRead($edit_textToCheck) <> "" Then
				GUICtrlSetData($label_Output, "Text data (update time " & @HOUR & ":" & @MIN & ":" & @SEC & ")")
			Else
				GUICtrlSetData($label_Output, "Text data")
			EndIf
			$check_offset = GUICtrlRead($input_offset)
			$check_regex = GUICtrlRead($input_regex)
			$check_www = GUICtrlRead($input_website)
			$checktextToCheck = GUICtrlRead($edit_textToCheck)
			$check_replace = GUICtrlRead($input_replace)
			$radio_state_check = $radio_state
		EndIf

		If GUICtrlRead($input_website) <> "" Then
			If GUICtrlRead($input_website) <> $webinput Or GUICtrlRead($input_website_post) <> $postinput Then
				If StringInStr(GUICtrlRead($input_website), ".") Then
					GUICtrlSetData($edit_textToCheck, _Post_send(GUICtrlRead($input_website), GUICtrlRead($input_website_post)))
					$webinput = GUICtrlRead($input_website)
					$postinput = GUICtrlRead($input_website_post)
					$tabstate = 0
				EndIf
			EndIf
		EndIf
	WEnd
EndFunc

Func _Generate_code()
	Local $show_code
	If GUICtrlRead($edit_textToCheck) <> "" And GUICtrlRead($edit_matches) <> "" Then
		If GUICtrlRead($input_website) = "" And GUICtrlRead($input_file_open) = "" Then
			Switch $radio_state
					Case 0
						$show_code = '#include <StringConstants.au3>' & @CRLF & @CRLF & _
									 'Local $return = StringRegExp("' & GUICtrlRead($edit_textToCheck) & '", "' & GUICtrlRead($input_regex) & '", $STR_REGEXPMATCH, ' & GUICtrlRead($input_offset) & ')' & @CRLF & @CRLF & _
									 'If $return Then' & @CRLF & _
									 '	Consolewrite("Regulair Expression is a match")' & @CRLF & _
									 'Else' & @CRLF & _
									 '	Consolewrite("Regulair Expression is not a match")' & @CRLF & _
									 'EndIf'
					Case 1
						$show_code = '#include <Array.au3>' & @CRLF & _
									 '#include <StringConstants.au3>' & @CRLF & @CRLF & _
									 'Local $array = StringRegExp("' & GUICtrlRead($edit_textToCheck) & '", "' & GUICtrlRead($input_regex) & '", $STR_REGEXPARRAYGLOBALMATCH, ' & GUICtrlRead($input_offset) & ')' & @CRLF & _
									 '_ArrayDisplay($array)'
					Case 2
						$show_code = 'Local $return = StringRegExpReplace("' & GUICtrlRead($edit_textToCheck) & '", "' & GUICtrlRead($input_regex) & '", "' & GUICtrlRead($input_replace) & '", ' & GUICtrlRead($input_offset) & ')' & @CRLF & _
									 'Consolewrite($return & @CRLF)'
				EndSwitch
		Else
			Switch $tabstate
			Case 0
				Switch $radio_state
					Case 0
						$show_code = '#include <StringConstants.au3>' & @CRLF & @CRLF & _
									 'Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")' & @CRLF & _
									 'If Not @error Then' & @CRLF & _
									 '	$oHTTP.Open("POST", "' & GUICtrlRead($input_website) & '")' & @CRLF & _
									 '	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")' & @CRLF & _
									 '	$oHTTP.Send("' & GUICtrlRead($input_website_post) & '")' & @CRLF & @CRLF & _
									 '	Local $return = StringRegExp($oHTTP.ResponseText, "' & GUICtrlRead($input_regex) & '", $STR_REGEXPMATCH, ' & GUICtrlRead($input_offset) & ')' & @CRLF & @CRLF & _
									 '	If $return Then' & @CRLF & _
									 '		Consolewrite("Regulair Expression is a match")' & @CRLF & _
									 '	Else' & @CRLF & _
									 '		Consolewrite("Regulair Expression is not a match")' & @CRLF & _
									 '	EndIf' & @CRLF & _
									 'EndIf'

					Case 1
						$show_code = '#include <Array.au3>' & @CRLF & _
									 '#include <StringConstants.au3>' & @CRLF & @CRLF & _
									 'Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")' & @CRLF & _
									 'If Not @error Then' & @CRLF & _
									 '	$oHTTP.Open("POST", "' & GUICtrlRead($input_website) & '")' & @CRLF & _
									 '	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")' & @CRLF & _
									 '	$oHTTP.Send("' & GUICtrlRead($input_website_post) & '")' & @CRLF & @CRLF & _
									 '	Local $array = StringRegExp($oHTTP.ResponseText, "' & GUICtrlRead($input_regex) & '", $STR_REGEXPARRAYGLOBALMATCH, ' & GUICtrlRead($input_offset) & ')' & @CRLF & _
									 '	_ArrayDisplay($array)' & @CRLF & _
									 'EndIf'

					Case 2
						$show_code = 'Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")' & @CRLF & _
									 'If Not @error Then' & @CRLF & _
									 '	$oHTTP.Open("POST", "' & GUICtrlRead($input_website) & '")' & @CRLF & _
									 '	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")' & @CRLF & _
									 '	$oHTTP.Send("' & GUICtrlRead($input_website_post) & '")' & @CRLF  & @CRLF & _
									 '	Local $return = StringRegExpReplace($oHTTP.ResponseText, "' & GUICtrlRead($input_regex) & '", "' & GUICtrlRead($input_replace) & '", ' & GUICtrlRead($input_offset) & ')' & @CRLF & _
									 '	Consolewrite($return & @CRLF)' & @CRLF & _
									 'EndIf'
				EndSwitch
			Case 1
				Switch $radio_state
					Case 0
						$show_code = '#include <StringConstants.au3>' & @CRLF & @CRLF & _
									 'Local $hfile = FileOpen("' & GUICtrlRead($input_file_open) & '", 0)' & @CRLF & _
									 'Local $file = FileRead($hfile)' & @CRLF & @CRLF & _
									 'Local $return = StringRegExp($file, "' & GUICtrlRead($input_regex) & '", $STR_REGEXPMATCH, ' & GUICtrlRead($input_offset) & ')' & @CRLF & @CRLF & _
									 'If $return Then' & @CRLF & _
									 '	Consolewrite("Regulair Expression is a match")' & @CRLF & _
									 'Else' & @CRLF & _
									 '	Consolewrite("Regulair Expression is not a match")' & @CRLF & _
									 'EndIf' & @CRLF & @CRLF
					Case 1
						$show_code = '#include <Array.au3>' & @CRLF & @CRLF & _
									 '#include <StringConstants.au3>' & @CRLF & _
									 'Local $hfile = FileOpen("' & GUICtrlRead($input_file_open) & '", 0)' & @CRLF & _
									 'Local $file = FileRead($hfile)' & @CRLF & @CRLF & _
									 'Local $array = StringRegExp($file, "' & GUICtrlRead($input_regex) & '", $STR_REGEXPARRAYGLOBALMATCH, ' & GUICtrlRead($input_offset) & ')' & @CRLF & _
									 '_ArrayDisplay($array)' & @CRLF & @CRLF
					Case 2
						$show_code = 'Local $hfile = FileOpen("' & GUICtrlRead($input_file_open) & '", 0)' & @CRLF & _
									 'Local $file = FileRead($hfile)' & @CRLF & @CRLF & _
									 'Local $return = StringRegExpReplace($file, "' & GUICtrlRead($input_regex) & '", "' & GUICtrlRead($input_replace) & '", ' & GUICtrlRead($input_offset) & ')' & @CRLF & _
									 'Consolewrite($return & @CRLF)' & @CRLF & @CRLF
				EndSwitch
				$show_code = $show_code & 'FileClose($hfile)'
			EndSwitch
		EndIf
		ClipPut($show_code)
		MsgBox(64, $program_name, "AutoiIt code has been copied to clipboard")
	EndIf
EndFunc

Func _Import($file, $gui_handle)
	If FileExists($file) Then
		$check_www = ""
		GUICtrlSetData($input_regex, IniRead($file, "Regular expression", "Regex", ""))
		GUICtrlSetData($input_replace, IniRead($file, "Regular expression", "Replace", ""))
		Switch IniRead($file, "Regular expression", "Choice", "")
			Case 0
				$radio_state = 0
				GUICtrlSetState($radio[0], $GUI_CHECKED)
				GUICtrlSetState($input_replace, $GUI_DISABLE)
				GUICtrlSetData($label_offset, "Offset")
				GUICtrlSetTip($input_offset, "The string position to start the match (starts at 1)." & @CRLF & "The default is 1.")
			Case 1
				$radio_state = 1
				GUICtrlSetState($radio[1], $GUI_CHECKED)
				GUICtrlSetState($input_replace, $GUI_DISABLE)
				GUICtrlSetData($label_offset, "Offset")
				GUICtrlSetTip($input_offset, "The string position to start the match (starts at 1)." & @CRLF & "The default is 1.")
			Case 2
				$radio_state = 2
				GUICtrlSetState($radio[2], $GUI_CHECKED)
				GUICtrlSetState($input_replace, $GUI_ENABLE)
				GUICtrlSetData($label_offset, "Count")
				GUICtrlSetTip($input_offset, "The number of times to execute the replacement in the string." & @CRLF & "The default is 0." & @CRLF & "Use 0 for global replacement.")
		EndSwitch
		If IniRead($file, "Regular expression", "Choice", "") = 2 Then
			If IniRead($file, "Regular expression", "Offset", "") = "" Then
				GUICtrlSetData($input_offset, 0)
			Else
				GUICtrlSetData($input_offset, IniRead($file, "Regular expression", "Count", ""))
			EndIf
		Else
			If IniRead($file, "Regular expression", "Offset", "") = "" Then
				GUICtrlSetData($input_offset, 1)
			Else
				GUICtrlSetData($input_offset, IniRead($file, "Regular expression", "Offset", ""))
			EndIf
		EndIf

		GUICtrlSetData($input_website, IniRead($file, "Website", "URL",""))
		GUICtrlSetData($input_website_post, IniRead($file, "Website", "POST", ""))

		GUICtrlSetData($input_file_open, IniRead($file, "File", "File name", ""))
		GUICtrlSetData($edit_textToCheck, IniRead($file, "Text", "Text", ""))

		If GUICtrlRead($input_file_open) <> "" Then
			_GUICtrlTab_ActivateTab($tab, 1)
			$tabstate = 1
		Else
			$tabstate = 0
		EndIf

		$webinput = ""
		MsgBox($IDOK, $program_name, "Settings are loaded", 2, $gui_handle)
	EndIf
EndFunc

Func _Start_helpfile()
	Local $Err

	If @Compiled = 0 Then
		Local $path = StringLeft(@AutoItExe, StringInStr(@AutoItExe, "\", 0, -1))
		Run($path & "AutoIt3Help.exe StringRegExp")
		$Err = @error
	Else
		Local $sWow64 = ""
		If @AutoItX64 Then
			 $sWow64 = "\Wow6432Node"
		EndIf

		Local $sPathToAutoIt = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE" & $sWow64 & "\AutoIt v3\AutoIt", "InstallDir")
		$Err = @error

		If $Err = 0 Then
			Run($sPathToAutoIt & "\AutoIt3Help.exe StringRegExp")
			$Err = @error
		EndIf
	EndIf
	If $Err Then
		MsgBox($MB_SYSTEMMODAL, $program_name, "Help file not found")
	EndIf
EndFunc

Func _WM_DROPFILES_FUNC($hWnd, $msgID, $wParam, $lParam)
 	Local $nSize = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", 0, "ptr", 0, "int", 0)
	$nSize = $nSize[0] + 1
	Local $pFileName = DllStructCreate("char[" & $nSize & "]")
	DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", 0, "ptr", DllStructGetPtr($pFileName), "int", $nSize)
	$gaDropFiles = DllStructGetData($pFileName, 1)
	$pFileName = 0
	_Import($gaDropFiles, $hWnd)
EndFunc

Func _GuiCtrlCreateHyperlink($s_Text, $i_Left, $i_Top, $i_Width = -1, $i_Height = -1, $i_Color = 0x0000ff, $s_ToolTip = '', $i_Style = -1, $i_ExStyle = -1)
    Local $i_CtrlID
    $i_CtrlID = GUICtrlCreateLabel($s_Text, $i_Left, $i_Top, $i_Width, $i_Height, $i_Style, $i_ExStyle)
    If $i_CtrlID <> 0 Then
		GUICtrlSetFont($i_CtrlID, Default, Default, 4)
		GUICtrlSetColor($i_CtrlID, $i_Color)
        GUICtrlSetCursor($i_CtrlID, 0)
        If $s_ToolTip <> '' Then
            GUICtrlSetTip($i_CtrlID, $s_ToolTip)
        EndIf
    EndIf

    Return $i_CtrlID
EndFunc

Func _Post_send($server, $sendstring = "")
	$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	If Not @error Then
		$oHTTP.Open("POST", $server)
		$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		$oHTTP.Send($sendstring)
		Return($oHTTP.ResponseText)
	EndIf
EndFunc

Func _WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case GUICtrlGetHandle($listview_help)
			Switch $iCode
				Case $NM_DBLCLK
					GUICtrlSendToDummy($dummy_listview_dclick)
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
	#forceref $hWnd, $iMsg, $wParam
EndFunc

Func _Cheatsheet()
	Local $listview_help_array[23][2]

	$listview_help_array[0][0] = "abc…"
	$listview_help_array[0][1] = "Letters"
	$listview_help_array[1][0] = "123…"
	$listview_help_array[1][1] = "Digits"
	$listview_help_array[2][0] = "\d"
	$listview_help_array[2][1] = "Any Digit"
	$listview_help_array[3][0] = "\D"
	$listview_help_array[3][1] = "Any Non-digit character"
	$listview_help_array[4][0] = "."
	$listview_help_array[4][1] = "Any Character"
	$listview_help_array[5][0] = "[abc]"
	$listview_help_array[5][1] = "Only a, b, or c"
	$listview_help_array[6][0] = "[^abc]"
	$listview_help_array[6][1] = "Not a, b, nor c"
	$listview_help_array[7][0] = "[a-z]"
	$listview_help_array[7][1] = "Characters a to z"
	$listview_help_array[8][0] = "[0-9]"
	$listview_help_array[8][1] = "Numbers 0 to 9"
	$listview_help_array[9][0] = "\x"
	$listview_help_array[9][1] = "Represents Unicode character from hex"
	$listview_help_array[10][0] = "\w"
	$listview_help_array[10][1] = "Any Non-alphanumeric character"
	$listview_help_array[11][0] = "{m}"
	$listview_help_array[11][1] = "m Repetitions"
	$listview_help_array[12][0] = "{m,n}"
	$listview_help_array[12][1] = "m to n Repetitions"
	$listview_help_array[13][0] = "*"
	$listview_help_array[13][1] = "Zero or more repetitions"
	$listview_help_array[14][0] = "+"
	$listview_help_array[14][1] = "One or more repetitions"
	$listview_help_array[15][0] = "?"
	$listview_help_array[15][1] = "Optional character"
	$listview_help_array[16][0] = "\s"
	$listview_help_array[16][1] = "Any Whitespace"
	$listview_help_array[17][0] = "\S"
	$listview_help_array[17][1] = "Any Non-whitespace character"
	$listview_help_array[18][0] = "^…$"
	$listview_help_array[18][1] = "Starts and ends"
	$listview_help_array[19][0] = "(?i)"
	$listview_help_array[19][1] = "Case-insensitive from that point on"
	$listview_help_array[20][0] = "(…)"
	$listview_help_array[20][1] = "Capture Group"
	$listview_help_array[21][0] = "(a(bc))"
	$listview_help_array[21][1] = "Capture Sub-group"
	$listview_help_array[22][0] = "(.*)"
	$listview_help_array[22][1] = "Capture all"

	Return $listview_help_array
EndFunc

Func _GetScale()
	Local $hWnd = 0
	Local $hDC = DllCall("user32.dll", "long", "GetDC", "long", $hWnd)
    Local $aRet = DllCall("gdi32.dll", "long", "GetDeviceCaps", "long", $hDC[0], "long", 10)  ; = reported vert height ( logical, which is param=90)
    Local $bRet = DllCall("gdi32.dll", "long", "GetDeviceCaps", "long", $hDC[0], "long", 117) ; = true vert pixels of desktop
    $hDC = DllCall("user32.dll", "long", "ReleaseDC", "long", $hWnd, "long", $hDC)
    Return $bRet[0] / $aRet[0]
EndFunc