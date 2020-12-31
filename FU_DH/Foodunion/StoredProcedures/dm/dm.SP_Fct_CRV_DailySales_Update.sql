USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC  [dm].[SP_Fct_CRV_DailySales_Update]
AS BEGIN

	 DECLARE @errmsg nvarchar(max),
	 @DatabaseName varchar(100) = DB_NAME(),
	 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	IF EXISTS (SELECT TOP 1 1 FROM [ODS].[ods].[Mongo_CRV_DailySales] WHERE Load_DTM>= DATEADD(HH,-1,GETDATE())
			UNION
			SELECT TOP 1 1 FROM [ODS].[ods].[File_SG_DailySales] WHERE Load_DTM>= DATEADD(HH,-1,GETDATE())
			UNION
			SELECT TOP 1 1 FROM [ODS].[ods].[File_CRV_DailySales] WHERE Load_DTM>= DATEADD(HH,-1,GETDATE())
			UNION
		    SELECT TOP 1 1 FROM (SELECT MAX(CONVERT(VARCHAR(10),[sdate],112)) MT FROM [ODS].[ods].[File_CRV_DailySales]) A
		                 LEFT JOIN (SELECT MAX([Datekey]) MT FROM [dm].[Fct_CRV_DailySales]) B
						 ON A.MT=B.MT WHERE B.MT IS NULL)                    --增加判断当ODS 的数据最大日期与DM 数据最大日期不一致 则执行程序
	BEGIN
	--TRUNCATE TABLE  [dm].[Fct_CRV_DailySales] ;
	--select *from [dm].[Fct_CRV_DailySales] ;

	--DELETE d
	--FROM ODS.[ods].[File_CRV_DailySales] ods
	--LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	--LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
	--	CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
	--	CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	--JOIN  [dm].[Fct_CRV_DailySales] d ON CONVERT(VARCHAR(8),ods.[sdate],112) = [Datekey]
	--	AND s.Store_ID = d.[Store_ID];

