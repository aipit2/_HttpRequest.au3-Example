Global Const $MUABAN_URL = 'Muaban.net'
Global Const $MUABAN_FOLDER_DATA = @ScriptDir & '\Data\' & $MUABAN_URL & '\'
Global Const $MUABAN_ARRAY_CITY_ID = FileReadToArray($MUABAN_FOLDER_DATA & "ARRAY_CITY_ID.data")
Global Const $MUABAN_REGEX_GET_NAME = '"name":"(.*?)"'
Global Const $MUABAN_REGEX_GET_ID = '"id":(\d+)'
Global Const $MUABAN_REG_ACCOUNT = $REG_ACCOUNT & $MUABAN_URL
Global Const $MUABAN_ARRAY_PRICE = [0,0,10^6,10^9,10^5,10^6]
Global Const $MUABAN_HEADER_UPLOAD = StringReplace(FileRead($MUABAN_FOLDER_DATA & 'HEADER_UPLOAD.data'),@CRLF,"|")
Local $dataPosting = FileRead($MUABAN_FOLDER_DATA & 'JSON_DATA_POSTING.data')
Global Const $MUABAN_JSON_DATA_POSTING = _HttpRequest_ParseJSON($dataPosting)
Local $arrayProperty[0]
_FileReadToArray($MUABAN_FOLDER_DATA & 'ARRAY_PROPERTY.data',$arrayProperty,0,@TAB)
Global Const $MUABAN_ARRAY_PROPERTY = $arrayProperty
Local $dataEstate = FileRead($MUABAN_FOLDER_DATA & 'JSON_DATA_ESTATE.data')
Global Const $MUABAN_JSON_DATA_ESTATE = _HttpRequest_ParseJSON($dataEstate)
Local $dataAddress = FileRead($MUABAN_FOLDER_DATA & 'JSON_DATA_ADDRESS.data')
Global Const $MUABAN_JSON_DATA_ADDRESS = _HttpRequest_ParseJSON($dataAddress) ; Phải include dưới _HttpRequest.au3
