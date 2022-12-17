; Xác định vấn đề:
; Mình thường mua acc liên minh trên shop này mà mình chỉ cần nhiều tướng và giá rẻ nhất có thể
; Nhưng trên web không có phần sắp xếp acc theo số lượng tướng, số lượng acc rất nhiều nên mình muốn gom lại 1 chỗ để lựa chọn cho dễ


#include <_HttpRequest.au3>

Global Const $FROM_10_TO_70K 	= "https://lienminhshop.vn/tu-10k-den-70k/acc/?keyword=&page="
Global Const $FROM_70_TO_100K 	= "https://lienminhshop.vn/tu-70k-den-100k/acc/?keyword=&page="
Global Const $FROM_100_TO_200K 	= "https://lienminhshop.vn/tu-100k-den-200k/acc/?keyword=&page="

Global $aAccount = LienMinhShop_GetAccount($FROM_70_TO_100K,10)

_ArrayDisplay($aAccount,"Đã tìm kiếm xong","",0,Default,"ID|RANK|KHUNG|TƯỚNG|SKIN|GIÁ CARD|GIÁ BANK")

; #FUNCTION# ====================================================================================================================
; Name ..........: LienMinhShop_GetAccount
; Description ...: Lấy danh sách tài khoản từ trang lienminhshop.vn
; Syntax ........: LienMinhShop_GetAccount([$option = 1])
; Parameters ....: $option              - [optional] giá trị lựa chọn acc. Default is 1: Lấy danh sách acc từ 10-70k
;              							- 2: Lấy danh sách acc từ 70-100k
;              							- 3: Lấy danh sách acc từ 100-200k
;                : $page                - Số lượng trang muốn lấy dữ liệu - Mặc định sẽ lấy 100 trang đầu tiên - Sẽ thoát vòng lặp khi không tìm thấy tài khoản
; (Các bạn tự code thêm option nhé)
; Lưu ý giá thành càng cao thì số lượng acc càng nhiều, nên request sẽ hơi lâu, mình khuyến khích ae nên áp dụng thêm Multi Process
; Return values .: $aResult 			- Mảng chứa danh sách acc lấy được
; ===============================================================================================================================
Func LienMinhShop_GetAccount($url = $FROM_10_TO_70K,$page = 100)
	Local $aResult[0][7]
	For $i = 1 To $page
		; Giờ có URL rồi thì request đến trang để lấy dữ liệu
		Local $response = _HttpRequest(2,$url & $i) ; 2 để lấy dữ liệu ở dạng string
		; Có dữ liệu rồi mình giờ sẽ tách những thứ mình cần lấy (Nhớ dùng UDF Regex Toolkit cho dễ nha)
		Local $aAccId = StringRegExp($response,'c-rank">Acc #(.*?) </h3>',3)
		If @error Then
			ExitLoop
		EndIf
		Local $aRank = StringRegExp($response,'Rank Đơn: (.*?)\<',3)
		If @error Then
			ExitLoop
		EndIf
		Local $aKhung = StringRegExp($response,'Khung: (.*?)\<',3)
		If @error Then
			ExitLoop
		EndIf
		Local $aChamp = StringRegExp($response,'Tướng: (.*?)\<',3)
		If @error Then
			ExitLoop
		EndIf
		Local $aSkin = StringRegExp($response,'Trang Phục: (.*?)\<',3)
		If @error Then
			ExitLoop
		EndIf
		Local $aPriceCard = StringRegExp($response,'cart-price">(.*?) <',3)
		If @error Then
			ExitLoop
		EndIf
		Local $aPriceAtm = StringRegExp($response,'atm-price">(.*?) <',3)
		If @error Then
			ExitLoop
		EndIf
		; Ở đây thường cần 1 đoạn check size của các mảng có bằng nhau không tránh bị lỗi.
		For $i = 0 To UBound($aAccId) - 1
			$value = $aAccId[$i] & "|" & $aRank[$i] & "|" & $aKhung[$i] & "|" & $aChamp[$i]
			$value &= "|" & $aSkin[$i] & "|" & $aPriceCard[$i] & "|" & $aPriceAtm[$i]
			_ArrayAdd($aResult,$value)
		Next
	Next
	Return $aResult
EndFunc