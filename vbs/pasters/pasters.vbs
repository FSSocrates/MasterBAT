Option Explicit
Dim fso, dir, name, target, f, ext, http, stream, errNum, status, resp

Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName) & "\"
name = fso.GetBaseName(WScript.ScriptFullName)
target = ""

For Each f In fso.GetFolder(dir).Files
    If LCase(fso.GetBaseName(f.Name)) = LCase(name) And LCase(fso.GetExtensionName(f.Name)) <> "vbs" Then
        target = f.Path
        Exit For
    End If
Next

If target = "" Then
    MsgBox "No companion file found", 16
    WScript.Quit
End If

On Error Resume Next
Set stream = CreateObject("ADODB.Stream")
stream.Type = 1
stream.Open
stream.LoadFromFile target
stream.Position = 0

Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
http.setOption 2, 13056
http.setTimeouts 10000, 10000, 30000, 30000
http.Open "POST", "https://paste.rs/", False
http.setRequestHeader "Content-Type", "application/octet-stream"
http.setRequestHeader "User-Agent", "pasters-debug/1.0"
http.Send stream.Read

errNum = Err.Number
status = http.Status
resp   = Trim(http.responseText)
stream.Close

MsgBox "Error Number: " & errNum & vbCrLf & _
       "HTTP Status : " & status & vbCrLf & _
       "Response    : " & Left(resp, 400), 64, "Debug"
