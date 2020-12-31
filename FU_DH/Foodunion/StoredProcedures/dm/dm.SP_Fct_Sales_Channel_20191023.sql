USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dm].[SP_Fct_Sales_Channel_20191023]
	-- Add the parameters for the stored procedure here
AS
BEGIN


	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	/****** Script for SelectTopNRows command from SSMS  ******/
	TRUNCATE TABLE [dm].[Fct_Sales_Channel]

	insert into [dm].[Fct_Sales_Channel]
	SELECT Year,replace(Period,'.','') Period,Customer,Channel_ID,Store_NM,SKU,t.[SKU_NM],Brand,category,rsp,qty,gs_price,pos,GETDATE() AS [Create_Time],OBJECT_NAME(@@PROCID) AS [Create_By],GETDATE() AS [Update_Time],OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM (
	SELECT left(Period,4) year,Period,Customer,'7' Channel_ID,area as Store_NM,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	FROM [ODS].[ods].[File_Sales_Beequick]
	UNION ALL
	SELECT left(Period,4) year,Period,Customer,'8' Channel_ID,Area,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	FROM [ODS].[ods].[File_Sales_Missfresh]
	UNION ALL
	SELECT left(Period,4) year,Period,Customer,'9' Channel_ID,Area,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	FROM [ODS].[ods].[File_Sales_Ourhours]
	UNION ALL
	SELECT left(Period,4) year,Period,Customer,'10' Channel_ID,Area,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	FROM [ODS].[ods].[File_Sales_Icoffee]
	--UNION ALL
	--SELECT left(Period,4) year,Period,'Auchan' Customer,'C005' Channel_ID,Store_NM,SKU_Code_New,null SKU_NM,Brand,category,rsp,qty,0 , pos
	--FROM [FU_ODS].[T_ODS_Sales_Auchan]
	--UNION ALL
	--SELECT year,Period,'HuaGuan' Customer,'C006' Channel_ID,Store_NM,Product_CD,[Product_NM],Brand,category,rsp,qty ,0,Total
	--FROM [FU_ODS].[T_ODS_Sales_HuaGuan]
	UNION ALL
	SELECT  left(Period,4) year,Period,'Mia' Customer,'13' Channel_ID,null Store_NM,SKU_ID,[SKU_NM],null Brand,null category,rsp,qty ,Order_GS,pay_split
	FROM [ODS].[ods].[File_Sales_Mia]
	UNION ALL
	SELECT left(Period,4) year,Period,'Wechat' Customer,'3' Channel_ID,null Store_NM,SKU_ID,[SKU_NM],null Brand,null category,rsp,qty ,Order_GS,pay_split 
	FROM [ODS].[ods].[File_Sales_Wechat]
	--UNION ALL ---------------------------new version of JD TM

	--SELECT 
	--	  LEFT(o.Order_DateKey,4) AS [Year]
	--	 ,o.Order_DateKey AS [PERIOD]
	--	 ,CASE dc.Channel_Name_short WHEN 'TM' THEN 'Tmall' ELSE dc.Channel_Name_short END AS [Customer]
	--	 ,CASE dc.Channel_Name_short WHEN 'TM' THEN '2' WHEN 'JD' THEN '1' END AS [Channel_ID]
	--	 ,pf.Platform_Name_CN AS [Store_NM]
	--	 ,NULL AS SKU
	--	 ,NULL AS SKU_NM
	--	 ,LEFT(pf.Platform_Name_CN,[dbo].[IndexOfCh](pf.Platform_Name_CN)) AS BRAND
	--	 ,NULL AS Category
	--	 ,0 AS RSP
	--	 ,0 AS QTY
	--	 ,0 AS Order_GS
	--	 ,CASE WHEN op.Received_Amount>0 THEN op.Received_Amount-op.Post_Fee ELSE op.Received_Amount END AS Received_Amount
	--	FROM [dm].[Dim_Order] o
	--	LEFT JOIN [dm].[Fct_Order_payment] op ON o.Order_ID = op.Order_ID   
	--	LEFT JOIN [dm].[Dim_Platform] pf ON o.Platform_ID = pf.Platform_ID
	--	LEFT JOIN [dm].[Dim_Channel] dc ON o.Channel_ID = dc.Channel_ID
	--	WHERE dc.Channel_Name_Display in ('TM','JD')

	UNION ALL
	SELECT left(Calendar_DT,4) year,Calendar_DT,'YH' Customer,'5' Channel_ID,null Store_NM,SKU_ID,null [SKU_NM],null Brand,null category,0 rsp,sum(sales_qty) ,0 Order_GS, sum(Sales_amt)
	FROM dm.Fct_YH_Sales_Inventory
	group by Calendar_DT,SKU_ID
	--UNION ALL
	--SELECT left(Period,4) year,Period,'Lotus' Customer,'14' Channel_ID,Store_NM,SKU_ID,SKU_NM,Brand,null category,0 rsp,0 qty ,0,AMT
	--FROM [ODS].[ods].[File_Sales_Lotus]
	---------------------------Lotus South
	--UNION ALL
	--SELECT 
	--	 left(Sales_DT,4) AS [year]
	--	,CONVERT(varchar(8),CAST(Sales_DT AS DATE),112) AS [Period]
	--	,'Lotus South' AS [Customer]
	--	,'C012' AS Channel_ID
	--	,Lotus_Store_NM AS Store_NM
	--	,Prod.SKU_ID
	--	,LS.SKU_NM
	--	,Prod.Brand_NM
	--	,null category
	--	,0 rsp
	--	,CAST(Bottle_Qty AS FLOAT) AS qty 
	--	,0 AS GS_Price
	--	,CAST(Sales_AMT AS FLOAT) AS POS
	--FROM [FU_ODS].[T_ODS_Sales_Lotus_South] LS
	--LEFT JOIN (SELECT SKU_ID,Brand_NM,Lotus_Item_ID,ROW_NUMBER() OVER(PARTITION BY Lotus_Item_ID ORDER BY Lotus_Item_ID) RN FROM [FU_EDW].[T_EDW_DIM_Product]) PROD ON PROD.RN = 1 AND PROD.Lotus_Item_ID = LS.Lotus_Item_ID

	----------------------KA POS
	UNION ALL
	SELECT 
			[YEAR]
		   ,CONVERT(varchar(8),CAST([DATE] AS DATE),112) AS [Period]
		   ,Customer_NM AS [Customer]
		   ,CASE Customer_NM WHEN '易初东区' THEN '14'
							 WHEN '易初南区' THEN '14'
							 WHEN '欧尚'	 THEN '11'
							 WHEN '华冠'	 THEN '12'
			END AS Channel_ID
	   		,Store_NM AS Store_NM
			,SKU_ID
			,SKU_NM
			,SKU_Brand_NM
			,SKU_Category_NM
			,0 AS rsp
			,CAST(ISNULL(Sales_QTY,0) AS FLOAT) AS qty 
			,0 AS GS_Price
			,CAST(ISNULL(Sales_With_Tax_AMT,0) AS FLOAT) AS POS
	FROM [ODS].[ods].[File_Sales_KA_POS] kp
	-------------Kidswant
	UNION ALL
	SELECT left([Date],4) year,CONVERT(VARCHAR(8),CAST([Date] AS DATE),112),'Kidswant' AS Customer,'16' AS Channel_ID,ds.Store_Name AS Store_NM, prod.SKU_ID AS SKU,prod.SKU_Name AS SKU_NM,prod.Brand_Name AS Brand,Product_Sort AS category,0 AS rsp,SUM(CAST(Sales_QTY AS FLOAT)) AS qty,0 AS gs_price,SUM(CAST(Sales_AMT AS FLOAT)) AS pos
	FROM [ODS].[ods].[File_Kidswant_DailySales] ds
    LEFT JOIN dm.Dim_Product prod ON ds.Bar_Code = prod.Bar_Code AND CASE WHEN ds.SKU_Name LIKE '%小猪%' THEN 'PEPPA' WHEN ds.SKU_Name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	LEFT JOIN dm.Dim_Store st ON ds.[Store_Code] = st.Account_Store_Code AND st.Channel_Account = 'KW'
    WHERE store_id IS NOT NULL
 	GROUP BY [Date],prod.SKU_ID,prod.SKU_Name,prod.Brand_Name,Product_Sort,ds.Store_Name
	HAVING SUM(CAST(Sales_QTY AS FLOAT))<>0 AND SUM(CAST(Sales_AMT AS FLOAT))<>0

	UNION ALL
	-------------Vanguard
	
	SELECT left(crv.Datekey,4) year
		,crv.Datekey
		,'Vanguard' AS Customer
		,'15' AS Channel_ID
		,crv.Store_Name AS Store_NM
		,p.SKU_ID AS SKU
		,p.SKU_Name AS SKU_NM
		,p.Brand_Name AS Brand
		,Product_Sort AS category
		,0 AS rsp
		,SUM(CAST(Sale_QTY AS FLOAT)) AS qty
		,0 AS gs_price
		,SUM(CAST(Gross_Sale_Value AS FLOAT)) AS pos
	FROM dm.Fct_CRV_DailySales crv
	JOIN dm.Dim_Product p ON crv.SKU_ID=p.SKU_ID
	GROUP BY crv.Datekey,p.SKU_ID,p.SKU_Name,p.Brand_Name,Product_Sort,crv.Store_Name
	HAVING SUM(CAST(Sale_QTY AS FLOAT))>0 AND SUM(CAST(Gross_Sale_Value AS FLOAT))>0
	
	UNION ALL
	---------------------------------(⊙o⊙)？O2O
	SELECT YEAR(bi.order_create_time) year
		  ,CONVERT(VARCHAR(8),bi.order_create_time,112) AS Datekey 
		  ,'O2O' AS Customer
		  ,'45' AS Channel_ID
		  ,NULL AS Store_NM
		  ,'00000000' AS SKU
		  ,NULL AS SKU_NM
		  ,NULL AS Brand
		  ,NULL AS Category
		  ,NULL AS rsp
		  ,SUM(di.QTY) AS qty
		  ,0 AS gs_price
		  ,SUM(di.payment) AS pos
 	FROM [dm].[Fct_O2O_Order_Detail_info] di
	right JOIN [dm].[Fct_O2O_Order_Base_info] bi on di.Order_id = bi.order_id
	WHERE bi.pay_time IS NOT NULL
	GROUP BY bi.order_create_time
			,bi.order_id
	) as t




	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
