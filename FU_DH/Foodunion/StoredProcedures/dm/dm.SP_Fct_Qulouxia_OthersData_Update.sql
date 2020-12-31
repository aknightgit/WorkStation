USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dm].[SP_Fct_Qulouxia_OthersData_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	---------------------将ZBOX的产品信息 放进临时表  共享
	IF OBJECT_ID(N'tempdb..#Temp_Product_AccountCodeMapping') IS NOT NULL
	BEGIN
	DROP TABLE #Temp_Product_AccountCodeMapping
	END
	SELECT * INTO #Temp_Product_AccountCodeMapping FROM [Foodunion].[dm].[Dim_Product_AccountCodeMapping] 
	WHERE [Account]='ZBox'
	 

	--TRUNCATE TABLE [dm].[Fct_Qulouxia_Product_Scrap];    --11富友商品报损数据
	INSERT INTO [dm].[Fct_Qulouxia_Product_Scrap]
     ( DATEKEY,[Scrap_Date]
      ,[SKU_ID]
	  ,[SKU_CODE]
      ,[SKU_Name]
      ,[QTY]
      ,[Produce_Date]
      ,[Scrap_Reason]
	  ,[Source]
      ,[Store_ID]
      ,[Store_Name]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
 SELECT CONVERT(VARCHAR(10),O.[Scrap_Date],112) 
      ,O.[Scrap_Date]
      ,P.[SKU_ID]
	  ,O.[SKU_ID] AS CODE
      ,O.[SKU_Name]
      ,SUM(O.[QTY])
      ,O.[Produce_Date]
      ,O.[Scrap_Reason]
	  ,O.[Source]
      ,O.[Store_ID]
      ,O.[Store_Name]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_Product_Scrap] O
  LEFT JOIN #Temp_Product_AccountCodeMapping P
  ON O.[SKU_ID]=P.SKU_Code
  LEFT JOIN [dm].[Fct_Qulouxia_Product_Scrap] D
  ON CONVERT(VARCHAR(10),O.[Scrap_Date],112) =D.DATEKEY AND P.[SKU_ID]=D.[SKU_ID] AND O.[SKU_ID]=D.[SKU_CODE] AND O.[Produce_Date]=D.[Produce_Date] AND O.[Scrap_Reason]=D.[Scrap_Reason]
  WHERE  D.DATEKEY IS NULL AND D.[SKU_ID] IS NULL
  GROUP BY O.[Scrap_Date]
      ,P.[SKU_ID]
	  ,O.[SKU_ID]
	  ,O.[SKU_Name]
	  ,O.[Produce_Date]
      ,O.[Scrap_Reason]
	  ,O.[Source]
      ,O.[Store_ID]
      ,O.[Store_Name];

  --TRUNCATE TABLE [dm].[Fct_Qulouxia_Store_List];    --06门店在售明细
  INSERT INTO [dm].[Fct_Qulouxia_Store_List]
  ([DateKey]
      ,[Store_ID]
	  ,[Store_Code]
      ,[Store_Name]
      ,[SKU_ID]
	  ,[SKU_CODE]
      ,[SKU_Name]
      ,[Category]
      ,[Shelf_Life_D]
      ,[Solt_Capacity]
      ,[Solt_QTY]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT CONVERT(VARCHAR(10),O.[Date],112)
      ,S.[Store_ID]
	  ,O.[Store_ID] AS CODE
      ,S.[Store_Name]
      ,P.[SKU_ID]
	  ,O.[SKU_ID] AS CODE
      ,O.[SKU_Name]
      ,O.[Category]
      ,O.[Shelf_Life_D]
      ,O.[Solt_Capacity]
      ,O.[Solt_QTY]
      ,GETDATE() [Create_Time]
      ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'[Create_By]
      ,GETDATE() [Update_Time]
     ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]' [Update_By]
  FROM [ODS].[ods].[File_Qulouxia_Store_List] O
  LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_ID]=S.Account_Store_Code
  LEFT JOIN #Temp_Product_AccountCodeMapping P
  ON O.[SKU_ID]=P.SKU_Code
  LEFT JOIN [dm].[Fct_Qulouxia_Store_List] D
  ON CONVERT(VARCHAR(10),[Date],112)=D.[DateKey] AND S.[Store_ID]=D.[Store_ID] AND O.[Store_ID]=D.[Store_Code] AND P.[SKU_ID]=D.[SKU_ID]
     AND O.[Shelf_Life_D]=D.[Shelf_Life_D] AND O.[Solt_Capacity]=D.[Solt_Capacity]
	 WHERE D.DATEKEY IS NULL AND D.Store_ID IS NULL AND D.SKU_ID IS NULL;
  --WHERE [Date]='2020-06-22' AND S.[Store_ID]='ZB3519' AND P.[SKU_ID]='2100072_0';



