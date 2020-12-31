USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_Qulouxia_DCInventory_Daily_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE [dm].[Fct_Qulouxia_DCInventory_Daily];   --09上一天的期末库存
	INSERT INTO [dm].[Fct_Qulouxia_DCInventory_Daily]
     ( [Datekey]
      ,[SKU_ID]
	  ,[SKU_Code]
      ,[Scale]
      ,[Unit]
      ,[Produce_Date]
      ,[Expiry_Date]
      ,[Remain_Days]
      ,[Inventory_QTY]
      ,[Inbound_QTY]
      ,[Outbound_QTY]
      ,[NetChange_QTY]
      ,[Sale_Days]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	SELECT CONVERT(VARCHAR(8),dc.[Date],112) AS [Datekey]
		,CM.[SKU_ID]
		,DC.SKU_Code
		,P.Sale_Scale AS  [Scale]
		,MAX(p.Sale_Unit) AS [Unit]
		,CAST(DC.Batch_No as Date) AS [Produce_Date]
		,DATEADD(DAY,CAST(p.Shelf_Life_D AS INT),CAST(DC.Batch_No as Date)) AS [Expiry_Date]
		,CASE WHEN CAST(p.Shelf_Life_D AS INT) - DATEDIFF(DAY,CAST(DC.Batch_No as Date),CAST(DC.[Date] AS DATE)) <0 THEN 0
			ELSE CAST(p.Shelf_Life_D AS INT) - DATEDIFF(DAY,CAST(DC.Batch_No as Date),CAST(DC.[Date] AS DATE)) END AS [Remain_Days]
		,SUM(DC.Inv_QTY) AS  [Inventory_QTY]
		,0 AS [Inbound_QTY]
		,0 AS [Outbound_QTY]
		,0 [NetChange_QTY]
		,NULL AS [Sale_Days]
		,GETDATE() AS [Create_Time]
		,'' AS [Create_By]
		,GETDATE() AS [Update_Time]
		,'' AS [Update_By] 
		--into #DCInv_L
	FROM ODS.ODS.File_Qulouxia_Inventory dc 
	LEFT JOIN (SELECT * FROM DM.Dim_Product_AccountCodeMapping WHERE Account='Zbox') CM
	ON DC.SKU_Code=CM.SKU_Code
	LEFT JOIN [dm].[Dim_Product] P
	ON CM.SKU_ID=P.SKU_ID
	WHERE CONVERT(VARCHAR(10),DATEADD(DAY,1,DC.[Date]),112)<=CONVERT(VARCHAR(10),GETDATE(),112)
	AND dc.SKU_Code NOT IN ('126911') --蓝堡臻风味优格一次性勺子1g
	GROUP BY dc.[Date]
		,CM.[SKU_ID]
		,DC.SKU_Code
		,P.Sale_Scale
		,DC.Batch_No
		,p.Shelf_Life_D
		,DC.Batch_No ;

	/*
	SELECT CONVERT(VARCHAR(8),DC.DATE,112) AS [Datekey]
		,CM.[SKU_ID]
		,P.Sale_Scale AS  [Scale]
		,MAX(DC.[Unit])
		,DC.[Produce_Date]
		,DC.[Expiry_Date]
		,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) AS [Remain_Days]
		,SUM(DC.Inv_QTY) AS  [Inventory_QTY]
		,0 AS [Inbound_QTY]
		,0 AS [Outbound_QTY]
		,0 [NetChange_QTY]
		,NULL AS [Sale_Days]
		,GETDATE() AS [Create_Time]
		,'' AS [Create_By]
		,GETDATE() AS [Update_Time]
		,'' AS [Update_By] 
		--into #DCInv_L
	FROM ODS.ODS.File_Qulouxia_DCInventory DC 
	LEFT JOIN (SELECT * FROM DM.Dim_Product_AccountCodeMapping WHERE Account='Zbox') CM
	ON DC.SKU_Code=CM.SKU_Code
	LEFT JOIN [dm].[Dim_Product] P
	ON CM.SKU_ID=P.SKU_ID
	WHERE CONVERT(VARCHAR(10),DATEADD(DAY,1,DC.DATE),112)<=CONVERT(VARCHAR(10),GETDATE(),112)
	AND dc.SKU_Code NOT IN ('126911') --蓝堡臻风味优格一次性勺子1g
	GROUP BY CONVERT(VARCHAR(8),DC.DATE,112)
		,CM.[SKU_ID]
		,P.Sale_Scale
		--,DC.[Unit]
		,DC.[Produce_Date]
		,DC.[Expiry_Date]
		,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) ;
		*/
	
	  

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END


--select * from #DCInv1 where Datekey=20200519 and sku_id ='2100073_0' and Expiry_Date='2020-05-30'
--select * from #DCInv_L where Datekey=20200519 and sku_id ='2100073_0' and Expiry_Date='2020-05-30'


--select distinct date from ods.ods.File_Qulouxia_DCInventory


	
	--IF (SELECT MAX(CONVERT(VARCHAR(10),DATE,112)) FROM ODS.ODS.File_Qulouxia_DCInventory)< CONVERT(VARCHAR(10),GETDATE(),112)  --判断当天是否有数据
	--BEGIN
	--DROP TABLE  IF EXISTS #DCInv1;
	--SELECT CONVERT(VARCHAR(10),DC.DATE,112) AS [Datekey]
	--	,CM.[SKU_ID]
	--	,P.Sale_Scale AS  [Scale]
	--	,DC.[Unit]
	--	,DC.[Produce_Date]
	--	,DC.[Expiry_Date]
	--	,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) AS [Remain_Days]
	--	,SUM(DC.Inv_QTY) AS  [Inventory_QTY]
	--	,0 AS [Inbound_QTY]
	--	,0 AS [Outbound_QTY]
	--	,0 [NetChange_QTY]
	--	,NULL AS [Sale_Days]
	--	,GETDATE() AS [Create_Time]
	--	,'' AS [Create_By]
	--	,GETDATE() AS [Update_Time]
	--	,'' AS [Update_By] INTO #DCInv1
	--FROM ODS.ODS.File_Qulouxia_DCInventory DC
	--LEFT JOIN (SELECT * FROM DM.Dim_Product_AccountCodeMapping WHERE Account='Zbox') CM
	--ON DC.SKU_Code=CM.SKU_Code
	--LEFT JOIN [dm].[Dim_Product] P
	--ON CM.SKU_ID=P.SKU_ID
	--WHERE dc.SKU_Code NOT IN ('126911') --蓝堡臻风味优格一次性勺子1g
	--GROUP BY CONVERT(VARCHAR(10),DC.DATE,112) 
	--	,CM.[SKU_ID]
	--	,P.Sale_Scale 
	--	,DC.[Unit]
	--	,DC.[Produce_Date]
	--	,DC.[Expiry_Date]
	--	,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) 
	--UNION  --如果当天没有数据，取前一天数据作为当天数据
	--SELECT CONVERT(VARCHAR(10),GETDATE(),112) AS [Datekey]
	--	,CM.[SKU_ID]
	--	,P.Sale_Scale AS [Scale]
	--	,DC.[Unit]
	--	,DC.[Produce_Date]
	--	,DC.[Expiry_Date]
	--	,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) AS [Remain_Days]
	--	,SUM(DC.Inv_QTY) AS  [Inventory_QTY]
	--	,0 AS [Inbound_QTY]
	--	,0 AS [Outbound_QTY]
	--	,0 [NetChange_QTY]
	--	,NULL AS [Sale_Days]
	--	,GETDATE() AS [Create_Time]
	--	,'' AS [Create_By]
	--	,GETDATE() AS [Update_Time]
	--	,'' AS [Update_By]
	--FROM ODS.ODS.File_Qulouxia_DCInventory DC
	--LEFT JOIN (SELECT * FROM DM.Dim_Product_AccountCodeMapping WHERE Account='Zbox') CM
	--ON DC.SKU_Code=CM.SKU_Code
	--LEFT JOIN [dm].[Dim_Product] P
	--ON CM.SKU_ID=P.SKU_ID
	--WHERE CONVERT(VARCHAR(10),DC.DATE,112)=CONVERT(VARCHAR(10),DATEADD(DAY,-1,GETDATE()),112)
	--AND dc.SKU_Code NOT IN ('126911') --蓝堡臻风味优格一次性勺子1g
	--GROUP BY CONVERT(VARCHAR(10),DC.DATE,112) 
	--	,CM.[SKU_ID]
	--	,P.Sale_Scale 
	--	,DC.[Unit]
	--	,DC.[Produce_Date]
	--	,DC.[Expiry_Date]
	--	,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) ;

	--	TRUNCATE TABLE [dm].[Fct_Qulouxia_DCInventory_Daily];
	--	INSERT INTO [dm].[Fct_Qulouxia_DCInventory_Daily]
	--	( [Datekey]
	--	,[SKU_ID]
	--	,[Scale]
	--	,[Unit]
	--	,[Produce_Date]
	--	,[Expiry_Date]
	--	,[Remain_Days]
	--	,[Inventory_QTY]
	--	,[Inbound_QTY]
	--	,[Outbound_QTY]
	--	,[NetChange_QTY]
	--	,[Sale_Days]
	--	,[Create_Time]
	--	,[Create_By]
	--	,[Update_Time]
	--	,[Update_By])
	--	SELECT ISNULL(D1.[Datekey],DL.[Datekey]) [Datekey]
	--	,ISNULL(D1.[SKU_ID],DL.[SKU_ID]) [SKU_ID]
	--	,ISNULL(D1.[Scale],DL.[Scale]) [Scale]
	--	,ISNULL(D1.[Unit],DL.[Unit]) [Unit]
	--	,ISNULL(D1.[Produce_Date],DL.[Produce_Date]) [Produce_Date]
	--	,ISNULL(D1.[Expiry_Date],DL.[Expiry_Date]) [Expiry_Date]
	--	,ISNULL(D1.[Remain_Days],DL.[Remain_Days]) [Remain_Days]
	--	,ISNULL(D1.[Inventory_QTY],0) [Inventory_QTY]
	--	,ISNULL(D1.[Inbound_QTY],DL.[Inbound_QTY]) [Inbound_QTY]
	--	,ISNULL(D1.[Outbound_QTY],DL.[Outbound_QTY]) [Outbound_QTY]
	--	,ISNULL(D1.[Inventory_QTY],0)-ISNULL(DL.[Inventory_QTY],0) AS [NetChange_QTY]
	--	,ISNULL(D1.[Sale_Days],DL.[Sale_Days]) [Sale_Days]
	--	,ISNULL(D1.[Create_Time],DL.[Create_Time]) [Create_Time]
	--	,ISNULL(D1.[Create_By],DL.[Create_By]) [Create_By]
	--	,ISNULL(D1.[Update_Time],DL.[Update_Time])[Update_Time]
	--	,ISNULL(D1.[Update_By],DL.[Update_By]) [Update_By]
	--	FROM #DCInv1 AS D1
	--	FULL JOIN #DCInv_L AS DL
	--	ON D1.Datekey=DL.Datekey AND D1.SKU_ID=DL.SKU_ID AND D1.Expiry_Date=DL.Expiry_Date
	--	WHERE ISNULL(D1.[Datekey],DL.[Datekey])='20200519' AND ISNULL(D1.[SKU_ID],DL.[SKU_ID])='2100073_0' AND ISNULL(D1.[Expiry_Date],DL.[Expiry_Date])='2020-05-30'

 --END

