Option Explicit

' pasters.vbs – upload companion file to a public paste host
' Put this .vbs next to a file with the same base name (any other extension).

Const SERVER = "https://paste.c-net.org/"

Dim fso, shell, dir, baseName, target, f
Dim http, stream, bytes, status, url, errNum

Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

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
    MsgBox "Could not find companion file named """ & baseName & ".*""", 16, "RawText"
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
    MsgBox "Failed to read file:" & vbCrLf & target, 16, "RawText"
    WScript.Quit 1
End If

Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
http.SetTimeouts 15000, 15000, 60000, 60000
http.Open "POST", SERVER, False
http.SetRequestHeader "Content-Type", "application/octet-stream"
http.SetRequestHeader "User-Agent", "RawText-vbs/2.2"
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

If errNum <> 0 Then
    MsgBox "Network error (" & errNum & ")", 16, "RawText"
    WScript.Quit 1
End If

' paste.c-net.org returns 200 + URL; some hosts return 201
If (status = 200 Or status = 201) And LCase(Left(url, 4)) = "http" Then
    shell.Run "cmd.exe /c echo|set /p=""" & url & """|clip", 0, True
    MsgBox "Upload successful." & vbCrLf & vbCrLf & url, 64, "RawText"
    WScript.Quit 0
End If

MsgBox "Upload failed." & vbCrLf & _
       "HTTP status: " & status & vbCrLf & _
       "Response: " & Left(url, 300), 16, "RawText"
WScript.Quit 1
