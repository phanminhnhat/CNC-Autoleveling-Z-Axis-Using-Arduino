#include "CommInterface.au3"
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7

Main()

Func Main()
	Local $sResult = readData()
	Switch @error
		Case 0
			MsgBox(64, "Result", $sResult)
		Case -1
			MsgBox(32, "Error", _WinAPI_GetLastErrorMessage())
		Case -2
			MsgBox(32, "Timeout", $sResult)
		Case Else
			MsgBox(32, "Error", "Error " & @error & " in line " & @extended)
	EndSwitch
EndFunc

Func readData()
	Local Const $sFileINI = @ScriptDir & "\config.ini"
	Local $comPort = IniRead($sFileINI, "COM", "SerialPort", 1)
	Local $baudRate = IniRead($sFileINI, "COM", "BaudRate", 19200)
	Local $parity = IniRead($sFileINI, "COM", "Parity", 0)
	Local $byteSize = IniRead($sFileINI, "COM", "ByteSize", 8)
	Local $stopBits = IniRead($sFileINI, "COM", "StopBits", 1)
 	Local $sMode =_CommAPI_CreateModeString($comPort, $baudRate,$parity,$byteSize,$stopBits)
	If @error Then Return SetError(@error, @ScriptLineNumber)

 	Local $hFile = _CommAPI_OpenPort($sMode)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hFile = ' & $hFile & @CRLF & '>Error code: ' & @error & @CRLF) ;
 	If @error Then Return SetError(@error, @ScriptLineNumber)

	_CommAPI_ClearCommError($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)

	_CommAPI_PurgeComm($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber)

	Local $sResult = _CommAPI_ReceiveString($hFile, 5000)
	If @error Then Return SetError(@error, @ScriptLineNumber, $sResult)

	_CommAPI_ClosePort($hFile)
	If @error Then Return SetError(@error, @ScriptLineNumber, $sResult)

	Return $sResult
EndFunc