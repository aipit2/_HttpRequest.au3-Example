Global $pIdServer
Global $Form1_1 = GUICreate("tPost", $GUI_WIDTH, $GUI_HEIGHT, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_TABSTOP,$WM_SIZE))
Global $__g_idMenu_PostFunc = GUICtrlCreateMenu("Tin đăng")
; Menu
Global $__g_idMenu_NewPost = GUICtrlCreateMenuItem("Tin mới " & @TAB & @TAB & " Ctrl + N",$__g_idMenu_PostFunc)
Global $__g_idMenu_SavePost = GUICtrlCreateMenuItem("Lưu tin " & @TAB & @TAB & " Ctrl + S",$__g_idMenu_PostFunc)
Global $__g_idMenu_Posting = GUICtrlCreateMenuItem("Đăng tin " & @TAB & @TAB & " F5",$__g_idMenu_PostFunc)
Global $__g_idMenu_Setting = GUICtrlCreateMenu("Cài đặt")
Global $__g_idMenu_Setting_Account = GUICtrlCreateMenuItem("Tài khoản",$__g_idMenu_Setting)
Global $__g_idMenu_Setting_Web = GUICtrlCreateMenuItem("Danh sách web",$__g_idMenu_Setting)
Global $__g_idMenu_Setting_Vip = GUICtrlCreateMenuItem("Cài đặt tin vip",$__g_idMenu_Setting)
Global $__g_idMenu_Debug_Mode = GUICtrlCreateMenuItem("Debug Mode",$__g_idMenu_Setting)
; Tab 1
Global $Tab1 = GUICtrlCreateTab(0, 10, $GUI_WIDTH, $GUI_HEIGHT - 10)
Global $TabSheet1 = GUICtrlCreateTabItem("TabSheet1")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $Group1 = GUICtrlCreateGroup("Danh sach web hien tai", 76, 59, 329, 333)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Group2 = GUICtrlCreateGroup("Danh sach web can dang", 580, 59, 329, 333)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $List1 = GUICtrlCreateList("", 92, 98, 303, 285)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $List2 = GUICtrlCreateList("", 596, 99, 303, 285)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Button1 = GUICtrlCreateButton("Them", 541, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button2 = GUICtrlCreateButton("Them tat ca", 745, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Combo1 = GUICtrlCreateCombo("Combo1", 42, 445, 423, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
; Tab 2
Local $TabSheet2 = GUICtrlCreateTabItem("TabSheet2")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $Combo2 = GUICtrlCreateCombo("", 47, 59, 194, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo3 = GUICtrlCreateCombo("", 47, 107, 194, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo4 = GUICtrlCreateCombo("", 47, 155, 194, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo5 = GUICtrlCreateCombo("", 47, 203, 194, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Input1 = GUICtrlCreateInput("Dien tich", 47, 251, 143, 30,$ES_NUMBER)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Input5 = GUICtrlCreateInput("Gia", 47, 299, 194, 30)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo6 = GUICtrlCreateCombo("", 47, 347, 194, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Edit1 = GUICtrlCreateEdit("", 258, 57, 659, 283)
GUICtrlSetLimit(-1, 2000)
GUICtrlSetData(-1, "Noi dung")
Local $Edit2 = GUICtrlCreateEdit("", 258, 353, 455, 138,$ES_READONLY)
GUICtrlSetData(-1, "Hinh anh")
Local $Button4 = GUICtrlCreateButton("Them anh", 744, 353, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button3 = GUICtrlCreateButton("Xoa anh", 744, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button5 = GUICtrlCreateButton("Thong tin", 47, 395, 193, 97)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Label1 = GUICtrlCreateLabel("m2", 202, 259, 38, 35)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
; Tab 3
Local $TabSheet3 = GUICtrlCreateTabItem("TabSheet3")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $Group3 = GUICtrlCreateGroup("Danh sach web can dang", 76, 57, 329, 333)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $List3 = GUICtrlCreateList("", 92, 96, 303, 285,BitOR($WS_BORDER, $WS_VSCROLL))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Edit3 = GUICtrlCreateEdit("", 443, 57, 481, 119)
GUICtrlSetData(-1, "Tieu de")
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Button6 = GUICtrlCreateButton("Do dai tieu de", 445, 197, 480, 43)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Button7 = GUICtrlCreateButton("Tieu de truoc", 745, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button8 = GUICtrlCreateButton("Tu dong dien", 541, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button9 = GUICtrlCreateButton("Nhap lai", 337, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
; Tab 4
Local $TabSheet4 = GUICtrlCreateTabItem("TabSheet4")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $Group4 = GUICtrlCreateGroup("Danh sach web can dang", 46, 56, 329, 333)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $List4 = GUICtrlCreateList("", 62, 95, 303, 285,BitOR($WS_BORDER, $WS_VSCROLL))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Combo7 = GUICtrlCreateCombo("Tinh/thanh pho", 404, 75, 237, 25, BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo8 = GUICtrlCreateCombo("Quan/huyen", 667, 75, 237, 25, BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo9 = GUICtrlCreateCombo("Phuong/xa", 404, 120, 501, 25, BitOR($CBS_DROPDOWN,$WS_VSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo10 = GUICtrlCreateCombo("Duong", 404, 164, 501, 25, BitOR($CBS_DROPDOWN,$WS_VSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo11 = GUICtrlCreateCombo("Du an", 404, 209, 501, 25, BitOR($CBS_DROPDOWN,$WS_VSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Combo12 = GUICtrlCreateCombo("Loai tin vip", 404, 254, 501, 25, BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL))
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Input6 = GUICtrlCreateInput("",404,299,501,30)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Input3 = GUICtrlCreateInput("Ngay", 403, 295, 130, 30,$ES_NUMBER)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Label2 = GUICtrlCreateLabel("Ngay", 547, 303, 70, 26)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Checkbox1 = GUICtrlCreateCheckbox("Noi bat tin dang", 404, 345, 202, 25)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Checkbox2 = GUICtrlCreateCheckbox("Noi bat tin dang", 707, 345, 202, 25)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Checkbox3 = GUICtrlCreateCheckbox("Noi bat tin dang", 707, 307, 202, 25)
GUICtrlSetFont(-1, 15, 400, 0, "Times New Roman")
Local $Button10 = GUICtrlCreateButton("Tu dong tim", 745, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button11 = GUICtrlCreateButton("Nhap lai", 541, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button12 = GUICtrlCreateButton("Xoa dia chi", 337, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button13 = GUICtrlCreateButton("Luu dia chi", 133, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
; Tab 5
Local $TabSheet5 = GUICtrlCreateTabItem("TabSheet5")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $ListView1 = GUICtrlCreateListView("", 50, 62, 868, 166,$LVS_SINGLESEL,BitOR($LVS_EX_GRIDLINES,$LVS_EX_FULLROWSELECT))
Local $Button14 = GUICtrlCreateButton("Xoa tin", 745, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button15 = GUICtrlCreateButton("Sua tin", 541, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button16 = GUICtrlCreateButton("Xem anh", 334, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Global $Pic1 = GUICtrlCreateIcon($ICON_Black,"", 217, 262, 100, 100)
Global $Pic2 = GUICtrlCreateIcon($ICON_Black,"", 373, 262, 100, 100)
Global $Pic3 = GUICtrlCreateIcon($ICON_Black,"", 528, 262, 100, 100)
Global $Pic4 = GUICtrlCreateIcon($ICON_Black,"", 684, 262, 100, 100)
; Tab 6
Local $TabSheet6 = GUICtrlCreateTabItem("TabSheet6")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $Group8 = GUICtrlCreateGroup("Danh sach thanh cong", 52, 53, 384, 290)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $List6 = GUICtrlCreateList("", 71, 101, 346, 223)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Group9 = GUICtrlCreateGroup("Danh sach that bai", 529, 53, 384, 290)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $List7 = GUICtrlCreateList("", 550, 99, 346, 223)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Button20 = GUICtrlCreateButton("Kiem tra", 745, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button21 = GUICtrlCreateButton("Dang tin loi", 541, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Progress1 = GUICtrlCreateProgress(238, 379, 540, 36, $PBS_SMOOTH)
; Tab 7
Local $TabSheet7 = GUICtrlCreateTabItem("TabSheet7")
_GUICtrlTab_SetBkColor($Form1_1,$Tab1,$COLOR_BLUE)
Local $Group5 = GUICtrlCreateGroup("Danh sach da hen gio", 46, 52, 362, 333)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $List5 = GUICtrlCreateList("", 62, 91, 331, 285,BitOR($WS_BORDER, $WS_VSCROLL))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Input2 = GUICtrlCreateInput("04/08/2022", 421, 199, 238, 39)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Date1 = GUICtrlCreateDate("2022/04/08 12:55:32", 420, 276, 239, 39, BitOR($DTS_UPDOWN,$DTS_TIMEFORMAT))
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Group6 = GUICtrlCreateGroup("Tin trang", 422, 53, 238, 133)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Label3 = GUICtrlCreateLabel("Da cai dat", 423, 110, 228, 50,$ES_CENTER)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Group7 = GUICtrlCreateGroup("Sau khi dang tin", 687, 55, 238, 261)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Radio1 = GUICtrlCreateRadio("Sleep", 748, 118, 167, 36)
Local $Radio2 = GUICtrlCreateRadio("Tat may", 748, 163, 167, 36)
Local $Radio3 = GUICtrlCreateRadio("Nothing", 748, 208, 167, 36)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $Button17 = GUICtrlCreateButton("Luu tac vu", 745, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button18 = GUICtrlCreateButton("Kiem tra", 541, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
Local $Button19 = GUICtrlCreateButton("Xoa tac vu", 337, 436, 176, 57)
GUICtrlSetFont(-1, 20, 400, 0, "Times New Roman")
GUICtrlCreateTabItem("")
Local $iLast_Control = GUICtrlCreateDummy()
Local $aGUI_Size = WinGetClientSize($Form1_1)
Local $iFontSize = Int(2 * (5.25 + (8 * $aGUI_Size[0] / $GUI_WIDTH))) / 2
;~ ; Reset font size for all controls on main GUI
For $i = 0 To $iLast_Control
	Switch $i
		Case $Label3
			GUICtrlSetFont($i, $iFontSize + 10)
			ContinueLoop
	EndSwitch
	GUICtrlSetFont($i, $iFontSize)
Next

; Cập nhật lại tiếng Việt
Global $__g_h_MainGUI = $Form1_1
GUICtrlSetData($Group1,"Danh sách web hiện tại")
GUICtrlSetData($Group2,"Danh sách web cần đăng")
GUICtrlSetData($Button1,"Thêm")
GUICtrlSetData($Button2,"Thêm tất cả")

GUICtrlSetImage($Button1,$FOLDER_ICON & "\move.ico")
GUICtrlSetImage($Button2,$FOLDER_ICON & "\move.ico")
GUICtrlSetData($TabSheet1,"Chọn Web")
GUICtrlSetCursor($List1,0)
GUICtrlSetCursor($List2,0)
GUICtrlSetCursor($Button1,0)
GUICtrlSetCursor($Button2,0)
GUICtrlSetCursor($Combo1,0)

; Tab 2
GUICtrlSetData($TabSheet2,"Thông tin chính")
GUICtrlSetData($Combo2,"|Loại tin|Bán|Cho thuê")
_GUICtrlComboBox_SetCurSel($Combo2,0)
Local $estateString = "Nhà mặt tiền|Nhà trong hẻm|Biệt thự, nhà liền kề|Căn hộ chung cư|Phòng trọ, nhà trọ|"
$estateString &= "Văn phòng|Kho, xưởng|Nhà hàng, khách sạn|Shop, quán|Kiot|Trang trại|Mặt bằng|Đất thổ cư, đất ở|"
$estateString &= "Đất nền, liền kề, đất dự án|Đất nông, lâm nghiệp|Các loại khác"
GUICtrlSetData($Combo3,"|Loại bds|" & $estateString)
_GUICtrlComboBox_SetCurSel($Combo3,0)
GUICtrlSetData($Combo4,"|Số phòng ngủ|1 phòng ngủ|2 phòng ngủ|3 phòng ngủ|4 phòng ngủ|5 phòng ngủ|6 phòng ngủ")
_GUICtrlComboBox_SetCurSel($Combo4,0)
GUICtrlSetData($Combo5,"|Số wc|1 wc|2 wc|3 wc|4 wc|5 wc|6 wc")
_GUICtrlComboBox_SetCurSel($Combo5,0)
GUICtrlSetData($Input1,"") ; Diện tích
GUICtrlSendMsg($Input1, $EM_SETCUEBANNER, False, "Diện tích (m2)")
GUICtrlSetData($Input5,"") ; Giá
GUICtrlSendMsg($Input5, $EM_SETCUEBANNER, False, "Giá")
GUICtrlSetData($Combo6,"|Đơn vị|Thỏa thuận|Triệu|Tỷ|Trăm nghìn/m2|Triệu/m2")
_GUICtrlComboBox_SetCurSel($Combo6,0)

GUICtrlSetData($Edit1,"Điền nội dung vào đây") ; Nội dung
GUICtrlSetData($Button3,"Xóa ảnh")
GUICtrlSetImage($Button3,$FOLDER_ICON & "\remove image.ico")
GUICtrlSetData($Button4,"Thêm ảnh")
GUICtrlSetImage($Button4,$FOLDER_ICON & "\add image.ico")
GUICtrlSetData($Edit2,"Hình ảnh")
GUICtrlSetData($Button5,"Thông tin")

GUICtrlSetCursor($Combo2,0)
GUICtrlSetCursor($Combo3,0)
GUICtrlSetCursor($Combo4,0)
GUICtrlSetCursor($Combo5,0)
GUICtrlSetCursor($Combo6,0)
GUICtrlSetCursor($Button3,0)
GUICtrlSetCursor($Button4,0)
GUICtrlSetCursor($Button5,7)
GUICtrlSetCursor($Edit2,7)
; Tab 3 - Tiêu đề
GUICtrlSetData($TabSheet3,"Tiêu đề")
GUICtrlSetData($Group3,"Danh sách web cần đăng")
GUICtrlSetData($Edit3,"Nhập tiêu đề tại đây")
GUICtrlSetData($Button6,"Độ dài tiêu đề")
GUICtrlSetData($Button7,"Tiêu đề trước")
GUICtrlSetImage($Button7,$FOLDER_ICON & "\undo.ico")
GUICtrlSetData($Button8,"Tự động điền")
GUICtrlSetImage($Button8,$FOLDER_ICON & "\check.ico")
GUICtrlSetData($Button9,"Nhập lại")
GUICtrlSetImage($Button9,$FOLDER_ICON & "\x.ico")

GUICtrlSetCursor($Button6,0)
GUICtrlSetCursor($Button7,0)
GUICtrlSetCursor($Button8,0)
GUICtrlSetCursor($Button9,0)
GUICtrlSetCursor($List3,0)
; Tab 4 - Địa chỉ
GUICtrlSetData($TabSheet4,"Địa chỉ")
GUICtrlSetData($Group4,"Danh sách web cần đăng")
GUICtrlSetData($Combo7,"|Tỉnh/thành phố")
_GUICtrlComboBox_SetCurSel($Combo7,0)
GUICtrlSetData($Combo8,"|Quận/huyện")
_GUICtrlComboBox_SetCurSel($Combo8,0)
GUICtrlSetData($Combo9,"|Phường/xã")
_GUICtrlComboBox_SetCurSel($Combo9,0)
GUICtrlSetData($Combo10,"|Đường")
_GUICtrlComboBox_SetCurSel($Combo10,0)
GUICtrlSetData($Combo11,"|Dự án")
_GUICtrlComboBox_SetCurSel($Combo11,0)
GUICtrlSetData($Combo12,"|Địa chỉ đã lưu")
_GUICtrlComboBox_SetCurSel($Combo12,0)

GUICtrlSendMsg($Input6, $EM_SETCUEBANNER, False, "Địa chỉ hiển thị")
GUICtrlSendMsg($Combo7, $CB_SETMINVISIBLE, 10, 0)
GUICtrlSendMsg($Combo8, $CB_SETMINVISIBLE, 10, 0)
GUICtrlSendMsg($Combo9, $CB_SETMINVISIBLE, 10, 0)
GUICtrlSendMsg($Combo10, $CB_SETMINVISIBLE, 10, 0)
GUICtrlSendMsg($Combo11, $CB_SETMINVISIBLE, 10, 0)
GUICtrlSendMsg($Combo12, $CB_SETMINVISIBLE, 10, 0)
GUICtrlSetState($Input3,32)
GUICtrlSetState($Label2,32)
GUICtrlSetState($Checkbox1,32)
GUICtrlSetState($Checkbox2,32)
GUICtrlSetState($Checkbox3,32)
GUICtrlSetData($Label2,"Ngày")

GUICtrlSetData($Button10,"Tự động tìm")
GUICtrlSetImage($Button10,$FOLDER_ICON & "\search.ico")
GUICtrlSetData($Button11,"Nhập lại")
GUICtrlSetImage($Button11,$FOLDER_ICON & "\x.ico")
GUICtrlSetData($Button12,"Xóa địa chỉ")
GUICtrlSetImage($Button12,$FOLDER_ICON & "\remove address.ico")
GUICtrlSetData($Button13,"Lưu địa chỉ")
GUICtrlSetImage($Button13,$FOLDER_ICON & "\add address.ico")

GUICtrlSetCursor($List4,0)
GUICtrlSetCursor($Combo7,0)
GUICtrlSetCursor($Combo8,0)
GUICtrlSetCursor($Combo12,0)
GUICtrlSetCursor($Button10,0)
GUICtrlSetCursor($Button11,0)
GUICtrlSetCursor($Button12,0)
GUICtrlSetCursor($Button13,0)
; Tab 5 - Tin đăng đã lưu
GUICtrlSetData($Tabsheet5,"Tin đăng đã lưu")
GUICtrlSetColor($Listview1, 0xffffff) ; Chữ màu trắng
GUICtrlSetBkColor($Listview1, 0x208557)
GUICtrlSetData($Button14,"Xóa tin")
GUICtrlSetData($Button15,"Sửa tin")
GUICtrlSetData($Button16,"Xem ảnh")
GUICtrlSetImage($Button14,$FOLDER_ICON & "\remove post.ico")
GUICtrlSetImage($Button15,$FOLDER_ICON & "\edit post.ico")
GUICtrlSetImage($Button16,$FOLDER_ICON & "\view image.ico")
GUICtrlSetImage($Pic1,$ICON_Black)
GUICtrlSetImage($Pic2,$ICON_Black)
GUICtrlSetImage($Pic3,$ICON_Black)
GUICtrlSetImage($Pic4,$ICON_Black)

GUICtrlSetCursor($Button14,0)
GUICtrlSetCursor($Button15,0)
GUICtrlSetCursor($Button16,0)
; Tab 6
GUICtrlSetData($TabSheet6,"Quá trình đăng tin")
GUICtrlSetData($Button21,"Đăng trang lỗi")
GUICtrlSetImage($Button21,$FOLDER_ICON & "\undo.ico")
GUICtrlSetData($Button20,"Kiểm tra")
GUICtrlSetImage($Button20,$FOLDER_ICON & "\check.ico")
GUICtrlSetData($Group8,"Danh sách thành công")
GUICtrlSetData($Group9,"Danh sách thất bại")

GUICtrlSetCursor($Button21,0)
GUICtrlSetCursor($Button20,0)
GUICtrlSetCursor($List7,0)
GUICtrlSetCursor($List6,0)
; Tab 7
GUICtrlSetData($TabSheet7,"Hẹn giờ đăng tin")
GUICtrlSetData($Group5,"Danh sách đã hẹn giờ")
GUICtrlSetData($Group6,"Tình trạng")
GUICtrlSetData($Group7,"Sau khi đăng tin")
GUICtrlSetData($Button17,"Lưu tác vụ")
GUICtrlSetImage($Button17,$FOLDER_ICON & "\save.ico")
GUICtrlSetData($Button18,"Kiểm tra")
GUICtrlSetImage($Button18,$FOLDER_ICON & "\check.ico")
GUICtrlSetData($Button19,"Xóa tác vụ")
GUICtrlSetImage($Button19,$FOLDER_ICON & "\remove post.ico")
GUICtrlSetData($Radio2,"Tắt máy")
GUICtrlSetState($Radio3, $GUI_CHECKED)
;~ 	GUIRegisterMsg($WM_COMMAND, "My_WM_COMMAND")
;~ 	GUICtrlSetData($Label4,"Mật khẩu máy tính (Nếu có)")

;~ 	GUICtrlSendMsg($Input4, $EM_SETCUEBANNER, False, "Mật khẩu máy tính (Nếu có)")

GUICtrlSetCursor($List5,0)
GUICtrlSetCursor($Input2,5)
GUICtrlSetCursor($Button17,0)
GUICtrlSetCursor($Button18,0)
GUICtrlSetCursor($Button19,0)
GUICtrlSetCursor($Radio1,0)
GUICtrlSetCursor($Radio2,0)
GUICtrlSetCursor($Radio3,0)
GUICtrlSetState($TabSheet1,$GUI_SHOW)

; Đổi tên ID GUI
; Tab Main
Global $__g_idDummy_Main_NextTab 		= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Ctrl_A	 	= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Ctrl_S	 	= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Ctrl_N	 	= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Ctrl_Z	 	= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Ctrl_Tab	 	= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Tab	 		= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Right	 	= GUICtrlCreateDummy()
Global $__g_idDummy_Hotkey_Left	 		= GUICtrlCreateDummy()
Global $__g_idTab_Main = $Tab1
; Tab 1 - Chọn web
Global $__g_idCombo_ChooseWeb_ListName = $Combo1
Global $__g_idList_ChooseWeb_Current = $List1
Global $__g_idList_ChooseWeb_Post = $List2
Global $keyLeftChooseWeb = GUICtrlCreateDummy()
Global $keyRightChooseWeb = GUICtrlCreateDummy()
Global $__g_idButton_ChooseWeb_Move = $Button1
Global $__g_idButton_ChooseWeb_MoveAll = $Button2
; Tab 2 - Thông tin chính
Global $__g_idButton_Tab2_AddImage = $Button4
Global $__g_idButton_Tab2_RemoveImage = $Button3
Global $__g_idButton_Tab2_Infor = $Button5
Global $__g_idEdit_Tab2_Content = $Edit1
Global $__g_idEdit_Tab2_Image = $Edit2
Global $__g_idCombo_Tab2_PostType = $Combo2
Global $__g_idCombo_Tab2_EstateType = $Combo3
Global $__g_idCombo_Tab2_Room = $Combo4
Global $__g_idCombo_Tab2_Wc = $Combo5
Global $__g_idInput_Tab2_Acr = $Input1
Global $__g_idInput_Tab2_Price = $Input5
Global $__g_idCombo_Tab2_PriceType = $Combo6
; Tab 3 - Tiêu đề
Global $__g_idList_Tab3_Post = $List3
Global $__g_idEdit_Tab3_Title = $Edit3
Global $__g_idButton_Tab3_TitleLen = $Button6
Global $__g_idDummy_Tab3_NextSite = GUICtrlCreateDummy()
Global $__g_idDummy_Tab3_LastTitle = GUICtrlCreateDummy()
Global $__g_idButton_TitleManager_LastTitle = $Button7
Global $__g_idButton_TitleManager_Complete = $Button8
Global $__g_idButton_TitleManager_Remove = $Button9

; Tab 4 - Địa chỉ
Global $__g_idList_Address_Site 			= $List4
Global $__g_idInput_Address_Date 			= $Input3
Global $__g_idLabel_Address_Date 			= $Label2
Global $__g_idCheckbox_Address_Option1 		= $Checkbox1
Global $__g_idCheckbox_Address_Option2 		= $Checkbox2
Global $__g_idCombo_Address_City 			= $Combo7
Global $__g_idCombo_Address_District 		= $Combo8
Global $__g_idCombo_Address_Ward 			= $Combo9
Global $__g_idCombo_Address_Street 			= $Combo10
Global $__g_idCombo_Address_Project 		= $Combo11
Global $__g_idButton_Address_Search 		= $Button10
Global $__g_idCombo_Address_SavedAddress 	= $Combo12
Global $__g_idInput_Address_Direct 			= $Input6
Global $__g_idButton_Address_SaveAddress 	= $Button13
Global $__g_idButton_Address_Reset 			= $Button11
Global $__g_idButton_Address_RemoveAddress 	= $Button12
; Tab 5 - Tin đăng đã lưu
Global $__g_idListview_Tab5_SavedPost 	= $ListView1
Global $__g_idButton_Tab5_ViewImage 	= $Button16
Global $__g_idButton_Tab5_EditPost 		= $Button15
Global $__g_idButton_Tab5_RemovePost 	= $Button14
; Tab 6 - Quá trình đăng tin
Global $__g_idProgress_Tab6_Process = $Progress1
Global $__g_idList_Tab6_Success = $List6
Global $__g_idList_Tab6_Fail = $List7
Global $__g_idButton_Tab6_Check = $Button20
Global $keyLeftTab6 = GUICtrlCreateDummy()
Global $keyRightTab6 = GUICtrlCreateDummy()

; Tab 7 - Hẹn giờ
Global $__g_idList_Timer_TaskName = $List5
Global $__g_idInput_Timer_Date = $Input2
Global $__g_idDate_Timer_Time = $Date1
Global $__g_idRadio_Timer_Nothing = $Radio3
Global $__g_idLabel_Timer_Status = $Label3
Global $__g_idRadio_Timer_Sleep = $Radio1
Global $__g_idRadio_Timer_TurnOff = $Radio2
Global $__g_idButton_Timer_Save	= $Button17
; Gán Func cho ID GUI
GUIRegisterMsg($WM_COMMAND, "My_WM_COMMAND")
GUISetOnEvent($GUI_EVENT_CLOSE,"GUIExit",$Form1_1)
GUICtrlSetOnEvent($__g_idTab_Main,"Hotkey_Setting")
GUICtrlSetOnEvent($__g_idMenu_Setting_Web,"ChooseWeb_Manager_GUI")
GUICtrlSetOnEvent($__g_idMenu_SavePost,"Post_Manager_SavePost")
GUICtrlSetOnEvent($__g_idMenu_NewPost,"Post_Manager_NewPost")
GUICtrlSetOnEvent($__g_idMenu_Setting_Account,"AccountSetting_GUI")
GUICtrlSetOnEvent($__g_idMenu_Setting_Vip,"VIP_Manager_GUI")
GUICtrlSetOnEvent($__g_idMenu_Posting,"Posting_checkSite")
GUICtrlSetOnEvent($__g_idMenu_Debug_Mode,"Switch_Debug_Mode")
GUICtrlSetOnEvent($__g_idDummy_Main_NextTab,"NextTab")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Ctrl_A	,"Hotkey_Ctrl_A")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Ctrl_S	,"Hotkey_Ctrl_S")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Ctrl_N	,"Hotkey_Ctrl_N")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Ctrl_Z	,"Hotkey_Ctrl_Z")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Ctrl_Tab	,"Hotkey_Ctrl_Tab")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Tab		,"Hotkey_Tab")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Right		,"Hotkey_Right")
GUICtrlSetOnEvent($__g_idDummy_Hotkey_Left		,"Hotkey_Left")

; Tab 1 - Chọn web
GUICtrlSetOnEvent($keyLeftChooseWeb	,"ChooseWeb_KeyLeft")
GUICtrlSetOnEvent($keyRightChooseWeb,"ChooseWeb_KeyRight")
GUICtrlSetOnEvent($__g_idList_ChooseWeb_Current	,"ChooseWeb_ClickLeft")
GUICtrlSetOnEvent($__g_idList_ChooseWeb_Post	,"ChooseWeb_ClickRight")
GUICtrlSetOnEvent($__g_idButton_ChooseWeb_Move,"ChooseWeb_AddOrRemove")
GUICtrlSetOnEvent($__g_idButton_ChooseWeb_MoveAll,"ChooseWeb_AddOrRemoveAll")
GUICtrlSetOnEvent($__g_idCombo_ChooseWeb_ListName,"ChooseWeb_LoadWebFromList")

; Tab 2 - Thông tin chính
GUICtrlSetOnEvent($__g_idButton_Tab2_AddImage	, "Tab2_AddImage")
GUICtrlSetOnEvent($__g_idButton_Tab2_RemoveImage, "Tab2_RemoveImage")

; Tab 3 - Tiêu đề
GUICtrlSetOnEvent($__g_idList_Tab3_Post					, "TitleManager_LoadTitle")
GUICtrlSetOnEvent($__g_idButton_TitleManager_LastTitle	, "TitleManager_LastTitle")
GUICtrlSetOnEvent($__g_idButton_TitleManager_Complete	, "TitleManager_CompleteTitle")
GUICtrlSetOnEvent($__g_idButton_TitleManager_Remove		, "TitleManager_RemoveAllTitle")
GUICtrlSetOnEvent($__g_idDummy_Tab3_NextSite			, "TitleManager_NextSite")
; Tab 4 - Địa chỉ
GUICtrlSetOnEvent($__g_idCombo_Address_City				,"Address_LoadDistrict_CheckSite")
GUICtrlSetOnEvent($__g_idCombo_Address_District			,"Address_LoadWard_CheckSite")
GUICtrlSetOnEvent($__g_idCombo_Address_Ward				,"Address_SaveWard")
GUICtrlSetOnEvent($__g_idCombo_Address_Street			,"Address_SaveStreet")
GUICtrlSetOnEvent($__g_idCombo_Address_Project			,"Address_SaveProject")
GUICtrlSetOnEvent($__g_idButton_Address_Search			,"Address_Search_GUI")
GUICtrlSetOnEvent($__g_idList_Address_Site				,"Address_ChangeSite")
GUICtrlSetOnEvent($__g_idButton_Address_SaveAddress		,"Address_SaveAddress")
GUICtrlSetOnEvent($__g_idButton_Address_Reset			,"Address_ResetAddress")
GUICtrlSetOnEvent($__g_idCombo_Address_SavedAddress		,"Address_LoadSavedAddress")
GUICtrlSetOnEvent($__g_idButton_Address_RemoveAddress	,"Address_RemoveAddress")
; Tab 5 - Tin đã lưu
GUICtrlSetOnEvent($__g_idButton_Tab5_ViewImage	,"Post_Manager_ViewImage")
GUICtrlSetOnEvent($__g_idButton_Tab5_EditPost	,"Post_Manager_EditPost")
GUICtrlSetOnEvent($__g_idButton_Tab5_RemovePost	,"Post_Manager_RemovePost")
; Tab 6 - Quá trình đăng tin
GUICtrlSetOnEvent($__g_idButton_Tab6_Check,"CheckResultPosting")
GUICtrlSetOnEvent($Button21,"Re_Posting_Error")
GUICtrlSetOnEvent($__g_idList_Tab6_Success,"Tab6_ClickLeft")
GUICtrlSetOnEvent($__g_idList_Tab6_Fail,"Tab6_ClickRight")
GUICtrlSetOnEvent($keyLeftTab6,"Tab6_KeyLeft")
GUICtrlSetOnEvent($keyRightTab6,"Tab6_KeyRight")
; Tab 7 - Hẹn giờ
GUICtrlSetOnEvent($__g_idButton_Timer_Save,"Timer_CheckBeforeSet")

Global $__g_a_Hotkey = [["^a",$__g_idDummy_Hotkey_Ctrl_A] _
	, ["^s",$__g_idDummy_Hotkey_Ctrl_S] 		_
	, ["^n",$__g_idDummy_Hotkey_Ctrl_N] 		_
	, ["^z",$__g_idDummy_Hotkey_Ctrl_Z] 		_
	, ["^{TAB}",$__g_idDummy_Hotkey_Ctrl_Tab] 	_
	, ["{TAB}",$__g_idDummy_Hotkey_Tab] 		_
	, ["{LEFT}",$__g_idDummy_Hotkey_Left] 		_
	, ["{RIGHT}",$__g_idDummy_Hotkey_Right]]
GUISetAccelerators($__g_a_Hotkey,$__g_h_MainGUI)

Func GUIExit()
	Local $confirm = ErrorShow($MB_YESNO + $MB_ICONQUESTION,"","BẠN CÓ CHẮC CHẮN MUỐN THOÁT PHẦN MỀM?")
	If $confirm = 6 Then
		ProcessClose($pIdServer)
		Exit
	Else
		Return False
	EndIf
EndFunc

Func _GUICtrlTab_SetBkColor($hWnd, $hSysTab32, $sBkColor)
	Local $aTabPos = ControlGetPos($hWnd, "", $hSysTab32)
	Local $aTab_Rect = _GUICtrlTab_GetItemRect($hSysTab32, -1)
	GUICtrlCreateLabel("", $aTabPos[0], $aTabPos[1]+$aTab_Rect[3]+15, $aTabPos[2]-0, $aTabPos[3]-$aTab_Rect[3]-7)
	GUICtrlSetBkColor(-1, $sBkColor)
	GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc

Func My_WM_COMMAND($hWnd, $imsg, $iwParam, $ilParam)
	Local $setHK = False
	Local $nNotifyCode = BitShift($iwParam, 16)
	Local $nID = BitAND($iwParam, 0x0000FFFF)
	Local $hCtrl = $ilParam

	Local $handle_Content = GUICtrlGetHandle($__g_idEdit_Tab2_Content)
	Local $handle_Title = GUICtrlGetHandle($__g_idEdit_Tab3_Title)
	Local $handle_Address = GUICtrlGetHandle($__g_idInput_Address_Direct)
	;~ 	Local $handle_Date = GUICtrlGetHandle($__g_idInput_Tab4_Date)
	If $nNotifyCode = $EN_CHANGE Then
		Switch $hCtrl
			Case $handle_Content
				Tab2_CountContent()
			Case $handle_Title
				TitleManager_CountTitle()
			Case $handle_Address
				Address_SaveDirect()
		EndSwitch
	ElseIf $nNotifyCode = $EN_SETFOCUS Then
		Switch $hCtrl
			Case $handle_Content
				If GUICtrlRead($__g_idTab_Main) = 1 Then
					If GUICtrlRead($__g_idEdit_Tab2_Content) = "Điền nội dung vào đây" Then
						GUICtrlSetData($__g_idEdit_Tab2_Content,"")
					EndIf
					Tab2_CountContent()
				EndIf
			Case $handle_Title
				If GUICtrlRead($__g_idTab_Main) = 2 Then
					If GUICtrlRead($__g_idEdit_Tab3_Title) = "Nhập tiêu đề tại đây" Then
						GUICtrlSetData($__g_idEdit_Tab3_Title,"")
					EndIf
					TitleManager_CountTitle()
				EndIf
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>My_WM_COMMAND

Func StringSelectAll()
	Write_Log("===================")
	Write_Log("+ StringSelectAll")
	Local $id = _WinAPI_GetFocus()
	_GUICtrlEdit_SetSel($id,0,-1)
EndFunc




