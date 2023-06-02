#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Data\icon\main icon.ico
#Au3Stripper_Parameters=/mo /sf=0 /sv=0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)
Opt("GUIResizeMode", 1)
#include-once
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <GuiTab.au3>
#include <ListViewConstants.au3>
#include <ProgressConstants.au3>
#include <DateTimeConstants.au3>
#include <GuiComboBox.au3>
#include <Array.au3>
#include <GuiListBox.au3>
#include <GDIPlus.au3>
#include <Crypt.au3>
#include <GuiListView.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <Date.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <GuiEdit.au3>

#include-once
#include <include/UDF/Write Log/Write_Log.au3>
#include <include/Constant/Constant Main.au3>
#include <include/GUI.au3>
#include <include/UDF/ConsoleWriteVi/ConsoleWriteVi.au3>
#include <include/UDF/_PrintFromArray/_PrintFromArray.au3>
#include <include/UDF/Compare2/Compare2.au3>
#include <include/UDF/ConvertVie/ConvertVie.au3>
#include <include/UDF/StringSplit2D/StringSplit2D.au3>
#include <include/UDF/__ArrayToString/__ArrayToString.au3>
#include <include/UDF/__Center/__Center.au3>
#include <include/UDF/AddDate/addDate.au3>
#include <include/UDF/_TrayTip/_TrayTip.au3>
#include <include/UDF/API/API.au3>
#include <include/UDF/_StringToBase64/_StringToBase64.au3>

;~ GetTaskName()
;~ ConnectTask()

#include-once
#include <include/UDF/_HttpRequest/_HttpRequest.au3>
#include <include/Constant/Chotot.com.au3>
#include <include/Constant/Batdongsan.com.vn.au3>
#include <include/Constant/Dothi.net.au3>
#include <include/Constant/Muaban.net.au3>
#include <include/Constant/Bds123.vn.au3>
#include <include/Constant/Thuecanho123.com.au3>
#include <include/Constant/Homedy.com.au3>
#include <include/Control GUI/FuncTab1/Manager Site List.au3>
#include <include/Control GUI/FuncTab1/Choose Site.au3>
#include <include/Control GUI/FuncTab2/Content Counter.au3>
#include <include/Control GUI/FuncTab2/Image Control.au3>
#include <include/Control GUI/FuncTab3/Title Manager.au3>
#include <include/Control GUI/FuncTab4/Address Manager.au3>
#include <include/Control GUI/FuncTab5/Post Manager.au3>
#include <include/Control GUI/FuncTab6/AfterPost.au3>
#include <include/Control GUI/Timer/Timer.au3>
#include <include/Control GUI/VipManager.au3>
#include <include/Batdongsan.com.vn.au3>
#include <include/Muaban.net.au3>
#include <include/Dothi.net.au3>
#include <include/Bds123.vn.au3>
#include <include/Chotot.com.au3>
#include <include/Control GUI/FuncMain/NextTab.au3>
#include <include/Control GUI/FuncMain/Switch_Debug_Mode.au3>
#include <include/Control GUI/FuncTab4/Load Address.au3>
#include <include/Control GUI/FuncTab4/Search Address.au3>
#include <include/Control GUI/Hotkey Setting.au3>
#include <include/Account/Account.au3>
#include <include/Posting/checkBeforePost.au3>
#include <include/Posting/Batdongsan.com.vn.au3>
#include <include/Posting/Dothi.net.au3>
#include <include/Posting/Bds123.vn.au3>
#include <include/Posting/Muaban.net.au3>
#include <include/Posting/Chotot.com.au3>
#include <include/Posting/Thuecanho123.com.au3>
#include <include/Posting/Homedy.com.au3>
#include <include/UDF/CoProcEx/CoProcEx.au3>

Global $pIdServer = _CoProc_Create("AccountSetting_Server_Login_TurnOn")
_CoProc_Suspend($pIdServer)
_HttpRequest_CookieJarSet($FILE_COOKIE)
; Chạy trước khi hiện GUI
ChooseWeb_LoadList()
Address_LoadCity()
Hotkey_Setting()
Post_Manager_LoadSavedPost() ; Load những tin đăng đã lưu
Address_LoadSavedAddressName() ; Load tên địa chỉ đã lưu
GUISetState(@SW_SHOW,$Form1_1)

While 1
	Sleep(100)
WEnd