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
--ɾ������ODS��EDW���
IF OBJECT_ID(N'Foodunion'+'.'+REPLACE(@STG_Table_Name,'STG','ODS')) IS NOT NULL
BEGIN
SET @QUERY = 'DROP TABLE '+REPLACE(@STG_Table_Name,'STG','ODS')
EXEC(@QUERY)
END

--����CREATE ���
SET @QUERY='CREATE TABLE '+REPLACE(@STG_Table_Name,'STG','ODS') +'('

--��ȡSTG���ÿ���ֶ��������ͺ����ͳ��ȣ���ΪODS���EDW����ֶ����͸�ʽ
SELECT 
@QUERY+=
COL.[name]+' '+
CASE COL.[precision] 
WHEN 0  THEN 
CASE COL.[is_ansi_padded]
WHEN 1 THEN CONVERT(NVARCHAR(15),TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[max_length])+')') --�ַ�
WHEN 0 THEN TP.name + '('+CONVERT(nvarchar(10),COL.[max_length])+')'  --�ַ�
END 
ELSE
CASE COL.[scale] 
WHEN 0 THEN TP.[name] --����
ELSE TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[precision])+','+CONVERT(NVARCHAR(10),COL.[scale])+')' --ʵ��
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
--ִ��create table���
EXEC(@QUERY)



----------------------------------EDW TABLE 
----ɾ������ODS��EDW���
--IF OBJECT_ID(N'Foodunion'+'.'+REPLACE(@STG_Table_Name,'STG','EDW')) IS NOT NULL
--BEGIN
--SET @QUERY = 'DROP TABLE '+REPLACE(@STG_Table_Name,'STG','EDW')
--EXEC(@QUERY)
--END

----����CREATE ���
--SET @QUERY='CREATE TABLE '+REPLACE(@STG_Table_Name,'STG','EDW') +'('

----��ȡSTG���ÿ���ֶ��������ͺ����ͳ��ȣ���ΪODS���EDW����ֶ����͸�ʽ
--SELECT 
--@QUERY+=
--COL.[name]+' '+
--CASE COL.[precision] 
--WHEN 0  THEN 
--CASE COL.[is_ansi_padded]
--WHEN 1 THEN CONVERT(NVARCHAR(15),TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[max_length])+')') --�ַ�
--WHEN 0 THEN TP.name + '('+CONVERT(nvarchar(10),COL.[max_length])+')'  --�ַ�
--END 
--ELSE
--CASE COL.[scale] 
--WHEN 0 THEN TP.[name] --����
--ELSE TP.[name]+ '('+CONVERT(NVARCHAR(10),COL.[precision])+','+CONVERT(NVARCHAR(10),COL.[scale])+')' --ʵ��
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
----ִ��create table���
--EXEC(@QUERY)


--------------------------------ODS PROC
--����Create���
SET @QUERY = 'CREATE OR ALTER PROCEDURE  [FU_ODS].[SP_UPINSERT_'+REPLACE(@TableName,'STG','ODS')+'] '+CHAR(13)+CHAR(10)+'AS ' +CHAR(13)+CHAR(10)+  'BEGIN '+CHAR(13)+CHAR(10)
SET @QUERY+='MERGE INTO '+REPLACE(@STG_Table_Name,'STG','ODS') +CHAR(13)+CHAR(10)
SET @QUERY+='AS T' +CHAR(13)+CHAR(10)
SET @QUERY+='USING(' +CHAR(13)+CHAR(10)
SET @QUERY+='SELECT' +CHAR(13)+CHAR(10)

--��ȡSTG���ÿ���ֶ��������ͺ����ͳ��ȣ���ΪODS���EDW����ֶ����͸�ʽ
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
--ִ�д����洢���̵�create���
EXEC (@QUERY)
--ִ�д洢���̵����
SET @QUERY = 'EXEC '+'[FU_ODS].[SP_UPINSERT_'+REPLACE(@TableName,'STG','ODS')+'] '
--ִ�д洢����
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

----ִ�д����洢���̵�create���
--EXEC (@QUERY)
----ִ�д洢���̵����
--SET @QUERY = 'EXEC '+'[FU_EDW].[SP_UPINSERT_'+REPLACE(@TableName,'STG','EDW')+'] '
----ִ�д洢����
--EXEC (@QUERY)



END
GO
