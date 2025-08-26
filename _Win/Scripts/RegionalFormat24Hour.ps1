Write-Host "Setting Short time format"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm"

Write-Host "Setting Long time format"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss"