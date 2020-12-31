USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








  CREATE PROC  [rpt].[SP_RPT_SellIn_byTarget]
  as
  BEGIN
	
	----------------target-------------------
	
	SELECT 
	   [CID]
      ,[ID]
      ,[Datekey]
      ,sch.[Team]
      ,sch.[Channel_Category]
	  ,dc.Channel_Type
      ,[Customer_Name]
      ,sch.[Channel_Name_Display]
      ,[Handler]
      ,sch.[Team_Handler]
      ,[Target_AMT]
      ,[MT_Target_VOL]
	  ,0 AS [MT_DP_VOL]                              --增加单独DP     Justin 2020-01-09
      ,[Actual_AMT]
      ,[Actual_VOL]
      ,[Active_Order_AMT]
      ,[Open_Order_AMT]
      ,[Active_Order_Vol]
      ,[Open_Order_Vol]
      ,[UPDATE_DTM] 
	  FROM [dm].[Fct_Sales_SellInTarget_ByChannel_hist] sch 
	  LEFT JOIN dm.Dim_Channel dc on sch.Customer_Name = dc.ERP_Customer_Name

	UNION ALL
	SELECT CASE WHEN ch.Team IN ('OFFLINE','Dragon Team','YH') THEN 1 WHEN ch.Team IN ('Phoenix Team') THEN 2 ELSE 99 END  AS CID
		,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ch.Channel_Name_Display='Vanguard' THEN 2 ELSE 99 END AS ID
		,sit.Monthkey*100+1 AS [Datekey]
		,UPPER(ch.[Team]) AS [Team]
		,ch.Channel_Category AS [Channel_Category]
		--,CASE WHEN ch.ERP_Customer_Name = '北京去楼下科技有限公司' THEN 'Qulouxia' ELSE sit.Channel_Type END AS Channel_Type
		,sit.Channel_Type AS Channel_Type
		--,CASE WHEN ch.Channel_Name_Display='Vanguard' THEN '华润万家生活超市（浙江）有限公司' WHEN ch.Channel_Name_Display='Kidswant' THEN '孩子王儿童用品股份有限公司采购中心' ELSE sit.ERP_Customer_Name END AS [Customer_Name]
		,sit.ERP_Customer_Name AS [Customer_Name]
		,ISNULL(ch.[Channel_Name_Display],ch.[ERP_Customer_Name]) AS [Channel_Name_Display]
		,ISNULL(ch.[Channel_Handler],'') AS [Handler]
		,ISNULL(ch.[Team_Handler],'') AS [Team_Handler]
		,CASE WHEN sit.Channel_Type='Distributor' THEN 0 ELSE ISNULL(sit.[Target_Amt_KRMB],0)  END AS [Target_AMT]    --增加单独DP ，CP Target 用CP上传数据    Justin 2020-01-09
		--,ISNULL(sit.[Target_Vol_MT],0) AS [MT_Target_VOL]
		,CASE WHEN sit.Channel_Type='Distributor' THEN 0 ELSE ISNULL(sit.[Target_Vol_MT],0) END AS [MT_Target_VOL]    --增加单独DP ，CP Target 用CP上传数据    Justin 2020-01-09
		,ISNULL(sit.[DP_Vol_MT],0) AS [MT_DP_VOL]     --增加单独DP     Justin 2020-01-09
		,0 AS [Actual_AMT]
		,0 AS [Actual_VOL]
		,0 AS [Active_Order_AMT]
		,0 AS [Open_Order_AMT]
		,0 AS [Active_Order_Vol]
		,0 AS [Open_Order_Vol]
		,GETDATE() UPDATE_DTM
		--,sit.Customer_Name
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] sit WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
    ON sit.ERP_Customer_Name=ch.ERP_Customer_Name AND ch.Monthkey = sit.Monthkey AND (sit.Target_Amt_KRMB IS NOT NULL OR sit.[Target_Vol_MT] IS NOT NULL)
	--AND sit.Channel_Type <> 'CP'
	--WHERE sit.Monthkey=202006        --增加单独DP Target ,不需要过滤CP   Justin 2020-01-09

	UNION ALL

	SELECT DISTINCT CASE WHEN ISNULL(ch.[Team],sit.Team) IN ('OFFLINE','Dragon Team','YH') THEN 1 WHEN ISNULL(ch.[Team],sit.Team) IN ('Phoenix Team') THEN 2 ELSE 99 END  AS CID
		,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ch.Channel_Category='Vanguard' THEN 2 ELSE 99 END AS ID
		,sit.Monthkey*100+1 AS [Datekey]
		,UPPER(ISNULL(ch.[Team],sit.Team)) AS [Team]
		,sit.Channel_Category_Name AS [Channel_Category]
		,sit.Channel_Type
		,'' AS [Customer_Name]
		,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN '永辉YH' WHEN ch.Channel_Category='DTC' THEN '有赞Youzan' ELSE ch.Channel_Category END AS [Channel_Name_Display]
		,ISNULL(ch.[Channel_Handler],sit.Channel_Handler) AS [Handler]
		,ISNULL(ch.[Team_Handler],sit.Team_Handler) AS [Team_Handler]
		,ISNULL(sit.Category_Target_Amt_KRMB,0) AS [Target_AMT]
		,ISNULL(sit.Category_Target_Vol_MT,0) AS [MT_Target_VOL]
		,ISNULL(sit.[Category_DP_Vol_MT],0) AS [MT_DP_VOL]                                     --增加单独DP    Justin 2020-01-09
		,0 AS [Actual_AMT]
		,0 AS [Actual_VOL]
		,0 AS [Active_Order_AMT]
		,0 AS [Open_Order_AMT]
		,0 AS [Active_Order_Vol]
		,0 AS [Open_Order_Vol]
		,GETDATE() UPDATE_DTM
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] sit WITH(NOLOCK)
	LEFT JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON sit.Channel_Category_Name=ch.Channel_Category AND ch.Monthkey = sit.Monthkey
	--LEFT JOIN (SELECT DISTINCT Monthkey, Team, Team_Handler, Channel_Category,Channel_Handler FROM [dm].[Dim_Channel_hist]) ch2 
	--	ON sit.Region=ch2.Channel_Category AND ch2.Monthkey = sit.Monthkey
	WHERE (sit.Category_Target_Amt_KRMB IS NOT NULL OR sit.Category_Target_Vol_MT IS NOT NULL OR sit.[Category_DP_Vol_MT] IS NOT NULL)
	--AND sit.Monthkey=202006
	

	UNION ALL
	----------------SaleIn-------------------
	
	SELECT CASE WHEN ch.Team IN ('OFFLINE','Dragon Team','YH') THEN 1 WHEN ch.Team IN ('Phoenix Team') THEN 2 ELSE 99 END  AS CID
		  ,CASE WHEN ch.Channel_Name_Display ='永辉YH' THEN 1 WHEN ch.Channel_Name_Display='Vanguard' THEN 2 ELSE 99 END 
		  ,[Datekey]
		  ,UPPER(ch.[Team]) AS [Team]
		  ,ch.Channel_Category  AS [Channel_Category]
		  --,CASE WHEN ch.ERP_Customer_Name = '北京去楼下科技有限公司' THEN 'Qulouxia' ELSE ch.Channel_Type END AS Channel_Type
		  ,ch.Channel_Type AS Channel_Type
		  --,CASE WHEN ch.Channel_Name_Display='Vanguard' THEN '华润万家生活超市（浙江）有限公司' WHEN ch.Channel_Name_Display='Kidswant' THEN '孩子王儿童用品股份有限公司采购中心' ELSE ch.ERP_Customer_Name END AS [Customer_Name] 
		  ,ch.ERP_Customer_Name AS [Customer_Name] 
		  ,ISNULL(ch.Channel_Name_Display,ch.[ERP_Customer_Name]) AS [Channel_Name_Display]
		  ,ISNULL(ch.[Channel_Handler],'') AS [Handler]
		  ,ch.[Team_Handler] AS [Team_Handler]
		  ,0 AS [Target_AMT]
		  ,0 AS [MT_Target_VOL]
		  ,0 AS [MT_DP_VOL]
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
	WHERE [Datekey]>=20190101 
		and ch.Channel_Name <>'KidsWant'
	--and ch.ERP_Customer_Name='北京去楼下科技有限公司'
	AND ch.Channel_Category NOT IN ('EC-Tmall','EC-PDD','Zbox','DTC')
	GROUP BY [Datekey]
        ,ch.[Team]
        --,[Channel]
		,ch.Channel_Type
		,ch.Channel_Category
        ,ch.[ERP_Customer_Name] 
        ,ch.Channel_Name_Display
        ,ch.[Team_Handler]
        ,ch.[Channel_Handler]
		--ORDER BY 3,4,6

	
	--UNION ALL
	------------------寄售模式(孩子王) 使用调拨单计算--------------------
	/* 
	SELECT  
	   1 AS CID
	  ,99 AS ID 
	  ,[Datekey]
      ,ch.Team AS [Team]
      ,ch.Channel_Category AS [Channel_Category]
	  ,'Kidswant' AS [Channel_Type]
      ,'孩子王儿童用品股份有限公司采购中心' AS [Customer_Name]
	  ,'Kidswant' AS [Channel_Name_Display]
	  ,ch.Channel_Handler AS [Handler]
      ,ch.Team_Handler AS [Team_Handler]
	  ,0 AS [Target_AMT]
	  ,0 AS [MT_Target_VOL]
	  ,0 AS [MT_DP_VOL]
      ,Sum(stie.Sale_QTY * isnull(pl.SKU_Price,p.Sale_Unit_RSP*0.85) / 1000) AS [Actual_AMT]
      ,sum(stie.Base_Unit_QTY * p.Base_Unit_Weight_KG / 1000) AS [Actual_VOL]
      ,0 [Active_Order_Amt]
      ,0 [Open_Order_AMT]
      ,0 [Active_Order_Vol]
      ,0 [Open_Order_Vol]
      ,GETDATE() 
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON ch.Channel_Name='Kidswant' AND ch.Monthkey = sti.DateKey/100
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock like '%孩子王寄售仓%'
	--AND pl.SKU_ID IS NULL
	GROUP BY [Datekey],ch.Team 
      ,ch.Channel_Category,ch.Channel_Handler,ch.Team_Handler
	  */
	
	ORDER BY 3 DESC,4,5
	
END

GO
