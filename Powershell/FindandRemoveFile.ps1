#ɾ��Ŀ¼�ڶ����ļ���Ŀ¼�ļ���������$count�󣬰�����޸�ʱ�䵹�����У�ɾ����ɵ��ļ���
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

#ɾ��Ŀ¼�������ļ��޸�ʱ�䳬��timeOutDay���ļ���
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