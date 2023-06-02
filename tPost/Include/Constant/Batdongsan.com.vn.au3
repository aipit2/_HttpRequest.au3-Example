Global Const $BDS_URL = "Batdongsan.com.vn"
Global Const $BDS_FOLDER_DATA = @ScriptDir & '\Data\' & $BDS_URL & "\"
Global Const $BDS_HEADER_GET_ADDRESS = StringReplace(FileRead($BDS_FOLDER_DATA & "HEADER_GET_ADDRESS.data"), @CRLF, "|")

Global Const $BDS_REGEX_GET_Name = 'name":"(.*?)"'
Global Const $BDS_REGEX_GET_ID = 'id":(\d+)'

Global Const $__g_a_Bds_PostTypeId = [0, 38, 49] ; Mảng id loại tin
Global Const $__g_a_Bds_VipId = [5, 3, 2, 1, 0] ;
Global Const $__g_a_Bds_EstateTypeId[17][2] = [[-1,-1], _
	[163, 51	], _
	[41	, 52	], _
	[325, 577	], _
	[324, 326	], _
	[41	, 57	], _
	[41	, 50	], _
	[45	, 53	], _
	[562, 576	], _
	[575, 576	], _
	[48	, 55	], _
	[48	, 59	], _
	[48	, 55	], _
	[283, 53	], _
	[40	, 53	], _
	[283, 53	], _
	[48	, 59	]]

Global Const $__g_a_Bds_PriceId[6][2] = [[Null,Null], _ ; Không nhập
	[Null, Null	], _ 	; Thỏa thuận
	[1, 2	], _ 		; Triệu
	[2, 2	], _ 		; Tỷ
	[6, 6	], _ 		; Trăm nghìn/m2
	[7, 5	]] 			; Triệu/m2

Global Const $__g_a_Bds_Price[6][2] = [[0,0], _ ; Không nhập
	[0, 0		], _ 	; Thỏa thuận
	[1, 1		], _ 	; Triệu
	[1, 1000	], _ 	; Tỷ
	[1, 1		], _ 	; Trăm nghìn/m2
	[1, 1		]] 		; Triệu/m2
	; Ví dụ: Bán 1 triệu thì sẽ là 1|1
	; Ví dụ bán 1 tỷ thì sẽ là 1000|1
	; Bán 1 trăm nghìn/m2 sẽ là 0.1

Global Const $BDS_URL_CREATE_POST = 'https://sellernetapi.batdongsan.com.vn/api/ProductDraft/UpdateProductDraft'
Global Const $BDS_URL_UPDATE_POST = 'https://sellernetapi.batdongsan.com.vn/api/product/saveProduct'
Global Const $BDS_URL_GET_UPLOAD_TOKEN = 'https://sellernetapi.batdongsan.com.vn/api/common/generateUploadToken?folderName=temp'
Global Const $BDS_URL_UPLOAD = 'https://upload2.batdongsan.com.vn/Upload.php'
Global Const $BDS_URL_LOGIN = 'https://batdongsan.com.vn/user-management-service/api/v1/User/Login'
Global Const $BDS_REG_ACCOUNT = $REG_ACCOUNT & $BDS_URL
Global Const $BDS_DATA_CREATE_POST = FileRead($BDS_FOLDER_DATA & 'DATA_CREATE_POST.data')

Func Bds_Header_Update_Post($accessToken)
	Local $header = 'authority: sellernetapi.batdongsan.com.vn'
	$header &= '|path: /api/product/saveProduct'
	$header &= '|scheme: https'
	$header &= '|access-control-allow-credentials: true'
	$header &= '|access-control-allow-headers: Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers'
	$header &= '|access-control-allow-methods: GET,HEAD,OPTIONS,POST,PUT'
	$header &= '|access-control-allow-origin: *'
	$header &= '|apiversion: 2020-02-28 18:30'
	$header &= '|auth: 1'
	$header &= '|authorization: ' & $accessToken
	$header &= '|cache-control: no-cache'
	$header &= '|captcha_token: '
	$header &= '|origin: https://batdongsan.com.vn'
	$header &= '|referer: https://batdongsan.com.vn/'
	$header &= '|uniqueid: deviceidfromweb'
	Return $header
EndFunc

