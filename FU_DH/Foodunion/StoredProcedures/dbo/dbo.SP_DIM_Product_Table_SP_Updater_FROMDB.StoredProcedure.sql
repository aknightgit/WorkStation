USE [Foodunion]
GO
DROP PROCEDURE [dbo].[SP_DIM_Product_Table_SP_Updater_FROMDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 

CREATE   PROCEDURE [dbo].[SP_DIM_Product_Table_SP_Updater_FROMDB] 
@STG_Table_Name NVARCHAR(50),
@Key NVARCHAR(50)
AS 
BEGIN
DECLARE @Schema NVARCHAR(50)
DECLARE @TableName NVARCHAR(50)
DECLARE @QUERY NVARCHAR(4000)

SET @STG_Table_Name = @STG_Table_Name
SET @Key = @Key
SET @STG_Table_Name = REPLACE(@STG_Table_Name,']','')
SET @STG_Table_Name = REPLACE(@STG_Table_Name,'[','')
SET @Schema = LEFT(@STG_Table_Name,CHARINDEX('.',@STG_Table_Name)-1)
SET @TableName = REPLACE(@STG_Table_Name,@Schema+'.','')

--------------------------------ODS TABLE 
--删除现有ODS或EDW层表
IF OBJECT_ID(N'Foodunion'+'.'+REPLACE(@STG_Table_Name,'STG','ODS')) IS NOT NULL
BEGIN
SET @QUERY = 'DROP TABLE '+REPLACE(@STG_Table_Name,'STG','ODS')
EXEC(@QUERY)
END

--创建CREATE 语句
SET @QUERY='CREATE TABLE '+REPLACE(@STG_Table_Name,'STG','ODS') +'('

--获取STG表的每个字段名和类型和类型长度，作为ODS层或EDW层的字段名和格式
SELECT 
@QUERY+=
COL.[name]+' '+
CASE COL.[precision] 
WHEN 0  THEN 
CASE COL.[is_ansi_padded]
WHEN 1 THEN CONVERT(NVARCHAR(15),TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[max_length])+')') --字符
WHEN 0 THEN TP.name + '('+CONVERT(nvarchar(10),COL.[max_length])+')'  --字符
END 
ELSE
CASE COL.[scale] 
WHEN 0 THEN TP.[name] --整形
ELSE TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[precision])+','+CONVERT(NVARCHAR(10),COL.[scale])+')' --实数
END
END+','
FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
WHERE 
 COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
 COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

SET @QUERY+= 'Update_DTM datetime,Load_DTM datetime)'
SET @QUERY = REPLACE(@QUERY,'datetime(23,3)','datetime')
SET @QUERY = REPLACE(@QUERY,'xml(-1)','xml')
--执行create table语句
EXEC(@QUERY)



----------------------------------EDW TABLE 
----删除现有ODS或EDW层表
--IF OBJECT_ID(N'Foodunion'+'.'+REPLACE(@STG_Table_Name,'STG','EDW')) IS NOT NULL
--BEGIN
--SET @QUERY = 'DROP TABLE '+REPLACE(@STG_Table_Name,'STG','EDW')
--EXEC(@QUERY)
--END

----创建CREATE 语句
--SET @QUERY='CREATE TABLE '+REPLACE(@STG_Table_Name,'STG','EDW') +'('

----获取STG表的每个字段名和类型和类型长度，作为ODS层或EDW层的字段名和格式
--SELECT 
--@QUERY+=
--COL.[name]+' '+
--CASE COL.[precision] 
--WHEN 0  THEN 
--CASE COL.[is_ansi_padded]
--WHEN 1 THEN CONVERT(NVARCHAR(15),TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[max_length])+')') --字符
--WHEN 0 THEN TP.name + '('+CONVERT(nvarchar(10),COL.[max_length])+')'  --字符
--END 
--ELSE
--CASE COL.[scale] 
--WHEN 0 THEN TP.[name] --整形
--ELSE TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[precision])+','+CONVERT(NVARCHAR(10),COL.[scale])+')' --实数
--END
--END+','
--FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
--LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
--WHERE 
-- COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
-- COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

