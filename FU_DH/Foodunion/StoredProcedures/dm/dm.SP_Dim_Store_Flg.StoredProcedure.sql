USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Store_Flg]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dm].[SP_Dim_Store_Flg]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 
  TRUNCATE TABLE  [Foodunion].[dm].[Dim_Store_Flg] 
   
   INSERT INTO [Foodunion].[dm].[Dim_Store_Flg](
Store_ID,
Account_Store_Code,
FIRST_SALES_DATE_AMBIENT,
FIRST_SALES_DATE_Fresh,
FIRST_SALES_DATE,
FIRST_SALES_DATE_BOTH,
[Load_DTM]
   )
SELECT 
T.Store_ID,
T.Account_Store_Code,
FIRST_SALES_DATE_AMBIENT,
FIRST_SALES_DATE_Fresh,
FIRST_SALES_DATE,
FIRST_SALES_DATE_BOTH,
GETDATE()
FROM [Foodunion].[dm].[Dim_Store] T
LEFT JOIN (
	SELECT Store_ID,
	YH_Store_CD,
	MAX(CASE WHEN YH_categroy='Ambient' THEN FIRST_SALES_DATE ELSE NULL END)FIRST_SALES_DATE_AMBIENT,
	MAX(CASE WHEN YH_categroy='Fresh' THEN FIRST_SALES_DATE ELSE NULL END)FIRST_SALES_DATE_Fresh,
	MIN(FIRST_SALES_DATE) FIRST_SALES_DATE,
	(CASE WHEN (MAX(CASE WHEN YH_categroy='Fresh' THEN FIRST_SALES_DATE ELSE NULL END)) IS NOT NULL
	AND MAX(CASE WHEN YH_categroy='Ambient' THEN FIRST_SALES_DATE ELSE NULL END) IS NOT NULL 
	THEN 
	MAX(FIRST_SALES_DATE) ELSE NULL END )FIRST_SALES_DATE_BOTH
	FROM 
	(
		SELECT 
		inv.Store_ID,
		st.Account_Store_Code AS YH_Store_CD,
		prod.Product_Sort AS YH_categroy,
		MIN(Calendar_DT) FIRST_SALES_DATE,
		MAX(Calendar_DT) LAST_SALES_DATE
		FROM [dm].[Fct_YH_Sales_Inventory] inv
		LEFT JOIN dm.Dim_Product prod ON inv.SKU_ID = prod.SKU_ID
		LEFT JOIN dm.Dim_Store st ON inv.Store_ID = st.Store_ID
		GROUP BY 
		inv.Store_ID,
		st.Account_Store_Code,
		prod.Product_Sort
	)T
	GROUP BY 
	 Store_ID,
	YH_Store_CD 
)T1 ON T1.Store_ID=T.Store_ID
WHERE T.Channel_Account = 'YH'





   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
