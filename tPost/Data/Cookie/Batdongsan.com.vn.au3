#include <../../Include/UDF/_HttpRequest/_HttpRequest.au3>
_HttpRequest_CookieJarSet("Cookie.data")
Bds_Login()
Func Bds_Login()
	Local $rq = _HttpRequest(2,"https://batdongsan.com.vn/HandlerWeb/UserHandler.ashx?type=getuserid")
	_HttpRequest_Test($rq)
EndFunc