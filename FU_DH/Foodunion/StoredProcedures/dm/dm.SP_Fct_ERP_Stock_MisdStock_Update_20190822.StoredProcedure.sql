USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_ERP_Stock_MisdStock_Update_20190822]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_MisdStock_Update_20190822]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--[dm].[Fct_ERP_Stock_MisdStock]
		--UPDATE p
		--SET p.[MisdStock_ID] = c.[MisdStock_ID]
		--   ,p.[Datekey] = convert(varchar(8),c.Date,112)
  --          ,p.[Bill_Type]		  =c.[Bill_Type]		
		--	,p.[Bill_No]		  =c.[Bill_No]		
		--	,p.[Stock_Org]		  =c.[Stock_Org]		
		--	,p.[Document_Status]  =c.[Document_Status]
		--	,p.[Stock_Direct]	  =c.[Stock_Direct]	
		--	,p.[Cancel_Status]	  =c.[Cancel_Status]	
		--	,p.[Note]			  =c.[Note]			
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_MisdStock] p
		--JOIN ODS.[ods].[ERP_Stock_MisdStock] c ON p.[MisdStock_ID] = c.[MisdStock_ID]
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_MisdStock]
	
		INSERT INTO [dm].[Fct_ERP_Stock_MisdStock]
           ([MisdStock_ID]
		   ,[Datekey]
           ,[Bill_Type]
		   ,[Bill_No]
		   ,[Stock_Org]
		   ,[Document_Status]
		   ,[Stock_Direct]
		   ,[Cancel_Status]
		   ,[Note]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			c.[MisdStock_ID]
			,convert(varchar(8),c.Date,112)
           ,c.[Bill_Type]
		   ,c.[Bill_No]
		   ,c.[Stock_Org]
		   ,c.[Document_Status]
		   ,c.[Stock_Direct]
		   ,c.[Cancel_Status]
		   ,c.[Note]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_MisdStock] c
		LEFT JOIN [dm].[Fct_ERP_Stock_MisdStock] p	ON p.[MisdStock_ID] = c.[MisdStock_ID]
		WHERE p.[MisdStock_ID] IS NULL;
		
		--[dm].[Fct_ERP_Stock_InStockEntry]
		--UPDATE p
		--SET  p.[MisdStock_ID] =c.[MisdStock_ID]
		--    ,p.[Sequence_ID]  =c.[Sequence_ID] 
		--    ,p.[SKU_ID]		  =c.[SKU_ID]		 
		--    ,p.[Stock_Name]	  =c.[Stock_Name]	 
		--    ,p.[Stock_Status] =c.[Stock_Status]
		--    ,p.[Produce_Date] =c.[Produce_Date]
		--    ,p.[Expiry_Date]  =c.[Expiry_Date] 
		--    ,p.[LOT]		  =c.[LOT]		 
		--    ,p.[LOT_Display]  =c.[LOT_Display] 
		--    ,p.[Unit]		  =c.[Unit]		 
		--    ,p.[QTY]		  =c.[QTY]		 
		--    ,p.[Price]		  =c.[Price]		 
		--    ,p.[Note]		  =c.[Note]		 
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_MisdStockEntry] p
		--JOIN ODS.[ods].[ERP_Stock_MisdStockEntry] c ON p.[MisdStock_ID] = c.[MisdStock_ID] AND p.[Sequence_ID] = c.[Sequence_ID]
		--;
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_MisdStockEntry]
	
		INSERT INTO [dm].[Fct_ERP_Stock_MisdStockEntry]
           ([MisdStock_ID]
		   ,[Sequence_ID]
		   ,[SKU_ID]
		   ,[Stock_Name]
		   ,[Stock_Status]
		   ,[Produce_Date]
		   ,[Expiry_Date]
		   ,[LOT]
		   ,[LOT_Display]
		   ,[Unit]
		   ,[QTY]
		   ,[Price]
		   ,[Note]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			 c.[MisdStock_ID]
		    ,c.[Sequence_ID]
		    ,c.[SKU_ID]
		    ,c.[Stock_Name]
		    ,c.[Stock_Status]
		    ,c.[Produce_Date]
		    ,c.[Expiry_Date]
		    ,c.[LOT]
		    ,c.[LOT_Display]
		    ,ISNULL(prod.Sale_Unit_CN,c.Unit) AS Unit
		    ,ISNULL(CASE WHEN c.Unit = prod.Sale_Unit_CN THEN c.QTY ELSE c.QTY*cr.Convert_Rate END,C.QTY) AS QTY
		    ,c.[Price]
		    ,c.[Note]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_MisdStockEntry] c
		LEFT JOIN [dm].[Fct_ERP_Stock_MisdStockEntry] p	ON p.[MisdStock_ID] = c.[MisdStock_ID] and  p.[Sequence_ID] = c.[Sequence_ID]
		LEFT JOIN [dm].Dim_Product prod ON prod.SKU_ID = c.SKU_ID 
		LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr ON cr.From_Unit = c.Unit AND cr.To_Unit = prod.Sale_Unit_CN
		WHERE p.[MisdStock_ID] IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
