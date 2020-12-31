USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dm].[SP_Fct_MiniSOP_Forecast_Update_20200117]
AS 
BEGIN

	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	DELETE msf
	FROM [dm].[Fct_MiniSOP_Forecast] msf
	JOIN ODS.[ods].[File_MiniSOP] ods ON msf.[Period]=ods.[Period];	

	INSERT INTO [dm].[Fct_MiniSOP_Forecast]
           ([Period]
           ,[Year]
           ,[Week_no]
           ,[SKU_ID]
           ,[Barcode]
           ,[Category]
           ,[Brand]
           ,[Family]
           ,[Product_Description_EN]
           ,[Product_Description_CN]
           ,[Plant]
           ,[Sales_Territory]
           ,[RDC]
           ,[Channel]
           ,[Baseline_Forecast]
           ,[Promotion]
           ,[Order_Qty]
           ,[Ship_to_Qty]
           ,[OTIF]
           ,[Sell_out_Qty]
           ,[Sell_out_Vs_Forecast]
           ,[Closing_Inv]
           ,[Inv_Coverage_Days]
           ,[Date]
           ,[SaleManager]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT [Period]
           ,[Year]
           ,[Week_no]
           ,[SKU_ID]
           ,[Barcode]
           ,[Category]
           ,[Brand]
           ,[Family]
           ,[Product_Description_EN]
           ,[Product_Description_CN]
           ,[Plant]
           ,[Sales_Territory]
           ,[RDC]
           ,[Channel]
           ,[Baseline_Forecast]
           ,[Promotion]
           ,[Order_Qty]
           ,[Ship_to_Qty]
           ,[OTIF]
           ,[Sell_out_Qty]
           ,[Sell_out_Vs_Forecast]
           ,[Closing_Inv]
           ,[Inv_Coverage_Days]
           ,[Date]
           ,[SaleManager]
		   ,GETDATE(),@ProcName
		   ,GETDATE(),@ProcName
	FROM ODS.[ods].[File_MiniSOP];

	--SELECT * FROM [dm].[Fct_MiniSOP_Forecast]
	--每周动销
	--HK/香港
	DROP TABLE IF EXISTS #saleQTY;
	SELECT 
	--top 10 
		CASE WHEN s.Store_Province='内蒙古' THEN 'IM/内蒙'
			WHEN s.Store_Province='北京市' THEN 'BJ/北京'
			WHEN s.Store_Province='天津市' THEN 'TJ/天津'
			WHEN s.Store_Province='山东省' THEN 'SD/山东'
			WHEN s.Store_Province='重庆市' THEN 'CQ/重庆'
			WHEN s.Store_Province='四川省' THEN 'CD/成都'
			WHEN s.Store_Province='安徽省' THEN 'AH/安徽'
			WHEN s.Store_Province='江苏省' THEN 'JS/江苏'
			WHEN s.Store_Province='浙江省' THEN 'ZJ/浙江'
			WHEN s.Store_Province='上海市' THEN 'SH/上海'
			WHEN s.Store_Province='吉林省' THEN 'JL/吉林'
			WHEN s.Store_Province='黑龙江省' THEN 'HLJ/黑龙江'
			WHEN s.Store_Province='辽宁省' THEN 'LN/辽宁'
			WHEN s.Store_Province='河北省' THEN 'HB/河北'
			WHEN s.Store_Province='河南省' THEN 'HN/河南'
			WHEN s.Store_Province='陕西省' THEN 'SX/陕西'
			WHEN s.Store_Province='江西省' THEN 'JX/江西'
			WHEN s.Store_Province='广东省' THEN 'GD/广东'
			ELSE '' END AS Territory
		,dc.Year
		,dc.Week_Year_NBR
		,p.SKU_ID
		,CASE WHEN s.Channel_Account='Vanguard' THEN 'VG' ELSE s.Channel_Account END AS Channel_Account
		,sum(Sales_Qty) AS Sell_Out_Qty
	INTO #saleQTY
	FROM dm.Fct_KAStore_DailySalesInventory ka
	JOIN dm.Dim_Product p ON ka.SKU_ID=p.SKU_ID
	JOIN dm.Dim_Store s ON KA.Store_ID=s.Store_ID
	JOIN FU_EDW.Dim_Calendar dc on ka.Datekey=dc.Date_ID
	GROUP BY CASE WHEN s.Store_Province='内蒙古' THEN 'IM/内蒙'
			WHEN s.Store_Province='北京市' THEN 'BJ/北京'
			WHEN s.Store_Province='天津市' THEN 'TJ/天津'
			WHEN s.Store_Province='山东省' THEN 'SD/山东'
			WHEN s.Store_Province='重庆市' THEN 'CQ/重庆'
			WHEN s.Store_Province='四川省' THEN 'CD/成都'
			WHEN s.Store_Province='安徽省' THEN 'AH/安徽'
			WHEN s.Store_Province='江苏省' THEN 'JS/江苏'
			WHEN s.Store_Province='浙江省' THEN 'ZJ/浙江'
			WHEN s.Store_Province='上海市' THEN 'SH/上海'
			WHEN s.Store_Province='吉林省' THEN 'JL/吉林'
			WHEN s.Store_Province='黑龙江省' THEN 'HLJ/黑龙江'
			WHEN s.Store_Province='辽宁省' THEN 'LN/辽宁'
			WHEN s.Store_Province='河北省' THEN 'HB/河北'
			WHEN s.Store_Province='河南省' THEN 'HN/河南'
			WHEN s.Store_Province='陕西省' THEN 'SX/陕西'
			WHEN s.Store_Province='江西省' THEN 'JX/江西'
			WHEN s.Store_Province='广东省' THEN 'GD/广东'
			ELSE '' END
		,dc.Year
		,dc.Week_Year_NBR
		,p.SKU_ID
		,CASE WHEN s.Channel_Account='Vanguard' THEN 'VG' ELSE s.Channel_Account END ;
			
	--每周期末库存
	SELECT CASE WHEN s.Store_Province='内蒙古' THEN 'IM/内蒙'
			WHEN s.Store_Province='北京市' THEN 'BJ/北京'
			WHEN s.Store_Province='天津市' THEN 'TJ/天津'
			WHEN s.Store_Province='山东省' THEN 'SD/山东'
			WHEN s.Store_Province='重庆市' THEN 'CQ/重庆'
			WHEN s.Store_Province='四川省' THEN 'CD/成都'
			WHEN s.Store_Province='安徽省' THEN 'AH/安徽'
			WHEN s.Store_Province='江苏省' THEN 'JS/江苏'
			WHEN s.Store_Province='浙江省' THEN 'ZJ/浙江'
			WHEN s.Store_Province='上海市' THEN 'SH/上海'
			WHEN s.Store_Province='吉林省' THEN 'JL/吉林'
			WHEN s.Store_Province='黑龙江省' THEN 'HLJ/黑龙江'
			WHEN s.Store_Province='辽宁省' THEN 'LN/辽宁'
			WHEN s.Store_Province='河北省' THEN 'HB/河北'
			WHEN s.Store_Province='河南省' THEN 'HN/河南'
			WHEN s.Store_Province='陕西省' THEN 'SX/陕西'
			WHEN s.Store_Province='江西省' THEN 'JX/江西'
			WHEN s.Store_Province='广东省' THEN 'GD/广东'
			ELSE '' END AS Territory
		,wkd.Year
		,wkd.Week_Year_NBR
		,ka.SKU_ID
		,CASE WHEN s.Channel_Account='Vanguard' THEN 'VG' ELSE s.Channel_Account END AS Channel_Account
		,SUM(ka.Inventory_Qty) AS Ending_QTY
	INTO #tmpInv
	FROM dm.Fct_KAStore_DailySalesInventory ka
	JOIN dm.Dim_Store s ON KA.Store_ID=s.Store_ID
	JOIN (
		SELECT Year,Week_Year_NBR,MAX(Date_ID) Date_ID from FU_EDW.Dim_Calendar
		GROUP BY Year,Week_Year_NBR
	)wkd ON wkd.Date_ID = ka.Datekey
	--WHERE wkd.Year=2019 
	--AND wkd.Week_Year_NBR=37
	GROUP BY CASE WHEN s.Store_Province='内蒙古' THEN 'IM/内蒙'
			WHEN s.Store_Province='北京市' THEN 'BJ/北京'
			WHEN s.Store_Province='天津市' THEN 'TJ/天津'
			WHEN s.Store_Province='山东省' THEN 'SD/山东'
			WHEN s.Store_Province='重庆市' THEN 'CQ/重庆'
			WHEN s.Store_Province='四川省' THEN 'CD/成都'
			WHEN s.Store_Province='安徽省' THEN 'AH/安徽'
			WHEN s.Store_Province='江苏省' THEN 'JS/江苏'
			WHEN s.Store_Province='浙江省' THEN 'ZJ/浙江'
			WHEN s.Store_Province='上海市' THEN 'SH/上海'
			WHEN s.Store_Province='吉林省' THEN 'JL/吉林'
			WHEN s.Store_Province='黑龙江省' THEN 'HLJ/黑龙江'
			WHEN s.Store_Province='辽宁省' THEN 'LN/辽宁'
			WHEN s.Store_Province='河北省' THEN 'HB/河北'
			WHEN s.Store_Province='河南省' THEN 'HN/河南'
			WHEN s.Store_Province='陕西省' THEN 'SX/陕西'
			WHEN s.Store_Province='江西省' THEN 'JX/江西'
			WHEN s.Store_Province='广东省' THEN 'GD/广东'
			ELSE '' END 
		,wkd.Year
		,wkd.Week_Year_NBR
		,ka.SKU_ID
		,CASE WHEN s.Channel_Account='Vanguard' THEN 'VG' ELSE s.Channel_Account END;

	--未来3周预计动销
	SELECT f.Period
		,f.Sales_Territory AS Territory
		,d.Year
		,d.Week_Year_NBR
		,f.SKU_ID
		,f.Channel
		,SUM(CASE WHEN (f.YEAR >= d.nextweekyear AND f.Week_no>=d.nextweek) AND (f.YEAR<=d.next3weekyear and f.Week_no<=d.next3week) THEN f.Baseline_Forecast+f.Promotion
		ELSE 0 END) AS Week3Sales
	INTO #week3Sales
	FROM [dm].[Fct_MiniSOP_Forecast] f
	--JOIN dm.Dim_Store s ON KA.Store_ID=s.Store_ID
	JOIN (SELECT Year,Week_Year_NBR,Datepart(year,Dateadd(DAY,1,MAX(Date_NM))) AS nextweekyear,Datepart(week,Dateadd(DAY,1,MAX(Date_NM))) AS nextweek
		,Datepart(year,Dateadd(DAY,21,MAX(Date_NM))) AS next3weekyear,Datepart(week,Dateadd(DAY,21,MAX(Date_NM))) AS next3week
		FROM FU_EDW.Dim_Calendar 
		GROUP BY Year,Week_Year_NBR)d ON f.Year=d.Year AND f.Week_no=d.Week_Year_NBR
	GROUP BY  f.Period
		,f.Sales_Territory 
		,d.Year
		,d.Week_Year_NBR
		,f.SKU_ID
		,f.Channel;

	UPDATE f
		SET f.Sell_out_Qty = tmp.Sell_Out_Qty
		,[Sell_out_Vs_Forecast] = 1 - abs(tmp.Sell_Out_Qty-isnull([Baseline_Forecast],0)-isnull([Promotion],0))/([Baseline_Forecast]+[Promotion])
	FROM [dm].[Fct_MiniSOP_Forecast] f
	JOIN #saleQTY tmp
	ON f.Year=tmp.Year 
		AND f.Week_No=tmp.Week_Year_NBR 
		AND f.Sales_Territory=tmp.Territory 
		AND f.SKU_ID=tmp.SKU_ID 
		AND f.Channel=tmp.Channel_Account;

	UPDATE f
		SET f.Closing_Inv = tmp.Ending_QTY
	FROM [dm].[Fct_MiniSOP_Forecast] f
	JOIN #tmpInv tmp
	ON f.Year=tmp.Year 
		AND f.Week_No=tmp.Week_Year_NBR 
		AND f.Sales_Territory=tmp.Territory 
		AND f.SKU_ID=tmp.SKU_ID 
		AND f.Channel=tmp.Channel_Account;
	
	UPDATE f
		SET f.[Inv_Coverage_Days] = CASE WHEN tmp.Week3Sales=0 THEN NULL ELSE f.Closing_Inv/ (tmp.Week3Sales/21) END   --以未来3周销量预估，计算库存天数
	FROM [dm].[Fct_MiniSOP_Forecast] f
	JOIN #week3Sales tmp
	ON  f.Period = tmp.Period
		AND f.Year=tmp.Year 
		AND f.Week_No=tmp.Week_Year_NBR 
		AND f.Sales_Territory=tmp.Territory 
		AND f.SKU_ID=tmp.SKU_ID 
		AND f.Channel=tmp.Channel;
	
	

	--SELECT DISTINCT Store_Province FROM  dm.Dim_Store
	--select top 100 * from FU_EDW.Dim_Calendar where Week_Year_NBR=37
	--SELECT * FROM dm.Fct_KAStore_DailySalesInventory where Store_ID in (select store_id from dm.dim_store where Channel_Account='yh' and Store_Province='北京市')
	--and sku_id='2100062' and datekey between 20190909 and 20190915
	

	END TRY
	BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	 RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
