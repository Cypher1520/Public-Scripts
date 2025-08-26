$clientId = "--" #Provide the Client ID
$clientSecret = "--" # Provide the ClientSecret
$ourTenantId = "--" #Specify the TenatID

$Resource = "deviceManagement/windowsAutopilotDeviceIdentities"
$Resource = "deviceManagement/managedDevices"
$graphApiVersion = "Beta"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
$authority = "https://login.microsoftonline.com/$ourTenantId"
Update-MSGraphEnvironment -AppId $clientId -Quiet
Update-MSGraphEnvironment -AuthUrl $authority -Quiet
Connect-MSGraph -ClientSecret $clientSecret

$SerialNumbers = Get-Content -Path "SerialNumber.txt" #Provide the list of device you want to check the GroupTag
$table = foreach ($Serial in $SerialNumbers)
{
Get-AutopilotDevice -serial $Serial | select serialnumber, GroupTag
}
$table | Out-GridView