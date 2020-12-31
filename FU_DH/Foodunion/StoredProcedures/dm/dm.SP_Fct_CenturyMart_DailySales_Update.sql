USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC  [dm].[SP_Fct_CenturyMart_DailySales_Update] 
	@Ret_Days int = 7
AS BEGIN

	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	--DECLARE @Ret_Days int = 30
	DELETE dm.Fct_CenturyMart_DailySales WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)

	INSERT INTO  dm.Fct_CenturyMart_DailySales
	(
	   [Datekey]
      ,[Cust_No]
      ,[Cust_Name]
      ,[Barcode]
      ,[Goods_No]
      ,[Sub_No]
      ,[SKU_ID]
      ,[Goods_Name]
      ,[Goods_Code]
      ,[Scale]
      ,[Unit]
      ,[Store_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[Ending_Inv]
      ,[Ending_Amt]
      ,[Pre_Amt]
      ,[Sale_Days]
      ,[Sale_Qty]
      ,[Sale_Amt]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT 
	   ocds.[Datekey]
      ,ocds.[Cust_No]
      ,ocds.[Cust_Name]
      ,ocds.[Barcode]
      ,ocds.[Goods_No]
      ,ocds.[Sub_No]
      ,p.SKU_ID
      ,ocds.[Goods_Name]
      ,ocds.[Goods_Code]
      ,ocds.[Scale]
      ,ocds.[Unit]
      ,st.[Store_ID]
      ,st.[Account_Store_Code]
      ,ocds.[Store_Name]
      ,ocds.[Ending_Inv]
      ,ocds.[Ending_Amt]
      ,ocds.[Pre_Amt]
      ,ocds.[Sale_Days]
      ,ocds.[Sale_Qty]
      ,ocds.[Sale_Amt]
	  ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
	FROM [ODS].[ods].[File_CenturyMart_DailySales] ocds
	LEFT JOIN dm.Dim_Product p ON ocds.Barcode =  p.Bar_Code AND p.IsEnabled=1
	LEFT JOIN dm.Dim_Store st ON replace(cast(ocds.[Store_Code]+100000000 as varchar(20)),'1000','0') = st.Account_Store_Code AND st.Channel_Account='CenturyMart'
	LEFT JOIN dm.Fct_CenturyMart_DailySales dcds ON p.SKU_ID = dcds.[SKU_ID] 
		AND ocds.Datekey = dcds.Datekey 
		AND dcds.Store_ID = st.Store_ID
	WHERE dcds.Datekey IS NULL 
	--AND ocds.Sale_Amt>0
	--AND st.Store_ID is null
	--AND ocds.[SKU_ID] IS NULL

	--select top 100 * from dm.Dim_Store 
	--where Channel_Account='centurymart'
	----and Store_Name like '%芜湖%'
	----or Account_Store_Code='12028'
	--order by 1 desc

	--update dm.Dim_Store 
	--set Account_Store_Code=cast(Account_Store_Code+100000000 as varchar(20))
	--where Channel_Account='centurymart'
	--update dm.Dim_Store 
	--set Account_Store_Code=replace(Account_Store_Code,'1000','0')
	--where Channel_Account='centurymart'

	--select top 100 * from [ODS].[ods].[File_CenturyMart_DailySales]  
	--delete from [ODS].[ods].[File_CenturyMart_DailySales]  
	--where Load_DTM<='2019-12-04 12:35:16.597'

	--select * from dm.Fct_CenturyMart_DailySales

	--TRUNCATE TABLE [ODS].ods.[File_CenturyMart_DailySales]  
	--select * from [ODS].[stg].[File_CenturyMart_DailySales]  
	--select * from [ODS].ods.[File_CenturyMart_DailySales]  


END TRY
BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	RAISERROR(@errmsg,16,1);

END CATCH

END




--select * from [ODS].ods.[File_CenturyMart_DailySales]  
--where unit='提'
--select * from dm.Dim_Product where SKU_Name_CN like '%礼盒%'

--update dm.Dim_Product 
--set Product_Category_CN='常温酸奶-饮用',Bar_Code='6970432022601',Sale_Unit='Case',Sale_Unit_CN='Case',Base_Unit_Volumn_L='0.2',Sale_Unit_Volumn_L='2.4',Produce_Unit='GBX48'
--,Sale_Unit_Weight_KG=5.016/2,Qty_BaseInSale=12,Qty_SaleInTray=4,Qty_BaseInTray=48
--where SKU_Name_CN like '%礼盒%'
--and SKU_ID='1182005'
--update dm.Dim_Product 
--set Product_Category_CN='常温酸奶-饮用',Bar_Code='6970432022687',Sale_Unit='Case',Sale_Unit_CN='Case',Base_Unit_Volumn_L='0.2',Sale_Unit_Volumn_L='2.4',Produce_Unit='GBX48'
--,Sale_Unit_Weight_KG=5.016/2,Qty_BaseInSale=12,Qty_SaleInTray=4,Qty_BaseInTray=48
--where SKU_Name_CN like '%礼盒%'
--and SKU_ID='1182006'
--update dm.Dim_Product 
--set Product_Category_CN='',Bar_Code='6970432022694',Sale_Unit='Case',Sale_Unit_CN='Case',Base_Unit_Volumn_L='0.2',Sale_Unit_Volumn_L='2.4',Produce_Unit='GBX48'
--,Sale_Unit_Weight_KG=4.920/2,Qty_BaseInSale=12,Qty_SaleInTray=4,Qty_BaseInTray=48
--where SKU_Name_CN like '%礼盒%'
--and SKU_ID='1181003'

--update dm.Dim_Product 
--set Bar_Code=''
--where SKU_Name_CN like '%礼盒%'
--and SKU_ID='1182004'
GO
