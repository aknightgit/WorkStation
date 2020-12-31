USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dm].[SP_Fct_O2O_Order_Detail_info_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	
	EXEC [dm].[SP_Dim_Product_OutSKUMapping_Update];   --刷新套餐Mapping表

	UPDATE [ods].[ods].[SCRM_order_detail_info] SET product_id=product_id+'X1'
	WHERE RIGHT(product_id,4) NOT LIKE '%X%' AND product_id LIKE '%X%';

	--- #skumapping
	DROP TABLE IF EXISTS  #skumapping;
	SELECT REPLACE(product_id,'B#T','BXT') as product_id,a.product_name
		,REPLACE(CASE WHEN CHARINDEX('*',value)=0 THEN value ELSE dbo.split(value,'*',1) END,'B#T','BXT') AS SKU_ID
		,CASE WHEN CHARINDEX('*',value)=0 THEN 1 ELSE dbo.split(value,'*',-1) END AS QTY
		,ROW_NUMBER() OVER(PARTITION BY a.product_name,a.product_id ORDER BY value) RID
	INTO #skumapping
	FROM (SELECT replace(REPLACE(product_id,'BXT','B#T'),'X','*') AS product_id,product_name,ROW_NUMBER() OVER(PARTITION BY product_name ORDER BY create_time DESC) SID		
		FROM [ods].[ods].[SCRM_order_detail_info] o
		WHERE isnull(product_id,'')<>''
		AND product_name<>'【单品】Lakto乐味可小猪佩奇优格翻趣杯LGG益生菌儿童酸奶116g*2杯' AND product_id <>'BXT001'
		)a
		CROSS APPLY STRING_SPLIT(replace(a.product_id,'/','|'), '|')
	WHERE a.SID=1 
	UNION 
	  SELECT '1120001','【单品】Lakto乐味可小猪佩奇风味乳酸奶牛奶常温发酵乳200ml*6瓶','1120001',1,1
	UNION SELECT '1150003','【单品】Shapetime 形动力 21 高蛋白低脂奶昔 330ml*6瓶 巧克力口味','1150003',1,1
	UNION SELECT '2100030','【单品】乐味可小猪翻趣杯LAKTO Flip cup 116g*2 (2 flavors) LGG Probiotics','2100030',1,1
	--UNION SELECT '2100030','【订阅计划】Lakto乐味可小猪佩奇优格翻趣杯(跳跳糖）116g*2杯（每周2盒）','2100030',1,1
	UNION SELECT '2100030','69.9元4件 - 乐味可 小猪佩奇优格翻趣杯LGG益生菌儿童酸奶116g*2杯','2100030',1,1
	UNION SELECT '2100002','69.9元4件-乐味可 优酪乳 LGG益生菌儿童新鲜酸奶多口味100ml*4瓶','2100030',1,1
	UNION SELECT '2100030','79.9元4件 - 乐味可 小猪佩奇优格翻趣杯LGG益生菌儿童酸奶116g*2杯 |232','2100030',1,1
	UNION SELECT '2100002','79.9元4件-乐味可 优酪乳 LGG益生菌儿童新鲜酸奶多口味100ml*4瓶 |420','2100030',1,1

	--UNION SELECT '2100001','【订购计划】乐味可 Lakto 优酪乳活性益生菌 LGG 多口味','2100001',1,1
	UNION SELECT '1180004','【订阅计划】蓝堡臻 鲜牛奶 原味 950ml','1180004',2,1
	UNION SELECT '1180004','【订阅计划】蓝堡臻 鲜牛奶（每周1盒） 原味 950ml*1','1180004',1,1
	--UNION SELECT '2100002','【订阅计划】乐味可-原味- 优酪乳 LGG益生菌儿童新鲜酸奶100ml*4瓶','2100002',1,1
	UNION SELECT '1150003','【热卖】Shapetime 形动力 21 高蛋白低脂奶昔 330ml*6瓶 巧克力口味','1150003',1,1
	UNION SELECT '1120001','Lakto乐味可小猪佩奇风味乳酸奶牛奶常温发酵乳200ml*6瓶','1120001',1,1
	UNION SELECT '1150003','Shapetime 形动力 21 高蛋白低脂奶昔 330ml*6瓶 巧克力口味','1150003',1,1
	UNION SELECT '2100002','乐味可 Lakto 优酪乳儿童浓缩酸奶低温奶风味发酵乳多口味100ml*4瓶','2100002',1,1

	UPDATE #skumapping SET QTY=6 WHERE product_name='【蓝堡臻】巴氏鲜奶250ml*6盒装';
	UPDATE #skumapping SET QTY=3 WHERE product_name='乐味可 欧式鲜酪 儿童新鲜奶酪50g*4杯 （3盒套装）（无糖原味）';

	--select * from #skumapping  where product_name ='乐味可 欧式鲜酪 儿童新鲜奶酪50g*4杯 （3盒套装）（无糖原味）' order by 2;
	--select  * from #skumapping where product_name like '%订阅%'
			
	--product weight
	DROP TABLE IF EXISTS  #prodg;
	SELECT IDENTITY(INT, 1 ,1) as RID,a.product_name, value  
	INTO #prodg
	FROM (SELECT DISTINCT product_name FROM [ods].[ods].[SCRM_order_detail_info])a
		CROSS APPLY STRING_SPLIT(a.product_name, '|')
	--where order_id=331254951177228288  ;

	DROP TABLE IF EXISTS  #weight;
	;WITH CTE AS(
		SELECT ROW_NUMBER() OVER(PARTITION BY product_name ORDER BY RID) pid, product_name, [value] AS weight_g  
		FROM #prodg)
	--select * from CTE
	,CTE2 AS(SELECT MAX(pid) pid,product_name FROM CTE GROUP BY product_name)
	SELECT w.product_name,max(weight_g) AS weight_g   -- ONLY THE MAX ONE 
	INTO #weight
	FROM (
		SELECT  CTE.product_name,CTE.weight_g 
		FROM CTE
		LEFT JOIN CTE2 on CTE2.product_name=CTE.product_name AND CTE2.pid=CTE.pid
		WHERE CTE.product_name is NOT NULL AND CTE2.pid <> 1

		UNION

		SELECT  Prod_Name,weight_g FROM ODS.[ods].[SCRM_O2O_ProdMapping]	
	)w
	GROUP BY w.product_name;
	
	--SKU_NAME Parser
	DROP TABLE IF EXISTS  #skudesc;
	SELECT DISTINCT ord.order_no,
		JsonData.k AS name,
		JsonData.v AS value,
		ISJSON(ord.sku_name) AS IsJsonCol
	INTO #skudesc
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
	WHERE ISJSON(ord.sku_name)>0;
	--SELECT *FROM #skudesc

		
		--[dm].[Fct_O2O_Order_Detail_info]
		TRUNCATE TABLE [dm].[Fct_O2O_Order_Detail_info];
		INSERT INTO [dm].[Fct_O2O_Order_Detail_info]
           ([Order_ID]
           ,[Sub_Order]
           ,[Product_ID]
		   ,[Product_SKU_ID]
           ,[Product_Name]
           ,[is_gift]
           ,[SeqID]
           ,[SKU_ID]
           ,[SKU_Name_CN]
           ,[QTY]
           ,[Unit_Price]
           ,[Total_Price]
           ,[Unit_Weight_g]
           ,[Scale]
           ,[SubscriptionType]
           ,[pcs_cnt]
           ,[delivery_cnt]
           ,[Buyer_Messages]
           ,[SKU_Desc]
		   ,payment
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			d.order_id AS Order_ID,
			d.order_no AS Sub_Order,
			CASE WHEN ISNULL(D.product_sku_id,'') <> '' THEN  (CASE WHEN D.product_sku_id  IN('2100018#NGY','2100019#NGY','2100021#NGY') THEN REPLACE(D.product_sku_id,'#NGY','')
			                                                        WHEN D.product_sku_id='1180004X2#NGY' THEN '1180004X2NG' ELSE D.product_sku_id END)                         --优先选择数据新增列规格编码 product_sku_id,修改套餐规格名称不一致情况    Justin 2020-07-16
			    WHEN d.sku_unique_code='45743711536283537' THEN '2100029' WHEN d.sku_unique_code='45743711536283538' THEN '2100030' 
				WHEN d.product_name LIKE '%订阅套装%' THEN '2100017*3' 
				WHEN d.product_name LIKE '%暑假长高高%' THEN '2100017*4' 
				WHEN D.product_id = 'LBZ-QJT-A' THEN 'LBZ-QJT-A'    --相同规格名称，不同规格编码（Product ID 存在且为规格编码）
				WHEN D.product_id = 'LBZ-QJT-B' THEN 'LBZ-QJT-B' 
				WHEN D.sku_name like '%精选礼盒100个- 莓果酸奶12瓶%' AND D.product_name IN ('【欧洲乳品 精选礼盒】- 欧洲品质乳品,好评不断,营养满满和增强抵抗!','【限时促销】- 限量88份 欧洲品质乳品,好评不断,营养满满和增强抵抗!')
				THEN '1182006'                                       --相同规格名称，不同规格编码（Product ID 不存在，根据Name判断）
				WHEN D.sku_name like '%精选礼盒100个- 莓果酸奶12瓶%' AND D.product_name IN ('【限时促销】- 限量188份 欧洲品质乳品,好评不断,营养满满和增强抵抗!')
				THEN '1182007' 
				WHEN SMP.[OutSKUID] IS NOT NULL  THEN SMP.[OutSKUID]	----------增加福袋规格判断  Justin  2020-02-18			
				  
				ELSE d.product_id END AS Product_ID,
				D.[product_sku_id],
			CASE ----------增加福袋规格判断  Justin  2020-02-18
				WHEN SMP.[OutSKUID] IS NOT NULL  
				THEN SMP.[OutSKUName]
				----------增加福袋规格判断  
				ELSE d.product_name END AS Product_Name,			
			d.gift AS is_gift,
			isnull(sm.RID,1) AS SeqID,
			CASE  WHEN d.sku_unique_code='45743711536283537' THEN '2100029' WHEN d.sku_unique_code='45743711536283538' THEN '2100030' 
				WHEN d.product_name LIKE '%订阅套装%' THEN '2100017' 
				WHEN d.product_name LIKE '%暑假长高高%' THEN '2100017' ELSE sm.SKU_ID END AS SKU_ID,
			dp.SKU_Name_CN,
			--d.quantity  AS QTY,
			CASE WHEN d.product_name LIKE '%第二件%' THEN 2 * d.quantity	
				WHEN d.product_name LIKE '%订阅套装%' THEN 3 * d.quantity	
				WHEN d.product_name LIKE '%暑假长高高%' THEN 4 * d.quantity	
				WHEN d.Product_Name='【单品】蓝堡臻 鲜牛奶 原味 950ml' AND s.value ='1箱（12盒）' THEN 12 * d.quantity	
				WHEN d.Product_Name='【单品】蓝堡臻 鲜牛奶 原味 950ml' AND s.value ='2盒' THEN 2 * d.quantity	
				WHEN d.Product_Name='【单品】蓝堡臻 鲜牛奶 原味 950ml' AND s.value ='3盒' THEN 3 * d.quantity	
				WHEN d.Product_Name='【单品】蓝堡臻 鲜牛奶 原味 950ml' AND s.value ='4盒' THEN 4 * d.quantity	
				WHEN d.Product_Name='【单品】蓝堡臻 鲜牛奶 原味 950ml' AND s.value ='5盒' THEN 5 * d.quantity	
				WHEN d.Product_Name='【单品】蓝堡臻 鲜牛奶 原味 950ml' AND s.value ='12盒' THEN 12 * d.quantity	
				ELSE d.quantity END AS QTY,  --购买份数, 所有第二份活动，都double计算
			d.Unit_Price AS Unit_Price,
			d.total_price AS Total_Price,
			isnull(dp.Sale_Unit_Weight_KG *1000, w.[weight_g]) AS [Unit_Weight_g], 
			s.value AS Scale,
		    --s2.value AS Flavor,
		    s3.value AS SubscriptionType,		
			ISNULL(CASE WHEN ISNULL(sm.product_id,'')='' AND s.value LIKE '%,%' THEN dbo.split(dbo.split(REPLACE(s.value,'组','盒'),'盒',1),'周',2)  --Scale = 每周两组，100ml*8瓶
			     WHEN ISNULL(sm.product_id,'')='' AND s.value is null and (s3.value LIKE '%,每周%') THEN dbo.split(dbo.split(REPLACE(replace(replace(s3.value,'每周',''),'盒','组'),'一','1'),',',2),'组',1) 	  --Subscription_Type = 配送8周，每周2组8瓶  /配送4周，每周2盒
				 ELSE 
				 coalesce(dbo.split(dbo.split(REPLACE(REPLACE(s.value,'期','周'),'一盒','1盒'),'*',2),'盒',1),dbo.split(dbo.split(REPLACE(REPLACE(s.value,'期','周'),'一盒','1盒'),'周',2),'盒',1),1) 
				 END
				 ,1) * isnull(sm.QTY,1)   --如果Product_ID正常填写，su.product_id>'',则只取sm.QTY；如果Product_ID为空白，则解析Scale字段
				 as pcs_cnt,   --每期瓶数
			CASE WHEN s3.value LIKE '每周%共%' THEN dbo.split(dbo.split(REPLACE(REPLACE(s3.value,'期','周'),'一盒','1盒'),'共',2),'周',1) ELSE
			     coalesce(dbo.split(dbo.split(REPLACE(REPLACE(s3.value,'期','周'),'一盒','1盒'),'送',2),'次',1),dbo.split(dbo.split(REPLACE(REPLACE(s3.value,'期','周'),'一盒','1盒'),'送',2),'周',1),1) END as delivery_cnt,		   
			d.Buyer_Messages,
			d.sku_name as SKU_Desc,
			d.payment,
			getdate() AS [Create_Time],
			'' AS [Create_By],
			getdate() AS [Update_Time],
			'' AS [Update_By]			
		FROM [ods].[ods].[SCRM_order_detail_info] d 
		LEFT JOIN #weight w ON d.product_name =  w.product_name
		LEFT JOIN #skudesc s ON d.order_no = s.order_no AND s.name='件'
		--LEFT JOIN #skudesc s2 ON d.order_id = s2.order_id AND s2.name='口味'
		LEFT JOIN #skudesc s3 ON d.order_no = s3.order_no AND s3.name='周期购规格'
		LEFT JOIN #skumapping sm ON d.product_name = sm.product_name
		LEFT JOIN dm.Dim_Product dp ON (CASE d.sku_unique_code WHEN '45743711536283537' THEN '2100029' WHEN '45743711536283538' THEN '2100030' ELSE sm.SKU_ID END)=dp.SKU_ID
		LEFT JOIN (SELECT DISTINCT [OutSKUID],[OutSKUName],[SKUMappingName] FROM [Foodunion].[dm].[Dim_Product_OutSKUMapping] WHERE [OutSKUName] NOT IN( '蓝堡臻全家桶套餐','精选礼盒100个- 莓果酸奶12瓶') AND [SKUMappingName] IS NOT NULL) SMP  
		ON D.sku_name=SMP.[SKUMappingName]
		--ORDER by 1 desc,2,sm.RID
		;
 ----根据套餐规格 Mapping 对应SKU                            Justin 2020-04-20      
 TRUNCATE TABLE [Foodunion].[dm].[Fct_O2O_Order_Detail_bySKU]
 INSERT INTO [Foodunion].[dm].[Fct_O2O_Order_Detail_bySKU]
 ( [Order_ID]
      ,[Sub_Order]
      ,[Product_ID]
      ,[Product_Name]
      ,[is_gift]
      ,[SeqID]
      ,[SKU_ID]
      ,[SKU_Name_CN]
      ,[QTY]
      ,[Unit_Price]
      ,[Total_Price]
      ,[Unit_Weight_g]
      ,[Scale]
      ,[SubscriptionType]
      ,[pcs_cnt]
      ,[delivery_cnt]
      ,[Buyer_Messages]
      ,[SKU_Desc]
      ,[payment]
      ,[PriceRatio]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
SELECT [Order_ID]
      ,[Sub_Order]
      ,[Product_ID]
      ,[Product_Name]
      ,[is_gift]
      ,[SeqID]
      ,CASE WHEN om.SKU_ID IS NOT NULL THEN om.SKU_ID ELSE ISNULL(di.SKU_ID,'') END AS [SKU_ID]
      ,P.SKU_Name_CN AS [SKU_Name_CN]
      ,di.QTY AS [QTY]
      ,CASE WHEN om.SKU_ID IS NOT NULL THEN CAST(PM.Retail_price_group AS decimal(9,2)) ELSE [Unit_Price] END [Unit_Price]
      ,CASE WHEN om.SKU_ID IS NOT NULL 
	   THEN CASE WHEN [Unit_Price]*[Total_Price]=0 THEN 0 ELSE CAST(CAST(PM.Retail_price_group AS decimal(9,2))/[Unit_Price]*[Total_Price]AS decimal(9,2)) END
	   ELSE [Total_Price] END AS [Total_Price]
      ,CASE WHEN om.SKU_ID IS NOT NULL THEN CAST(ISNULL(P.[Net_Weight_KG],Sale_Unit_Weight_KG)*1000 AS decimal(9,1)) ELSE [Unit_Weight_g] END [Unit_Weight_g]
      ,[Scale]
      ,[SubscriptionType]
      ,CASE WHEN om.SKU_ID IS NOT NULL THEN om.QTY  ELSE di.pcs_cnt END AS[pcs_cnt]
      ,[delivery_cnt]
      ,[Buyer_Messages]
      ,[SKU_Desc]
      ,CASE WHEN om.[OutSKUID] IS NOT NULL THEN CAST(di.payment *ISNULL(om.[PriceRatio],1) AS decimal(16,4)) else CAST(di.payment  AS decimal(9,2))end  AS [payment]
	  --,ISNULL(om.[PriceRatio],1) AS  [PriceRatio]
	  ,om.[PriceRatio] AS  [PriceRatio]
      ,DI.[Create_Time]
      ,DI.[Create_By]
      ,DI.[Update_Time]
      ,DI.[Update_By] 
  FROM [Foodunion].[dm].[Fct_O2O_Order_Detail_info] DI 
  LEFT JOIN (SELECT DISTINCT [OutSKUID],[SKU_ID],[PriceRatio],[QTY] FROM [Foodunion].[dm].[Dim_Product_OutSKUMapping]) om ON ISNULL(di.Product_ID,'')=om.[OutSKUID]
  LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON (CASE WHEN om.SKU_ID IS NOT NULL THEN om.SKU_ID ELSE di.SKU_ID END)=p.SKU_ID
  LEFT JOIN (SELECT * FROM [dm].[Dim_Product_AccountCodeMapping] WHERE Account='Youzan') PM ON (CASE WHEN om.SKU_ID IS NOT NULL THEN om.SKU_ID ELSE di.SKU_ID END)=PM.SKU_ID ;



		DROP TABLE IF EXISTS  #weight;
		DROP TABLE IF EXISTS  #prodg;
		DROP TABLE IF EXISTS  #skudesc;
		DROP TABLE IF EXISTS  #skumapping;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END



--SELECT * FROM #skudesc
--WHERE NAME='件'
--and value like '%共%'
GO
