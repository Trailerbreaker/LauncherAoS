#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icone.ico
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <SliderConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>

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

Local $OptionsButton[4] = [569, 417, 688, 452]
Local $PlayButton[4] = [715, 417, 834, 452]
Local $RefreshButton[4] = [682, 47, 801, 82]
Local $ServerListButton[4] = [23, 348, 215, 379]
Local $FavoritesButton[4] = [228, 348, 420, 379]
Local $AddToFavoritesButton[4] = [432, 348, 625, 378]

$listview = GUICtrlCreateListView("Status|Players|Ping|Country|Name                               ", 24, 8, 593, 330)
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
				$server = _StringExplode($servers[GUICtrlRead($listview)], '-|-')
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
	If FileExists(@HomeDrive & '\Ace of Spades\config.ini') Then
		$iniFile = @HomeDrive & '\Ace of Spades\config.ini'
	Else
		$emplacement = FileSelectFolder("Choose your Ace of Spades folder", "")
		If @error Then
		Else
			If FileExists($emplacement & '\config.ini') Then
				$iniFile = $emplacement & '\config.ini'
			EndIf
		EndIf
	EndIf

	$OptionsWin = GUICreate("Options", 251, 275, 475, 250)
	$NameLabel = GUICtrlCreateLabel("Name :", 24, 16, 38, 17)
	$NameInput = GUICtrlCreateInput(IniRead($iniFile, "client", "name", "Deuce"), 72, 13, 161, 21)
	$ResolutionLabel = GUICtrlCreateLabel("Resolution :", 24, 48, 60, 17)
	$VolumeLabel = GUICtrlCreateLabel("Volume :", 24, 80, 45, 17)
	$VolumeSlider = GUICtrlCreateSlider(72, 72, 158, 29)
	GUICtrlSetData(-1, IniRead($iniFile, "client", "vol", "10"))
	GUICtrlSetLimit(-1, 10, 0)
	$ResolutionCombo = GUICtrlCreateCombo("", 88, 45, 145, 25)
	GUICtrlSetData($ResolutionCombo, "640x480|800x600|1024x768|1152x864|1280x600|1280x720|1280x768|1280x800|1280x854|1280x960|1280x1024|1360x768|1440x900|1600x900|1600x1200|1680x1050", IniRead($iniFile, "client", "xres", "800") & "x" & IniRead($iniFile, "client", "yres", "600"))
	$InvertMouse = GUICtrlCreateCheckbox("Invert Mouse", 24, 112, 201, 17)
	If IniRead($iniFile, "client", "inverty", "0") == "1" Then GUICtrlSetState(-1, $GUI_CHECKED)
	$Windowed = GUICtrlCreateCheckbox("Windowed Mode", 24, 141, 201, 17)
	If IniRead($iniFile, "client", "windowed", "0") == "1" Then GUICtrlSetState(-1, $GUI_CHECKED)
	$LanguageLabel = GUICtrlCreateLabel("Language :", 24, 168, 58, 17)
	$LanguageCombo = GUICtrlCreateCombo("", 88, 164, 145, 25)
	Local $LangArray[6] = ['English', 'Deutsch', 'Français', 'Español', 'Português', 'Italiano']
	GUICtrlSetData($LanguageCombo, "English|Deutsch|Français|Español|Português|Italiano", $LangArray[IniRead($iniFile, "client", "language", "0")])
	$MouseSensitivityLabel = GUICtrlCreateLabel("Mouse Sensitivity :", 24, 200, 92, 17)
	$MouseSensitivitySlider = GUICtrlCreateSlider(112, 194, 118, 29)
	GUICtrlSetData(-1, IniRead($iniFile, "client", "mouse_sensitivity", "5"))
	GUICtrlSetLimit(-1, 10, 0)
	$OKButton = GUICtrlCreateButton("OK", 24, 232, 207, 38)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $OKButton
				IniWrite($iniFile, "client", "name", GUICtrlRead($NameInput))
				$resolution = _StringExplode(GUICtrlRead($ResolutionCombo), "x")
				IniWrite($iniFile, "client", "xres", $resolution[0])
				IniWrite($iniFile, "client", "yres", $resolution[1])
				IniWrite($iniFile, "client", "vol", GUICtrlRead($VolumeSlider))
				If GUICtrlRead($InvertMouse) == $GUI_CHECKED Then
					IniWrite($iniFile, "client", "inverty", "1")
				Else
					IniWrite($iniFile, "client", "inverty", "0")
				EndIf
				If GUICtrlRead($Windowed) == $GUI_CHECKED Then
					IniWrite($iniFile, "client", "windowed", "1")
				Else
					IniWrite($iniFile, "client", "windowed", "0")
				EndIf
				If GUICtrlRead($LanguageCombo) == "English" Then
					IniWrite($iniFile, "client", "language", "0")
				ElseIf GUICtrlRead($LanguageCombo) == "Deutsch" Then
					IniWrite($iniFile, "client", "language", "1")
				ElseIf GUICtrlRead($LanguageCombo) == "Français" Then
					IniWrite($iniFile, "client", "language", "2")
				ElseIf GUICtrlRead($LanguageCombo) == "Español" Then
					IniWrite($iniFile, "client", "language", "3")
				ElseIf GUICtrlRead($LanguageCombo) == "Português" Then
					IniWrite($iniFile, "client", "language", "4")
				Else
					IniWrite($iniFile, "client", "language", "5")
				EndIf
				IniWrite($iniFile, "client", "mouse_sensitivity", GUICtrlRead($MouseSensitivitySlider))
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete($OptionsWin)
EndFunc   ;==>Options

Func ServerList()

EndFunc   ;==>ServerList

Func Favorites()

EndFunc   ;==>Favorites

Func AddToFavorites($server)

EndFunc   ;==>AddToFavorites

Func Play($server)
	If FileExists(@HomeDrive & '\Ace of Spades\client.exe') Then
		;ShellExecute(@HomeDrive & '\Ace of Spades\client.exe', '//' . $server)
		Run(@HomeDrive & '\Ace of Spades\client.exe ' & $server)
	Else
		$emplacement = FileSelectFolder("Choo23 your Ace of Spades folder", "")
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
