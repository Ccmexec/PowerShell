[CmdletBinding()]
Param(
    [string]$MachineName,
    [string]$AppName
  )
 
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
$SiteCode = (Get-WmiObject -Namespace root\sms -Query 'SELECT SiteCode FROM SMS_ProviderLocation').SiteCode
Set-Location "$($SiteCode):"
$NameSpace ="ROOT\SMS\site_$($SiteCode)"
 
$AppID = (Get-CMApplication -Name "$AppName").ModelName
$SMSID = (Get-CMDevice -Name "$MachineName").SMSID
 
$reqObj = Get-WmiObject -Namespace $NameSpace -Class SMS_UserApplicationRequest | Where {$_.ModelName -eq $AppID -and $_.RequestedMachine -eq $MachineName}
$reqObjPath = $reqObj.__PATH
 
Invoke-WmiMethod -Path $reqObjPath -Name RetryInstall