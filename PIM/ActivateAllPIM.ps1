########################## Config ##########################

$expirationDuration = "PT4H"                               # Activation Duration
$justification = "Execute changes to environment"          # Justification for accessing role

########################## Common Role IDs ##########################
#                                                                   #
# Contributor:                 b24988ac-6180-42a0-ab88-20f7382dd24c #
# Resource Policy Contributor: 36243c78-bf99-498c-9df9-86d9f8d28608 #
# Network Contributor:         4d97b98b-1d4f-4787-a291-c67834d212e7 #
# Security Admin:              fb1c8493-542b-48eb-b624-b4c8fea62acd #
######################################################################

<#
#Role Selection
Write-Host "    1. Contributor"
Write-Host "    2. Resource Policy Contributor"
Write-Host "    3. Network Contributor"
Write-host "    4. Security Admin"
$roleId = Read-Host Select Role

if ($roleId -eq 1) {
    $roleid = "b24988ac-6180-42a0-ab88-20f7382dd24c"    #Contributor
}
elseif ($roleid -eq 2) {
    $roleid = "36243c78-bf99-498c-9df9-86d9f8d28608"    #Resource Policy Contributor
}
elseif ($roleid -eq 3) {
    $roleid = "4d97b98b-1d4f-4787-a291-c67834d212e7"    #Network Contributor
}
elseif ($roleid -eq 4) {
    $roleid = "fb1c8493-542b-48eb-b624-b4c8fea62acd"    #Security Admin
}

#>

$roleid1 = "b24988ac-6180-42a0-ab88-20f7382dd24c"
$roleid2 = "36243c78-bf99-498c-9df9-86d9f8d28608"
$roleid3 = "fb1c8493-542b-48eb-b624-b4c8fea62acd"

######################################################################

$subdump = (Get-AzSubscription | Where-Object { $_.Name -Like "SUB-*" -and $_.Name -notlike "SUB-ENT-*" -and $_.Name -notlike "*PPJV*" -and $_.Name -notlike "*Everlink*" })
$step = 0

foreach ($item in $subdump) {
    $guid = New-Guid
    $startTime = Get-Date -Format o 
    $scope = "/subscriptions/$($item.id)"
    $roledefinitionid = "/subscriptions/$($item.id)/providers/Microsoft.Authorization/roleDefinitions/$roleId1"
    $principalId = (Get-AzContext).Account.ExtendedProperties.HomeAccountId.Split('.')[0]

    New-AzRoleAssignmentScheduleRequest -Name $guid `
        -Scope $scope `
        -ExpirationDuration $expirationDuration `
        -ExpirationType AfterDuration `
        -PrincipalId $principalId `
        -RequestType SelfActivate `
        -RoleDefinitionId $roledefinitionID `
        -ScheduleInfoStartDateTime $startTime `
        -Justification $justification

    $guid = New-Guid
    $startTime = Get-Date -Format o 
    $scope = "/subscriptions/$($item.id)"
    $roledefinitionid = "/subscriptions/$($item.id)/providers/Microsoft.Authorization/roleDefinitions/$roleId2"
    $principalId = (Get-AzContext).Account.ExtendedProperties.HomeAccountId.Split('.')[0]

    New-AzRoleAssignmentScheduleRequest -Name $guid `
        -Scope $scope `
        -ExpirationDuration $expirationDuration `
        -ExpirationType AfterDuration `
        -PrincipalId $principalId `
        -RequestType SelfActivate `
        -RoleDefinitionId $roledefinitionID `
        -ScheduleInfoStartDateTime $startTime `
        -Justification $justification

    $guid = New-Guid
    $startTime = Get-Date -Format o 
    $scope = "/subscriptions/$($item.id)"
    $roledefinitionid = "/subscriptions/$($item.id)/providers/Microsoft.Authorization/roleDefinitions/$roleId3"
    $principalId = (Get-AzContext).Account.ExtendedProperties.HomeAccountId.Split('.')[0]

    New-AzRoleAssignmentScheduleRequest -Name $guid `
        -Scope $scope `
        -ExpirationDuration $expirationDuration `
        -ExpirationType AfterDuration `
        -PrincipalId $principalId `
        -RequestType SelfActivate `
        -RoleDefinitionId $roledefinitionID `
        -ScheduleInfoStartDateTime $startTime `
        -Justification $justification
    
    $step += 1
    $step
}