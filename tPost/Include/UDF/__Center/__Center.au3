; #FUNCTION# ====================================================================================================================
; Name ..........: __Center
; Description ...: Tìm vị tọa độ của button để sắp xếp đều trong GUI
; Syntax ........: __Center($So_Luong_Btn,$Chieu_Dai_Tong,$Chieu_Dai_Tung_Btn)
; Parameters ....: $So_Luong_Btn		- Tổng số lượng Button
;                  $Chieu_Dai_Tong      - Chiều dài tổng của GUI
;                  $Chieu_Dai_Tung_Btn  - Chiều dài của từng Button
; Return values .: Một mảng là tọa độ của những Button cần sắp xếp, trong đó giá trị [0] = 0
; Example .......: __Center(3,1000,200) (Có 3 Button, Chiều dài GUI là 1000, Mỗi Button dài 200)
; Cách giải:
; Số khoảng trống = Số lượng Button + 1.														VD: 3 + 1 = 4
; Chiều dài tổng của Button = Số lượng Button * Chiều dài từng Button							VD: 4 * 200 = 800
; Chiều dài tổng khoảng trống = Chiều dài tổng - Chiều dài tổng của Button						VD: 1000 - 800 = 200
; Chiều dài từng khoảng trống = Chiều dài tổng khoảng trống / Số lượng khoảng trống				VD: 200 / 4 = 50
; Chiều dài của 1 Button + 1 Khoảng trống														VD: 50 + 200
; Tham số cần tìm = Chiều dài của 1 Button + 1 Khoảng trống * vị trí của Button (Bắt đầu từ 1) 	VD: 250 * 1 = 250(Vị trí 1)
;~ 																								VD: 250 * 2 = 500(Vị trí 2)
;~ 																								VD: 250 * 3 = 750(Vị trí 3)
; ===============================================================================================================================
Func __Center($So_Luong_Btn,$Chieu_Dai_Tong,$Chieu_Dai_Tung_Btn)
	Local $Array_X = [0]
	Local $So_Luong_Khoang_Trong = $So_Luong_Btn + 1
	Local $Chieu_Dai_Tong_Btn = $So_Luong_Btn * $Chieu_Dai_Tung_Btn
	Local $Chieu_Dai_Tong_Khoang_Trong = $Chieu_Dai_Tong - $Chieu_Dai_Tong_Btn
	Local $Chieu_Dai_Tung_Khoang_Trong = $Chieu_Dai_Tong_Khoang_Trong / $So_Luong_Khoang_Trong
	Local $Chieu_Dai_Btn_AND_Khoang_Trong = $Chieu_Dai_Tung_Khoang_Trong + $Chieu_Dai_Tung_Btn
	For $i = 1 To $So_Luong_Btn Step 1
		_ArrayAdd($Array_X,$Chieu_Dai_Tung_Khoang_Trong + $Chieu_Dai_Btn_AND_Khoang_Trong * ($i - 1))
	Next
	Return $Array_X
EndFunc