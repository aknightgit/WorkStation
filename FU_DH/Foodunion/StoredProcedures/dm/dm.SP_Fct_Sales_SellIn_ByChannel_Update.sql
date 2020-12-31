USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE  [dm].[SP_Fct_Sales_SellIn_ByChannel_Update]
	@Ret_Days INT = 90
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--增量抽取天数
	--DECLARE @Ret_Days INT = 180;

	--Reload latest 7 days
	DELETE FROM [dm].[Fct_Sales_SellIn_ByChannel]
	WHERE --Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) AND 
	Datekey >= 20200101; --2020年之前的数据不动
	 

	INSERT INTO   [dm].[Fct_Sales_SellIn_ByChannel] 
           ([DateKey]
           ,[Channel_ID]
		   ,[Sale_Dept]
           ,[SKU_ID]
           ,[QTY]
		   ,[Stock_QTY]
           ,[Amount]
           ,[Discount_Amount]
           ,[Full_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
		   ,[Order_Amount]
           ,[Full_Order_Amount]
           ,[Status]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	SELECT 
		o.Datekey
		,ch.Channel_ID
		,o.[Sale_Dept]
		,o.SKU_ID
	    ,SUM(O.Sale_Unit_QTY) AS Sale_Unit_QTY
		,SUM(o.Stock_QTY) AS Stock_QTY	
		,CASE WHEN CH.Channel_Category='EC-EKA' THEN SUM(o.Full_Amount) ELSE SUM(o.Amount) END AS [Amount]  --增加判断'EC-EKA'+税   Justin 2020-01-13
		,SUM([Discount_Amount]) AS [Discount_Amount]
		,SUM(O.Full_Amount) AS [Full_Amount]
		,MAX(Price) AS [Unit_Price]
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,SUM(O.[Amount]) AS [Order_Amount]
		,SUM(O.Full_Amount) AS [Full_Order_Amount]
		,o.Document_Status
		,GETDATE() [Create_time]   
		,@ProcName
		,GETDATE() [Update_time]   
		,@ProcName
	FROM (SELECT eso.[Datekey],
		''[Sale_Order_ID],
		Document_Status ,
		eso.[Customer_Name],
		ISNULL(eso.[Sale_Dept],eso.Delivery_Dept) AS [Sale_Dept],
		oe.[SKU_ID],
		oe.[Sale_Unit],
		--oe.[Sale_Unit_QTY],
		[Sale_Unit_QTY],
		oe.[BASE_UNIT],
		--oe.[Base_Unit_QTY],
		[Base_Unit_QTY],
		[Unit] AS [Stock_Unit],
		--oe.[Stock_QTY],
		[Actual_QTY] AS [Stock_QTY],
		pl.[price_list_no],
		[Price],
		[Full_Amount],
		[Discount_Amount],
	    [Amount]
		FROM [dm].[Fct_ERP_Stock_OutStock] eso WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Stock_OutStockEntry] oe WITH(NOLOCK) ON eso.[OutStock_ID] = oe.[OutStock_ID]
		LEFT JOIN [dm].[Dim_ERP_CustomerList] cl ON eso.Customer_Name = cl.Customer_Name  AND cl.IsActive = 1
		LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON cl.Price_List_No = pl.Price_List_No  --Customer Price
			AND oe.SKU_ID = pl.SKU_ID 
			AND eso.Date BETWEEN pl.Effective_Date AND pl.Expiry_Date
		WHERE eso.Sale_Org='富友联合食品（中国）有限公司'		
		)o  
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON o.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Channel_hist ch WITH(NOLOCK) ON o.[Customer_Name] = ch.ERP_Customer_Name AND LEFT(o.Datekey,6)=ch.Monthkey
	WHERE o.Datekey >='20200101'  --CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	GROUP BY o.Datekey,ch.Channel_Category
		,ch.Channel_ID
		,o.[Sale_Dept]
		,o.SKU_ID
		,o.Document_Status;

	--10月起，Lakto数据用OMS订单数据
	--18: Lakto
	--115: LBZ旗舰店
	--71: Pinduoduo拼多多（富友联合旗舰店） 97:拼多多（乐味可富友联合专卖店）
	--108 109
	--45: Youzan
	--58: 社区店
	--65: 上海徐汇爱睿格林托育有限公司
	--48: 去楼下
	--DELETE FROM  [dm].[Fct_Sales_SellIn_ByChannel]
	--WHERE Channel_ID in (18,71,97)
	--AND DateKey >= 20191001;
	--DELETE FROM  [dm].[Fct_Sales_SellIn_ByChannel]
	--WHERE Channel_ID in (45,58,65)
	--AND DateKey >= 20191001;
	--DELETE FROM  [dm].[Fct_Sales_SellIn_ByChannel]    
	--WHERE Channel_ID =48
	--AND DateKey >= 20191201;
  SELECT   
		o.Order_DateKey AS [DateKey]
		,o.Channel_ID
		,'Sales Operation 销售管理' AS [Sale_Dept]
		,oi.SKU_ID
	    ,SUM(oi.Quantity) AS [QTY]
		,NULL AS [Stock_QTY]		
		--,SUM(oi.Quantity * pl.SKU_Price) AS [Amount]  
		,SUM(
			ISNULL((oi.Quantity * pl.SKU_Price), oi.Payment_Amount_Split-isnull(oi.Refund_Amount_Split,0))
			) AS [Amount]  
		,NULL AS [Discount_Amount]
		,NULL [Full_Amount]
		,NULL AS [Unit_Price]
		,SUM(oi.Quantity*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(oi.Quantity*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,'已审核' AS [Status]
		,GETDATE() AS [Create_time]   
		,'dm.Fct_Order Lakto' [Create_By]
		,GETDATE() AS [Update_time]   
		,'dm.Fct_Order Lakto' [Update_By]  into #A
	From dm.Fct_Order o 
	JOIN dm.Fct_Order_Item oi ON o.Order_Key=oi.Order_Key
	JOIN dm.Dim_Channel c ON o.Channel_ID=c.Channel_ID
	LEFT JOIN dm.DIm_Product p ON oi.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Product_PriceList pl ON pl.Price_List_Name='统一供价' AND oi.SKU_ID = pl.SKU_ID
	WHERE c.Channel_Category in ('EC-PDD','EC-TMall','DTC-MeiTun')
		--o.Channel_ID in (18 ,71, 97)  --pdd/tmall
		AND o.Is_Cancelled <> 1
		AND o.Order_DateKey >= 20190901
	GROUP BY o.Order_DateKey,o.Channel_ID,oi.SKU_ID ;

	--Youzan 调整为调拨单   
  SELECT   
		sti.Datekey AS Datekey
		,45 AS Channel_ID
		,'O2O有赞' AS [Sale_Dept]
		,stie.SKU_ID
	    ,SUM(stie.Sale_QTY) AS [QTY]
		,NULL AS [Stock_QTY]		
		,SUM(stie.Sale_QTY * pl.SKU_Price) AS [Amount]  
		--,SUM(stie.Amount) AS [Amount]  
		,NULL AS [Discount_Amount]
		,NULL [Full_Amount]
		,NULL AS [Unit_Price]
		,SUM(stie.Sale_QTY*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(stie.Sale_QTY*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,'已审核' AS Status
		,GETDATE() AS [Create_time]   
		,'O2O调拨单' [Create_By]
		,GETDATE() AS [Update_time]   
		,'O2O调拨单' [Update_By] into #B
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock in ('社区店在途库',  '赢养顾问网点库存',	  'O2O在途')
	AND sti.Datekey>=20191001
	GROUP BY sti.Datekey 
		,stie.SKU_ID;
	
	--去楼下，走ERP调拨单                 
	--ZBOX 12月开始销售订单，调整为调拨单   Justin 2020-01-13
	SELECT   
		sti.Datekey AS Datekey
		,48 AS Channel_ID
		,'ZBox去楼下' AS [Sale_Dept]
		,stie.SKU_ID
	    ,SUM(stie.Sale_QTY) AS [QTY]
		,NULL AS Stock_QTY		
		,SUM(stie.Sale_QTY * pl.SKU_Price) AS [Amount]  
		--,SUM(stie.Amount) AS [Amount]  
		,NULL AS [Discount_Amount]
		,NULL [Full_Amount]
		,NULL AS [Unit_Price]
		,SUM(stie.Sale_QTY*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(stie.Sale_QTY*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,'已审核' AS Status
		,GETDATE() AS [Create_time]   
		,'ZBox调拨单' [Create_By]
		,GETDATE() AS [Update_time]   
		,'ZBox调拨单' [Update_By] into #C
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) 
		ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock  LIKE '%楼下%'
	AND sti.Datekey>=20191201
	GROUP BY sti.Datekey 
		,stie.SKU_ID 
    
	--将Sale Order 里面数据设置为0，后面Update
	UPDATE a
	SET [QTY]=0,[Amount]=0,[Weight_KG]=0,[Volume_L]=0
	FROM [dm].[Fct_Sales_SellIn_ByChannel] a
	JOIN dm.Dim_Channel c ON a.Channel_ID=c.Channel_ID		
	WHERE Channel_Category in ('EC-PDD','EC-TMall','DTC-MeiTun')
	AND DateKey >= 20191001;

	--用调拨单数据更新Sale Order 
	UPDATE S SET S.QTY=A.QTY	        
           ,S.[Amount]=A.Amount           
           ,S.[Weight_KG]=A.Weight_KG
           ,S.[Volume_L]=A.Volume_L           
	FROM [dm].[Fct_Sales_SellIn_ByChannel] S
	JOIN  #A as A
	ON S.DateKey=A.DateKey 
		AND S.Channel_ID=A.Channel_ID 
		AND S.SKU_ID=A.SKU_ID 
		AND S.status=A.status 
		AND S.Sale_Dept=A.Sale_Dept;
	
	--插入Sales Order 没有的数据
	INSERT INTO [dm].[Fct_Sales_SellIn_ByChannel]
           ([DateKey]
           ,[Channel_ID]
		   ,[Sale_Dept]
           ,[SKU_ID]
           ,[QTY]
		   ,[Stock_QTY]
           ,[Amount]
           ,[Discount_Amount]
           ,[Full_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
           ,[Status]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	SELECT  A.[DateKey]
           ,A.[Channel_ID]
		   ,A.[Sale_Dept]
           ,A.[SKU_ID]
           ,A.[QTY]
		   ,A.[Stock_QTY]
           ,A.[Amount]
           ,A.[Discount_Amount]
           ,A.[Full_Amount]
           ,A.[Unit_Price]
           ,A.[Weight_KG]
           ,A.[Volume_L]
           ,A.[Status]
           ,A.[Create_time]
           ,A.[Create_By]
           ,A.[Update_time]
           ,A.[Update_By]
	FROM #A AS A LEFT JOIN [dm].[Fct_Sales_SellIn_ByChannel] S
	ON S.DateKey=A.DateKey AND S.Channel_ID=A.Channel_ID AND S.SKU_ID=A.SKU_ID  AND S.Sale_Dept=A.Sale_Dept AND S.status=A.status
	WHERE S.DateKey IS NULL AND S.Channel_ID IS NULL AND S.SKU_ID IS NULL AND S.status IS NULL AND S.Sale_Dept IS NULL;
	
	--重置O2O sellin
	UPDATE a
	SET [QTY]=0,[Amount]=0,[Weight_KG]=0,[Volume_L]=0
	FROM [dm].[Fct_Sales_SellIn_ByChannel] a
	JOIN dm.Dim_Channel c ON a.Channel_ID=c.Channel_ID		
	WHERE a.Channel_ID in (45,58,65) AND DateKey >= 20191001;

	UPDATE S SET S.QTY=B.QTY	       
           ,S.[Amount]=B.Amount          
           ,S.[Weight_KG]=B.Weight_KG
           ,S.[Volume_L]=B.Volume_L           
	FROM [dm].[Fct_Sales_SellIn_ByChannel] S
    JOIN  #B AS B
	ON S.DateKey=B.DateKey AND S.Channel_ID=B.Channel_ID AND S.SKU_ID=B.SKU_ID AND S.status=B.status AND S.Sale_Dept=B.Sale_Dept;

	INSERT INTO [dm].[Fct_Sales_SellIn_ByChannel]
           ([DateKey]
           ,[Channel_ID]
		   ,[Sale_Dept]
           ,[SKU_ID]
           ,[QTY]
		   ,[Stock_QTY]
           ,[Amount]
           ,[Discount_Amount]
           ,[Full_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
           ,[Status]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	SELECT  B.[DateKey]
           ,B.[Channel_ID]
		   ,B.[Sale_Dept]
           ,B.[SKU_ID]
           ,B.[QTY]
		   ,B.[Stock_QTY]
           ,B.[Amount]
           ,B.[Discount_Amount]
           ,B.[Full_Amount]
           ,B.[Unit_Price]
           ,B.[Weight_KG]
           ,B.[Volume_L]
           ,B.[Status]
           ,B.[Create_time]
           ,B.[Create_By]
           ,B.[Update_time]
           ,B.[Update_By]
	FROM #B AS B LEFT JOIN [dm].[Fct_Sales_SellIn_ByChannel] S
	ON S.DateKey=B.DateKey AND S.Channel_ID=B.Channel_ID AND S.SKU_ID=B.SKU_ID AND S.status=B.status AND S.Sale_Dept=B.Sale_Dept
	WHERE S.DateKey IS NULL AND S.Channel_ID IS NULL AND S.SKU_ID IS NULL AND S.status IS NULL AND S.Sale_Dept IS NULL;
	
	--重置O2O sellin
	UPDATE a
	SET [QTY]=0,[Amount]=0,[Weight_KG]=0,[Volume_L]=0
	FROM [dm].[Fct_Sales_SellIn_ByChannel] a
	JOIN dm.Dim_Channel c ON a.Channel_ID=c.Channel_ID		
	WHERE Channel_Category in ('Zbox') 
	AND DateKey >= 20191201;
	--UPDATE [dm].[Fct_Sales_SellIn_ByChannel] SET QTY=0,[Amount]=0,[Weight_KG]=0,[Volume_L]=0
	--WHERE Channel_ID =48 AND DateKey >= 20191201;

	UPDATE S SET S.QTY=C.QTY	     
           ,S.[Amount]=C.Amount         
           ,S.[Weight_KG]=C.Weight_KG
           ,S.[Volume_L]=C.Volume_L         
	FROM [dm].[Fct_Sales_SellIn_ByChannel] S
	JOIN  #C AS C
	ON S.DateKey=C.DateKey AND S.Channel_ID=C.Channel_ID AND S.SKU_ID=C.SKU_ID AND S.status=C.status AND S.Sale_Dept=C.Sale_Dept;

	INSERT INTO [dm].[Fct_Sales_SellIn_ByChannel]
           ([DateKey]
           ,[Channel_ID]
		   ,[Sale_Dept]
           ,[SKU_ID]
           ,[QTY]
		   ,[Stock_QTY]
           ,[Amount]
           ,[Discount_Amount]
           ,[Full_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
           ,[Status]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	SELECT  C.[DateKey]
           ,C.[Channel_ID]
		   ,C.[Sale_Dept]
           ,C.[SKU_ID]
           ,C.[QTY]
		   ,C.[Stock_QTY]
           ,C.[Amount]
           ,C.[Discount_Amount]
           ,C.[Full_Amount]
           ,C.[Unit_Price]
           ,C.[Weight_KG]
           ,C.[Volume_L]
           ,C.[Status]
           ,C.[Create_time]
           ,C.[Create_By]
           ,C.[Update_time]
           ,C.[Update_By]
	FROM #C AS C LEFT JOIN [dm].[Fct_Sales_SellIn_ByChannel] S
	ON S.DateKey=C.DateKey AND S.Channel_ID=C.Channel_ID AND S.SKU_ID=C.SKU_ID AND S.status=C.status AND S.Sale_Dept=C.Sale_Dept
	WHERE S.DateKey IS NULL AND S.Channel_ID IS NULL AND S.SKU_ID IS NULL AND S.status IS NULL AND S.Sale_Dept IS NULL;

	--修正部分stock qty和sale qty不同步的问题
	UPDATE a
	SET a.Stock_QTY=a.QTY * ISNULL(cr.Convert_Rate,1)
	--SELECT a.QTY,a.Stock_QTY,a.QTY * cr.Convert_Rate,cr.Convert_Rate
	FROM [dm].[Fct_Sales_SellIn_ByChannel] a
	JOIN dm.Dim_Product p ON a.SKU_ID=p.SKU_ID
	JOIN dm.Dim_ERP_Unit_ConvertRate cr on p.Sale_Unit=cr.From_Unit and p.Produce_Unit=cr.To_Unit
	WHERE ISNULL(a.Stock_QTY,0)<>a.QTY * ISNULL(cr.Convert_Rate,1)
	--WHERE DateKey=20200229 --and SKU_ID='1120003'
	--and Channel_ID=71


	DROP TABLE #A;
	DROP TABLE #B;
	DROP TABLE #C;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END

GO
