# Connect to Graph first
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"
Select-MgProfile -Name "beta"

# Path to sanitized JSON file
$baselinePath = "C:\Users\ChrisRockwell\OneDrive - Rockwell Information Services\Downloads\MacOS - OIB - Device Security - D - Restrictions - v1.0.json"
$baselineJson = Get-Content -Raw -Path $baselinePath

# Convert JSON to a PSObject
$body = $baselineJson | ConvertFrom-Json

# Create the configuration policy in Intune
$policy = Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" `
    -Body ($body | ConvertTo-Json -Depth 20 -Compress) `
    -ContentType "application/json"

Write-Host "Policy created with ID:" $policy.id