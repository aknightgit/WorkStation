USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dm].[SP_Dim_Warehouse_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	
	INSERT INTO [dm].[Dim_Warehouse]
			   ([WHS_ID]
			   ,[Warehouse_Name]
			   ,[Warehouse_Name_EN]
			   ,[Org_Group]
			   ,[City]
			   ,[Warehouse_Type]
			   ,[Status]
			   ,[BeginDate]
			   ,[EndDate]
			   ,[Create_Time]
			   ,[Create_By]
			   ,[Update_Time]
			   ,[Update_By])
	SELECT s.Stock_ID
		,s.Stock_Name
		,s.Stock_Name_EN
		,s.Stock_Org
		,null
		,s.Stock_Group+'('+s.Stock_Group_Desc+')'
		,s.Status
		,null
		,null
		,getdate(),'[dm].[Dim_ERP_StockList]'
		,getdate(),'[dm].[Dim_ERP_StockList]'
	FROM [dm].[Dim_ERP_StockList] s
	LEFT JOIN [dm].[Dim_Warehouse] w ON w.[WHS_ID]=s.Stock_ID
	WHERE W.WHS_ID IS NULL;
 

	UPDATE w
	   SET w.[Warehouse_Name] = s.Stock_Name
		  ,w.[Warehouse_Name_EN] = s.Stock_Name_EN
		  ,w.[Org_Group] = s.Stock_Org
		  ,w.[Status] = s.[Status]
		  ,w.Warehouse_Type=s.Stock_Group+'('+s.Stock_Group_Desc+')'
		  ,w.[Update_Time] = getdate()
		  ,w.[Update_By] = @ProcName
	FROM [dm].[Dim_Warehouse] w
	JOIN [dm].[Dim_ERP_StockList] s ON w.[WHS_ID]=Stock_ID
	WHERE  isnull(w.[Warehouse_Name],'') <> s.Stock_Name 
		OR isnull(w.[Warehouse_Name_EN],'') <> s.Stock_Name_EN
		OR isnull(w.[Status],'') <> s.[Status];


	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END

--select * from [dm].[Dim_Warehouse] w
--select * from [dm].[Dim_ERP_StockList]
GO
