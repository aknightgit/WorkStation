#删除目录内多余文件，目录文件个数大于$count后，按最后修改时间倒序排列，删除最旧的文件。
$count = 3
$filePathList = "E:\MySql\1",
"E:\MySql\2",
"E:\MySql\3"

foreach($filePath in $filePathList)
{
    $files = Get-ChildItem -Path $filePath | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip $count
    if ($files.count -gt 0) {
        foreach($file in $files)
        {
            Remove-Item $file.FullName -Recurse -Force
        }
    }    
}

#删除目录内所有文件修改时间超过timeOutDay的文件。
$timeOutDay = 30
$filePath = "H:\DataBackup\File\1",
"H:\DataBackup\Database\2"

$allFile = Get-ChildItem -Path $filePath

foreach($file in $allFile)
{
    $daySpan = ((Get-Date) - $file.LastWriteTime).Days
    if ($daySpan -gt $timeOutDay)
    {
        Remove-Item $file.FullName -Recurse -Force
    }
}