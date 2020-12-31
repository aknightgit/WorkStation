USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_ERP_CustomerMapping_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [dm].[SP_Dim_ERP_CustomerMapping_Update]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);
BEGIN TRY

		--DELETE t
		--FROM  [dm].[Dim_ERP_CustomerMapping] t
		--JOIN ODS.[ODS].[File_Sales_SellInTarget] O
		--ON convert(varchar(6),t.Begin_DATE,112) = o.Monthkey;

		UPDATE ecm
			SET 
			ecm.Customer_ID = ISNULL(ecl.Customer_ID,ecm2.Customer_ID)
			,ecm.Customer_Name = isnull(sit.Customer_Name,'')
			,ecm.Account_Display_Name = isnull(sit.Customer_Account_Display,'') 
			,ecm.Channel = ISNULL(sit.Channel, ecm2.Channel)
			,ecm.Region = ISNULL(sit.Region , ecm2.Region)
			,ecm.Handler = ISNULL(sit.Handler, ecm2.Handler)
			,ecm.[Channel_Handler] = CASE 
					 WHEN sit.Monthkey<='201904' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Vincent'						 
					 WHEN sit.Monthkey<='201907' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Charlene'
					 WHEN sit.Monthkey<='201908' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Susie'

					 WHEN sit.Monthkey<='201905' AND ISNULL(sit.Channel,ecm2.Channel) = 'Offline' THEN 'Patrick'

					 WHEN sit.Monthkey<='201907' AND ISNULL(sit.Channel,ecm2.Channel) = 'O2O' THEN 'Lenore'

					 WHEN sit.Monthkey<='201906' AND ISNULL(sit.Channel,ecm2.Channel) = 'YH' THEN 'Frank'
					 WHEN sit.Monthkey<='201907' AND ISNULL(sit.Channel,ecm2.Channel) = 'YH' THEN 'Daniel'
					 WHEN sit.Monthkey<='201909' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Susie'
					 --WHEN ISNULL(sit.Channel,ecm2.Channel) = 'YH' THEN 'Alvin'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'Offline' THEN 'Daniel'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Ben'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'CK' THEN 'Lenore'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'MKT' THEN 'Susie'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'Dragon team' THEN 'Daniel'
					 END 
			--,CAST(LEFT(sit.Monthkey,4)+'-'+RIGHT(sit.Monthkey,2)+'-01' AS DATETIME) AS [Begin_Date]
			,ecm.[End_Date] = DATEADD(Month,1,CAST(sit.Monthkey*100+1 AS VARCHAR))-1 
			,ecm.[Is_Current] = CASE WHEN sit.Monthkey = (SELECT MAX(Monthkey) FROM ODS.[ODS].[File_Sales_SellInTarget]) THEN 1 ELSE 0 END  
			,ecm.Update_Time = getdate()
			--,ecm.Update_By = @ProcName
		FROM ODS.[ODS].[File_Sales_SellInTarget] sit
		LEFT JOIN [dm].[Dim_ERP_CustomerList] ecl ON ecl.Customer_Name = sit.Customer_Name AND ecl.IsActive = 1
		JOIN [dm].[Dim_ERP_CustomerMapping] ecm ON isnull(sit.Customer_Name,'') = ecm.Customer_Name AND CAST(LEFT(sit.Monthkey,4)+'-'+RIGHT(sit.Monthkey,2)+'-01' AS DATETIME) = ecm.Begin_Date
		LEFT JOIN (SELECT [Customer_Name],Customer_ID,[Account_Display_Name],[Channel],[Region],[Handler],[Channel_Handler],
			ROW_NUMBER() OVER(PARTITION BY [Customer_Name] ORDER BY [Begin_Date] DESC,[End_Date] DESC) rn 
			FROM [dm].[Dim_ERP_CustomerMapping] 
			WHERE [Account_Display_Name] <> 'New Customer' 
				AND [Customer_Name]<>'' 
				AND [Customer_Name] IS NOT NULL) ecm2 on ecm2.rn=1 AND ecm2.Customer_Name = sit.Customer_Name
		WHERE  isnull(sit.Customer_Name,'') <> '还未知全称' AND  isnull(sit.Customer_Name,'') <>''	--不加这个有可能会把没有ERP Account的display account都更新成一样的

		INSERT INTO [dm].[Dim_ERP_CustomerMapping] 
			([Customer_ID]
			  ,[Customer_Name]
			  ,[Account_Display_Name]
			  ,[Channel]
			  ,[Region]
			  ,[Handler]
			  ,[Channel_Handler]
			  ,[Begin_Date]
			  ,[End_Date]
			  ,[Is_Current]
			  ,[Create_Time]
			  ,[Create_By]
			  ,[Update_Time]
			  ,[Update_By]
			  )
		SELECT ISNULL(ecl.Customer_ID,ecm2.Customer_ID) AS Customer_ID
			,isnull(sit.Customer_Name,'')
			,isnull(ISNULL(sit.Customer_Account_Display,ecm2.Account_Display_Name),'') AS Account_Display_Name
			,ISNULL(sit.Channel, ecm2.Channel) AS Channel
			,ISNULL(sit.Region , ecm2.Region)  AS Region 
			,ISNULL(sit.Handler, ecm2.Handler) AS Handler
			,CASE 
					WHEN sit.Monthkey<='201904' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Vincent'						 
					 WHEN sit.Monthkey<='201907' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Charlene'
					 WHEN sit.Monthkey<='201908' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Susie'

					 WHEN sit.Monthkey<='201905' AND ISNULL(sit.Channel,ecm2.Channel) = 'Offline' THEN 'Patrick'

					 WHEN sit.Monthkey<='201907' AND ISNULL(sit.Channel,ecm2.Channel) = 'O2O' THEN 'Lenore'

					 WHEN sit.Monthkey<='201906' AND ISNULL(sit.Channel,ecm2.Channel) = 'YH' THEN 'Frank'
					 WHEN sit.Monthkey<='201907' AND ISNULL(sit.Channel,ecm2.Channel) = 'YH' THEN 'Daniel'
					 WHEN sit.Monthkey<='201909' AND ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Susie'

					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'Offline' THEN 'Daniel'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'Online' THEN 'Ben'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'CK' THEN 'Lenore'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'MKT' THEN 'Susie'
					 WHEN ISNULL(sit.Channel,ecm2.Channel) = 'Dragon team' THEN 'Daniel'
					 END  AS [Channel_Handler]
			,CAST(LEFT(sit.Monthkey,4)+'-'+RIGHT(sit.Monthkey,2)+'-01' AS DATETIME) AS [Begin_Date]
			,DATEADD(Month,1,CAST(sit.Monthkey*100+1 AS VARCHAR))-1 AS [End_Date]
			,CASE WHEN sit.Monthkey = (SELECT MAX(Monthkey) FROM ODS.[ODS].[File_Sales_SellInTarget]) THEN 1 ELSE 0 END AS [Is_Current]
			,getdate()
			,@ProcName
			,getdate()
			,@ProcName
		FROM ODS.[ODS].[File_Sales_SellInTarget] sit
		LEFT JOIN [dm].[Dim_ERP_CustomerList] ecl ON ecl.Customer_Name = sit.Customer_Name AND ecl.IsActive = 1
		LEFT JOIN [dm].[Dim_ERP_CustomerMapping] ecm ON isnull(sit.Customer_Name,'') = ecm.Customer_Name AND (LEFT(sit.Monthkey,4)+'-'+RIGHT(sit.Monthkey,2)+'-01') = ecm.Begin_Date AND sit.Customer_Account_Display = ecm.Account_Display_Name
		LEFT JOIN (SELECT [Customer_Name],Customer_ID,[Account_Display_Name],[Channel],[Region],[Handler],[Channel_Handler],ROW_NUMBER() OVER(PARTITION BY [Customer_Name] ORDER BY [Begin_Date] DESC,[End_Date] DESC) rn FROM [Foodunion].[dm].[Dim_ERP_CustomerMapping] WHERE [Account_Display_Name] <> 'New Customer' AND [Customer_Name]<>'' AND [Customer_Name] IS NOT NULL) ecm2 on ecm2.rn=1 AND ecm2.Customer_Name = sit.Customer_Name
		WHERE ecm.Customer_Name IS NULL AND sit.Customer_Account_Display <> 'New Customer' AND sit.Handler IS NOT NULL
		;
		---在每个月插入所有的历史维度
		INSERT INTO [dm].[Dim_ERP_CustomerMapping] 
			([Customer_ID]
			  ,[Customer_Name]
			  ,[Account_Display_Name]
			  ,[Channel]
			  ,[Region]
			  ,[Handler]
			  ,[Channel_Handler]
			  ,[Begin_Date]
			  ,[End_Date]
			  ,[Is_Current]
			  ,[Create_Time]
			  ,[Create_By]
			  ,[Update_Time]
			  ,[Update_By]
			  )
		SELECT ecm2.Customer_ID AS Customer_ID
			,ecmcu.Customer_Name
			,isnull(ecm2.Account_Display_Name,'') AS Account_Display_Name
			,ecm2.Channel AS Channel
			,ecm2.Region  AS Region 
			,ecm2.Handler AS Handler
			,CASE WHEN ecmdt.Begin_Date<='2019-04-01' AND ecm2.Channel = 'YH' THEN 'Frank'
				  WHEN ecmdt.Begin_Date<='2019-04-01' AND ecm2.Channel = 'Offline' THEN 'Patrick'
				  WHEN ecmdt.Begin_Date<='2019-04-01' AND ecm2.Channel = 'Online' THEN 'Vincent'
				  WHEN ecmdt.Begin_Date<='2019-05-01' AND ecm2.Channel = 'YH' THEN 'Frank'
				  WHEN ecmdt.Begin_Date<='2019-05-01' AND ecm2.Channel = 'Offline' THEN 'Patrick'
				  WHEN ecmdt.Begin_Date<='2019-05-01' AND ecm2.Channel = 'Online' THEN 'Charlene'
				  WHEN ecmdt.Begin_Date<='2019-05-01' AND ecm2.Channel = 'O2O' THEN 'Lenore'
				  WHEN ecmdt.Begin_Date<='2019-06-01' AND ecm2.Channel = 'YH' THEN 'Frank'
				  WHEN ecmdt.Begin_Date<='2019-07-01' AND ecm2.Channel = 'YH' THEN 'Daniel'
				  WHEN ecmdt.Begin_Date<='2019-07-01' AND ecm2.Channel = 'Online' THEN 'Charlene'
				  WHEN ecmdt.Begin_Date<='2019-09-01' AND ecm2.Channel = 'Online' THEN 'Susie'
				  WHEN ecm2.Channel = 'Offline' THEN 'Daniel'
				  WHEN ecm2.Channel = 'Online' THEN 'Ben'
				  WHEN ecm2.Channel = 'CK' THEN 'Lenore'
				  WHEN ecm2.Channel = 'MKT' THEN 'Susie'
				  WHEN ecm2.Channel = 'Dragon team' THEN 'Daniel'
				  END AS [Channel_Handler]
			,ecmdt.Begin_Date AS [Begin_Date]
			,ecmdt.End_Date AS [End_Date]
			,CASE WHEN LEFT(ecmdt.Begin_Date,7) = (SELECT MAX(LEFT(Begin_Date,7)) FROM [dm].[Dim_ERP_CustomerMapping]) THEN 1 ELSE 0 END AS [Is_Current]
			,getdate()
			,@ProcName
			,getdate()
			,@ProcName
		FROM (SELECT DISTINCT ISNULL(Begin_Date,'') AS Begin_Date,ISNULL(End_Date,'') AS End_Date FROM [dm].[Dim_ERP_CustomerMapping] WHERE DAY(Begin_Date) = 1) ecmdt
		CROSS JOIN (SELECT DISTINCT ISNULL(Customer_Name,'') AS Customer_Name FROM [dm].[Dim_ERP_CustomerMapping] WHERE DAY(Begin_Date) = 1) ecmcu
		LEFT JOIN (SELECT DISTINCT ISNULL(Begin_Date,'') AS Begin_Date,ISNULL(End_Date,'') AS End_Date,ISNULL(Customer_Name,'') AS Customer_Name FROM [dm].[Dim_ERP_CustomerMapping] WHERE DAY(Begin_Date) = 1) ecm1 ON isnull(ecmcu.Customer_Name,'') = ecm1.Customer_Name AND ecmdt.Begin_Date = ecm1.Begin_Date AND ecmdt.End_Date = ecm1.End_Date 
		LEFT JOIN (SELECT [Customer_Name],Customer_ID,[Account_Display_Name],[Channel],[Region],[Handler],[Channel_Handler],ROW_NUMBER() OVER(PARTITION BY [Customer_Name] ORDER BY [Begin_Date] DESC,[End_Date] DESC) rn FROM [Foodunion].[dm].[Dim_ERP_CustomerMapping] WHERE [Account_Display_Name] <> 'New Customer' AND [Customer_Name]<>'' AND [Customer_Name] IS NOT NULL AND [Customer_Name]<>'还未知全称') ecm2 on ecm2.rn=1 AND ecm2.Customer_Name = ecmcu.Customer_Name
		WHERE ecm1.Customer_Name is null AND ecmcu.Customer_Name<>''AND ecmcu.Customer_Name<>'还未知全称'


		--select * from [dm].[Dim_ERP_CustomerMapping] 
		UPDATE c
		SET c.Is_Current=0
		FROM  [dm].[Dim_ERP_CustomerMapping]  c
		JOIN (SELECT Customer_Name,MAX(Begin_Date) as Begin_Date FROM [dm].[Dim_ERP_CustomerMapping] GROUP BY Customer_Name)m ON c.Customer_Name=m.Customer_Name AND c.Begin_Date<>m.Begin_Date;		


		--insert missing Customer from [dm].[Fct_ERP_Sale_Order]
		TRUNCATE TABLE [dm].[Dim_ERP_CustomerMapping_Missing];

		INSERT INTO [dm].[Dim_ERP_CustomerMapping_Missing]
			([Monthkey],
			[Customer_Name],
			[Create_Time],
			[Create_By],
			[Update_Time],
			[Update_By] )
		SELECT om.Monthkey,
			om.Customer_Name,
			getdate(),
			@ProcName,
			getdate(),
			@ProcName		
		FROM (
			select distinct Datekey/100 AS Monthkey, isnull(Customer_Name,'') AS Customer_Name
			from [dm].[Fct_ERP_Sale_Order]
			where Sale_Dept IN ('Marketing 市场部','Sales Operation 销售管理','O2O有赞','Logistics 物流')
			and left(Datekey,6) = convert(varchar(6),getdate(),112)
		) om
		LEFT JOIN dm.Dim_Channel_hist ch ON om.Monthkey = ch.Monthkey AND om.Customer_Name=ch.ERP_Customer_Name
		WHERE ISNULL(ch.Channel_Category,'')=''
		--LEFT JOIN [dm].[Dim_ERP_CustomerMapping] cm ON om.Date BETWEEN cm.Begin_Date AND cm.End_Date
		--AND om.Customer_Name = cm.Customer_Name
		--WHERE cm.Customer_Name IS NULL
		;

		--Upon missing record, you can update ODS table later
		--Sample:
		/*
		UPDATE ODS.[stg].[File_Sales_SellInTarget]
		SET Customer_Name='北京悠然天成国际贸易有限公司'
		,Customer_Account_Display='北京悠然天成Youran'
		,Load_Source='AK',Load_DTM=GETDATE()
		where Monthkey=201905 AND REGION='NORTH'
		*/

		--UPDATE Channel Handler
		UPDATE [dm].[Dim_ERP_CustomerMapping] 
		SET Channel_Handler = CASE WHEN Channel = 'Offline' THEN 'Daniel'
					 WHEN Channel = 'Online' THEN 'Ben'
					 WHEN Channel = 'CK' THEN 'Lenore'
					 WHEN Channel = 'MKT' THEN 'Susie' 
					 WHEN Channel = 'Dragon team' THEN 'Daniel'
					 ELSE Channel_Handler END
					,Update_Time=getdate()
		WHERE Begin_Date = cast(dateadd(dd,-day(getdate())+1,getdate()) as Date);
	

	    ---------------------------------channel name update
		-- 201909 OFFLINE team改名叫Dragon team

		UPDATE [dm].[Dim_ERP_CustomerMapping] 
		SET Channel = CASE WHEN Channel = 'Offline'AND Begin_Date>='2019-09-01' THEN 'Dragon team' 
					  ELSE Channel END
					,Update_Time=getdate();





	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END

