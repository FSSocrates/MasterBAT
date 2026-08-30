Option Explicit

' pasters.vbs – upload companion file to paste.rs and copy the URL
' Place this .vbs next to a file that has the same base name (any other extension).

Dim fso, shell, dir, baseName, target, f, http, stream, bytes
Dim status, url, errNum

Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

dir      = fso.GetParentFolderName(WScript.ScriptFullName) & "\"
baseName = fso.GetBaseName(WScript.ScriptFullName)
target   = ""

' Find the companion file (same base name, different extension)
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
    MsgBox "Could not find a companion file named """ & baseName & ".*""", _
           16, "pasters"
    WScript.Quit 1
End If

On Error Resume Next

' Read file as binary
Set stream = CreateObject("ADODB.Stream")
stream.Type = 1          ' adTypeBinary
stream.Open
stream.LoadFromFile target
stream.Position = 0
bytes = stream.Read
stream.Close
Set stream = Nothing

If Err.Number <> 0 Or IsEmpty(bytes) Then
    MsgBox "Failed to read file:" & vbCrLf & target & vbCrLf & vbCrLf & Err.Description, _
           16, "pasters"
    WScript.Quit 1
End If

' Upload
Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
http.SetTimeouts 15000, 15000, 60000, 60000
http.Open "POST", "https://paste.rs/", False
http.SetRequestHeader "Content-Type", "application/octet-stream"
http.SetRequestHeader "User-Agent", "pasters-vbs/2.0"
http.Send bytes

errNum = Err.Number
status = 0
url    = ""

If errNum = 0 Then
    status = http.Status
    url    = Trim(http.ResponseText)
End If

Set http = Nothing
On Error GoTo 0

' Evaluate result
If errNum <> 0 Then
    MsgBox "Network / client error (" & errNum & ")", 16, "pasters"
    WScript.Quit 1
End If

If status = 201 And LCase(Left(url, 4)) = "http" Then
    ' Success – copy URL to clipboard
    shell.Run "cmd.exe /c echo|set /p=""" & url & """|clip", 0, True
    MsgBox "Upload successful." & vbCrLf & vbCrLf & url, 64, "pasters"
    WScript.Quit 0
End If

' Server-side problems (current paste.rs behaviour for larger pastes)
If status = 500 Or status = 503 Then
    MsgBox "paste.rs returned " & status & " (server error / overloaded)." & vbCrLf & _
           "This is currently common for pastes larger than a few KB." & vbCrLf & vbCrLf & _
           "Try again later or use a smaller file.", 48, "pasters"
    WScript.Quit 1
End If

' Any other failure
MsgBox "Upload failed." & vbCrLf & _
       "HTTP status: " & status & vbCrLf & _
       "Response: " & Left(url, 200), 16, "pasters"
WScript.Quit 1
