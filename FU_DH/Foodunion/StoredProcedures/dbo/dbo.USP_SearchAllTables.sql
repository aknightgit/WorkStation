USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[USP_SearchAllTables] 
(
	@SearchStr nvarchar(100)
	,@TableName nvarchar(256) = NULL  --if null, then search in all table
)
AS
BEGIN

	--dbo.USP_SearchAllTables N'付款后15天内',N'[stg].[OMS_Order_Info]'

	SET NOCOUNT ON;
	DROP TABLE IF EXISTS #Results;
	CREATE TABLE #Results (ColumnName nvarchar(370), ColumnValue nvarchar(3630));	

	DECLARE @ColumnName nvarchar(128), @SearchStr2 nvarchar(110);
	--SET  @TableName = ''
	SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''');

	IF @TableName IS NOT NULL 
	BEGIN
		SET @ColumnName = ''
		WHILE (@ColumnName IS NOT NULL)
			BEGIN
				SET @ColumnName =
				(
					SELECT MIN(QUOTENAME(COLUMN_NAME))
					FROM    INFORMATION_SCHEMA.COLUMNS
					WHERE       TABLE_SCHEMA    = PARSENAME(@TableName, 2)
						AND TABLE_NAME  = PARSENAME(@TableName, 1)
						AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
						AND QUOTENAME(COLUMN_NAME) > @ColumnName
				)
				PRINT @ColumnName
				PRINT @TableName
				print @SearchStr2

				--PRINT 'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
				--		FROM ' + @TableName + ' (NOLOCK) ' +
				--		' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2

				IF @ColumnName IS NOT NULL
				BEGIN
					INSERT INTO #Results
					EXEC
					(
						'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
						FROM ' + @TableName + ' (NOLOCK) ' +
						' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
					)
				END
			END 
	END
	ELSE
	BEGIN	
		SET @TableName = ''
		WHILE @TableName IS NOT NULL
		BEGIN
			SET @ColumnName = ''
			SET @TableName = 
			(
				SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
				FROM    INFORMATION_SCHEMA.TABLES
				WHERE       TABLE_TYPE = 'BASE TABLE'
					AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
					AND OBJECTPROPERTY(
							OBJECT_ID(
								QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
								 ), 'IsMSShipped'
								   ) = 0
			)

			WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
			BEGIN
				SET @ColumnName =
				(
					SELECT MIN(QUOTENAME(COLUMN_NAME))
					FROM    INFORMATION_SCHEMA.COLUMNS
					WHERE       TABLE_SCHEMA    = PARSENAME(@TableName, 2)
						AND TABLE_NAME  = PARSENAME(@TableName, 1)
						AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
						AND QUOTENAME(COLUMN_NAME) > @ColumnName
				)

				IF @ColumnName IS NOT NULL
				BEGIN
					INSERT INTO #Results
					EXEC
					(
						'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
						FROM ' + @TableName + ' (NOLOCK) ' +
						' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
					)
				END
			END 
		END

	END

SELECT ColumnName, ColumnValue FROM #Results

END
GO
