USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_Sales_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [dm].[SP_Fct_YH_Sales_Inventory]
	-- Add the parameters for the stored procedure here
	-- [dm].[Fct_YH_Sales_Inventory] 表中的数据由[ods].[File_YH_Sales] 手工数据和ods.EDI_YH_Sales EDI数据两部分组成，数据更新改成增量后就不再从手工表抽取数据了  20191017
@Total INT = 0
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

IF @Total = 1 
BEGIN
DELETE [dm].[Fct_YH_Sales_Inventory] WHERE Calendar_DT>='20190707'
END
ELSE
BEGIN
------------------------------------------------以过去8天的数据做增量
DELETE [dm].[Fct_YH_Sales_Inventory] WHERE Calendar_DT>CONVERT(VARCHAR(8),DATEADD(DAY,-8,GETDATE()),112)
END


------------------------------------------------获取现在表中最大的时间
DECLARE @MAX_CAL VARCHAR(8) = (SELECT ISNULL(MAX(Calendar_DT),'19900101') FROM [dm].[Fct_YH_Sales_Inventory])
------------------------------------------------获取最后一天销售日期
DECLARE @LAST_DAY_OF_YH_SALES VARCHAR(8) = (SELECT MAX(calday) FROM ODS.ods.EDI_YH_Sales)

---------------------插入数据
INSERT INTO [dm].[Fct_YH_Sales_Inventory]
	  ([SKU_ID]
      ,[Store_ID]
      ,[Calendar_DT]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[DiscountSales_AMT]
      ,[Inventory_AMT]
      ,[Inventory_QTY]
      ,[Inventory_LD_AMT]
      ,[Inventory_LD_QTY]
      ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By])
SELECT prod.SKU_ID
	  ,st.Store_ID
	  ,[Calendar_DT]
	  ,SUM([Sales_AMT]		  ) AS [Sales_AMT]
	  ,SUM([Sales_QTY]		  ) AS [Sales_QTY]
	  ,SUM([DiscountSales_AMT]) AS [DiscountSales_AMT]
	  ,SUM([Inventory_AMT]	  ) AS [Inventory_AMT]
	  ,SUM([Inventory_QTY]	  ) AS [Inventory_QTY]
	  ,SUM([Inventory_LD_AMT] ) AS [Inventory_LD_AMT]
	  ,SUM([Inventory_LD_QTY] ) AS [Inventory_LD_QTY]
	  ,GETDATE() AS [Create_Time]
	  ,@ProcName AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,@ProcName AS [Update_By]
FROM (
------------------------------------------------从ODS.ods.EDI_YH_Sales获取销售数据
	SELECT sal.bar_code AS [YH_UPC]
	      ,goods_name AS SKU_NM
	      ,shop_id AS [YH_Store_CD]
	      ,calday AS [Calendar_DT]
	      ,CAST(sales_amt AS DECIMAL(18,6)) AS [Sales_AMT]				
	      ,CAST(sales_qty AS DECIMAL(18,6)) AS [Sales_QTY]				
	      ,CAST(pro_chg_amt AS DECIMAL(18,6)) AS [DiscountSales_AMT]	
		  ,0 AS [Inventory_AMT]
		  ,0 AS [Inventory_QTY]
		  ,0 AS [Inventory_LD_AMT]
		  ,0 AS [Inventory_LD_QTY]
	FROM ODS.ods.EDI_YH_Sales sal
	WHERE calday>@MAX_CAL AND (CAST(sales_amt AS DECIMAL(18,6))<> 0 OR CAST(sales_qty AS DECIMAL(18,6)) <> 0 OR CAST(pro_chg_amt AS DECIMAL(18,6))<>0)  ---删除度量值为0的行节省空间
------------------------------------------------从ODS.ods.EDI_YH_Inventory获取销售数据
	UNION ALL
	SELECT inv.bar_code AS [YH_UPC]
		  ,goods_name AS SKU_NM
		  ,shop_id AS [YH_Store_CD]
	      ,calday AS [Calendar_DT]
	      ,0 AS [Sales_AMT]				
	      ,0 AS [Sales_QTY]				
	      ,0 AS [DiscountSales_AMT]	
		  ,CAST(inv_amt AS FLOAT) AS [Inventory_AMT]		---存在科学技术法，只能转float
		  ,CAST(inv_qty AS FLOAT) AS [Inventory_QTY]
		  ,0 AS [Inventory_LD_AMT]
		  ,0 AS [Inventory_LD_QTY]
	FROM [ODS].ods.EDI_YH_Inventory AS inv
	WHERE inv.calday>@MAX_CAL AND (CAST(inv_amt AS FLOAT) <> 0 OR CAST(inv_qty AS FLOAT) <> 0) AND calday <= @LAST_DAY_OF_YH_SALES

------------------------------------------------从EDI获取的数据是当天的销售和期末库存，需要当天的期初库存，取前一天的期末库存作为期初库存
	UNION ALL
	SELECT inv.bar_code AS [YH_UPC]
		  ,goods_name AS SKU_NM
		  ,shop_id AS [YH_Store_CD]
	      ,CONVERT(VARCHAR(8),DATEADD(DAY,1,calday),112) AS [Calendar_DT]
	      ,0 AS [Sales_AMT]				
	      ,0 AS [Sales_QTY]				
	      ,0 AS [DiscountSales_AMT]	
		  ,0 AS [Inventory_AMT]
		  ,0 AS [Inventory_QTY]
		  ,CAST(inv_amt AS FLOAT) AS [Inventory_LD_AMT]	
		  ,CAST(inv_qty AS FLOAT) AS [Inventory_LD_QTY]
	FROM [ODS].ods.EDI_YH_Inventory AS inv
	WHERE CONVERT(VARCHAR(8),DATEADD(DAY,1,calday),112)>@MAX_CAL AND (CAST(inv_amt AS FLOAT) <> 0 OR CAST(inv_qty AS FLOAT) <> 0) AND DATEADD(DAY,1,calday) <= @LAST_DAY_OF_YH_SALES --删除天数+1导致的错误数据
) ua
LEFT JOIN DM.Dim_Product Prod ON ua.[YH_UPC] = Prod.Bar_Code AND CASE WHEN ua.SKU_NM LIKE '%小猪%' THEN 'PEPPA' WHEN ua.SKU_NM LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END-------------产品表中瑞奇宝宝和小猪佩奇用的是同一套barcode,存在一个barcode对应多个SKU_ID的情况,要通过产品名称区别,默认用小猪佩奇
LEFT JOIN dm.Dim_Store st ON ua.YH_Store_CD = st.Account_Store_Code AND st.Channel_Account = 'YH'

GROUP BY prod.SKU_ID
	    ,st.Store_ID
	    ,[Calendar_DT]



END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
