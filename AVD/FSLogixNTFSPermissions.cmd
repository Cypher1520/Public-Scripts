::Set the target fileshare location
set /p STA= Storage Account location:

:: Creates Subfolders if not exist
if not exist %STA%\Profiles mkdir %STA%\Profiles
if not exist %STA%\O365 mkdir %STA%\O365

::Top Level
icacls %STA% /inheritance:d
icacls %STA% /grant:r "NETWORK\RG-VDI-Admins":(OI)(CI)(F)
icacls %STA% /remove:g "Authenticated Users"
icacls %STA% /grant:r "Authenticated Users":(M)
icacls %STA% /remove:g "SYSTEM"
icacls %STA% /remove:g "Users"
icacls %STA% /remove:g "CREATOR OWNER"

::O365
icacls %STA%\O365 /inheritance:d
icacls %STA%\O365 /grant:r "CREATOR OWNER":(OI)(CI)(IO)(M)
icacls %STA%\O365 /grant:r "Authenticated Users":(M)

::Profiles
icacls %STA%\Profiles /inheritance:d
icacls %STA%\Profiles /grant:r "CREATOR OWNER":(OI)(CI)(IO)(M)
icacls %STA%\Profiles /grant:r "Authenticated Users":(M)