--  IF (SELECT MAX(CONVERT(VARCHAR(10),DATE,112)) FROM ODS.ODS.File_Qulouxia_DCInventory)=CONVERT(VARCHAR(10),GETDATE(),112)  --判断当天是否有数据
--  BEGIN
--  DROP TABLE  IF EXISTS #DCInv2;
--  SELECT CONVERT(VARCHAR(10),DC.DATE,112) AS [Datekey]
--      ,CM.[SKU_ID]
--      ,P.Sale_Scale [Scale]
--      ,DC.[Unit]
--      ,DC.[Produce_Date]
--      ,DC.[Expiry_Date]
--      ,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) AS [Remain_Days]
--      ,SUM(DC.Inv_QTY) AS  [Inventory_QTY]
--      ,0 AS [Inbound_QTY]
--      ,0 AS [Outbound_QTY]
--      ,0 [NetChange_QTY]
--      ,NULL AS [Sale_Days]
--      ,GETDATE() AS [Create_Time]
--      ,'' AS [Create_By]
--      ,GETDATE() AS [Update_Time]
--      ,'' AS [Update_By] INTO #DCInv2
--  FROM ODS.ODS.File_Qulouxia_DCInventory DC
--  LEFT JOIN (SELECT * FROM DM.Dim_Product_AccountCodeMapping WHERE Account='Zbox') CM
--  ON DC.SKU_Code=CM.SKU_Code
--   LEFT JOIN [dm].[Dim_Product] P
--  ON CM.SKU_ID=P.SKU_ID
--  GROUP BY CONVERT(VARCHAR(10),DC.DATE,112) 
--      ,CM.[SKU_ID]
--      ,P.Sale_Scale 
--      ,DC.[Unit]
--      ,DC.[Produce_Date]
--      ,DC.[Expiry_Date]
--      ,DATEDIFF(DAY,CAST(DC.DATE AS DATE),CAST(DC.[Expiry_Date] AS DATE)) 

