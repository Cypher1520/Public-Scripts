<#
How to remove/shorted a variable to a specific #
#>

#$Variable1 = "0F00B4Y22403FB"
$Variable1 = "LR088AH4"
for ($Variable1; $Variable1.length -gt 11; $Variable1 = $Variable1.Remove(0,1)) {
    Write-host "Shortened" 
}

Write-Host "L11-$Variable1"




$SerialNum = "0F00B4Y22403FB"
$NamePrefix = "L11-"
# --------------------------------------------------------------------------------------
# Now, we will process the serial number.  If it exceeds 11 characters we trim
# it back TO 11 characters so that when the L-11 is added, the total characters = 15
# --------------------------------------------------------------------------------------
# For example, we want serialnumber to work itself down to 0B4Y22403FB
# --------------------------------------------------------------------------------------

write-host "Processing serial number $SerialNum..."
for ($SerialNum; $SerialNum.length -gt 11; $SerialNum = $SerialNum.Remove(0,1)){
    #write-host "Modified Serial: $SerialNum"
    #$SerialNum
}
Write-host "Processed Serial Number: $SerialNum"
$newName = $NamePrefix + $SerialNum
Write-Host "-----------------------------------------------------------"
Write-Host "New (Windows 11) Computer Name WILL BE: $newName"
Write-Host "-----------------------------------------------------------"