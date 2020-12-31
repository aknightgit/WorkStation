USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_Sales_YH_SellInOut_Weekly](@Starttime int = null)
AS
BEGIN

------------------判断是否传参，如果参数有值，则参数作为日期条件，没有传参则查询当前日期往前推2周的数据   20201126-----------------------------------
	    IF @Starttime is not null


			BEGIN
				--DECLARE @Start int =20201101
				--select DATEPART(WEEKDAY,getdate())
				--SELECT DATEADD(D,-28,GETDATE())
				--select CONVERT(VARCHAR(8),DATEADD(D,-28 + 2 - DATEPART(WEEKDAY,GETDATE()),GETDATE()),112)
				--返回过去4周的销售数据
				DECLARE @Start int =  @Starttime

				SELECT 
						x.Datekey,
						dc.Week_Nature_Str,
						dc.Week_Day_Name,
						s.Sales_Region,
						s.Store_Province,
						s.Store_City,
						x.Store_ID,
						s.Account_Store_Code AS Store_Code,
						s.Store_Name,
						x.SKU_ID,
						p.SKU_Name_S,
						p.Product_Sort,
						x.SellIn_woVAT,
						x.SellIn_withVAT,
						x.POS
					FROM (
						SELECT ISNULL(so.Datekey,si.Datekey) Datekey,
							ISNULL(so.Store_ID,si.Store_ID) Store_ID,
							ISNULL(so.SKU_ID,si.SKU_ID) SKU_ID,
							ISNULL(si.SellIn_woVAT,0.00) SellIn_woVAT,
							ISNULL(si.SellIn,0.00) SellIn_withVAT,
							ISNULL(so.SellOut,0.00) POS
						FROM 
						(SELECT 
							jxt.Calendar_DT as Datekey,
							jxt.Store_ID,	
							jxt.SKU_ID,
							SUM(CAST(jxt.Sales_AMT AS decimal(18,2))) AS SellOut		
						FROM [dm].[Fct_YH_Sales_Inventory] jxt WITH(NOLOCK)
						WHERE jxt.Calendar_DT >= @Start
							AND jxt.Sales_QTY>0
						GROUP BY jxt.Calendar_DT,
							jxt.Store_ID,
							jxt.SKU_ID
						) so
						FULL JOIN (
							SELECT so.Receipt_Datekey as Datekey
								,so.Store_ID
								,so.SKU_ID
								,SUM(so.Receipt_QTY) Receipt_QTY 
								,SUM(CAST(ISNULL(so.Receipt_QTY*pp.SKU_Price_withTax,0) AS decimal(18,2))) AS SellIn
								,SUM(CAST(ISNULL(so.Receipt_QTY*pp.SKU_Price,0) AS decimal(18,2))) AS SellIn_woVAT
							FROM [dm].[Fct_YH_Store_DailyOrders] so WITH(NOLOCK) 
							JOIN dm.Dim_Store ds on so.Store_ID=ds.Store_ID AND ds.Account_Store_Code not like 'w%'
							LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON so.SKU_ID=pp.SKU_ID 
								AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
							WHERE so.Receipt_Datekey>=20201101 
								AND so.Receipt_Datekey <>'-'
								AND so.Receipt_QTY>0
							GROUP BY so.Receipt_Datekey,so.Store_ID	,so.SKU_ID
						)si ON so.Datekey=si.Datekey AND so.Store_ID=si.Store_ID AND so.SKU_ID=si.SKU_ID
						WHERE ISNULL(so.Datekey,si.Datekey) >= @Start

					)x
					JOIN dm.dim_Store s ON x.Store_ID=s.Store_ID
					JOIN dm.Dim_Calendar dc ON x.Datekey=dc.Datekey
					JOIN dm.Dim_Product p ON x.SKU_ID=p.SKU_ID
						--and s.Account_Store_Code='9011'
						;

			END

		ELSE
			BEGIN
				--DECLARE @Start int =20201101
				--select DATEPART(WEEKDAY,getdate())
				--SELECT DATEADD(D,-28,GETDATE())
				--select CONVERT(VARCHAR(8),DATEADD(D,-28 + 2 - DATEPART(WEEKDAY,GETDATE()),GETDATE()),112)
				--返回过去4周的销售数据
				SELECT @Start = CONVERT(VARCHAR(8),DATEADD(D,-14 + 2 - DATEPART(WEEKDAY,GETDATE()),GETDATE()),112); -- 4 WEEKS before Monday

				SELECT 
					x.Datekey,
					dc.Week_Nature_Str,
					dc.Week_Day_Name,
					s.Sales_Region,
					s.Store_Province,
					s.Store_City,
					x.Store_ID,
					s.Account_Store_Code AS Store_Code,
					s.Store_Name,
					x.SKU_ID,
					p.SKU_Name_S,
					p.Product_Sort,
					x.SellIn_woVAT,
					x.SellIn_withVAT,
					x.POS
				FROM (
					SELECT ISNULL(so.Datekey,si.Datekey) Datekey,
						ISNULL(so.Store_ID,si.Store_ID) Store_ID,
						ISNULL(so.SKU_ID,si.SKU_ID) SKU_ID,
						ISNULL(si.SellIn_woVAT,0.00) SellIn_woVAT,
						ISNULL(si.SellIn,0.00) SellIn_withVAT,
						ISNULL(so.SellOut,0.00) POS
					FROM 
					(SELECT 
						jxt.Calendar_DT as Datekey,
						jxt.Store_ID,	
						jxt.SKU_ID,
						SUM(CAST(jxt.Sales_AMT AS decimal(18,2))) AS SellOut		
					FROM [dm].[Fct_YH_Sales_Inventory] jxt WITH(NOLOCK)
					WHERE jxt.Calendar_DT >= @Start
						AND jxt.Sales_QTY>0
					GROUP BY jxt.Calendar_DT,
						jxt.Store_ID,
						jxt.SKU_ID
					) so
					FULL JOIN (
						SELECT so.Receipt_Datekey as Datekey
							,so.Store_ID
							,so.SKU_ID
							,SUM(so.Receipt_QTY) Receipt_QTY 
							,SUM(CAST(ISNULL(so.Receipt_QTY*pp.SKU_Price_withTax,0) AS decimal(18,2))) AS SellIn
							,SUM(CAST(ISNULL(so.Receipt_QTY*pp.SKU_Price,0) AS decimal(18,2))) AS SellIn_woVAT
						FROM [dm].[Fct_YH_Store_DailyOrders] so WITH(NOLOCK) 
						JOIN dm.Dim_Store ds on so.Store_ID=ds.Store_ID AND ds.Account_Store_Code not like 'w%'
						LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON so.SKU_ID=pp.SKU_ID 
							AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
						WHERE so.Receipt_Datekey>=20201101 
							AND so.Receipt_Datekey <>'-'
							AND so.Receipt_QTY>0
						GROUP BY so.Receipt_Datekey,so.Store_ID	,so.SKU_ID
					)si ON so.Datekey=si.Datekey AND so.Store_ID=si.Store_ID AND so.SKU_ID=si.SKU_ID
					WHERE ISNULL(so.Datekey,si.Datekey) >= @Start

				)x
				JOIN dm.dim_Store s ON x.Store_ID=s.Store_ID
				JOIN dm.Dim_Calendar dc ON x.Datekey=dc.Datekey
				JOIN dm.Dim_Product p ON x.SKU_ID=p.SKU_ID
 
					--and s.Account_Store_Code='9011'
		;
			END

	
