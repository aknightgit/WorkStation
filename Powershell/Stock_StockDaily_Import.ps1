$server = "AKNIGHT\AK"
$dbname ="staging"


foreach($file in Get-ChildItem -Path C:\AK\Home\indir -Filter stockdaily* | Sort-Object name -Descending |Select-Object -First 1)
{
        
	$query ="truncate table dms.DimStockDaily
	go
	BULK INSERT dms.DimStockDaily
	   FROM '"+$file.fullname+"'
	   WITH 
		  (
			 FIELDTERMINATOR ='|',
			 ROWTERMINATOR ='\n', 
			 FIRSTROW = 1
		  );"
	echo "Importing file "$file.Fullname   # 这里可以显示文件名，
	echo $query
                                     
	Invoke-Sqlcmd -Query $query -ServerInstance $server  -Database $dbname
	write-host "File imported : "$file.fullname

}
#read-host

