USE [Foodunion]
GO
DROP PROCEDURE [dbo].[USP_Change_TableColumn]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --[dbo].[USP_Change_TableColumn]  '[ods].[SCRM_order_detail_info]','delete','payment','unit_price','0'
CREATE PROCEDURE [dbo].[USP_Change_TableColumn]  
@FullTableName NVARCHAR(200),
@Action NVARCHAR(10),
@ColumnDesc NVARCHAR(100),		--���� 'NewCol Varchar(100)',  ֻ�������NULL�ֶλ��ߴ���defaultԼ��
@AfterCol NVARCHAR(100)='',
@PrintOnly INT = 1				--�Ƿ��ӡ��䣬������ֱ��ִ��
AS
BEGIN
----------------------------------------test
--DECLARE @FullTableName NVARCHAR(200)
--DECLARE @Action NVARCHAR(10) = 'alter'
--DECLARE @ColumnDesc NVARCHAR(100)
--DECLARE @AfterCol NVARCHAR(100)=''
--DECLARE @PrintOnly INT = 1

--SET @FullTableName = '[dm].[Dim_Channel_20190905]'
--SET @AfterCol='Channel_ID'
--SET @ColumnDesc = 'NewCol3 nVarchar(100)'
---------------------------------------------Validation
IF @Action NOT IN ('ADD','REMOVE','DELETE','ALTER')
BEGIN
RAISERROR('��2����������ADD,REMOVE,DELETE����ALTER',15,3)
RETURN
END
IF @AfterCol <> ''
BEGIN
	IF @AfterCol NOT IN (SELECT [name] FROM sys.columns WHERE OBJECT_ID = OBJECT_ID(@FullTableName))
	BEGIN
	RAISERROR('��4����������ָ���ı���',15,3)
	RETURN
	END
END



SET @FullTableName = REPLACE(@FullTableName,'[','')
SET @FullTableName = REPLACE(@FullTableName,']','')
DECLARE @Schema_Name NVARCHAR(50) = LEFT(@FullTableName,CHARINDEX('.',@FullTableName)-1)
DECLARE @Table_Name NVARCHAR(200) = RIGHT(@FullTableName,LEN(@FullTableName)-LEN(@Schema_Name)-1)
DECLARE @FullTableName_BKP NVARCHAR(200) = @FullTableName+'_'+CONVERT(VARCHAR(8),GETDATE(),112)
DECLARE @Object_ID NVARCHAR(50) = (SELECT [object_id] FROM sys.[objects] WHERE [name] = @Table_Name AND [schema_id] = SCHEMA_ID(@Schema_Name))

