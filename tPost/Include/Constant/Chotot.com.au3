Global Const $CHOTOT_URL = 'Chotot.com'
Global Const $CHOTOT_FOLDER_DATA = @ScriptDir & '\Data\' & $CHOTOT_URL & '\'
Global Const $CHOTOT_ARRAY_CITY_ID = FileReadToArray($CHOTOT_FOLDER_DATA & 'CITY_ID.data')
Local $dataAddress = FileRead($CHOTOT_FOLDER_DATA & 'JSON_DATA_ADDRESS.data')
Global Const $CHOTOT_JSON_DATA_ADDRESS = _HttpRequest_ParseJSON($dataAddress)
Global Const $REG_ACCOUNT_CHOTOT = $REG_ACCOUNT & $CHOTOT_URL
Global Const $CHOTOT_ARRAY_ESTATE_NAME = ["","apartment_type","house_type","commercial_type","land_type"]
Local $estateId
_FileReadToArray($CHOTOT_FOLDER_DATA & "ESTATE_ID.data",$estateId,0,"|")
Global Const $CHOTOT_ARRAY_ESTATE_ID = $estateId
Global Const $CHOTOT_FORM_POSTING = FileRead($CHOTOT_FOLDER_DATA & "FORM_POSTING.data")
Global Const $CHOTOT_URL_UPLOAD = "https://cloudgw.chotot.com/v1/private/images/upload"
Global Const $CHOTOT_URL_POSTING = "https://gateway.chotot.com/v2/private/flashad/new"
Global Const $CHOTOT_ARRAY_POST_TYPE = ["","s","u"]
#Region ; Login
	Global Const $CHOTOT_URL_LOGIN = "https://gateway.chotot.com/v1/public/auth/login"
	Func Chotot_Data_Login($user,$pass)
		Return '{"phone":"'&$user&'","password":"'&$pass&'"}'
	EndFunc
#EndRegion