<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#Main Connectors

    <#
    To install run PS as admin and run following to install then connect with following.
    Install-Module "AzureAD | MSOnline | ExchangeOnlineShell"
    #>

#Find-Module -Name "*MSOnline*"
#Update-Module -Name ExchangeOnlineManagement
    
    ipmo AzureADPreview
    Connect-AzureAD
    gcm -module LAPS

    Install-Module Microsoft.Graph
    Import-Module Microsoft.Graph
    Connect-Graph

    Import-Module MSOnline
    Connect-MsolService
    
    Install-Module ExchangeOnlineManagement
    Import-Module ExchangeOnlineManagement
    Get-Module ExchangeOnlineManagement
    $UserCredential = Get-Credential
    <#NoMFA#>Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true
    <#MFA#>Connect-ExchangeOnline -UserPrincipalName crockwell@naturespath.com -ShowProgress $true

    Import-Module ExchangeOnlineShell
    Connect-ExchangeOnline

    Import-Module MicrosoftTeams
    Connect-MicrosoftTeams

    #teams with MFA
    Import-Module MicrosoftTeams
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession

    #PSSoftware for "Get-InstalledSoftware"
    Install-Module PSSoftware -AllowClobber


    <# Needs to be enabled in tenant
    https://docs.microsoft.com/en-us/mem/intune/developer/intune-graph-apis
    Import-Module Microsoft.Graph.Intune
    Connect-MSGraph#>

#Skype/Teams online connector
    #Import-Module SkypeOnlineConnector
    #Install connector and then run below
    Import-Module "C:\\Program Files\\Common Files\\Skype for Business Online\\Modules\\SkypeOnlineConnector\\SkypeOnlineConnector.psd1"

    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession

#Connect Sercurity & Compliance
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session

#ExOnPremise Connector
    <#$cred = Get-Credential "Accountname"
    $2010session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://"exchangeserver"/powershell -Credential $cred
    Import-PSSession $2010session#>
    $cred = Get-Credential
    $exsession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ta-ex05.company.local/powershell -Credential $cred
    Import-PSSession $exsession

        (get-item C:\Windows\System32\WindowsPowerShell\v1.0\Modules\MSOnline\Microsoft.Online.Administration.Automation.PSModule.dll).VersionInfo.FileVersion