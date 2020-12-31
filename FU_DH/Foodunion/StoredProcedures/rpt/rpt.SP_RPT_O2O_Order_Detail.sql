USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_RPT_O2O_Order_Detail]
AS
BEGIN

SELECT 
	   od.order_id
	  ,od.Sub_Order AS order_no
	  ,eo.Employee_name AS Apply_Name
	  ,CAST(ob.consign_time AS DATE) AS consign_time
	  ,cal.Start_of_Week AS Sales_DT			--取FOC那周一作为销售日期AS [Date]
	  ,od.product_id AS SKU_ID
	  ,od.product_name
	  ,od.QTY AS Sales_Qty
	  ,od.unit_price
	  ,ob.order_create_time
	  ,od.Unit_Weight_g AS Weight_g
	  ,od.payment
	  --INTO #Sales
FROM [dm].[Fct_O2O_Order_Detail_info] od
LEFT JOIN [dm].[Fct_O2O_Order_Base_info] ob ON od.order_id = ob.order_id
LEFT JOIN dm.Dim_O2O_Employee eo ON ob.operator_employee_id = eo.employee_id
LEFT JOIN dm.Dim_Calendar cal ON CAST(ob.consign_time AS DATE) = cal.Date_Str
WHERE ob.consign_time IS NOT NULL

END
GO
