USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [rpt].[SP_RPT_Rawdata_OutStock]
AS
BEGIN

SELECT  
	dc.Year
	,dc.Monthkey AS 'Month'
	,os.Datekey
	,dc.Date_Str AS 'Date'
	,os.Customer_Name
	,c.Channel_FIN
	,c.SubChannel_FIN
	,os.Bill_Type
	,os.Bill_No
	,os.Sale_Dept
	,os.Sale_Org
	--,os.Stock_Org
	,ose.SKU_ID
	,p.SKU_Name
	,p.SKU_Name_CN
	,p.Brand_Name
	,p.Product_Sort
	,p.Product_Category
	,ose.LOT
	,ose.Amount
	,p.Sale_Unit
	,ose.Sale_Unit_QTY
	,ose.[Price]
	,ose.[Tax_Price]
	,ose.[Price_Unit]
	,ose.[Price_Unit_QTY]	
	,ose.Sale_Unit_QTY*p.Sale_Unit_Weight_KG AS Weight_KG 
	,ship.[Ship_To_Desc]
	,ose.[Note]
	,ose.[Produce_Date]
	,ose.[Expiry_Date]
	,ose.[Arrival_Status]
	,ose.[Arrival_Date]
	--,CASE when os.Customer_Name='富平云商供应链管理有限公司' THEN coalesce(ship.Province,so.Province,w.Province,ec.Province) ELSE	
	--	coalesce(ship.Province,so.Province,ec.Province,w.Province) END AS '发货-客户地址-发货仓省份'
	,ship.Province AS '收货地址省份'
	,ec.Province AS '客户联系地址省份'
	,w.Province AS '发货仓省份'	
	,so.Province AS '订单备注省份'
	,ship.City AS '收货地址城市'
	,ose.Stock_Name AS '发货仓'
	,ec.[Customer_Address] AS '客户联系地址'
	,os.[Receive_Contact] AS '收货联系人'
	,os.[Receive_Address] AS '收货地址'
	,so.[Address] AS '销售订单备注地址'
	,os.SourceBillNo AS '下推源订单'
	,os.SaleOrderNo AS '销售订单'
	--,soe.Sale_Unit_QTY
FROM dm.Fct_ERP_Stock_OutStock os
JOIN dm.Fct_ERP_Stock_OutStockEntry ose ON os.OutStock_ID=ose.OutStock_ID
JOIN dm.Dim_Product p on ose.SKU_ID=p.SKU_ID
LEFT JOIN (select ship_to,MAX(Province) Province,MAX(City) City,Max(Ship_To_Desc) Ship_To_Desc from [dm].[Dim_ERP_Customer_Shipto] 
	group by ship_to) ship on isnull(os.Ship_To,'')=ship.Ship_To
JOIN dm.Dim_Calendar dc on os.Datekey=dc.Datekey
LEFT JOIN dm.Dim_ERP_CustomerList ec on os.Customer_Name=ec.Customer_Name
LEFT JOIN dm.Dim_Channel c on ec.Customer_ID=c.ERP_Customer_ID
LEFT JOIN dm.Dim_Warehouse w on w.Warehouse_Name=ose.Stock_Name
LEFT JOIN dm.Fct_ERP_Sale_Order so on os.SaleOrderNo=so.Bill_No
--LEFT JOIN dm.Fct_ERP_Sale_OrderEntry soe on so.Sale_Order_ID=soe.Sale_Order_ID AND ose.SKU_ID=soe.SKU_ID
WHERE os.Datekey>=20190101
AND os.Sale_Org='富友联合食品（中国）有限公司'
AND os.Bill_Type = '标准销售出库单'

END
GO