-------------------���ݱ�
DECLARE @QUERY AS NVARCHAR(MAX)
SET @QUERY = 'DROP TABLE IF EXISTS '+@FullTableName_BKP+';SELECT * INTO '+@FullTableName_BKP + ' FROM '+@FullTableName
-------------------ִ��
EXEC(@QUERY)
SET @QUERY = ''
-----------------------------------------------��ȡ�ֶζ���
DROP TABLE IF EXISTS #ColumnDefs
SELECT   c.[object_id] AS TableObj
		,c.column_id AS ColSeq 
		,c.[name] AS ColName
		,QUOTENAME(c.name) + ' ' + CASE WHEN c.is_computed = 1 
			THEN 'as ' + COALESCE(k.[definition], '') + CASE WHEN k.is_persisted = 1 
																THEN ' PERSISTED'  + CASE WHEN k.is_nullable = 0 
																					 THEN ' NOT NULL' 
																					 ELSE ''  END
                                                                ELSE ''  END
               ELSE DataType + CASE    WHEN DataType IN ( 'decimal','numeric')
                               THEN '(' + CAST(c.precision AS VARCHAR(10)) + CASE WHEN c.scale <> 0
																			 THEN ',' + CAST(c.scale AS VARCHAR(10))
																			 ELSE '' END + ')'
                                WHEN DataType IN ('char','varchar','nchar','nvarchar','binary','varbinary')
                                THEN '(' + CASE WHEN c.max_length = -1
                                           THEN 'max'
                                           ELSE CASE WHEN DataType IN ('nchar','nvarchar')
                                                THEN CAST(c.max_length / 2 AS VARCHAR(10))
                                                ELSE CAST(c.max_length AS VARCHAR(10))
                                                END
                                           END + ')'
                                WHEN DataType = 'float' AND c.precision <> 53
                                THEN '(' + CAST(c.precision AS VARCHAR(10)) + ')'
                                WHEN DataType IN ('time','datetime2','datetimeoffset') AND c.scale <> 7
                                THEN '(' + CAST(c.scale AS VARCHAR(10)) + ')'
                                ELSE '' END
               END + CASE  WHEN c.is_identity = 1 
                                        THEN ' IDENTITY(' + CAST(IDENT_SEED(QUOTENAME(OBJECT_SCHEMA_NAME(c.[object_id])) + '.' + QUOTENAME(OBJECT_NAME(c.[object_id]))) AS VARCHAR(30)) + ',' + CAST(IDENT_INCR(QUOTENAME(OBJECT_SCHEMA_NAME(c.[object_id])) + '.' + QUOTENAME(OBJECT_NAME(c.[object_id]))) AS VARCHAR(30)) + ')'
                                        ELSE ''
                                    END + CASE    WHEN c.is_rowguidcol = 1
                                                THEN ' ROWGUIDCOL'
                                                ELSE ''
                                            END + CASE    WHEN c.xml_collection_id > 0
                                                        THEN ' (CONTENT ' + QUOTENAME(SCHEMA_NAME(x.schema_id)) + '.' + QUOTENAME(x.name) + ')'
                                                        ELSE ''
                                                    END + CASE    WHEN c.is_computed = 0 AND UserDefinedFlag = 0 THEN CASE  WHEN c.collation_name <> CAST(DATABASEPROPERTYEX(DB_NAME(),  'collation') AS NVARCHAR(128))
                                                           THEN ' COLLATE ' + c.collation_name  ELSE '' END  ELSE ''  END + CASE   WHEN c.is_computed = 0  THEN CASE   WHEN c.is_nullable = 0   THEN ' NOT'  ELSE ''  END + ' NULL' ELSE ''
                                                                END + CASE                                                                                                        
                                                                WHEN c.default_object_id > 0 --AND ISNULL(@new,0) = 0
                                                                THEN ' CONSTRAINT ' + QUOTENAME(d.name) + ' DEFAULT ' + COALESCE(d.[definition],
                                                                '')
                                                                WHEN c.default_object_id > 0 --AND ISNULL(@new,0) = 1
                                                                THEN ' DEFAULT ' + COALESCE(d.[definition],
                                                                '')
                                                                ELSE ''
                                                                END AS ColumnDef
INTO #ColumnDefs
FROM    sys.columns c
CROSS APPLY (SELECT TYPE_NAME(c.user_type_id) AS DataType,CASE WHEN c.system_type_id = c.user_type_id THEN 0  ELSE 1 END AS UserDefinedFlag) F1
LEFT JOIN sys.default_constraints d ON c.default_object_id = d.[object_id]
LEFT JOIN sys.computed_columns k ON c.[object_id] = k.[object_id] AND c.column_id = k.column_id
LEFT JOIN sys.xml_schema_collections x ON c.xml_collection_id = x.xml_collection_id
WHERE c.[object_id] = @Object_ID
----------------------------------------------------------------��ȡ��������
DROP TABLE IF EXISTS #IxDefs
SELECT i.[object_id] AS TableObj
      ,QUOTENAME(i.name+'_'+LEFT(NEWID(),4)) AS IxName
	  ,i.is_primary_key AS IxPKFlag
	  ,CASE WHEN i.is_primary_key = 1 THEN 'PRIMARY KEY ' WHEN i.is_unique = 1 THEN 'UNIQUE ' ELSE '' END + LOWER(type_desc) AS IxType
	  ,'(' + IxColList + ')' + COALESCE(' INCLUDE (' + IxInclList + ')', '') IxDef
	  ,IxOptList AS IxOpts
