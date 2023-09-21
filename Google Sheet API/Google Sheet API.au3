#include <_HttpRequest.au3>
Global Const $CryptoJS = @ScriptDir & "\jsrsasign.js"
;~ Global Const $CryptoJS = "https://raw.githubusercontent.com/aipit2/jsrsasign/main/jsrsasign.js" ; Nếu không muốn phải kèm file js theo tool thì xài dòng này

; #FUNCTION# ====================================================================================================================
; Name ..........: Google_Sheet_Create_JWT
; Description ...: Tạo JWT
; Syntax ........: Google_Sheet_Create_JWT($service_account_file_dir_or_data)
; Parameters ....: $service_account_file_dir_or_data - Đường dẫn hoặc data của service account.
; Return values .: JWT
; Author ........: Trần Hùng
; ===============================================================================================================================
Func Google_Sheet_Create_JWT($service_account_file_dir_or_data)
	Local $data, $json
	If FileExists($service_account_file_dir_or_data) = 1 Then
		$data = FileRead($service_account_file_dir_or_data)
	Else
		$data = $service_account_file_dir_or_data
	EndIf

	Local $jsonKey = _HttpRequest_ParseJSON($data)
	Local $header = '{"alg" : "RS256", "typ" : "JWT"}'
	Local $timeStamp = _GetTimeStamp()
	Local $claimSet = '{"iss": "' & $jsonKey.client_email & '",'
	$claimSet &= '"scope": "https://www.googleapis.com/auth/spreadsheets",'
	$claimSet &= '"aud": "https://www.googleapis.com/oauth2/v4/token",'
	$claimSet &= '"exp": ' & $timeStamp + 3600 & ','
	$claimSet &= '"iat": ' & $timeStamp & '}'
	Local $privateKey = StringRegExpReplace($jsonKey.private_key,'\n','\\n')
	Local $codeJs = 'var jwt = KJUR.jws.JWS.sign(null, ' & $header & ', ' & $claimSet & ', "' & $privateKey & '");'
	Local $JWT = _JS_Execute($CryptoJS,$codeJs,"jwt",True)
	Return $JWT
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Google_Sheet_Create_Access_Token
; Description ...: Tạo access token
; Syntax ........: Google_Sheet_Create_Access_Token($service_account_file_dir_or_data)
; Parameters ....: $service_account_file_dir_or_data - Đường dẫn hoặc data của service account.
; Return values .: Access Token
; Author ........: Trần Hùng
; ===============================================================================================================================
Func Google_Sheet_Create_Access_Token($service_account_file_dir_or_data)
	Local $jwt = Google_Sheet_Create_JWT($service_account_file_dir_or_data)
	Local $url = "https://oauth2.googleapis.com/token"
	Local $data = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=" & _URIEncode($jwt)
	Local $res = _HttpRequest(2,$url,$data)
	Local $accessToken = StringRegExp($res,'access_token":"(.*?)"',1)
	If @error Then
		SetError(1,0,$res)
	EndIf

	Return $accessToken[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Google_Sheet_Read
; Description ...: Đọc giữ liệu
; Syntax ........: Google_Sheet_Read($spreadSheetId, $range, $accessToken)
; Parameters ....: $spreadSheetId       -
;                  $range               - ví dụ: Sheet1!A1:A2
;                  $accessToken         -
; Return values .: Object chứa giá trị
; Author ........: Trần Hùng
; Example .......: Ví dụ khi đọc dữ liệu từ 1 ô duy nhất: return.index(0).index(0) (return là giá trị trả về từ hàm read)
;                : Ví dụ khi đọc dữ liệu từ 1 vùng: ở đây đọc vùng A1:B2 - để dễ hiểu thì các bạn cứ hiểu như mảng nhưng thay vì là array[0][0] thì giờ dùng object.index(0).index(0)
;				 : Ô A1 sẽ là return.index(0).index(0)
;				 : Ô A2 sẽ là return.index(1).index(0)
;				 : Ô B1 sẽ là return.index(0).index(1)
;				 : Ô B2 sẽ là return.index(1).index(1)
; ===============================================================================================================================
Func Google_Sheet_Read($spreadSheetId,$accessToken,$range)
	Local $url = "https://sheets.googleapis.com/v4/spreadsheets/" & $spreadSheetId & "/values/" & $range
	Local $header = "Authorization: Bearer " & $accessToken
	Local $res = _HttpRequest(2,$url,'','','',$header)
	If Google_Sheet_Is_Access_Token_Expired($res) = 1 Then ; Access Token đã hết hạn
		Return SetError(1,0,"Access Token đã hết hạn, vui lòng tạo mới")
	EndIf

	Local $json = _HttpRequest_ParseJSON($res)

	If $json == False Then
		Return SetError(2,0,$res)
	ElseIf $json.values == False Then
		Return SetError(3,0,$res)
	EndIf

	Return $json.values
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Google_Sheet_Write
; Description ...: Ghi dữ liệu
; Syntax ........: Google_Sheet_Write($spreadSheetId, $accessToken, $range, $value)
; Parameters ....: $spreadSheetId       - a string value.
;                  $accessToken         - an array of unknowns.
;                  $range               - Ví dụ
;                  $value               - Mảng 2 chiều chứa giá trị(Nếu ghi giữ liệu cho 1 ô thì [["Gia"]])
; Return values .: True					- Ghi thành công
;                ; @error               - Thất bại
; Author ........: Trần Hùng
; ===============================================================================================================================
Func Google_Sheet_Write($spreadSheetId,$accessToken,$range,$value)
	Local $url = "https://sheets.googleapis.com/v4/spreadsheets/" & $spreadSheetId & "/values/" & $range & "?valueInputOption=RAW"
	Local $data = '{"values": ' & __ArrayToString($value) & '}'
	Local $header = "Authorization: Bearer " & $accessToken
	Local $res = _HttpRequest(2,$url,_Utf8ToAnsi($data),'','',$header,'PUT')
	If Google_Sheet_Is_Access_Token_Expired($res) = 1 Then ; Access Token đã hết hạn
		Return SetError(1,0,"Access Token đã hết hạn, vui lòng tạo mới")
	EndIf

	If StringRegExp($res,'updatedRange',0) = 1 Then
		Return True
	Else
		Return SetError(2,0,$res)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: Google_Sheet_Is_Access_Token_Expired
; Description ...: Kiểm tra Access Token hết hạn chưa
; Syntax ........: Google_Sheet_Is_Access_Token_Expired($res)
; Parameters ....: $res                 - Response từ request
; Return values .: 1 - Đã hết hạn
;				 : 0 - Chưa hết hạn
; Author ........: Trần Hùng
; ===============================================================================================================================
Func Google_Sheet_Is_Access_Token_Expired($res)
	Return StringRegExp($res,'ACCESS_TOKEN_EXPIRED',0)
EndFunc

Func __ArrayToString($array)
	Return '[["' & _ArrayToString($array,'","',Default,Default,'"],["') & '"]]'
EndFunc