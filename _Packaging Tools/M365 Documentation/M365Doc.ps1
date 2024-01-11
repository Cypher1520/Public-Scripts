Install-Module MSAL.PS
Install-Module PSWriteWord
Install-Module M365Documentation

# Connect to your tenant
Connect-M365Doc

# Collect information for component Intune as an example 
$doc = Get-M365Doc -Components Intune <#-ExcludeSections "MobileAppDetailed"#>

# Output the documentation to a Word file
$doc | Write-M365DocWord -FullDocumentationPath "c:\temp\$($doc.CreationDate.ToString("yyyyMMddHHmm"))-WPNinjas-Doc.docx"
