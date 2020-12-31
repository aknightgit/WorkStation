USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [rpt].[SP_RPT_YH_DailySales]
AS
BEGIN 
	
SELECT DateKey
	  ,Store_ID
	  ,SKU_ID
	  ,InStock_QTY
	  ,InStock_Amount
--FROM dm.[Fct_YH_DailySales] 
FROM dm.[Fct_YH_JXT_Daily] 


END

GO
