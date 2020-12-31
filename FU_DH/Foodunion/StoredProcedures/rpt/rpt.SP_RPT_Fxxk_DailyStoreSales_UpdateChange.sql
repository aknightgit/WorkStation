USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [rpt].[SP_RPT_Fxxk_DailyStoreSales_UpdateChange]
AS
BEGIN

	--更新14天内推送过，且有发生变化的数据
	DECLARE @day int =14;
  
	--YH sellin Sellout
	SELECT z.*,
		aud.ID    -- DATA ID IN FXXK		 
	FROM (
	SELECT 
		yh.Calendar_DT AS Datekey,
		Datediff_big(MS, '1970-01-01',CAST(LEFT(CAST(yh.Calendar_DT AS VARCHAR(8)),4)+'-'+SUBSTRING(CAST(yh.Calendar_DT AS VARCHAR(8)),5,2)+'-'++SUBSTRING(CAST(yh.Calendar_DT AS VARCHAR(8)),7,2) AS DATE)) AS TimStamp,
		yh.Store_ID,
		s.Account_Store_Code AS Store_Code,
		fxxk.Owner_ID,
		fxxk.Fxxk_ID,
		--SUM(CAST(yh.InStock_QTY*pp.SKU_Price AS decimal(9,2))) AS SellIn,
		SUM(CAST(ISNULL(i.Receipt_QTY,0)*pp.SKU_Price_withTax AS decimal(18,2))) AS SellIn,		
		SUM(CAST(yh.Sales_AMT AS decimal(18,2))) AS SellOut
	FROM [dm].[Fct_YH_Sales_Inventory] yh WITH(NOLOCK)
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) on yh.Store_ID=s.Store_ID
	LEFT JOIN (SELECT so.Receipt_Datekey,so.Store_ID,so.SKU_ID,SUM(so.Receipt_QTY) Receipt_QTY 
		FROM [dm].[Fct_YH_Store_DailyOrders] so WITH(NOLOCK) 
		JOIN dm.Dim_Store ds on so.Store_ID=ds.Store_ID AND ds.Account_Store_Code not like 'w%'
		WHERE so.Receipt_Datekey>=20200801
			AND so.Receipt_Datekey <>'-'
		GROUP BY so.Receipt_Datekey,so.Store_ID,so.SKU_ID
		)i ON yh.Calendar_DT=i.Receipt_Datekey and yh.SKU_ID=i.SKU_ID and yh.Store_ID=i.Store_ID
	LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON yh.SKU_ID=pp.SKU_ID AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
	LEFT JOIN [dm].[Dim_Store_Fxxk] fxxk WITH(NOLOCK) ON s.Account_Store_Code=fxxk.Store_Code AND fxxk.Channel='永辉'		
	WHERE yh.Calendar_DT >= convert(varchar(8),getdate()-@day,112)		
		--and s.Account_Store_Code='9011'
		AND fxxk.Owner_ID is NOT null
		AND fxxk.Fxxk_ID is NOT null		
	GROUP BY yh.Calendar_DT
		,yh.Store_ID
		,s.Account_Store_Code
		,fxxk.Owner_ID
		,fxxk.Fxxk_ID	
	)z 
	INNER JOIN [rpt].[Fxxk_DailyStoreSales_Export_Audit] aud WITH(NOLOCK) ON z.Datekey=aud.Datekey AND z.Store_ID=aud.Store_ID
	WHERE  (aud.SellIn <> z.SellIn OR z.SellOut <> aud.SellOut) -- some changes since last update
		AND (z.SellIn>0.00 OR z.SellOut>0.00)
	ORDER BY 1,3
	;

END
GO
