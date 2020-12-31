USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dm].[SP_Dim_Product_Update]
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
			,p.[Bar_Code] = CASE WHEN ISNULL(p.[Bar_Code],'')='' THEN esl.Sale_Barcode ELSE p.[Bar_Code] END
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
			,p.[Sale_Unit_Weight_KG] = CASE WHEN (CASE WHEN ISNULL(p.[Qty_SaleInTray],0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) /p.[Qty_SaleInTray]  END ) <> 0 THEN
			   (CASE WHEN ISNULL(p.[Qty_SaleInTray],0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) /p.[Qty_SaleInTray]  END) ELSE  p.[Sale_Unit_Weight_KG] END  --金蝶系统更新Net Weight（与财务提供一致），根据New Weight 计算Sale Unit Weight   Justin 2020-05-06
			,p.Produce_Unit = CASE WHEN ISNULL(p.Produce_Unit,'')='' THEN esl.Produce_Unit ELSE p.Produce_Unit END
			,p.Shelf_Life_D = CASE WHEN CAST(esl.[LifeTime] AS REAL) = 0 THEN p.Shelf_Life_D ELSE CAST(esl.[LifeTime] AS REAL) END
			,p.Base_Unit_Weight_KG = CASE WHEN (CASE WHEN ISNULL(p.[Qty_BaseInTray],0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) /p.[Qty_BaseInTray]  END)<> 0 THEN
			 (CASE WHEN ISNULL(p.[Qty_BaseInTray],0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) /p.[Qty_BaseInTray]  END)  ELSE p.Base_Unit_Weight_KG END --金蝶系统更新Net Weight（与财务提供一致），根据New Weight 计算Base Unit Weight   Justin 2020-05-06
			--,p.Qty_BaseInSale = CAST(ucs.Convert_Rate AS INT)
			,p.Qty_BaseInSale = CAST(ucs.Convert_Rate AS decimal(18,0))      --转换QTY需要四舍五入   Justin 2020-05-08
			,p.Status = CASE WHEN esl.Status ='' THEN  p.Status ELSE esl.Status END
			,p.[Update_Time] = GETDATE() 
			,p.[Update_By] = 'SP_Dim_Product_Update'
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
			,[Bar_Code]
			,[Product_Type]
			,[Product_Sort]
			,[Plant]
			,[Brand_Name]
			,[Brand_Name_CN]
			,[Brand_IP]
			,[Sale_Scale]
			,[Base_Unit]
			,[Base_Unit_CN]
			,[Sale_Unit]
			,[Sale_Unit_CN]
			--,[Sale_Unit_Weight_KG]
			,[Produce_Unit]
			,[Shelf_Life_D]
			,[Base_Unit_Weight_KG]
			,[Qty_BaseInSale]
			,[Status]
			,[IsEnabled]
			,[Qty_ExtendPcs]
			,Product_Group
			,Product_Category
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By]
			)
		SELECT 
			esl.SKU_ID
			,isnull(esl.[SKU_Name_EN],esl.[SKU_Name])
			,esl.SKU_Name
			,esl.Sale_Barcode
			,'Dairy'
			,CASE WHEN esl.[Prod_Category] ='冷藏' OR CAST(esl.LifeTime AS decimal(5,2)) <=40 THEN 'Fresh' ELSE 'Ambient' END
			,esl.JV
			,CASE WHEN esl.Brand LIKE '%LAKTO%' OR esl.[SKU_Name_EN] LIKE '%LPP%' THEN 'LAKTO' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN 'Rasa' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BRAVO%' THEN 'BRAVO MAMA' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%Piens%' THEN 'Limbazu Piens' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SHAPETIME%' THEN 'SHAPETIME' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN 'Bonne Maman' 
				ELSE 'Others' END
			,CASE WHEN esl.Brand LIKE '%LAKTO%' OR esl.[SKU_Name_EN] LIKE '%LPP%' THEN '乐味可' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN '醇饴牧场' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BVM%' THEN '倍乐曼' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%LBZ%' THEN '蓝堡臻' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SPT%' THEN '形动力' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN '蓓妮妈妈' 
				ELSE '其他' END
			,CASE WHEN esl.Brand LIKE '%LAKTO%' AND esl.[SKU_Name_EN] LIKE '%LPP%' THEN 'PEPPA' 
				WHEN esl.Brand LIKE '%LAKTO%' AND esl.[SKU_Name_EN] LIKE '%LKR%' THEN 'RIKI' 
				WHEN esl.Brand LIKE '%Rasa%' OR esl.[SKU_Name_EN] LIKE '%Rasa%' THEN 'RSA' 
				WHEN esl.Brand LIKE '%BRAVO%' OR esl.[SKU_Name_EN] LIKE '%BVM%' THEN 'BVM' 
				WHEN esl.Brand LIKE '%Piens%' OR esl.[SKU_Name_EN] LIKE '%LBZ%' THEN 'LBZ' 
				WHEN esl.Brand LIKE '%SHAPETIME%' OR esl.[SKU_Name_EN] LIKE '%SPT%' THEN 'SPT' 
				WHEN esl.Brand LIKE '%MEJERIGAARDEN%' OR esl.[SKU_Name_EN] LIKE '%MEJERIGAARDEN%' THEN 'MEJERIGAARDEN' 
				WHEN esl.Brand LIKE '%Bonne%' OR esl.[SKU_Name_EN] LIKE '%Bonne%' THEN 'BonneMaman' 
				ELSE 'Others' END
			,esl.Sale_Scale
			,esl.Base_Unit_EN
			,esl.Base_Unit
			,esl.Sale_Unit_EN
			,esl.Sale_Unit
			,esl.Produce_Unit
			,CASE WHEN CAST(esl.[LifeTime] AS REAL) = 0 THEN NULL ELSE CAST(esl.[LifeTime] AS REAL) END AS [Shelf_Life_D]
			,CASE WHEN ISNULL( CAST(ucs.Convert_Rate AS INT),0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) / CAST(ucs.Convert_Rate AS INT) END  --金蝶系统更新Net Weight（与财务提供一致），根据New Weight 计算Base Unit Weight   Justin 2020-05-06
			,CAST(ucs.Convert_Rate AS INT)
			,esl.Status
			,1
			,1
			,CASE WHEN esl.[SKU_Name_EN] LIKE '%A DR YOG%' THEN 'YOGHURTS' 
				WHEN esl.[SKU_Name_EN] LIKE '%F DR YOG%' THEN 'YOGHURTS' 
				WHEN esl.[SKU_Name_EN] LIKE '%F SP YOG%' THEN 'YOGHURTS' 
				WHEN esl.[SKU_Name_EN] LIKE '%A SP YOG%' THEN 'YOGHURTS' 
				WHEN esl.[SKU_Name_EN] LIKE '%MIL%' THEN 'Milk' 
				END
			,CASE WHEN esl.[SKU_Name_EN] LIKE '%A DR YOG%' THEN 'A DR Yogurt' 
				WHEN esl.[SKU_Name_EN] LIKE '%F DR YOG%' THEN 'F DR Yogurt' 
				WHEN esl.[SKU_Name_EN] LIKE '%F SP YOG%' THEN 'F SP Yogurt' 
				WHEN esl.[SKU_Name_EN] LIKE '%A SP YOG%' THEN 'A SP Yogurt' 
				WHEN esl.[SKU_Name_EN] LIKE '%A PU Mil%' THEN 'A PU Milk' 
				END
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
		set p.Qty_BaseInSale =cast(uc.Convert_Rate AS decimal(18,0))--cast(uc.Convert_Rate as int)  --转换QTY需要四舍五入   Justin 2020-05-08
		from [dm].[Dim_Product] p
		join dm.Dim_ERP_Unit_ConvertRate uc 
		on p.Base_Unit=uc.To_Unit and p.Sale_Unit=uc.From_Unit
		where uc.Convert_Rate<>p.Qty_BaseInSale;

		update p
		set p.Qty_SaleInTray = cast(uc.Convert_Rate AS decimal(18,0)) --cast(uc.Convert_Rate as int)  --转换QTY需要四舍五入   Justin 2020-05-08
		from [dm].[Dim_Product] p
		join dm.Dim_ERP_Unit_ConvertRate uc 
		on ISNULL(p.Sale_Unit,p.Sale_Unit_CN)=uc.To_Unit and p.Produce_Unit=uc.From_Unit
		where uc.Convert_Rate<>ISNULL(p.Qty_SaleInTray,0);

		update p
		set p.Qty_BaseInTray = cast(uc.Convert_Rate AS decimal(18,0)) --cast(uc.Convert_Rate as int) --转换QTY需要四舍五入   Justin 2020-05-08
		from [dm].[Dim_Product] p
		join dm.Dim_ERP_Unit_ConvertRate uc 
		on ISNULL(p.Base_Unit,p.Base_Unit_CN)=uc.To_Unit and p.Produce_Unit=uc.From_Unit
		where uc.Convert_Rate<>ISNULL(p.Qty_BaseInTray,0);

		update p
		set p.Sale_Unit_Weight_KG = CASE WHEN (CASE WHEN ISNULL(p.[Qty_SaleInTray],0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) /CAST(p.[Qty_SaleInTray] AS INT) END)<>0 THEN 
		    (CASE WHEN ISNULL(p.[Qty_SaleInTray],0)=0 THEN NULL ELSE CAST(esl.Net_Weight AS FLOAT) /CAST(p.[Qty_SaleInTray] AS INT)  END ) ELSE p.Sale_Unit_Weight_KG END    --根据New Weight 计算   Justin 2020-05-06
		--p.Base_Unit_Weight_KG * p.Qty_BaseInSale 
			,p.Sale_Unit_Volumn_L = p.Base_Unit_Volumn_L * p.Qty_BaseInSale
		from [dm].[Dim_Product] p
		LEFT JOIN ODS.[ods].[ERP_SKU_List] esl
		ON p.SKU_ID = esl.SKU_ID 
		where CAST(esl.Net_Weight AS FLOAT) * p.[Qty_SaleInTray] is not null ;
		--order by 1

		--update  [dm].[Dim_Product]  set Sale_Unit_Weight_KG=0.1*4,Sale_Unit_Volumn_L=0.0960*4,Qty_BaseInSale=4 where SKU_ID='2100073'
		update [dm].[Dim_Product]  set --Sale_Unit_Weight_KG=0.1,
		       Sale_Unit_Volumn_L=0.120,Qty_SaleInTray=24 where SKU_ID='2100073_0'
		--update  [dm].[Dim_Product]  set Sale_Unit_Weight_KG=0.1*4,Sale_Unit_Volumn_L=0.0960*4,Qty_BaseInSale=4 where SKU_ID='2100072'
		update [dm].[Dim_Product]  set --Sale_Unit_Weight_KG=0.1,
		       Sale_Unit_Volumn_L=0.120,Qty_SaleInTray=24 where SKU_ID='2100072_0'
		update [dm].[Dim_Product] set --Sale_Unit_Weight_KG=0.2*4,
		       Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100031'
		update [dm].[Dim_Product] set --Sale_Unit_Weight_KG=0.2*4,
		       Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100032'
		update [dm].[Dim_Product] set --Sale_Unit_Weight_KG=0.2*4,
		       Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100033'
		update [dm].[Dim_Product] set --Sale_Unit_Weight_KG=0.2*4,
		       Sale_Unit_Volumn_L=0.19*4,Qty_BaseInSale=4 where SKU_ID='2100034'

		update dm.Dim_Product 
		set Base_Unit_Volumn_L=0.2
		where SKU_Name like '%200ml%' and Base_Unit_Volumn_L is null
		update dm.Dim_Product 
		set Base_Unit_Volumn_L=0.19
		where SKU_Name like '%190ml%' and Base_Unit_Volumn_L is null
		update dm.Dim_Product 
		set Base_Unit_Volumn_L=0.1
		where SKU_Name like '%100ml%' and Base_Unit_Volumn_L is null;

		UPDATE [dm].[Dim_Product] 
		SET Base_Unit='Cluster',Base_Unit_CN='包',--Base_Unit_Weight_KG=0.30,  Sale_Unit_Weight_KG=0.3,
		    Sale_Unit='Cluster',Sale_Unit_CN='包'
			,Qty_BaseInSale=1,Qty_SaleInTray=8,Qty_BaseInTray=8,Qty_ExtendPcs=6
		WHERE SKU_ID IN ('2100083');

		UPDATE [dm].[Dim_Product] 
		SET --Sale_Unit_Weight_KG=2.784/12,Base_Unit_Weight_KG=2.784/12,
		    Qty_BaseInSale=1,Qty_SaleInTray=12,Qty_BaseInTray=12,Package_Category='CUP',Package='FFS CUP'
		WHERE SKU_ID IN ('2100084','2100085','2100086');

		UPDATE [dm].[Dim_Product] 
		SET --Sale_Unit_Weight_KG=4.730/6,Base_Unit_Weight_KG=4.730/24,
		    Qty_BaseInSale=4,Qty_SaleInTray=6,Qty_BaseInTray=24,Qty_ExtendPcs=1
		,Sale_Unit_Volumn_L=0.76,Base_Unit_Volumn_L=0.19
		,Base_Unit='Pcs',Base_Unit_CN='Pcs'
		WHERE SKU_ID IN ('2100079','2100080');
		
		UPDATE [dm].[Dim_Product] SET Produce_Unit='Tray24',Qty_SaleInTray=24,Qty_BaseInTray=24,Qty_ExtendPcs=1
		,Sale_Scale='100g+25g',Plan_Group='Line 3',Product_Group='YOGHURTS',Product_Category='F SP Yogurt',Product_Category_CN='新鲜酸奶-勺食'
		WHERE SKU_ID IN ('2100087','2100088');

		UPDATE [dm].[Dim_Product] SET Produce_Unit='Tray24',Qty_SaleInTray=24,Qty_BaseInTray=24,Qty_ExtendPcs=1
		,Sale_Scale='70g',Plan_Group='Line 4',Product_Group='SPREAD CHEESE',Product_Category='F SP Cheese',Product_Category_CN='鲜酪'
		WHERE SKU_ID IN ('2100089','2100090');

	

		--update status
		UPDATE p
		SET p.Status = isnull(sku.Status,p.Status),
			p.Update_Time = getdate(),
			p.Update_By = '[ods].[ERP_SKU_List]'
		FROM [dm].[Dim_Product] p
		JOIN ODS.ods.ERP_SKU_List sku ON p.SKU_ID=sku.SKU_ID
		WHERE p.Status <> isnull(sku.Status,p.Status);

		--Inactive child as Parent
		UPDATE p
		SET p.Status = isnull(p2.Status,p.Status),
			p.Update_Time = getdate(),
			p.Update_By = 'Inactive as parent'
		FROM [dm].[Dim_Product] p
		JOIN [dm].[Dim_Product] p2 on p.SKU_ID+'_0' = p2.SKU_ID
		WHERE p.Status <> p2.Status;

		--分类
		UPDATE [dm].[Dim_Product] SET Product_Group='YOGHURTS',Product_Category='A SP Yogurt',Product_Category_CN='常温酸奶-勺食',Plan_Group='Hamba' 
		WHERE SKU_Name LIKE '%A SP YOG%' AND isnull(Product_Category,'') <> 'A SP Yogurt';
		UPDATE [dm].[Dim_Product] SET Product_Group='YOGHURTS',Product_Category='F SP Yogurt',Product_Category_CN='新鲜酸奶-勺食' 
		WHERE SKU_Name LIKE '%F SP YOG%' AND SKU_Name NOT LIKE '%DC%' AND isnull(Product_Category,'') <> 'F SP Yogurt'
		UPDATE [dm].[Dim_Product] SET Product_Sort='Fresh',Product_Group='SPREAD CHEESE',Product_Category='F SP Cheese',Product_Category_CN='鲜酪' 
		WHERE SKU_Name LIKE '%F FS CHE%' AND isnull(Product_Category,'') <> 'F SP Cheese'
		UPDATE [dm].[Dim_Product] SET Product_Sort='Ambient',Product_Group='MILK',Product_Category='A NE Milk',Product_Category_CN='营养强化奶',Plan_Group='Serac',
		Package_Category='BOTTLE',Package='HDPE BOTTLE'
		WHERE SKU_Name LIKE '%A FL MIL%' AND isnull(Product_Category,'') <> 'A NE Milk'

		--增加Tax Rate 更新
		UPDATE D SET D.Tax_Rate=O.Tax_Rate/100
		FROM [dm].[Dim_Product] D
		LEFT JOIN [ODS].[ods].[ERP_SKU_List] O
		ON D.SKU_ID=O.SKU_ID;

		--更新 Net_Weight_KG
		UPDATE D SET D.Net_Weight_KG=O.[Weight_kg]
		FROM [dm].[Dim_Product] D
		LEFT JOIN [ODS].[ods].[File_Product_Database] O
		ON D.SKU_ID=O.[SKU_ID];

		--更新 Tax_Rate
		 UPDATE P SET P.Tax_Rate=MP.Tax_Rate
		  FROM [Foodunion].[dm].[Dim_Product] P
		  LEFT JOIN (
		  SELECT DISTINCT [SKU_ID],[Tax_Rate]
		  FROM [Foodunion].[dm].[Dim_Product]
		  WHERE Tax_Rate IS NOT NULL) MP
		  ON LEFT(P.SKU_ID,7)=MP.SKU_ID
		  WHERE P.Tax_Rate IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
