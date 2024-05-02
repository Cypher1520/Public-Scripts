#Install Modules
$modules = @(
    "MSAL.PS"
    "PSWriteWord"
    "M365Documentation"
)
foreach ($m in $modules) {
    $ver = Find-Module $m
    $mver = (Get-ChildItem "C:\Program Files\WindowsPowerShell\Modules\$m").Name
    if (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\$m")) {
        W
        Install-Module $m -Force -Confirm:$false
    }
    elseif (!($mver -eq $ver.version)) {
        Install-Module $m -Force -Confirm:$false -AllowClobber
    }
}

# Connect to your tenant
Connect-M365Doc

# Collect information for component Intune as an example 
$doc = Get-M365Doc -Components Intune -ExcludeSections "MobileAppDetailed"

# Output the documentation to a Word file
$doc | Write-M365DocWord -FullDocumentationPath "c:\temp\$($doc.CreationDate.ToString("yyyyMMddHHmm"))-As-Built.docx"