INTO #IxDefs
FROM sys.indexes i
LEFT JOIN sys.stats s ON i.index_id = s.stats_id AND i.[object_id] = s.[object_id]
CROSS APPLY (SELECT    STUFF((SELECT    CASE    WHEN i.is_padded = 1 THEN ', PAD_INDEX=ON' ELSE ''END 
									  + CASE    WHEN i.fill_factor <> 0 THEN ', FILLFACTOR=' + CAST(i.fill_factor AS VARCHAR(10)) ELSE '' END 
									  + CASE    WHEN i.ignore_dup_key = 1 THEN ', IGNORE_DUP_KEY=ON' ELSE '' END 
									  + CASE    WHEN s.no_recompute = 1 THEN ', STATISTICS_RECOMPUTE=ON' ELSE '' END 
									  + CASE    WHEN i.allow_row_locks = 0 THEN ', ALLOW_ROW_LOCKS=OFF' ELSE '' END 
									  + CASE    WHEN i.allow_page_locks = 0 THEN ', ALLOW_PAGE_LOCKS=OFF' ELSE '' END), 1, 2, '')) F_IxOpts (IxOptList)
CROSS APPLY (SELECT    STUFF((SELECT ',' + QUOTENAME(c.name) + CASE    WHEN ic.is_descending_key = 1 AND i.type <> 3 THEN ' DESC' WHEN ic.is_descending_key = 0 AND i.type <> 3 THEN ' ASC' ELSE '' END
                            FROM    sys.index_columns ic
                            JOIN    sys.columns c ON ic.[object_id] = c.[object_id] AND ic.column_id = c.column_id
                            WHERE    ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.is_included_column = 0
                            ORDER BY ic.key_ordinal    
                    FOR        XML    PATH('')
                            ,    TYPE).value('.', 'nvarchar(max)'), 1, 1, '')) F_IxCols (IxColList)
CROSS APPLY (SELECT    STUFF((SELECT    ',' + QUOTENAME(c.name)
                            FROM    sys.index_columns ic
                            JOIN    sys.columns c ON ic.[object_id] = c.[object_id] AND ic.column_id = c.column_id
                            WHERE    ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.is_included_column = 1
                            ORDER BY ic.key_ordinal    
                    FOR        XML    PATH('')
                            ,    TYPE).value('.', 'nvarchar(max)'), 1, 1, '')) F_IxIncl (IxInclList)
