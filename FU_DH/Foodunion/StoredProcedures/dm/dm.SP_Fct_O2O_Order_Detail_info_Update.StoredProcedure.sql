USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_O2O_Order_Detail_info_Update]
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
	

	--- #skumapping
	DROP TABLE IF EXISTS  #skumapping;
	SELECT a.product_id,a.product_name
		,CASE WHEN CHARINDEX('*',value)=0 THEN value ELSE dbo.split(value,'*',1) END AS SKU_ID
		,CASE WHEN CHARINDEX('*',value)=0 THEN 1 ELSE dbo.split(value,'*',-1) END AS QTY
		,ROW_NUMBER() OVER(PARTITION BY a.product_name,a.product_id ORDER BY value) RID
	INTO #skumapping
	FROM (SELECT replace(product_id,'X','*') AS product_id,product_name,ROW_NUMBER() OVER(PARTITION BY product_name ORDER BY create_time DESC) SID		
		FROM [ods].[ods].[SCRM_order_detail_info] o
		WHERE isnull(product_id,'')<>''
		AND product_name<>'����Ʒ��Lakto��ζ��С�������Ÿ�Ȥ��LGG��������ͯ����116g*2��'
		)a
		CROSS APPLY STRING_SPLIT(replace(a.product_id,'/','|'), '|')
	WHERE a.SID=1
	UNION 
	  SELECT '1120001','����Ʒ��Lakto��ζ��С�������ζ������ţ�̳��·�����200ml*6ƿ','1120001',1,1
	UNION SELECT '1150003','����Ʒ��Shapetime �ζ��� 21 �ߵ��׵�֬���� 330ml*6ƿ �ɿ�����ζ','1150003',1,1
	UNION SELECT '2100030','����Ʒ����ζ��С��Ȥ��LAKTO Flip cup 116g*2 (2 flavors) LGG Probiotics','2100030',1,1
	UNION SELECT '2100030','�����ļƻ���Lakto��ζ��С�������Ÿ�Ȥ��(�����ǣ�116g*2����ÿ��2�У�','2100030',1,1
	UNION SELECT '2100030','69.9Ԫ4�� - ��ζ�� С�������Ÿ�Ȥ��LGG��������ͯ����116g*2��','2100030',1,1
	UNION SELECT '2100002','69.9Ԫ4��-��ζ�� ������ LGG��������ͯ�������̶��ζ100ml*4ƿ','2100030',1,1
	UNION SELECT '2100030','79.9Ԫ4�� - ��ζ�� С�������Ÿ�Ȥ��LGG��������ͯ����116g*2�� |232','2100030',1,1
	UNION SELECT '2100002','79.9Ԫ4��-��ζ�� ������ LGG��������ͯ�������̶��ζ100ml*4ƿ |420','2100030',1,1

	--UNION SELECT '2100001','�������ƻ�����ζ�� Lakto ��������������� LGG ���ζ','2100001',1,1
	UNION SELECT '1180004','�����ļƻ��������� ��ţ�� ԭζ 950ml','1180004',2,1
	UNION SELECT '1180004','�����ļƻ��������� ��ţ�̣�ÿ��1�У� ԭζ 950ml*1','1180004',1,1
	--UNION SELECT '2100002','�����ļƻ�����ζ��-ԭζ- ������ LGG��������ͯ��������100ml*4ƿ','2100002',1,1
	UNION SELECT '1150003','��������Shapetime �ζ��� 21 �ߵ��׵�֬���� 330ml*6ƿ �ɿ�����ζ','1150003',1,1
	UNION SELECT '1120001','Lakto��ζ��С�������ζ������ţ�̳��·�����200ml*6ƿ','1120001',1,1
	UNION SELECT '1150003','Shapetime �ζ��� 21 �ߵ��׵�֬���� 330ml*6ƿ �ɿ�����ζ','1150003',1,1
	UNION SELECT '2100002','��ζ�� Lakto �������ͯŨ�����̵����̷�ζ��������ζ100ml*4ƿ','2100002',1,1

	UPDATE #skumapping SET QTY=6 WHERE product_name='�������顿��������250ml*6��װ';
	UPDATE #skumapping SET QTY=3 WHERE product_name='��ζ�� ŷʽ���� ��ͯ��������50g*4�� ��3����װ��������ԭζ��';

	--select * from #skumapping  where product_name ='��ζ�� ŷʽ���� ��ͯ��������50g*4�� ��3����װ��������ԭζ��' order by 2;
	--select  * from #skumapping where product_name like '%����%'
			
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
	SELECT  ord.order_no,
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
			CASE  WHEN d.sku_unique_code='45743711536283537' THEN '2100029' WHEN d.sku_unique_code='45743711536283538' THEN '2100030' 
				WHEN d.product_name LIKE '%������װ%' THEN '2100017*3' 
				WHEN d.product_name LIKE '%��ٳ��߸�%' THEN '2100017*4' ELSE d.product_id END AS Product_ID,
			d.product_name AS Product_Name,			
			d.gift AS is_gift,
			isnull(sm.RID,1) AS SeqID,
			CASE  WHEN d.sku_unique_code='45743711536283537' THEN '2100029' WHEN d.sku_unique_code='45743711536283538' THEN '2100030' 
				WHEN d.product_name LIKE '%������װ%' THEN '2100017' 
				WHEN d.product_name LIKE '%��ٳ��߸�%' THEN '2100017' ELSE sm.SKU_ID END AS SKU_ID,
			dp.SKU_Name_CN,
			--d.quantity  AS QTY,
			CASE WHEN d.product_name LIKE '%�ڶ���%' THEN 2 * d.quantity	
				WHEN d.product_name LIKE '%������װ%' THEN 3 * d.quantity	
				WHEN d.product_name LIKE '%��ٳ��߸�%' THEN 4 * d.quantity	
				WHEN d.Product_Name='����Ʒ�������� ��ţ�� ԭζ 950ml' AND s.value ='1�䣨12�У�' THEN 12 * d.quantity	
				WHEN d.Product_Name='����Ʒ�������� ��ţ�� ԭζ 950ml' AND s.value ='2��' THEN 2 * d.quantity	
				WHEN d.Product_Name='����Ʒ�������� ��ţ�� ԭζ 950ml' AND s.value ='3��' THEN 3 * d.quantity	
				WHEN d.Product_Name='����Ʒ�������� ��ţ�� ԭζ 950ml' AND s.value ='4��' THEN 4 * d.quantity	
				WHEN d.Product_Name='����Ʒ�������� ��ţ�� ԭζ 950ml' AND s.value ='5��' THEN 5 * d.quantity	
				WHEN d.Product_Name='����Ʒ�������� ��ţ�� ԭζ 950ml' AND s.value ='12��' THEN 12 * d.quantity	
				ELSE d.quantity END AS QTY,  --�������, ���еڶ��ݻ����double����
			d.Unit_Price AS Unit_Price,
			d.total_price AS Total_Price,
			isnull(dp.Sale_Unit_Weight_KG *1000, w.[weight_g]) AS [Unit_Weight_g], 
			s.value AS Scale,
		    --s2.value AS Flavor,
		    s3.value AS SubscriptionType,		
			ISNULL(CASE WHEN ISNULL(sm.product_id,'')='' AND s.value LIKE '%,%' THEN dbo.split(dbo.split(REPLACE(s.value,'��','��'),'��',1),'��',2)  --Scale = ÿ�����飬100ml*8ƿ
			     WHEN ISNULL(sm.product_id,'')='' AND s.value is null and (s3.value LIKE '%,ÿ��%') THEN dbo.split(dbo.split(REPLACE(replace(replace(s3.value,'ÿ��',''),'��','��'),'һ','1'),',',2),'��',1) 	  --Subscription_Type = ����8�ܣ�ÿ��2��8ƿ  /����4�ܣ�ÿ��2��
				 ELSE 
				 coalesce(dbo.split(dbo.split(REPLACE(REPLACE(s.value,'��','��'),'һ��','1��'),'*',2),'��',1),dbo.split(dbo.split(REPLACE(REPLACE(s.value,'��','��'),'һ��','1��'),'��',2),'��',1),1) 
				 END
				 ,1) * isnull(sm.QTY,1)   --���Product_ID������д��su.product_id>'',��ֻȡsm.QTY�����Product_IDΪ�հף������Scale�ֶ�
				 as pcs_cnt,   --ÿ��ƿ��
			CASE WHEN s3.value LIKE 'ÿ��%' THEN dbo.split(dbo.split(REPLACE(REPLACE(s3.value,'��','��'),'һ��','1��'),'��',2),'��',1) ELSE
			     coalesce(dbo.split(dbo.split(REPLACE(REPLACE(s3.value,'��','��'),'һ��','1��'),'��',2),'��',1),dbo.split(dbo.split(REPLACE(REPLACE(s3.value,'��','��'),'һ��','1��'),'��',2),'��',1),1) END as delivery_cnt,		   
			d.Buyer_Messages,
			d.sku_name as SKU_Desc,
			d.payment,
			getdate() AS [Create_Time],
			'' AS [Create_By],
			getdate() AS [Update_Time],
			'' AS [Update_By]			
		FROM [ods].[ods].[SCRM_order_detail_info] d 
		LEFT JOIN #weight w ON d.product_name =  w.product_name
		LEFT JOIN #skudesc s ON d.order_no = s.order_no AND s.name='��'
		--LEFT JOIN #skudesc s2 ON d.order_id = s2.order_id AND s2.name='��ζ'
		LEFT JOIN #skudesc s3 ON d.order_no = s3.order_no AND s3.name='���ڹ����'
		LEFT JOIN #skumapping sm ON d.product_name = sm.product_name
		LEFT JOIN dm.Dim_Product dp ON (CASE d.sku_unique_code WHEN '45743711536283537' THEN '2100029' WHEN '45743711536283538' THEN '2100030' ELSE sm.SKU_ID END)=dp.SKU_ID
		--ORDER by 1 desc,2,sm.RID
		;

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
--WHERE NAME='��'
--and value like '%��%'
GO
