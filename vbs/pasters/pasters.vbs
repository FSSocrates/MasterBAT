Option Explicit
Dim fso, shell, dir, name, target, f, ext, http, stream, url
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
On Error Resume Next
Set stream = CreateObject("ADODB.Stream")
stream.Type = 1: stream.Open: stream.LoadFromFile target
Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
http.Open "POST", "https://paste.rs/", False
http.Send stream
url = Trim(http.responseText)
stream.Close
If Err.Number <> 0 Or http.Status <> 201 Or Left(LCase(url), 4) <> "http" Then
    MsgBox "Upload Failed: Network error, timeout, or server rejected request.", 16, "Paste.rs VB Script"
    WScript.Quit
End If
On Error GoTo 0
shell.Run "cmd.exe /c echo | set /p=""" & url & """ | clip", 0, True
MsgBox "Upload Successful: The raw data link has been copied to your clipboard.", 64, "Paste.rs VB Script"
