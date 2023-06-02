Global Const $DOTHI_REGEX_GET_NAME = 'Text":"(.*?)"'
Global Const $DOTHI_REGEX_GET_ID = 'Id":"(.*?)"'
Global Const $DOTHI_URL = "Dothi.net"
Global Const $REG_ACCOUNT_DOTHI = $REG_ACCOUNT & $DOTHI_URL
Global Const $__g_a_Dothi_Price = [[0,0], _ ; Không nhập
	[0,0], _ 	; Thỏa thuận
	[1,1], _ 	; Triệu
	[1,1000], _ ; Tỷ
	[1,1], _ 	; Trăm nghìn/m2
	[1,1]]		; Triệu/m2

Global Const $__g_a_Dothi_PriceId = [[0,0], _ ; Không nhập
	[0,0], _ 	; Thỏa thuận
	[1,2], _ 	; Triệu
	[2,2], _ 	; Tỷ
	[6,6], _ 	; Trăm nghìn/m2
	[7,5]] 		; Triệu/m2

Global Const $__g_a_Dothi_VipId = [5,5,2,1,0]

Global Const $__g_a_Dothi_PostTypeId = [0,38,49]

Global Const $__g_a_Dothi_EstateTypeId = [[-1,-1,-1], _
	[-1,163	,51	], _
	[-1,41	,52	], _
	[-1,325	,52	], _
	[-1,324	,326], _
	[-1,48	,57	], _
	[-1,48	,50	], _
	[-1,45	,53	], _
	[-1,48	,59	], _
	[-1,48	,55	], _
	[-1,48	,55	], _
	[-1,44	,59	], _
	[-1,48	,59	], _
	[-1,283	,53	], _
	[-1,40	,53	], _
	[-1,283	,53	], _
	[-1,48	,59	]]

Global Const $DOTHI_URL_POSTING = 'https://dothi.net/thanh-vien/dang-tin-ban-cho-thue-nha-dat.htm'
