<#
Software Remediation Script to update the software
Author: Chris Rockwell | chris@r-is.tech | chris.rockwell@insight.com
#>

#Variables

# Run upgrade of the software
winget.exe upgrade --all --silent --accept-package-agreements --include-unknown --accept-source-agreements