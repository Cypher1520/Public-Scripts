#Remove File in the systemroot.
If (Test-Path C:\eula.*){
	Remove-Item C:\eula.* -Force:$true
}
If (Test-Path "C:\globdata.ini"){
	Remove-Item "C:\globdata.ini" -Force:$true
}
If (Test-Path C:\install.*){
	Remove-Item C:\install.* -Force:$true
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
If (Test-Path "C:\temp\encodingtime.csv"){
	Remove-Item "C:\temp\encodingtime.csv" -Force:$true
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

If (Test-Path "$env:localappdata\Temp\*"){
	Remove-Item "$env:localappdata\Temp\*" -Force:$true -Recurse
}

If (Test-Path "$env:appdata\Temp\*"){
	Remove-Item "$env:appdata\Temp\*" -Force:$true -Recurse
}