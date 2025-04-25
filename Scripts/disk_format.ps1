# Получаем список дисков
$disks = Get-Disk | Where-Object { $_.PartitionStyle -ne 'RAW' }

foreach ($disk in $disks) {
    # Удаляем только некритические разделы
    Get-Partition -DiskNumber $disk.Number | Where-Object { -not ($_.IsBoot -or $_.IsSystem) } | Remove-Partition -Confirm:$false
    
    # Форматируем оставшиеся разделы
    Get-Partition -DiskNumber $disk.Number | New-Partition -UseMaximumSize -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "Formatted_$($disk.Number)" -Force
}
