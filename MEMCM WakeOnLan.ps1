<#
    Script to use client notification to Wake up a single computer or a collection of computers.

    Written by Johan Schrewelius and Jörgen Nilsson

    2019-01-22 ccmexec.com
#>

[CmdletBinding()]
Param(
    $CmpName = $Null,
    $CollId = "SMS00001",
    $SiteServer = "<site server fgdn>"
)

if (!$CmpName -and $CollId -eq "SMS00001") {

    Write-Host "Seems wrong to wake every single computer in the environment, refusing to perform."
    exit 1
}

$SiteCode = (Get-WmiObject -ComputerName "$SiteServer" -Namespace root\sms -Query 'SELECT SiteCode FROM SMS_ProviderLocation').SiteCode

if ($CmpName) {

    $ResourceID = (Get-WmiObject  -ComputerName "$SiteServer" -Namespace "Root\SMS\Site_$($SiteCode)" -Query "Select ResourceID from SMS_R_System Where NetBiosName = '$($CmpName)'").ResourceID

    if ($ResourceID) {
        $CmpName = @($ResourceID)
    }
}

$WMIConnection = [WMICLASS]"\\$SiteServer\Root\SMS\Site_$($SiteCode):SMS_SleepServer"
$Params = $WMIConnection.psbase.GetMethodParameters("MachinesToWakeup")
$Params.MachineIDs = $CmpName
$Params.CollectionID  = $CollId
$return = $WMIConnection.psbase.InvokeMethod("MachinesToWakeup", $Params, $Null) 

if (!$return) {
    Write-Host "No machines are online to wake up selected devices"
}

if ($return.numsleepers -ge 1) {
    Write-Host "The resource selected are scheduled to wake-up as soon as possible"
}
