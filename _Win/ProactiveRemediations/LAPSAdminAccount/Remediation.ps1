<#
==================================================

Script Name:     Remediation-Account.ps1
Description:     Checks for LAPSAdmin account for Windows LAPS Management
Notes:           Customize the script by editing Variable for admin account name.

==================================================
#>

# Define Variables
$localAdminName = "Harry"
$minimumPasswordLength = 24

# Define Fucntions
function Get-RandomCharacters($length, $characters) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    $private:ofs = "" 
    return [String]$characters[$random]
}

function Get-NewPassword($passwordLength) {
    #minimum 10 characters will always be returned
    $password = Get-RandomCharacters -length ([Math]::Max($passwordLength - 6, 4)) -characters 'abcdefghiklmnoprstuvwxyz'
    $password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
    $password += Get-RandomCharacters -length 2 -characters '1234567890'
    $password += Get-RandomCharacters -length 2 -characters '!_%&/()=?}][{#*+'
    $characterArray = $password.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

#=============Script Body=============
try {
    $newPwd = Get-NewPassword $minimumPasswordLength
    $newPwdSecStr = $newPwd | ConvertTo-SecureString -AsPlainText -Force
    $pwdSet = $True
    $localAdmin = New-LocalUser -PasswordNeverExpires -AccountNeverExpires -Name $localAdminName -Password $newPwdSecStr
    Write-CustomEventLog "$localAdminName created"
    Enable-LocalUser -Name $localAdminName

    exit 0
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}