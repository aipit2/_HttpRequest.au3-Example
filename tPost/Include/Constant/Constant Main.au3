Global $__g_b_TestingMode = True

Global $GUI_WIDTH = 960
Global $GUI_HEIGHT = 540

Global Const $COLOR_BLUE = 0x6BAAF8
Global Const $COLOR_GREEN = 0x68EA06
Global Const $COLOR_ORANGE = 0xe64607
Global $__g_a_ImageLink[0] ; Mảng chứa link ảnh
Global Const $REG_DIR				= "HKEY_CURRENT_USER\Software\TPOST"
Global Const $REG_SITELIST 			= $REG_DIR & "\SITE_LIST\"
Global Const $REG_CONFIG 			= $REG_DIR & "\CONFIG\"
Global Const $REG_RESPONSE 			= $REG_DIR & "\RESPONSE\"
Global Const $REG_SAVEPOST 			= $REG_DIR & "\SAVE_POST\"
Global Const $REG_SAVEADDRESS 		= $REG_DIR & "\SAVE_ADDRESS\"
Global Const $REG_ACCOUNT 			= $REG_DIR & "\ACCOUNT\"
Global Const $REG_VIP_SETTING 		= $REG_DIR & "\VIP_SETTING\"
Global Const $REG_RESULT_POSTING 	= $REG_DIR & "\RESULT_POSTING\"
Global Const $REG_TASK 				= $REG_DIR & "\TASK\"
Global Const $FOLDER_ICON 			= @ScriptDir & "\Data\icon\"
Global Const $ICON_Black 			= $FOLDER_ICON & 'black.ico'
Global Const $FOLDER_MAIN_DATA 		= @ScriptDir & '\Data\'
Global Const $JSON_FORM_POSTING 	= FileRead($FOLDER_MAIN_DATA & "JSON_FORM_POSTING.data")
Global Const $FILE_COOKIE		 	= @ScriptDir & "\Data\Cookie\Cookie.txt"
;~ Global Const $__g_folder_TaskName = "\TPOST"
;~ Global Const $__g_i_Timeout = -1
;~ Global Const $__g_i_CancelButton = 2
;~ Global Const $__g_i_OKButton = 1
Local $aWebLimit
_FileReadToArray($FOLDER_MAIN_DATA & "ARRAY_WEB_LIMIT.data",$aWebLimit,0,"|")
Global Const $WEB_LIMIT = $aWebLimit
Global $arrayMain[0][23]
Global Enum $eSite, $eLimit, $eTitle, $eCityName,$eArrayCityName, $eCityId, _
$eArrayCityId, $eDistrictName, $eArrayDistrictName, $eDistrictId, $eArrayDistrictId, _
$eWardName, $eArrayWardName, $eWardId, $eArrayWardId, _
$eStreetName, $eArrayStreetName, $eStreetId, $eArrayStreetId, _
$eProjectName, $eArrayProjectName, $eProjectId, $eArrayProjectId

Global Const $__g_a_CityName = FileReadToArray($FOLDER_MAIN_DATA & "ARRAY_CITY_NAME.data")
Global Const $__g_a_CityId = FileReadToArray($FOLDER_MAIN_DATA & "ARRAY_CITY_ID.data")
Global $__g_i_CityIndex
Global $__g_s_CityName, $__g_s_CityId
Global $__g_a_DistrictName, $__g_a_DistrictId, $__g_s_DistrictName, $__g_s_DistrictId
Global $__g_a_WardName, $__g_a_WardId, $__g_s_WardName, $__g_s_WardId
Global $__g_a_StreetName, $__g_a_StreetId, $__g_s_StreetName, $__g_s_StreetId
Global $__g_a_ProjectName, $__g_a_ProjectId, $__g_s_ProjectName, $__g_s_ProjectId
Global $__g_s_AddressPost
Global $HOMEDY_IS_LOGIN = False
Global $__g_s_CurrentPostName
Global $__g_a_PostName[0]
Global $__g_a_UserHeader = FileReadToArray($FOLDER_MAIN_DATA & "ARRAY_HEADER_LISTVIEW.data")