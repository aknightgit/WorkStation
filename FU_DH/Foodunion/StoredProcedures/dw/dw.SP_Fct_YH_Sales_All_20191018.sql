USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE PROCEDURE  [dw].[SP_Fct_YH_Sales_All_20191018]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 
   TRUNCATE TABLE   dw.[Fct_YH_Sales_All] 
   TRUNCATE TABLE dw.[Fct_YH_Sales_All_Not_Mapped]


   -----------------------------------从手工文件获取时间早于20190630的数据
   INSERT INTO dw.[Fct_YH_Sales_All](
		[YH_Type]
      ,[YH_Type_CN]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[YH_UPC]
	  ,[SC_Density_SKU_Ton_Num]
	  ,[YH_categroy]
      ,[Region_CD]
      ,[Region_NM]
      ,[Store_ID]
      ,[YH_Store_CD]
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
	  ,YH_Home_Sales_AMT
	  ,JD_Home_Sales_AMT
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
   SELECT Sales.[YH_Type]
		 ,Sales.[YH_Type_CN]
		 ,Prod.[SKU_ID]
		 ,Prod.SKU_Name
		 ,Sales.[YH_UPC]
		 ,Prod.Sale_Unit_Weight_KG/1000 AS [SC_Density_SKU_Ton_Num]
		 ,Prod.Product_Sort
		 ,Sales.[Region_CD]
		 ,Sales.[Region_NM]
		 ,ST.[Store_ID]
		 ,ISNULL(Sales.[YH_Store_CD],Salesc.[YH_Store_CD]) AS [YH_Store_CD]
		 ,ST.Account_Store_Code as [YH_Store_CD]
		 ,DT.Date_ID
		 ,Sales.[Sales_AMT]
		 ,Sales.[Sales_QTY]
		 ,Sales.[DiscountSales_AMT]
		 ,Sales.[DiscountSales_QTY]
		 ,Sales.[WithTax_SalesCost_AMT]
		 ,Sales.[Sals_Share_PC]
		 ,Sales.[WithTax_Discount_AMT]
		 ,Sales.[Gross_WithTax_AMT]
		 ,Sales.[Gross_WithTax_PC]
		 ,Salesc.YH_Home_Sales_AMT
		 ,Salesc.JD_Home_Sales_AMT
		 ,GETDATE() AS [Create_Time]
		 ,OBJECT_NAME(@@PROCID) AS [Create_By]
		 ,GETDATE() AS [Update_Time]
		 ,OBJECT_NAME(@@PROCID) AS [Update_By]
	  FROM [ODS].[ods].[File_YH_Sales] Sales
	  FULL OUTER JOIN 
	  (
		SELECT Calendar_DT
			  ,YH_Store_CD
			  ,YH_UPC
			  ,SKU_NM
			  ,SUM(CAST(YH_Home_Sales_AMT AS FLOAT)) AS YH_Home_Sales_AMT
			  ,SUM(CAST(JD_Home_Sales_AMT AS FLOAT)) AS JD_Home_Sales_AMT
			  FROM
		[ODS].[ods].[File_YH_Sales_Channel]
		WHERE ISNULL(CAST(YH_Home_Sales_AMT AS FLOAT),0)<>0 OR ISNULL(CAST(JD_Home_Sales_AMT AS FLOAT),0)<>0 
			GROUP BY Calendar_DT
			  ,YH_Store_CD
			  ,YH_UPC
			  ,SKU_NM
	  ) Salesc ON CAST(ISNULL(Sales.Calendar_DT,'99991231') AS DATE) = CAST(ISNULL(Salesc.Calendar_DT,'99991231') AS DATE) AND ISNULL(Salesc.YH_Store_CD,'') = ISNULL(Sales.YH_Store_CD,'') AND ISNULL(Salesc.YH_UPC,'') = ISNULL(Sales.YH_UPC,'')
	  LEFT JOIN (select distinct [Store_ID],Account_Store_Code,Store_Name from [dm].[Dim_Store] WHERE  Channel_Account = 'YH' ) ST ON ISNULL(Sales.[YH_Store_CD],Salesc.YH_Store_CD) = ST.Account_Store_Code
	  LEFT JOIN DM.Dim_Product Prod ON ISNULL(Sales.[YH_UPC],Salesc.[YH_UPC]) = Prod.Bar_Code AND CASE WHEN ISNULL(Sales.SKU_NM,Salesc.SKU_NM) LIKE '%小猪%' THEN 'PEPPA' WHEN ISNULL(Sales.SKU_NM,Salesc.SKU_NM) LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	  LEFT JOIN [FU_EDW].[Dim_Calendar] DT ON ISNULL(CAST(Sales.Calendar_DT AS DATE),CAST(Salesc.Calendar_DT AS DATE)) = CAST(DT.Date_NM AS DATE)
	  WHERE Date_ID <='20190630'
	 
	 UNION ALL
	 ------------------------------------------从EDI 获取20190701后的YHSales 数据

	 SELECT NULL AS [YH_Type]
		   ,NULL AS [YH_Type_CN]
		   ,prod.SKU_ID AS SKU_ID
		   ,prod.SKU_Name	 AS [SKU_NM]
		   ,sal.bar_code	 AS [YH_UPC]
		   ,Prod.Sale_Unit_Weight_KG/1000 AS [SC_Density_SKU_Ton_Num]
		   ,Prod.Product_Sort AS [YH_categroy]
		   ,NULL	 AS [Region_CD]
		   ,NULL	 AS [Region_NM]
		   ,st.Store_ID	 AS [Store_ID]
		   ,sal.shop_id	 AS [YH_Store_CD]
		   ,sal.shop_name	 AS [Store_NM]
		   ,sal.calday	 AS [Calendar_DT]
		   ,sal.sales_amt	 AS [Sales_AMT]
		   ,sal.sales_qty	 AS [Sales_QTY]
		   ,sal.pro_chg_amt	 AS [DiscountSales_AMT]
		   ,NULL	 AS [DiscountSales_QTY]
		   ,NULL	 AS [WithTax_SalesCost_AMT]
		   ,NULL	 AS [Sals_Share_PC]
		   ,NULL	 AS [WithTax_Discount_AMT]
		   ,NULL	 AS [Gross_WithTax_AMT]
		   ,NULL	 AS [Gross_WithTax_PC]
		   ,CASE WHEN channel_name IN ('线上','团购') THEN sal.sales_amt END AS [YH_Home_Sales_AMT]
		   ,NULL	 AS [JD_Home_Sales_AMT]
		   ,GETDATE() AS [Create_Time]
		   ,OBJECT_NAME(@@PROCID) AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,OBJECT_NAME(@@PROCID) AS [Update_By]
	 FROM ODS.ods.EDI_YH_Sales sal
	  LEFT JOIN DM.Dim_Product Prod ON sal.bar_code = Prod.Bar_Code AND CASE WHEN sal.goods_name LIKE '%小猪%' THEN 'PEPPA' WHEN sal.goods_name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
		 LEFT JOIN dm.Dim_Store st ON sal.shop_id = st.Account_Store_Code
	 WHERE sal.calday>='20190701'


	 -- WHERE DT.Date_ID>='20181101'\

	  INSERT INTO dw.[Fct_YH_Sales_All_Not_Mapped](
		[YH_Type]
      ,[YH_Type_CN]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[YH_UPC]
      ,[Region_CD]
      ,[Region_NM]
      ,[Store_ID]
      ,[YH_Store_CD]
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
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
   SELECT Sales.[YH_Type]
		 ,Sales.[YH_Type_CN]
		 ,Prod.[SKU_ID]
		 ,Prod.SKU_Name
		 ,Sales.[YH_UPC]
		 ,Sales.[Region_CD]
		 ,Sales.[Region_NM]
		 ,ST.[Store_ID]
		 ,Sales.[YH_Store_CD]
		 ,ST.Store_Name
		 ,DT.Date_ID
		 ,Sales.[Sales_AMT]
		 ,Sales.[Sales_QTY]
		 ,Sales.[DiscountSales_AMT]
		 ,Sales.[DiscountSales_QTY]
		 ,Sales.[WithTax_SalesCost_AMT]
		 ,Sales.[Sals_Share_PC]
		 ,Sales.[WithTax_Discount_AMT]
		 ,Sales.[Gross_WithTax_AMT]
		 ,Sales.[Gross_WithTax_PC]
	     ,GETDATE() AS [Create_Time]
	     ,OBJECT_NAME(@@PROCID) AS [Create_By]
	     ,GETDATE() AS [Update_Time]
	     ,OBJECT_NAME(@@PROCID) AS [Update_By]
	  FROM [ODS].[ods].[File_YH_Sales] Sales
	   LEFT JOIN (select distinct [Store_ID],Account_Store_Code,Store_Name from [dm].[Dim_Store] WHERE Channel_Account = 'YH' ) ST ON Sales.[YH_Store_CD] = ST.Account_Store_Code
	  LEFT JOIN DM.Dim_Product Prod ON Sales.[YH_UPC] = Prod.Bar_Code AND CASE WHEN sales.SKU_NM LIKE '%小猪%' THEN 'PEPPA' WHEN sales.SKU_NM LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	  LEFT JOIN [FU_EDW].[Dim_Calendar] DT ON Year(Sales.Calendar_DT) = DT.[Year] AND Month(Sales.Calendar_DT) = DT.[Month] AND Day(Sales.Calendar_DT) = RIGHT(Date_ID,2)
	  WHERE ST.Account_Store_Code IS NULL OR Prod.Bar_Code IS NULL 








   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
