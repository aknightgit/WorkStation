USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dm].[SP_Dim_Product_OutSKUMapping_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

  DROP TABLE IF EXISTS  #SKUM;  
  WITH MAPPING AS(  
  SELECT sku_name,v_id,value,ROW_NUMBER()OVER(PARTITION BY sku_name ORDER BY v_id) AS RN
  FROM (
  SELECT DISTINCT ord.sku_name,		
		JsonData.v AS value ,v_id
	FROM [ods].[ods].[SCRM_order_detail_info] ord
	CROSS APPLY 
	OPENJSON (ord.sku_name, N'$')  
			   WITH (  
				  k		varchar(200) N'$.k',   
				  k_id  varchar(200) N'$.k_id',  
				  v		varchar(200) N'$.v',   
				  v_id	varchar(200) N'$.v_id'  
			   )  
	  AS JsonData 
	WHERE ISJSON(ord.sku_name)>0) S)

   
   SELECT ROW_NUMBER()OVER(PARTITION BY sku_name ORDER BY v_id) AS RN ,sku_name,v_id,value
   INTO #SKUM
   FROM MAPPING ORDER BY RN;

   DROP TABLE IF EXISTS  #OutSKUMapping; 
	  SELECT  DISTINCT [Account]
      ,[OutSKUID]
      ,[OutSKUName]
      --,[SKUMappingName]
	  ,T.sku_name
      ,[SKU_ID]
      ,[Price]
      ,[PriceRatio]
      ,[QTY]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By] INTO #OutSKUMapping
  	   FROM [Foodunion].[dm].[Dim_Product_OutSKUMapping] S
	   LEFT JOIN
	   (SELECT sku_name,REPLACE(SKU_M,'#','') AS  SKU_M FROM
	           (SELECT A1.sku_name,SKU_M = stuff((SELECT '#' + value FROM #SKUM AS A WHERE A.sku_name =A1.sku_name  FOR XML path('') ), 1, 1, '')
                 FROM #SKUM AS A1 GROUP BY sku_name ) R   ) T
	   ON SKU_M=S.OutSKUName
	   ;
      TRUNCATE TABLE [Foodunion].[dm].[Dim_Product_OutSKUMapping];
	  INSERT INTO [Foodunion].[dm].[Dim_Product_OutSKUMapping]
	  ([Account]
      ,[OutSKUID]
      ,[OutSKUName]
      ,[SKUMappingName]
      ,[SKU_ID]
      ,[Price]
      ,[PriceRatio]
      ,[QTY]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	  SELECT DISTINCT [Account]
      ,[OutSKUID]
      ,[OutSKUName]
      --,[SKUMappingName]
	  ,sku_name
      ,[SKU_ID]
      ,[Price]
      ,[PriceRatio]
      ,[QTY]
      ,GETDATE() [Create_Time]
      ,'SP_Dim_Product_OutSKUMapping_Update' [Create_By]
      ,GETDATE() [Update_Time]
      ,'SP_Dim_Product_OutSKUMapping_Update' [Update_By] 
	  FROM #OutSKUMapping
	  ;


--补充订单中非套餐组合产品

--DROP TABLE IF EXISTS  #productmapping;
--SELECT a.PID
--,RO.SKU_ID
--,RO.QTY  into #productmapping
--FROM (SELECT DISTINCT replace(product_id,'X','*') AS product_id,product_id AS PID
--	FROM [ods].[ods].[SCRM_order_detail_info]  o LEFT JOIN [Foodunion].[dm].[Dim_Product_OutSKUMapping] M
--	ON o.product_id=m.OutSKUID
--	WHERE isnull(product_id,'')<>'' AND product_id<>'1180004-1'	and m.OutSKUID is  null)a
--OUTER APPLY [dbo].[Split_Product_20200514]( a.product_id ) ro 

-- INSERT INTO [Foodunion].[dm].[Dim_Product_OutSKUMapping]  
--     ([Account]
--      ,[OutSKUID]
--      --,[OutSKUName]
--      --,[SKUMappingName]
--      ,[SKU_ID]
--      ,[Price]
--      ,[PriceRatio]
--      ,[QTY]
--      ,[Create_Time]
--      ,[Create_By]
--      )
-- SELECT 'Youzan' AS [Account]
--		 ,P1.PID AS [OutSKUID]
--		 ,P1.SKU_ID
--		 ,SP.[有赞定价] AS [Price]
--		 ,SP.[有赞定价]/SUM([有赞定价])OVER(PARTITION BY P1.PID) AS [PriceRatio]
--		 ,P1.QTY
--		 ,GETDATE() AS [Create_Time]
--		 ,'SP_Dim_Product_OutSKUMapping_Update'[Create_By]
		 
-- FROM #productmapping P1
-- JOIN 
-- (select pid from #productmapping WHERE LEFT(PID,1) IN ('1','2','3','4','5')  GROUP BY pid HAVING COUNT(1)>1) P2
-- ON P1.PID=P2.PID
-- LEFT JOIN [Foodunion].[dm].[Dim_YouZan_SKU_Price] SP
-- ON P1.SKU_ID=SP.[Product Code]
		
 ;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