END


/*
--月度门店sellin POS

	SELECT * FROM(
	SELECT 
		DC.Monthkey,
		--yh.Calendar_DT as Datekey,
		--dc.Week_Nature_Str,
		--dc.Week_Day_Name,
		s.Sales_Region,
		s.Store_Province,
		s.Store_City,
		yh.Store_ID,
		s.Account_Store_Code AS Store_Code,
		s.Store_Name,
		--yh.SKU_ID,
		--p.SKU_Name_S,
		--p.Product_Sort,
		SUM(CAST(ISNULL(i.Receipt_QTY*pp.SKU_Price,0) AS decimal(18,2))) AS SellIn_woVAT,	
		SUM(CAST(ISNULL(i.Receipt_QTY*pp.SKU_Price_withTax,0) AS decimal(18,2))) AS SellIn_withVAT,		
		SUM(CAST(yh.Sales_AMT AS decimal(18,2))) AS POS		
	FROM [dm].[Fct_YH_Sales_Inventory] yh WITH(NOLOCK)
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) on yh.Store_ID=s.Store_ID
	JOIN [dm].[dim_product] p WITH(NOLOCK) on yh.sku_id=p.sku_id
	JOIN [dm].[Dim_Calendar] dc WITH(NOLOCK) ON yh.Calendar_DT = dc.Datekey
	LEFT JOIN (SELECT so.Receipt_Datekey,so.Store_ID,so.SKU_ID,SUM(so.Receipt_QTY) Receipt_QTY 
		FROM [dm].[Fct_YH_Store_DailyOrders] so WITH(NOLOCK) 
		JOIN dm.Dim_Store ds WITH(NOLOCK) on so.Store_ID=ds.Store_ID AND ds.Account_Store_Code not like 'w%'
		WHERE so.Receipt_Datekey>=20200801 
		AND so.Receipt_Datekey <>'-'
		GROUP BY so.Receipt_Datekey,so.Store_ID,so.SKU_ID
		)i ON yh.Calendar_DT=i.Receipt_Datekey and yh.SKU_ID=i.SKU_ID and yh.Store_ID=i.Store_ID
	LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON yh.SKU_ID=pp.SKU_ID 
		AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
	
	WHERE yh.Calendar_DT >= 20201001
	GROUP BY DC.Monthkey,
		--yh.Calendar_DT as Datekey,
		--dc.Week_Nature_Str,
		--dc.Week_Day_Name,
		s.Sales_Region,
		s.Store_Province,
		s.Store_City,
		yh.Store_ID,
		s.Account_Store_Code ,
		s.Store_Name

	UNION

	SELECT 
		DC.Monthkey,
		--yh.Calendar_DT as Datekey,
		--dc.Week_Nature_Str,
		--dc.Week_Day_Name,
		s.Sales_Region,
		s.Store_Province,
		s.Store_City,
		yh.Store_ID,
		s.Account_Store_Code AS Store_Code,
		s.Store_Name,
		--yh.SKU_ID,
		--p.SKU_Name_S,
		--p.Product_Sort,
		SUM(CAST(ISNULL(yh.InStock_QTY*pp.SKU_Price,0) AS decimal(18,2))) AS SellIn_woVAT,	
		SUM(CAST(ISNULL(yh.InStock_QTY*pp.SKU_Price_withTax,0) AS decimal(18,2))) AS SellIn_withVAT,		
		SUM(CAST(yh.Sale_Amount AS decimal(18,2))) AS POS		
	FROM [dm].[Fct_YH_JXT_Daily] yh WITH(NOLOCK)
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) on yh.Store_ID=s.Store_ID
	JOIN [dm].[dim_product] p WITH(NOLOCK) on yh.sku_id=p.sku_id
	JOIN [dm].[Dim_Calendar] dc WITH(NOLOCK) ON yh.Datekey = dc.Datekey
	--LEFT JOIN (SELECT so.Receipt_Datekey,so.Store_ID,so.SKU_ID,SUM(so.Receipt_QTY) Receipt_QTY 
	--	FROM [dm].[Fct_YH_Store_DailyOrders] so WITH(NOLOCK) 
	--	JOIN dm.Dim_Store ds WITH(NOLOCK) on so.Store_ID=ds.Store_ID AND ds.Account_Store_Code not like 'w%'
	--	WHERE so.Receipt_Datekey>=20200801 
	--	AND so.Receipt_Datekey <>'-'
	--	GROUP BY so.Receipt_Datekey,so.Store_ID,so.SKU_ID
	--	)i ON yh.Calendar_DT=i.Receipt_Datekey and yh.SKU_ID=i.SKU_ID and yh.Store_ID=i.Store_ID
	LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON yh.SKU_ID=pp.SKU_ID 
		AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
	
	WHERE yh.Datekey between 20200101 and 20200931
	GROUP BY DC.Monthkey,
		--yh.Calendar_DT as Datekey,
		--dc.Week_Nature_Str,
		--dc.Week_Day_Name,
		s.Sales_Region,
		s.Store_Province,
		s.Store_City,
		yh.Store_ID,
		s.Account_Store_Code ,
		s.Store_Name

	)z WHERE (z.SellIn_woVAT>0.00 OR z.POS>0.00)
	order by 1,2,3

	*/

	--select top 10 *from dm.Dim_Product


GO
