param(
[int]$timeOutDay=$(throw "Parameter missing: -timeOutDay timeOutDay") 
)


$timeOutDay = $args[1]
$filePath = "C:\AK\Home\indir",
"C:\AK\Home\logdir"

$backup_path = "C:\AK\Home\bkpdir"

$allFile = Get-ChildItem -Path $filePath

#move files older than $timeoutday to bkpdir
foreach($file in $allFile)
{
    $daySpan = ((Get-Date) - $file.LastWriteTime).Days
    if ($daySpan -gt $timeOutDay)
    {
        #Remove-Item $file.FullName -Recurse -Force
		write-host "Moving file "$file.fullname" to $backup_path..."
		Move-Item $file.fullname $backup_path
    }
}

write-host "All files moved to '$backup_path'"
#read-host