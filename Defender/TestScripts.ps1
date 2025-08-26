"ForceDefenderPassiveMode: " + (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection").ForceDefenderPassiveMode

"DisableAntiSpyware: " + (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender").DisableAntiSpyware

"DefenderSignaturesOutOfDate: " + (Get-MpComputerStatus).DefenderSignaturesOutOfDate

"QuickScanAge: " + (Get-MpComputerStatus).QuickScanAge
