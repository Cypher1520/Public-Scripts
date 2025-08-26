#region Settings
$ServiceName = 'tzautoupdate'
$Action = 'Start'
#endregion
#region Functions
Function Manage-Services {
    Param
    (
        [string]$ServiceName,
        [ValidateSet("Start", "Stop", "Restart", "Disable", "Auto", "Manual")]
        [string]$Action
    )

    try {
        Start-Transcript -Path "C:\ProgramData\AutopilotConfig\$($ServiceName)_Management.Log" -Force -ErrorAction SilentlyContinue
        # Turn on service
        Get-Date
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        $service
        if ($service) {
            Switch ($Action) {
                "Start" { Start-Service -Name $ServiceName; Break; }
                "Stop" { Stop-Service -Name $ServiceName; Break; }
                "Restart" { Restart-Service -Name $ServiceName; Break; }
                "Disable" { Set-Service -Name $ServiceName -StartupType Disabled -Status Stopped; Break; }
                "Auto" { Set-Service -Name $ServiceName -StartupType Automatic -Status Running; Break; }
                "Manual" { Set-Service -Name $ServiceName -StartupType Manual -Status Running; Break; }
            }
            Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        }
        Stop-Transcript -ErrorAction SilentlyContinue
    }

    catch {
        throw $_
    }
}

Function Manage-Registry {

    try {
        # Set Registry Values
        $registrySettings = @(
            @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; Name = "Value"; DesiredValue = "Allow" },
            @{ Path = "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"; Name = "Start"; DesiredValue = 3 }
        )
        foreach ($setting in $registrySettings) {
    
            if (Test-Path $setting.Path) {
                $currentValue = (Get-ItemProperty -Path $setting.Path -ErrorAction SilentlyContinue).$($setting.Name)
                if ($currentValue -ne $setting.DesiredValue) {
                    Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.DesiredValue
                    Write-Host "Updated or created $($setting.Name) in $($setting.Path) with value $($setting.DesiredValue)"
                }
                else {
                    Write-Host "$($setting.Name) in $($setting.Path) is already set to $($setting.DesiredValue)"
                }
            }
            else {
                Write-Warning "Registry path $($setting.Path) does not exist."
            }
    
        }
    }

    catch {
        throw $_
    }
}
    #endregion

    #region Process
    try {
        Write-Host "Fixing TimeZone service statup type to MANUAL."
        Manage-Services -ServiceName $ServiceName -Action $Action
        Write-Host "Setting Registry values"
        Manage-Registry
        Exit 0
    }
    catch {
        Write-Error $_.Exception.Message
    }
    #endregion