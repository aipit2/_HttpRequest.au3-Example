Global $SCITE_RECV_CMD
Global Const $SCITE_IDM_CLOSE = 0x69
Global Const $SCITE_WM_COPYDATA = 0x4A


If Not @Compiled Then
	If __SciTE_SendCommand("askproperty:output.code.page") <> "65001" Then
		__SciTE_SendCommand("property:output.code.page=65001")
		__SciTE_SendCommand($SCITE_IDM_CLOSE)
		__SciTE_SendCommand("open:" & @ScriptFullPath)
	EndIf
	__SciTE_SendCommand("editor:MultiEdgeClearAll()")
Else
	DllCall("Kernel32.dll", "bool", "SetConsoleOutputCP", "uint", 65001) ;CUI
EndIf


Func ConsoleWriteVi($sText)
	ConsoleWrite(BinaryToString(StringToBinary($sText, 4)))
EndFunc


Func __SciTE_SendCommand($sCmd, $msg = 0, $wParam = 0, $lParam = 0)
	#forceref $sCmd, $msg, $wParam, $lParam
	Local Static $hReceiverInterface = 0
	$SCITE_RECV_CMD = Null
	;#
	If @NumParams = 4 Then
		If $sCmd = $hReceiverInterface Then
			Local $tCOPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
			Local $CmdStruct = DllStructCreate('Char[255]', DllStructGetData($tCOPYDATA, 3))
			$SCITE_RECV_CMD = StringLeft(DllStructGetData($CmdStruct, 1), DllStructGetData($tCOPYDATA, 2))
		EndIf

	Else
		If $hReceiverInterface = 0 Then
			$hReceiverInterface = WinGetHandle('--SciTE interface--')
			If @error Or $hReceiverInterface = 0 Then
				$hReceiverInterface = GUICreate("--SciTE interface--")
				GUIRegisterMsg($SCITE_WM_COPYDATA, "__SciTE_SendCommand")
			EndIf
		EndIf
		;#
		Local Static $hSciTE = WinGetHandle("DirectorExtension")
		Local Static $dReceiverInterface = ':' & Number($hReceiverInterface) & ':'
		;#
		$sCmd = StringReplace($sCmd, '\', '\\')
		If IsNumber($sCmd) Or StringIsDigit($sCmd) Then $sCmd = 'menucommand:' & $sCmd
		If StringRegExp($sCmd, '(?i)^(editor|output)\:') Then $sCmd = 'extender:dostring ' & $sCmd
		;#
		Local $SciTE_getInfo = StringRegExp($sCmd, '(?i)^(ask\w+\:|editor\.|output\.)')
		;#
		$sCmd = $dReceiverInterface & $sCmd
		;#
		Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
		DllStructSetData($CmdStruct, 1, $sCmd)
		Local $tCOPYDATA = DllStructCreate('Ptr;DWord;Ptr')
		DllStructSetData($tCOPYDATA, 1, 1)
		DllStructSetData($tCOPYDATA, 2, StringLen($sCmd) + 1)
		DllStructSetData($tCOPYDATA, 3, DllStructGetPtr($CmdStruct))
		DllCall('user32.dll', 'none', 'SendMessageA', 'hwnd', $hSciTE, 'Int', $SCITE_WM_COPYDATA, 'hwnd', $hReceiverInterface, 'ptr', DllStructGetPtr($tCOPYDATA))
		;#
		If $SciTE_getInfo Then
			For $x = 1 To 10
				If $SCITE_RECV_CMD <> Null Then ExitLoop
				Sleep(20)
			Next
			Return StringRegExpReplace($SCITE_RECV_CMD, '(?i)^' & $dReceiverInterface & '(macro:stringinfo:)?', '', 1)
		EndIf
	EndIf
EndFunc
