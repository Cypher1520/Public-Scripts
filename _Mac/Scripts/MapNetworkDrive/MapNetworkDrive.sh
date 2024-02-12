#!/bin/bash
#set -x
# remove the previous line if you want to run the script line by line.
# in terminal type: bash -x scriptname

# NOTES

#Source: https://allthingscloud.blog/deploy-network-drive-mappings-on-macos-with-microsoft-intune/
# original script can be found at: https://github.com/microsoft/shell-intune-samples/blob/master/macOS/Config/Dock/addAppstoDock.sh
# original script will also add apps to dock.This script will only add network shares to the dock 

# SCRIPT VERSION/HISTORY:
# 15-11-2023 - Oktay Sari - original script downsized to only deploy network shares without anything extra
# 16-11-2023 - Oktay Sari - script restored with original functions and checks. Only part that adds apps to the dock is removed. This script will only add network shares to the dock 

# ROADMAP/WISHLIST:
# 1: Update icons for (smb shares) shortcuts to custom icons

# Requirements:
# MDM to deploy script
# to access on-premise network shares, you will have to configure a VPN on your modern workplace.


# [Removed the original script header]

# Define variables
log="$HOME/addNetworkSharesToDock.log"
appname="Dock"
startCompanyPortalifADE="true"
secondsToWaitForOtherApps=1800

exec &> >(tee -a "$log")

if [[ -f "$HOME/Library/Logs/prepareDock" ]]; then

  echo "$(date) | Script has already run, nothing to do"
  exit 0

fi

# define your network shares here
netshares=(   "smb://192.168.0.12/Data"
              "smb://192.168.0.12/Home"
              "smb://192.168.0.12/Tools")

echo ""
echo "##"
echo "# $(date) | Start configuration of $appname"
echo "##"
echo ""

# Function to update Swift dialog
function updateSplashScreen () {

    #######################################################################################
    #######################################################################################
    ##
    ##  This function is designed to update the Splash Screen status (if required)
    ##
    #######################################################################################
    #######################################################################################


    # Is Swift Dialog present
    if [[ -a "/Library/Application Support/Dialog/Dialog.app/Contents/MacOS/Dialog" ]]; then


        echo "$(date) | Updating Swift Dialog monitor for [$appname] to [$1]"
        echo listitem: title: $appname, status: $1, statustext: $2 >> /var/tmp/dialog.log 

        # Supported status: wait, success, fail, error, pending or progress:xx

    fi

}

# function to delay until the user has finished setup assistant.
waitForDesktop () {
  until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Dock not running, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Dock is here, lets carry on"
}

waitForDesktop

START=$(date +%s) # define loop start time so we can timeout gracefully
echo "$(date) | Have a break...have a coffee...we are getting things ready..."

  # If we've waited for too long, we should just carry on
  if [[ $(($(date +%s) - $START)) -ge $secondsToWaitForOtherApps ]]; then
      echo "$(date) | Waited for [$secondsToWaitForOtherApps] seconds, continuing anyway]"
  fi    

  updateSplashScreen wait "Adding Network Shares to Dock"

# Add only network shares to Dock using defaults
if [[ "$netshares" ]]; then
  echo "$(date) |  Adding Network Shares to Dock"
  for j in "${netshares[@]}"; do
      label="$(basename $j)"
      echo "$(date) |  Adding [$j][$label] to Dock"    
      defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>label</key><string>$label</string><key>url</key><dict><key>_CFURLString</key><string>$j</string><key>_CFURLStringType</key><integer>15</integer></dict></dict><key>tile-type</key><string>url-tile</string></dict>"
      updateSplashScreen wait "Adding $j to Dock"
  done
fi

# Configure other Dock settings

echo "$(date) | Enabling Magnification"
defaults write com.apple.dock magnification -boolean YES
defaults write com.apple.dock largesize -int 50

echo "$(date) | Enable Dim Hidden Apps in Dock"
defaults write com.apple.dock showhidden -bool true

echo "$(date) | Disable show recent items"
defaults write com.apple.dock show-recents -bool FALSE

echo "$(date) | Enable Minimise Icons into Dock Icons"
defaults write com.apple.dock minimize-to-application -bool yes

echo "$(date) | Restarting Dock"
killall Dock

echo "$(date) | Writng completion lock to [~/Library/Logs/prepareDock]"
touch "$HOME/Library/Logs/prepareDock"

updateSplashScreen success Installed

# If this is an ADE enrolled device (DEP) we should launch the Company Portal for the end user to complete registration
if [ "$startCompanyPortalifADE" = true ]; then
  echo "$(date) | Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [ ! $? == 0 ]; then
    echo "$(date) | This device is not ABM managed, exiting"
    exit 0;
  else
    echo "$(date) | Device is ABM Managed. launching Company Portal"
    open "/Applications/Company Portal.app"
  fi
fi