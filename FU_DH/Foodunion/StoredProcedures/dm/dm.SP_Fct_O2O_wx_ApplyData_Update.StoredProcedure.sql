USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_O2O_wx_ApplyData_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_O2O_wx_ApplyData_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	DROP TABLE IF EXISTS #kv;
	
	;WITH s AS(
		SELECT sp_num,p.Parent_ID,p.[Name],p.StringValue,p.ValueType
		FROM ods.[ods].[SCRM_wx_applylist] as al
		CROSS APPLY dbo.parseJSON(apply_data) as P 
		WHERE sp_num>=convert(varchar(8),getdate()-7,112)+'0000' AND 
		--sp_num='201907170029' and
		(p.name in ('title','value') or (p.name is null and p.[Object_ID] is null))
	)
	,kv AS(
	SELECT s1.sp_num,s1.Parent_ID,s1.[Name],isnull(s2.StringValue,s1.StringValue) StringValue
	FROM s s1
	LEFT JOIN s s2 ON s1.sp_num=s2.sp_num and s1.name='value' and s1.ValueType='array'
		and s1.stringvalue=CAST(s2.Parent_ID AS VARCHAR(50)) and s2.Name is null
	WHERE s1.Name IS NOT NULL
	)
	SELECT kv1.sp_num,kv1.Parent_ID,kv1.StringValue AS k,kv2.StringValue AS v
	INTO #kv
	FROM kv kv1
	LEFT JOIN kv kv2 ON kv1.sp_num = kv2.sp_num 
		and kv1.Parent_ID = kv2.Parent_ID 
		and kv2.[Name] = 'value'
	WHERE kv1.[Name]='title';


	DELETE t
	FROM dm.Fct_O2O_wx_ApplyData t
	JOIN #kv kv ON t.sp_num=kv.sp_num;

	INSERT INTO [dm].[Fct_O2O_wx_ApplyData]
		(sp_num
		,[item_id]
		,[k]
		,[v]
		,[Create_time]
		,[Create_By]
		,[Update_time]
		,[Update_By])
	SELECT sp_num
		,Parent_ID
		,k
		,v
		,GETDATE()
		,''
		,GETDATE()
		,''		
	FROM #kv;


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
--SELECT *FROM [dm].[Dim_Store]


	END


	--select *  FROM [dm].[Dim_Store] ds 
GO
