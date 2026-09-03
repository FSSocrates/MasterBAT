Option Explicit

Const SERVER = "https://paste.rs/"

Dim fso, shell, dir, baseName, target, f
Dim http, stream, bytes, status, url, errNum

Set fso = CreateObject("Scripting.FileSystemObject")

dir      = fso.GetParentFolderName(WScript.ScriptFullName) & "\"
baseName = fso.GetBaseName(WScript.ScriptFullName)
target   = ""

If fso.FolderExists(dir) Then
    For Each f In fso.GetFolder(dir).Files
        If LCase(fso.GetBaseName(f.Name)) = LCase(baseName) Then
            If LCase(fso.GetExtensionName(f.Name)) <> "vbs" Then
                target = f.Path
                Exit For
            End If
        End If
    Next
End If

If target = "" Then
    MsgBox "Could not find companion file named """ & baseName & ".*""", 16, "RawBin"
    WScript.Quit 1
End If

On Error Resume Next

Set stream = CreateObject("ADODB.Stream")
stream.Type = 1
stream.Open
stream.LoadFromFile target
stream.Position = 0
bytes = stream.Read
stream.Close
Set stream = Nothing

If Err.Number <> 0 Or IsEmpty(bytes) Then
    MsgBox "Failed to read file:" & vbCrLf & target, 16, "RawBin"
    WScript.Quit 1
End If

Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
http.SetTimeouts 15000, 15000, 60000, 60000
http.Open "POST", SERVER, False
http.SetRequestHeader "Content-Type", "text/plain"
http.SetRequestHeader "User-Agent", "RawBin-vbs/2.3"
http.Send bytes

errNum = Err.Number
status = 0
url    = ""

If errNum = 0 Then
    status = http.Status
    url    = Trim(http.ResponseText)
End If

Set http = Nothing

If errNum <> 0 Then
    MsgBox "Network error (" & errNum & ")", 16, "RawBin"
    WScript.Quit 1
End If

If (status = 200 Or status = 201) And LCase(Left(url, 4)) = "http" Then
    Set shell = CreateObject("WScript.Shell")
    ' 0 hides the window completely, True waits for execution
    shell.Run "powershell.exe -NoProfile -Command ""Set-Clipboard -Value '" & url & "'""", 0, True
    
    If Err.Number <> 0 Then
        Err.Clear
        shell.Run "cmd.exe /c <nul set /p=""" & url & """ | clip", 0, True
    End If
    
    MsgBox "Upload successful." & vbCrLf & vbCrLf & url, 64, "RawBin"
    On Error GoTo 0
    WScript.Quit 0
End If

On Error GoTo 0
MsgBox "Upload failed." & vbCrLf & "HTTP status: " & status & vbCrLf & "Response: " & Left(url, 300), 16, "RawBin"
WScript.Quit 1
