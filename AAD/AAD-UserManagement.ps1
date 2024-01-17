<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Get users with proxy-----------#
    get-azureaduser -All:$true | select UserPrincipalName,@{name="OnMicrosoftProxyAddress";e={($_.proxyaddresses | ? {$_ -match "@\w*.onmicrosoft.com"}) -replace "smtp:"}}


#-----------Sign-in Logs-----------#
<#
Prerequsits
Install-module azureadpreview
May need to "Uninstall-Module AzureAD" first and then "install-module azureadpreview"
#>
    Get-AzureADAuditSignInLogs -Filter "createdDateTime gt 2022-03-06T17:30:00.0Z" | Select UserDisplayName,UserPrincipalName,IPAddress,DeviceDetail | Export-CSV "C:\Temp\3moSignInLogs.CSV" -NoTypeInformation -Encoding UTF8