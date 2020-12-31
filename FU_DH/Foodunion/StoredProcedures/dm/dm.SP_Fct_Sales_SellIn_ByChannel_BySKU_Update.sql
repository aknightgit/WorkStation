USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Modified  2020-11-09
--Change:  Set Zbox/DTC channel 出库单Net Sales，规则和其他渠道一样

--SELECT COUNT(1) FROM [dm].[Fct_Sales_SellIn_ByChannel_BySKU]
CREATE PROCEDURE [dm].[SP_Fct_Sales_SellIn_ByChannel_BySKU_Update] 
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	    TRUNCATE TABLE [dm].[Fct_Sales_SellIn_ByChannel_BySKU]
		INSERT INTO [dm].[Fct_Sales_SellIn_ByChannel_BySKU]
			  ([Monthkey]
			  ,[Datekey]
			  ,[Customer_ID]
			  ,[Customer_Name]
			  ,[Channel_ID]
			  ,[Channel_Type]
			  ,[Channel_Name_Short]
			  ,[Channel_FIN]
			  ,[SubChannel_FIN]
			  ,[SKU_ID]
			  ,[出库单未税]
			  ,[FOC未税]
			  ,[调拨单金额]
			  ,[退货单未税]
			  ,[Net_Sales]
			  ,[出库单含税]
			  ,[FOC含税]
			  ,[退货单含税]
			  ,[Net_Sales_wTax]
			  ,[出库单非FOC吨数]
			  ,[FOC吨数]
			  ,[调拨单吨数]
			  ,[退货单吨数]
			  ,[Create_time]
			  ,[Create_By]
			  ,[Update_time]
			  ,[Update_By])        
		SELECT LEFT([Datekey],6), [Datekey],Customer_ID,Customer_Name,Channel_ID,Channel_Type,Channel_Name_Short,Channel_FIN,SubChannel_FIN, SKU_ID,
			   SUM([出库单未税]) AS [出库单未税],
			   SUM([FOC未税]) AS [FOC未税],
			   SUM([调拨单金额]) AS [调拨单金额],
			   SUM([退货单未税]) AS [退货单未税],
			   SUM([Net_Sales]) AS [Net_Sales],
			   SUM([出库单含税]) AS [出库单含税],
			   SUM([FOC含税]) AS [FOC含税],
			   SUM([退货单含税]) AS [退货单含税],
			   SUM([Net_Sales_wTax]) AS [Net_Sales_wTax],
			   SUM([出库单非FOC吨数]) AS [出库单非FOC吨数],
			   SUM([FOC吨数]) AS [FOC吨数],
			   SUM([调拨单吨数]) AS [调拨单吨数],
			   SUM([退货单吨数]) AS [退货单吨数],
			   GETDATE() [Create_time],
			   '[dm].[Fct_Sales_SellIn_ByChannel_BySKU]' [Create_By],
			   GETDATE() [Update_time],
			   '[dm].[Fct_Sales_SellIn_ByChannel_BySKU]' [Update_By]
			   
		FROM ( 
		SELECT sos.[Datekey],ose.SKU_ID,
		       CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN '153457' ELSE cl.ERP_Customer_ID  END AS Customer_ID,
			   CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN '有赞商城' ELSE  cl.ERP_Customer_Name END AS Customer_Name,
			   CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN 45 ELSE sos.Channel_ID END AS Channel_ID,
			   CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN 'DTC' ELSE CL.Channel_Type END AS Channel_Type,
			   CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN '有赞' ELSE CL.Channel_Name_Short END  AS Channel_Name_Short,  --合并有赞数据
			   CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN 'ONLINE' ELSE CL.Channel_FIN END AS Channel_FIN,
			   CASE WHEN SOS.Channel_ID  IN (45,58,65) THEN 'DTC' ELSE CL.SubChannel_FIN END AS SubChannel_FIN,
			   --CASE WHEN SOS.Channel_ID  IN (16,45,48,58,65)  then 0 else ose.Amount end AS [出库单未税],   --有赞，去楼下取调拨数据           Justin  2020-06-08
			   ose.Amount AS [出库单未税],
			   CASE WHEN ose.Full_Amount=0 THEN ose.Cost_Amount ELSE 0 END AS [FOC未税],
			   0 AS [调拨单金额],
			   0 AS [退货单未税],
			   --CASE WHEN SOS.Channel_ID  IN (16,45,48,58,65)  then 0 ELSE ose.Amount END AS [Net_Sales],
			   ose.Amount AS [Net_Sales],
			   ose.Full_Amount AS [出库单含税],
			   CASE WHEN ose.Full_Amount=0 THEN ose.Cost_Amount ELSE 0 END AS [FOC含税],  --更改使用 总成本(系统标准)Cost_Amount
			   0 AS [退货单含税],
			   --CASE WHEN SOS.Channel_ID  IN (16,45,48,58,65)  then 0 ELSE ose.Full_Amount END AS Net_Sales_wTax,
			   ose.Full_Amount AS Net_Sales_wTax,			
			   --CASE WHEN SOS.Channel_ID  IN (16,45,48,58,65)  then 0  else (CASE WHEN ose.Full_Amount>0.01 THEN ose.Net_Weight/1000 ELSE 0 END) end [出库单非FOC吨数],  --有赞，去楼下取调拨数据           Justin  2020-06-08
			   (CASE WHEN ose.Full_Amount>=0.01 THEN ose.Net_Weight/1000 ELSE 0 END) AS [出库单非FOC吨数],
			   CASE WHEN ose.Full_Amount=0.00 THEN ose.Net_Weight/1000 ELSE 0 END [FOC吨数],
			   0 AS [调拨单吨数],
			   0 AS [退货单吨数]
        FROM [dm].[Fct_ERP_Stock_OutStock] sos WITH(NOLOCK)
		LEFT JOIN [dm].[Fct_ERP_Stock_OutStockEntry] ose WITH(NOLOCK) ON sos.[OutStock_ID] = ose.[OutStock_ID]
		LEFT JOIN [dm].[Dim_Channel] cl ON sos.[Customer_ID] = cl.ERP_Customer_ID  	 
		WHERE sos.Sale_Org='富友联合食品（中国）有限公司'	

		--考虑FOC退单
		UNION ALL		
		SELECT rs.[Datekey],rse.SKU_ID,
		       CASE WHEN rs.Channel_ID  IN (45,58,65) THEN '153457' ELSE cl.ERP_Customer_ID  END AS Customer_ID,
			   CASE WHEN rs.Channel_ID  IN (45,58,65) THEN '有赞商城' ELSE  cl.ERP_Customer_Name END AS Customer_Name,
			   CASE WHEN rs.Channel_ID  IN (45,58,65) THEN 45 ELSE rs.Channel_ID END AS Channel_ID,
			   CASE WHEN rs.Channel_ID  IN (45,58,65) THEN 'DTC' ELSE CL.Channel_Type END AS Channel_Type,
			   CASE WHEN rs.Channel_ID  IN (45,58,65) THEN '有赞' ELSE CL.Channel_Name_Short END  AS Channel_Name_Short,  --合并有赞数据
			   CASE WHEN rs.Channel_ID  IN (45,58,65) THEN 'ONLINE' ELSE CL.Channel_FIN END AS Channel_FIN,
			   CASE WHEN rs.Channel_ID  IN (45,58,65) THEN 'DTC' ELSE CL.SubChannel_FIN END AS SubChannel_FIN,
			   0 AS [出库单未税],  
			   0 - rse.Cost_Amount AS [FOC未税],  --更改使用, FOC 总成本(系统标准)Cost_Amount 扣除退货
			   0 AS [调拨单金额],
			   0 AS [退货单未税],
			   0 AS [Net_Sales],
			   0 AS [出库单含税],
			   0 AS [Net_Sales_wTax],
			   0 - rse.Cost_Amount AS [FOC含税],  --更改使用 总成本(系统标准)Cost_Amount 扣除退货
			   0 AS [退货单含税],
			   0 AS [出库单非FOC吨数],  
			   0 AS [FOC吨数],
			   0 AS [调拨单吨数],
			   0 AS [退货单吨数]
        FROM [dm].[Fct_ERP_Stock_ReturnStock] rs WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Stock_ReturnStockEntry] rse WITH(NOLOCK) ON rs.[ReturnStock_ID] = rse.[ReturnStock_ID]
		JOIN [dm].[Dim_Channel] cl ON rs.Channel_ID=cl.Channel_ID  
		JOIN [dm].[Fct_ERP_Sale_OrderEntry] soe WITH(NOLOCK) ON rse.Sale_OrderEntry=soe.Order_Entry_ID and soe.Full_Amount=0	 
		WHERE rs.Stock_Org='富友联合食品（中国）有限公司'	
		--AND rs.Datekey/100=202005 AND  cl.Channel_FIN='indirect'

		UNION ALL   

		--计算有赞调拨数据
		SELECT   
			sti.Datekey AS Datekey, stie.SKU_ID
			,'153457' AS [Customer_ID]
			,'有赞商城' AS [Customer_Name]
			,45 AS Channel_ID
			,'DTC' AS [Channel_Type]
			,'有赞' AS [Channel_Name_Short]
			,'ONLINE' AS [Channel_FIN]
			,'DTC' AS [SubChannel_FIN]
			,0 AS [出库单未税]
			,0 AS [FOC未税]
			,SUM(stie.Sale_QTY * pl.SKU_Price) AS [调拨单金额]
			,0 AS [退货单未税]
			,0 AS [Net_Sales]
			,0 AS [出库单含税]
			,0 AS [FOC含税]
			,0 AS [退货单含税]
			,0 AS [Net_Sales_wTax]
			,0 AS [出库单非FOC吨数]
			,0 AS [FOC吨数]
			,SUM(stie.Sale_QTY*p.Sale_Unit_Weight_KG)/1000 AS [调拨单吨数]
			,0 AS [退货单吨数]	
		FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
		JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
		LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
		WHERE stie.Dest_Stock in ('社区店在途库',  '赢养顾问网点库存',	  'O2O在途')
		AND sti.Datekey>=20191001
		GROUP BY sti.Datekey 
			,stie.SKU_ID
		
		--计算去楼下调拨数据
		UNION ALL    
		SELECT   
			sti.Datekey AS Datekey, stie.SKU_ID
			,'153445' AS [Customer_ID]
			,'北京去楼下科技有限公司' AS [Customer_Name]
			,48 AS Channel_ID
			,'Zbox' AS [Channel_Type]
			,'北京去楼下' AS [Channel_Name_Short]
			,'ONLINE' AS [Channel_FIN]
			,'ZBOX' AS [SubChannel_FIN]
			,0 AS [出库单未税]
			,0 AS [FOC未税]
			,SUM(stie.Sale_QTY * pl.SKU_Price) AS [调拨单金额]
			,0 AS [退货单未税]
			,0 AS [Net_Sales]
			,0 AS [出库单含税]
			,0 AS [FOC含税]
			,0 AS [退货单含税]
			,0 AS [Net_Sales_wTax]
			,0 AS [出库单非FOC吨数]
			,0 AS [FOC吨数]
			,SUM(stie.Sale_QTY*p.Sale_Unit_Weight_KG)/1000 AS [调拨单吨数]
			,0 AS [退货单吨数]
		FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
		JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
		LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) 
			ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
		WHERE stie.Dest_Stock  LIKE '%楼下%'
		AND sti.Datekey>=20191201
		GROUP BY sti.Datekey 
			,stie.SKU_ID 
		
		--计算孩子王调拨数据
		UNION ALL    
		SELECT  
			[Datekey],stie.SKU_ID
			,'231229' AS [Customer_ID]
			,'孩子王儿童用品股份有限公司采购中心' AS [Customer_Name]
			,16 AS Channel_ID
			,'Distributor' AS [Channel_Type]
			,'孩子王' AS [Channel_Name_Short]
			,'NKA' AS [Channel_FIN]
			,'OTHER' AS [SubChannel_FIN]
			,0 AS [出库单未税]
			,0 AS [FOC未税]
			,Sum(stie.Sale_QTY * isnull(pl.SKU_Price,p.Sale_Unit_RSP*0.85)) AS [调拨单金额]
			,0 AS [退货单未税]
			,0 AS [Net_Sales]
			,0 AS [出库单含税]
			,0 AS [FOC含税]
			,0 AS [退货单含税]
			,0 AS [Net_Sales_wTax]
			,0 AS [出库单非FOC吨数]
			,0 AS [FOC吨数]
			,sum(stie.Base_Unit_QTY * p.Base_Unit_Weight_KG / 1000) AS [调拨单吨数]
			,0 AS [退货单吨数]     
		FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
		JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
		JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
			ON ch.Channel_Name='Kidswant' AND ch.Monthkey = sti.DateKey/100
		LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
		WHERE stie.Dest_Stock like '%孩子王寄售仓%'
		--AND pl.SKU_ID IS NULL
		GROUP BY [Datekey],stie.SKU_ID

		--计算退货数据
		UNION ALL   
		SELECT srs.[Datekey], rse.SKU_ID,
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN '153457' ELSE cl.ERP_Customer_ID  END AS Customer_ID,
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN '有赞商城' ELSE  cl.ERP_Customer_Name END AS Customer_Name,
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN 45 ELSE srs.Channel_ID END AS Channel_ID,
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN 'DTC' ELSE CL.Channel_Type END AS Channel_Type,
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN '有赞' ELSE CL.Channel_Name_Short END  AS Channel_Name_Short,  --合并有赞数据
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN 'ONLINE' ELSE CL.Channel_FIN END AS Channel_FIN,
				CASE WHEN srs.Channel_ID  IN (45,58,65) THEN 'DTC' ELSE CL.SubChannel_FIN END AS SubChannel_FIN,
				0 AS [出库单未税],
				0 AS [FOC未税],
				0 AS [调拨单金额],
				rse.Amount AS [退货单未税],
				-rse.Amount AS [Net_Sales],
				0 AS [出库单含税],
				0 AS [FOC含税],
				rse.Full_Amount AS [退货单含税],
				-rse.Full_Amount AS [Net_Sales_wTax],
				0 [出库单非FOC吨数],
				0 [出库单FOC吨数],
				0 AS [调拨单吨数],
				rse.Net_Weight_KG/1000 AS [退货单吨数]
		FROM [dm].[Fct_ERP_Stock_ReturnStock] srs
		LEFT JOIN [dm].[Fct_ERP_Stock_ReturnStockEntry] rse
		ON srs.ReturnStock_ID=rse.ReturnStock_ID
		LEFT JOIN [dm].[Dim_Channel] cl ON srs.[Customer] = cl.ERP_Customer_Name
		WHERE srs.[Stock_Org]='富友联合食品（中国）有限公司'
		) T
		WHERE Channel_ID<>16  AND Customer_ID IS NOT NULL
		GROUP BY LEFT([Datekey],6),[Datekey],SKU_ID,Customer_ID,Customer_Name,Channel_ID,Channel_Type,Channel_Name_Short,Channel_FIN,SubChannel_FIN
	   ;

	   --Zbox 202006月份调单，不显示
	   DELETE FROM [dm].[Fct_Sales_SellIn_ByChannel_BySKU]
	   WHERE  Channel_ID=48 and Monthkey=202006

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH


	END


	--select * from  ODS.[ODS].[File_Sales_SellInTarget_ByChannel] o
	--where MonthKey=201912

	--select top 100 *from [ODS].[ods].[File_C
GO
