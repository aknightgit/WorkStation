USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_Sales_StoreRepDailyReport_Update]
AS
BEGIN

	TRUNCATE TABLE DataMart.rpt.Sales_StoreRepDailyReport;
	
	;with jxt AS (SELECT jxt.Datekey,
			sp.Sales_Person,
			ds.Account_Store_Code,
			ds.Store_Name,
			jxt.SKU_ID,
			p.SKU_Name_CN,
			jxt.InStock_QTY,
			jxt.Sale_Amount,
			jxt.Sale_QTY
	FROM [dm].[Dim_Store_SalesPerson_Monthly] sp with(NOLOCK)
	JOIN [dm].[Fct_YH_JXT_Daily] jxt with(NOLOCK) ON sp.Store_ID=jxt.Store_ID AND sp.Monthkey=jxt.Datekey/100
	JOIN [dm].[Dim_Product] p with(NOLOCK) ON jxt.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Store] ds with(NOLOCK) ON sp.Store_ID=ds.Store_ID
	WHERE sp.Monthkey=(SELECT MAX(Monthkey) FROM [dm].[Dim_Store_SalesPerson_Monthly] with(NOLOCK))
	AND jxt.Sale_Amount * jxt.Sale_QTY * jxt.InStock_QTY>0
	)
	INSERT INTO [DataMart].[rpt].[Sales_StoreRepDailyReport]
           ([Date]
           ,[SalesRep]
		   ,[Mobile]
           ,[Store]           
           ,[D-1_Sales_Amount]
           ,[D-1_Best_Selling_SKU]
           ,[OOS_SKUs]
           ,[L3D_InStock_QTY]
           ,[L3D_Sales_QTY]
           ,[MTD_Sales_Amount]
           ,[Monthly_Target]
           ,[MTD_Arc%]
		   ,[Rank_by_MTD_Sales_Amount]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])	
	SELECT CAST(GETDATE() AS DATE) AS [Date],
		a.Sales_Person AS [SalesRep],
		'',
		a.Store_Name AS [Store],
		ISNULL(c.Sale_Amount,0) AS [D-1 Sales Amount],
		ISNULL(b.SKU_Name_CN,'昨日无销量') AS [D-1 Best Selling SKU],
		'' AS [OOS SKUs],
		ISNULL(d.InStock_QTY,0) AS [L3D InStock QTY],
		ISNULL(d.Sale_QTY,0) AS [L3D Sales QTY],
		ISNULL(e.Sale_Amount,0.00) AS [MTD Sales Amount],
		ISNULL(f.SellOut_TGT,0.00) AS [Monthly Target],
		CASE WHEN f.SellOut_TGT=0 THEN NULL ELSE CAST(CAST(ISNULL(e.Sale_Amount,0)/f.SellOut_TGT * 100 AS decimal(18,1)) AS VARCHAR(50))+'%' END AS [MTD Arc%],
		e.RID AS [Rank by MTD Sales Amount],
		GETDATE(),
		'[rpt].[SP_Sales_StoreRepDailyReport_Update]',
		GETDATE(),
		'[rpt].[SP_Sales_StoreRepDailyReport_Update]'

	FROM 
	(SELECT DISTINCT Sales_Person,Store_Name,Account_Store_Code AS Store_Code FROM jxt) a  --人、店
	LEFT JOIN ( 
		SELECT Sales_Person,Store_Name,SKU_Name_CN,SUM(Sale_Amount) Sale_Amount,RANK() OVER(PARTITION BY Sales_Person,Store_Name ORDER BY SUM(Sale_Amount) DESC) RID 
		FROM jxt
		WHERE Datekey=CONVERT(VARCHAR(8),GETDATE()-1,112)
		GROUP BY Sales_Person,Store_Name,SKU_Name_CN
		)b ON a.Sales_Person=b.Sales_Person AND a.Store_Name=b.Store_Name AND b.RID=1 --最近一日销售最好的SKU
	LEFT JOIN ( 
		SELECT Sales_Person,Store_Name,SUM(Sale_Amount) Sale_Amount 
		FROM jxt
		WHERE Datekey=CONVERT(VARCHAR(8),GETDATE()-1,112)
		GROUP BY Sales_Person,Store_Name
		)c ON a.Sales_Person=c.Sales_Person AND a.Store_Name=c.Store_Name  --最近一日门店销售
	LEFT JOIN ( 
		SELECT Sales_Person,Store_Name,SUM(Sale_QTY) Sale_QTY ,SUM(InStock_QTY) InStock_QTY
		FROM jxt
		WHERE Datekey>=CONVERT(VARCHAR(8),GETDATE()-3,112)
		GROUP BY Sales_Person,Store_Name
		)d ON a.Sales_Person=d.Sales_Person AND a.Store_Name=d.Store_Name  --最近3日门店进货销售数量
	LEFT JOIN ( 
		SELECT Sales_Person,Store_Name,SUM(Sale_Amount) Sale_Amount, RANK() OVER(PARTITION BY Sales_Person ORDER BY SUM(Sale_Amount) DESC) RID
		FROM jxt
		WHERE Datekey/100=CONVERT(VARCHAR(6),GETDATE(),112)
		GROUP BY Sales_Person,Store_Name
		)e ON a.Sales_Person=e.Sales_Person AND a.Store_Name=e.Store_Name  --MTD门店销售/名下门店MTD销量排名
	LEFT JOIN (
		SELECT SalesPerson,StoreCode,MAX(CAST(SellOut AS decimal(18,2))) AS SellOut_TGT FROM ODS.ODS.File_Sales_SellInOutTarget_byStore
		WHERE Month=CONVERT(VARCHAR(6),GETDATE(),112)
		GROUP BY SalesPerson,StoreCode
		)f ON a.Sales_Person=f.SalesPerson AND a.Store_Code=f.StoreCode

	--ORDER BY [SalesRep],[Rank by MTD Sales Amount]
		

	
			

	

END
GO
