# --------------------------------
# Uninstall.ps1
# This script intends to uninstall applications based off name
# --------------------------------
#Sets security protocols to allow silent Powershell Run
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::tls12
#Installs NuGet
Install-PackageProvider -Name NuGet -Force
#set PowerShelly Gallery as trusted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# --------------------------------
# Uninstall <APPNAME>
# --------------------------------
Get-Package * | Where-Object {$_.Name -like "*<APPNAME*"} | % {Uninstall-Package $_.Name}

Remove-Item -Path C:\Apps\sqldeveloper -Recurse -Confirm:$false