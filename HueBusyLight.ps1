function Find-HueBridge {
    try {
        #Find HUE BRIDGE IP
        $Result = Invoke-webRequest -Method 'GET' -Uri https://discovery.meethue.com/
        if($Result.StatusCode -eq 200) {
            $BridgeIP = ($Result.Content | ConvertFrom-Json).InternalIPAddress
            return $BridgeIP
        } else {
            Write-Host "Error: Received statuscode $($Result.StatusCode)"
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Check-HueBridge {
    PARAM(
        $bridgeIp
    )
    try {
        $Uri = "https://$bridgeIp/clip/v2/resource/device"
        $Result = Invoke-webRequest -Method 'GET' -Uri $Uri
        if($Result.StatusCode -eq 200) {
            $BridgeIP = ($Result.Content | ConvertFrom-Json).InternalIPAddress
            return $BridgeIP
        } else {
            Write-Host "Error: Received statuscode $($Result.StatusCode)"
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Activate-HueBusyLight {
    PARAM(

    )
}