---------------------------------------Mongo_CRV
	DELETE d
	FROM [ODS].[ods].[Mongo_CRV_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
		CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	JOIN  [dm].[Fct_CRV_DailySales] d ON CONVERT(VARCHAR(8),CAST(ods.[sdate] AS DATE),112) = [Datekey]
		AND s.Store_ID = d.[Store_ID]
		WHERE CAST(d.[Datekey] AS INT)>='20190901'
----------------------------------------SG
	DELETE d
	FROM [ODS].[ods].[File_SG_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=CAST(TRIM(ods.Store_Code) AS INT) AND Account_Area_CN='07苏果'
	LEFT JOIN dm.Dim_Product_AccountCodeMapping acm ON TRIM(ods.Goods_Code) = acm.SKU_Code AND acm.Account = 'Suguo'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=TRIM(acm.bar_code) AND 
		CASE WHEN ods.goods_name LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goods_name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	JOIN  [dm].[Fct_CRV_DailySales] d ON ods.[Datekey] = d.[Datekey]
	AND s.Store_ID = d.[Store_ID]
	WHERE CAST(d.[Datekey] AS INT)>='20190901'

---------------------------------------Mongo_CRV
	INSERT INTO [dm].[Fct_CRV_DailySales]
           ([Datekey]
           ,[Date]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Name]
           ,[CRV_goodsname]
           ,[Sale_Scale]
           ,[Sale_Unit]
           ,[Sale_Type]
           ,[Sale_Qty]
           ,[Gross_Cost_Value]
           ,[Net_Cost_Value]
           ,[Tax_Cost_Value]
           ,[Gross_Sale_Value]
           ,[Net_Sale_Value]
           ,[Tax_Sale_Value]
           ,[Sale_Tax_Rate]
           ,[Sale_Cost_Rate]
           ,[Touch_Time]
           ,[CRV_Category_Name]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
		   ,Sales_Weight)
	--SELECT CONVERT(VARCHAR(8),ods.[sdate],112) Datekey
	--	,ods.[sdate] 
	--	,s.Store_ID
	--	,p.SKU_ID
	--	,ods.[shopname]
	--	,p.SKU_Name_CN
	--	,ods.[spec]
	--	,ods.[unitname]
	--	,ods.[saletype]
	--	,ods.[qty]
	--	,ods.[grosscostvalue]
	--	,ods.[netcostvalue]
	--	,ods.[grosscostvalue]-ods.[netcostvalue]
	--	,ods.[grosssalevalue]
	--	,ods.[netsalevalue]
	--	,ods.[grosssalevalue]-ods.[netsalevalue]
	--	,ods.[saletaxrate]
	--	,ods.[salecostrate]
	--	,ods.[touchtime]
	--	,ods.[categoryname]
	--	,GETDATE()
	--	,@ProcName
	--	,GETDATE()
	--	,@ProcName
	--	,ods.qty*p.Sale_Unit_Weight_KG	  
	--FROM ODS.[ods].[File_CRV_DailySales] ods
	--LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	--LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
	--	CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
	--	CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	--LEFT JOIN  [dm].[Fct_CRV_DailySales] d ON CONVERT(VARCHAR(8),ods.[sdate],112) = [Datekey]
	--	AND s.Store_ID = d.[Store_ID]
	--WHERE d.Store_ID IS NULL AND CONVERT(VARCHAR(8),ods.[sdate],112)<'20190901'
	--UNION ALL 
		SELECT CONVERT(VARCHAR(8),CAST(ods.[sdate] AS DATE),112) Datekey
		,ods.[sdate] 
		,s.Store_ID
		,p.SKU_ID
		,ods.[shopname]
		,p.SKU_Name_CN
		,ods.[spec]
		,ods.[unitname]
		,ods.[saletype]
		,ods.[qty]
		,ods.[grosscostvalue]
		,ods.[netcostvalue]
		,CAST(ods.[grosscostvalue] AS DECIMAL(20,10))-CAST(ods.[netcostvalue] AS DECIMAL(20,10))
		,ods.[grosssalevalue]
		,ods.[netsalevalue]
		,CAST(ods.[grosssalevalue] AS DECIMAL(20,10))-CAST(ods.[netsalevalue] AS DECIMAL(20,10))
		,ods.[saletaxrate]
		,ods.[salecostrate]
		,ods.[touchtime]
		,ods.[categoryname]
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName
		,ods.qty*p.Sale_Unit_Weight_KG	  
	FROM [ODS].[ods].[Mongo_CRV_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
		CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	LEFT JOIN  [dm].[Fct_CRV_DailySales] d ON CONVERT(VARCHAR(8),CAST(ods.[sdate] AS DATE),112) = [Datekey]
		AND s.Store_ID = d.[Store_ID]
	WHERE d.Store_ID IS NULL AND CONVERT(VARCHAR(8),CAST(ods.[sdate] AS DATE),112)>='20190901'
---------------------------------------SG
	INSERT INTO [dm].[Fct_CRV_DailySales]
           ([Datekey]
           ,[Date]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Name]
           ,[CRV_goodsname]
           ,[Sale_Scale]
           ,[Sale_Unit]
           ,[Sale_Type]
           ,[Sale_Qty]
		   ,Sales_Weight
           ,[Gross_Cost_Value]
           ,[Net_Cost_Value]
           ,[Tax_Cost_Value]
           ,[Gross_Sale_Value]
           ,[Net_Sale_Value]
           ,[Tax_Sale_Value]
           ,[Sale_Tax_Rate]
           ,[Sale_Cost_Rate]
           ,[Touch_Time]
           ,[CRV_Category_Name]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT ods.Datekey Datekey
		,CAST(ods.Datekey AS DATE) AS [sdate] 
		,s.Store_ID
		,p.SKU_ID
		,ods.Store_Name
		,p.SKU_Name_CN
		,ods.Sale_Scale
		,p.Sale_Unit_CN
		,NULL AS [saletype]
		,CAST(ods.[Sales_Qty] AS DECIMAL(20,10)) AS Sale_Qty
		,CAST(ods.[Sales_Qty] AS DECIMAL(20,10))*p.Sale_Unit_Weight_KG	
		,NULL AS [grosscostvalue]
		,NULL AS [netcostvalue]
		,NULL AS Tax_Cost_Value
		,CAST(ods.[Sales_AMT] AS DECIMAL(20,10)) AS [grosssalevalue]
		,NULL AS [netsalevalue]
		,NULL AS Tax_Sale_Value
		,NULL AS [saletaxrate]
		,NULL AS [salecostrate]
		,NULL AS [touchtime]
		,p.Product_Category_CN AS [categoryname]
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName
	FROM [ODS].[ods].[File_SG_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=CAST(TRIM(ods.Store_Code) AS INT) AND Account_Area_CN='07苏果'
	LEFT JOIN dm.Dim_Product_AccountCodeMapping acm ON TRIM(ods.Goods_Code) = acm.SKU_Code
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=acm.bar_code AND 
		CASE WHEN ods.goods_name LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goods_name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	LEFT JOIN  [dm].[Fct_CRV_DailySales] d ON ods.[Datekey] = d.[Datekey]
	AND s.Store_ID = d.[Store_ID]
	WHERE CAST(ods.[Datekey] AS INT)>='20190901' AND  d.Store_ID IS NULL
		AND (CAST(ods.Sales_AMT AS DECIMAL(18,5))>0 OR CAST(ods.Ending_AMT AS DECIMAL(18,5))>0);
	

	--IF (SELECT MAX(CONVERT(VARCHAR(10),[sdate],112)) MT FROM [ODS].[ods].[File_CRV_DailySales])>(SELECT MAX([Datekey]) MT FROM [dm].[Fct_CRV_DailySales])
	--BEGIN

	DELETE d  FROM 
  	(SELECT * FROM [ODS].[ods].[File_CRV_DailySales] WHERE CONVERT(VARCHAR(10),[Load_DTM],112)=(SELECT MAX(CONVERT(VARCHAR(10),[Load_DTM],112)) FROM [ODS].[ods].[File_CRV_DailySales])) ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
		CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	JOIN  [dm].[Fct_CRV_DailySales] d ON CONVERT(VARCHAR(8),CAST(ods.[sdate] AS DATE),112) = [Datekey]
	AND s.Store_ID = d.[Store_ID]

		INSERT INTO [dm].[Fct_CRV_DailySales]
           ([Datekey]
           ,[Date]
           ,[Store_ID]
           ,[SKU_ID]
           ,[Store_Name]
           ,[CRV_goodsname]
           ,[Sale_Scale]
           ,[Sale_Unit]
           ,[Sale_Type]
           ,[Sale_Qty]
           ,[Gross_Cost_Value]
           ,[Net_Cost_Value]
           ,[Tax_Cost_Value]
           ,[Gross_Sale_Value]
           ,[Net_Sale_Value]
           ,[Tax_Sale_Value]
           ,[Sale_Tax_Rate]
           ,[Sale_Cost_Rate]
           ,[Touch_Time]
           ,[CRV_Category_Name]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
		   ,Sales_Weight)
	SELECT CONVERT(VARCHAR(8),ods.[sdate],112) Datekey
		,ods.[sdate] 
		,s.Store_ID
		,p.SKU_ID
		,ods.[shopname]
		,p.SKU_Name_CN
		,ods.[spec]
		,ods.[unitname]
		,ods.[saletype]
		,ods.[qty]
		,ods.[grosscostvalue]
		,ods.[netcostvalue]
		,ods.[grosscostvalue]-ods.[netcostvalue]
		,ods.[grosssalevalue]
		,ods.[netsalevalue]
		,ods.[grosssalevalue]-ods.[netsalevalue]
		,ods.[saletaxrate]
		,ods.[salecostrate]
		,ods.[touchtime]
		,ods.[categoryname]
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName
		,ods.qty*p.Sale_Unit_Weight_KG	  
	FROM ODS.[ods].[File_CRV_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] s ON s.Account_Store_Code=ods.shopid AND Channel_Account='Vanguard'
	LEFT JOIN [dm].[Dim_Product] p ON p.Bar_Code=ods.barcode AND 
		CASE WHEN ods.goodsname LIKE '%小猪%' THEN 'PEPPA' WHEN ods.goodsname LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END =  
		CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
	LEFT JOIN  [dm].[Fct_CRV_DailySales] d ON CONVERT(VARCHAR(8),ods.[sdate],112) = [Datekey]
		AND s.Store_ID = d.[Store_ID]
	WHERE d.Store_ID IS NULL AND CONVERT(VARCHAR(10),[Load_DTM],112)=(SELECT MAX(CONVERT(VARCHAR(10),[Load_DTM],112)) FROM [ODS].[ods].[File_CRV_DailySales])

	--END
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
