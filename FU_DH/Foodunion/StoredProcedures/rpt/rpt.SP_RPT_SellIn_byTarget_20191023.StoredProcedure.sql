USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_SellIn_byTarget_20191023]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





  CREATE PROC  [rpt].[SP_RPT_SellIn_byTarget_20191023]
  as
  BEGIN
	
	----------------target-------------------
	
	SELECT CASE WHEN ch.Team IN ('OFFLINE','Dragon Team','YH') THEN 1 ELSE 99 END  AS CID
		  ,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ch.Channel_Name_Display='Vanguard' THEN 2 ELSE 99 END AS ID
		  ,sit.Monthkey*100+1 AS [Datekey]
		  ,UPPER(ch.[Team]) AS [Team]
		  ,ISNULL(ch.Channel_Category,sit.Region) AS [Channel_Category]
		  ,CASE WHEN ch.Channel_Name_Display='Vanguard' THEN '华润万家Vanguard' ELSE ISNULL(ch.[ERP_Customer_Name],sit.Customer_Name) END AS [Customer_Name]
		  ,ISNULL(ch.Channel_Name_Display,ch.[ERP_Customer_Name]) AS [Channel_Name_Display]
		  ,ISNULL(ch.[Channel_Handler],'') AS [Handler]
		  ,ISNULL(ch.[Team_Handler],'') AS [Team_Handler]
		  ,sit.Target_Amount AS [Target_AMT]
		,sit.Target_Volumn_MT AS [MT_Target_VOL]
		,0 AS [Actual_AMT]
		,0 AS [Actual_VOL]
		,0 AS [Active_Order_AMT]
		,0 AS [Open_Order_AMT]
		,0 AS [Active_Order_Vol]
		,0 AS [Open_Order_Vol]
		,GETDATE() UPDATE_DTM
		--,sit.Customer_Name
	FROM [dm].[Fct_Sales_SellInTarget] sit WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON sit.Customer_Name=ch.ERP_Customer_Name AND ch.Monthkey = sit.Monthkey
	--WHERE sit.Monthkey=201910

	union


	SELECT DISTINCT CASE WHEN coalesce(ch.[Team],sit.Channel,ch2.Team) IN ('OFFLINE','Dragon Team','YH') THEN 1 ELSE 99 END  AS CID
		,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ISNULL(ch.Channel_Category,sit.Region)='Vanguard' THEN 2 ELSE 99 END AS ID
		,sit.Monthkey*100+1 AS [Datekey]
		,UPPER(coalesce(ch.[Team],sit.Channel,ch2.Team)) AS [Team]
		,ISNULL(ch.Channel_Category,sit.Region) AS [Channel_Category]
		,CASE WHEN ch.Channel_Name_Display='Vanguard' THEN '华润万家Vanguard' ELSE ISNULL(ch.[ERP_Customer_Name],sit.Customer_Name) END AS [Customer_Name]
		,ISNULL(ch.Channel_Name_Display,sit.Account_Display_Name) AS [Channel_Name_Display]
		,coalesce(ch.[Channel_Handler],ch2.[Channel_Handler],'') AS [Handler]
		,ISNULL(ch.[Team_Handler],ch2.[Team_Handler]) AS [Team_Handler]
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
	LEFT JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON sit.Customer_Name=ch.ERP_Customer_Name AND ch.Monthkey = sit.Monthkey
	LEFT JOIN (SELECT DISTINCT Monthkey, Team, Team_Handler, Channel_Category,Channel_Handler FROM [dm].[Dim_Channel_hist]) ch2 
		ON sit.Region=ch2.Channel_Category AND ch2.Monthkey = sit.Monthkey
	--WHERE sit.Monthkey=201910 AND ch.ERP_Customer_Name is null


	UNION ALL


	----------------SaleIn-------------------
	
	SELECT CASE WHEN ch.Team IN ('OFFLINE','Dragon Team','YH') THEN 1 ELSE 99 END  AS CID
		  ,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ch.Channel_Name_Display='Vanguard' THEN 2 ELSE 99 END 
		  ,[Datekey]
		  ,UPPER(ch.[Team]) AS [Team]
		  ,ch.Channel_Category  AS [Channel_Category]
		  ,CASE WHEN ch.Channel_Name_Display='Vanguard' THEN '华润万家Vanguard' ELSE ch.[ERP_Customer_Name] END AS [Customer_Name]
		  ,ISNULL(ch.Channel_Name_Display,ch.[ERP_Customer_Name]) AS [Channel_Name_Display]
		  ,ISNULL(ch.[Channel_Handler],'') AS [Handler]
		  ,ch.[Team_Handler] AS [Team_Handler]
		  ,0 AS [Target_AMT]
		  ,0 AS [MT_Target_VOL]
		  ,Sum(Amount)/1000 AS [Actual_AMT]
		  ,sum(Weight_KG)/1000 AS [Actual_VOL]
		  ,sum(CASE WHEN [Status]='已关闭' THEN Amount ELSE 0 END)/1000 AS [Active_Order_Amt]
		  ,sum(CASE WHEN [Status]='已关闭' THEN 0 ELSE Amount END)/1000 AS [Open_Order_AMT]
		  ,sum(CASE WHEN [Status]='已关闭' THEN Weight_KG ELSE 0 END)/1000 AS [Active_Order_Vol]
		  ,sum(CASE WHEN [Status]='已关闭' THEN 0 ELSE Weight_KG END)/1000 AS [Open_Order_Vol]
		  ,GETDATE() UPDATE_DTM
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE [Datekey]>=20190201 
	--and ch.ERP_Customer_Name='北京去楼下科技有限公司'
	GROUP BY [Datekey]
        ,ch.[Team]
        --,[Channel]
		,ch.Channel_Category
        ,ch.[ERP_Customer_Name] 
        ,ch.Channel_Name_Display
        ,ch.[Team_Handler]
        ,ch.[Channel_Handler]
		--ORDER BY 3,4,6

	
	UNION ALL
	------------------寄售模式 使用调拨单计算--------------------
	SELECT  
	   99 AS CID
	  ,99 AS ID 
	  ,[Datekey]
      ,'MKT' AS [Team]
      ,'Kidswant' AS [Channel_Category]
      ,'Kidswant' AS [Customer_Name]
	  ,'Kidswant' AS [Channel_Name_Display]
	  ,'Joe You' AS [Handler]
      ,'Susie' AS [Team_Handler]
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
