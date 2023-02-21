<#
    .NOTES
    =============================================================================
    Author: j0shbl0ck https://github.com/j0shbl0ck
    Version: 1.0.1
    Date: 12.21.21
    Type: Public
    Source: 
    Description: Unistall SonicWallNetExtender without restart.
    =============================================================================
#>

#Removes NetExtender by Product code. Note, registry files will still be present due to no restart. Remove /norestart for complete removal and restart.
msiexec /x "{EF06A6A8-6B81-4A09-8223-789953972FFF}" /q /norestart