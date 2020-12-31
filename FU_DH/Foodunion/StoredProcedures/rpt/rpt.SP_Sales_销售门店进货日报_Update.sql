USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_Sales_销售门店进货日报_Update]
AS
BEGIN

	IF EXISTS (SELECT TOP 1 1 FROM dm.Fct_YH_JXT_Daily WHERE Datekey=CONVERT(VARCHAR(8),GETDATE()-1,112))
	BEGIN

	EXEC [dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update];
	EXEC [dm].[SP_Dim_Store_SalesPerson_Monthly_Update];

	TRUNCATE TABLE rpt.Sales_销售门店进货日报;

	INSERT INTO [rpt].[Sales_销售门店进货日报]
	SELECT sp.Sales_Person '销售'
		,ds.Store_Province '省份'
		,ds.Sales_Area_CN '区域'
		,ds.Account_Store_Code '门店编码'
		,ds.Store_Name '门店名称'
		,p.SKU_ID 'SKU_ID'
		,p.Sale_Scale '规格'
		,p.SKU_Name_CN '产品名称'
		,CAST(SUM(jxt.InStock_QTY) AS INT) AS '最近3日进货数量'
		,CAST(SUM(jxt.Sale_QTY) AS INT) AS '最近3日销售数量'
		,CAST(SUM(jxt.Sale_Amount) AS decimal(9,2)) AS '最近3日销售金额'
		,CAST(SUM(CASE WHEN jxt.Datekey = CONVERT(VARCHAR(8),GETDATE()-1,112) THEN jxt.Sale_QTY ELSE 0 END) AS INT) AS '昨日销售数量'
		,CAST(SUM(CASE WHEN jxt.Datekey = CONVERT(VARCHAR(8),GETDATE()-1,112) THEN jxt.Sale_Amount ELSE 0 END) AS decimal(9,2)) AS '昨日销售金额'
		,NULL,GETDATE(),'[rpt].[SP_Sales_销售门店进货日报_Update]'
	FROM [dm].[Dim_Store_SalesPerson_Monthly] sp with(NOLOCK)
	JOIN dm.Fct_YH_JXT_Daily jxt with(NOLOCK) ON sp.Store_ID=jxt.Store_ID
	JOIN dm.Dim_Product p with(NOLOCK) on jxt.SKU_ID=p.SKU_ID
	JOIN dm.Dim_Store ds with(NOLOCK) ON sp.Store_ID=ds.Store_ID
	WHERE sp.Monthkey=(SELECT MAX(Monthkey) FROM [dm].[Dim_Store_SalesPerson_Monthly] with(NOLOCK))
	AND jxt.Datekey BETWEEN CONVERT(VARCHAR(8),GETDATE()-3,112) AND CONVERT(VARCHAR(8),GETDATE()-1,112)
	GROUP BY sp.Sales_Person
		,ds.Store_Province
		,ds.Sales_Area_CN
		,ds.Account_Store_Code
		,ds.Store_Name
		,p.SKU_ID
		,p.Sale_Scale
		,p.SKU_Name_CN
	HAVING(SUM(jxt.InStock_QTY)>0 OR SUM(CASE WHEN jxt.Datekey = CONVERT(VARCHAR(8),GETDATE()-1,112) THEN jxt.Sale_QTY ELSE 0 END)>0);
	
	END
END
GO
