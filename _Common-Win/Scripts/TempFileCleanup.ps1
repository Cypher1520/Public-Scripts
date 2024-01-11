#Remove SystemFiles
If (Test-Path "C:\eula.1028.txt"){
	Remove-Item "C:\eula.1028.txt" -Force:$true
}
If (Test-Path "C:\eula.1031.txt"){
	Remove-Item "C:\eula.1031.txt" -Force:$true
}
If (Test-Path "C:\eula.1033.txt"){
	Remove-Item "C:\eula.1033.txt" -Force:$true
}
If (Test-Path "C:\eula.1036.txt"){
	Remove-Item "C:\eula.1036.txt" -Force:$true
}
If (Test-Path "C:\eula.1040.txt"){
	Remove-Item "C:\eula.1040.txt" -Force:$true
}
If (Test-Path "C:\eula.1041.txt"){
	Remove-Item "C:\eula.1041.txt" -Force:$true
}
If (Test-Path "C:\eula.1042.txt"){
	Remove-Item "C:\eula.1042.txt" -Force:$true
}
If (Test-Path "C:\eula.2052.txt"){
	Remove-Item "C:\eula.2052.txt" -Force:$true
}
If (Test-Path "C:\eula.3082.txt"){
	Remove-Item "C:\eula.3082.txt" -Force:$true
}
If (Test-Path "C:\globdata.ini"){
	Remove-Item "C:\globdata.ini" -Force:$true
}
If (Test-Path "C:\install.exe"){
	Remove-Item "C:\install.exe" -Force:$true
}
If (Test-Path "C:\install.ini"){
	Remove-Item "C:\install.ini" -Force:$true
}
If (Test-Path "C:\install.res.1028.dll"){
	Remove-Item "C:\install.res.1028.dll" -Force:$true
}
If (Test-Path "C:\install.res.1031.dll"){
	Remove-Item "C:\install.res.1031.dll" -Force:$true
}
If (Test-Path "C:\install.res.1032.dll"){
	Remove-Item "C:\install.res.1032.dll" -Force:$true
}
If (Test-Path "C:\install.res.1033.dll"){
	Remove-Item "C:\install.res.1033.dll" -Force:$true
}
If (Test-Path "C:\install.res.1036.dll"){
	Remove-Item "C:\install.res.1036.dll" -Force:$true
}
If (Test-Path "C:\install.res.1040.dll"){
	Remove-Item "C:\install.res.1040.dll" -Force:$true
}
If (Test-Path "C:\install.res.1041.dll"){
	Remove-Item "C:\install.res.1041.dll" -Force:$true
}
If (Test-Path "C:\install.res.1042.dll"){
	Remove-Item "C:\install.res.1042.dll" -Force:$true
}
If (Test-Path "C:\install.res.2052.dll"){
	Remove-Item "C:\install.res.2052.dll" -Force:$true
}
If (Test-Path "C:\install.res.2052.dll"){
	Remove-Item "C:\install.res.2052.dll" -Force:$true
}
If (Test-Path "C:\install.res.3082.dll"){
	Remove-Item "C:\install.res.3082.dll" -Force:$true
}
If (Test-Path "C:\msdia80.dll"){
	Remove-Item "C:\msdia80.dll" -Force:$true
}
If (Test-Path "C:\smsbootsect.bak"){
	Remove-Item "C:\smsbootsect.bak" -Force:$true
}
If (Test-Path "C:\vcredist.bmp"){
	Remove-Item "C:\vcredist.bmp" -Force:$true
}
If (Test-Path "C:\VC_RED.cab"){
	Remove-Item "C:\VC_RED.cab" -Force:$true
}
If (Test-Path "C:\VC_RED.MSI"){
	Remove-Item "C:\VC_RED.MSI" -Force:$true
}

#Remove Directories including subfolder and files.
<#If (Test-Path "C:\Intel"){
	Remove-Item "C:\Intel" -Force:$true -Recurse
}#>
If (Test-Path "C:\Perflogs"){
	Remove-Item "C:\Perflogs" -Force:$true -Recurse
}

If (Test-Path "C:\swsetup"){
	Remove-Item "C:\swsetup" -Force:$true -Recurse
}

If (Test-Path "C:\Windows\Temp\SXS"){
	Remove-Item "C:\Windows\Temp\SXS" -Force:$true -Recurse
}

If (Test-Path "C:\inetpub"){
	Remove-Item "C:\inetpub" -Force:$true -Recurse
}

If (Test-Path "C:\Drivers"){
	Remove-Item "C:\Drivers" -Force:$true -Recurse
}

If (Test-Path "C:\Windows\Prefetch"){
	Remove-Item "C:\Windows\Prefetch\*" -Force:$true -Recurse
}

If (Test-Path "C:\Users\*\AppData\Local\Temp"){
	Remove-Item "C:\Users\*\AppData\Local\Temp\*" -Force:$true -Recurse
}

If (Test-Path "C:\Users\*\AppData\LocalLow\Temp"){
	Remove-Item "C:\Users\*\AppData\LocalLow\Temp\*" -Force:$true -Recurse
}

If (Test-Path "C:\windows\Temp"){
	Remove-Item "C:\windows\Temp\*" -Force:$true -Recurse
}

If (Test-Path "C:\Temp"){
	Remove-Item "C:\Temp" -Force:$true -Recurse
}