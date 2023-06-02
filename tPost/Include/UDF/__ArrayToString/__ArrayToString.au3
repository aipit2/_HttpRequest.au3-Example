Func __ArrayToString($array,$sDelim_Col = "|",$sDelim_Row = @LF)
	Local $result
	If IsArray($array) = 0 Then
		Return SetError(1,0,"")
	EndIf
	If UBound($array) = 0 Then
		Return SetError(2,0,"")
	EndIf
	For $i = 0 To UBound($array) - 1
		For $i2 = 0 To UBound($array,2) - 1
			If $i2 <> UBound($array,2) - 1 Then
				If IsArray($array[$i][$i2]) = 1 Then
					$result &= $sDelim_Col
				Else
					$result &= $array[$i][$i2] & $sDelim_Col
				EndIf
			Else
				If IsArray($array[$i][$i2]) = 0 Then
					$result &= $array[$i][$i2]
				EndIf
			EndIf
		Next
		If $i <> UBound($array) - 1 Then
			$result &= $sDelim_Row
		EndIf
	Next
	Return $result
EndFunc