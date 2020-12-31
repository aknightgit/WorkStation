USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC  [dm].[SP_Fct_CRV_DailyInventory_Update]
AS BEGIN


	 DECLARE @errmsg nvarchar(max),
	 @DatabaseName varchar(100) = DB_NAME(),
	 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE  [dm].[Fct_CRV_DailyInventory] ;

	IF EXISTS (SELECT TOP 1 1 FROM [ODS].[ods].[Mongo_CRV_Inventory] WHERE Load_DTM>= DATEADD(HH,-1,GETDATE())
			UNION
			SELECT TOP 1 1 FROM [ODS].[ods].[File_SG_DailySales] WHERE Load_DTM>= DATEADD(HH,-1,GETDATE())
			UNION
			SELECT TOP 1 1 FROM [ODS].[ods].[File_CRV_DailyInventory] WHERE Load_DTM>= DATEADD(HH,-1,GETDATE()))
	BEGIN

	DELETE inv
	FROM [dm].[Fct_CRV_DailyInventory] inv 
	WHERE inv.Datekey >= '20190917';

	INSERT INTO [dm].[Fct_CRV_DailyInventory]
           ([Datekey]
           ,[Date]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Name]
           ,[CRV_goodsname]
           ,[Sale_Scale]
           ,[Sale_Unit]
           ,[Qty]
           ,[Gross_Cost_Value]
           ,[Tax_Cost_Value]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	--SELECT CONVERT(VARCHAR(8),ods.[releasedate],112) Datekey
	--	,ods.[releasedate] 
	--	,s.Store_ID
	--	,p.SKU_ID
	--	,ods.[shopname]
	--	,p.SKU_Name_CN
	--	,ods.[spec]
	--	,ods.[unitname]
	--	,ods.[qty]
	--	,ods.[grosscostvalue]
	--	,ods.[taxcostvalue]
	--	,GETDATE()
	--	,@ProcName
	--	,GETDATE()
	--	,@ProcName	  
	--FROM ODS.[ods].[File_CRV_DailyInventory] ods
	--LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	--LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
	--  CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
	--  CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	--WHERE  CONVERT(VARCHAR(8),ods.[releasedate],112)< '20190917'
	--UNION  ALL
	SELECT CONVERT(VARCHAR(8),CAST(ods.[releasedate] AS DATE),112) Datekey
		,ods.[releasedate] 
		,s.Store_ID
		,p.SKU_ID
		,ods.[shopname]
		,p.SKU_Name_CN
		,ods.[spec]
		,ods.[unitname]
		,ods.[qty]
		,ods.[grosscostvalue]
		,ods.[taxcostvalue]
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName	  
	FROM [ODS].[ods].[Mongo_CRV_Inventory] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
	  CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
	  CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	WHERE  CONVERT(VARCHAR(8),CAST(ods.[releasedate] AS DATE),112) >= '20190917'
	UNION 
	--------------------------------------------------SG
	SELECT ods.Datekey
		,CAST(ods.Datekey AS DATE) AS [sdate] 
		,s.Store_ID
		,p.SKU_ID
		,ods.Store_Name
		,p.SKU_Name_CN
		,ods.Sale_Scale
		,p.Sale_Unit_CN
		,CAST(ods.Ending_Qty AS DECIMAL(20,10)) AS [qty]
		,NULL AS [grosscostvalue]
		,NULL AS [taxcostvalue]
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName	
	FROM [ODS].[ods].[File_SG_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=CAST(TRIM(ods.Store_Code) AS INT) AND Account_Area_CN='07苏果'
	LEFT JOIN dm.Dim_Product_AccountCodeMapping acm ON TRIM(ods.Goods_Code) = acm.SKU_Code AND acm.Account = 'Suguo'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=acm.bar_code AND 
		CASE WHEN ods.goods_name LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goods_name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	WHERE  ods.DATEKEY >= '20190917'
	AND (CAST(ods.Sales_AMT AS DECIMAL(18,5))>0 OR CAST(ods.Ending_AMT AS DECIMAL(18,5))>0);


	--当MongoDB 数据未推送时，用下载文件更新数据
	--IF (SELECT MAX(CONVERT(VARCHAR(8),[releasedate],112)) FROM ODS.[ods].[File_CRV_DailyInventory])> (SELECT MAX([Datekey]) FROM  [dm].[Fct_CRV_DailyInventory])
	--BEGIN
	INSERT INTO [dm].[Fct_CRV_DailyInventory]
           ([Datekey]
           ,[Date]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Name]
           ,[CRV_goodsname]
           ,[Sale_Scale]
           ,[Sale_Unit]
           ,[Qty]
           ,[Gross_Cost_Value]
           ,[Tax_Cost_Value]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT CONVERT(VARCHAR(8),ods.[releasedate],112) Datekey
		,ods.[releasedate] 
		,s.Store_ID
		,p.SKU_ID
		,ods.[shopname]
		,p.SKU_Name_CN		
		,P.Sale_Scale
		,ods.[unitname]
		,ods.[qty]
		,NULL [grosscostvalue]
		,NULL [taxcostvalue]
	    ,GETDATE()
		,'[dm].[SP_Fct_CRV_DailyInventory_Update]' ProcName
		,GETDATE()
		,'[dm].[SP_Fct_CRV_DailyInventory_Update]' ProcName	
	FROM ODS.[ods].[File_CRV_DailyInventory] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
	  CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
	  CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	LEFT JOIN [dm].[Fct_CRV_DailyInventory] D
	ON CONVERT(VARCHAR(8),ods.[releasedate],112)=D.Datekey AND s.Store_ID=D.Store_ID AND p.SKU_ID=D.SKU_ID
	WHERE D.Store_ID IS NULL AND D.SKU_ID IS NULL AND LEFT(CONVERT(VARCHAR(8),ods.[releasedate],112),6)>='202007'--(SELECT MAX([Datekey]) FROM  [dm].[Fct_CRV_DailyInventory])
	;




	END
END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
