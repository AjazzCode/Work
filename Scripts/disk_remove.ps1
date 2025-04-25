# ☞ Безопасный очиститель дисков ☜

# Исключаемые системные папки и файлы
$excludedFoldersAndFiles = @(
    "${env:SystemRoot}*",                            # Windows
    "${env:ProgramFiles}*",                          # Program Files
    "${env:ProgramFiles(x86)}*",                     # Program Files x86
    "${env:USERPROFILE}*",                           # Пользовательские профили
    "${env:SYSTEMDRIVE}\System Volume Information*",
    "${env:SYSTEMDRIVE}\PerfLogs*",
    "${env:SYSTEMDRIVE}\ProgramData*",
    "${env:SYSTEMDRIVE}\pagefile.sys",
    "${env:SYSTEMDRIVE}\hiberfil.sys",
    "${env:SYSTEMDRIVE}\swapfile.sys"
)

# Получаем список всех доступных физических дисков
$physicalDisks = Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 3 | Select-Object Name

# Перебираем все доступные диски
foreach ($disk in $physicalDisks.Name) {
    Write-Host "Обрабатываю диск: $disk" -ForegroundColor Yellow

    # Получаем список файлов и папок на диске
    $filesAndFolders = Get-ChildItem -Path "$disk\" -Recurse -Force -ErrorAction SilentlyContinue

    # Перебираем каждый файл или папку
    foreach ($item in $filesAndFolders) {
        # Пропускаем системные и важные папки
        if ($excludedFoldersAndFiles | Where-Object { $item.FullName -like $_ }) {
            continue
        }

        # Проверяем и удаляем (включая папки с подкаталогами)
        try {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop -Confirm:$false
            Write-Host "Удалён объект: $($item.FullName)" -ForegroundColor Green
        } catch {
            Write-Warning "Ошибка при удалении объекта '$($item.FullName)': $($_.Exception.Message)"
        }
    }
}

Write-Host "Очистка завершена." -ForegroundColor Cyan
