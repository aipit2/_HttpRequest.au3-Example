#include-once

#include <WinAPI.au3>
#include <GuiEdit.au3>
#include <GuiRichEdit.au3>
#include <Misc.au3>

#include "AutoItObject_Internal.au3"


Const $c_WhiteMode = 0
Const $c_DarkMode = 1

Const $__cBlack = 0x000000
Const $__cWhite = 0xFFFFFF
Const $__cRed = 0x0000FF
Const $__cBlue = 0xFF0000
Const $__cGreen = 0x00FF00

Const $__ERROR = "ERROR"

Global $__Console[0], $__iC = 0
Global $__posWatch = False

Func ConsoleStart()
	Local $aWatch[3][0]

	Local $Console = IDispatch()
	$Console.Mode = $c_WhiteMode
	$Console.aWatch = $aWatch
	$Console.Draw = False

	Return $Console
EndFunc


Func ConsoleOpen($Console)

	If __CheckConsole($Console) = False Then Return SetError(-1, 0, -1)
	ConsoleOpenThread($Console)
	While Not _IsPressed("1B")
		ConsoleUpdate($Console)
	WEnd

EndFunc

Func ConsoleOpenThread($Console)

	If __CheckConsole($Console) = False Then Return SetError(-1, 0, -1)

	If $Console.Draw = False Then _CS_SetupColor($Console)

	Local $iW = 1000, $iH = 600, $iPadding = 15
	Local $dMemory[0], $nMemCount = 0, $iIndexMemory = 0, $tempMemory = False
	Local $tEnter = TimerInit(), $tUp = TimerInit(), $tDown = TimerInit(), $tLastBreak = TimerInit(), $tUpdate = TimerInit()
	Local $isHoldEnter, $isHoldUp, $isHoldDown

	Local $hGUI = GUICreate("Console", $iW, $iH, -1, -1, BitOR(0x00040000,0x00080000))

	Local $hConsole = _GUICtrlRichEdit_Create($hGUI, "", 0, 0, $iW, $iH-25, $ES_MULTILINE + 0x00200000 + $ES_AUTOVSCROLL , 0x00000200 + 0x00000200)
	_GUICtrlRichEdit_SetBkColor($hConsole, $Console.cBackground)
	_GUICtrlRichEdit_SetCharColor($hConsole, $Console.cText)
	_GUICtrlRichEdit_SetParaSpacing($hConsole, Default, .06)
    _GUICtrlEdit_SetMargins($hConsole, BitOR($EC_LEFTMARGIN, $EC_RIGHTMARGIN), 10, 0)

	GUISetState()
	_CS_Info($Console, $hConsole)

	Local $iLastSel = _GUICtrlRichEdit_GetSel($hConsole)[0] - 3

	$Console.dMemory = $dMemory
	$Console.nMemCount = $nMemCount
	$Console.iIdexMemory = $iIndexMemory
	$Console.tempMemory = $tempMemory
	$Console.tEnter = $tEnter
	$Console.tUp = $tUp
	$Console.tDown = $tDown
	$Console.tLastBreak = $tLastBreak
	$Console.tUpdate = $tUpdate
	$Console.isHoldEnter = $isHoldEnter
	$Console.isHoldUp = $isHoldUp
	$Console.isHoldDown = $isHoldDown
	$Console.iLastSel = $iLastSel
	$Console.hConsole = $__iC

	ReDim $__Console[$__iC + 1]
	$__Console[$__iC] = $hConsole
	$__iC += 1
EndFunc

Func ConsolePush($Console, $push)

	If __CheckConsole($Console) = False Then Return SetError(-1, 0, -1)

	$Console.data = $push

EndFunc

