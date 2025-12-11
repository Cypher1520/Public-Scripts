<#
.AUTHOR
        Chris Rockwell
        Email: chris@r-is.tech | chris.rockwell@insight.com

.SYNOPSIS
        Uninstall helper that supports product-based (Win32_Product/MSI) or
        file-based uninstall flows with logging and clean-up of tag files.

.DESCRIPTION
        This template provides two uninstall approaches:
            - ProductUninstall: locates MSI products via Win32_Product matching
                $productName and uninstalls them using msiexec.
            - FileUninstall: runs a provided uninstall executable ($uninstallFile)
                with silent switches in $argumentList.

        The script captures a transcript to %ProgramData%\IntuneConfig\Transcripts
        and removes tag/log artifacts for the target package after a successful
        uninstall. Adjust $argumentList, $productName, or $uninstallFile to suit
        the application being removed.

.EXAMPLE
        Intune command for uninstallation (copy/paste into intune program page):
                powershell.exe -ExecutionPolicy Bypass -NoProfile -File .\uninstall.ps1

.NOTES
        - Set $fileName and either $productName (preferred) or $uninstallFile
            before running the script.
        - Success exit codes treated as success: 0, 3010, 1641.
        - Uses registry-based detection for faster performance compared to Win32_Product.
        - Get Installed apps options (use DisplayName value for $productName):
            $uninstallPaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            foreach ($path in $uninstallPaths) {
                Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | Sort-Object DisplayName | Select-Object DisplayName
            }
#>

#region Variables
$fileName = $null       #Replace with filename
$productName = $null    #Replace with product name if available, use: "Get-Package | Select-Object Name, Version | Sort-Object Name | Format-Table -AutoSize"

# if app not in the list above, use uninstallFiles variable below, remove comment and fill in path for uninstall file.
$uninstallFile = $null  #Replace with "<FILEPATH>" if product name not available
$argumentList = @(
    #"SILENTSWITCHES"
)

#endRegion
#-------------------------------------------

