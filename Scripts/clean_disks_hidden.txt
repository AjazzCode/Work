# Получаем список всех доступных физических дисков
$disks = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object DeviceID

# Список исключаемых папок и файлов
$excludedPaths = @(
    "^${env:SystemRoot}$",
    "^${env:ProgramFiles}$",
    "^${env:ProgramFiles(x86)}$",
    "^${env:USERPROFILE}$",
    "^${env:SYSTEMDRIVE}\\System Volume Information$",
    "^${env:SYSTEMDRIVE}\\PerfLogs$",
    "^${env:SYSTEMDRIVE}\\ProgramData$",
    "^${env:SYSTEMDRIVE}\\pagefile\.sys$",
    "^${env:SYSTEMDRIVE}\\hiberfil\.sys$",
    "^${env:SYSTEMDRIVE}\\swapfile\.sys$"
)

# Отключаем прогрессии
$ProgressPreference = 'SilentlyContinue'

# Перебор всех доступных дисков
foreach ($disk in $disks.DeviceID) {
    # Получаем список файлов и папок для удаления
    $itemsToDelete = Get-ChildItem -Path "$disk\" -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not ($excludedPaths | ForEach-Object { $_.Replace("\", "\\") }) -match ([regex]"^$($_.FullName)$")}

    foreach ($item in $itemsToDelete) {
        # Проверяем доступность объекта перед удалением
        if (Test-Path $item.FullName) {
            try {
                Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop -Confirm:$false
                Write-Host "Удалён объект '$($item.FullName)'" -ForegroundColor Green
            } catch {
                Write-Host "Ошибка при удалении объекта '$($item.FullName)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}