Func ConsoleUpdate($Console)

	If __CheckConsole($Console) = False Then Return SetError(-1, 0, -1)

	Local $iCurrentSel, $iMaxSel, $iRead, $iCurrentLine

	Local $dMemory = $Console.dMemory
	Local $nMemCount = $Console.nMemCount
	Local $iIndexMemory = $Console.iIdexMemory
	Local $tempMemory = $Console.tempMemory
	Local $tEnter = $Console.tEnter
	Local $tUp = $Console.tUp
	Local $tDown = $Console.tDown
	Local $tLastBreak = $Console.tLastBreak
	Local $tUpdate = $Console.tUpdate
	Local $isHoldEnter = $Console.isHoldEnter
	Local $isHoldUp = $Console.isHoldUp
	Local $isHoldDown = $Console.isHoldDown
	Local $iLastSel = $Console.iLastSel
	Local $hConsole = $__Console[$Console.hConsole]
	Local $aWatch = $Console.aWatch

	; Check for enter key
	Local $isEnter = _IsPressed("0D")
	Local $isUp = _IsPressed("26")
	Local $isDown = _IsPressed("28")
	Local $isCTRL_A = _IsPressed("11") And _IsPressed("41")

	__CheckHold($isEnter, $isHoldEnter, $tEnter)
	__CheckHold($isUp, $isHoldUp, $tUp)
	__CheckHold($isDown, $isHoldDown, $tDown)

	If __RemoveBreak($hConsole) Then $isEnter = True

	__CS_Info2Var($hConsole, $iCurrentSel, $iCurrentLine, $iMaxSel, $iRead, $iLastSel)

	If $Console.data Then
		_GUICtrlRichEdit_SetSel($hConsole, $iLastSel + 3, $iMaxSel, True)
		_GUICtrlRichEdit_ReplaceText($hConsole, "")
		_GUICtrlRichEdit_AppendText($hConsole, $Console.data)
		__CS_Info2Var($hConsole, $iCurrentSel, $iCurrentLine, $iMaxSel, $iRead, $iLastSel)
		$Console.data = Null
	EndIf


	If $isCTRL_A Then _GUICtrlRichEdit_SetSel($hConsole, $iLastSel + 3, $iMaxSel, False)

	If $isUp And $nMemCount >= 1 And $iIndexMemory > 0 Then
		_GUICtrlRichEdit_SetSel($hConsole, $iLastSel + 3, $iMaxSel, True)
		_GUICtrlRichEdit_ReplaceText($hConsole, "")
		_GUICtrlRichEdit_AppendText($hConsole, $dMemory[$iIndexMemory - 1])
		If $tempMemory = False Then $tempMemory = StringTrimLeft($iRead, 3)
		$iIndexMemory -= 1
	EndIf

	If $isDown And $nMemCount >= 1 And $iIndexMemory < $nMemCount Then
		Local $data = $iIndexMemory = $nMemCount - 1 ? $tempMemory : $dMemory[$iIndexMemory + 1]
		_GUICtrlRichEdit_SetSel($hConsole, $iLastSel + 3, $iMaxSel, True)
		_GUICtrlRichEdit_ReplaceText($hConsole, "")
		_GUICtrlRichEdit_AppendText($hConsole, $data)
		$iIndexMemory += 1
	EndIf

	If $iCurrentLine <= 2 Then
		_CS_Info($Console, $hConsole)
		Return
	EndIf
	If $iCurrentSel - $iLastSel <= 2 Then
		If $isUp Or $isDown Then
			__CS_Info2Var($hConsole, $iCurrentSel, $iCurrentLine, $iMaxSel, $iRead, $iLastSel)
			_GUICtrlRichEdit_SetSel($hConsole, $iMaxSel, $iMaxSel)

		Else
			_GUICtrlRichEdit_SetSel($hConsole, $iLastSel + 3, $iLastSel + 3)
		EndIf
	EndIf
	If StringLeft($iRead, 3) <> ">_ " Then
		_GUICtrlRichEdit_SetSel($hConsole, $iLastSel, $iCurrentSel, True)
		_GUICtrlRichEdit_ReplaceText($hConsole, ">_ ")
	EndIf

	Local $iFCS = _GUICtrlRichEdit_GetSel($hConsole)
	$iFCS[0] -= $iLastSel
	$iFCS[1] -= $iLastSel
	If UBound($aWatch, 2) > 0 And TimerDiff($tUpdate) > 500 Then
		BlockInput(1)
		GUICtrlSetStyle($hConsole, $ES_READONLY , 0x00000200 + 0x00000200)
		_GUICtrlRichEdit_PauseRedraw($hConsole)

		For $i = 0 To UBound($aWatch, 2) - 1
			Local $result = _CS_Execute($Console, $aWatch[0][$i])
			Local $result_add = @LF
			If StringLen($result) <= 200 And StringInStr($result, @LF) = False Then $result_add = "  ----  "
			$result =  $result_add & "   " & $result

			_GUICtrlRichEdit_SetSel($hConsole, $aWatch[1][$i], $aWatch[1][$i] + $aWatch[2][$i], True)
			_GUICtrlRichEdit_ReplaceText($hConsole, $result)
			_GUICtrlRichEdit_Deselect($hConsole)
			_GUICtrlRichEdit_SetSel($hConsole, $aWatch[1][$i], $aWatch[1][$i] + StringLen($result), True)
			_GUICtrlRichEdit_SetCharColor($hConsole, $result = $__ERROR ? $Console.cErrorText : $Console.cResultText)
			_GUICtrlRichEdit_Deselect($hConsole)

			Local $delta = StringLen($result) - $aWatch[2][$i]

			For $j = $i + 1 To UBound($aWatch, 2) - 1
				$aWatch[1][$j] += $delta
			Next

			$iLastSel += $delta
			$aWatch[2][$i] = StringLen($result)

		Next
		$Console.aWatch = $aWatch
		_GUICtrlRichEdit_SetSel($hConsole, $iFCS[0] + $iLastSel, $iFCS[1] + $iLastSel)
		_GUICtrlRichEdit_ResumeRedraw($hConsole)
		GUICtrlSetStyle($hConsole, $ES_MULTILINE + 0x00200000 + $ES_AUTOVSCROLL , 0x00000200 + 0x00000200 )

		$tUpdate = TimerInit()
	EndIf
	If $isEnter And TimerDiff($tLastBreak) > 100 Then
		__RemoveBreak($hConsole)
		Local $dEnter = StringTrimLeft($iRead, 3)

		$tempMemory = False
		If $dEnter Then
			Local $result = _CS_Execute($Console, $dEnter)

			ReDim $dMemory[$nMemCount + 1]
			$dMemory[$nMemCount] = $dEnter
			$nMemCount += 1
			$iIndexMemory = $nMemCount

			If $result Then
				$result_add = @LF
				If StringLen($result) <= 200 And StringInStr($result, @LF) = False Then $result_add = "  ----  "
				$result =  $result_add & "   " & $result
				If $__posWatch Then
					$aWatch = $Console.aWatch
					$aWatch[1][UBound($aWatch, 2) - 1] = _GUICtrlRichEdit_GetSel($hConsole)[0]
					$aWatch[2][UBound($aWatch, 2) - 1] = StringLen($result)
					$Console.aWatch = $aWatch
					$__posWatch = False
				EndIf

				_GUICtrlRichEdit_SetCharColor($hConsole, $result = $__ERROR ? $Console.cErrorText : $Console.cResultText)
				_GUICtrlRichEdit_AppendText($hConsole, $result)
				_GUICtrlRichEdit_SetCharColor($hConsole, $Console.cText)

			EndIf
		EndIf

		_GUICtrlRichEdit_SetFont($hConsole, 11, "CONSOLAS")
		_GUICtrlEdit_AppendText($hConsole,  @LF & ">_ ")

		$iLastSel = _GUICtrlRichEdit_GetSel($hConsole)[0] - 3
		$tLastBreak = TimerInit()
	EndIf

	$Console.dMemory = $dMemory
	$Console.nMemCount = $nMemCount
	$Console.iIdexMemory = $iIndexMemory
	$Console.tempMemory = $tempMemory
	$Console.tEnter = $tEnter
	$Console.tUp = $tUp
	$Console.tDown = $tDown
	$Console.tLastBreak = $tLastBreak
	$Console.tUpdate = $tUpdate
	$Console.isHoldEnter = $isHoldEnter
	$Console.isHoldUp = $isHoldUp
	$Console.isHoldDown = $isHoldDown
	$Console.iLastSel = $iLastSel

