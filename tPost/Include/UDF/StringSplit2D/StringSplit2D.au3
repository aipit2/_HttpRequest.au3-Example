Func StringSplit2D($sMatches = "x,y|x,y", Const $sDelim_Item = ",", Const $sDelim_Row = @CRLF, $bFixLast = Default)
    Local $iValDim_1, $iValDim_2 = 0, $iColCount

    ; Fix last item or row.
    If $bFixLast <> False Then
        Local $sTrim = StringRight($sMatches, 1)
        If $sTrim = $sDelim_Row Or $sTrim = $sDelim_Item Then $sMatches = StringTrimRight($sMatches, 1)
    EndIf

    Local $aSplit_1 = StringSplit($sMatches, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
    $iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
    Local $aTmp[$iValDim_1][0], $aSplit_2
    For $i = 0 To $iValDim_1 - 1
        $aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
        $iColCount = UBound($aSplit_2)
        If $iColCount > $iValDim_2 Then
            $iValDim_2 = $iColCount
            ReDim $aTmp[$iValDim_1][$iValDim_2]
        EndIf
        For $j = 0 To $iColCount - 1
            $aTmp[$i][$j] = $aSplit_2[$j]
        Next
    Next
    Return $aTmp
EndFunc   ;==>StringSplit2D