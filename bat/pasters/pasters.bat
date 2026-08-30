@echo off
setlocal enabledelayedexpansion

set "ScriptDir=%~dp0"
set "ScriptName=%~n0"

powershell -NoProfile -WindowStyle Hidden -Command ^
    "[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); ^
     $toast = New-Object System.Windows.Forms.NotifyIcon; ^
     $toast.Visible = $true; ^
     $target = Get-Item -Path '!ScriptDir!!ScriptName!.*' | Where-Object { $_.Extension -ne '.bat' } | Select-Object -First 1; ^
     if (-not $target) { ^
         $toast.Icon = [System.Drawing.SystemIcons]::Error; ^
         $toast.BalloonTipTitle = 'Upload Failed'; ^
         $toast.BalloonTipText = 'Could not find a companion data file named %ScriptName%.*'; ^
         $toast.ShowBalloonTip(5000); ^
         Start-Sleep -s 5; ^
         $toast.Dispose(); ^
         exit; ^
     } ^
     try { ^
         $url = Invoke-RestMethod -Method Post -InFile $target.FullName -Uri 'https://paste.rs' -TimeoutSec 10; ^
         $url | clip; ^
         $toast.Icon = [System.Drawing.SystemIcons]::Information; ^
         $toast.BalloonTipTitle = 'Upload Successful'; ^
         $toast.BalloonTipText = 'The raw data link has been copied to your clipboard.'; ^
     } catch { ^
         $toast.Icon = [System.Drawing.SystemIcons]::Error; ^
         $toast.BalloonTipTitle = 'Upload Failed'; ^
         $toast.BalloonTipText = 'Network error or server timed out while transferring.'; ^
     } ^
     $toast.ShowBalloonTip(5000); ^
     Start-Sleep -s 5; ^
     $toast.Dispose()"

exit /b
