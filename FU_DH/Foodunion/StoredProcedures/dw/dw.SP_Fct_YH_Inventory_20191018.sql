USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE  [dw].[SP_Fct_YH_Inventory_20191018]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 
   TRUNCATE TABLE dw.[Fct_YH_Inventory]

   INSERT INTO dw.[Fct_YH_Inventory](
	[YH_Type]      ,
	[YH_Type_CN] ,
	[SKU_ID] ,
	[SKU_NM] ,
	[YH_UPC] ,
	[Region_CD] ,
	[Region_NM] ,
	[Store_ID] ,
	[Store_NM] ,
	[Calendar_DT] ,
	[Inventory_AMT] ,
	[Inventory_WithTax_AMT] ,
	[Inventory_QTY]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By] )
  SELECT NULL AS [YH_Type],
		 NULL AS [YH_Type_CN],
		 P.[SKU_ID],
		 P.SKU_Name_CN,
		 t.[YH_UPC],
		 NULL AS [Region_CD],
		 NULL AS [Region_NM],
		 ST.[Store_ID],
		 ST.Store_Name,
		 CAST([Calendar_DT] AS DATE),
		 [Inventory_AMT],
		 [Inventory_WithTax_AMT],
		 [Inventory_QTY]
		 ,GETDATE() AS [Create_Time]
		 ,OBJECT_NAME(@@PROCID) AS [Create_By]
		 ,GETDATE() AS [Update_Time]
		 ,OBJECT_NAME(@@PROCID) AS [Update_By]
		 FROM [ODS].[ods].[File_YH_Inventory] t
		 LEFT JOIN dm.Dim_Product P ON T.[YH_UPC] = P.Bar_Code AND CASE WHEN t.SKU_NM LIKE '%小猪%' THEN 'PEPPA' WHEN t.SKU_NM LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
		 LEFT JOIN dm.Dim_Store ST ON t.[YH_Store_CD] = ST.Account_Store_Code AND st.Channel_Account = 'YH' 
		 WHERE t.Calendar_DT<='2019-07-06'
	UNION ALL
  SELECT NULL AS [YH_Type],
		 NULL AS [YH_Type_CN],
		 P.[SKU_ID],
		 P.SKU_Name_CN,
		 t.bar_code,
		 NULL AS [Region_CD],
		 NULL AS [Region_NM],
		 ST.[Store_ID],
		 ST.Store_Name,
		 CAST(calday AS DATE),
		 inv_amt,
		 0 AS [Inventory_WithTax_AMT],
		 inv_qty
		 ,GETDATE() AS [Create_Time]
		 ,OBJECT_NAME(@@PROCID) AS [Create_By]
		 ,GETDATE() AS [Update_Time]
		 ,OBJECT_NAME(@@PROCID) AS [Update_By]
		 FROM [ODS].[ods].EDI_YH_Inventory t
		 LEFT JOIN dm.Dim_Product P ON T.bar_code = P.Bar_Code AND CASE WHEN t.goods_name LIKE '%小猪%' THEN 'PEPPA' WHEN t.goods_name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN p.Brand_IP IN ('PEPPA','RIKI') THEN p.Brand_IP ELSE 'PEPPA' END
		 LEFT JOIN dm.Dim_Store ST ON t.shop_id = ST.Account_Store_Code AND st.Channel_Account = 'YH'
		 WHERE calday>'20190706'


   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