EndFunc

Func __CS_Info2Var($hConsole, ByRef $iCurrentSel, ByRef $iCurrentLine, ByRef $iMaxSel, ByRef $iRead, $iLastSel)

	$iCurrentSel = _GUICtrlRichEdit_GetSel($hConsole)[0]
	$iCurrentLine = _GUICtrlRichEdit_GetLineCount($hConsole)
	$iMaxSel = _GUICtrlRichEdit_GetFirstCharPosOnLine($hConsole, $iCurrentLine) + _GUICtrlRichEdit_GetLineLength($hConsole, $iCurrentLine)
	$iRead = _GUICtrlRichEdit_GetTextInRange($hConsole, $iLastSel, $iMaxSel)

EndFunc

Func _CS_Execute($Console, $String, $isResult = False)
	If Not $String Then Return False

	Local $result, $aWatch, $isWatch = False, $_instance
	$String = __RemoveBlank($String)

	If StringLeft($String, 1) = ">" Then
		$result = StringTrimLeft($string, 1)
		$result = _CS_Execute($Console, $result)

		If $result = False Or $result = $__ERROR Then Return $__ERROR

		$aWatch = $Console.aWatch
		$_instance = UBound($aWatch, 2)
		ReDim $aWatch[3][ $_instance + 1 ]
		$aWatch[0][$_instance] = StringTrimLeft($string, 1)
		$isWatch = True
		$__posWatch = True
		$Console.aWatch = $aWatch

	ElseIf StringInStr($String, "=") Then

		If StringLeft($string, 1) = "$" Then

			Local $strSplit = StringSplit($String, "=", 1)
			Local $strVariable = StringReplace( StringTrimLeft($strSplit[1], 1), " ", "")
			Local $strExecute = $strSplit[2]

			$result = _CS_Execute($Console, $strExecute, True)
			Assign($strVariable, $result, 2)
			If UBound($result) > 0 Then $result = _CS_Table($result)
		Else
			$result = $__ERROR
		EndIf

	ElseIf StringRegExp($String, "[\+\-\*\/\&](?![^\(]*\))") Then

		$strExecute = StringRegExp($String, "[\+\-\*\/\&](?![^\(]*\))", 3)
		Local $SplitExecute = StringSplit(StringRegExpReplace($String, "[\+\-\*\/\&](?![^\(]*\))", @LF), @LF, 1)

		For $i = 1 To $SplitExecute[0]
			$result &= _CS_Execute($Console, $SplitExecute[$i], True) & ($i < $SplitExecute[0] ? $strExecute[$i - 1] : "")
		Next
		$result = Execute($result)

	ElseIf StringRegExp($String, "[\<\>]") Then

		$strExecute = StringRegExp($String, "[\<\>]", 1)[0]
		$SplitExecute = StringSplit(StringRegExpReplace($String, "[\<\>]", @LF), @LF, 1)

		If $SplitExecute[0] <> 2 Then Return $__ERROR

		Switch $strExecute
			Case "<"
				$result = _CS_Execute($Console, $SplitExecute[1], True) < _CS_Execute($Console, $SplitExecute[2], True) ? "True" : "False"

			Case ">"
				$result = _CS_Execute($Console, $SplitExecute[1], True) > _CS_Execute($Console, $SplitExecute[2], True) ? "True" : "False"
		EndSwitch

	ElseIf StringRegExp($String, "[\(\)]") Then
		Local $strFunc = StringRegExp($string, "(.*?)(\()", 1)[0]
		$strExecute = StringTrimRight(StringRegExp($string, "(\()(.*)", 3)[1], 1)
		Local $strParams = StringSplit(StringRegExpReplace($strExecute, ",(?![^\(]*\))", @LF), @LF, 1)

		For $i = 1 To $strParams[0]
			$strParams[$i] = _CS_Execute($Console, $strParams[$i], True)
		Next

		$result = _CS_CallFunc($strFunc, $strParams)

	ElseIf StringLeft($String, 1) = '"' Then

		$result = StringTrimLeft($String, 1)
		$result = StringTrimRight($result, 1)

	ElseIf StringLeft($String, 1) = "$" Then

		$result = Execute($String)

		If (Not $result) And (Not IsArray($result)) And (Not IsObj($result)) Then Return $__ERROR
		$result = $isResult ? $result : _CS_Table($result)

	Else
		$result = $String
		If StringIsDigit($result) = False And StringLeft($result, 1) <> "@" Then $result = $__ERROR

	EndIf
	Return $result