#region Functions
function ProductUninstall {
    # Use this when program exists in the registry uninstall list, if not use fileUninstall
    # Uninstall
    Write-Host (Get-Date) "|" Uninstalling $fileName...

    if ([string]::IsNullOrEmpty($productName)) {
        Write-Host (Get-Date) "|" "Error: productName variable is not set." -ForegroundColor Red
        Stop-Transcript
        Exit 1
    }

    $exitCode = 0
    $uninstallAttempts = 0
    $maxAttempts = 10  # Prevent infinite loops

    do {
        $uninstallAttempts++
        Write-Host (Get-Date) "|" "Uninstall attempt #$uninstallAttempts - Checking for products matching: $productName" -ForegroundColor Cyan
        
        # Registry paths for installed applications
        $uninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $products = @()
        foreach ($path in $uninstallPaths) {
            $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
                $_.DisplayName -and $_.DisplayName -like "*$productName*"
            }
            if ($apps) {
                $products += $apps
            }
        }
        
        if ($products.Count -eq 0) {
            Write-Host (Get-Date) "|" "No more products found matching: $productName" -ForegroundColor Green
            break
        }

        Write-Host (Get-Date) "|" "Found $($products.Count) product(s) to uninstall" -ForegroundColor Yellow

        # Uninstall the first product found
        $product = $products[0]
        Write-Host (Get-Date) "|" "Uninstalling: $($product.DisplayName)" -ForegroundColor Cyan
        Write-Host (Get-Date) "|" "UninstallString: $($product.UninstallString)" -ForegroundColor Gray
        
        $proc = $null
        
        # Check if it's an MSI package
        if ($product.UninstallString -match "msiexec") {
            Write-Host (Get-Date) "|" "Detected MSI package" -ForegroundColor Yellow
            # Use MSI uninstall with product code
            $productCode = $null
            
            # Try to extract product code from UninstallString
            if ($product.UninstallString -match '\{[A-F0-9\-]{36}\}') {
                $productCode = $matches[0]
            } elseif ($product.PSChildName -match "^\{[A-F0-9\-]{36}\}$") {
                $productCode = $product.PSChildName
            }
            
            if ($productCode) {
                $proc = Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $productCode /qn /norestart" -PassThru -Wait
            } else {
                Write-Host (Get-Date) "|" "Could not determine MSI product code for $($product.DisplayName)" -ForegroundColor Yellow
                continue
            }
        }
        # Handle non-MSI packages using their UninstallString
        elseif ($product.UninstallString) {
            Write-Host (Get-Date) "|" "Detected non-MSI package - using UninstallString" -ForegroundColor Yellow
            
            $uninstallString = $product.UninstallString.Trim()
            
            # Parse the uninstall string to separate executable and arguments
            if ($uninstallString.StartsWith('"')) {
                # Handle quoted executable path
                $endQuoteIndex = $uninstallString.IndexOf('"', 1)
                if ($endQuoteIndex -gt 0) {
                    $executable = $uninstallString.Substring(1, $endQuoteIndex - 1)
                    $existingArguments = $uninstallString.Substring($endQuoteIndex + 1).Trim()
                }
                else {
                    $executable = $uninstallString
                    $existingArguments = ""
                }
            }
            else {
                # No quotes - split on first space
                $spaceIndex = $uninstallString.IndexOf(' ')
                if ($spaceIndex -gt 0) {
                    $executable = $uninstallString.Substring(0, $spaceIndex)
                    $existingArguments = $uninstallString.Substring($spaceIndex + 1).Trim()
                }
                else {
                    $executable = $uninstallString
                    $existingArguments = ""
                }
            }
            
            # Combine existing arguments with custom argumentList
            $finalArguments = @()
            
            # Add existing arguments from UninstallString
            if ($existingArguments) {
                $finalArguments += $existingArguments.Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
            }
            
            # Add custom arguments from argumentList if they don't already exist
            if ($argumentList -and $argumentList.Count -gt 0) {
                Write-Host (Get-Date) "|" "Custom arguments to add: $($argumentList -join ', ')" -ForegroundColor Gray
                foreach ($arg in $argumentList) {
                    # Check if this exact argument already exists (case-insensitive)
                    $argExists = $finalArguments | Where-Object { $_ -eq $arg }
                    if (-not $argExists) {
                        Write-Host (Get-Date) "|" "  Adding argument: $arg" -ForegroundColor Gray
                        $finalArguments += $arg
                    } else {
                        Write-Host (Get-Date) "|" "  Skipping duplicate argument: $arg" -ForegroundColor Gray
                    }
                }
            }
            
            Write-Host (Get-Date) "|" "Executable: `"$executable`"" -ForegroundColor Gray
            Write-Host (Get-Date) "|" "Existing Arguments: $existingArguments" -ForegroundColor Gray
            Write-Host (Get-Date) "|" "Final Arguments: $($finalArguments -join ' ')" -ForegroundColor Gray
            
            # Execute the uninstall command
            if (Test-Path $executable) {
                try {
                    if ($finalArguments -and $finalArguments.Count -gt 0) {
                        $proc = Start-Process "$executable" -ArgumentList $finalArguments -PassThru -Wait -ErrorAction Stop
                    }
                    else {
                        $proc = Start-Process "$executable" -PassThru -Wait -ErrorAction Stop
                    }
                }
                catch {
                    Write-Host (Get-Date) "|" "Failed to execute uninstall command: $($_.Exception.Message)" -ForegroundColor Red
                    $exitCode = 1
                    break
                }
            }
            else {
                Write-Host (Get-Date) "|" "Uninstall executable not found: $executable" -ForegroundColor Red
                $exitCode = 1
                break
            }
        } else {
            Write-Host (Get-Date) "|" "No uninstall string found for $($product.DisplayName)" -ForegroundColor Yellow
            break
        }
        
        if ($proc -and $proc.ExitCode -notin @(0, 3010, 1641, 1605)) {
            Write-Host (Get-Date) "|" "Uninstall failed for $($product.DisplayName). Exit code: $($proc.ExitCode)" -ForegroundColor Red
            $exitCode = $proc.ExitCode
            break  # Stop on actual uninstall failure
        } elseif ($proc) {
            if ($proc.ExitCode -eq 1605) {
                Write-Host (Get-Date) "|" "Product already uninstalled: $($product.DisplayName). Exit code: 1605" -ForegroundColor Yellow
            } else {
                Write-Host (Get-Date) "|" "Uninstall completed successfully for $($product.DisplayName). Exit code: $($proc.ExitCode)" -ForegroundColor Green
            }
        }
        
        # Brief pause to allow registry to update
        Start-Sleep -Seconds 2
        
    } while ($products.Count -gt 0 -and $uninstallAttempts -lt $maxAttempts)

    if ($uninstallAttempts -ge $maxAttempts) {
        Write-Host (Get-Date) "|" "Warning: Maximum uninstall attempts reached. Some products may still remain." -ForegroundColor Yellow
    }

    # PostUninstall
    # Delete Tag files if present
    if (Test-Path "$($logDest)\$($fileName).tag") {
        Write-Host (Get-Date) "|" Removing $fileName tag file -ForegroundColor Green
        Remove-Item -Path "$($logDest)\$($fileName).tag"
    }

    $logFile = "$logDest\$fileName.log"
    if (Test-Path $logFile) {
        Write-Host (Get-Date) "|" Removing $logFile -ForegroundColor Green
        Remove-Item -Path $logFile
    }

    # Quit
    Write-Host (Get-Date) "|" "Uninstall complete. Exit code: $exitCode" -ForegroundColor Green
    Stop-Transcript
    Exit $exitCode
}

function FileUninstall {
    # Uninstall
    if ([string]::IsNullOrEmpty($uninstallFile)) {
        Write-Host (Get-Date) "|" "Error: uninstallFile variable is not set." -ForegroundColor Red
        Stop-Transcript
        Exit 1
    }

    if (!(Test-Path $uninstallFile)) {
        Write-Host (Get-Date) "|" "Error: Uninstall file not found: $uninstallFile" -ForegroundColor Red
        Stop-Transcript
        Exit 1
    }

    Write-Host (Get-Date) "|" "Uninstalling using file: $uninstallFile" -ForegroundColor Cyan
    $proc = Start-Process "$uninstallFile" -Verb RunAs -ArgumentList $argumentList -PassThru -Wait
    $exitCode = $proc.ExitCode

    if ($exitCode -notin @(0, 3010, 1641)) {
        Write-Host (Get-Date) "|" "Uninstall failed. Exit code: $exitCode" -ForegroundColor Red
    }

    # PostUninstall
    # Delete tag files if present
    if (Test-Path "$($logDest)\$($fileName).tag") {
        Write-Host (Get-Date) "|" Removing $fileName tag file -ForegroundColor Green
        Remove-Item -Path "$($logDest)\$($fileName).tag"
    }
    $logFile = "$logDest\$fileName.log"
    if (Test-Path $logFile) {
        Write-Host (Get-Date) "|" Removing $logFile -ForegroundColor Green
        Remove-Item -Path $logFile
    }

    # Quit
    Write-Host (Get-Date) "|" "Uninstall complete. Exit code: $exitCode" -ForegroundColor Green
    Stop-Transcript
    Exit $exitCode
}
#endregion

#region Execution
# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host (Get-Date) "|" Relaunching as 64-bit Powershell -ForegroundColor Yellow
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

# PreUninstall
$logDest = "$($env:ProgramData)\IntuneConfig"
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "IntuneConfig" -ItemType Directory
}

# Create Transcripts subdirectory if it doesn't exist
if (!(Test-Path "$logDest\Transcripts")) {
    New-Item -Path "$logDest" -Name "Transcripts" -ItemType Directory
}

# Validate required variables
if ([string]::IsNullOrEmpty($fileName)) {
    Write-Host (Get-Date) "|" "Error: fileName variable is not set. Please specify a filename." -ForegroundColor Red
    Exit 1
}

Start-Transcript "$logDest\Transcripts\$fileName-uninstall.log" -Append

if ($null -ne $productName) {
    ProductUninstall
}
elseif (($null -eq $productName) -and ($null -ne $uninstallFile)) {
    FileUninstall
}
else {
    Write-Host (Get-Date) "|" "Error: Either productName or uninstallFile must be specified." -ForegroundColor Red
    Stop-Transcript
    Exit 1
}
#endregion