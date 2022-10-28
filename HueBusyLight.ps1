function Find-HueBridge {
    try {
        #Find HUE BRIDGE IP
        $Result = Invoke-RestMethod -Method 'GET' -Uri https://discovery.meethue.com/
        if($Result.internalipaddress) {
            $BridgeIP = $Result.internalipaddress$Result.internalipaddress
            return $BridgeIP
        } else {
            Write-Host "Error: no Hue Bridge found"
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Connect-HueBridge {
    PARAM(
        $bridgeIp
    )
    try {
        $Uri = "https://$bridgeIp/api"
        $Body = '{"devicetype":"app_name#instance_name","generateclientkey":true}'
        do {
            $Result = Invoke-RestMethod -Method 'POST' -Uri $Uri -Body $Body -SkipCertificateCheck
            if($Result.Error.Type -eq 101 -and ($Result.Error.description -eq "link button not pressed")) {
                Read-Host "Please click the Hue Bridge button and then press enter"
            }
        }
        until ($Result.Success)
        Write-Host "Authentication OK!"
        $username = $Result.Success.username
        $clientKey = $Result.Success.clientkey
        $hash = @{"username" = $username;"clientkey" = $clientKey}
        return $hash
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Get-HueInformation {
    PARAM(
        $bridgeIp,
        $appkey
    )
    try {
        $Uri = "https://$bridgeIp/clip/v2/resource/device"
        $Headers = @{
            "hue-application-key" = $appkey
        }
        $Result = Invoke-RestMethod -Method 'GET' -Uri $Uri -Headers $Headers -SkipCertificateCheck

        # Split into lights and sensors
        $Lights = @{}
        foreach($light in $Result.Data) {
            if($light.id_v1 -match "/lights/*") {
                $hash = @{
                    "Light$($light.id_v1.Split("/")[-1])" = @{
                        "RID" = ($light.services | where-object {$_.rtype -eq "light"}).rid
                        "Description" = $light.metadata.name
                        "Type" = $light.metadata.archetype
                    }
                }
                Write-Host "Found $($light.metadata.archetype) named $($light.metadata.name) with RID $(($light.services | where-object {$_.rtype -eq "light"}).rid)"
                $Lights += $hash
            }
        }
        return $Lights
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Disable-HueLight {
    PARAM(
        $bridgeIp,
        $appkey,
        $lightId
    )
    try {
        $Uri = "https://$bridgeIp/clip/v2/resource/light/$lightId"
        $Headers = @{
            "hue-application-key" = $appkey
        }
        $Body = @"
        {
            "on": {
                "on": false
            }
        }
"@
            
    $Result = Invoke-RestMethod -Method 'PUT' -Uri $Uri -Headers $Headers -Body $Body -SkipCertificateCheck
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Enable-HueLight {
    PARAM(
        $bridgeIp,
        $appkey,
        $lightId
    )
    try {
        $Uri = "https://$bridgeIp/clip/v2/resource/light/$lightId"
        $Headers = @{
            "hue-application-key" = $appkey
        }
        $Body = @"
        {
            "on": {
                "on": true
            }
        }
"@
            
    $Result = Invoke-RestMethod -Method 'PUT' -Uri $Uri -Headers $Headers -Body $Body -SkipCertificateCheck
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Change-HueLightColor {
    # color values https://www.enigmaticdevices.com/philips-hue-lights-popular-xy-color-values/
    PARAM(
        $bridgeIp,
        $appkey,
        $lightId,
        $x,
        $y
    )
    try {
        $Uri = "https://$bridgeIp/clip/v2/resource/light/$lightId"
        $Headers = @{
            "hue-application-key" = $appkey
        }
        $Body = @"
        {
            "color": {
                "xy": {
                    "x": $x,
                    "y": $y
                }
            }
        }
"@
            
    $Result = Invoke-RestMethod -Method 'PUT' -Uri $Uri -Headers $Headers -Body $Body -SkipCertificateCheck
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Change-HueBrightness {
    PARAM(
        $bridgeIp,
        $appkey,
        $lightId,
        $brightnesspercent
    )
    try {
        $Uri = "https://$bridgeIp/clip/v2/resource/light/$lightId"
        $Headers = @{
            "hue-application-key" = $appkey
        }
        $Body = @"
        {
            "dimming": {
                "brightness": $brightnesspercent
            }
        }
"@
            
        $Result = Invoke-RestMethod -Method 'PUT' -Uri $Uri -Headers $Headers -Body $Body -SkipCertificateCheck
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Activate-HueNotBusyLight {
    PARAM(
        $bridgeIp,
        $appkey,
        $lightId
    )
    try {
        Enable-HueLight -bridgeIp $bridgeIp -appkey $appkey -lightId $lightId
        Change-HueBrightness -bridgeIp $bridgeIp -appkey $appkey -lightId $lightId -brightnesspercent 100
        Change-HueLightColor -bridgeIp $bridgeIp -appkey $appkey -lightId $lightId -x 0.4091 -y 0.518
    }
    catch {
        Write-Host "Error: $_"
    }
}
function Activate-HueBusyLight {
    PARAM(
        $bridgeIp,
        $appkey,
        $busyMinutes
    )
    try {
        Enable-HueLight -bridgeIp $bridgeIp -appkey $appkey -lightId "2256e1cc-ea9f-4d5f-8558-9b2c11d6d529"
        Change-HueBrightness -bridgeIp $bridgeIp -appkey $appkey -lightId "2256e1cc-ea9f-4d5f-8558-9b2c11d6d529" -brightnesspercent 100
        Change-HueLightColor -bridgeIp $bridgeIp -appkey $appkey -lightId "2256e1cc-ea9f-4d5f-8558-9b2c11d6d529" -x 0.6435 -y 0.3045
        Start-Sleep ($busyMinutes*60)
        Activate-HueNotBusyLight -bridgeIp $bridgeIp -appkey $appkey
    }
    catch {
        Write-Host "Error: $_"
    }
}
