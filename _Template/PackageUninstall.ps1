# --------------------------------
# <APPNAME>Uninstall.ps1
# This script intends to clean up
# Dell Apps installed
# on new systems
# --------------------------------
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# --------------------------------
# Uninstall <APPNAME>
# --------------------------------
Get-Package * | Where-Object {$_.Name -like "*<APPNAME*"} | % {Uninstall-Package $_.Name}