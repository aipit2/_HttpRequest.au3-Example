#include <Date.au3>
Func AddDate($dateAdd,$type = "dd/mm/yyyy")
	Local $split = StringRegExp($type,"\w+(.)\w+",1)[0]
	Local $today = StringReplace($type,"dd",@MDAY)
	Local $today2 = StringReplace($today,"mm",@MON)
	Local $today3 = StringReplace($today2,"yyyy",@YEAR)
	Local $dateAdd3 = _DateAdd("D",$dateAdd,_NowCalcDate())
	Local $arrayDateEnd = StringSplit($dateAdd3,"/",2)
	Local $dateEnd = StringReplace($type,"dd",$arrayDateEnd[2])
	Local $dateEnd2 = StringReplace($dateEnd,"mm",$arrayDateEnd[1])
	Local $dateEnd3 = StringReplace($dateEnd2,"yyyy",$arrayDateEnd[0])
	Local $result = [$today3,$dateEnd3]
	Return $result
EndFunc