--select * from  [dm].[Dim_ERP_CustomerMapping]
--select *from ODS.[ODS].[File_Sales_SellInTarget]
--select top 10 *from [dm].[Fct_ERP_Sale_Order]

--SELECT * FROM (
--	select distinct cast(left(Datekey,4)+'-'+right(left(Datekey,6),2)+'-01' as Datetime) as Date, isnull(Customer_Name,'') AS Customer_Name
--	from [dm].[Fct_ERP_Sale_Order]
--	where Sale_Dept IN ('Marketing 市场部','Sales Operation 销售管理')
--	and left(Datekey,6) = convert(varchar(6),getdate(),112)
--) om
--LEFT JOIN [dm].[Dim_ERP_CustomerMapping] cm ON om.Date BETWEEN cm.Begin_Date AND cm.End_Date
--AND om.Customer_Name = cm.Customer_Name
--WHERE cm.Customer_Name IS NULL
--;

--SELECT * FROM [dm].[Dim_ERP_CustomerMapping]
--WHERE Update_By='SP_Dim_ERP_CustomerMapping_Update'
--ORDER BY Customer_Name,Begin_Date

--DELETE FROM [dm].[Dim_ERP_CustomerMapping]
--WHERE Update_By='SP_Dim_ERP_CustomerMapping_Update'

--SELECT * FROM ODS.[ODS].[File_Sales_SellInTarget]
--UPDATE ODS.[ODS].[File_Sales_SellInTarget]
--SET Customer_Name='微商城Shapetime' ,Customer_Account_Display='微商城Wechat Shapetime'
--WHERE Customer_Name='微商城 Shapetime'
--UPDATE ODS.[ODS].[File_Sales_SellInTarget]
--SET Customer_Name='微商城Lakto' ,Customer_Account_Display='微商城Wechat Lakto'
--WHERE Customer_Name='微商城 Lakto'
GO
