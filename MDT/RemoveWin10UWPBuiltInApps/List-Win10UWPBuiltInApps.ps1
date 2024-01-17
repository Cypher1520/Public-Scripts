$ListFile = $PSScriptRoot + “\W10UWPAppList.txt"
$Appx = Get-AppxPackage | select name | Sort-Object -Property Name
$appx | Out-File -FilePath $ListFile