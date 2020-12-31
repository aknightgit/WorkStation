USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Dim_Order_CombineItem_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE [dm].[Dim_Order_CombineItem];
	
	DECLARE @pName varchar(100)='[dm].[SP_Dim_Order_CombineItem_Update]'

	
	;WITH CI AS(
	SELECT *,DENSE_RANK() OVER(PARTITION BY Outer_SKU_ID ORDER BY Datekey DESC,Load_Source DESC) AS RID 
	FROM ODS.[ODS].[TP_Trade_CombineItem] WITH(NOLOCK)
	--where Outer_SKU_ID='1130003-104-1'
	--ORDER BY 1,2,4
	)
	INSERT INTO [dm].[Dim_Order_CombineItem]
           ([Outer_SKU_ID]
           ,[SKU_ID]
           ,[Quantity]
           ,[Begin_Date]
           ,[End_Date]
           ,[Is_Current]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT a.Outer_SKU_ID,a.SKU_ID,
		a.Quantity,
		CASE WHEN m.RID is not null THEN '19990101' ELSE a.Datekey END AS Being_Date,
		CASE WHEN b.RID is not null THEN CONVERT(VARCHAR(8),DATEADD("D",-1,SUBSTRING(CAST(b.Datekey AS CHAR(8)),1,4)+'-'+
										SUBSTRING(CAST(b.Datekey AS CHAR(8)),5,2)+'-'+
										SUBSTRING(CAST(b.Datekey AS CHAR(8)),7,2)) ,112)
			ELSE isnull(b.Datekey,99991231) END AS End_Date,		
		CASE WHEN a.RID=1 THEN 1 ELSE 0 END AS Is_Current,
		a.Load_DTM,a.Load_Source,
		GETDATE(),@pName
		
	FROM CI a
	LEFT JOIN (SELECT DISTINCT Outer_SKU_ID,Datekey, RID FROM CI) b ON a.Outer_SKU_ID=b.Outer_SKU_ID AND a.RID=b.RID+1
	LEFT JOIN (SELECT Outer_SKU_ID,max(RID) RID FROM CI GROUP BY Outer_SKU_ID)m 
			ON a.Outer_SKU_ID=m.Outer_SKU_ID
			AND a.RID=m.RID
	--where a.Outer_SKU_ID='113101-6-02-603-608-6'
	ORDER BY 1,4,2;

	--adhoc missing records 2019/4/3
	insert into [dm].[Dim_Order_CombineItem] 
	select '2100030-2',2100030,2,'19000101','99991231',1,getdate(),'',getdate(),'';
	insert into [dm].[Dim_Order_CombineItem] 
	select '21002930',2100030,1,'19000101','99991231',1,getdate(),'',getdate(),'';
	insert into [dm].[Dim_Order_CombineItem] 
	select '21002930',2100029,1,'19000101','99991231',1,getdate(),'',getdate(),'';
	insert into [dm].[Dim_Order_CombineItem] 
	select '2100029-2',2100029,2,'19000101','99991231',1,getdate(),'',getdate(),'';
	--adhoc missing records 2019/4/24
	insert into [dm].[Dim_Order_CombineItem] 
	select '1133007-108-109-110-1',1133007,1,'19000101','99991231',1,getdate(),'',getdate(),'';
	insert into [dm].[Dim_Order_CombineItem] 
	select '1133007-108-109-110-1',1133008,1,'19000101','99991231',1,getdate(),'',getdate(),'';
	insert into [dm].[Dim_Order_CombineItem] 
	select '1133007-108-109-110-1',1133009,1,'19000101','99991231',1,getdate(),'',getdate(),'';
	insert into [dm].[Dim_Order_CombineItem] 
	select '1133007-108-109-110-1',1133010,1,'19000101','99991231',1,getdate(),'',getdate(),'';

	

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
