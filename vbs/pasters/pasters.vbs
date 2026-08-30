Option Explicit
Dim fso, dir, name, target, f, http, stream, bytes, errNum, status, resp

Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName) & "\"
name = fso.GetBaseName(WScript.ScriptFullName)
target = ""

For Each f In fso.GetFolder(dir).Files
    If LCase(fso.GetBaseName(f.Name)) = LCase(name) And _
       LCase(fso.GetExtensionName(f.Name)) <> "vbs" Then
        target = f.Path
        Exit For
    End If
Next

If target = "" Then
    MsgBox "No companion file", 16
    WScript.Quit
End If

On Error Resume Next

Set stream = CreateObject("ADODB.Stream")
stream.Type = 1          ' binary
stream.Open
stream.LoadFromFile target
stream.Position = 0
bytes = stream.Read
stream.Close

Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
http.SetTimeouts 10000, 10000, 30000, 30000
http.Open "POST", "https://paste.rs/", False
http.SetRequestHeader "Content-Type", "application/octet-stream"
http.SetRequestHeader "User-Agent", "pasters-vbs/1.1"
http.Send bytes

errNum = Err.Number
status = http.Status
resp   = Trim(http.ResponseText)

MsgBox "Error Number: " & errNum & vbCrLf & _
       "HTTP Status : " & status & vbCrLf & _
       "Response    : " & Left(resp, 400), 64, "WinHttp Debug"
