param(
[string]$Folder=$(throw "Parameter missing: -Folder Folder") 
)

#$Folder = $args[0]
$server = "AKNIGHT\AK"
$dbname ="staging"
$fileformat = "*[\d][\d][\d][\d][\d][\d.txt"

$query ="truncate table dms.DimStockDaily_History
	go"
Invoke-Sqlcmd -Query $query -ServerInstance $server  -Database $dbname

echo "Staging table truncated!"
foreach($file in Get-ChildItem -Path $Folder -Filter *.txt|Where-object {$_.Basename -match '\w\w#\d{6}$'})
{
	#echo $file.name 
    
	$query ="
	BULK INSERT dms.[DimStockDaily_History]
	   FROM '"+$file.fullname+"'
	   WITH 
		  (
			 FIELDTERMINATOR ='|',
			 ROWTERMINATOR ='\n', 
			 FIRSTROW = 1
		  );"
	echo "Importing file : "$file.fullname   # 这里可以显示文件名，
	#echo $query
                                     
	Invoke-Sqlcmd -Query $query -ServerInstance $server  -Database $dbname
	write-host "File imported : "$file.fullname
	
}
#read-host

