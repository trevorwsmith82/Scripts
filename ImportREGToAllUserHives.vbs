'==========================================================================
'
' NAME: ImportREGToAllUserHives.vbs
'
' AUTHOR: Brian Gonzalez
' DATE  : 8/21/2013
'
' COMMENT: 
'
'==========================================================================
On Error Resume Next
'Setup Objects and Constants
Const cForReading = 1, cForWriting = 2, cForAppending = 8
sScriptVersion = "08.21.2013"
Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = WScript.CreateObject("WScript.Shell")
Set oNetwork = createobject("Wscript.Network")
Set oReg = GetObject("winmgmts:{impersonationLevel=Impersonate}!\\.\root\default:StdRegProv")
sScriptFolPath = oFSO.GetParentFolderName(Wscript.ScriptFullName) 'No trailing backslash
sLogFilePath = sScriptFolPath & "\ImportREGToAllUserHives.log"

'Main Execution section of script
'==========================================================================
Set oLogFile = oFSO.OpenTextFile(sLogFilePath, cForWriting, True)
oLogFile.WriteLine "ImportREGToAllUserHives script (v" & sScriptVersion & ") has begun on " & Date

Dim sUserHiveFolPath : sUserHiveFolPath = "C:\Users"
For Each oSDir In oFSO.GetFolder(sUserHiveFolPath).SubFolders
	Select Case oSDir.Name
	Case "Administrator", "Public", "Default User", "All Users"
	Case Else
		oShell.Run "%ComSpec% /c reg.exe load HKU\Temp """ & oSDir.Path & "\NTUser.DAT""", 1, True
		oShell.Run "%ComSpec% /c reg.exe import """ & sScriptFolPath & "\Import.REG""", 1, True
		oShell.Run "%ComSpec% /c reg.exe unload HKU\Temp"
	End Select
Next

oLogFile.WriteLine "ImportREGToAllUserHives script has completed."