EndFunc

Func _CS_Table($result)

	Local $strResult

	If UBound($result) > 0 Then
		If UBound($result, 2) > 0 Then

			Local $iSpace[UBound($result, 2)], $iSpaceIndex = 7
			; calculate the space
			For $iRow = 0 To UBound($result) - 1
				For $iCol = 0 To UBound($result, 2) - 1
					Local $len = StringLen($result[$iRow][$iCol])
					Local $lenCol = StringLen($iCol)
					If $len + 2 > $iSpace[$iCol] Then $iSpace[$iCol] = $len + 2
					If $iCol + 2 > $iSpace[$iCol] Then $iSpace[$iCol] = $iCol + 2
				Next
				If StringLen($iRow) + 2 > $iSpaceIndex Then $iSpaceIndex = StringLen($iRow) + 2
			Next

			; header
			$strResult = "|  index" & __Space($iSpaceIndex - 5) & "|"
			For $iCol = 0 To UBound($result, 2) - 1
				$strResult &= "  " & $iCol & __Space($iSpace[$iCol] - StringLen($iCol)) & "|"
			Next
			$strResult &= @LF & @LF

			; data
			For $iRow = 0 To UBound($result) - 1
				$strResult &= "   |  " & $iRow & __Space($iSpaceIndex - StringLen($iRow)) & "|"
				For $iCol = 0 To UBound($result, 2) - 1
					$strResult &= "  " & $result[$iRow][$iCol] & __Space($iSpace[$iCol] - StringLen($result[$iRow][$iCol])) & "|"
				Next
				If $iRow <> UBound($result) - 1 Then $strResult &= @LF
			Next

		Else

			$strResult = "["
			For $i = 0 To UBound($result) - 1
				If IsString($result[$i]) Then $result[$i] = '"' & $result[$i] & '"'
				$strResult &= $result[$i]
				If $i <> UBound($result) - 1 Then $strResult &= ", "
			Next
			$strResult &= "]"

		EndIf
	EndIf
	If $strResult Then Return $strResult
	Return $result
