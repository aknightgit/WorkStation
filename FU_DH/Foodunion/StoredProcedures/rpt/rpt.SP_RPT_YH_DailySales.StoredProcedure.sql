USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_YH_DailySales]
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
FROM Foodunion.dm.[Fct_YH_DailySales] 


END

GO
