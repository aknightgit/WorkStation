USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_ERP_Stock_TransferOut_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_TransferOut_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--[dm].[Fct_ERP_Stock_TransferOut]
		--UPDATE p
		--SET p.[TransID] = c.[TransID]
		--  ,p.[Datekey] = convert(varchar(8),c.Date,112)
		--  ,p.[Bill_No] = c.[Bill_No]
		--  ,p.[Date] = c.[Date]
		--  ,p.[Stock_Org] = c.[Stock_Org]
		--  ,p.[Bill_Type] = c.[Bill_Type]
		--  ,p.[Transfer_Biz_Type] = c.[Transfer_Biz_Type]
		--  ,p.[Transfer_Direct] = c.[Transfer_Direct]
		--  ,p.[Biz_Type] = c.[Biz_Type]
		--  ,p.[Document_Status] = c.[Document_Status]
		--  ,p.[Bill_Create_Date] = c.[Create_Date]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_TransferOut] p
		--JOIN ODS.[ods].[ERP_Stock_TransferOut] c ON p.[TransID] = c.[TransID];
		;
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_TransferOut]
	
		INSERT INTO [dm].[Fct_ERP_Stock_TransferOut]
           ([TransID]
		  ,[Datekey]
		  ,[Bill_No]
		  ,[Date]
		  ,[Stock_Org]
		  ,[Bill_Type]
		  ,[Customer_Name]
		  ,[Transfer_Biz_Type]
		  ,[Transfer_Direct]
		  ,[Biz_Type]
		  ,[Document_Status]
		  ,[Bill_Create_Date]
		  ,[Note]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By])
		SELECT 
		   c.[TransID]
		   ,convert(varchar(8),c.Date,112)
		  ,c.[Bill_No]
		  ,c.[Date]
		  ,c.[Stock_Org]
		  ,c.[Bill_Type]
		  ,c.[Customer_Name]
		  ,c.[Transfer_Biz_Type]
		  ,c.[Transfer_Direct]
		  ,c.[Biz_Type]
		  ,c.[Document_Status]
		  ,c.[Create_Date]
		  ,c.[Note]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_TransferOut] c
		LEFT JOIN [dm].[Fct_ERP_Stock_TransferOut] p	ON p.[TransID] = c.[TransID]
		WHERE p.[TransID] IS NULL;
		
		-- select * from [dm].[Fct_ERP_Stock_TransferOutEntry]
		--UPDATE p
		--SET p.[TransID] = c.[TransID]
		--  ,p.[Sequence_ID] = c.[Sequence_ID]
		--  ,p.[SKU_ID] = c.[SKU_ID]
		--  ,p.[LOT] = c.[LOT]
		--  ,p.[LOT_Display] = c.[LOT_Display]
		--  ,p.[Source_Stock] = c.[Source_Stock]
		--  ,p.[Dest_Stock] = c.[Dest_Stock]
		--  ,p.[Unit] = ISNULL(prod.Sale_Unit_CN,c.Unit)
		--  ,p.[QTY] = ISNULL(CASE WHEN prod.Base_Unit_CN = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,c.QTY )
		--  ,p.[Base_Unit] = c.[Base_Unit]
		--  ,p.[Base_Unit_QTY] = c.[Base_Unit_QTY]
		--  ,p.[Base_Unit_Price] = c.[Base_Unit_Price]
		--  ,p.[Amount] = c.[Amount]
		--  ,p.[Cost_Price] = c.[Cost_Price]
		--  ,p.[Cost_Amount] = c.[Cost_Amount]
		--  ,p.[Produce_Date] = c.[Produce_Date]
		--  ,p.[Exipry_Date] = c.[Exipry_Date]
		--  ,p.[Source_Stock_Status] = c.[Source_Stock_Status]
		--  ,p.[DEST_Stock_Status] = c.[DEST_Stock_Status]
		--  ,p.[Note] = c.[Note]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_TransferOutEntry] p
		--JOIN ODS.[ods].[ERP_Stock_TransferOutEntry] c ON p.[TransID] = c.[TransID] AND p.[Sequence_ID] = c.[Sequence_ID]
		--LEFT JOIN [dm].Dim_Product prod ON prod.SKU_ID = c.SKU_ID 
		--LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr ON cr.From_Unit = prod.Base_Unit_CN AND cr.To_Unit = prod.Sale_Unit_CN
		--;
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_TransferOutEntry]
	
		INSERT INTO [dm].[Fct_ERP_Stock_TransferOutEntry]
           ([TransID]
		  ,[Sequence_ID]
		  ,[SKU_ID]
		  ,[LOT]
		  ,[LOT_Display]
		  ,[Source_Stock]
		  ,[Dest_Stock]
		  ,[Unit]
		  ,[QTY]
		  ,[Base_Unit]
		  ,[Base_Unit_QTY]
		  ,[Base_Unit_Price]
		  ,[Amount]
		  ,[Cost_Price]
		  ,[Cost_Amount]
		  ,[Produce_Date]
		  ,[Exipry_Date]
		  ,[Source_Stock_Status]
		  ,[DEST_Stock_Status]
		  ,[Note]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By])
		SELECT 
			c.[TransID]
		  ,c.[Sequence_ID]
		  ,c.[SKU_ID]
		  ,c.[LOT]
		  ,c.[LOT_Display]
		  ,c.[Source_Stock]
		  ,c.[Dest_Stock]
		  ,ISNULL(prod.Sale_Unit_CN,c.Unit) AS Unit
		  ,ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,c.QTY ) AS QTY
		  ,c.[Base_Unit]
		  ,c.[Base_Unit_QTY]
		  ,c.[Base_Unit_Price]
		  ,c.[Amount]
		  ,c.[Cost_Price]
		  ,c.[Cost_Amount]
		  ,c.[Produce_Date]
		  ,c.[Exipry_Date]
		  ,c.[Source_Stock_Status]
		  ,c.[DEST_Stock_Status]
		  ,c.[Note]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_TransferOutEntry] c
		LEFT JOIN [dm].[Fct_ERP_Stock_TransferOutEntry] p	
		ON p.[TransID] = c.[TransID] and  p.[Sequence_ID] = c.[Sequence_ID]
		LEFT JOIN [dm].Dim_Product prod ON prod.SKU_ID = c.SKU_ID 
		LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr ON cr.From_Unit = c.Base_Unit AND cr.To_Unit = prod.Sale_Unit_CN
		WHERE p.[TransID] IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