--TRUNCATE TABLE [dm].[Fct_Qulouxia_StoreInventory];     --10门店内富友商品批次库存
INSERT INTO [dm].[Fct_Qulouxia_StoreInventory]
([DateKey],[SKU_ID],[SKU_CODE]
      ,[Batch_No]
      ,[Sales_Price]
      ,[Cost_Price]
      ,[Tax_Rate]
      ,[Store_ID]
	  ,[Store_CODE]
      ,[Cargo_Rack]
      ,[QTY]
      ,[Info_Update_Time]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
SELECT CONVERT(VARCHAR(10),[Date],112), P.[SKU_ID],O.SKU_ID AS CODE
      ,O.[Batch_No]
      ,O.[Sales_Price]
      ,O.[Cost_Price]
      ,O.[Tax_Rate]
      ,S.[Store_ID]
	  ,O.Store_ID AS CODE
      ,O.[Cargo_Rack]
      ,O.[QTY]
      ,O.[Info_Update_Time]
       ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_StoreInventory] O
  LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_ID]=S.Account_Store_Code
  LEFT JOIN  #Temp_Product_AccountCodeMapping P
  ON O.[SKU_ID]=P.SKU_Code 
  LEFT JOIN [dm].[Fct_Qulouxia_StoreInventory] SI
  ON CONVERT(VARCHAR(10),O.[Date],112) = SI.DateKey
  AND P.[SKU_ID] = SI.SKU_ID
  AND O.[Batch_No] = SI.Batch_No
  AND S.[Store_ID] = SI.Store_ID
  AND O.Cargo_Rack = SI.Cargo_Rack
  WHERE SI.DateKey IS NULL 
  ;


--  TRUNCATE TABLE [dm].[Fct_Qulouxia_Product_DailyData];
  INSERT INTO [dm].[Fct_Qulouxia_Product_DailyData]
      ([DateKey]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[SKU_Name]
      ,[Brand]
      ,[Share_of_diary]
      ,[RSP]
      ,[On_sale_stores]
      ,[GMV]
      ,[Discount_Value]
      ,[Net_sales_revenue]
      ,[Consumer_numbers]
      ,[Sales_numbers]
      ,[GMV_per_store]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT CONVERT(VARCHAR(10),[Date],112)
      ,P.SKU_ID
      ,O.[Product_Code]      
      ,O.[Product]
      ,O.[Brand]
      ,O.[Share_of_diary]
      ,O.[RSP]
      ,O.[On_sale_stores]
      ,O.[GMV]
      ,O.[Discount_Value]
      ,O.[Net_sales_revenue]
      ,O.[Consumer_numbers]
      ,O.[Sales_numbers]
      ,O.[GMV_per_store]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_Product_DailyData] O
  LEFT JOIN  #Temp_Product_AccountCodeMapping P
  ON O.[Product_Code]=P.SKU_Code 
  LEFT JOIN [dm].[Fct_Qulouxia_Product_DailyData] Q
  ON CONVERT(VARCHAR(10),O.[Date],112) = Q.DateKey
  AND P.SKU_ID = Q.SKU_ID 
  AND O.[Product_Code] = Q.SKU_Code
  WHERE Q.DateKey IS NULL 
  ;


