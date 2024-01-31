#download installer
$url = "DOWNLOAD URL"
$file = "DOWNLOADZIPFILE"

#extract installer
Expand-Archive -Path $file -DestinationPath .

#Install
$installer = ".\EXTRACTED FILE LOCATION"
Start-Process -FilePath $installer -ArgumentList "/silent" -Wait

#cleanup
Remove-Item -Path $file -Force
Remove-Item -Path ".\Extracted folder" -Recurse -Force