EndFunc


Func _CS_CallFunc($Func, $Params = False)
	$Func = StringReplace($Func, " ", "")

	If $Params[0] = 1 And $Params[1] = "" Then Return Call($Func)
	If $Params[0] = 1 Then Return Call($Func, $Params[1])
	If $Params[0] = 2 Then Return Call($Func, $Params[1], $Params[2])
	If $Params[0] = 3 Then Return Call($Func, $Params[1], $Params[2], $Params[3])
	If $Params[0] = 4 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4])
	If $Params[0] = 5 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4], $Params[5])
	If $Params[0] = 6 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4], $Params[5], $Params[6])
	If $Params[0] = 7 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4], $Params[5], $Params[6], $Params[7])
	If $Params[0] = 8 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4], $Params[5], $Params[6], $Params[7], $Params[8])
	If $Params[0] = 9 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4], $Params[5], $Params[6], $Params[7], $Params[8], $Params[9])
	If $Params[0] = 10 Then Return Call($Func, $Params[1], $Params[2], $Params[3], $Params[4], $Params[5], $Params[6], $Params[7], $Params[8], $Params[9], $Params[10])

EndFunc

Func __Space($value)
	Local $space
	For $i = 1 To $value
		$space &= " "
	Next
	Return $space
EndFunc


Func __RemoveBlank($String)
	While StringLeft($String, 1) = " "
		$String = StringTrimLeft($String, 1)
	WEnd
	While StringRight($String, 1) = " "
		$String = StringTrimRight($String, 1)
	WEnd
	Return $String
EndFunc

Func __RemoveBreak($hConsole)
	Local $isBreak = False

	Local $line = _GUICtrlRichEdit_GetLineCount($hConsole)
	Local $readLine = _GUICtrlRichEdit_GetTextInLine($hConsole, $line)

	While $readLine = "" Or StringLeft($readLine, 1) <> ">"
		If $line <= 2 Then Return
		Local $_sel = _GUICtrlRichEdit_GetFirstCharPosOnLine($hConsole, $line)
		_GUICtrlRichEdit_SetSel($hConsole, $_sel - 1, $_sel, True)
		_GUICtrlRichEdit_ReplaceText($hConsole, "")

		$line = _GUICtrlRichEdit_GetLineCount($hConsole)
		$readLine = _GUICtrlRichEdit_GetTextInLine($hConsole, $line)

		$isBreak = True
	WEnd

	Return $isBreak
EndFunc

Func _CS_Info($Console, $hConsole)
	_GUICtrlRichEdit_SetText($hConsole, "")
	_GUICtrlRichEdit_SetCharColor($hConsole, $Console.cText)
	_GUICtrlRichEdit_SetFont($hConsole, 11, "CONSOLAS")
	_GUICtrlRichEdit_InsertText($hConsole, "AutoIT Console - created by Ho Hai Dang" & @CRLF & @CRLF)
	_GUICtrlRichEdit_SetCharColor($hConsole, $Console.cText)
	_GUICtrlRichEdit_SetFont($hConsole, 11, "CONSOLAS")
	_GUICtrlRichEdit_InsertText($hConsole,">_ ")
EndFunc

Func _CS_SetupColor($Console)

	If __CheckConsole($Console) = False Then Return SetError(-1, 0, -1)
	Switch $Console.Mode
		Case $c_WhiteMode
			$Console.cBackground = $__cWhite
			$Console.cText = $__cBlack
			$Console.cErrorText = $__cRed
			$Console.cResultText = $__cBlue

		Case $c_DarkMode
			$Console.cBackground = $__cBlack
			$Console.cText = $__cWhite
			$Console.cErrorText = $__cRed
			$Console.cResultText = $__cGreen
	EndSwitch
EndFunc


Func __CheckConsole($Console)
	If Not IsObj($Console) Then Return False
	Return True
EndFunc

Func __CheckHold(ByRef $isKey, ByRef $isHold, ByRef $tKey)

	If $isKey And Not $isHold Then
		$tKey = TimerInit()
		$isHold = True
		$isKey = True
	ElseIf Not $isKey And $isHold Then
		$isHold = False
	Else
		$isKey = $isKey And TimerDiff($tKey) > 500 ? True : False
	EndIf

EndFunc