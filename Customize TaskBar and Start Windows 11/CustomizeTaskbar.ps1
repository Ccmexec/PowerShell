<#
    Customize Taskbar in Windows 11
    Sassan Fanai / Jörgen Nilsson
    Version 1.0 
#>

param (
    [switch]$RemoveTaskView,
    [switch]$RemoveWidgets,
    [switch]$RemoveChat,
    [switch]$MoveStartLeft,
    [switch]$RemoveSearch,    
    [switch]$StartMorePins,
    [switch]$StartMoreRecommendations,
    [switch]$RunForExistingUsers
)

[string]$RegValueName = "CustomizeTaskbar"
[string]$FullRegKeyName = "HKLM:\SOFTWARE\ccmexec\" 

# Create registry value if it doesn't exist
If (!(Test-Path $FullRegKeyName)) {
    New-Item -Path $FullRegKeyName -type Directory -force 
    }

New-itemproperty $FullRegKeyName -Name $RegValueName -Value "1" -Type STRING -Force

REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT

switch ($PSBoundParameters.Keys) {
    # Removes Task View from the Taskbar
    'RemoveTaskView' {
        Write-Host "Attempting to run: $PSItem"
        $reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}

    }
    # Removes Widgets from the Taskbar
    'RemoveWidgets' {
        Write-Host "Attempting to run: $PSItem"
        $reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}
    }
    # Removes Chat from the Taskbar
    'RemoveChat' {
        Write-Host "Attempting to run: $PSItem"
        $reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}
    }
    # Default StartMenu alignment 0=Left
    'MoveStartLeft' {
        Write-Host "Attempting to run: $PSItem"
        $reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}
    }
    # Default StartMenu pins layout 0=Default, 1=More Pins, 2=More Recommendations (requires Windows 11 22H2)
    'StartMorePins' {
        Write-Host "Attempting to run: $PSItem"
        $reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value "1" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}
    }
    # Default StartMenu pins layout 0=Default, 1=More Pins, 2=More Recommendations (requires Windows 11 22H2)
    'StartMoreRecommendations' {
        Write-Host "Attempting to run: $PSItem"
        $reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value "2" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}

    }    # Removes search from the Taskbar
    'RemoveSearch' {
        Write-Host "Attempting to run: $PSItem"
        $RegKey = "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Search"
        if (-not(Test-Path $RegKey )) {
            $reg = New-Item $RegKey -Force | Out-Null
            try { $reg.Handle.Close() } catch {}
        }
        $reg = New-ItemProperty $RegKey -Name "SearchboxTaskbarMode"  -Value "0" -PropertyType Dword -Force
        try { $reg.Handle.Close() } catch {}
    }
    Default { 'No parameters were specified' }
}
[GC]::Collect()
REG UNLOAD HKLM\Default

if ($PSBoundParameters.ContainsKey('RunForExistingUsers')) {
    Write-Host "RunForExistingUsers parameter specified."
    $UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" |
    Where-Object { $_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } |
    Select-Object @{Name = "SID"; Expression = { $_.PSChildName } }, @{Name = "UserHive"; Expression = { "$($_.ProfileImagePath)\NTuser.dat" } }

    # Loop through each profile on the machine
    foreach ($UserProfile in $UserProfiles) {
        Write-Host "Running for profile: $($UserProfile.UserHive)"
        # Load User NTUser.dat if it's not already loaded
        if (($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)) -eq $false) {
            Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$($UserProfile.SID) $($UserProfile.UserHive)" -Wait -WindowStyle Hidden
        }
        switch ($PSBoundParameters.Keys) {
            # Removes Task View from the Taskbar
            'RemoveTaskView' {
                Write-Host "Attempting to run: $PSItem"
                $reg = New-ItemProperty "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}

            }
            # Removes Widgets from the Taskbar
            'RemoveWidgets' {
                Write-Host "Attempting to run: $PSItem"
                $reg = New-ItemProperty "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}
            }
            # Removes Chat from the Taskbar
            'RemoveChat' {
                Write-Host "Attempting to run: $PSItem"
                $reg = New-ItemProperty "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}
            }
            # Default StartMenu alignment 0=Left
            'MoveStartLeft' {
                Write-Host "Attempting to run: $PSItem"
                $reg = New-ItemProperty "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}
            }
            # Default StartMenu pins layout 0=Default, 1=More Pins, 2=More Recommendations (requires Windows 11 22H2)
            'StartMorePins' {
                Write-Host "Attempting to run: $PSItem"
                $reg = New-ItemProperty "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value "1" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}
            }
            # Default StartMenu pins layout 0=Default, 1=More Pins, 2=More Recommendations (requires Windows 11 22H2)
            'StartMoreRecommendations' {
                Write-Host "Attempting to run: $PSItem"
                $reg = New-ItemProperty "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value "2" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}
            }
            # Removes search from the Taskbar
            'RemoveSearch' {
                Write-Host "Attempting to run: $PSItem"
                $RegKey = "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Search"
                if (-not(Test-Path $RegKey )) {
                    $reg = New-Item $RegKey -Force | Out-Null
                    try { $reg.Handle.Close() } catch {}
                }
                $reg = New-ItemProperty $RegKey -Name "SearchboxTaskbarMode"  -Value "0" -PropertyType Dword -Force
                try { $reg.Handle.Close() } catch {}
            }
            Default { 'No parameters were specified' }
        }
        # Unload NTUser.dat
        if ($ProfileWasLoaded -eq $false) {
            [GC]::Collect()
            Start-Sleep 1
            Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$($UserProfile.SID)" -Wait -WindowStyle Hidden
        }
    }
}
