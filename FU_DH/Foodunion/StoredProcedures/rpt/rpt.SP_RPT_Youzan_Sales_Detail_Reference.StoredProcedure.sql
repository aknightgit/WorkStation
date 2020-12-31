USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Youzan_Sales_Detail_Reference]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_Youzan_Sales_Detail_Reference]
AS
BEGIN

DROP TABLE IF EXISTS #Period_Rank

SELECT [Period]
	  ,sp_year_max+'/'+LEFT([period],CHARINDEX('-',[period])-1) AS Begin_DT
	  ,sp_year_min+'/'+RIGHT([period],LEN([period])-CHARINDEX('-',[period])) AS End_DT
	  ,DENSE_RANK() OVER(ORDER BY sp_year_max+'/'+LEFT([period],CHARINDEX('-',[period])-1)) AS Period_Rank
	  ,[Date]
	  INTO #Period_Rank
FROM 
(SELECT  MAX(LEFT(sp_num,4)) AS sp_year_max,MIN(LEFT(sp_num,4)) AS sp_year_min,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period],MIN(v) AS [Date] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE v LIKE '%期间%' GROUP BY RIGHT(v,[dbo].[IndexOfChR](v))) AS per
UNION ALL
SELECT '7/27-7/31','2019-07-27','2019-07-31',0,'7月期间7/27-7/31'

SELECT [Order_No]
      ,[Recon_Date]
      ,[Order_No_Unique]
      ,[Product_Name]
      ,[Product_Type]
      ,[Recon_AMT]
      ,[Distributin_Cycle]
      ,[Qty_By_Month]
      ,[Distribution_AMT_OneTime]
      ,[Distribution_Times_During_Period]
      ,[Distribution_Qty_During_Period]
      ,[Distribution_AMT_During_Period]
      ,[Dumy_Order]
      ,[Delivery_AMT_During_Period]
      ,[Fenxiao_Product]
      ,[Refund_AMT]
      ,[Delivery_AMT_By_Cycle]
      ,[Delivery_AMT]
      ,[SKU_ID]
      ,[RSP]
      ,[RSP_Total]
      ,[Discount_AMT]
      ,[Moveout_Warehouse]
      ,[Moveout_Employee]
      ,[SKU_Qty]
      ,[Subtotal_Qty]
      ,[Payment_AMT]
      ,[Commodity_Credits]
      ,[Commodity_Message]
      ,[Receiver]
      ,[Receiver_Phone_NBR]
      ,[Receiver_Province]
      ,[Receiver_City]
      ,[Receiver_Region]
      ,[Receiver_Address]
      ,[Buyer_Remark]
      ,[Delivery_Status]
      ,[Delivery_Type]
      ,[Delivery_Company]
      ,[Delivery_NBR]
      ,[Delivery_Time]
      ,[Refund_Status]
      ,[Order_Remark]
      ,[Cycle_Information]
	  ,pr.Date AS Period
      ,[Load_Source]
      ,[Load_DTM]
  FROM [ODS].[ods].[File_Youzan_Sales_Detail_Reference] dr
  LEFT JOIN #Period_Rank pr ON CAST(dr.[Recon_Date] AS DATE) BETWEEN pr.Begin_DT AND pr.End_DT
END
GO
