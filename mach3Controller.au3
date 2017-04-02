; #INDEX# =======================================================================================================================
; Name ..........: mach3Controller.au3
; Title .........: Control MACH3 CNC via arduino
; Description ...: Using Arduino to get CNC status then send the control to MACH3.
; Version Date ..: 2016-13-10
; AutoIt Version : 3.3.14.2
; Link ..........: N/A
; Tag(s) ........: CNC, Arduino, COM port, Zero tool set, remote control
; Author(s) .....: Nhat Phan
; Dll(s) ........: kernel32.dll
; Error handling : Everytime @extended is set, it is filled with @ScriptLineNumber of the error.
; ===============================================================================================================================

#include "CommInterface.au3"

;~ '   *******************************************************************************************
;~ '**  Desc: Activate app.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 13-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
Func activateApp($appName)
    ; Run Mach3
    ;Run("Mach3.exe")

    ; Wait 10 seconds for the Notepad window to appear.
    Global $hWnd = WinWait("[TITLE:"&$appName&"]", "", 1)

    ; Activate the app window using the handle returned by WinWait.
    WinActivate($hWnd)

    ; Close the Notepad window using the handle returned by WinWait.
    ;WinClose($hWnd)
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Activate app.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 13-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
Func getAppSize()
	Local $aClientSize = WinGetClientSize($hWnd)
	ConsoleWrite("Pos Size x:" & $aClientSize[0]& @CRLF)
	ConsoleWrite("Pos Size y:" & $aClientSize[1]& @CRLF)
	Return $aClientSize
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Setup com port from ini file.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 14-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
	;Setting up com port
Func setUpComPort()
	Local Const $sFileINI = @ScriptDir & "\config.ini"
	Local $comPort = IniRead($sFileINI, "COM", "SerialPort", 1)
	Local $baudRate = IniRead($sFileINI, "COM", "BaudRate", 19200)
	Local $parity = IniRead($sFileINI, "COM", "Parity", 0)
	Local $byteSize = IniRead($sFileINI, "COM", "ByteSize", 8)
	Local $stopBits = IniRead($sFileINI, "COM", "StopBits", 1)
 	Local $sMode =_CommAPI_CreateModeString($comPort, $baudRate,$parity,$byteSize,$stopBits)
	If @error Then Return SetError(@error, @ScriptLineNumber)
	Return $sMode
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Open Comm port.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 14-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
	;Setting up com port
Func openComPort($sMode)
 	Local $hFile = _CommAPI_OpenPort($sMode)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hFile = ' & $hFile & @CRLF & '>Error code: ' & @error & @CRLF) ;
 	If @error Then Return SetError(@error, @ScriptLineNumber)

	_CommAPI_ClearCommError($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)

	_CommAPI_PurgeComm($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)

	Return $hFile
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Receive data from com port.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 14-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
	;Setting up com port
Func receiveDataComPort($hFile, $timeout)
	Local $sResult = _CommAPI_ReceiveString($hFile, $timeout)
	If @error Then Return SetError(@error, @ScriptLineNumber, $sResult)

	; clear error
	_CommAPI_ClearCommError($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)

	;clear cache
	_CommAPI_PurgeComm($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)

	Return $sResult
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Close com port.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 14-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
	;Setting up com port
Func closeComPort($hFile)
	_CommAPI_ClosePort($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)
	Return 0
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Check for Error.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 14-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
Func checkCommError()
	Switch @error
		Case 0
			;MsgBox(64, "Result", $sResult)
		Case -1
			MsgBox(32, "Error", _WinAPI_GetLastErrorMessage())
		Case -2
			MsgBox(32, "Timeout", "TimeOut")
		Case Else
			MsgBox(32, "Error", "Error " & @error & " in line " & @extended)
	EndSwitch
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: Handle unexpected issue.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 14-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
Func unexpectedErrrorHandling($appName)
	Send("{PGDN down}") ;Press and hold page down key button
	ControlClick($appName, "", "[CLASS:AfxWnd70s; INSTANCE:475]") ;Click Reset button
EndFunc

;~ '   *******************************************************************************************
;~ '**  Desc: This is auto zero Z functions.
;~ '**  Created By: Nhat Phan
;~ '**  Created Date: 13-10-2016
;~ '**  Modification History:
;~ '**         Modify by:                Date:                    Note:
;~ '**************************************************************************************************
Func autoZeroZAxis()
	Local $appName= "Mach3 CNC"
	;Comm port preparation
	Local $sMode = setUpComPort()
	if @error <> 0 Then
		unexpectedErrrorHandling($appName)
	EndIf
	checkCommError()
	Local $hFile = openComPort($sMode)
	if @error <> 0 Then
		unexpectedErrrorHandling($appName)
	EndIf
	checkCommError()
	;Controlling MACH3 CNC
	activateApp($appName)
	;ControlClick($appName, "", "[CLASS:AfxWnd70s; INSTANCE:475]") ;Click Reset button
	;Sleep (1000)
	Send("{TAB}");Press tab to open controller
	;Sleep (1000)
	ControlClick($appName, "", "[CLASS:AfxWnd70s; INSTANCE:810]") ;Click Slow Jog Rate  to Edit
	Sleep (500)
	Send("5");Input value 5%
	Send("{ENTER}")
	Sleep(500)
	Send("{TAB}");Press tab to close controller
	Send("{PGDN down}") ;Press and hold page down key button
	;Detect if the serial port is sending command to stop or not. If yes, break
	While Not(StringInStr (receiveDataComPort($hFile,100),"Z0"))
		if @error <> 0 Then
			unexpectedErrrorHandling($appName)
			checkCommError()
			Break
		EndIf
	WEnd
	Send("{PGDN up}") ;Unhold page down key button
	;Press Emergency stop
	closeComPort($hFile)
	checkCommError()
	Sleep(500)
	;Set  Zero
	Local $aClientSize = getAppSize()
	Local Const $appWidth=1366
	Local Const $appHeight=685
	ConsoleWrite("Mouse Click" & @CRLF)
	MouseClick ("",787*$aClientSize[0]/$appWidth, 195*$aClientSize[1]/$appHeight , 1, 10 )
	Sleep(200)
	Send("0");Input delta Z if need be
	ConsoleWrite("ENTER" & @CRLF)
	Send("{ENTER}")
	;Page up
	ConsoleWrite("MOVE UP" & @CRLF)
	Send("{PGUP down}") ;Move the bit up 3s
	Sleep(3000)
	Send("{PGUP up}") ;Stop CNC

EndFunc   ;==>Main_Form


;========================================================================================================================================================
; Call Main_Form

autoZeroZAxis()