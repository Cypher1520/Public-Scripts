<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    Installation script to install msi or exe files. Will evaluate what type of file is used and then install accordingly.
    For custom/additional install steps add them to the "PostInstall" Sections under the respective "Functions" regions.

    References
        $result = (Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
        FOR /d %%G in ("*") DO xcopy /Y "FILES TO COPY" "C:\users\%%G\AppData\Roaming\..."
        FOR /D %%G in ("*") DO REN "C:\Users\%%G\AppData\Local\OpenText" "OpenText.old"
        #####PSADT reference
        powershell.exe -ExecutionPolicy Bypass -command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
        powershell.exe -ExecutionPolicy Bypass -command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall' -DeployMode 'Silent'; Exit $LastExitCode }"

    Silent install flag variants
        /s /silent /q /qn /qb --SILENT --VERYSILENT "/SILENT /VERYSILENT /SUPPRESSMSGBOXES /SP-"

.Example
    Intune install command
        powershell.exe -ExecutionPolicy Bypass -command .\install.ps1
#>

#region Variables
# Global Variables
$fileName = $null        #fill in "filename.msi/exe"
$installer = "Media\$fileName"

# MSI Variables
$logFile = "$logDest\$fileName.log"
$logDest = "$($env:ProgramData)\AutopilotConfig"
    #edit variables in below list if necessary
$msiArgumentList = @(   #add any arguments for msi installations, quote each line if strings
    "/i "
    $installer
    "/qb!"
    "/norestart"
    "/L*v"
    $logFile
    #"ALLUSERS=1"
    #"OTHERATTRIBUTE=ABC"
    #"TRANSFORMS=transorm1.mst;transform2.mst"
)

# EXE Variables
$exeArgumentList = @(   #add any arguments for exe installations, quote each line if strings
    #"/s"
    #"--SILENT"
)

$errorCodes = @([int]0, 3010, 1641)     #errorcodes related to successful installation
#endregion



#region Functions
function InstallMSI {
    # Install
    Write-Host MSI Installing $fileName...
    $result = (Start-Process "msiexec.exe" -ArgumentList $msiArgumentList -Verb RunAs -PassThru -Wait).ExitCode
    if (!($result -in $errorCodes)) {
        Write-Host Install Failed -ForegroundColor Red
        Write-Host Exitcode: $result -ForegroundColor Red
        Stop-Transcript
        Exit $result
    }

    # PostInstall
    #creates tag file
    if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($filename).tag")) {
        Write-Host Creating Tag file. -ForegroundColor Cyan
        New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($filename).tag" -ItemType File -Value "Tag" -Force
    }

    # Quit
    Write-Host "Install complete, ExitCode: $($result)" -ForegroundColor Green
    Exit $result
}

function InstallEXE {
    # Install
    Write-Host EXE Installing $fileName...
    $result = (Start-Process "$installer" -ArgumentList $exeArgumentList -Verb RunAs -PassThru -Wait).ExitCode
    if (!($result -in $errorCodes)) {
        Write-Host "Install Failed, Try again"-ForegroundColor Red
        Stop-Transcript
        Exit $result
    }

    # PostInstall
    #creates tag file
    if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($fileName).tag")) {
        Write-Host Creating Tag file. -ForegroundColor Cyan
        New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($fileName).tag" -ItemType File -Value "Tag"
    }

    # Quit
    Write-Host "Install complete" -ForegroundColor Green
    Exit $result
}
#endregion

#region PreInstall
# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Cyan
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#Log setup
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}

Start-Transcript "$logDest\Transcripts\$fileName-install.log" -Append
#endregion

#region Exectue
if (($fileName.Substring($fileName.Length - 3) -eq "msi")) {
    InstallMSI 
}
elseif (($fileName.Substring($fileName.Length - 3) -eq "exe")) {
    InstallEXE
}
else {
    Write-Host "File type not valid installer, please try again" -ForegroundColor Red
    Stop-Transcript
}
#endregion