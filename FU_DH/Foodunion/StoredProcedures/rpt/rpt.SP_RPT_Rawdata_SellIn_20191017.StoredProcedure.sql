USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Rawdata_SellIn_20191017]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [rpt].[SP_RPT_Rawdata_SellIn_20191017]
AS
BEGIN


--Sell-In QTY(by StockUnit)/Volumn(by KG)

--select top 10 * from [dm].[Fct_ERP_Sale_Order]
--select distinct sale_org from  [dm].[Fct_ERP_Sale_Order]
--select top 10 * from  [dm].[Fct_ERP_Sale_OrderEntry]
--select *from dm.Dim_Product
--select top 10 * from dm.Dim_ERP_CustomerMapping
select c.Year,c.Month,c.Week_Year_NBR,
	o.Datekey,
	o.Sale_Order_ID,
	o.Customer_Name,
	case when o.Customer_Name  in ('一次性现金客户') THEN 'Other' ELSE isnull(cm.Account_Display_Name,'Other') END AS Customer_Name_EN,
	Sale_Dept,oe.SKU_ID,
	p.SKU_Name,
	p.Product_Sort,
	p.Product_Category,
	p.Plan_Group,
	oe.Stock_Unit,
	oe.Stock_QTY AS SaleQTY_by_StockUnit,
	CAST(oe.Amount AS decimal(9,2)) Amount,
	CAST(oe.Sale_Unit_QTY*p.Sale_Unit_Weight_KG AS decimal(9,2)) AS Weight_KG
	--,p.Sale_Unit_Weight_KG,oe.Sale_Unit_QTY
from [dm].[Fct_ERP_Sale_Order] o with(NOLOCK)
left join dm.Dim_ERP_CustomerMapping cm with(NOLOCK) on o.Customer_Name=cm.Customer_Name and cm.Is_Current=1
join [FU_EDW].[Dim_Calendar] c with(NOLOCK) on o.Datekey=c.date_ID
join [dm].[Fct_ERP_Sale_OrderEntry] oe with(NOLOCK)
join dm.Dim_Product p with(NOLOCK) on oe.SKU_ID=p.SKU_ID
on o.Sale_Order_ID=oe.Sale_Order_ID
where Sale_Dept in ('Marketing 市场部','Sales Operation 销售管理','O2O有赞','Logistics 物流')
--and o.Customer_Name not in ('一次性现金客户')
--and o.Sale_Order_ID='102701'
--and p.Sale_Unit_Weight_KG is null
order by 1,2,4,5

END
GO
