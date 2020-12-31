USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROC  [rpt].[SP_RPT_OutStock_By_Province]
as
BEGIN
SELECT 
	    LEFT(si.Datekey,6)+'01' AS Monthkey
	   ,LEFT(si.Datekey,4) AS [Year]
	   ,si.Customer_Name
	   ,sie.SKU_ID
	   ,dc.Province
	   ,SUM(Sale_Unit_QTY) AS Sale_Unit_QTY
	   ,SUM(Sale_Unit_QTY*prod.Sale_Unit_Weight_KG)/1000 AS [Weight]
FROM dm.Fct_ERP_Sale_OrderEntry sie
LEFT JOIN dm.Fct_ERP_Sale_Order si ON sie.Sale_Order_ID = si.Sale_Order_ID
LEFT JOIN dm.Dim_Product prod ON sie.SKU_ID = prod.SKU_ID
LEFT JOIN dm.Dim_Channel dc ON si.Customer_Name = dc.ERP_Customer_Name
WHERE Customer_Name NOT IN('富平云商供应链管理有限公司','富友联合澳亚乳业有限公司','富友联合食品（中国）有限公司') AND si.Document_Status = '已审核'  AND si.Close_Status = '已关闭' AND si.Bill_Type <> '受托加工销售'
and LEFT(si.Datekey,4) =2019
GROUP BY LEFT(si.Datekey,6)
        ,LEFT(si.Datekey,4)
	    ,si.Customer_Name
	    ,dc.Province
	   ,sie.SKU_ID

UNION ALL

SELECT 
  LEFT(s.Datekey,6)+'01' AS Monthkey
 ,LEFT(s.Datekey,4) AS [Year]
 ,'富平云商供应链管理有限公司' AS Customer_Name
 ,p.SKU_ID
 ,ds.Store_Province
 ,SUM(s.InStock_QTY) AS Sale_Unit_QTY
 ,SUM(s.instock_qty*p.Sale_Unit_Weight_KG/1000) [Weight]
--from dm.Fct_YH_DailySales s
from dm.Fct_YH_JXT_Daily s
join dm.Dim_Product p on s.SKU_ID=p.SKU_ID
join dm.Dim_Store ds on s.Store_ID=ds.Store_ID
GROUP BY LEFT(s.Datekey,6)
        ,LEFT(s.Datekey,4)
		,ds.Store_Province
		,p.SKU_ID



	
END

GO
