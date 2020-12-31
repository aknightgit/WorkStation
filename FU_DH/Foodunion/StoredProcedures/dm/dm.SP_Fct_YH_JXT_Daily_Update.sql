USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_YH_JXT_Daily_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		DECLARE @Ret_Days INT = 90;

		--TRUNCATE TABLE [dm].[Fct_YH_JXT_Daily]

		DELETE FROM [dm].[Fct_YH_JXT_Daily]
		WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112);
           
		INSERT INTO [dm].[Fct_YH_JXT_Daily]
           ([Datekey]
		   ,[Store_ID]
		   ,[SKU_ID]
		   ,[InStock_QTY]
		   ,[InStock_Amount]
		   ,[Sale_QTY]
		   ,[Sale_Amount]
		   ,[Promotion_Amount]
		   ,[Create_Time]
		   ,[Create_By]
		   ,[Update_Time]
		   ,[Update_By])
		SELECT dt.Datekey AS DateKey
			  ,st.Store_ID
			  ,prod.SKU_ID
			  ,sum(CAST(InStock_QTY AS DECIMAL(20,2))) AS InStock_QTY
			  ,sum(CAST(InStock_Amount AS DECIMAL(20,2))) AS InStock_Amount
			  ,sum(CAST([Sale_QTY] AS DECIMAL(20,2))) AS [Sale_QTY]
			  ,sum(CAST([Sale_Amount] AS DECIMAL(20,2))) AS [Sale_Amount]
			  ,sum(CAST([Promotion_Amount] AS DECIMAL(20,2))) AS [Promotion_Amount]
              ,GETDATE()
			  ,@ProcName
			  ,GETDATE()
			  ,@ProcName
		FROM ods.ods.[File_YH_DailySales] ds
		LEFT JOIN dm.Dim_Store st ON ds.Store_Code = st.Account_Store_Code AND st.Channel_Account = 'YH'
		LEFT JOIN dm.Dim_Product prod ON (CASE ds.Bar_Code WHEN '2100001364151' THEN '6970432020898' ELSE ds.Bar_Code END)=prod.Bar_Code 
			AND prod.IsEnabled=1
			--AND CASE WHEN ds.SKU_Name LIKE '%小猪%' THEN 'PEPPA' WHEN ds.SKU_Name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END 
			--	= CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
		LEFT JOIN [dm].[Dim_Calendar] dt ON ds.[Date] = dt.[Date]
		WHERE CONVERT(VARCHAR(8),ds.Date,112) >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
		GROUP BY dt.Datekey 
			  ,st.Store_ID
			  ,prod.SKU_ID
		--WHERE InStock_QTY>0 OR InStock_Amount>0

		--当天jxt文件第一次进系统的时候，刷新一次[rpt].[Sales_销售区域达成日报]
		--IF EXISTS (SELECT TOP 1 1 FROM [dm].[Fct_YH_JXT_Daily] WITH(NOLOCK) WHERE Datekey=CONVERT(VARCHAR(8),GETDATE()-1,112) AND Create_Time>= DATEADD(HH,-1,GETDATE()))
		--	--AND NOT EXISTS (SELECT TOP 1 1 FROM [rpt].[Sales_销售区域达成日报] WHERE Update_Time>=CAST(GETDATE() AS DATE))
		--BEGIN
		--	--EXEC [rpt].[SP_Sales_销售区域达成日报_Update];
		--	--EXEC [rpt].[SP_Sales_销售门店进货日报_Update];

		--END

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
