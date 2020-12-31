USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_ERP_Stock_TransferIn_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_TransferIn_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		----[dm].[Fct_ERP_Stock_TransferIn]
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
		--  ,p.[Extrange_Rate] = c.[Extrange_Rate]
		--  ,p.[Tax_Include] = c.[Tax_Include]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_TransferIn] p
		--JOIN ODS.[ods].[ERP_Stock_TransferIn] c ON p.[TransID] = c.[TransID];
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_TransferIn]
	
		INSERT INTO [dm].[Fct_ERP_Stock_TransferIn]
           ([TransID]
		  ,[Datekey]
		  ,[Bill_No]
		  ,[Date]
		  ,[Stock_Org]
		  ,[Bill_Type]
		  ,[Transfer_Biz_Type]
		  ,[Transfer_Direct]
		  ,[Biz_Type]
		  ,[Document_Status]
		  ,[Bill_Create_Date]
		  ,[Extrange_Rate]
		  ,[Tax_Include]
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
		  ,c.[Transfer_Biz_Type]
		  ,c.[Transfer_Direct]
		  ,c.[Biz_Type]
		  ,c.[Document_Status]
		  ,c.[Create_Date]
		  ,c.[Extrange_Rate]
		  ,c.[Tax_Include]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_TransferIn] c
		LEFT JOIN [dm].[Fct_ERP_Stock_TransferIn] p	ON p.[TransID] = c.[TransID]
		WHERE p.[TransID] IS NULL;
		
		--[dm].[Fct_ERP_Stock_TransferInEntry]
		--UPDATE p
		--SET p.[TransID] = c.[TransID]
		--  ,p.[Sequence_ID] = c.[Sequence_ID]
		--  ,p.[SKU_ID] = c.[SKU_ID]
		--  ,p.[LOT] = c.[LOT]
		--  ,p.[LOT_Display] = c.[LOT_Display]
		--  ,p.[Source_Stock] = c.[Source_Stock]
		--  ,p.[Dest_Stock] = c.[Dest_Stock]
		--  ,p.[Unit] = c.[Unit]
		--  ,p.[QTY] = c.[QTY]
		--  ,p.[Base_Unit] = c.[Base_Unit]
		--  ,p.[Base_Unit_QTY] = c.[Base_Unit_QTY]
		--  ,p.[Sale_Unit] = ISNULL(c.Sale_Unit,prod.Sale_Unit_CN)
		--  ,p.[Sale_QTY] = ISNULL(c.Sale_QTY,CASE WHEN prod.Base_Unit_CN = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END )
		--  ,p.[Price_Unit] = c.[Price_Unit]
		--  ,p.[Price_Unit_QTY] = c.[Price_Unit_QTY]
		--  ,p.[Price] = c.[Price]
		--  ,p.[Amount] = c.[Amount]
		--  ,p.[Produce_Date] = c.[Produce_Date]
		--  ,p.[Exipry_Date] = c.[Exipry_Date]
		--  ,p.[Source_Stock_Status] = c.[Source_Stock_Status]
		--  ,p.[Note] = c.[Note]
		--  ,p.[Business_Date] = c.[Business_Date]
		--  ,p.[IsFree] = c.[IsFree]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_TransferInEntry] p
		--JOIN ODS.[ods].[ERP_Stock_TransferInEntry] c ON p.[TransID] = c.[TransID] AND p.[Sequence_ID] = c.[Sequence_ID]
		--LEFT JOIN [dm].Dim_Product prod ON prod.SKU_ID = c.SKU_ID 
		--LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr ON cr.From_Unit = prod.Base_Unit_CN AND cr.To_Unit = prod.Sale_Unit_CN

		TRUNCATE TABLE [dm].[Fct_ERP_Stock_TransferInEntry]
	
		INSERT INTO [dm].[Fct_ERP_Stock_TransferInEntry]
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
		  ,[Sale_Unit]
		  ,[Sale_QTY]
		  ,[Price_Unit]
		  ,[Price_Unit_QTY]
		  ,[Price]
		  ,[Amount]
		  ,[Produce_Date]
		  ,[Exipry_Date]
		  ,[Source_Stock_Status]
		  ,[Note]
		  ,[Business_Date]
		  ,[IsFree]
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
		  ,c.[Unit]
		  ,c.[QTY]
		  ,c.[Base_Unit]
		  ,c.[Base_Unit_QTY]
		  ,ISNULL(prod.Sale_Unit_CN,c.Sale_Unit) AS [Sale_Unit]
		  ,ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,c.Sale_QTY ) AS [Sale_QTY]
		  ,c.[Price_Unit]
		  ,c.[Price_Unit_QTY]
		  ,c.[Price]
		  ,c.[Amount]
		  ,c.[Produce_Date]
		  ,c.[Exipry_Date]
		  ,c.[Source_Stock_Status]
		  ,c.[Note]
		  ,c.[Business_Date]
		  ,c.[IsFree]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_TransferInEntry] c
		LEFT JOIN [dm].[Fct_ERP_Stock_TransferInEntry] p ON p.[TransID] = c.[TransID] and  p.[Sequence_ID] = c.[Sequence_ID]
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
