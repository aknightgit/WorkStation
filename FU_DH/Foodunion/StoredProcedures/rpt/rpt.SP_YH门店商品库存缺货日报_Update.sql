USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_YH门店商品库存缺货日报_Update]
AS

BEGIN
   --查看表[rpt].[YH门店商品库存缺货日报]是否存在数据，数据日期是否小于当前天，再执行  Justin  2020-05-26
   IF (SELECT CONVERT(VARCHAR(10),MAX(CREATE_DATE),112) FROM [Foodunion].[rpt].[YH门店商品库存缺货日报])<CONVERT(VARCHAR(10),GETDATE(),112) OR (SELECT COUNT(1) FROM [Foodunion].[rpt].[YH门店商品库存缺货日报])=0
   
   BEGIN

   TRUNCATE TABLE [Foodunion].[rpt].[YH门店商品库存缺货日报];
   
  SELECT SI.SKU_ID,
          P.SKU_Name_CN,
		  S.Province_Short AS Sales_Area,		  
		  ISNULL(ISNULL(REPLACE(MD.[Sales_Person],'* ',''),MD.[Merchandiser_A]),'none person') AS [Sales or MD],		
		  TM.Manager AS [城市经理],
		  --LEFT(Region_Director,CHARINDEX(' ',Region_Director)-1) AS [大区负责人],
		  CASE WHEN CHARINDEX(' ',Region_Director)>1 THEN  LEFT(Region_Director,CHARINDEX(' ',Region_Director)-1) ELSE Region_Director END AS [大区负责人],
		  SI.Store_Code AS [Store code],
		  SI.Store_Name,		
		  SI.Inventory_Qty,
		  'OOS' AS [OOS (stock <=10)],
		  ISNULL(MD.[Region],R.Region) AS Region,
		  0 AS [MailSent],
		  GETDATE() AS CREATE_DATE INTO #INV
   FROM [Foodunion].[dm].[Fct_KAStore_DailySalesInventory] SI
   JOIN [Foodunion].[dm].[Dim_Store] S
   ON SI.Store_ID=S.Store_ID AND S.[Channel_Account]='YH' 
   LEFT JOIN [ODS].[ods].[File_KAStore_SalesMD] MD
   ON SI.Store_Code=MD.[Store_ID]
   LEFT JOIN [dm].[Dim_Product] P
   ON SI.SKU_ID=P.SKU_ID
   LEFT JOIN [dm].[Dim_SalesTerritory_Mapping_Monthly] TM
   ON S.Province_Short=TM.Province_Short AND TM.Monthkey=(SELECT MAX(Monthkey) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly])
   LEFT JOIN(SELECT DISTINCT Province,Region FROM [ODS].[ods].[File_KAStore_SalesMD]) R
   ON S.Store_Province=R.Province
   WHERE Datekey=CONVERT(VARCHAR(10),DATEADD(DAY,-1,GETDATE()),112) AND SI.Inventory_Qty<=10 AND SI.SKU_ID IN ('1170001','1170002')
        AND ISNULL(MD.[Region],R.Region) IN ('东区','西区','北区','中沪')  AND SI.Store_Code NOT LIKE 'W%'  --W 开头为仓库，不在销售关注内   Justin 2020-06-04

   DELETE FROM #INV WHERE Sales_Area IN ('四川','重庆') AND SKU_ID='1170005'    --'四川','重庆' 暂停'1170005' 销售     Justin 2020-06-03

    INSERT INTO [Foodunion].[rpt].[YH门店商品库存缺货日报]
	([SKU_ID]
      ,[SKU_Name_CN]
      ,[Sales_Area]
      ,[Sales or MD]
      ,[城市经理]
      ,[大区负责人]
      ,[Store code]
      ,[Store_Name]
      ,[Inventory_Qty]
      ,[OOS (stock <=10)]
      ,[Region]
      ,[MailSent]
	  ,CREATE_DATE)
	SELECT  [SKU_ID]
      ,[SKU_Name_CN]
      ,[Sales_Area]
      ,[Sales or MD]
      ,[城市经理]
      ,CASE WHEN [大区负责人]='孙宝云' THEN '杨谦' ELSE [大区负责人] END AS [大区负责人]
      ,[Store code]
      ,[Store_Name]
      ,[Inventory_Qty]
      ,[OOS (stock <=10)]
      ,[Region]
      ,[MailSent]
	  ,CREATE_DATE
	FROM #INV
	UNION
	SELECT [SKU_ID]+' 汇总' AS [SKU_ID]
      ,''[SKU_Name_CN]
      ,''[Sales_Area]
      ,''[Sales or MD]
      ,''[城市经理]
      ,''[大区负责人]
      ,''[Store code]
      ,''[Store_Name]
      ,SUM([Inventory_Qty]) AS [Inventory_Qty]
      ,'OOS'[OOS (stock <=10)]
      ,[Region]
      ,0 [MailSent]
	  ,MAX(CREATE_DATE) CREATE_DATE
	   FROM #INV
	  GROUP BY [SKU_ID],[Region]
	  ORDER BY Region,1,2,3,[Inventory_Qty] DESC ;


	  ----计算缺货门店汇总
	  TRUNCATE TABLE [Foodunion].[rpt].[YH门店商品库存缺货日报汇总];
	   INSERT INTO [Foodunion].[rpt].[YH门店商品库存缺货日报汇总]
     ([SKU_ID]
      ,[SKU_Name_CN]
      ,[Sales_Area]
      ,[Sales or MD]
      ,[Sales Manager]
      ,[Sales Director]
      ,[Store_no]
      ,[OOS]
      ,[Region]
      ,[Row_Attr])
  SELECT [SKU_ID]
      ,[SKU_Name_CN]
      ,[Sales_Area]
      ,[Sales or MD]
      ,[城市经理]
      ,[大区负责人]
      ,COUNT(DISTINCT [Store code]) AS [Store_no]
      ,[OOS (stock <=10)]
      ,[Region]
      ,''[Row_Attr]
	  FROM [Foodunion].[rpt].[YH门店商品库存缺货日报]
	  WHERE ISNULL([SKU_Name_CN],'')<>'' 
	  GROUP BY [SKU_ID]
      ,[SKU_Name_CN]
      ,[Sales_Area]
      ,[Sales or MD]
      ,[城市经理]
      ,[大区负责人]
	  ,[OOS (stock <=10)]
      ,[Region]
  UNION 
   SELECT [SKU_ID]+' 汇总'
      ,''[SKU_Name_CN]
      ,''[Sales_Area]
      ,''[Sales or MD]
      ,''[城市经理]
      ,''[大区负责人]
      ,COUNT(DISTINCT [Store code]) AS [Store_no]
      ,[OOS (stock <=10)]
      ,[Region]
      ,'bgcolor=#E6E6E6 align=left style="font-weight:bold;"'[Row_Attr]
	  FROM [Foodunion].[rpt].[YH门店商品库存缺货日报]
	  WHERE ISNULL([SKU_Name_CN],'')<>'' 
	  GROUP BY [SKU_ID]     
	  ,[OOS (stock <=10)]
      ,[Region]
 UNION
  SELECT '总计'
      ,''[SKU_Name_CN]
      ,''[Sales_Area]
      ,''[Sales or MD]
      ,''[城市经理]
      ,''[大区负责人]
      ,COUNT(DISTINCT [Store code]) AS [Store_no]
      ,[OOS (stock <=10)]
      ,[Region]
      ,'bgcolor=#E6E6E6 align=left style="font-weight:bold;"'[Row_Attr]
	  FROM [Foodunion].[rpt].[YH门店商品库存缺货日报]
	  WHERE ISNULL([SKU_Name_CN],'')<>''
	  GROUP BY  [OOS (stock <=10)]
      ,[Region];
	  
END

END
 
GO