WHERE i.type_desc <> 'HEAP'AND i.[object_id] = @Object_ID
------------------------�ж��Ƿ�������
DECLARE @index INT = CASE (SELECT MAX(1) FROM #IxDefs WHERE IxPKFlag = 0) WHEN 1 THEN 2 ELSE 0 END
------------------------------------------------��ȡ����
--DROP TABLE IF EXISTS #PKDef
--SELECT si.id AS TableObj
--	  ,si.[name] AS PKName
--	  ,STRING_AGG(sc.[name],',') AS ColName 
--INTO #PKDef
--FROM dbo.sysindexes si
--INNER JOIN dbo.sysindexkeys sik ON si.id = sik.id AND si.indid = sik.indid
--INNER JOIN dbo.syscolumns sc ON sc.id = sik.id AND sc.colid = sik.colid
--INNER JOIN dbo.sysobjects so ON so.name = si.name AND so.xtype = 'PK'
--WHERE si.id = @Object_ID
--GROUP BY si.id
--		,si.[name]

-------------------�ж�ִ���߼�
IF @Action IN ('ADD' ,'DEFAULT ADD')
BEGIN
	---------------��ȡ��������
	DECLARE @ColName NVARCHAR(50) = LEFT(@ColumnDesc,CHARINDEX(' ',@ColumnDesc)-1)
	---------------�ж������Ƿ��Ѵ���
	IF @ColName IN (SELECT ColName FROM #ColumnDefs)
	BEGIN
			RAISERROR('�µ������Ѵ���',15,3)
			RETURN
	END




	-------------------------�ж��в���λ��
	IF @AfterCol <> ''
	BEGIN
		DECLARE @ColSeq INT = (SELECT Colseq+1 FROM #ColumnDefs WHERE ColName = @AfterCol)
		----------------������
		INSERT INTO #ColumnDefs
		SELECT @Object_ID AS TableObj
			  ,@ColSeq AS ColSeq
			  ,@ColName AS ColName 
			  ,@ColumnDesc AS ColumnDef 
		UPDATE #ColumnDefs SET Colseq = Colseq+1 WHERE Colseq>=@ColSeq AND ColName <> @ColName
		
	-------------------------------------------���ɲ����ѯ���
		DECLARE    @crlf CHAR(2);
		SET @crlf = CHAR(13) + CHAR(10);
		-------------------------ɾ�����ؽ���Ŀǰֻ���ؽ��С���Լ��������������
		SELECT @QUERY = 'DROP TABLE IF EXISTS '+@FullTableName+@crlf+';'+@crlf+[definition]+@crlf+';'+@crlf     
        FROM    sys.tables t
        CROSS APPLY (SELECT    TableName = QUOTENAME(OBJECT_SCHEMA_NAME(t.[object_id])) + '.' + QUOTENAME(OBJECT_NAME(t.[object_id]))) F_Name
		-----------------------�нṹ
        CROSS APPLY (SELECT    STUFF((SELECT    @crlf + '  ,' + ColumnDef
                                    FROM    #ColumnDefs
                                    WHERE    TableObj = t.[object_id]
                                    ORDER BY ColSeq    
                            FOR        XML    PATH('')
                                    ,    TYPE).value('.', 'nvarchar(max)'), 1, 5, '')) F_Cols (ColumnList)
        CROSS APPLY (SELECT    STUFF((SELECT    @crlf + '  ,CONSTRAINT ' + QUOTENAME(name) + ' CHECK ' + CASE
                                                                                                        WHEN is_not_for_replication = 1
                                                                                                        THEN 'NOT FOR REPLICATION '
                                                                                                        ELSE ''
                                                                                                        END + COALESCE([definition],
                                                                                                        '')
                                    FROM    sys.check_constraints
                                    WHERE    parent_object_id = t.[object_id]
                            FOR        XML    PATH('')
                                    ,    TYPE).value('.', 'nvarchar(max)'), 1, 2, '')) F_Const (ChkConstList)
		----------------------�������
        CROSS APPLY (SELECT    STUFF((SELECT    @crlf + '  ,CONSTRAINT ' + IxName + ' ' + IxType + ' ' + IxDef + COALESCE(' WITH (' + IxOpts + ')',
                                                                                                        '')
                                    FROM    #IxDefs
                                    WHERE    TableObj = t.[object_id] AND IxPKFlag = 1
                            FOR        XML    PATH('')
                                    ,    TYPE).value('.', 'nvarchar(max)'), 1, 2, '')) F_IxConst (IxConstList)
        CROSS APPLY (SELECT    STUFF((SELECT    @crlf + 'CREATE ' + IxType + ' INDEX ' + IxName + ' ON ' + TableName + ' ' + IxDef + COALESCE(' WITH (' + IxOpts + ')',
                                                                                                        '')
                                    FROM    #IxDefs
                                    WHERE    TableObj = t.[object_id] AND IxPKFlag = 0
                            FOR        XML    PATH('')
                                    ,    TYPE).value('.', 'nvarchar(max)'), 1, 2, '')) F_Indexes (IndexList)
		--------------------------����ṹ
        CROSS APPLY (SELECT    [definition] =
            ( SELECT    CASE    WHEN @index <> 1
                                THEN 'CREATE TABLE ' + TableName + @crlf + '(' + @crlf + '   ' + ColumnList + COALESCE(@crlf + ChkConstList,
                                                                                                        '') + COALESCE(@crlf + IxConstList,
                                                                                                        '') + @crlf + ')' + @crlf
                                ELSE ''
                        END + CASE    WHEN @index <> 0 THEN COALESCE(@crlf + IndexList, '')
                                    ELSE ''
                                END    
                        FOR    XML    PATH('')
                            ,    TYPE).value('.', 'nvarchar(max)')) F_Link
        WHERE    t.[is_ms_shipped] = 0 AND [definition] <> '' AND t.[object_id] = @Object_ID
		-----------------------------------------�����ݴӱ��ݱ����Դ��
		-----------------------------------------�ж��Ƿ����������
		
		SELECT @QUERY+='IF EXISTS(SELECT 1 FROM sys.identity_columns WHERE [object_id] = OBJECT_ID('''+@FullTableName+''') ) BEGIN SET IDENTITY_INSERT '+@FullTableName+' ON INSERT INTO '+@FullTableName + ' ('+STRING_AGG(ColName,',')+')  SELECT * FROM '+@FullTableName_BKP + ' SET IDENTITY_INSERT '+@FullTableName+' OFF END ELSE BEGIN   INSERT INTO '+@FullTableName + ' ('+STRING_AGG(ColName,',')+')  SELECT * FROM '+@FullTableName_BKP + ' END;'
		FROM #ColumnDefs WHERE ColName<>@ColName
	END
	--------------------------��@AfterColΪ�� ֱ�� ʹ���������������мӵ����
	ELSE BEGIN
		SELECT @QUERY = 'ALTER TABLE '+@FullTableName + ' ADD '+@ColumnDesc
	END

------------------------ѡ��ִ�л��ߴ�ӡ���
IF @PrintOnly =1 
BEGIN
SELECT @QUERY
END
ELSE
BEGIN
EXEC(@QUERY)
END
END
---------------------------------����ɾ�������
ELSE IF @Action IN ('REMOVE','DELETE')
BEGIN
	SET @QUERY = 'ALTER TABLE '+@FullTableName + ' DROP Column '+@ColumnDesc 

------------------------ѡ��ִ�л��ߴ�ӡ���
IF @PrintOnly =1 
BEGIN
SELECT @QUERY
END
ELSE
BEGIN
EXEC(@QUERY)
END
END
-----------------------�޸��е��������ɾ�����ٲ���
IF @Action IN ('ALTER')
BEGIN

	---------------��ȡҪ�޸ĵ�������
	DECLARE @ColName2 NVARCHAR(50) = LEFT(@ColumnDesc,CHARINDEX(' ',@ColumnDesc)-1)
	---------------�ж������Ƿ��Ѵ���
	IF @ColName2 NOT IN (SELECT ColName FROM #ColumnDefs)
	BEGIN
			RAISERROR('���������������������������б���',15,3)
			RETURN
	END

	UPDATE #ColumnDefs SET ColumnDef = @ColumnDesc WHERE  ColName = @ColName2
	-------------------------ɾ�����ؽ���Ŀǰֻ���ؽ��С���Լ��������������
	SET @crlf = CHAR(13) + CHAR(10);
	SELECT @QUERY = 'DROP TABLE IF EXISTS '+@FullTableName+@crlf+';'+@crlf+[definition]+@crlf+';'+@crlf     
    FROM    sys.tables t
    CROSS APPLY (SELECT    TableName = QUOTENAME(OBJECT_SCHEMA_NAME(t.[object_id])) + '.' + QUOTENAME(OBJECT_NAME(t.[object_id]))) F_Name
	-----------------------�нṹ
    CROSS APPLY (SELECT    STUFF((SELECT    @crlf + '  ,' + ColumnDef
                                FROM    #ColumnDefs
                                WHERE    TableObj = t.[object_id]
                                ORDER BY ColSeq    
                        FOR        XML    PATH('')
                                ,    TYPE).value('.', 'nvarchar(max)'), 1, 5, '')) F_Cols (ColumnList)
    CROSS APPLY (SELECT    STUFF((SELECT    @crlf + '  ,CONSTRAINT ' + QUOTENAME(name) + ' CHECK ' + CASE
                                                                                                    WHEN is_not_for_replication = 1
                                                                                                    THEN 'NOT FOR REPLICATION '
                                                                                                    ELSE ''
                                                                                                    END + COALESCE([definition],
                                                                                                    '')
                                FROM    sys.check_constraints
                                WHERE    parent_object_id = t.[object_id]
                        FOR        XML    PATH('')
                                ,    TYPE).value('.', 'nvarchar(max)'), 1, 2, '')) F_Const (ChkConstList)
	----------------------�������
    CROSS APPLY (SELECT    STUFF((SELECT    @crlf + '  ,CONSTRAINT ' + IxName + ' ' + IxType + ' ' + IxDef + COALESCE(' WITH (' + IxOpts + ')',
                                                                                                    '')
                                FROM    #IxDefs
                                WHERE    TableObj = t.[object_id] AND IxPKFlag = 1
                        FOR        XML    PATH('')
                                ,    TYPE).value('.', 'nvarchar(max)'), 1, 2, '')) F_IxConst (IxConstList)
    CROSS APPLY (SELECT    STUFF((SELECT    @crlf + 'CREATE ' + IxType + ' INDEX ' + IxName + ' ON ' + TableName + ' ' + IxDef + COALESCE(' WITH (' + IxOpts + ')',
                                                                                                    '')
                                FROM    #IxDefs
                                WHERE    TableObj = t.[object_id] AND IxPKFlag = 0
                        FOR        XML    PATH('')
                                ,    TYPE).value('.', 'nvarchar(max)'), 1, 2, '')) F_Indexes (IndexList)
	--------------------------����ṹ
    CROSS APPLY (SELECT    [definition] =
        ( SELECT    CASE    WHEN @index <> 1
                            THEN 'CREATE TABLE ' + TableName + @crlf + '(' + @crlf + '   ' + ColumnList + COALESCE(@crlf + ChkConstList,
                                                                                                    '') + COALESCE(@crlf + IxConstList,
                                                                                                    '') + @crlf + ')' + @crlf
                            ELSE ''
                    END + CASE    WHEN @index <> 0 THEN COALESCE(@crlf + IndexList, '')
                                ELSE ''
                            END    
                    FOR    XML    PATH('')
                        ,    TYPE).value('.', 'nvarchar(max)')) F_Link
    WHERE    t.[is_ms_shipped] = 0 AND [definition] <> '' AND t.[object_id] = @Object_ID
	-------------------------------------------�����ݴӱ��ݱ����Դ��
			SELECT @QUERY+='IF EXISTS(SELECT 1 FROM sys.identity_columns WHERE [object_id] = OBJECT_ID('''+@FullTableName+''') ) BEGIN SET IDENTITY_INSERT '+@FullTableName+' ON INSERT INTO '+@FullTableName + ' ('+STRING_AGG(ColName,',')+')  SELECT * FROM '+@FullTableName_BKP + ' SET IDENTITY_INSERT '+@FullTableName+' OFF END ELSE BEGIN   INSERT INTO '+@FullTableName + ' ('+STRING_AGG(ColName,',')+')  SELECT * FROM '+@FullTableName_BKP + ' END;'
	FROM #ColumnDefs 

------------------------ѡ��ִ�л��ߴ�ӡ���
IF @PrintOnly =1 
BEGIN
SELECT @QUERY
END
ELSE
BEGIN
EXEC(@QUERY)
END

END

END



GO
