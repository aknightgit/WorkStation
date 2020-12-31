USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dm].[SP_Dim_Store_Flag_Update]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 
  TRUNCATE TABLE  [Foodunion].[dm].[Dim_Store_Flag]
   
INSERT INTO [Foodunion].[dm].[Dim_Store_Flag](
       [Store_ID]
      ,[Account_Store_Code]
      ,[FIRST_SALES_DATE_AMBIENT]
      ,[FIRST_SALES_DATE_Fresh]
      ,[FIRST_SALES_DATE]
      ,[FIRST_SALES_DATE_BOTH]
      ,[Star_Store]
      ,[Target_Store]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
       )
	SELECT 
	T.Store_ID,
	T.Account_Store_Code,
	FIRST_SALES_DATE_AMBIENT,
	FIRST_SALES_DATE_Fresh,
	FIRST_SALES_DATE,
	FIRST_SALES_DATE_BOTH,
	NULL,
	NULL,
	GETDATE(),
	@ProcName,
	GETDATE(),
	@ProcName
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
WHERE T.Channel_Account = 'YH';


--临时增加 Target_Store，Star_Store 数据维护      2020-10-09  Justin
  UPDATE A SET A.Target_Store='Focused stores'
  FROM [Foodunion].[dm].[Dim_Store_Flag] A
  JOIN [ODS].[ods].[277KA_Store_List_20201009] B
  ON A.[Account_Store_Code]=B.Store_code;

  UPDATE A SET A.[Star_Store]='Top 100 stores'
  FROM [Foodunion].[dm].[Dim_Store_Flag] A
  JOIN [ODS].[ods].[TOP100_Store_List_20201009] B
  ON A.[Account_Store_Code]=B.Store_code;





   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
