Global Const $BDS123_URL = 'Bds123.vn'
Global Const $BDS123_FOLDER_DATA = @ScriptDir & '\Data\' & $BDS123_URL & "\"
Global Const $BDS123_REG_ACCOUNT = $REG_ACCOUNT & $BDS123_URL
Global Const $BDS123_ARRAY_CITY_ID = FileReadToArray($BDS123_FOLDER_DATA & "ARRAY_CITY_ID.data")
Global Const $BDS123_URL_LOGIN = 'https://bds123.vn/api/user/login'
Global Const $BDS123_URL_GET_UPLOAD_TOKEN = 'https://bds123.vn/dashboard/dang-tin'
Global Const $BDS123_URL_UPLOAD = 'https://static123.com/api/upload'
Local $arrayEstateId[0]
_FileReadToArray($BDS123_FOLDER_DATA & 'ARRAY_ESTATE_ID.data',$arrayEstateId,0,'|')
Global Const $BDS123_ARRAY_ESTATE_ID = $arrayEstateId
Global Const $BDS123_ERROR_LOGIN = ['Đăng nhập thành công', 'Không tìm thấy User ID', 'Không tìm thấy Số điện thoại', 'Không tìm thấy Tên']
Global Const $BDS123_ARRAY_PRICE = [0,0,10^6,10^9,10^6,10^7]
Global Const $Bds123_ARRAY_PRICE_TYPE = [[17,17,17,17,18,18],[20,20,20,20,19,19]] ; 17 is Đồng, 18 is Đồng/m2 || Tháng
Local $sEstate = FileRead($BDS123_FOLDER_DATA & 'JSON_ESTATE_ID.data')
Global Const $BDS123_JSON_ESTATE_ID = _HttpRequest_ParseJSON($sEstate)
Global Const $BDS123_URL_PAY = "https://bds123.vn/api/post/repay"