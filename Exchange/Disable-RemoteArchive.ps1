# Copyright (c) 2016 Microsoft Corporation. All rights reserved.
#
# THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK
# OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
# This script sets msExchRemoteRecipientType of the user and store msExchArchiveGUID in msExchDisabledArchiveGUID. Then the attributes will get synced to cloud and ForwardSync will disable the archive for the user.
#
Param 
(
    [Parameter(Mandatory=$true)]
    [string] $Identity
)

# Get the ADObject.
function TryGetADObject($identity, [ref]$user)
{
    $domainName = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName;
    $ldapBindString = "LDAP://{0}/RootDse" -f $domainName;
    $rootDse = New-Object System.DirectoryServices.DirectoryEntry($ldapBindString);
    $defaultNamingContext = [string] $rootDse.Properties["defaultNamingContext"];
    $rootDse.Dispose();

    $ldapQueryBindString = "LDAP://{0}/{1}" -f $domainName, $defaultNamingContext;
    $searchRoot = New-Object System.DirectoryServices.DirectoryEntry($ldapQueryBindString)
    $searcher = New-Object System.DirectoryServices.DirectorySearcher;
    $searcher.SearchRoot = $searchRoot;
    $searcher.Filter = "(samaccountname=$identity)";
    $searcher.SearchScope = [System.DirectoryServices.SearchScope]::Subtree;
    $result = $searcher.FindAll();

    if ($result.Count -eq 1)
    {
        $user.Value = New-Object System.DirectoryServices.DirectoryEntry($result[0].Path);
    }
    else
    {
        if ($result.Count -eq 0)
        {
            Write-Error "Could not find AD Object with name=($identity)."
        }
        else
        {
            Write-Error "More than one AD Object with name=($identity) are found."
        }

        $searcher.Dispose();
        return $false;
    }

    $searcher.Dispose();
    return $true;
}

# msExRemoteRecipientType is a COMObject, which is a large integer.
function GetRemoteRecipientTypeValue($largeInteger)
{
    $highPart = $largeInteger.GetType().InvokeMember("HighPart", "GetProperty", $null, $largeInteger, $null);
    $lowPart  = $largeInteger.GetType().InvokeMember("LowPart", "GetProperty", $null, $largeInteger, $null);
    $bytes = [System.BitConverter]::GetBytes($highPart);
    $tmp = [System.Byte[]]@(0, 0, 0, 0, 0, 0, 0, 0);
    [System.Array]::Copy($bytes, 0, $tmp, 4, 4);
    $highPart = [System.BitConverter]::ToInt64($tmp, 0);
    $bytes = [System.BitConverter]::GetBytes($lowPart);
    $lowPart = [System.BitConverter]::ToUInt32($bytes, 0);
    return $lowPart + $highPart;
}

# Set msExRemoteRecipientType.
function SetRemoteRecipientTypeValue([System.DirectoryServices.DirectoryEntry]$user, [UInt64]$value)
{
    $byteArray = [System.BitConverter]::GetBytes($value);
    $highPart = [System.BitConverter]::ToInt32($byteArray, 4);
    $lowPart = [System.BitConverter]::ToInt32($byteArray, 0);
    $largeInteger = new-object -ComObject LargeInteger;
    [Void] $largeInteger.GetType().InvokeMember("HighPart", "SetProperty", $null, $largeInteger, $highPart);
    [Void] $largeInteger.GetType().InvokeMember("LowPart", "SetProperty", $null, $largeInteger, $lowPart);
    $user.msExchRemoteRecipientType.Value = $largeInteger;
}

$PROVISIONARCHIVE = 0x2;
$DEPROVISIONARCHIVE= 0x10;

Import-Module ActiveDirectory;
$user = New-Object PSObject;

if (!(TryGetADObject -identity $Identity -user ([ref]$user)))
{
    return;
}

if ($user.msExchRemoteRecipientType -ne $null)
{
    $userRemoteRecipientType = GetRemoteRecipientTypeValue -largeInteger ($user.msExchRemoteRecipientType.Value);
}

if (($userRemoteRecipientType -band $DEPROVISIONARCHIVE) -eq $DEPROVISIONARCHIVE)
{
    Write-Error "Archive for this user is already disabled.";
    return;
}

try
{
    # Put msExchArchiveGUID in msExchDisabledArchiveGUID.
    if (($user.msExchArchiveGUID.Value -ne $null) -and ((New-Object System.Guid (,([Byte[]]($user.msExchArchiveGUID.Value)))).Guid -ne [Guid]::Empty))
    {
        $user.msExchDisabledArchiveGuid.Value = $user.msExchArchiveGUID.Value;
    }

    $user.msExchArchiveName.Value = $null;
    $user.msExchArchiveGUID.Value = $null;
    $userRemoteRecipientType = ($userRemoteRecipientType -band (-bnot $PROVISIONARCHIVE)) -bor $DEPROVISIONARCHIVE;
    SetRemoteRecipientTypeValue -user $user -value $userRemoteRecipientType;
    $user.CommitChanges();
}
catch 
{
    Write-Error "Errors encountered when trying to write to ADObject $UserName. Exception: $($_.Exception.Message)";
}
finally
{
    $user.Dispose();
}