--  TRUNCATE TABLE [dm].[Fct_Qulouxia_Store_SKU_Mapping];
  INSERT INTO [dm].[Fct_Qulouxia_Store_SKU_Mapping]
  ([Store_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[SKU_Name]
      ,[SKU_Category]
      ,[Begin_Date]
      ,[End_Date]
      ,[Update_Source]
      ,[Update_DTM]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT S.Store_ID        
      ,O.[Store_Code]
	  ,O.[Store_Name]
      ,P.SKU_ID
      ,O.[SKU_Code]
      ,O.[SKU_Name]
	  ,O.[SKU_Category]
      ,O.[Begin_Date]
      ,O.[End_Date]
      ,O.[Update_Source]
      ,O.[Update_DTM]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_Store_SKU_Mapping] O 
   LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_Code]=S.Account_Store_Code
  LEFT JOIN  #Temp_Product_AccountCodeMapping P
  ON O.[SKU_Code]=P.SKU_Code 
  LEFT JOIN [dm].[Fct_Qulouxia_Store_SKU_Mapping] Q
  ON S.Store_ID  = Q.Store_ID 
  AND O.[Store_Code] = Q.Store_Code
  AND O.[SKU_Code] = Q.SKU_Code
  AND O.[Begin_Date] = Q.Begin_Date
  WHERE Q.Store_ID IS NULL

  ;
 
--   TRUNCATE TABLE [dm].[Fct_Qulouxia_Store_Sales];
   INSERT INTO [dm].[Fct_Qulouxia_Store_Sales]
     ([DateKey]
      ,[Store_ID]
      ,[Store_Name]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[SKU_Name]
      ,[Member_Sales]
      ,[Non_Member_Sales]
      ,[Coupon_Sales]
      ,[Total_Sales]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT CONVERT(VARCHAR(10),O.[Date],112)
      ,ISNULL(S.Store_ID,O.Store_Name)
      ,O.[Store_Name]
	  ,P.SKU_ID
      ,O.[SKU_ID]
      ,O.[SKU_Name]
      ,O.[Member_Sales]
      ,O.[Non_Member_Sales]
      ,O.[Coupon_Sales]
      ,O.[Total_Sales]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_Store_Sales] O
  LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_Name]=S.Store_Name
  LEFT JOIN  #Temp_Product_AccountCodeMapping  P
  ON O.[SKU_ID]=P.SKU_Code  
  LEFT JOIN [dm].[Fct_Qulouxia_Store_Sales] Q
  ON CONVERT(VARCHAR(10),O.[Date],112) = Q.DateKey
  AND ISNULL(S.Store_ID,O.Store_Name) = Q.Store_ID
  AND O.[Store_Name] = Q.Store_Name
  AND O.[SKU_ID] = Q.SKU_Code
  WHERE Q.DateKey IS NULL
  ;

 -- TRUNCATE TABLE [dm].[Fct_Qulouxia_PrepaidCard];
  INSERT INTO [dm].[Fct_Qulouxia_PrepaidCard]
       ([DateKey]
      ,[Card_Order_ID]
      ,[Card_ID]
      ,[Card_Name]
      ,[Booking_Type]
      ,[Customer_ID]
      ,[Customer_Phone]
      ,[Store_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[SKU_Name]
      ,[Cycle_Num]
      ,[Weekly_Pickup_Times]
      ,[Pickup_Day]
      ,[Pickup_Time_1st]
      ,[Pickup_Time_Last]
      ,[QTY_Per]
      ,[QTY_Total]
      ,[Pay_Amount]
      ,[Pay_Type]
      ,[Pay_Status]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]) 
  SELECT CONVERT(VARCHAR(10),[Create_Date],112)
      ,O.[Card_Order_ID]
      ,O.[Card_ID]
      ,O.[Card_Name]
      ,O.[Booking_Type]
      ,O.[Customer_ID]
      ,O.[Customer_Phone]
	  ,S.Store_ID
      ,O.[Store_ID]
      ,O.[Store_Name]
	  ,P.SKU_ID
      ,O.[Product_ID]
      ,O.[Product_Name]
      ,O.[Cycle_Num]
      ,O.[Weekly_Pickup_Times]
      ,O.[Pickup_Day]
      ,O.[Pickup_Time_1st]
      ,O.[Pickup_Time_Last]
      ,O.[QTY_Per]
      ,O.[QTY_Total]
      ,O.[Pay_Amount]
      ,O.[Pay_Type]
      ,O.[Pay_Status]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_PrepaidCard] O
  LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_ID]=S.Account_Store_Code
  LEFT JOIN #Temp_Product_AccountCodeMapping P
  ON O.[Product_ID]=P.SKU_Code
  LEFT JOIN [dm].[Fct_Qulouxia_PrepaidCard] Q 
  ON O.[Card_Order_ID] = Q.Card_Order_ID
  AND O.[Card_ID] = Q.Card_ID

  ----------2020/10/30   过滤 维达手帕纸1包
  where O.[Product_ID] <> '123652' 
  AND Q.Card_Order_ID IS NULL ;


