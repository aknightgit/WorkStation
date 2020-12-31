USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_Fxxk_DailyStoreSales]
AS
BEGIN

	--插入3天以内，且未被推送的数据
	DECLARE @day int =7;
  
	--YH sellin Sellout
	SELECT * FROM (
	SELECT 
		Datediff_big(MS, '1970-01-01',CAST(LEFT(CAST(jxt.Calendar_DT AS VARCHAR(8)),4)+'-'+SUBSTRING(CAST(jxt.Calendar_DT AS VARCHAR(8)),5,2)+'-'++SUBSTRING(CAST(jxt.Calendar_DT AS VARCHAR(8)),7,2) AS DATE)) AS TimStamp,
		jxt.Store_ID,
		s.Account_Store_Code AS Store_Code,
		fxxk.Owner_ID,
		fxxk.Fxxk_ID,
		--SUM(CAST(jxt.InStock_QTY*pp.SKU_Price AS decimal(9,2))) AS SellIn,
		SUM(CAST(ISNULL(i.Receipt_QTY,0)*pp.SKU_Price_withTax AS decimal(18,2))) AS SellIn,		
		SUM(CAST(jxt.Sales_AMT AS decimal(18,2))) AS SellOut
		,jxt.Calendar_DT as Datekey
	FROM [dm].[Fct_YH_Sales_Inventory] jxt WITH(NOLOCK)
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) on jxt.Store_ID=s.Store_ID
	LEFT JOIN (SELECT so.Receipt_Datekey,so.Store_ID,so.SKU_ID,SUM(so.Receipt_QTY) Receipt_QTY 
		FROM [dm].[Fct_YH_Store_DailyOrders] so WITH(NOLOCK) 
		JOIN dm.Dim_Store ds on so.Store_ID=ds.Store_ID AND ds.Account_Store_Code not like 'w%'
		WHERE so.Receipt_Datekey>=20200801
		GROUP BY so.Receipt_Datekey,so.Store_ID,so.SKU_ID
		)i ON jxt.Calendar_DT=i.Receipt_Datekey and jxt.SKU_ID=i.SKU_ID and jxt.Store_ID=i.Store_ID
	LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON jxt.SKU_ID=pp.SKU_ID AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
	LEFT JOIN [dm].[Dim_Store_Fxxk] fxxk WITH(NOLOCK) ON s.Account_Store_Code=fxxk.Store_Code AND fxxk.Channel='永辉'	  
	LEFT JOIN [rpt].[Fxxk_DailyStoreSales_Export_Audit] aud WITH(NOLOCK) ON Datediff_big(MS, '1970-01-01', CAST(LEFT(CAST(jxt.Calendar_DT AS VARCHAR(8)),4)+'-'+SUBSTRING(CAST(jxt.Calendar_DT AS VARCHAR(8)),5,2)+'-'++SUBSTRING(CAST(jxt.Calendar_DT AS VARCHAR(8)),7,2) AS DATE))=aud.TS AND jxt.Store_ID=aud.Store_ID
	WHERE jxt.Calendar_DT >= convert(varchar(8),getdate()-@day,112)
		--and s.Account_Store_Code='9011'
		AND fxxk.Owner_ID is not null
		AND fxxk.Fxxk_ID is not null
		AND aud.Store_ID IS NULL
	GROUP BY jxt.Calendar_DT
		,jxt.Store_ID
		,s.Account_Store_Code
		,fxxk.Owner_ID
		,fxxk.Fxxk_ID
	)z WHERE (z.SellIn>0.00 OR z.SellOut>0.00)
	AND z.Datekey <= (SELECT MAX(Receipt_Datekey) FROM [dm].[Fct_YH_Store_DailyOrders] WITH(NOLOCK))
	;

END
GO
