CREATE TABLE dbo.DimStock(
	ID INT IDENTITY(1,1),
	StockCode VARCHAR(50) NOT NULL,
	StockName NVARCHAR(50) NOT NULL
	)

CREATE TABLE dbo.DimStockDetail(
	StockID INT NOT NULL,
	
	StockBeginDate INT,
	StockEndDate INT
	)
