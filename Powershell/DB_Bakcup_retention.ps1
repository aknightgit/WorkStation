param(
[string]$DBName=$(throw "Parameter missing: -DBName DBName"),
[string]$BACKUP_FOLDER=$(throw "Parameter missing: -BACKUP_FOLDER BACKUP_FOLDER"),
[int]$KeepDays=$(throw "Parameter missing: -KeepDays KeepDays")
)


$server = "AKNIGHT\AK"
$initDB ="master"
$today = Get-Date
$date_suffix = $today.ToString('yyyyMMdd')

echo $DBName
echo $BACKUP_FOLDER
echo $date_suffix

$query = "BACKUP DATABASE [$DBName] 
TO  DISK = N'$BACKUP_FOLDER\${DBName}_$date_suffix.bak' WITH NOFORMAT, 
NOINIT,  
NAME = N'$DBName-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  
STATS = 10
GO"
echo $query

Invoke-Sqlcmd -Query $query -ServerInstance $server  -Database $initDB

$allFile = Get-ChildItem -Path $BACKUP_FOLDER

#move files older than $timeoutday to bkpdir
foreach($file in $allFile)
{
    $daySpan = ((Get-Date) - $file.LastWriteTime).Days
    if ($daySpan -gt $KeepDays)
    {
        #Remove-Item $file.FullName -Recurse -Force
		write-host "Deleting "$file.fullname"..."
		Remove-Item $file.fullname 
    }
}

write-host "Old backup files (> $KeepDays days) files removed!"
#read-host