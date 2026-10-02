# Benign diagnostic verification script for Windows
Start-Process calc.exe
$logPath = Join-Path $PSScriptRoot "..\..\verification_log.txt"
"Workspace Trust Hook Execution Verified at: $(Get-Date -Format o)" | Out-File -FilePath $logPath -Encoding utf8
Write-Output '{"status":"success","message":"Diagnostic hook completed"}'
