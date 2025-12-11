$TenantID = "be422d78-5df5-41f6-83d9-d8cc35052964"
$ManagedIdentity = "ris-automation"
$Permissions = @("DeviceManagementManagedDevices.Read.All", "DeviceManagementManagedDevices.ReadWrite.All", "AuditLog.Read.All", "User.Read.All")
$GraphAppId = "00000003-0000-0000-c000-000000000000"

Connect-AzureAD -TenantId $TenantID
$ManagedIdentityServicePrincipal = (Get-AzureADServicePrincipal -Filter "displayName eq '$ManagedIdentity'")
$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"

foreach ($Permission in $Permissions)
    {
    $AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $Permission -and $_.AllowedMemberTypes -contains "Application"}
    New-AzureAdServiceAppRoleAssignment -ObjectId $ManagedIdentityServicePrincipal.ObjectId -PrincipalId $ManagedIdentityServicePrincipal.ObjectId -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id
    }
 