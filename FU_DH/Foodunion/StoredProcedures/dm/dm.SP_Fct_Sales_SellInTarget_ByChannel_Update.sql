USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Fct_Sales_SellInTarget_ByChannel_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	-- update  [Fct_Sales_SellInTarget]
	DELETE t
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] t
	JOIN ODS.[ods].[File_Sales_SellInTarget_ByChannel] o
	ON t.Monthkey = o.Monthkey --AND ISNULL(t.[ERP_Customer_Name],'') = ISNULL(o.[ERP_Customer_Name],'')

	INSERT INTO [dm].[Fct_Sales_SellInTarget_ByChannel]
           ( [MonthKey]
			,[Channel_ID]
			,[ERP_Customer_Name]
			,[Account_Display_Name]
			,[Channel_Short_Name]
			,[Channel_Type]
			,[Channel_Category_Name]
			,[Channel_Handler]
			,[Team]
			,[Team_Handler]
			,[Target_Amt_KRMB]
			,[Target_Vol_MT]
			,[DP_Vol_MT]                              --增加单独DP     Justin 2020-01-09
			,[Category_Target_Amt_KRMB]
			,[Category_Target_Vol_MT]
			,[Category_DP_Vol_MT]                     --增加单独DP     Justin 2020-01-09
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
    SELECT  [MonthKey]
			,ISNULL(dc.Channel_ID,0)
			,ISNULL(o.[ERP_Customer_Name],'') AS [ERP_Customer_Name]
			,[Account_Display_Name]
			,o.[Channel_Short_Name]
			,o.[Channel_Type]
			,o.[Channel_Category_Name]
			,o.[Channel_Handler]
			,o.[Team]
			,o.[Team_Handler]
			,o.[Target_Amt_KRMB]
			,o.[Target_Vol_MT]
			--,o.[Target_Vol_MT]
			,NULL
			,MAX(o.[Category_Target_Amt_KRMB])
			--,MAX(o.[Category_Target_Vol_MT])
			,NULL
			,MAX(o.[Category_Target_Vol_MT])
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
	FROM ODS.[ODS].[File_Sales_SellInTarget_ByChannel] o
	LEFT JOIN dm.Dim_Channel dc ON o.ERP_Customer_Name=dc.ERP_Customer_Name
	--WHERE [MonthKey]=201912
	GROUP BY [MonthKey]
			,ISNULL(dc.Channel_ID,0)
			,ISNULL(o.[ERP_Customer_Name],'') 
			,o.[Account_Display_Name]
			,o.[Channel_Short_Name]
			,o.[Channel_Type]
			,o.[Channel_Category_Name]
			,o.[Channel_Handler]
			,o.[Team]
			,o.[Team_Handler]
			,o.[Target_Amt_KRMB]
			,o.[Target_Vol_MT]
	;


	-------------------------------------------------------------********************Justin 2019-12-23*******************------------------------------------------------------------------

	--根据Customer 更新 [Channel_Category_Name]，[Channel_Handler]       
	UPDATE A SET A.[Channel_Category_Name]=CP.[Region_Name_EN],
	             A.[Channel_Handler]=CP.[CP_Manager]
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] A
	LEFT JOIN [dm].[Dim_ERP_CustomerList] C
	ON A.ERP_Customer_Name=C.Customer_Name
	JOIN [ODS].[ods].[File_CP_ManagerTarget] CP
	ON A.MonthKey=CP.MonthKey AND C.ERP_Code=CP.[ERP_Customer_Code]
	WHERE A.Channel_Type IN ('Distributor','Kidswant') AND A.MonthKey>='202001';   --将Channel_Type 中 CP改成Distributor  Justin 2020-05-07


	--根据Channel_Category_Name 统一 Channel_Handler    
	UPDATE A 
		SET A.[Channel_Handler]=CP.[CP_Manager]
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] A
	JOIN (SELECT DISTINCT MonthKey,[Region_Name_EN],[CP_Manager] FROM [ODS].[ods].[File_CP_ManagerTarget] WHERE MonthKey>='202001') CP
	ON A.MonthKey=CP.MonthKey AND A.[Channel_Category_Name]=CP.[Region_Name_EN]
	WHERE A.Channel_Type IN('Distributor','Kidswant') ;                              --将Channel_Type 中 CP改成Distributor  Justin 2020-05-07

	--删除需要更新的Target    
	--修改规则： 上传指标 由金额变成吨数 ，逻辑修改 把金额变成吨数 --Justin 2020-01-02
	--CP的指标改回吨数为金额  2020-05-08
	--UPDATE T SET T.[Category_Target_Amt_KRMB] = NULL,T.[Target_Amt_KRMB]= NULL
	
	UPDATE T 
	SET T.[Category_Target_Vol_MT] = NULL
		,T.[Target_Vol_MT]= NULL
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] T
	JOIN (SELECT DISTINCT MonthKey FROM [ODS].[ods].[File_CP_ManagerTarget] WHERE MonthKey>='202001') CP
	ON T.MonthKey=CP.MonthKey 
	WHERE T.Channel_Type IN('Distributor','Kidswant') ;   --将Channel_Type 中 CP改成Distributor  Justin 2020-05-07
	
	--修改存在的Customer 的Target,Customer_Handler     
	--修改规则： 上传指标 由金额变成吨数 ，逻辑修改 把金额变成吨数 --Justin 2020-01-02
	--CP的指标改回吨数为金额  2020-05-08
	UPDATE T 
	SET 
		--T.[Target_Vol_MT]=S.MANAGER_TARGET ,
		--T.[Category_Target_Vol_MT]=S.CP_MANAGER_TARGET ,
		T.Category_Target_Amt_KRMB = S.CP_MANAGER_TARGET/1000,
		T.Target_Amt_KRMB = S.MANAGER_TARGET/1000,
		T.[Customer_Handler]=S.Customer_Handler
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] T
	JOIN (SELECT MonthKey,
		  ISNULL(B.[Customer_Name],A.[Region_Name_EN]) AS [Customer_Name],
		  B.Customer_Name_EN,
		  B.Short_Name,
		  CASE WHEN Customer_Name LIKE '%孩子王%' THEN 'Kidswant' ELSE 'Distributor' END CHANNEL_TYPE,   --将Channel_Type 中 CP改成Distributor  Justin 2020-05-07
		  ISNULL(A.Manager,A.CP_Manager) AS Customer_Handler ,
		  A.[Region_Name_EN],
		  A.[CP_Manager],
		  'Dragon Team' AS [Team],
		  'Daniel' AS [Team_Handler],
		  --A.MANAGER_TARGET/1000 AS MANAGER_TARGET,
		  --A.CP_MANAGER_TARGET/1000 AS CP_MANAGER_TARGET,
		  A.MANAGER_TARGET AS MANAGER_TARGET,
		  A.CP_MANAGER_TARGET AS CP_MANAGER_TARGET,
		  NULL AS VOL,		  
		  GETDATE() AS [Create_Time],
		  A.LOAD_SOURCE AS [Create_By],		  
		  GETDATE() AS [Update_Time],
		  A.LOAD_SOURCE AS [Update_By]
		 FROM [ODS].[ods].[File_CP_ManagerTarget] A
		 LEFT JOIN [dm].[Dim_ERP_CustomerList] B
		 ON  B.ERP_Code=A.[ERP_Customer_Code] OR b.Customer_Name=A.ERP_Customer_Name
		 WHERE MonthKey>='202003') S
    ON T.MonthKey=S.MonthKey AND T.[ERP_Customer_Name]=S.[Customer_Name] AND T.[Channel_Type]=S.[Channel_Type]

	
	--插入不存在的Customer的Target，Customer_Handler    
	--修改规则： 上传指标 由金额变成吨数 ，逻辑修改 把金额变成吨数 --Justin 2020-01-02
	--CP的指标改回吨数为金额  2020-05-08
	INSERT  INTO [dm].[Fct_Sales_SellInTarget_ByChannel] 
	([MonthKey]
	  --,[Region]
      ,[ERP_Customer_Name]
      ,[Account_Display_Name]
      ,[Channel_Short_Name]
      ,[Channel_Type]
	  ,[Customer_Handler]
      ,[Channel_Category_Name]
      ,[Channel_Handler]
      ,[Team]
      ,[Team_Handler]      
	  ,[Target_Amt_KRMB]
      ,[Target_Vol_MT]
      ,[Category_Target_Amt_KRMB]
      ,[Category_Target_Vol_MT]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	SELECT S.* FROM (SELECT MonthKey,--CASE WHEN A.Region_Name_CN='中区&上海' THEN '中沪' ELSE A.Region_Name_CN END  AS Region,
		  ISNULL(B.[Customer_Name],A.[Region_Name_EN]) AS [Customer_Name],
		  B.Customer_Name_EN,
		  B.Short_Name,
		  CASE WHEN Customer_Name LIKE '%孩子王%' THEN 'Kidswant' ELSE 'Distributor' END CHANNEL_TYPE,   --将Channel_Type 中 CP改成Distributor  Justin 2020-05-07
		  ISNULL(A.Manager,A.CP_Manager) AS Customer_Handler ,
		  A.[Region_Name_EN],
		  A.[CP_Manager],
		  'Dragon Team' AS [Team],
		  'Daniel' AS [Team_Handler],
		  --0 AS [Target_Amt_KRMB],
		  --A.MANAGER_TARGET AS [Target_Vol_MT],
		  --0 AS [Category_Target_Amt_KRMB],		  
		  --A.CP_MANAGER_TARGET AS [Category_Target_Vol_MT],	
		  A.MANAGER_TARGET/1000 AS [Target_Amt_KRMB],
		  0 AS [Target_Vol_MT],
		  A.CP_MANAGER_TARGET/1000 AS [Category_Target_Amt_KRMB],		  
		  0 AS [Category_Target_Vol_MT],	  	  
		  GETDATE() AS [Create_Time],
		  A.LOAD_SOURCE AS [Create_By],		  
		  GETDATE() AS [Update_Time],
		  A.LOAD_SOURCE AS [Update_By]
	FROM [ODS].[ods].[File_CP_ManagerTarget] A
	LEFT JOIN [dm].[Dim_ERP_CustomerList] B
	ON  B.ERP_Code=A.[ERP_Customer_Code] OR b.Customer_Name=A.ERP_Customer_Name
	WHERE MonthKey>='202003') S
	LEFT JOIN [dm].[Fct_Sales_SellInTarget_ByChannel] T
	ON T.MonthKey=S.MonthKey AND T.[ERP_Customer_Name]=S.[Customer_Name] AND T.[Channel_Type]=S.[Channel_Type]
	WHERE T.ERP_Customer_Name IS NULL ;
	
	-------------------------------------------------------------***************************************------------------------------------------------------------------

	UPDATE si 
		SET si.Channel_ID=dc.Channel_ID
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] si
	JOIN [dm].[Dim_Channel] dc ON si.ERP_Customer_Name=dc.ERP_Customer_Name
	WHERE si.Channel_ID IS NULL;

	--UPDATE si 
	--	SET si.Region=CASE WHEN cp.Region_Name_CN='中区&上海' THEN '中沪' ELSE cp.Region_Name_CN END
	--FROM [dm].[Fct_Sales_SellInTarget_ByChannel] si
	--JOIN [ODS].[ods].[File_CP_ManagerTarget] cp ON si.ERP_Customer_Name=cp.ERP_Customer_Name AND si.MonthKey=SI.MonthKey AND si.[Channel_Type]=SI.[Channel_Type]
	--WHERE si.Region IS NULL AND si.[Channel_Type]='Distributor';


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
