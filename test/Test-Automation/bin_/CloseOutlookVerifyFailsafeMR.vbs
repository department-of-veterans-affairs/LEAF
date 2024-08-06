delay = 3000 'delay in milliseconds to let Outlook close gracefully
strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

'If Outlook is running, let it quit on its own.
For Each Process in objWMIService.InstancesOf("Win32_Process")
  If StrComp(Process.Name,"OUTLOOK.EXE",vbTextCompare) = 0 Then
    Set objOutlook = CreateObject("Outlook.Application")
    objOutlook.Quit
    WScript.Sleep delay
    Exit For
  End If
Next

'Make sure Outlook is closed and otherwise force it.
Set colProcessList = objWMIService.ExecQuery _
("Select * from Win32_Process Where Name = 'Outlook.exe'")
For Each objProcess in colProcessList
  objProcess.Terminate()
Next
Set objWMIService = Nothing
Set objOutlook = Nothing
Set colProcessList = Nothing