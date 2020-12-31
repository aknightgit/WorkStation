USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Youzan_Recon_Detail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [rpt].[SP_RPT_Youzan_Recon_Detail]
AS
BEGIN


DROP TABLE IF EXISTS #OrderRsp

SELECT 
	 bi.Order_No
	,SUM(rsp.sku_Price*di.QTY*di.pcs_cnt*delivery_cnt) AS Order_Rsp_Amount
	INTO #OrderRsp
FROM [dm].[Fct_O2O_Order_Detail_info] di
LEFT JOIN [dm].[Fct_O2O_Order_Base_info] bi ON di.order_id = bi.order_id
LEFT JOIN dm.Dim_Product_Pricelist rsp ON di.SKU_ID = rsp.SKU_ID and rsp.Price_List_Name = 'O2O对账专用'
GROUP BY bi.Order_No
HAVING SUM(rsp.sku_Price*di.QTY*di.pcs_cnt*delivery_cnt) IS NOT NULL



------------------------------[dm].[Fct_Youzan_Recon] 的 Order_no 和[dm].[Fct_O2O_Order_Detail_info] 的 Order_no是多对多的关系，所以数据会发生膨胀，要以[dm].[Fct_Youzan_Recon] 的 Order_No和 Recon_Date字段对[dm].[Fct_O2O_Order_Detail_info]表进行拆分


--E20190321195500073700033
SELECT 
	   yr.Recon_ID
	  ,yr.Recon_Date
	  ,yr.Recon_DateKey
	  ,yr.Order_No
	  ,yr.pay_type_str
	  ,yr.Order_Amount
	  ,yr.shipping_amount
	  ,yr.Order_Pay_Amount
	  ,yr.Order_Create_DateKey
	  ,yr.Pay_Datekey
	  ,yr.Recon_Type
	  ,yr.cycle
	  ,yr.Cycle_Times
	  ,ors.Order_Rsp_Amount
	  ,di.SKU_ID
	  ,di.Product_Name
	  ,rsp.SKU_Price
	  ,di.QTY
	  ,di.pcs_cnt
	  ,di.delivery_cnt
	  ,yr.Amount
	  --,ROUND(rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt,2,1) AS Order_SKU_Amount
	  --,ROUND(ROUND(rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt,2,1)/ROUND(ors.Order_Rsp_Amount,2,1),2,1) AS Order_SKU_Amount_Pct
	  --,ROUND(ROUND(ROUND(rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt,2,1)/ROUND(ors.Order_Rsp_Amount,2,1),2,1)*yr.Amount,2,1) AS Recon_Amount_Split
	  ,di.QTY*di.pcs_cnt AS Recon_Qty
	  ,di.QTY*di.pcs_cnt*prod.Sale_Unit_Weight_KG AS Recon_Weight
	  ,rsp.SKU_Price*di.QTY*di.pcs_cnt AS Rsp_Amount
	  ,rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt AS Order_SKU_Amount
	  ,CASE WHEN yr.cycle =1 THEN 1 ELSE rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt/ors.Order_Rsp_Amount END AS Order_SKU_Amount_Pct
	  ,CASE WHEN (rsp.SKU_ID IS NULL) AND( Product_Name LIKE '%寄生单%') THEN yr.Amount 
			WHEN di.Order_ID IS NULL THEN yr.Amount
			ELSE rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt/ors.Order_Rsp_Amount*yr.Amount END AS Recon_Amount_Split
	  ,CASE WHEN (rsp.SKU_ID IS NULL) AND( Product_Name LIKE '%寄生单%') THEN yr.Order_Pay_Amount 
			WHEN di.Order_ID IS NULL THEN yr.Order_Pay_Amount
			ELSE rsp.SKU_Price*di.QTY*di.pcs_cnt*di.delivery_cnt/ors.Order_Rsp_Amount*yr.Order_Pay_Amount END AS Pay_Amount_Split
	  ,ROW_NUMBER() OVER(PARTITION BY yr.rn ORDER BY di.SKU_ID DESC) AS Recon_Sec
	-- into #reconsku
FROM (SELECT *,ROW_NUMBER() OVER(ORDER BY GETDATE()) rn FROM [dm].[Fct_Youzan_Recon]) yr 
LEFT JOIN [dm].[Fct_O2O_Order_Base_info] bi ON yr.Order_No = bi.Order_No 
LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di ON bi.Order_ID = di.Order_ID
LEFT JOIN dm.Dim_Product_Pricelist rsp ON di.SKU_ID = rsp.SKU_ID and rsp.Price_List_Name = 'O2O对账专用'
LEFT JOIN #OrderRsp ors ON yr.Order_No = ors.Order_No
LEFT JOIN dm.Dim_Product prod ON di.SKU_ID = prod.SKU_ID
order by Recon_ID

END
GO
