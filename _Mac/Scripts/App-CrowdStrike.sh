#ID/Secret found in the CS console
#Support resources > API Client/id > setup new

#!/bin/bash
exec > "/var/log/intune.log" 2>&1

# Configuration - Add this before uploading
CLIENT_ID=""
CLIENT_SECRET=""
CS_CCID="BBB6ECDE3B9E4365996210D695C80B29-D2"
CS_INSTALL_TOKEN=
BASE_URL="https://api.crowdstrike.com"
GROUP_TAG="Nutrawise"


get_access_token() {
    json=$(curl -s -X POST -d "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}" ${BASE_URL}/oauth2/token)
    echo "function run() { let result = JSON.parse(\`$json\`); return result.access_token; }" | osascript -l JavaScript
}

get_sha256() {
    json=$(curl -s -H "Authorization: Bearer ${1}" ${BASE_URL}/sensors/combined/installers/v1\?filter=platform%3A%22mac%22)
    echo "function run() { let result = JSON.parse(\`$json\`); return result.resources[0].sha256; }" | osascript -l JavaScript
}

if [ ! -x "/Applications/Falcon.app/Contents/Resources/falconctl" ] || [ -z "$(/Applications/Falcon.app/Contents/Resources/falconctl stats | grep 'Sensor operational: true')" ]; then
    APITOKEN=$(get_access_token)
    FALCON_LATEST_SHA256=$(get_sha256 "${APITOKEN}")
    curl -o /tmp/FalconSensorMacOS.pkg -s -H "Authorization: Bearer ${APITOKEN}" ${BASE_URL}/sensors/entities/download-installer/v1?id=${FALCON_LATEST_SHA256}
    installer -package /tmp/FalconSensorMacOS.pkg -target /
    rm /tmp/FalconSensorMacOS.pkg
    /Applications/Falcon.app/Contents/Resources/falconctl license ${CS_CCID} ${CS_INSTALL_TOKEN} || true 
    /Applications/Falcon.app/Contents/Resources/falconctl grouping-tags set ${GROUP_TAG}
else
    echo "Crowdstrike Falcon is installed and operational"
    exit 0
fi