--  TRUNCATE TABLE [dm].[Fct_Qulouxia_Stores];
  INSERT INTO [dm].[Fct_Qulouxia_Stores]
     ( [Store_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[Store_Type]
      ,[Store_Address]
      ,[Store_City]
      ,[Number_of_Machines]
      ,[Opening_Date]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT S.Store_ID  
      ,O.[Store_ID]
      ,O.[Store_Name]
      ,O.[Store_Type]
      ,O.[Store_Address]
      ,O.[Store_City]
      ,O.[Number_of_Machines]
      ,O.[Opening_Date]
       ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_Stores] O
  LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_ID]=S.Account_Store_Code
  LEFT JOIN [dm].[Fct_Qulouxia_Stores] Q 
  ON O.[Store_ID] = Q.Store_Code
  WHERE Q.Store_Code IS NULL 
  ;



--  TRUNCATE TABLE [dm].[Fct_Qulouxia_Cost_Distribution];
  INSERT INTO [dm].[Fct_Qulouxia_Cost_Distribution]
      ([DateKey]
      ,[Store_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[SKU_Name]
      ,[Category]
      ,[Promotion_Type]
      ,[Promotion_ID]
	  ,[Promotion_Name]
      ,[Cost_Price]
      ,[Sales_Price]
      ,[Promotion_Price]
      ,[QTY]
      ,[Discount_Amount]
      ,[Order_No]
      ,[Is_Member]
      ,[UserID]
      ,[Platform]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
 SELECT  CONVERT(VARCHAR(10),[Date],112) [Date]
      ,S.[Store_ID]
	  ,O.Store_ID
      ,O.[Store_Name]
	  ,P.SKU_ID
      ,O.[SKU_ID]
      ,O.[SKU_Name]
      ,O.[Category]
      ,O.[Promotion_Type]
      ,O.[Promotion_ID]
	  ,O.[Promotion_Name]
      ,O.[Cost_Price]
      ,O.[Sales_Price]
      ,O.[Promotion_Price]
      ,O.[QTY]
      ,O.[Discount_Amount]
      ,O.[Order_No]
      ,O.[Is_Member]
      ,O.[UserID]
      ,O.[Platform]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
  FROM [ODS].[ods].[File_Qulouxia_Cost_Distribution] O
  LEFT JOIN [dm].[Dim_Store] S
  ON O.[Store_ID]=S.Account_Store_Code
  LEFT JOIN #Temp_Product_AccountCodeMapping P
  ON O.[SKU_ID]=P.SKU_Code
  LEFT JOIN [dm].[Fct_Qulouxia_Cost_Distribution] Q 
  ON O.[SKU_ID] = Q.SKU_Code
  AND O.[Promotion_ID] = Q.Promotion_ID
  AND CONVERT(DECIMAL(18,2),O.[Promotion_Price]) = Q.Promotion_Price
  AND O.[Order_No] = Q.Order_No
  WHERE Q.SKU_Code IS NULL
  ;


-------------------------------------------------------------
	Truncate Table [Foodunion].[dm].[Fct_Qulouxia_Coupon_Verification] ;

	Insert into [Foodunion].[dm].[Fct_Qulouxia_Coupon_Verification]
	  ([DateKey]
      ,[Coupon_ID]
      ,[Coupon_Name]
      ,[Coupon_Type]
      ,[Promotion_Threshold]
      ,[Coupon_AMT]
      ,[Delivered_QTY]
      ,[Used_QTY]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	  )
     Select CONVERT(VARCHAR(10),[Date],112) [Date]
      ,[Coupon_ID]
      ,[Coupon_Name]
      ,[Coupon_Type]
      ,[Promotion_Threshold]
      ,[Coupon_AMT]
      ,[Delivered_QTY]
      ,[Used_QTY]
      ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  ,GETDATE()
	  ,'[dm].[SP_Fct_Qulouxia_OthersData_Update]'
	  from [ODS].[ods].[File_Qulouxia_Coupon_Verification]

	  ;


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END





GO