--SET @QUERY+= 'Update_DTM datetime)'

--SET @QUERY = REPLACE(@QUERY,'datetime(23,3)','datetime')
--SET @QUERY = REPLACE(@QUERY,'xml(-1)','xml')
----执行create table语句
--EXEC(@QUERY)


--------------------------------ODS PROC
--创建Create语句
SET @QUERY = 'CREATE OR ALTER PROCEDURE  [FU_ODS].[SP_UPINSERT_'+REPLACE(@TableName,'STG','ODS')+'] '+CHAR(13)+CHAR(10)+'AS ' +CHAR(13)+CHAR(10)+  'BEGIN '+CHAR(13)+CHAR(10)
SET @QUERY+='MERGE INTO '+REPLACE(@STG_Table_Name,'STG','ODS') +CHAR(13)+CHAR(10)
SET @QUERY+='AS T' +CHAR(13)+CHAR(10)
SET @QUERY+='USING(' +CHAR(13)+CHAR(10)
SET @QUERY+='SELECT' +CHAR(13)+CHAR(10)

--获取STG表的每个字段名和类型和类型长度，作为ODS层或EDW层的字段名和格式
SELECT 
@QUERY+=
COL.[name]+','+CHAR(13)+CHAR(10)
FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
WHERE 
COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

SET @QUERY+='[Load_DTM]' +CHAR(13)+CHAR(10)
SET @QUERY+='FROM(' +CHAR(13)+CHAR(10)
SET @QUERY+='SELECT' +CHAR(13)+CHAR(10)

SELECT 
@QUERY+=
COL.[name]+','+CHAR(13)+CHAR(10)
FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
WHERE 
 COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
 COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

SET @QUERY+='[Load_DTM],' +CHAR(13)+CHAR(10)
SET @QUERY+='ROW_NUMBER()over(Partition by '+@Key+' order by '+@Key+') rn' +CHAR(13)+CHAR(10)
SET @QUERY+='FROM '+@STG_Table_Name+' ) a' +CHAR(13)+CHAR(10)
SET @QUERY+='where rn =1' +CHAR(13)+CHAR(10)
SET @QUERY+=') AS S' +CHAR(13)+CHAR(10)
SET @QUERY+='ON T.['+@Key+'] = S.['+@Key+']' +CHAR(13)+CHAR(10)
SET @QUERY+='WHEN MATCHED ' +CHAR(13)+CHAR(10)
SET @QUERY+='THEN UPDATE SET  ' +CHAR(13)+CHAR(10)

SELECT 
@QUERY+=
'T.'+COL.[name]+'=S.'+COL.[name]+','+CHAR(13)+CHAR(10)
FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
WHERE 
 COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
 COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)
SET @QUERY+='T.[Update_DTM] = GETDATE() ' +CHAR(13)+CHAR(10)
SET @QUERY+='WHEN NOT MATCHED ' +CHAR(13)+CHAR(10)
SET @QUERY+='THEN INSERT VALUES(' +CHAR(13)+CHAR(10)

SELECT 
@QUERY+=
'S.'+COL.[name]+','+CHAR(13)+CHAR(10)
FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
WHERE 
COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

SET @QUERY+='GETDATE(),' +CHAR(13)+CHAR(10)
SET @QUERY+='GETDATE()); END' +CHAR(13)+CHAR(10)
SET @QUERY = REPLACE(@QUERY,'datetime(23,3)','datetime')
SET @QUERY = REPLACE(@QUERY,'xml(-1)','xml')
--执行创建存储过程的create语句
EXEC (@QUERY)
--执行存储过程的语句
SET @QUERY = 'EXEC '+'[FU_ODS].[SP_UPINSERT_'+REPLACE(@TableName,'STG','ODS')+'] '
--执行存储过程
EXEC (@QUERY)


