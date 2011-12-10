#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>

DirCreate(@TempDir & '\LauncherAoS')
FileInstall('images/fond.png', @TempDir & '\LauncherAoS\fond.png', 1)
$pngFile = @TempDir & '\LauncherAoS\fond.png'
InetGet("http://aurel2108.tonbnc.fr/launcheraos/serverlist.php", @TempDir & '\LauncherAoS\serverlist.txt', 1)

$serverlist = FileOpen(@TempDir & '\LauncherAoS\serverlist.txt')

$Form1 = GUICreate("LauncherAoS", 855, 481)
 _GDIPlus_Startup()
$hBitmap = _GDIPlus_ImageLoadFromFile($pngFile)
$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($Form1)
$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics(855, 481, $hGraphicGUI)
$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff)
_GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)
GUIRegisterMsg(0xF, "MY_PAINT"); Register PAINT-Event 0x000F = $WM_PAINT (WindowsConstants.au3)
GUIRegisterMsg(0x85, "MY_PAINT") ; $WM_NCPAINT = 0x0085 (WindowsConstants.au3)Restore after Minimize.
_GDIPlus_GraphicsDrawImage($hGraphicGUI, $hBMPBuff, 0, 0)
GUISetIcon('Icone.ico')
GUISetState()
$Button1 = GUICtrlCreateButton("Options", 568, 424, 75, 25)
$Button2 = GUICtrlCreateButton("Play", 696, 424, 75, 25)
$listview = GUICtrlCreateListView("Status|Players|Ping|Country|Name                        ", 24, 8, 593, 370)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

$servers = _StringExplode(FileReadLine($serverlist), '---|||---')
Local $serversitems[UBound($servers)]
For $i = 0 To UBound($servers) - 1
	$server = _StringExplode($servers[$i], '-|-')
	if $server[0] == $server[1] Then
		$status = 'Full'
	elseif $server[0] == '0' Then
		$status = 'Empty'
	else
		$status = 'Normal'
	EndIf
	$serversitems[$i] = GUICtrlCreateListViewItem($status & '|' & $server[0] & '/' & $server[1] & '|' & $server[2] & '|' & $server[3] & '|' & $server[5], $listview)
Next

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			Options()
		Case $Button2
			Play()
	EndSwitch
WEnd

Func Options()

EndFunc

Func Play()

EndFunc

_GDIPlus_GraphicsDispose($hGraphicGUI)
_GDIPlus_GraphicsDispose($hGraphic)
_GDIPlus_BitmapDispose($hBitmap)
_GDIPlus_BitmapDispose($hBMPBuff)
_GDIPlus_Shutdown()

Func MY_PAINT($hWnd, $msg, $wParam, $lParam)
	_GDIPlus_GraphicsDrawImage($hGraphicGUI, $hBMPBuff, 0, 0)
	_WinAPI_RedrawWindow($Form1, "", "", BitOR($RDW_INVALIDATE, $RDW_FRAME, $RDW_ALLCHILDREN)) ;
	Return $GUI_RUNDEFMSG
EndFunc ;==>MY_PAINT