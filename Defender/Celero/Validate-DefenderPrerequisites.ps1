param(
    [Parameter()]
    [hashtable]$2012R2Prereqs = @{
        "SSU"                                                     = "KB5037021"
        "Update for customer experience and diagnostic telemetry" = "KB3080149"
        "Universal C Runtime in Windows"                          = "KB2999226"
        "Security Update for Windows Server 2012 R2"              = "KB3045999"
        "April 2024 LCU"                                          = "KB5036899"
        "Microsoft Defender Antivirus Updates"                    = "KB4052623"
    },
    [Parameter()]
    [hashtable]$2016Prereqs = @{
        "SSU"                                  = "KB5037016"
        "April 2024 LCU"                       = "KB5036899"
        "Microsoft Defender Antivirus Updates" = "KB4052623"
    },
    [Parameter()]
    [hashtable]$2019Prereqs = @{
    },
    [Parameter()]
    [hashtable]$2022Prereqs = @{
    }
)

####### MAIN #######
#Validate OS Version
$osVersion = Get-CimInstance Win32_Operatingsystem | Select-Object -expand Caption
Write-host "Current OS is $($osVersion)"
if ($osVersion.Contains("2012 R2")) {
    Write-host "Server 2012 R2 Detected, checking prerequisites..."
    $2012R2Prereqs.Keys | ForEach-Object {
        $hotFix = $false
        try {
            $hotFix = Get-HotFix -Id $2012R2Prereqs[$_] -ErrorAction Ignore
            if ($hotFix) {
                Write-Host -ForegroundColor Green "$($_) $($2012R2Prereqs[$_]) is installed"
            }
            else {
                Write-Host -ForegroundColor Red "$($_) $($2012R2Prereqs[$_]) is not installed"
            }
        }
        catch {
            throw $_
        }
    }
    Write-host "Checking Defender Feature status..."
    $defenderFeature = Get-WindowsOptionalFeature -FeatureName Windows-Defender -Online
    if ($defenderFeature.State -like "Enabled") {
        Write-Host -ForegroundColor Green "The Defender Feature is $($defenderFeature.State)"
    }
    else {
        Write-Host -ForegroundColor Red "The Defender Feature is $($defenderFeature.State)"
    }
}
elseif ($osVersion.Contains("2016")) {
    Write-host "Server 2016 Detected, checking prerequisites..."
    $2016Prereqs.Keys | ForEach-Object {
        $hotFix = $false
        try {
            $hotFix = Get-HotFix -Id $2016Prereqs[$_] -ErrorAction Ignore
            if ($hotFix) {
                Write-Host -ForegroundColor Green "$($_) $($2016Prereqs[$_]) is installed"
            }
            else {
                Write-Host -ForegroundColor Red "$($_) $($2016Prereqs[$_]) is not installed"
            }
        }
        catch {
            throw $_
        }       
    }
    Write-host "Checking Defender Feature status..."
    $defenderFeature = Get-WindowsOptionalFeature -FeatureName Windows-Defender -Online
    if ($defenderFeature.State -like "Enabled") {
        Write-Host -ForegroundColor Green "The Defender Feature is $($defenderFeature.State)"
    }
    else {
        Write-Host -ForegroundColor Red "The Defender Feature is $($defenderFeature.State)"
    }
}
else {
    Write-host "Unhandled OS detected, no action performed"
}