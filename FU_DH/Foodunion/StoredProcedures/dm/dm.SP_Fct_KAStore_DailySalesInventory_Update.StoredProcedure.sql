USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_KAStore_DailySalesInventory_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dm].[SP_Fct_KAStore_DailySalesInventory_Update]
AS BEGIN


 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 DECLARE @Ret_Days int = 30;

 BEGIN TRY

	DROP TABLE IF EXISTS #Fct_KAStore_DailySalesInventory;
	CREATE TABLE #Fct_KAStore_DailySalesInventory(
		[Datekey] [int] NOT NULL,
		[Store_ID] [nvarchar](50) NOT NULL,
		[SKU_ID] [nvarchar](50) NOT NULL,
		[Store_Code] [nvarchar](50) NULL,
		[Store_Name] [nvarchar](100) NULL,
		[KA_SKU_Name] [varchar](200) NULL,
		[Sale_Scale] [nvarchar](50) NULL,
		[InStock_Qty] [decimal](18, 9) NULL,
		[TransferIn_Qty] [decimal](18, 9) NULL,
		[TransferOut_Qty] [decimal](18, 9) NULL,
		[Return_Qty] [decimal](18, 9) NULL,
		[Sales_Qty] [decimal](18, 9) NULL,
		[Sales_AMT] [decimal](18, 9) NULL,
		[Sales_Vol_KG] [decimal](18, 9) NULL,
		[Inventory_Qty] [decimal](18, 9) NULL,
		[Create_Time] [datetime] NOT NULL,
		[Create_By] [nvarchar](100) NULL,
		[Update_Time] [datetime] NOT NULL,
		[Update_By] [nvarchar](100) NULL
	) ON [PRIMARY]


	INSERT INTO #Fct_KAStore_DailySalesInventory
           ([Datekey]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Code]
           ,[Store_Name]
           ,[KA_SKU_Name]
           ,[Sale_Scale]
           ,[InStock_Qty]
           ,[TransferIn_Qty]
           ,[TransferOut_Qty]
           ,[Return_Qty]
           ,[Sales_Qty]
           ,[Sales_AMT]
		   ,[Sales_Vol_KG]
           ,[Inventory_Qty]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
 
	SELECT 
		k.Datekey
		,k.Store_ID
		,k.SKU_ID 
		,s.Account_Store_Code
		,s.Store_Name
		,p.SKU_Name_CN
		,p.Sale_Scale
		,k.InStock_Qty
		,k.TransferIn_Qty
		,k.TransferOut_Qty
		,k.Return_Qty
		,k.Sales_Qty
		,k.Sales_AMT
		,k.Sales_Qty * p.Sale_Unit_Weight_KG AS [Sales_Vol_KG]
		,Ending_Qty AS Inventory_Qty
		,getdate(),'[dm].[Fct_KAStore_DailySalesInventory]'
		,getdate(),'[dm].[Fct_KAStore_DailySalesInventory]'
	FROM [dm].Fct_Kidswant_DailySales k  WITH(NOLOCK) 
	LEFT JOIN dm.Dim_Store s WITH(NOLOCK) ON k.Store_ID = s.Store_ID
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON k.SKU_ID=p.SKU_ID
	WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--AND k.Store_ID  IS null

	UNION all

	SELECT 
		k.Calendar_DT  Datekey
		,k.Store_ID
		,k.SKU_ID 
		,s.Account_Store_Code
		,s.Store_Name
		,p.SKU_Name_CN
		,p.Sale_Scale
		,NULL
		,NULL
		,NULL
		,NULL
		,k.Sales_Qty
		,k.Sales_AMT
		,k.Sales_Qty * p.Sale_Unit_Weight_KG as  [Sales_Vol_KG]
		,k.Inventory_QTY as  Inventory_Qty
		,getdate(),'[dm].[Fct_KAStore_DailySalesInventory]'
		,getdate(),'[dm].[Fct_KAStore_DailySalesInventory]'
	FROM [dm].[Fct_YH_Sales_Inventory] k WITH(NOLOCK) 
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID
	LEFT JOIN dm.Dim_Store s WITH(NOLOCK) ON k.Store_ID = s.Store_ID
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Calendar_DT = C.Date_ID
	WHERE k.Calendar_DT >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--AND k.Store_ID is not null

	UNION all

	SELECT 
		ISNULL(k.Datekey,q.Datekey) Datekey
		,ISNULL(k.Store_ID,q.Store_ID) Store_ID
		,ISNULL(k.SKU_ID,q.SKU_ID)  SKU_ID
		,s.Account_Store_Code
		,s.Store_Name
		,p.SKU_Name_CN
		,p.Sale_Scale
		,NULL
		,NULL
		,NULL
		,NULL
		,k.Sale_Qty as Sales_Qty
		,k.Gross_Sale_Value as Sales_AMT
		,k.Sale_Qty * p.Sale_Unit_Weight_KG  as  [Sales_Vol_KG]
		,q.Qty as  Inventory_Qty
		,getdate(),'[dm].[Fct_KAStore_DailySalesInventory]'
		,getdate(),'[dm].[Fct_KAStore_DailySalesInventory]'
		--select top 10 *
	FROM  [dm].[Fct_CRV_DailySales] k  WITH(NOLOCK)  
	FULL OUTER JOIN [dm].[Fct_CRV_DailyInventory] q WITH(NOLOCK) ON k.Datekey = q.Datekey and k.Store_ID = q.Store_ID and k.SKU_ID = q.SKU_ID  
	LEFT JOIN dm.Dim_Store s WITH(NOLOCK) ON isnull(k.Store_ID,q.Store_ID) = s.Store_ID
	LEFT JOIN dm.Dim_Product p on isnull(k.SKU_ID,q.SKU_ID)=p.SKU_ID
	WHERE isnull(k.Datekey,q.Datekey) >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--and ISNULL(k.Store_ID,q.Store_ID) is null;


	DELETE  t
	FROM [dm].[Fct_KAStore_DailySalesInventory] t
	JOIN #Fct_KAStore_DailySalesInventory s
	ON t.Datekey = s.Datekey AND t.Store_ID = s.Store_ID;

	INSERT INTO [dm].[Fct_KAStore_DailySalesInventory]
           ([Datekey]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Code]
           ,[Store_Name]
           ,[KA_SKU_Name]
           ,[Sale_Scale]
           ,[InStock_Qty]
           ,[TransferIn_Qty]
           ,[TransferOut_Qty]
           ,[Return_Qty]
           ,[Sales_Qty]
           ,[Sales_AMT]
		   ,[Sales_Vol_KG]
           ,[Inventory_Qty]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT [Datekey]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Code]
           ,[Store_Name]
           ,[KA_SKU_Name]
           ,[Sale_Scale]
           ,[InStock_Qty]
           ,[TransferIn_Qty]
           ,[TransferOut_Qty]
           ,[Return_Qty]
           ,[Sales_Qty]
           ,[Sales_AMT]
		   ,[Sales_Vol_KG]
           ,[Inventory_Qty]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
	FROM #Fct_KAStore_DailySalesInventory ;

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
