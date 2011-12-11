#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icone.ico
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>

Opt("TrayIconHide", 1)

DirCreate(@TempDir & '\LauncherAoS')
FileInstall('images/background.png', @TempDir & '\LauncherAoS\fond.png', 1)
$pngFile = @TempDir & '\LauncherAoS\fond.png'

InetGet("http://aurel2108.tonbnc.fr/launcheraos/serverlist.php", @TempDir & '\LauncherAoS\serverlist.txt', 1)

$serverlist = FileOpen(@TempDir & '\LauncherAoS\serverlist.txt')

$LauncherWin = GUICreate("LauncherAoS", 855, 481)
_GDIPlus_Startup()
$hBitmap = _GDIPlus_ImageLoadFromFile($pngFile)
$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($LauncherWin)
$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics(855, 481, $hGraphicGUI)
$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff)
_GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)
GUIRegisterMsg(0xF, "MY_PAINT"); Register PAINT-Event 0x000F = $WM_PAINT (WindowsConstants.au3)
GUIRegisterMsg(0x85, "MY_PAINT") ; $WM_NCPAINT = 0x0085 (WindowsConstants.au3)Restore after Minimize.
_GDIPlus_GraphicsDrawImage($hGraphicGUI, $hBMPBuff, 0, 0)
GUISetIcon('Icone.ico')
GUISetState()

Local $OptionsButton[4] = [581, 417, 581 + 119, 417 + 35]
Local $PlayButton[4] = [709, 417, 709 + 119, 417 + 35]
Local $RefreshButton[4] = [662, 57, 662 + 119, 57 + 35]

$listview = GUICtrlCreateListView("Status|Players|Ping|Country|Name                        ", 24, 8, 593, 370)
GUISetState(@SW_SHOW)
#endregion ### END Koda GUI section ###

$servers = _StringExplode(FileReadLine($serverlist), '---|||---')
Local $serversitems[UBound($servers)]
For $i = 0 To UBound($servers) - 1
	$server = _StringExplode($servers[$i], '-|-')
	If $server[0] == $server[1] Then
		$status = 'Full'
	ElseIf $server[0] == '0' Then
		$status = 'Empty'
	Else
		$status = 'Normal'
	EndIf
	$serversitems[$i] = GUICtrlCreateListViewItem($status & '|' & $server[0] & '/' & $server[1] & '|' & $server[2] & '|' & $server[3] & '|' & $server[5], $listview)
Next

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
	$cursorInfo = GUIGetCursorInfo()
	If IsArray($cursorInfo) And $cursorInfo[2] == 1 Then
		If ImgButton($cursorInfo[0], $cursorInfo[1], $OptionsButton[0], $OptionsButton[1], $OptionsButton[2], $OptionsButton[3]) Then
			Options()
		ElseIf ImgButton($cursorInfo[0], $cursorInfo[1], $PlayButton[0], $PlayButton[1], $PlayButton[2], $PlayButton[3]) Then
			If GUICtrlRead($listview) == 0 Then
				MsgBox(0, "Error", "You have not selected any server.")
			Else
				$server = _StringExplode($servers[GUICtrlRead($listview) - 7], '-|-')
				Play($server[4])
			EndIf
		ElseIf ImgButton($cursorInfo[0], $cursorInfo[1], $RefreshButton[0], $RefreshButton[1], $RefreshButton[2], $RefreshButton[3]) Then
			Refresh()
		EndIf
	EndIf
WEnd

Func Refresh()
	InetGet("http://aurel2108.tonbnc.fr/launcheraos/serverlist.php", @TempDir & '\LauncherAoS\serverlist.txt', 1)
	$serverlist = FileOpen(@TempDir & '\LauncherAoS\serverlist.txt')
	$servers = _StringExplode(FileReadLine($serverlist), '---|||---')
	For $i = 0 To UBound($serversitems) - 1
		GUICtrlDelete($serversitems[$i])
	Next
	Global $serversitems[UBound($servers)]
	For $i = 0 To UBound($servers) - 1
		$server = _StringExplode($servers[$i], '-|-')
		If $server[0] == $server[1] Then
			$status = 'Full'
		ElseIf $server[0] == '0' Then
			$status = 'Empty'
		Else
			$status = 'Normal'
		EndIf
		$serversitems[$i] = GUICtrlCreateListViewItem($status & '|' & $server[0] & '/' & $server[1] & '|' & $server[2] & '|' & $server[3] & '|' & $server[5], $listview)
	Next
EndFunc   ;==>Refresh

Func Options()

EndFunc   ;==>Options

Func Play($server)
	If FileExists(@HomeDrive & '\Ace of Spades\client.exe') Then
		;ShellExecute(@HomeDrive & '\Ace of Spades\client.exe', '//' . $server)
		Run(@HomeDrive & '\Ace of Spades\client.exe ' & $server)
	Else
		$emplacement = FileSelectFolder("Choose your Ace of Spades folder", "")
		If @error Then
		Else
			If FileExists($emplacement & '\client.exe') Then
				Run($emplacement & '\client.exe ' & $server)
			EndIf
		EndIf
	EndIf
	ConsoleWrite('Play : ' & $server & @CRLF)
EndFunc   ;==>Play

_GDIPlus_GraphicsDispose($hGraphicGUI)
_GDIPlus_GraphicsDispose($hGraphic)
_GDIPlus_BitmapDispose($hBitmap)
_GDIPlus_BitmapDispose($hBMPBuff)
_GDIPlus_Shutdown()

Func MY_PAINT($hWnd, $msg, $wParam, $lParam)
	_GDIPlus_GraphicsDrawImage($hGraphicGUI, $hBMPBuff, 0, 0)
	_WinAPI_RedrawWindow($LauncherWin, "", "", BitOR($RDW_INVALIDATE, $RDW_FRAME, $RDW_ALLCHILDREN)) ;
	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_PAINT

Func ImgButton($sourisX, $sourisY, $boutonX1, $boutonY1, $boutonX2, $boutonY2)
	If $sourisX >= $boutonX1 And $sourisX <= $boutonX2 And $sourisY >= $boutonY1 And $sourisY <= $boutonY2 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>ImgButton
