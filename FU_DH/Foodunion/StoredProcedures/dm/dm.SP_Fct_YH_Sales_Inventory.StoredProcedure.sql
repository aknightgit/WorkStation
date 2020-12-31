USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_Sales_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [dm].[SP_Fct_YH_Sales_Inventory]
	-- Add the parameters for the stored procedure here
	-- [dm].[Fct_YH_Sales_Inventory] ���е�������[ods].[File_YH_Sales] �ֹ����ݺ�ods.EDI_YH_Sales EDI������������ɣ����ݸ��¸ĳ�������Ͳ��ٴ��ֹ����ȡ������  20191017
@Total INT = 0
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

IF @Total = 1 
BEGIN
DELETE [dm].[Fct_YH_Sales_Inventory] WHERE Calendar_DT>='20190707'
END
ELSE
BEGIN
------------------------------------------------�Թ�ȥ8�������������
DELETE [dm].[Fct_YH_Sales_Inventory] WHERE Calendar_DT>CONVERT(VARCHAR(8),DATEADD(DAY,-8,GETDATE()),112)
END


------------------------------------------------��ȡ���ڱ�������ʱ��
DECLARE @MAX_CAL VARCHAR(8) = (SELECT ISNULL(MAX(Calendar_DT),'19900101') FROM [dm].[Fct_YH_Sales_Inventory])
------------------------------------------------��ȡ���һ����������
DECLARE @LAST_DAY_OF_YH_SALES VARCHAR(8) = (SELECT MAX(calday) FROM ODS.ods.EDI_YH_Sales)

---------------------��������
INSERT INTO [dm].[Fct_YH_Sales_Inventory]
	  ([SKU_ID]
      ,[Store_ID]
      ,[Calendar_DT]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[DiscountSales_AMT]
      ,[Inventory_AMT]
      ,[Inventory_QTY]
      ,[Inventory_LD_AMT]
      ,[Inventory_LD_QTY]
      ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By])
SELECT prod.SKU_ID
	  ,st.Store_ID
	  ,[Calendar_DT]
	  ,SUM([Sales_AMT]		  ) AS [Sales_AMT]
	  ,SUM([Sales_QTY]		  ) AS [Sales_QTY]
	  ,SUM([DiscountSales_AMT]) AS [DiscountSales_AMT]
	  ,SUM([Inventory_AMT]	  ) AS [Inventory_AMT]
	  ,SUM([Inventory_QTY]	  ) AS [Inventory_QTY]
	  ,SUM([Inventory_LD_AMT] ) AS [Inventory_LD_AMT]
	  ,SUM([Inventory_LD_QTY] ) AS [Inventory_LD_QTY]
	  ,GETDATE() AS [Create_Time]
	  ,@ProcName AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,@ProcName AS [Update_By]
FROM (
------------------------------------------------��ODS.ods.EDI_YH_Sales��ȡ��������
	SELECT sal.bar_code AS [YH_UPC]
	      ,goods_name AS SKU_NM
	      ,shop_id AS [YH_Store_CD]
	      ,calday AS [Calendar_DT]
	      ,CAST(sales_amt AS DECIMAL(18,6)) AS [Sales_AMT]				
	      ,CAST(sales_qty AS DECIMAL(18,6)) AS [Sales_QTY]				
	      ,CAST(pro_chg_amt AS DECIMAL(18,6)) AS [DiscountSales_AMT]	
		  ,0 AS [Inventory_AMT]
		  ,0 AS [Inventory_QTY]
		  ,0 AS [Inventory_LD_AMT]
		  ,0 AS [Inventory_LD_QTY]
	FROM ODS.ods.EDI_YH_Sales sal
	WHERE calday>@MAX_CAL AND (CAST(sales_amt AS DECIMAL(18,6))<> 0 OR CAST(sales_qty AS DECIMAL(18,6)) <> 0 OR CAST(pro_chg_amt AS DECIMAL(18,6))<>0)  ---ɾ������ֵΪ0���н�ʡ�ռ�
------------------------------------------------��ODS.ods.EDI_YH_Inventory��ȡ��������
	UNION ALL
	SELECT inv.bar_code AS [YH_UPC]
		  ,goods_name AS SKU_NM
		  ,shop_id AS [YH_Store_CD]
	      ,calday AS [Calendar_DT]
	      ,0 AS [Sales_AMT]				
	      ,0 AS [Sales_QTY]				
	      ,0 AS [DiscountSales_AMT]	
		  ,CAST(inv_amt AS FLOAT) AS [Inventory_AMT]		---���ڿ�ѧ��������ֻ��תfloat
		  ,CAST(inv_qty AS FLOAT) AS [Inventory_QTY]
		  ,0 AS [Inventory_LD_AMT]
		  ,0 AS [Inventory_LD_QTY]
	FROM [ODS].ods.EDI_YH_Inventory AS inv
	WHERE inv.calday>@MAX_CAL AND (CAST(inv_amt AS FLOAT) <> 0 OR CAST(inv_qty AS FLOAT) <> 0) AND calday <= @LAST_DAY_OF_YH_SALES

------------------------------------------------��EDI��ȡ�������ǵ�������ۺ���ĩ��棬��Ҫ������ڳ���棬ȡǰһ�����ĩ�����Ϊ�ڳ����
	UNION ALL
	SELECT inv.bar_code AS [YH_UPC]
		  ,goods_name AS SKU_NM
		  ,shop_id AS [YH_Store_CD]
	      ,CONVERT(VARCHAR(8),DATEADD(DAY,1,calday),112) AS [Calendar_DT]
	      ,0 AS [Sales_AMT]				
	      ,0 AS [Sales_QTY]				
	      ,0 AS [DiscountSales_AMT]	
		  ,0 AS [Inventory_AMT]
		  ,0 AS [Inventory_QTY]
		  ,CAST(inv_amt AS FLOAT) AS [Inventory_LD_AMT]	
		  ,CAST(inv_qty AS FLOAT) AS [Inventory_LD_QTY]
	FROM [ODS].ods.EDI_YH_Inventory AS inv
	WHERE CONVERT(VARCHAR(8),DATEADD(DAY,1,calday),112)>@MAX_CAL AND (CAST(inv_amt AS FLOAT) <> 0 OR CAST(inv_qty AS FLOAT) <> 0) AND DATEADD(DAY,1,calday) <= @LAST_DAY_OF_YH_SALES --ɾ������+1���µĴ�������
) ua
LEFT JOIN DM.Dim_Product Prod ON ua.[YH_UPC] = Prod.Bar_Code AND CASE WHEN ua.SKU_NM LIKE '%С��%' THEN 'PEPPA' WHEN ua.SKU_NM LIKE '%����%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END-------------��Ʒ�������汦����С�������õ���ͬһ��barcode,����һ��barcode��Ӧ���SKU_ID�����,Ҫͨ����Ʒ��������,Ĭ����С������
LEFT JOIN dm.Dim_Store st ON ua.YH_Store_CD = st.Account_Store_Code AND st.Channel_Account = 'YH'

GROUP BY prod.SKU_ID
	    ,st.Store_ID
	    ,[Calendar_DT]



END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
