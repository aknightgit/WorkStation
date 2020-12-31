USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROC [rpt].[SP_ERP_SaleOrder_FOC_Daily_Update]
AS
BEGIN

	TRUNCATE TABLE rpt.ERP_SaleOrder_FOC_Daily
	INSERT INTO rpt.ERP_SaleOrder_FOC_Daily
			([Datekey]
			,[Channel_ID]
			,[Sale_Dept]
			,[Channel_Category]
			,[Channel_Name_Display]
			,[Customer_Name]
			,[FOC_Type]
			,[Count_as_Sellin]
			,[SKU_ID]
			,[Freshness]
			,[Vol_KG])
	SELECT --* 
			so.Datekey
			,dc.Channel_ID
			,so.Sale_Dept
			,dc.Channel_Category
			,dc.Channel_Name_Display
			,so.Customer_Name
			,ISNULL(so.FOC_Type,'Other')
			,CASE WHEN FOC_Type LIKE '%货补%' OR FOC_Type LIKE '%抵扣%' THEN 1 ELSE 0 END AS Count_as_Sellin
			,oe.SKU_ID
			--,Produce_Date,Shelf_Life_D
			--,DATEDIFF(DAY,c.Date,DATEADD(day,CAST(p.Shelf_Life_D AS INT),cast(Produce_Date as date)))
			--,CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D
			,CASE  WHEN CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D <0.333 THEN '<1/3'
				WHEN CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D>=0.333 AND CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D<0.5 THEN '1/3~1/2'
				WHEN CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D>=0.5 AND CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D<0.667 THEN '1/2~2/3'
				WHEN CAST(DATEDIFF(DAY,oe.Produce_Date,c.Date) AS decimal(9,5))/Shelf_Life_D>=0.667 THEN '>2/3'
				END AS Freshness
			,oe.Sale_Unit_QTY*p.Sale_Unit_Weight_KG as Vol_KG  
		FROM dm.Fct_ERP_Sale_Order so WITH(NOLOCK)
		JOIN dm.Fct_ERP_Sale_OrderEntry oe WITH(NOLOCK) on so.Sale_Order_ID=oe.Sale_Order_ID 
		JOIN dm.Dim_Channel dc WITH(NOLOCK) on so.Customer_Name=dc.ERP_Customer_Name
		JOIN dm.Dim_Calendar c WITH(NOLOCK) on so.Datekey=c.Datekey
		JOIN dm.Dim_Product p WITH(NOLOCK) on oe.SKU_ID=p.SKU_ID
		WHERE (oe.isfree=1 OR CAST(oe.Full_Amount AS INT)=0)
		--and Full_Amount>0
		AND Sale_Org='富友联合食品（中国）有限公司'
		--AND (FOC_Type NOT LIKE '%货补%' AND FOC_Type NOT LIKE '%抵扣%' )
		;


   END
GO
