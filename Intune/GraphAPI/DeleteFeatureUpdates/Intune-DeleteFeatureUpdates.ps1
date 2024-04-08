<#PSScriptInfo
.SYNOPSIS
    Cleans up duplicate feature update profiles
 
.DESCRIPTION
    This script will delete all of the duplicate feature updates excluding the profiles containing specified display name of "assigned"
    To edit what name to delete, edit line 42
        
.EXAMPLE
   .\Intune-DeleteFeatureUpdates.ps1

.NOTES
    

.VERSION
    1.0

.AUTHOR
    Chris Rockwell
    chris@r-is.tech

.COPYRIGHT
    Feel free to use this, But would be grateful if my name is mentioned in Notes 

.CHANGELOG
    1.0 - 2024.2.12 - Initial Version
    
#>

Import-Module Microsoft.Graph.Intune
Get-Module -Name Microsoft.Graph.Intune -ListAvailable
(Get-Command -Module Microsoft.Graph.Intune).count

Connect-MSGraph -ForceInteractive

$resource = "deviceManagement/windowsFeatureUpdateProfiles"
$graphapiversion = "beta"
$uri = "https://graph.microsoft.com/$graphapiversion/$resource"

$all = Invoke-MSGraphRequest -HttpMethod GET -Url $uri | Get-MSGraphAllPages
$refined = $all | where {$_.displayName -notlike "assigned*"}

#delete objects
foreach ($r in $refined)
{
    $uri2 = "https://graph.microsoft.com/beta/deviceManagement/windowsFeatureUpdateProfiles/$($r.id)"
    Invoke-MSGraphRequest -HttpMethod DELETE -Url $uri2
    Write-Host Deleting ($r.displayName) -ForegroundColor Yellow
}