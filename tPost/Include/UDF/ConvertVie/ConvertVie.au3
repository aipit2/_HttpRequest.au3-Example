Func ConvertVie($text)
	Local $txt = StringLower($text)
	$txt = StringRegExpReplace($txt,"à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ","a")
	$txt = StringRegExpReplace($txt,"è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ","e")
	$txt = StringRegExpReplace($txt,"ì|í|ị|ỉ|ĩ","i")
	$txt = StringRegExpReplace($txt,"ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ","o")
	$txt = StringRegExpReplace($txt,"ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ","u")
	$txt = StringRegExpReplace($txt,"ỳ|ý|ỵ|ỷ|ỹ","y")
	$txt = StringRegExpReplace($txt,"đ","d")
	return $txt
EndFunc