--	  TRUNCATE TABLE [dm].[Fct_Qulouxia_DCInventory_Daily]
--	  INSERT INTO [dm].[Fct_Qulouxia_DCInventory_Daily]
--     ( [Datekey]
--      ,[SKU_ID]
--      ,[Scale]
--      ,[Unit]
--      ,[Produce_Date]
--      ,[Expiry_Date]
--      ,[Remain_Days]
--      ,[Inventory_QTY]
--      ,[Inbound_QTY]
--      ,[Outbound_QTY]
--      ,[NetChange_QTY]
--      ,[Sale_Days]
--      ,[Create_Time]
--      ,[Create_By]
--      ,[Update_Time]
--      ,[Update_By])
--	  SELECT ISNULL(D1.[Datekey],DL.[Datekey]) [Datekey]
--      ,ISNULL(D1.[SKU_ID],DL.[SKU_ID]) [SKU_ID]
--      ,ISNULL(D1.[Scale],DL.[Scale]) [Scale]
--      ,ISNULL(D1.[Unit],DL.[Unit]) [Unit]
--      ,ISNULL(D1.[Produce_Date],DL.[Produce_Date]) [Produce_Date]
--      ,ISNULL(D1.[Expiry_Date],DL.[Expiry_Date]) [Expiry_Date]
--      ,ISNULL(D1.[Remain_Days],DL.[Remain_Days]) [Remain_Days]
--      ,ISNULL(D1.[Inventory_QTY],0) [Inventory_QTY]
--      ,ISNULL(D1.[Inbound_QTY],DL.[Inbound_QTY]) [Inbound_QTY]
--      ,ISNULL(D1.[Outbound_QTY],DL.[Outbound_QTY]) [Outbound_QTY]
--      ,ISNULL(D1.[Inventory_QTY],0)-ISNULL(DL.[Inventory_QTY],0) AS [NetChange_QTY]
--      ,ISNULL(D1.[Sale_Days],DL.[Sale_Days]) [Sale_Days]
--      ,ISNULL(D1.[Create_Time],DL.[Create_Time]) [Create_Time]
--      ,ISNULL(D1.[Create_By],DL.[Create_By]) [Create_By]
--      ,ISNULL(D1.[Update_Time],DL.[Update_Time])[Update_Time]
--      ,ISNULL(D1.[Update_By],DL.[Update_By]) [Update_By]
--	  FROM #DCInv2 AS D1
--	   FULL JOIN #DCInv_L AS DL
--	   ON D1.Datekey=DL.Datekey AND D1.SKU_ID=DL.SKU_ID AND D1.Expiry_Date=DL.Expiry_Date
--END;

GO
