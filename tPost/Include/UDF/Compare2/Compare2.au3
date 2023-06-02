#include-once
#include <Math.au3>
Dim Const $maxOffset = 5 ; Change according to how far you want to search; a bigger value means a slower comparison
Func Compare2($string,$array,$mode) ; Cập nhật 3/4/2022
	Local $arrayResult[0]
	Local $xoadau_String = ConvertVie($string)
	Local $xoadau_Array = ConvertVie(_ArrayToString($array,"|"))
	Local $array_Xoadau = StringSplit($xoadau_Array,"|",2)
	If IsArray($array_Xoadau) = 0 Then
		Return SetError(1,0,-1)
	EndIf
	For $i = 0 To UBound($array) - 1
		Local $percent = _Similarity($xoadau_String,$array_Xoadau[$i],$mode)
		_ArrayAdd($arrayResult,$percent)
	Next
	If UBound($arrayResult) <= 0 Then
		Return SetError(2,0,-1)
	EndIf
	Local $maxIndex = _ArrayMaxIndex($arrayResult)
	Return $maxIndex
EndFunc

; Compute similarity between two strings
Func _Similarity($s1, $s2, $alg = 0)
    Local $dis
    If ($alg = 0) Then
        $dis = _Levenshtein($s1, $s2)
    Else
        $dis = _Distance($s1, $s2)
    EndIf
    Local $maxLen = _Max(StringLen($s1), StringLen($s2))
    If ($maxLen = 0) Then Return 100
    Return (1 - $dis / $maxLen) * 100
EndFunc

; Compute Levenshtein Distance
Func _Levenshtein($s, $t)
    Local $m, $n, $i, $j, $s_i, $t_j, $cost

    $n = StringLen($s)
    $m = StringLen($t)

    If $n * $m = 0 Then Return $m + $n

    Local $d[$n + 1][$m + 1]

    For $i = 0 To $n
        $d[$i][0] = $i
    Next

    For $j = 0 To $m
        $d[0][$j] = $j
    Next

    For $i = 1 To $n
        $s_i = StringMid($s, $i, 1)

        For $j = 1 To $m
            $t_j = StringMid($t, $j, 1)

            If $s_i = $t_j Then
                $cost = 0
            Else
                $cost = 1
            EndIf

            $d[$i][$j] = _Minimum3($d[$i - 1][$j] + 1, $d[$i][$j - 1] + 1, $d[$i - 1][$j - 1] + $cost)
        Next
    Next

    Return $d[$n][$m]

EndFunc

; Get minimum of three values
Func _Minimum3($a, $b, $c)
    Local $mi

    $mi = $a
    If $b < $mi Then $mi = $b
    If $c < $mi Then $mi = $c

    Return $mi
EndFunc

; Efficient calculation of similarity
Func _Distance($s1, $s2)
    Local $ls1 = StringLen($s1), $ls2 = StringLen($s2)
    If $ls1 * $ls2 = 0 Then Return $ls1 + $ls2

    Local $c = 0, $offset1 = 0, $offset2 = 0, $dist = 0, $i

    While (($c + $offset1 < $ls1) And ($c + $offset2 < $ls2))
        If (StringMid($s1, $c + $offset1 + 1, 1) <> StringMid($s2, $c + $offset2 + 1, 1)) Then
            $offset1 = 0
            $offset2 = 0
            For $i = 0 to $maxOffset - 1
                If (($c + $i < $ls1) And (StringMid($s1, $c + $i + 1, 1) = StringMid($s2, $c + 1, 1))) Then
                    If ($i > 0) Then
                        $dist += 1
                        $offset1 = $i
                    EndIf
                    $dist -= 1
                    ExitLoop
                EndIf
                If (($c + $i < $ls2) And (StringMid($s1, $c + 1, 1) = StringMid($s2, $c + $i + 1, 1))) Then
                    If ($i > 0) Then
                        $dist += 1
                        $offset2 = $i
                    EndIf
                    $dist -= 1
                    ExitLoop
                EndIf
            Next
            $dist += 1
        EndIf
        $c += 1
    Wend

    Return $dist + ($ls1 - $offset1 + $ls2 - $offset2) / 2 - $c
EndFunc