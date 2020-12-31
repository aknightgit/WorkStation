USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_ERP_SaleIn_byTarget_20191016]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





  CREATE PROC  [rpt].[SP_RPT_ERP_SaleIn_byTarget_20191016]
  as
  BEGIN
	
	----------------target-------------------
	SELECT 
		CASE WHEN sit.Channel IN ('OFFLINE','Dragon Team') THEN 1 ELSE 99 END  AS CID
		,CASE WHEN sit.Account_Display_Name ='永辉YH' THEN 1 WHEN sit.Account_Display_Name ='Vanguard' THEN 2 ELSE 99 END  AS ID
		,sit.Monthkey*100+1 AS [Period]
		  ,UPPER(sit.Channel) AS [On_Off_Line]
		  ,sit.Region AS [Channel]
		  ,CASE WHEN sit.Customer_Name LIKE '%华润%' THEN '华润万家'  
		  --WHEN sit.Customer_Name IN ('合肥苏鲜生超市采购有限公司') THEN '苏宁易购集团股份有限公司南京采购中心' 
		  ELSE sit.Customer_Name END AS [ERP_Account]
		  --,CASE WHEN sit.Account_Display_Name = '合肥苏鲜生超市采购有限公司' THEN '苏宁易购Suning' ELSE sit.Account_Display_Name END AS [Account]
		  ,sit.Account_Display_Name AS [Account]
		  ,ISNULL(ecm.[Handler],'') AS [Handler]
		  ,c.[Channel_Handler]
		  ,sit.Target_Amount AS [Target_AMT]
		  ,sit.Target_Volumn_MT AS [MT_Target_VOL]
		  ,0 AS [Actual_AMT]
		  ,0 AS [Actual_VOL]
		  ,0 AS [Active_Order_AMT]
		  ,0 AS [Open_Order_AMT]
		  ,0 AS [Active_Order_Vol]
		  ,0 AS [Open_Order_Vol]
		  ,GETDATE() UPDATE_DTM
	FROM [dm].[Fct_Sales_SellInTarget] sit WITH(NOLOCK)
	LEFT JOIN (SELECT DISTINCT  CONVERT(VARCHAR(6),Begin_Date,112) Monthkey,
			Channel,Channel_Handler 
		FROM [dm].[Dim_ERP_CustomerMapping])c ON sit.[Channel]=c.Channel AND sit.Monthkey=c.Monthkey
	LEFT JOIN [dm].[Dim_ERP_CustomerMapping] ecm WITH(NOLOCK) 
	ON sit.[Channel] = ecm.[Channel] AND sit.Region = ecm.Region
	AND sit.Customer_Name = isnull(ecm.Customer_Name,'')
	AND sit.Monthkey*100+1 BETWEEN convert(varchar(8),ecm.[Begin_Date],112) AND convert(varchar(8),ecm.[End_Date],112)
	AND sit.Account_Display_Name = ecm.Account_Display_Name
	--order by 1 desc

	UNION ALL


	----------------SaleIn-------------------
	/*
	SELECT CASE WHEN ch.Team IN ('OFFLINE','Dragon Team') THEN 1 ELSE 99 END  AS CID
		  ,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ch.Channel_Name_Display='Vanguard' THEN 2 ELSE 99 END 
		  ,[Datekey]
		  ,CASE WHEN ch.[ERP_Customer_Name] IN ('一次性现金客户','一次性现金客户-sales','一次性现金客户-清货') OR isnull(Channel_Name_Display,'') IN ('') THEN 'Other' 
				ELSE UPPER(Team) END AS Team
		  ,CASE WHEN ch.[ERP_Customer_Name] = '一次性现金客户' THEN 'FOC' 
				WHEN ch.[ERP_Customer_Name] IN ('一次性现金客户-sales','一次性现金客户-清货') THEN 'Clearance清货'
				WHEN isnull(ch.Channel_Name_Display,'')='' THEN ''  ELSE ch.Channel_Name_Display END AS [Channel]
		  ,CASE WHEN ch.Channel_Name_Display='Vanguard' THEN '华润万家' 
		  --WHEN [Customer_Name] IN ('合肥苏鲜生超市采购有限公司') THEN '苏宁易购集团股份有限公司南京采购中心' 
				ELSE ch.[ERP_Customer_Name] END AS [Customer_Name]
		  ,CASE 
		  --WHEN [Customer_Name] = '合肥苏鲜生超市采购有限公司' THEN '苏宁易购Suning'
				WHEN ch.[ERP_Customer_Name] IN ('一次性现金客户','一次性现金客户-sales','一次性现金客户-清货') OR [ERP_Customer_Name] IN ('Unknown') THEN ch.[ERP_Customer_Name] 	
				ELSE ch.Channel_Name_Display END AS Channel_Name_Display
		  ,CASE WHEN ch.[ERP_Customer_Name] IN ('一次性现金客户','一次性现金客户-sales','一次性现金客户-清货') OR [ERP_Customer_Name] IN ('Unknown') THEN '' ELSE ch.[Channel_Handler] END AS [Handler]
		  ,CASE WHEN ch.[Team_Handler] IN ('Unknown') THEN '' ELSE [Team_Handler] END AS [Team_Handler]
		  ,0 AS [Target_AMT]
		  ,0 AS [MT_Target_VOL]
		  ,Sum(Amount) AS [Actual_AMT]
		  ,sum(Weight_KG) AS [Actual_VOL]
		  ,sum(CASE WHEN [Status]='已关闭' THEN Amount ELSE NULL END) AS [Active_Order_Amt]
		  ,sum(CASE WHEN [Status]='已关闭' THEN  NULL ELSE Amount END) AS [Open_Order_AMT]
		  ,sum(CASE WHEN [Status]='已关闭' THEN Weight_KG ELSE NULL END) AS [Active_Order_Vol]
		  ,sum(CASE WHEN [Status]='已关闭' THEN NULL ELSE Weight_KG END) AS [Open_Order_Vol]
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE [Datekey]>=20190201 
	GROUP BY [Datekey]
        ,[Team]
        --,[Channel]
        ,ch.[ERP_Customer_Name] 
        ,ch.Channel_Name_Display
        ,ch.[Team_Handler]
        ,ch.[Channel_Handler]
*/
	SELECT  
	   CASE WHEN [On_Off_Line] IN ('OFFLINE','Dragon Team') THEN 1 ELSE 99 END  AS CID
	  ,CASE WHEN [Account] ='永辉YH' THEN 1 WHEN Channel LIKE '%Vanguard%' THEN 2 ELSE 99 END 
	  ,[Datekey]
      ,CASE WHEN [Customer_Name] IN ('一次性现金客户','一次性现金客户-sales','一次性现金客户-清货') OR [Account] IN ('Unknown') THEN 'Other' 
			ELSE UPPER([On_Off_Line]) END AS [On_Off_Line]
      ,CASE WHEN [Customer_Name] = '一次性现金客户' THEN 'FOC' 
			WHEN [Customer_Name] IN ('一次性现金客户-sales','一次性现金客户-清货') THEN 'Clearance清货'
			WHEN [Account] IN ('Unknown') THEN ''  ELSE [Channel] END AS [Channel]
      ,CASE WHEN [Customer_Name] LIKE '%华润%' THEN '华润万家' 
	  --WHEN [Customer_Name] IN ('合肥苏鲜生超市采购有限公司') THEN '苏宁易购集团股份有限公司南京采购中心' 
	  ELSE [Customer_Name] END AS [Customer_Name]
      ,CASE 
	  --WHEN [Customer_Name] = '合肥苏鲜生超市采购有限公司' THEN '苏宁易购Suning'
		    WHEN [Customer_Name] IN ('一次性现金客户','一次性现金客户-sales','一次性现金客户-清货') OR [Account] IN ('Unknown') THEN [Customer_Name] 	
			ELSE [Account] END AS [Account]
      ,CASE WHEN [Customer_Name] IN ('一次性现金客户','一次性现金客户-sales','一次性现金客户-清货') OR [Account] IN ('Unknown') THEN '' ELSE [Handler] END AS [Handler]
      ,CASE WHEN [Channel_Handler] IN ('Unknown') THEN '' ELSE [Channel_Handler] END AS [Channel_Handler]
	  ,0 AS [Target_AMT]
	  ,0 AS [MT_Target_VOL]
      ,Sum([Actual_AMT])[Actual_AMT]
      ,sum([Actual_VOL])[Actual_VOL]
      ,sum([Active_Order_Amt])[Active_Order_Amt]
      ,sum([Open_Order_AMT])[Open_Order_AMT]
      ,sum([Active_Order_Vol])[Active_Order_Vol]
      ,sum([Open_Order_Vol])[Open_Order_Vol]
      ,GETDATE() UPDATE_DTM
    FROM [rpt].[ERP_Sales_Order]
    WHERE [Datekey]>=20190201  --Show data only after 201902 in SellinOverview
    --AND  [Datekey]>=20190601  AND Customer_Name='有赞商城'
    GROUP BY [Datekey]
        ,[On_Off_Line]
        ,[Channel]
        ,[Customer_Name]
        ,[Account]
        ,[Handler]
        ,[Channel_Handler]
    --ORDER BY 1 DESC

	UNION ALL
	------------------寄售模式 使用调拨单计算--------------------
	SELECT  
	   99 AS CID
	  ,99 AS ID 
	  ,[Datekey]
      ,'MKT' AS [On_Off_Line]
      ,'MKT' AS [Channel]
      ,'Kidswant' AS [Customer_Name]
	  ,'Kidswant' AS [Account]
	  ,'Davy' AS [Handler]
      ,'Susie' AS [Channel_Handler]
	  ,0 AS [Target_AMT]
	  ,0 AS [MT_Target_VOL]
      ,Sum(stie.Sale_QTY * p.Sale_Unit_RSP / 1000) AS [Actual_AMT]
      ,sum(stie.Base_Unit_QTY * p.Base_Unit_Weight_KG / 1000) AS [Actual_VOL]
      ,0 [Active_Order_Amt]
      ,0 [Open_Order_AMT]
      ,0 [Active_Order_Vol]
      ,0 [Open_Order_Vol]
      ,GETDATE() 
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	WHERE stie.Dest_Stock like '%孩子王寄售仓%'
	GROUP BY [Datekey]

	  /*
	UNION ALL     -- Simulate Lakto/Rasa Tmall Flagship sales via OMS orders, if there's already record from ERP, this part should be ignored.
	SELECT  
		do.Order_MonthKey*100+1
		,cm.Channel
		,cm.Region
		--,'Online'	
		--,'EC-B2C'		
		,dp.Platform_Name_CN
		,CASE WHEN dp.Platform_Name_CN='Lakto旗舰店' THEN 'Tmall flagship store-lakto'
			WHEN dp.Platform_Name_CN='Rasa旗舰店' THEN 'Tmall flagship store-rasa' END
		--,'Seven Chen'	
		--,'Vincent'	
		,cm.Handler
		,cm.Channel_Handler
		,0	
		,0
		,sum(oi.Quantity*pl.SKU_Price)/1000 AS Sale_Amount -- 未税
		,null
		,0
		,0
		,null
		,null
		,getdate()
	FROM [dm].[Fct_Order_Item] oi with(nolock)
	JOIN [dm].[Dim_Order] do with(nolock) on oi.Order_ID=do.Order_ID
	LEFT JOIN  [dm].[Dim_Product_Pricelist] pl with(nolock) on oi.SKU_ID=pl.SKU_ID	
	JOIN  dm.Dim_Platform dp with(nolock) on do.Platform_ID=dp.Platform_ID	and pl.Is_Current=1	and pl.Price_List_Name='B2C20190422'   -- new price before tax
	LEFT JOIN dm.Dim_ERP_CustomerMapping cm on dp.Platform_Name_CN = cm.Customer_Name and cm.Is_Current = 1
	WHERE do.Platform_ID in (1,2)
	and do.Order_Status NOT IN ('TRADE_CLOSED','TRADE_CLOSED_BY_TAOBAO')  --normal order only
	and do.Order_MonthKey = convert(varchar(6),getdate(),112)  --current month only
	and not exists (select top 1 1 from [rpt].[ERP_Sales_Order] where Customer_Name IN ('Lakto旗舰店','Rasa旗舰店') AND Datekey >= convert(varchar(6),getdate(),112)*100+1)
	GROUP BY do.Order_MonthKey*100+1
		,cm.Channel
		,cm.Region
		,cm.Handler
		,cm.Channel_Handler
		,dp.Platform_Name_CN;
		*/
END

GO
