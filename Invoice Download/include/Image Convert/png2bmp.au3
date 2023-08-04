#include <GDIPlus.au3>

Func png2bmp($pngFile,$bmpFile)
	_GDIPlus_StartUp()
	Local $hImage = _GDIPlus_ImageLoadFromFile($pngFile)
	Local $sCLSID = _GDIPlus_EncodersGetCLSID("bmp")
	_GDIPlus_ImageSaveToFileEx($hImage, $bmpFile, $sCLSID)
	FileDelete($pngFile)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_ShutDown()
EndFunc