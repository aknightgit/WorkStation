USE [Foodunion]
GO
DROP PROCEDURE [dw].[SP_Fct_YH_Sales_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE PROC  [dw].[SP_Fct_YH_Sales_Inventory]
AS 
BEGIN

 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY

TRUNCATE TABLE  dw.[Fct_YH_Sales_Inventory]


--------------------------YH_Sales


SELECT 
       [YH_UPC]
	  ,prod.SKU_Name_CN AS SKU_NM
      ,[YH_Store_CD]
      ,[Calendar_DT]
      ,SUM([Sales_AMT]				 )			AS	  [Sales_AMT]
      ,SUM([Sales_QTY]				 )			AS	  [Sales_QTY]
      ,SUM([DiscountSales_AMT]		 )			AS	  [DiscountSales_AMT]
      ,SUM([DiscountSales_QTY]		 )			AS	  [DiscountSales_QTY]
      ,SUM([WithTax_SalesCost_AMT]	 )			AS	  [WithTax_SalesCost_AMT]
      ,SUM([Sals_Share_PC]			 )			AS	  [Sals_Share_PC]
      ,SUM([WithTax_Discount_AMT]	 )			AS	  [WithTax_Discount_AMT]
      ,SUM([Gross_WithTax_AMT]		 )			AS	  [Gross_WithTax_AMT]
      ,SUM([Gross_WithTax_PC]		 )			AS	  [Gross_WithTax_PC]
	  INTO #YH_Sales
FROM(
   SELECT 
       [YH_UPC]
	  ,SKU_NM
      ,[YH_Store_CD]
      ,[Calendar_DT]
      ,[Sales_AMT]				
      ,[Sales_QTY]				
      ,[DiscountSales_AMT]		
      ,[DiscountSales_QTY]		
      ,[WithTax_SalesCost_AMT]	
      ,[Sals_Share_PC]			
      ,[WithTax_Discount_AMT]	
      ,[Gross_WithTax_AMT]		
      ,[Gross_WithTax_PC]		

  FROM [ODS].[ods].[File_YH_Sales]
  WHERE Calendar_DT <= '2019-06-30'
  UNION ALL 
     SELECT 
       bar_code AS [YH_UPC]
	  ,goods_name
      ,shop_id AS [YH_Store_CD]
      ,CAST(calday AS DATE) AS [Calendar_DT]
      ,sales_amt AS [Sales_AMT]				
      ,sales_qty AS [Sales_QTY]				
      ,pro_chg_amt AS [DiscountSales_AMT]		
      ,NULL AS [DiscountSales_QTY]		
      ,NULL AS [WithTax_SalesCost_AMT]	
      ,NULL AS [Sals_Share_PC]			
      ,NULL AS [WithTax_Discount_AMT]	
      ,NULL AS [Gross_WithTax_AMT]		
      ,NULL AS [Gross_WithTax_PC]	
  FROM ODS.ods.EDI_YH_Sales
  WHERE calday>='20190701'
  ) sal
	  LEFT JOIN DM.Dim_Product Prod ON sal.[YH_UPC] = Prod.Bar_Code AND CASE WHEN sal.SKU_NM LIKE '%Ð¡Öí%' THEN 'PEPPA' WHEN sal.SKU_NM LIKE '%ÈðÆæ%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	
  GROUP BY 
       [YH_UPC]
	   ,prod.SKU_Name_CN
      ,[YH_Store_CD]
      ,[Calendar_DT]


------------------------------YH_Inventory
SELECT [YH_UPC]
      ,SKU_NM
      ,[YH_Store_CD]
      ,[Calendar_DT]
      ,SUM([Inventory_AMT]) AS [Inventory_AMT]
      ,SUM([Inventory_WithTax_AMT]) AS [Inventory_WithTax_AMT]
      ,SUM([Inventory_QTY]) AS [Inventory_QTY]
	  INTO #YH_Inventory
  FROM (SELECT [YH_UPC]
      ,prod.SKU_Name_CN AS SKU_NM
      ,[YH_Store_CD]
      ,CAST([Calendar_DT] AS DATE) AS [Calendar_DT]
      ,[Inventory_AMT]
      ,[Inventory_WithTax_AMT]
      ,[Inventory_QTY]
FROM [ODS].[ods].[File_YH_Inventory] AS inv
LEFT JOIN dm.Dim_Product prod ON inv.YH_UPC = prod.Bar_Code
WHERE inv.Calendar_DT<='2019-07-06'
UNION ALL
SELECT inv.bar_code
	,prod.SKU_Name_CN
	,shop_id
	,CAST(calday AS DATE)
	,inv_amt
	,0
	,inv_qty
FROM [ODS].ods.EDI_YH_Inventory AS inv
LEFT JOIN dm.Dim_Product prod ON inv.bar_code = prod.Bar_Code
WHERE inv.calday>'20190706'
) AS Base
	  GROUP BY
       [YH_UPC]
	  ,SKU_NM
      ,[YH_Store_CD]
      ,[Calendar_DT]




------------------------------YH_Inventory_LD

	SELECT [YH_UPC]
      ,SKU_NM
      ,[YH_Store_CD]
      ,DATEADD(DAY,1,[Calendar_DT]) AS [Calendar_DT]
      ,SUM([Inventory_AMT]) AS [Inventory_AMT]
      ,SUM([Inventory_WithTax_AMT]) AS [Inventory_WithTax_AMT]
      ,SUM([Inventory_QTY]) AS [Inventory_QTY]
	  INTO #YH_Inventory_LD
  FROM (SELECT [YH_UPC]
      ,prod.SKU_Name_CN AS SKU_NM
      ,[YH_Store_CD]
      ,CAST([Calendar_DT] AS DATE) AS [Calendar_DT]
      ,[Inventory_AMT]
      ,[Inventory_WithTax_AMT]
      ,[Inventory_QTY]
FROM [ODS].[ods].[File_YH_Inventory] AS inv
LEFT JOIN dm.Dim_Product prod ON inv.YH_UPC = prod.Bar_Code
WHERE inv.Calendar_DT<='2019-07-06'
UNION ALL
SELECT inv.bar_code
	,prod.SKU_Name_CN
	,shop_id
	,CAST(calday AS DATE)
	,inv_amt
	,0
	,inv_qty
FROM [ODS].ods.EDI_YH_Inventory AS inv
LEFT JOIN dm.Dim_Product prod ON inv.bar_code = prod.Bar_Code
WHERE inv.calday>'20190706'
) AS Base
	  GROUP BY
       [YH_UPC]
	  ,SKU_NM
      ,[YH_Store_CD]
      ,[Calendar_DT]


----------------------get last day of yh sales
DECLARE @LAST_DAY_OF_YH_SALES DATE
SELECT @LAST_DAY_OF_YH_SALES = MAX(Calendar_DT) FROM #YH_Sales







INSERT INTO dw.[Fct_YH_Sales_Inventory](
	   [YH_Type]
      ,[YH_Type_CN]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[YH_UPC]
      ,[Region_CD]
      ,[Region_NM]
      ,[YH_Store_CD]
	  ,[Store_ID]
      ,[Store_NM]
      ,[Calendar_DT]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[DiscountSales_AMT]
      ,[DiscountSales_QTY]
      ,[WithTax_SalesCost_AMT]
      ,[Sals_Share_PC]
      ,[WithTax_Discount_AMT]
      ,[Gross_WithTax_AMT]
      ,[Gross_WithTax_PC]
      ,[Inventory_AMT]
      ,[Inventory_WithTax_AMT]
      ,[Inventory_QTY]
      ,[Inventory_LD_AMT]
      ,[Inventory_WithTax_LD_AMT]
      ,[Inventory_LD_QTY]
	  ,[Is_Sold_FL]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
)
 SELECT NULL AS  [YH_Type]    
       ,NULL AS  [YH_Type_CN] 
       ,Prod.SKU_ID	  AS  [SKU_ID]	  
       ,Prod.SKU_Name  AS  [SKU_NM]	  
       ,ISNULL(ISNULL(Sales.[YH_UPC]	   ,Inv.[YH_UPC]		  ),InvLD.[YH_UPC]	)  AS  [YH_UPC]	  
       ,NULL AS  [Region_CD]  
       ,NULL AS  [Region_NM]  
       ,ISNULL(ISNULL(Sales.[YH_Store_CD] ,Inv.[YH_Store_CD]),InvLD.YH_Store_CD)	  AS  [YH_Store_CD]
	   ,ST.[Store_ID]
       ,NULL  AS  [Store_NM]	  
       ,DT.Date_ID	  AS  [Calendar_DT]
       ,ISNULL(Sales.[Sales_AMT]			 ,0)   AS   [Sales_AMT]			
       ,ISNULL(Sales.[Sales_QTY]			 ,0)   AS 	[Sales_QTY]			
       ,ISNULL(Sales.[DiscountSales_AMT]	 ,0)   AS 	[DiscountSales_AMT]	
       ,ISNULL(Sales.[DiscountSales_QTY]	 ,0)   AS 	[DiscountSales_QTY]	
       ,ISNULL(Sales.[WithTax_SalesCost_AMT] ,0)   AS 	[WithTax_SalesCost_AMT]
       ,ISNULL(Sales.[Sals_Share_PC]		 ,0)   AS 	[Sals_Share_PC]		
       ,ISNULL(Sales.[WithTax_Discount_AMT]	 ,0)   AS 	[WithTax_Discount_AMT]	
       ,ISNULL(Sales.[Gross_WithTax_AMT]	 ,0)   AS 	[Gross_WithTax_AMT]	
       ,ISNULL(Sales.[Gross_WithTax_PC]		 ,0)   AS 	[Gross_WithTax_PC]		
	   ,ISNULL(Inv.  [Inventory_AMT]		 ,0)   AS 	[Inventory_AMT]		
	   ,ISNULL(Inv.  [Inventory_WithTax_AMT] ,0)   AS 	[Inventory_WithTax_AMT]
	   ,ISNULL(Inv.  [Inventory_QTY]		 ,0)   AS 	[Inventory_QTY]		
	   ,ISNULL(InvLD.  [Inventory_AMT]		 ,0)   AS 	[Inventory_LD_AMT]		
	   ,ISNULL(InvLD.  [Inventory_WithTax_AMT] ,0)   AS 	[Inventory_WithTax_LD_AMT]
	   ,ISNULL(InvLD.  [Inventory_QTY]		 ,0)   AS 	[Inventory_LD_QTY]		
	   ,CASE WHEN ISNULL(Sales.Sales_QTY,0)=0 AND ISNULL(InvLD.Inventory_QTY,0) >0 THEN 1 ELSE 0 END
	   ,GETDATE() AS [Create_Time]
	   ,OBJECT_NAME(@@PROCID) AS [Create_By]
	   ,GETDATE() AS [Update_Time]
	   ,OBJECT_NAME(@@PROCID) AS [Update_By]
	   FROM #YH_Sales Sales 
	   FULL OUTER JOIN 
	   #YH_Inventory Inv ON CAST(Sales.Calendar_DT AS date) = cast(Inv.Calendar_DT as date) and Sales.YH_UPC = Inv.YH_UPC and Sales.YH_Store_CD = Inv.YH_Store_CD AND sales.SKU_NM = inv.SKU_NM
	   FULL OUTER JOIN 
	   #YH_Inventory_LD InvLD ON CAST(Sales.Calendar_DT AS date) = cast(InvLD.Calendar_DT as date) and Sales.YH_UPC = InvLD.YH_UPC and Sales.YH_Store_CD = InvLD.YH_Store_CD AND sales.SKU_NM = invld.SKU_NM
	   LEFT JOIN dm.Dim_Store ST ON ISNULL(ISNULL(Sales.[YH_Store_CD],Inv.YH_Store_CD),InvLD.YH_Store_CD) = ST.Account_Store_Code AND st.Channel_Account = 'YH'
	   LEFT JOIN DM.Dim_Product Prod ON ISNULL(ISNULL(Sales.[YH_UPC],Inv.[YH_UPC]),InvLD.[YH_UPC]) = Prod.Bar_Code AND CASE WHEN ISNULL(ISNULL(Sales.SKU_NM,Inv.SKU_NM),InvLD.SKU_NM) LIKE '%Ð¡Öí%' THEN 'PEPPA' WHEN ISNULL(ISNULL(Sales.SKU_NM,Inv.SKU_NM),InvLD.SKU_NM) LIKE '%ÈðÆæ%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	   LEFT JOIN [FU_EDW].[Dim_Calendar] DT ON CAST(ISNULL(ISNULL(Sales.Calendar_DT,Inv.Calendar_DT),InvLD.Calendar_DT) AS DATE) = CAST(DT.Date_NM AS DATE)
	   where /*ISNULL(isnull(Inv.YH_Store_CD,sales.YH_Store_CD),InvLD.YH_Store_CD) not like 'W%' AND*//* DT.Date_ID>='20181101' AND*/ DT.Date_NM<=@LAST_DAY_OF_YH_SALES

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
