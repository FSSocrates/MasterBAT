@echo off
setlocal enabledelayedexpansion

set "ScriptDir=%~dp0"
set "ScriptName=%~n0"

set "TargetFile="
for %%F in ("!ScriptDir!!ScriptName!.*") do (
    if /i not "%%~xF"==".bat" (
        set "TargetFile=%%F"
    )
)

if not defined TargetFile (
    msg * "Upload Failed: Could not find a companion data file named %ScriptName%.*"
    exit /b
)

for /f "delims=" %%I in ('curl --data-binary @"!TargetFile!" https://paste.rs 2^>nul') do set "ResponseURL=%%I"

if not defined ResponseURL (
    msg * "Upload Failed: Network error or server timed out while transferring."
    exit /b
)

echo | set /p="%ResponseURL%" | clip
msg * "Upload Successful: The raw data link has been copied to your clipboard."

exit /b
