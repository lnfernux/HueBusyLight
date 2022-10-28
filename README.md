🚨🚨🚨 HueBusyLight

Show when you're busy (or not) using Hue Lights.

## Setup

1. Dot source the script

```powershell
. ./HueBusyLight.ps1
```

2. Run the following command to find the Hue Bridge IP

```powershell
$bridgeIp = Find-HueBridge
```

3. Run the following command to connect to the Hue Bridge

```powershell
$connectionInfo = Connect-HueBridge -bridgeIp $bridgeIp
```

## Usage

### Finding Hue resources

Run the following command to find all Hue resources:

```powershell
$hueInformation = Get-HueInformation -bridgeIp $bridgeIp -appkey $connectionInfo.Username
```

This should return a hashtable with all the lights:

```
Name                           Value
----                           -----
Light8                         {RID, Type, Description}
Light6                         {RID, Type, Description}
Light9                         {RID, Type, Description}
Light3                         {RID, Type, Description}
Light7                         {RID, Type, Description}
Light1                         {RID, Type, Description}
Light5                         {RID, Type, Description}
Light2                         {RID, Type, Description}
Light4                         {RID, Type, Description}
```

Looking at a single light, we can find information about it and the ID:

```powershell
PS > $hueInformation.Light2

Name                           Value
----                           -----
RID                            50908fda-xxxx-xxxx-b5c5-18a79924f540
Type                           classic_bulb
Description                    Hue color lamp 2
```

### Activate BusyLight

```powershell
Activate-HueBusyLight -bridgeIp $bridgeIp -appkey $appkey -busyMinutes 1
```

After X minutes it will turn green, using the `Activate-HueNotBusyLight`-function.

### Other functions

The following functions perform simple tasks in the module:

1. `Enable-HueLight` - turns of a light with id
2. `Disable-HueLight` - same as above, just other way around
3. `Change-HueLightColor` - change the color [using X and Y values](https://www.enigmaticdevices.com/philips-hue-lights-popular-xy-color-values/) (value provided as decimal, 0.123 for instance)
4. `Change-HueBrightness` - changes the brightness of a hue bulb from 0-100 (value provided in INT)
