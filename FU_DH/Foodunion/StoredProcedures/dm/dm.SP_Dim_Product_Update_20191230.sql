USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






create PROCEDURE [dm].[SP_Dim_Product_Update_20191230]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		-- Update SKU list from ERP_SKU_List
		UPDATE p
		SET p.[SKU_Name] = coalesce(esl.[SKU_Name_EN],esl.[SKU_Name],p.[SKU_Name])
			,p.[SKU_Name_CN] = esl.[SKU_Name]
			,p.Product_Type = 'Dairy'
			,p.Product_Sort = CASE WHEN esl.[Prod_Category] ='冷藏'  OR CAST(esl.LifeTime AS decimal(5,2)) <=40 OR p.Product_Category LIKE '%Fresh%' THEN 'Fresh' 
				ELSE 'Ambient' END
			,p.Plant = esl.JV
			,p.Brand_Name =  CASE WHEN esl.Brand LIKE '%LAKTO%' OR esl.[SKU_Name_EN] LIKE '%LAKTO%' THEN 'LAKTO' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN 'Rasa' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BRAVO%' THEN 'BRAVO MAMA' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%Piens%' THEN 'Limbazu Piens' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SHAPETIME%' THEN 'SHAPETIME' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN 'Bonne Maman' 
				ELSE 'Others' END
			,p.Brand_Name_CN =  CASE WHEN esl.Brand LIKE '%LAKTO%' OR esl.[SKU_Name_EN] LIKE '%LAKTO%' THEN '乐味可' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN '醇饴牧场' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BRAVO%' THEN '倍乐曼' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%Piens%' THEN '蓝堡臻' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SHAPETIME%' THEN '形动力' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN '蓓妮妈妈' 
				ELSE '其他' END
			,p.Sale_Scale = CASE WHEN isnull(p.Sale_Scale,'')='' THEN esl.Sale_Scale ELSE p.Sale_Scale END
			,p.Base_Unit = CASE WHEN ISNULL(p.Base_Unit,'')='' THEN esl.Base_Unit_EN ELSE p.Base_Unit END
			,p.Base_Unit_CN = CASE WHEN ISNULL(p.Base_Unit_CN,'')='' THEN esl.Base_Unit ELSE p.Base_Unit_CN END
			,p.Sale_Unit = CASE WHEN ISNULL(p.Sale_Unit,'')='' THEN esl.Sale_Unit_EN ELSE p.Sale_Unit END
			,p.Sale_Unit_CN = CASE WHEN ISNULL(p.Sale_Unit_CN,'')='' THEN esl.Sale_Unit ELSE p.Sale_Unit_CN END
			,p.Shelf_Life_D = CASE WHEN CAST(esl.[LifeTime] AS REAL) = 0 THEN p.Shelf_Life_D ELSE CAST(esl.[LifeTime] AS REAL) END
			,p.Base_Unit_Weight_KG = CASE WHEN ISNULL(p.Base_Unit_Weight_KG,0)=0 THEN esl.Net_Weight * uc.Convert_Rate ELSE p.Base_Unit_Weight_KG END
			,p.Qty_BaseInSale = CAST(ucs.Convert_Rate AS INT)
			,p.Status = CASE WHEN esl.Status ='' THEN  p.Status ELSE esl.Status END
			,p.[Update_Time] = GETDATE() 
			,p.[Update_By] = @ProcName
		--SELECT p.sku_id,p.sku_name,p.Plant,esl.jv
		FROM [dm].[Dim_Product] p
		JOIN ODS.[ods].[ERP_SKU_List] esl
		ON p.SKU_ID = esl.SKU_ID
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] uc
		ON esl.Base_Unit=uc.From_Unit AND esl.Produce_Unit=uc.To_Unit
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] ucs
		ON esl.Sale_Unit=ucs.From_Unit AND esl.Base_Unit=ucs.To_Unit
		--WHERE p.SKU_ID NOT IN ('2100031'
		--		,'2100032'
		--		,'2100033'
		--		,'2100034'
		--		,'2100035'
		--		,'2100036'
		--		,'2100037'
		--		,'2100038'
		--		)
		--WHERE (p.[SKU_Name] <> esl.[SKU_Name_EN] 
		--	OR isnull(p.Plant,'') <> esl.JV
		--	OR p.Base_Unit <> esl.Base_Unit_EN
		--	OR p.Sale_Unit <> esl.Sale_Unit_EN
		--	OR CAST(ISNULL(p.Shelf_Life_D,0) AS REAL) <> CAST(esl.[LifeTime] AS REAL)
		--	OR isnull(p.Sale_Scale,'')<>isnull(esl.Sale_Scale,'')
		--	OR isnull(p.Product_Sort,'')=''
		--	OR isnull(p.Brand_Name,'')='')
		;
	
		INSERT INTO [dm].[Dim_Product]
			([SKU_ID]
			,[SKU_Name]
			,[SKU_Name_CN]
			,[Product_Type]
			,[Product_Sort]
			,[Plant]
			,[Brand_Name]
			,[Brand_Name_CN]
			,[Sale_Scale]
			,[Base_Unit]
			,[Base_Unit_CN]
			,[Sale_Unit]
			,[Sale_Unit_CN]
			,[Shelf_Life_D]
			,[Base_Unit_Weight_KG]
			,[Qty_BaseInSale]
			,[Status]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By]
			)
		SELECT 
			esl.SKU_ID
			,isnull(esl.[SKU_Name_EN],esl.[SKU_Name])
			,esl.SKU_Name
			,'Dairy'
			,CASE WHEN esl.[Prod_Category] ='冷藏' OR CAST(esl.LifeTime AS decimal(5,2)) <=40 THEN 'Fresh' ELSE 'Ambient' END
			,esl.JV
			,CASE WHEN esl.Brand LIKE '%LAKTO%' OR esl.[SKU_Name_EN] LIKE '%LAKTO%' THEN 'LAKTO' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN 'Rasa' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BRAVO%' THEN 'BRAVO MAMA' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%Piens%' THEN 'Limbazu Piens' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SHAPETIME%' THEN 'SHAPETIME' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN 'Bonne Maman' 
				ELSE 'Others' END
			,CASE WHEN esl.Brand LIKE '%LAKTO%' OR esl.[SKU_Name_EN] LIKE '%LAKTO%' THEN '乐味可' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN '醇饴牧场' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BRAVO%' THEN '倍乐曼' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%Piens%' THEN '蓝堡臻' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SHAPETIME%' THEN '形动力' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN '蓓妮妈妈' 
				ELSE '其他' END
			,esl.Sale_Scale
			,esl.Base_Unit_EN
			,esl.Base_Unit
			,esl.Sale_Unit_EN
			,esl.Sale_Unit
			,CASE WHEN CAST(esl.[LifeTime] AS REAL) = 0 THEN NULL ELSE CAST(esl.[LifeTime] AS REAL) END AS [Shelf_Life_D]
			,esl.Net_Weight * uc.Convert_Rate
			,CAST(ucs.Convert_Rate AS INT)
			,esl.Status
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_SKU_List] esl
		LEFT JOIN [dm].[Dim_Product] p
		ON p.SKU_ID = esl.SKU_ID 
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] uc
		ON esl.Base_Unit=uc.From_Unit AND esl.Produce_Unit=uc.To_Unit
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] ucs
		ON esl.Sale_Unit=ucs.From_Unit AND esl.Base_Unit=ucs.To_Unit
		WHERE p.SKU_ID IS NULL AND esl.SKU_Name IS NOT NULL;
		
		--update Sale Unit Weight/Volume
		update p
		set p.Qty_BaseInSale = cast(uc.Convert_Rate as int)
		from [dm].[Dim_Product] p
		join dm.Dim_ERP_Unit_ConvertRate uc 
		on p.Base_Unit=uc.To_Unit and p.Sale_Unit=uc.From_Unit
		where uc.Convert_Rate<>p.Qty_BaseInSale;

		update p
		set p.Sale_Unit_Weight_KG = p.Base_Unit_Weight_KG * p.Qty_BaseInSale 
			,p.Sale_Unit_Volumn_L = p.Base_Unit_Volumn_L * p.Qty_BaseInSale
		from [dm].[Dim_Product] p
		where p.Base_Unit_Weight_KG * p.Qty_BaseInSale is not null		;
		--order by 1

		update  dm.Dim_Product  set Sale_Unit_Weight_KG=0.1*4,Sale_Unit_Volumn_L=0.0960*4,Qty_BaseInSale=4 where SKU_ID='2100073'
		update  dm.Dim_Product  set Sale_Unit_Weight_KG=0.1,Sale_Unit_Volumn_L=0.0960,Qty_SaleInTray=24 where SKU_ID='2100073_0'
		update  dm.Dim_Product  set Sale_Unit_Weight_KG=0.1*4,Sale_Unit_Volumn_L=0.0960*4,Qty_BaseInSale=4 where SKU_ID='2100072'
		update  dm.Dim_Product  set Sale_Unit_Weight_KG=0.1,Sale_Unit_Volumn_L=0.0960,Qty_SaleInTray=24 where SKU_ID='2100072_0'
		update dm.Dim_Product set Sale_Unit_Weight_KG=0.2*4,Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100031'
		update dm.Dim_Product set Sale_Unit_Weight_KG=0.2*4,Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100032'
		update dm.Dim_Product set Sale_Unit_Weight_KG=0.2*4,Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100033'
		update dm.Dim_Product set Sale_Unit_Weight_KG=0.2*4,Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100034'

		--Overwright Names
		--LBZ
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh milk 950ml（15D）',sku_name_cn='蓝堡臻低温鲜奶原味950ml (15D)',Product_Category='F Milk' where sku_id='1180001';
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh milk 250ml（15D）',sku_name_cn='蓝堡臻低温鲜奶原味250ml (15D)',Product_Category='F Milk' where sku_id='1180002';
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh milk 250ml（25D）',sku_name_cn='蓝堡臻低温鲜奶原味250ml (25D)',Product_Category='F Milk' where sku_id='1180003';
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh milk 950ml(25D)',sku_name_cn='蓝堡臻低温鲜奶原味950ml (25D)',Product_Category='F Milk' where sku_id='1180004';
		--update dm.dim_product set Unified_Name='Limbažu Piens UHT Milk 200ml*6',sku_name_cn='蓝堡臻常温奶原味200*6',Product_Category='A PU Milk' where sku_id='1181001';
		--update dm.dim_product set Unified_Name='Limbažu Piens UHT Pure Milk 950ml',sku_name_cn='蓝堡臻常温奶950ml',Product_Category='A PU Milk' where sku_id='1181002';
		--update dm.dim_product set Unified_Name='Limbažu Piens Ambient Plain Yogurt 200ml*6',sku_name_cn='蓝堡臻常温酸奶原味200ml*6',Product_Category='A DR Yogurt' where sku_id='1182001';
		--update dm.dim_product set Unified_Name='Limbažu Piens Ambient Blueberry&Raspberry Yogurt 200ml*6',sku_name_cn='蓝堡臻常温酸奶混合莓果200ml*6',Product_Category='A DR Yogurt' where sku_id='1182002';
		--update dm.dim_product set Unified_Name='Limbažu Piens Ambient Plain Yogurt 950ml',sku_name_cn='蓝堡臻常温优酪乳950ml',Product_Category='A DR Yogurt' where sku_id='1182003';
		--update dm.dim_product set Unified_Name='Limbažu Piens Ambient Spoonable Yogurt Plain 80g*4',sku_name_cn='蓝堡臻风味酸奶原味80g*4',Product_Category='A SP Yogurt' where sku_id='1183001';
		--update dm.dim_product set Unified_Name='Limbažu Piens Ambient Spoonable Yogurt Strawberry 80g*4',sku_name_cn='蓝堡臻风味酸奶草莓味80g*4',Product_Category='A SP Yogurt' where sku_id='1183002';
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh Drinkable Yoghurt Vanilla 190ml',sku_name_cn='蓝堡臻香草低温优酪乳190ml',Product_Category='F DR Yogurt' where sku_id='2100071';
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh Spoonable Yoghurt Plain 100g*4',sku_name_cn='蓝堡臻低温风味发酵乳原味100g*4',Product_Category='F SP Yogurt' where sku_id='2100072';
		--update dm.dim_product set Unified_Name='Limbažu Piens Fresh Spoonable Yoghurt Strawberry 100g*4',sku_name_cn='蓝堡臻低温风味发酵乳草莓味100g*4',Product_Category='F SP Yogurt' where sku_id='2100073';

		--as of 20190725
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1171001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1172002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1172004';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1172005';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1172006';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Galdi' WHERE SKU_ID='1170001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Galdi' WHERE SKU_ID='1170002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Galdi' WHERE SKU_ID='1170005';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1171002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100062';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100063';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100064';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 3' WHERE SKU_ID='2100065';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 3' WHERE SKU_ID='2100066';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 3' WHERE SKU_ID='2100067';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 3' WHERE SKU_ID='2100068';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 3' WHERE SKU_ID='2100069';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 3' WHERE SKU_ID='2100070';
		--UPDATE dm.Dim_Product SET STATUS='inactive',Plan_Group='Serac' WHERE SKU_ID='1112001';
		--UPDATE dm.Dim_Product SET STATUS='inactive',Plan_Group='Serac' WHERE SKU_ID='1112003';
		--UPDATE dm.Dim_Product SET STATUS='inactive',Plan_Group='Serac' WHERE SKU_ID='1112004';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='serac' WHERE SKU_ID='1120001';
		--UPDATE dm.Dim_Product SET STATUS='inactive',Plan_Group='serac' WHERE SKU_ID='1120002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1120003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1120004';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1110001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1110002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1110003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='hamba' WHERE SKU_ID='1111001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='hamba' WHERE SKU_ID='1111002';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 2' WHERE SKU_ID='2100022';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 2' WHERE SKU_ID='2100023';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 2' WHERE SKU_ID='2100029';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 2' WHERE SKU_ID='2100030';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100004';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 4' WHERE SKU_ID='2100017';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 4' WHERE SKU_ID='2100018';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 4' WHERE SKU_ID='2100019';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 4' WHERE SKU_ID='2100020';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 4' WHERE SKU_ID='2100021';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 4' WHERE SKU_ID='2100009';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 4' WHERE SKU_ID='2100010';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 4' WHERE SKU_ID='2100011';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 4' WHERE SKU_ID='2100012';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Gasti' WHERE SKU_ID='1132002';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Gasti' WHERE SKU_ID='1132003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133004';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133005';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133006';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133007';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133008';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133009';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1133010';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131001';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131002';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131003';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131004';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131005';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131006';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131007';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1131008';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1130001';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1130002';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1130003';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1130004';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1150001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1150002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1150003';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1150004';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 2' WHERE SKU_ID='2100039';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 2' WHERE SKU_ID='2100040';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100031';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100032';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100033';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100034';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100035';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100036';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100037';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 5' WHERE SKU_ID='2100038';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1161001';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1161002';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1161003';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1160001';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1160002';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1160003';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 1' WHERE SKU_ID='2100059';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 1' WHERE SKU_ID='2100060';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 1' WHERE SKU_ID='2100061';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 1' WHERE SKU_ID='B-TBD-4';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 1' WHERE SKU_ID='B-TBD-5';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Line 1' WHERE SKU_ID='B-TBD-6';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Galdi' WHERE SKU_ID='1180001';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Serac' WHERE SKU_ID='1133011';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1120005';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1121001';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='1121002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Hamba' WHERE SKU_ID='1122001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Hamba' WHERE SKU_ID='1122002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Galdi' WHERE SKU_ID='1180003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Galdi' WHERE SKU_ID='1180004';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1181001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1181002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1182001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1182002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='1182003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Hamba' WHERE SKU_ID='1183001';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Hamba' WHERE SKU_ID='1183002';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 5' WHERE SKU_ID='2100071';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 3' WHERE SKU_ID='2100072';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Line 3' WHERE SKU_ID='2100073';
		--UPDATE dm.Dim_Product SET STATUS='Inactive',Plan_Group='Hamba' WHERE SKU_ID='LBZ-TBD';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Hamba' WHERE SKU_ID='1122003';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='NEW-1';
		--UPDATE dm.Dim_Product SET STATUS='Active',Plan_Group='Serac' WHERE SKU_ID='NEW-2';

		--update status
		UPDATE p
		SET p.Status = isnull(sku.Status,p.Status),
			p.Update_Time = getdate(),
			p.Update_By = '[ods].[ERP_SKU_List]'
		FROM [dm].[Dim_Product] p
		JOIN ODS.ods.ERP_SKU_List sku ON p.SKU_ID=sku.SKU_ID
		WHERE p.Status <> isnull(sku.Status,p.Status);

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
