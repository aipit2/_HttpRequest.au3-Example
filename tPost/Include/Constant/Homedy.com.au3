Global Const $HOMEDY_URL = "Homedy.com"
Global Const $HOMEDY_URL_LOGIN = "https://homedy.com/User/SSO_LoginAjax"
Global Const $HOMEDY_FOLDER_DATA = $FOLDER_MAIN_DATA & $HOMEDY_URL & "\"
Global Const $HOMEDY_HEADER_LOGIN = StringReplace(FileRead($HOMEDY_FOLDER_DATA & "HEADER_LOGIN.data"),@CRLF,"|")
Global Const $HOMEDY_REG_ACCOUNT = $REG_ACCOUNT & $HOMEDY_URL
Global Const $HOMEDY_ARRAY_CITY_ID = FileReadToArray($HOMEDY_FOLDER_DATA & "ARRAY_CITY_ID.data")
Global Const $HOMEDY_URL_UPLOAD = "https://agent.homedy.com/Media/AsyncUploadList"
Global Const $HOMEDY_DATA_POSTING = FileRead($HOMEDY_FOLDER_DATA & "JSON_DATA_POSTING.data")
Global Const $HOMEDY_JSON_DATA_POSTING = _HttpRequest_ParseJSON($HOMEDY_DATA_POSTING)
Global Const $HOMEDY_ARRAY_ESTATE_ID = FileReadToArray($HOMEDY_FOLDER_DATA & "DATA_ESTATE_ID.data")
Global Const $HOMEDY_ARRAY_POST_ID = [0,1,2]
Global Const $HOMEDY_ARRAY_VIP_ID = [4,3,2,1]
Global Const $HOMEDY_URL_POSTING = "https://agent.homedy.com/Product/SubmitProduct"
;~ Global Const $HOMEDY_ARRAY_PRICE [0,]


Func Homedy_Url_Get_District($cityId)
	Return "https://agent.homedy.com/Common/GetDistrictsByCity?cityId=" & $cityId
EndFunc

Func Homedy_Url_Get_Ward($districtId)
	Return "https://agent.homedy.com/Common/GetWardsByDistrict?districtId=" & $districtId
EndFunc

Func Homedy_Url_Get_Street($districtId)
	Return "https://agent.homedy.com/Common/GetStreetsByDistrict?districtId=" & $districtId
EndFunc

Func Homedy_Url_Get_Project($projectSearch)
	Return "https://agent.homedy.com/Product/SearchProjects?keyword=" & StringRegExpReplace($projectSearch,"\s","\+")
EndFunc

Func Homedy_Data_Upload($imageDir)
	Local $result = ["$_fromFile=" & $imageDir]
	Return $result
EndFunc
