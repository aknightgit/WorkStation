USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC dbo.SP_Move_From_FU_To_ODS
@Table_Name NVARCHAR(50),
@Source NVARCHAR(50)
AS
BEGIN



DECLARE @Schema NVARCHAR(50)
DECLARE @TableName NVARCHAR(50)
DECLARE @File_NM NVARCHAR(50)
DECLARE @QUERY NVARCHAR(4000)

SET @Table_Name = REPLACE(@Table_Name,']','')
SET @Table_Name = REPLACE(@Table_Name,'[','')
SET @Schema = LEFT(@Table_Name,CHARINDEX('.',@Table_Name)-1)
SET @TableName = REPLACE(@Table_Name,@Schema+'.','')
SET @File_NM = 'ODS.ods.'+@Source+REPLACE(@TableName,'T_ODS','')+'.File_NM'

IF @Schema = 'FU_ODS'
BEGIN
	IF OBJECT_ID(N'ODS.ods.'+@Source+REPLACE(@TableName,'T_ODS','')) IS NOT NULL AND OBJECT_ID(N'Foodunion'+'.'+@Table_Name) IS NOT NULL
		BEGIN
		SET @QUERY = 'DROP TABLE '+'ODS.ods.'+@Source+REPLACE(@TableName,'T_ODS','')
		EXEC(@QUERY)
	END
	SET @QUERY = 'SELECT * INTO ODS.ods.'+@Source+REPLACE(@TableName,'T_ODS','')+' FROM Foodunion.'+@Table_Name
	EXEC (@QUERY)

	EXEC sp_rename @File_NM,'Load_Source'
END

IF @Schema = 'FU_STG'
BEGIN
	IF OBJECT_ID(N'ODS'+'.'+REPLACE(@Table_Name,'FU_STG','stg')) IS NOT NULL AND OBJECT_ID(N'Foodunion'+'.'+@Table_Name) IS NOT NULL
		BEGIN
		SET @QUERY = 'DROP TABLE '+REPLACE(@Table_Name,'FU_STG','stg')
		EXEC(@QUERY)
	END
END

END


GO
