#include <_HttpRequest.au3>
Global Const $API_GET_TOKEN = "https://snaptik.app/vn"
Global Const $API_DOWNLOAD = "https://snaptik.app/abc2.php"
Global $CODE_JS = 'function _0xe39c(d,e,f){var g="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/".split("");var h=g.slice(0,e);var i=g.slice(0,f);var j=d.split("").reverse().reduce(function(a,b,c){if(h.indexOf(b)!==-1)return a+=h.indexOf(b)*Math.pow(e,c)},0);var k="";while(j>0){k=i[j%f]+k;j=(j-j%f)/f}return k||"0"}'
$CODE_JS &= 'function _0xe39c2(h,u,n,t,e,r){r="";for(var i=0,len=h.length;i<len;i++){var s="";while(h[i]!==n[e]){s+=h[i];i++}for(var j=0;j<n.length;j++)s=s.replace(new RegExp(n[j],"g"),j);r+=String.fromCharCode(_0xe39c(s,e,10)-t)}return decodeURIComponent(escape(r))}'

Global Const $URL_VIDEO = "https://www.tiktok.com/@sharemyplaylist/video/7064580201044249857?is_copy_url=1&is_from_webapp=v1"
Global Const $SAVE_DIR = @ScriptDir & "\" & "result.mp4"
Local $URL_RESULT = SnapTik_Download($URL_VIDEO,$SAVE_DIR)

; #FUNCTION# ====================================================================================================================
; Name ..........: SnapTik_GetToken
; Description ...: Tìm token download
; Syntax ........: SnapTik_GetToken()
; Parameters ....: None
; Return values .: Giá trị token dùng để tạo request download
; ===============================================================================================================================
Func SnapTik_GetToken()
	Global $responseToken = _HttpRequest(2,$API_GET_TOKEN)
	Local $arrayToken = StringRegExp($responseToken,'"token" value="(.*?)" type="hidden"',3)
	If @error Then
		ConsoleWrite("Khong tim thay token" & @CRLF)
		SetError(1)
	EndIf
	ConsoleWrite("Da tim thay token: " & $arrayToken[0] & @CRLF)
	Return $arrayToken[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: SnapTik_Download
; Description ...: Download video tiktok sử dụng API từ trang snaptik.app
; Syntax ........: SnapTik_Download($tiktokUrl, $dirSave)
; Parameters ....: $tiktokUrl           - a dll struct value.
;                  $dirSave             - a binary variant value.
; Return values .: Link tải video
; ===============================================================================================================================
Func SnapTik_Download($tiktokUrl,$dirSave)
	Local $token = SnapTik_GetToken()
	Local $dataDownload = SnapTik_Data_Download($tiktokUrl,$token)
	Local $responseDownload = _HttpRequest(2,$API_DOWNLOAD,$dataDownload)
	Local $codeRun = StringRegExp($responseDownload,'decodeURIComponent\(escape\(r\)\)}\((.*?)\)\)',3)
	If @error Then
		ConsoleWrite("Khong giai duoc m oi #1" & @CRLF)
		Return SetError(1)
	EndIf
	Local $codeJs = $CODE_JS & '_0xe39c2(' & $codeRun[0] & ')'
	Local $jsRun = _JS_Execute_Ex("https://snaptik.app/vn","",$codeJs)
	Local $arrayLink = StringRegExp($jsRun,'down-right\\"><a href=\\"(.*?)\\"',3)
	If @error Then
		ConsoleWrite("Khong giai duoc m oi #2" & @CRLF)
		Return SetError(2)
	EndIf
	Local $requestDownload = _HttpRequest(3,$arrayLink[0])
	_HttpRequest_Test($requestDownload,$dirSave,Default,False)
	MsgBox(64 + 8192 + 262144,"Thông báo","Đã tải xong")
	Return $arrayLink[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: SnapTik_Data_Download
; Description ...: Tạo data download
; Syntax ........: SnapTik_Data_Download($url, $token)
; Parameters ....: $url                 - URL video cần download.
;                  $token               - token download.
; Return values .: Data download
; ===============================================================================================================================
Func SnapTik_Data_Download($url,$token)
	Local $data = [["url", $url],["lang","vn"],["token",$token]] ; Dạng mảng 2 chiều
	; Bạn cũng có thể dùng 1 trong 2 dạng dưới đây
;~ 	Local $data = ["url=" & $url,"lang=vn","token=" & $token] ; Dạng mảng 1 chiều (Phân cách nhau bằng kí tự "=")
;~ 	Local $data = ["url:" & $url,"lang:vn","token:" & $token] ; Dạng mảng 1 chiều (Phân cách nhau bằng kí tự ":")
	; Đọc hướng dẫn UDF _HttpRequest.au3 của function _HttpRequest_DataFormCreate để tìm hiểu thêm
	Return $data
EndFunc
