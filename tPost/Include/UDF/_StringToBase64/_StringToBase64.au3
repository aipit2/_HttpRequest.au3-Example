Func _StringToBase64($string)
	Local $stringToBinary = StringToBinary($string,4)
	Return base64($stringToBinary)
EndFunc

Func _Base64ToString($base64)
	Local $base64ToBinary = base64($base64,False)
	Return BinaryToString($base64ToBinary,4)
EndFunc

;==============================================================================================================================
; Function:         base64($vCode [, $bEncode = True [, $bUrl = False]])
;
; Description:      Decode or Encode $vData using Microsoft.XMLDOM to Base64Binary or Base64Url.
;                   IMPORTANT! Encoded base64url is without @LF after 72 lines. Some websites may require this.
;
; Parameter(s):     $vData      - string or integer | Data to encode or decode.
;                   $bEncode    - boolean           | True - encode, False - decode.
;                   $bUrl       - boolean           | True - output is will decoded or encoded using base64url shema.
;
; Return Value(s):  On Success - Returns output data
;                   On Failure - Returns 1 - Failed to create object.
;
; Author (s):       (Ghads on Wordpress.com), Ascer
;===============================================================================================================================
Func base64($vCode, $bEncode = True, $bUrl = False)

    Local $oDM = ObjCreate("Microsoft.XMLDOM")
    If Not IsObj($oDM) Then Return SetError(1, 0, 1)

    Local $oEL = $oDM.createElement("Tmp")
    $oEL.DataType = "bin.base64"

    If $bEncode then
        $oEL.NodeTypedValue = Binary($vCode)
        If Not $bUrl Then Return $oEL.Text
        Return StringReplace(StringReplace(StringReplace($oEL.Text, "+", "-"),"/", "_"), @LF, "")
    Else
        If $bUrl Then $vCode = StringReplace(StringReplace($vCode, "-", "+"), "_", "/")
        $oEL.Text = $vCode
        Return $oEL.NodeTypedValue
    EndIf

EndFunc ;==>base64