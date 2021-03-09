[CmdletBinding()]
param (
    $CMEdgeAppName = "Microsoft Edge Latest - Stable",
    $CMAppDeploymentType = "Edge X64 Default Deployment Type",
    $TempPath =  "D:\Staging",
    $Targetpath = "\\d00008\Sources\Apps\Microsoft Edge\Stable\81.0.416.64\X64\",
    $VersionsToKeep = 3
)

# Logging parameters
$LogParams =  @{
    FileName = $($MyInvocation.MyCommand.Name)
    LogFileName = "$($TempPath)\$($MyInvocation.MyCommand.Name.Replace(".ps1", ".log"))"
    Component = "PowerShellScript"
    LogSizeKB = 2048
}

function WriteLog {
    param(
    [Parameter(Mandatory)]
    [string]$LogText,
    $Component,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Info','Warning','Error','Verbose')]
    [string]$Type,
    [string]$LogFileName,
    [string]$FileName,
    [int]$LogSizeKB = 2048
    )

    switch ($Type)
    {
        "Info"      { $typeint = 1 }
        "Warning"   { $typeint = 2 }
        "Error"     { $typeint = 3 }
        "Verbose"   { $typeint = 4 }
    }

    $time = Get-Date -f "HH:mm:ss.ffffff"
    $date = Get-Date -f "MM-dd-yyyy"
    $ParsedLog = "<![LOG[$($LogText)]LOG]!><time=`"$($time)`" date=`"$($date)`" component=`"$($Component)`" context=`"`" type=`"$($typeint)`" thread=`"$($pid)`" file=`"$($FileName)`">"
    $ParsedLog | Out-File -FilePath "$LogFileName" -Append -Encoding utf8 -WhatIf:$false

    if ((Get-Item "$LogFileName").length / 1KB -gt $LogSizeKB) {
    $ext = [System.IO.Path]::GetExtension($LogFileName)
    Rename-Item -Path "$LogFileName" -NewName "$LogFileName".Replace("$ext", "$((Get-Date -Format "_yyyy_MM_dd_HH_mm_ss_fff"))$($ext)") -Force -ErrorAction SilentlyContinue -WhatIf:$false
    }
}

# Create Staging path
if (!(Test-Path -Path $TempPath)) {
    New-Item -Path $TempPath -Force -ItemType Directory | Out-Null
}

WriteLog "### Starting script ###" @LogParams -Type Info
# Download and Import Modules
Write-Host "Importing CM Module..."
WriteLog "Importing CM Module..." @LogParams -Type Info
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("bin\i386","bin\ConfigurationManager.psd1") -Force -ErrorAction Stop
if ($null -eq (Get-Module ConfigurationManager)) {
    Write-Host "Could not load the ConfigurationManager module, exiting script." -ForegroundColor Red
    WriteLog "Could not load the ConfigurationManager module, exiting script." @LogParams -Type Error
    Exit 1
}
if ($null -eq (Get-Module -Name Evergreen -ListAvailable)) {
    Write-Host "Evergreen module not found, attempting to install module" -ForegroundColor Yellow
    WriteLog "Evergreen module not found, attempting to install module" @LogParams -Type Warning
    Install-Module Evergreen -Force
}

Write-Host "Updating Evergreen module..."
WriteLog "Updating Evergreen module..." @LogParams -Type Info
Update-Module Evergreen -Force
Import-Module Evergreen


# Check for updated Edge version
Write-Host "Info: Checking for updated version of Edge"
$LatestEdge = (Get-MicrosoftEdge | Where-Object {$PSItem.Channel -eq "Stable" -and $PSItem.Architecture -eq "x64"})
$CurrentEdge = Get-ChildItem  $TempPath -Directory | Sort-Object {[version]$PSItem.Name} -Descending | Select-Object -First 1
if ($null -ne $CurrentEdge) {
    if ([version]$CurrentEdge.Name -eq [version]$LatestEdge.Version) {
        Write-Host "Edge is up-to-date, version [$($LatestEdge.Version)] already in $TempPath." -ForegroundColor Green
        Write-Host "Nothing to do, exiting script."
        WriteLog "Edge is up-to-date, version [$($LatestEdge.Version)] already in $TempPath." @LogParams -Type Info
        WriteLog "### Nothing to do, exiting script. ###" @LogParams -Type Info
        Exit 0
    } 
}

# Download & Update Edge
$StagingPath = Join-Path $TempPath $LatestEdge.Version
Write-host "Update is available. Downloading version [$($LatestEdge.Version)] to $StagingPath" -ForegroundColor Yellow
WriteLog "Update is available. Downloading version [$($LatestEdge.Version)] to $StagingPath" @LogParams -Type Info
New-Item -Path $StagingPath -ItemType Directory | Out-Null
Invoke-WebRequest $LatestEdge.URI -OutFile "$($StagingPath)\MicrosoftEdgeEnterpriseX64.msi"
Write-host "Attempting to update Edge version to [$($LatestEdge.Version)] from [$($CurrentEdge.Name)]"
WriteLog "Attempting to update Edge version to [$($LatestEdge.Version)] from [$($CurrentEdge.Name)]" @LogParams -Type Info
Write-host "Copying MicrosoftEdgeEnterpriseX64.msi to $Targetpath"
WriteLog "Copying MicrosoftEdgeEnterpriseX64.msi to $Targetpath" @LogParams -Type Info
Copy-Item -Path "Microsoft.PowerShell.Core\FileSystem::$StagingPath\MicrosoftEdgeEnterpriseX64.msi" -Destination "Microsoft.PowerShell.Core\FileSystem::$Targetpath" -Force
Write-host "Updating content on DPs for App: [$CMEdgeAppName] and DeploymentType: [$CMAppDeploymentType]"
WriteLog "Updating content on DPs for App: [$CMEdgeAppName] and DeploymentType: [$CMAppDeploymentType]" @LogParams -Type Info
Set-Location -LiteralPath "$((Get-PSDrive -PSProvider CMSite).Name):" -ErrorAction Stop
Update-CMDistributionPoint -ApplicationName $CMEdgeAppName -DeploymentTypeName $CMAppDeploymentType

# Delete old versions from staging path
Get-ChildItem  $TempPath -Directory | Sort-Object {[version]$PSItem.Name} -Descending | Select-Object -Skip $VersionsToKeep |
ForEach-Object {
    Write-Host "Deleting old version [$($PSItem.Name)] from staging path"
    WriteLog "Deleting old version [$($PSItem.Name)] from staging path" @LogParams -Type Info
    Remove-Item $PSItem.Fullname -Recurse -Force
}

Write-host "### Done, existing script. ###"
WriteLog "### Done, existing script. ###" @LogParams -Type Info
