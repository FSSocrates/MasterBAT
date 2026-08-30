Option Explicit
Dim fso, shell, dir, name, target, f, ext, exec, url
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
dir = fso.GetParentFolderName(WScript.ScriptFullName) & "\"
name = fso.GetBaseName(WScript.ScriptFullName)
target = ""
If fso.FolderExists(dir) Then
    For Each f In fso.GetFolder(dir).Files
        If LCase(fso.GetBaseName(f.Name)) = LCase(name) Then
            ext = LCase(fso.GetExtensionName(f.Name))
            If ext <> "vbs" Then
                target = f.Path
                Exit For
            End If
        End If
    Next
End If
If target = "" Then
    MsgBox "Upload Failed: Could not find a companion data file named " & name & ".*", 16, "Paste.rs VB Script"
    WScript.Quit
End If
Set exec = shell.Exec("curl --data-binary @""" & target & """ https://paste.rs/")
url = ""
Do While Not exec.StdOut.AtEndOfStream
    url = Trim(exec.StdOut.ReadLine)
Loop
If exec.ExitCode <> 0 Or Left(LCase(url), 4) <> "http" Then
    MsgBox "Upload Failed: Server returned an invalid response or a network error occurred.", 16, "Paste.rs VB Script"
    WScript.Quit
End If
shell.Run "cmd.exe /c echo | set /p=""" & url & """ | clip", 0, True
MsgBox "Upload Successful: The raw data link has been copied to your clipboard.", 64, "Paste.rs VB Script"
