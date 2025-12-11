<#
.NOTES
    File    : detection.ps1
    Purpose : Intune Win32 App detection script template.
    Author  : Chris Rockwell 
    Email   : chris@r-is.tech | chris.rockwell@insight.com
    Usage   : Return exit code 0 when the application is detected (no install required).
              Return non-zero when detection fails (installer should run).

.DESCRIPTION
    Minimal, easy-to-edit template for use as the "Detection script" in Intune Win32 app
    packaging. The sample below checks for a tag file under a ProgramData path. Replace the
    detection logic with whatever artifact your installer creates (file, registry key, product
    version, etc.).

.EXAMPLE
    Run the following to get list of installed applications, then copy the DisplayName and paste into  $ProductName
        $uninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($path in $uninstallPaths) {
            Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | Sort DisplayName | Select-Object DisplayName
        }
#>

$fileName = $null # Filename to detect if product not registered in uninstall registry
$productName = @() # Set DisplayName(s) of app(s) to detect - can be single string or array with @("Product1", "Product2")
$detectionFilePath = $null # Path to the detection file

$found = $false

# Check if productName is provided for registry-based detection
if ($null -ne $productName -and $productName.Count -gt 0) {
    # Ensure productName is treated as an array
    $productNames = @($productName)
    Write-Host "Using registry-based detection for product(s): $($productNames -join ', ')" -ForegroundColor Yellow
    
    # Registry paths for installed applications
    $uninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($path in $uninstallPaths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
            if ($_.DisplayName) {
                # Check if DisplayName matches any of the product names
                $matchFound = $false
                foreach ($name in $productNames) {
                    if ($_.DisplayName -like "*$name*") {
                        $matchFound = $true
                        break
                    }
                }
                $matchFound
            }
        }
        if ($apps) {
            $found = $true
            $detectedProduct = $apps[0].DisplayName
            break
        }
    }
    
    if ($found) {
        Write-Host "Product Detected: $detectedProduct" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "None of the specified products detected: $($productNames -join ', ')" -ForegroundColor Red
        exit 1
    }
}
# Use file-based detection if productName is null
elseif ($null -ne $fileName -and $fileName.Trim() -ne "" -and $null -ne $detectionFilePath -and $detectionFilePath.Trim() -ne "") {
    Write-Host "Using file-based detection for file: $fileName at path: $detectionFilePath" -ForegroundColor Yellow
    
    # Construct the full file path
    $fullFilePath = Join-Path -Path $detectionFilePath -ChildPath $fileName
    
    # Check if the file exists
    if (Test-Path -Path $fullFilePath -PathType Leaf) {
        Write-Host "File $fileName detected at $fullFilePath" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "File $fileName not detected at $fullFilePath" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Error: Either productName must be specified for registry detection, or both fileName and detectionFilePath must be specified for file detection" -ForegroundColor Red
    exit 1
}