----------------------------------EDW PROC
--SET @QUERY = 'CREATE OR ALTER PROCEDURE  [FU_EDW].[SP_UPINSERT_'+REPLACE(@TableName,'STG','EDW')+'] '+CHAR(13)+CHAR(10)+'AS ' +CHAR(13)+CHAR(10)+  'BEGIN '+CHAR(13)+CHAR(10)
--SET @QUERY+='MERGE INTO '+REPLACE(@STG_Table_Name,'STG','EDW') +CHAR(13)+CHAR(10)
--SET @QUERY+='AS T' +CHAR(13)+CHAR(10)
--SET @QUERY+='USING(' +CHAR(13)+CHAR(10)
--SET @QUERY+='SELECT' +CHAR(13)+CHAR(10)

--SELECT 
--@QUERY+=
--COL.[name]+','+CHAR(13)+CHAR(10)
--FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
--LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
--WHERE 
-- COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
-- COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

--SET @QUERY=LEFT(@QUERY,LEN(@QUERY)-3)+CHAR(13)+CHAR(10)
--SET @QUERY+='FROM(' +CHAR(13)+CHAR(10)
--SET @QUERY+='SELECT' +CHAR(13)+CHAR(10)

--SELECT 
--@QUERY+=
--COL.[name]+','+CHAR(13)+CHAR(10)
--FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
--LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
--WHERE 
--COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
--COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

--SET @QUERY+='ROW_NUMBER()over(Partition by '+@Key+' order by '+@Key+') rn' +CHAR(13)+CHAR(10)
--SET @QUERY+='FROM '+@STG_Table_Name+' ) a' +CHAR(13)+CHAR(10)
--SET @QUERY+='where rn =1' +CHAR(13)+CHAR(10)
--SET @QUERY+=') AS S' +CHAR(13)+CHAR(10)
--SET @QUERY+='ON T.['+@Key+'] = S.['+@Key+']' +CHAR(13)+CHAR(10)
--SET @QUERY+='WHEN MATCHED ' +CHAR(13)+CHAR(10)
--SET @QUERY+='THEN UPDATE SET  ' +CHAR(13)+CHAR(10)

--SELECT 
--@QUERY+=
--'T.'+COL.[name]+'=S.'+COL.[name]+','+CHAR(13)+CHAR(10)
--FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
--LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
--WHERE 
-- COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
-- COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

--SET @QUERY+='T.[Update_DTM] = GETDATE() ' +CHAR(13)+CHAR(10)
--SET @QUERY+='WHEN NOT MATCHED ' +CHAR(13)+CHAR(10)
--SET @QUERY+='THEN INSERT VALUES(' +CHAR(13)+CHAR(10)

--SELECT 
--@QUERY+=
--'S.'+COL.[name]+','+CHAR(13)+CHAR(10)
--FROM SYS.COLUMNS COL LEFT JOIN SYS.TYPES TP ON COL.[system_type_id]=TP.[system_type_id] and COL.[user_type_id]=TP.[user_type_id] 
--LEFT JOIN SYS.OBJECTS OBJ ON COL.[object_id] = OBJ.[object_id]
--WHERE 
--COL.[name]<>'File_NM' AND COL.[name]<>'Load_DTM' and
--COL.[object_id] in (SELECT  [object_id] FROM SYS.OBJECTS WHERE [type]='U' and [name] =@TableName)

--SET @QUERY+='GETDATE()); END' +CHAR(13)+CHAR(10)
--SET @QUERY = REPLACE(@QUERY,'datetime(23,3)','datetime')
--SET @QUERY = REPLACE(@QUERY,'xml(-1)','xml')

----执行创建存储过程的create语句
--EXEC (@QUERY)
----执行存储过程的语句
--SET @QUERY = 'EXEC '+'[FU_EDW].[SP_UPINSERT_'+REPLACE(@TableName,'STG','EDW')+'] '
----执行存储过程
--EXEC (@QUERY)



END
GO
