@echo off
setlocal enabledelayedexpansion
title Paste.rs Batch Script

set "ScriptDir=%~dp0"
set "ScriptName=%~n0"

set "TargetFile="
for %%F in ("!ScriptDir!!ScriptName!.*") do (
    if /i not "%%~xF"==".bat" (
        set "TargetFile=%%F"
    )
)

if not defined TargetFile (
    echo MsgBox "Upload Failed: Could not find a companion data file named %ScriptName%.*", 16, "Paste.rs Batch Script" > "%temp%\alert.vbs"
    cscript //nologo "%temp%\alert.vbs" & del "%temp%\alert.vbs"
    exit /b
)

for /f "delims=" %%I in ('curl --data-binary @"!TargetFile!" https://paste.rs 2^>nul') do set "ResponseURL=%%I"

if not defined ResponseURL (
    echo MsgBox "Upload Failed: Network error or server timed out while transferring.", 16, "Paste.rs Batch Script" > "%temp%\alert.vbs"
    cscript //nologo "%temp%\alert.vbs" & del "%temp%\alert.vbs"
    exit /b
)

echo | set /p="%ResponseURL%" | clip

echo MsgBox "Upload Successful: The raw data link has been copied to your clipboard.", 64, "Paste.rs Batch Script" > "%temp%\alert.vbs"
cscript //nologo "%temp%\alert.vbs" & del "%temp%\alert.vbs"

exit /b
