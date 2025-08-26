<#
    .NOTES
        Author: Chris Rockwell
        Email: chris@r-is.tech | chris.rockwell@insight.com

    .DESCRIPTION
        Custom detection script for chocolatey apps

    .EXAMPLE
        Change App name in line 14 and upload this script as the custom detection script.
#>

#Variables
$app = "$null"

#Detection Test
$localprograms = choco list
if ($localprograms -like "*$app*") {
    Write-Host "Found $app" 
    Return 0 
    Exit 0
}