USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE  [dm].[SP_Fct_YH_Maco_Per_Store_Upsert]
as
begin
	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

--重新划分Sales Area
DROP TABLE IF EXISTS #Store;
SELECT [Store_ID]
      ,[Channel_Type]
      ,[Channel_ID]
      ,[Channel_Account]
      ,[Account_Short]
      ,[Account_Store_Code]
      ,[Store_Type]
      ,[Store_Province]
      ,[Store_Province_EN]
      ,[Province_Short]
      ,[Store_City]
      ,[Store_City_EN]
      ,[Store_Name]
      ,[Store_Address]
      ,[Store_Manager_NM]
      ,[Store_Manager_Phone]
      ,[Store_Manager_Mail]
      ,[Account_Store_Type]
      ,[Account_Store_Type_EN]
      ,[Account_Area_CN]
      ,[Account_Area_EN]
      ,CASE WHEN [Province_Short] IN ('黑龙江','吉林','辽宁') THEN '东北'  ELSE [Province_Short] END [Sales_Area_CN]
      ,[Target_Store_FL]
      ,[Level_Code]
      ,[PG_Store_FL]
      ,[SR_Level_1]
      ,[SR_Level_2]
      ,[Account_Store_Group]
      ,[Open_Date]
      ,[Status] INTO #STORE FROM [dm].[Dim_Store];

--计算上周数据
DROP TABLE IF EXISTS #Sales_Inventory;
SELECT Calendar_DT,[Store_ID],[SKU_ID],
       SUM([Sales_QTY]) AS [Sales_QTY],
	   SUM([Sales_AMT]) AS [Sales_AMT],
	   SUM([Inventory_QTY]) AS [Inventory_QTY],
	   SUM([QTY_W_1]) AS [QTY_W_1],
	   SUM([AMT_W_1]) AS [AMT_W_1] INTO #Sales_Inventory
FROM (
	SELECT Calendar_DT,[Store_ID],[SKU_ID],[Sales_QTY],[Sales_AMT],[Inventory_QTY],0 AS [QTY_W_1],0 AS [AMT_W_1] FROM [Foodunion].[dm].[Fct_YH_Sales_Inventory] YSI
	UNION ALL
	SELECT CONVERT(VARCHAR(10),DATEADD(DAY,7,CAST(CAST(Calendar_DT as char) AS DATE)),112) AS Calendar_DT,[Store_ID],[SKU_ID],0,0,0,[Sales_QTY],[Sales_AMT] 
	FROM [Foodunion].[dm].[Fct_YH_Sales_Inventory] YSI WHERE CONVERT(VARCHAR(10),DATEADD(DAY,7,CAST(CAST(Calendar_DT as char) AS DATE)),112)<= 
	                                                          (SELECT MAX(Calendar_DT) FROM [Foodunion].[dm].[Fct_YH_Sales_Inventory])) T
--WHERE LEFT(Calendar_DT,4)>=2020
WHERE Calendar_DT>=CONVERT(VARCHAR(10),DATEADD(DAY,-45,GETDATE()),112)
GROUP BY  Calendar_DT,[Store_ID],[SKU_ID]
	
DROP TABLE IF EXISTS #TEMP0;
SELECT C.Year,   --A
       C.Monthkey,  --B
	   C.Month_Name_Short,  --C
	   C.Week_of_Year, --D
	   C.Week_Nature_Str,  --E
	   CAST(CAST(SI.Calendar_DT AS CHAR) AS DATE) AS Calendar_DT,  --F
	   C.Week_Day_Name,  --G
	   CL.Channel_Name,  --H
	   S.Account_Area_CN,  --I
	   S.Store_Province,  --J
	   S.Province_Short,
	   S.Sales_Area_CN,  --K
	   '' AS IF_BLANK,  --L
	   S.Account_Store_Code,  --M
	   S.Store_Name,  --N
	   P.Brand_Name,  --O
	   P.Plant,  --P
	   P.Product_Sort,  --Q
	   P.Product_Category,  --R
       SI.[SKU_ID],  --S
	   P.SKU_Name,  --T
       P.SKU_Name_CN,  --U
	   P.Sale_Unit,  --V
       SI.[Sales_QTY],  --W
       SI.[Sales_AMT],  --X
	   SI.[QTY_W_1],
	   SI.[AMT_W_1],
       P.[Sale_Unit_Weight_KG]*SI.Sales_QTY AS Sales_Vol_KG,  --Y
	   SI.[Inventory_QTY],  --Z
	   P.[Sale_Unit_Weight_KG]*SI.[Inventory_QTY] AS Inventory_Vol_KG,  --AA
	   LEFT(SI.SKU_ID,7) AS Main_FU_SKU,  --AB
	   PP.Period AS Promo_Period,  --AC
	   --PP.Period+SI.SKU_ID+S.Sales_Area_CN,----------------------------------
	   CASE WHEN PPS.[R1]='全国' THEN 1 ELSE 0 END  AS Country_1st,  --AD
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS2.P2 THEN 1 ELSE 0 END  AS P2,  --AE
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS3.P3 THEN 1 ELSE 0 END  AS P3,  --AF
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS4.P4 THEN 1 ELSE 0 END  AS P4,  --AG
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS5.P5 THEN 1 ELSE 0 END  AS P5,  --AH
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS6.P6 THEN 1 ELSE 0 END  AS P6,  --AI
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS7.P7 THEN 1 ELSE 0 END  AS P7,  --AJ
	   CASE WHEN PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS8.P8 THEN 1 ELSE 0 END  AS P8,  --AK
	   CASE WHEN PPS.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END  AS Period_Promo_SKU,  --AL
	   P.Tax_Rate,--AM
	   CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_1/P1.[Qty_BaseInSale] ELSE PPS.FU_Sellin_Price_1 END FU_Sellin_Price_1,--AN
	   CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_2/P1.[Qty_BaseInSale] ELSE PPS.FU_Sellin_Price_2 END FU_Sellin_Price_2,--AO
	   VV.VIC_KG AS VIC_KG,--AP
	   VV.VLC_KG AS VLC_KG,--AQ
	   CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1) 
       ELSE PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END AS Initial_MACO,  --AR

	   (CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1) 
       ELSE PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END)/(PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)) AS [Initial_MACO%],  --AS

	   CASE WHEN (CASE WHEN PPS.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END)='N' THEN (CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1) 
                                                                                      ELSE PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END)
				  ELSE (CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1)
				             ELSE PPS.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END ) END AS Final_promo_MACO,  --AT

	   CASE WHEN (CASE WHEN PPS.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END)='N' THEN ((CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1) 
                                                                                            ELSE PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END)/(PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)))
            ELSE (CASE WHEN (CASE WHEN PPS.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END)='N' THEN (CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1) 
                                                                                      ELSE PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END)
				  ELSE (CASE WHEN LEN(SI.SKU_ID)>7 THEN PPS.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(VV.VIC_KG/PPS.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(VV.VLC_KG/PPS.FU_Sellin_Price_1)
				             ELSE PPS.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*VV.VIC_KG-P.Sale_Unit_Weight_KG*VV.VLC_KG END ) END)/(PPS.FU_Sellin_Price_1/(1+P.Tax_Rate)) END AS [Final_promo_MACO%],  --AU
	   CASE WHEN ISNULL(PPS.FU_Sellin_Price_1,0)=0 THEN 0 ELSE SI.[Sales_QTY]/PPS.FU_Sellin_Price_1 END AS TTL_value_Initial,  --AV
	   CASE WHEN ISNULL(PPS.FU_Sellin_Price_2,0)=0 THEN 0 ELSE SI.[Sales_QTY]/PPS.FU_Sellin_Price_2 END AS TTL_value_Promo,  --AW
	   CASE WHEN ISNULL(VV.VIC_KG,0)=0 THEN 0 ELSE P.[Sale_Unit_Weight_KG]*SI.[Sales_QTY]*VV.VIC_KG END AS VIC,  --AX
	   CASE WHEN ISNULL(VV.VLC_KG,0)=0 THEN 0 ELSE P.[Sale_Unit_Weight_KG]*SI.[Sales_QTY]*VV.VLC_KG END AS VLC,  --AY
	   ROW_NUMBER()OVER(PARTITION BY C.Monthkey,S.Account_Store_Code ORDER BY SI.Calendar_DT,SI.[SKU_ID]) RN
	 
  INTO #TEMP0    
  FROM #Sales_Inventory SI
  LEFT JOIN [dm].[Dim_Calendar] C
  ON SI.Calendar_DT=C.Datekey
  LEFT JOIN #STORE S
  ON SI.[Store_ID]=S.Store_ID
  LEFT JOIN [dm].[Dim_Channel] CL
  ON S.Channel_ID=CL.Channel_ID
  LEFT JOIN [dm].[Dim_Product] P
  ON SI.SKU_ID=P.SKU_ID
  LEFT JOIN [dm].[Fct_YH_Promo_Period] PP
  ON SI.[Calendar_DT]>=CONVERT(VARCHAR(10),PP.Start_Date,112) and SI.[Calendar_DT]<=CONVERT(VARCHAR(10),PP.End_Date,112)
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')=PPS.[P1] AND S.Sales_Area_CN=PPS.Promo_Region
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS2
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS2.P2
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS3
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS3.P3
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS4
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS4.P4
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS5
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS5.P5
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS6
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS6.P6
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS7
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS7.P7
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PPS8
  ON PP.Period+REPLACE(SI.SKU_ID,'_0','')+S.Sales_Area_CN=PPS8.P8
  LEFT JOIN [dm].[Dim_Product_VICVLC] VV 
  ON SI.SKU_ID=VV.SKU_ID AND VV.[Channel]='YH'
  LEFT JOIN  [dm].[Dim_Product] P1
  --ON CASE WHEN SI.SKU_ID LIKE '%_0%' THEN LEFT(SI.SKU_ID,7) ELSE SI.SKU_ID END =P1.SKU_ID
  ON CASE WHEN  CHARINDEX('_0',SI.SKU_ID)<>0 THEN LEFT(SI.SKU_ID,7) ELSE SI.SKU_ID END =P1.SKU_ID   --NOT LIKE '%_0'的需要修改成 AND CHARINDEX('_0',ka.SKU_ID)=0

  --WHERE [Calendar_DT]>='20200601' --AND SI.[Store_ID]='YH0009' --AND SI.SKU_ID='1171001'
  WHERE Calendar_DT>=CONVERT(VARCHAR(10),DATEADD(DAY,-30,GETDATE()),112)
  --ORDER BY SI.SKU_ID

  DROP TABLE IF EXISTS #TEMP;
  SELECT TEMP0.Year,   --A
       TEMP0.Monthkey,  --B
	   TEMP0.Month_Name_Short,  --C
	   TEMP0.Week_of_Year, --D
	   TEMP0.Week_Nature_Str,  --E
	   TEMP0.Calendar_DT,  --F
	   TEMP0.Week_Day_Name,  --G
	   TEMP0.Channel_Name,  --H
	   TEMP0.Account_Area_CN,  --I
	   TEMP0.Store_Province,  --J
	   TEMP0.[Province_Short],
	   TEMP0.Sales_Area_CN,  --K
	   TEMP0.IF_BLANK,  --L
	   TEMP0.Account_Store_Code,  --M
	   TEMP0.Store_Name,  --N
	   TEMP0.Brand_Name,  --O
	   TEMP0.Plant,  --P
	   TEMP0.Product_Sort,  --Q
	   TEMP0.Product_Category,  --R
       TEMP0.[SKU_ID],  --S
	   TEMP0.SKU_Name,  --T
       TEMP0.SKU_Name_CN,  --U
	   TEMP0.Sale_Unit,  --V
       TEMP0.[Sales_QTY],  --W
       TEMP0.[Sales_AMT],  --X
	   TEMP0.[QTY_W_1],
	   TEMP0.[AMT_W_1],
       TEMP0.Sales_Vol_KG,  --Y
	   TEMP0.[Inventory_QTY],  --Z
	   TEMP0.Inventory_Vol_KG,  --AA
	   TEMP0.Main_FU_SKU,  --AB
	   TEMP0.Promo_Period,  --AC
	   --PP.Period+SI.SKU_ID+S.Sales_Area_CN,----------------------------------
	   TEMP0.Country_1st,  --AD
	   TEMP0.P2,  --AE
	   TEMP0.P3,  --AF
	   TEMP0.P4,  --AG
	   TEMP0.P5,  --AH
	   TEMP0.P6,  --AI
	   TEMP0.P7,  --AJ
	   TEMP0.P8,  --AK
	   TEMP0.Period_Promo_SKU,  --AL
	   TEMP0.Tax_Rate,--AM
	   TEMP0.FU_Sellin_Price_1,--AN
	   TEMP0.FU_Sellin_Price_2,--AO
	   TEMP0.VIC_KG AS VIC_KG,--AP
	   TEMP0.VLC_KG AS VLC_KG,--AQ
	   CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1) 
       ELSE TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END AS Initial_MACO,  --AR

	   (CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1) 
       ELSE TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END)/(TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)) AS [Initial_MACO%],  --AS

	   CASE WHEN (CASE WHEN TEMP0.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END)='N' THEN (CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1) 
                                                                                      ELSE TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END)
				  ELSE (CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1)
				             ELSE TEMP0.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END ) END AS Final_promo_MACO,  --AT

	   CASE WHEN (CASE WHEN TEMP0.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END)='N' THEN ((CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1) 
                                                                                            ELSE TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END)/(TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)))
            ELSE (CASE WHEN (CASE WHEN TEMP0.FU_Sellin_Price_2 IS NULL THEN 'N' ELSE 'Y' END)='N' THEN (CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1) 
                                                                                      ELSE TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END)
				  ELSE (CASE WHEN LEN(TEMP0.SKU_ID)>7 THEN TEMP0.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*(TEMP0.VIC_KG/TEMP0.FU_Sellin_Price_1)-P.Sale_Unit_Weight_KG*(TEMP0.VLC_KG/TEMP0.FU_Sellin_Price_1)
				             ELSE TEMP0.FU_Sellin_Price_2/(1+P.Tax_Rate)-P.Sale_Unit_Weight_KG*TEMP0.VIC_KG-P.Sale_Unit_Weight_KG*TEMP0.VLC_KG END ) END)/(TEMP0.FU_Sellin_Price_1/(1+P.Tax_Rate)) END AS [Final_promo_MACO%],  --AU
	   CASE WHEN ISNULL(TEMP0.FU_Sellin_Price_1,0)=0 THEN 0 ELSE TEMP0.[Sales_QTY]*TEMP0.FU_Sellin_Price_1 END AS TTL_value_Initial,  --AV
	   CASE WHEN ISNULL(TEMP0.FU_Sellin_Price_2,0)=0 THEN 0 ELSE TEMP0.[Sales_QTY]*TEMP0.FU_Sellin_Price_2 END AS TTL_value_Promo,  --AW
	   TEMP0.VIC,  --AX
	   TEMP0.VLC  --AY
	 
  INTO #TEMP    
  FROM #TEMP0 AS TEMP0 
  LEFT JOIN [dm].[Dim_Product] P
  ON TEMP0.SKU_ID=P.SKU_ID 
  --LEFT JOIN [dm].[Fct_YH_Store_Target] T
  --ON TEMP0.Monthkey=T.[MonthKey] AND TEMP0.Account_Store_Code=T.[Store_Code] AND TEMP0.RN=1;
  ;

  DROP TABLE IF EXISTS #TEMP1;
  SELECT *,
         --=IFERROR(AV3/(1+AM3)-AX3-AY3,0)
		 TTL_value_Initial/(1+Tax_Rate)-VIC-VLC AS TTL_initial_MACO,  --AZ
         --=IFERROR(AZ3/(AV3/(1+AM3)),"")
		 CASE WHEN TTL_value_Initial/(1+Tax_Rate)=0 THEN 0 ELSE (TTL_value_Initial/(1+Tax_Rate)-VIC-VLC)/(TTL_value_Initial/(1+Tax_Rate)) END AS [Initial_MACO%2],   --BA
         --=IFERROR(IF(AL3="N",AZ3,AW3/(1+AM3)-AX3-AY3),0)	
		 CASE WHEN Period_Promo_SKU='N' THEN (TTL_value_Initial/(1+Tax_Rate)-VIC-VLC) ELSE (TTL_value_Promo/(1+Tax_Rate)-VIC-VLC) END AS TTL_final_promo_MACO,  --BB
		 --=IFERROR(IF(AL3="N",BA3,BB3/(AV3/(1+AM3))),"")
		 CASE WHEN TTL_value_Initial/(1+Tax_Rate)=0 THEN NULL ELSE 
		      CASE WHEN Period_Promo_SKU='N' THEN (CASE WHEN TTL_value_Initial/(1+Tax_Rate)=0 THEN 0 ELSE (TTL_value_Initial/(1+Tax_Rate)-VIC-VLC)/(TTL_value_Initial/(1+Tax_Rate)) END)
		      ELSE (CASE WHEN Period_Promo_SKU='N' THEN (TTL_value_Initial/(1+Tax_Rate)-VIC-VLC) ELSE (TTL_value_Promo/(1+Tax_Rate)-VIC-VLC) END)/(TTL_value_Initial/(1+Tax_Rate)) END END
			  AS [TTL_final_promo_MACO%],   --BC
----=IF([@[Period Promo SKU]]="N",[@[TTL value (FU Initial Sell in Price 1)]]/(1+[@VAT]),[@[TTL value (FU Promo Sell in Price)]]/(1+[@VAT]))
         CASE WHEN Period_Promo_SKU='N' THEN FU_Sellin_Price_1/(1+Tax_Rate) ELSE TTL_value_Promo/(1+Tax_Rate) END AS TTL_value_vat,     --BD
		 --=IF(RIGHT([@[Store_Name]],4)="配送中心","Y","N")
		 CASE WHEN RIGHT(Store_Name,4)='配送中心' THEN 'Y' ELSE 'N' END RDC,    --BE
		 --=IF(OR([@[Sales_Qty]]<=0,[@[Sales_AMT]]<=0),"Y","N")
		 CASE WHEN Sales_Qty<=0 OR Sales_AMT <=0 THEN 'Y' ELSE 'N' END AS Sales_amount_LT0   --BF
		 INTO #TEMP1
  FROM #TEMP 

  DROP TABLE IF EXISTS #TEMP2;
  SELECT TMP1.*,
        CASE WHEN [TTL_final_promo_MACO%]<0 THEN 'L1 ->   Maco% <0%'
		     WHEN [TTL_final_promo_MACO%]=0 THEN 'L2 ->   Maco% =0%'
			 WHEN [TTL_final_promo_MACO%]<0.1 THEN 'L3 ->   0% < Maco% < 10%'
			 WHEN [TTL_final_promo_MACO%]>=SL.Min_Value AND [TTL_final_promo_MACO%]<SL.Max_Value THEN SL.Level_Code 
			 WHEN [TTL_final_promo_MACO%]=1 THEN 'L8 ->   50% <= Maco% <= 100%'
			 ELSE 'FALSE' END AS Maco_Range,        --BG
        CASE WHEN Sales_amount_LT0='Y' THEN 0 
		     ELSE (CASE WHEN LEN(TMP1.SKU_ID)>7 THEN (CASE WHEN ((CASE WHEN ISNULL([Sales_QTY],0)=0 THEN 0 ELSE [Sales_AMT]/[Sales_QTY] END)*0.85- PS.Store_Cost)/PQ.Qty_BaseInSale<0
			                                          THEN ABS(((CASE WHEN ISNULL([Sales_QTY],0)=0 THEN 0 ELSE [Sales_AMT]/[Sales_QTY] END)*0.85- PS.Store_Cost)/PQ.Qty_BaseInSale)
												 ELSE ((CASE WHEN ISNULL([Sales_QTY],0)=0 THEN 0 ELSE [Sales_AMT]/[Sales_QTY] END)*0.85- PS.Store_Cost)/PQ.Qty_BaseInSale END
			                                     )
						ELSE ( (CASE WHEN (CASE WHEN ISNULL([Sales_QTY],0)=0 THEN 0 ELSE [Sales_AMT]/[Sales_QTY] END)*0.85-PS.Store_Cost<0
			                                          THEN ABS((CASE WHEN ISNULL([Sales_QTY],0)=0 THEN 0 ELSE [Sales_AMT]/[Sales_QTY] END)*0.85-PS.Store_Cost)
												 ELSE 0 END
			                                     ))
			       END ) END AS Actual_promo_deduct      --BH

		INTO #TEMP2
  FROM #TEMP1 TMP1
  LEFT JOIN [dm].[Dim_StoreLevels] SL
  ON [TTL_final_promo_MACO%]>=SL.Min_Value AND [TTL_final_promo_MACO%]<SL.Max_Value
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PS
  ON TMP1.Main_FU_SKU=PS.[FU_SKU] AND TMP1.Promo_Period=PS.Promo_Period AND TMP1.Sales_Area_CN=PS.Promo_Region
  LEFT JOIN [dm].[Dim_Product] PQ
  ON LEFT(TMP1.SKU_ID,7)=PQ.SKU_ID;


  DROP TABLE IF EXISTS #TEMP3;
  SELECT TMP2.*,
         CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END AS Actual_sellin_price2 ,   ----BI
		 --TMP2.[Sales_QTY]*(CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END)/(1+TMP2.Tax_Rate) AS Total_value_vat,   ----BJ
		 TMP2.[Sales_QTY]*TMP2.FU_Sellin_Price_1/(1+TMP2.Tax_Rate) AS Total_value_vat,   ----BJ
		 TMP2.[Sales_QTY]*(CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END)/(1+TMP2.Tax_Rate)-TMP2.VIC-TMP2.VLC AS Total_value_MACO,   ----BK
		 CASE WHEN TMP2.[Sales_QTY]*(CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END)/(1+TMP2.Tax_Rate)-TMP2.VIC-TMP2.VLC<0
		           AND TMP2.[Sales_QTY]*(CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END)/(1+TMP2.Tax_Rate)<0 
			  THEN  (CASE WHEN (TMP2.FU_Sellin_Price_1*TMP2.[Sales_QTY]/(1+TMP2.Tax_Rate))=0 THEN 0 
			              ELSE -(TMP2.[Sales_QTY]*(CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END)/(1+TMP2.Tax_Rate)-TMP2.VIC-TMP2.VLC)/(TMP2.FU_Sellin_Price_1*TMP2.[Sales_QTY]/(1+TMP2.Tax_Rate)) END)
			  ELSE (CASE WHEN (TMP2.FU_Sellin_Price_1*TMP2.[Sales_QTY]/(1+TMP2.Tax_Rate))=0 THEN 0 
			             ELSE (TMP2.[Sales_QTY]*(CASE WHEN Sales_amount_LT0='N' THEN TMP2.FU_Sellin_Price_1-Actual_promo_deduct ELSE 0 END)/(1+TMP2.Tax_Rate)-TMP2.VIC-TMP2.VLC)/(TMP2.FU_Sellin_Price_1*TMP2.[Sales_QTY]/(1+TMP2.Tax_Rate)) END)
			  END AS [Act_MACO%],  ----BL
         CASE WHEN LEN(TMP2.SKU_ID)>7 THEN PS.RSP/P.Qty_BaseInSale ELSE PS.RSP END AS RSP,  ----BM
		 (CASE WHEN LEN(TMP2.SKU_ID)>7 THEN PS.RSP/P.Qty_BaseInSale ELSE PS.RSP END)*TMP2.[Sales_QTY] AS RSP_VALUE,----BN
		 (CASE WHEN LEN(TMP2.SKU_ID)>7 THEN PS.RSP/P.Qty_BaseInSale ELSE PS.RSP END)*TMP2.[QTY_W_1] AS RSP_VALUE_W_1,----BN
		 CASE WHEN (CASE WHEN LEN(TMP2.SKU_ID)>7 THEN PS.RSP/P.Qty_BaseInSale ELSE PS.RSP END)=0 OR [Period_Promo_SKU]='N' THEN (CASE WHEN LEN(TMP2.SKU_ID)>7 THEN PS.RSP/P.Qty_BaseInSale ELSE PS.RSP END)
		      ELSE (TMP2.FU_Sellin_Price_1-TMP2.FU_Sellin_Price_2-PS.Store_Cost)/(-0.85) END AS Planned_Promo_Shelf_Price,  ----BO
		 CASE WHEN LEN(TMP2.SKU_ID)>7 THEN SR.Target_ASP_Max/P.Qty_BaseInSale
		      ELSE SR.Target_ASP_Max END AS Target_ASP_max,----BP
		 CASE WHEN LEN(TMP2.SKU_ID)>7 THEN SR.Target_ASP_Min/P.Qty_BaseInSale
		      ELSE SR.Target_ASP_Min END AS Target_ASP_Min, ----BQ
         (CASE WHEN LEN(TMP2.SKU_ID)>7 THEN P.Sale_Unit_Weight_KG/P.Qty_BaseInSale
		      ELSE P.Sale_Unit_Weight_KG END)*TMP2.Sales_QTY AS  TTL_sold_standard_kg  	 ----BR	 
  INTO  #TEMP3    
  FROM #TEMP2 TMP2
  LEFT JOIN [dm].[Fct_YH_Promo_Period_By_SKU] PS
  ON TMP2.Main_FU_SKU=PS.[FU_SKU] AND TMP2.Promo_Period=PS.Promo_Period AND TMP2.Sales_Area_CN=PS.Promo_Region
  LEFT JOIN [dm].[Dim_Product] P
  ON TMP2.SKU_ID=P.SKU_ID
  LEFT JOIN [dm].[Fct_YH_SKU_RSP] SR
  ON TMP2.Main_FU_SKU=SR.FU_SKU
  LEFT JOIN (SELECT [Account_Store_Code],[SKU_ID],Calendar_DT,Sales_AMT,Sales_Qty FROM #TEMP2) TMP22
  ON TMP2.Account_Store_Code=TMP22.Account_Store_Code AND TMP2.SKU_ID=TMP22.SKU_ID AND CAST(TMP2.Calendar_DT AS DATE)=DATEADD(DAY,7,CAST(TMP22.Calendar_DT AS DATE))

  --TRUNCATE TABLE [dm].[Fct_YH_Maco_Per_Store];
  DELETE FROM [dm].[Fct_YH_Maco_Per_Store] 
  WHERE [Datekey]>=CAST(DATEADD(DAY,-30,GETDATE()) AS DATE) OR [Datekey]=''  ;
INSERT INTO [dm].[Fct_YH_Maco_Per_Store]
      ([Year]
      ,[MonthKey]
      ,[Month_Name_Short]
      ,[Week_of_Year]
      ,[Week_Nature_Str]
      ,[Datekey]
      ,[Week_Day_Name]
      ,[Channel]
      ,[Region]
      ,[Province]
	  ,[Province_Short]
      ,[Sales_Area]
      ,[IF_BLANK]
      ,[Account_Store_Code]
      ,[Store_Name]
      ,[Brand_Name]
      ,[Plant]
      ,[Product_Sort]
      ,[Product_Category]
      ,[FU_SKU_ID]
      ,[SKU_Name]
      ,[SKU_Name_CN]
      ,[Sale_Unit]
      ,[Sales_Qty]
      ,[Sales_AMT]
	  ,[Store_Target]
      ,[Sales_Vol_KG]
      ,[Inventory_Qty]
      ,[Inventory_Vol_KG]
      ,[Main_FU_SKU]
      ,[Promo_Period]
      ,[Country_1st]
      ,[P_2nd]
      ,[P_3rd]
      ,[P_4th]
      ,[P_5th]
      ,[P_6th]
      ,[P_7th]
      ,[P_8th]
      ,[Period_Promo_SKU]
      ,[VAT]
      ,[Sellin_Initial_Price]
      ,[Sellin_Promo_Price]
      ,[Nomative_VIC_KG]
      ,[VLC_KG]
      ,[Initial_MACO]
      ,[Initial_MACO%]
      ,[Final_Promo_MACO]
      ,[Final_Promo_MACO%]
      ,[TTL_Value_Initial]
      ,[TTL_Value_Promo]
      ,[VIC]
      ,[VLC]
      ,[TTL_Initial_MACO]
      ,[TTL_Initial_MACO%]
      ,[TTL_Final_Promo_MACO]
      ,[TTL_Final_Promo_MACO%]
      ,[TTL_Value_Vat]
      ,[RDC]
      ,[Sales_Amount_LT0]
      ,[Maco_Range]
      ,[Actual_Promo_Deduct]
      ,[Actual_Sellin_price_2]
      ,[Total_Value_Vat]
      ,[Total_Value]
      ,[Act_MACO]
      ,[RSP]
	  ,RSP_VALUE
	  ,RSP_VALUE_W_1
      ,[Planned_Promo_Shelf_Price]
      ,[Target_ASP_Max]
      ,[Target_ASP_Min]
      ,[TTL_Sold_Standard]
	  ,Sales_AMT_W_1
	  ,Sales_Qty_W_1	  
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
   
   SELECT T3.Year,   --A
       T3.Monthkey,  --B
	   T3.Month_Name_Short,  --C
	   T3.Week_of_Year, --D
	   T3.Week_Nature_Str,  --E
	   T3.Calendar_DT,  --F
	   T3.Week_Day_Name,  --G
	   T3.Channel_Name,  --H
	   T3.Account_Area_CN,  --I
	   T3.Store_Province,  --J
	   T3.[Province_Short],
	   T3.Sales_Area_CN,  --K
	   T3.IF_BLANK,  --L
	   T3.Account_Store_Code,  --M
	   T3.Store_Name,  --N
	   T3.Brand_Name,  --O
	   T3.Plant,  --P
	   T3.Product_Sort,  --Q
	   T3.Product_Category,  --R
       T3.[SKU_ID],  --S
	   T3.SKU_Name,  --T
       T3.SKU_Name_CN,  --U
	   T3.Sale_Unit,  --V
       T3.[Sales_QTY],  --W
       T3.[Sales_AMT],  --X	 
	   0 TARGET,
       T3.Sales_Vol_KG,  --Y
	   T3.[Inventory_QTY],  --Z
	   T3.Inventory_Vol_KG,  --AA
	   T3.Main_FU_SKU,  --AB
	   T3.Promo_Period,  --AC	   
	   T3.Country_1st,  --AD
	   T3.P2,  --AE
	   T3.P3,  --AF
	   T3.P4,  --AG
	   T3.P5,  --AH
	   T3.P6,  --AI
	   T3.P7,  --AJ
	   T3.P8,  --AK
	   T3.Period_Promo_SKU,  --AL
	   T3.Tax_Rate,--AM
	   T3.FU_Sellin_Price_1,--AN
	   T3.FU_Sellin_Price_2,--AO
	   T3.VIC_KG,--AP
	   T3.VLC_KG,--AQ
	   Initial_MACO,  --AR
	   [Initial_MACO%],  --AS
	   Final_promo_MACO,  --AT
	   [Final_promo_MACO%],  --AU
	   TTL_value_Initial,  --AV
	   TTL_value_Promo,  --AW
	   T3.VIC,  --AX
	   T3.VLC,  --AY
	   TTL_initial_MACO,  --AZ
	   [Initial_MACO%2],   --BA
	   TTL_final_promo_MACO,  --BB
	   [TTL_final_promo_MACO%],   --BC
	   TTL_value_vat,    --BD
	   RDC,    --BE
	   Sales_amount_LT0,   --BF
	   Maco_Range,        --BG
	   Actual_promo_deduct,      --BH
	   Actual_sellin_price2 ,   ----BI
	   Total_value_vat,   ----BJ
	   Total_value_MACO,   ----BK
	   [Act_MACO%],  ----BL
	   RSP,  ----BM
	   CASE WHEN LEN(T3.[SKU_ID])>7 THEN 0 ELSE  RSP_VALUE END RSP_VALUE,----BN
	   CASE WHEN LEN(T3.[SKU_ID])>7 THEN 0 ELSE  RSP_VALUE_W_1 END RSP_VALUE_W_1,----
	   Planned_Promo_Shelf_Price,  ----BO
	   Target_ASP_max,----BP
	   Target_ASP_Min, ----BQ
	   TTL_sold_standard_kg,  	 ----BR	 
	   [AMT_W_1],
	   [QTY_W_1],	   
	   GETDATE() [Create_Time],
       '[dm].[SP_Fct_YH_Maco_Per_Store_Upsert]'[Create_By],
       GETDATE() [Update_Time],
       '[dm].[SP_Fct_YH_Maco_Per_Store_Upsert]'[Update_By]
   FROM #TEMP3 AS T3   
   WHERE T3.Calendar_DT>=CAST(DATEADD(DAY,-30,GETDATE()) AS DATE)

/*
   UNION ALL
   SELECT 
       C.[Year]
      ,T.[MonthKey]
      ,C.[Month_Name_Short]
      ,''[Week_of_Year]
      ,''[Week_Nature_Str]
      ,''[Datekey]
      ,''[Week_Day_Name]
      ,''[Channel]
      ,''[Region]
      ,''[Province]
	  ,[Province_Short]
      ,CASE WHEN [Province_Short] IN ('河北','天津','湖南') THEN [Province_Short] ELSE [Sales_Area_CN] END [Sales_Area]
      ,''[IF_BLANK]
      ,[Province_Short] [Account_Store_Code]
      ,''[Store_Name]
      ,''[Brand_Name]
      ,''[Plant]
      ,''[Product_Sort]
      ,''[Product_Category]
      ,''[FU_SKU_ID]
      ,''[SKU_Name]
      ,''[SKU_Name_CN]
      ,''[Sale_Unit]    
	  ,0[Sales_QTY]    
      ,0[Sales_AMT] 
	  ,SUM(T.[Target]) AS [Store_Target]
      ,0 [Sales_Vol_KG]
      ,0 [Inventory_Qty]
      ,0 [Inventory_Vol_KG]
      ,'' [Main_FU_SKU]
      ,'' [Promo_Period]
      ,'' [Country_1st]
      ,'' [P_2nd]
      ,'' [P_3rd]
      ,'' [P_4th]
      ,'' [P_5th]
      ,'' [P_6th]
      ,'' [P_7th]
      ,'' [P_8th]
      ,'' [Period_Promo_SKU]
      ,0 [VAT]
      ,0 [Sellin_Initial_Price]
      ,0 [Sellin_Promo_Price]
      ,0 [Nomative_VIC_KG]
      ,0 [VLC_KG]
      ,0 [Initial_MACO]
      ,0 [Initial_MACO%]
      ,0 [Final_Promo_MACO]
      ,0 [Final_Promo_MACO%]
      ,0 [TTL_Value_Initial]
      ,0 [TTL_Value_Promo]
      ,0 [VIC]
      ,0 [VLC]
      ,0 [TTL_Initial_MACO]
      ,0 [TTL_Initial_MACO%]
      ,0 [TTL_Final_Promo_MACO]
      ,0 [TTL_Final_Promo_MACO%]
      ,0 [TTL_Value_Vat]
      ,NULL [RDC]
      ,NULL [Sales_Amount_LT0]
      ,NULL [Maco_Range]
      ,0 [Actual_Promo_Deduct]
      ,0 [Actual_Sellin_price_2]
      ,0 [Total_Value_Vat]
      ,0 [Total_Value]
      ,0 [Act_MACO]
      ,0 [RSP]
	  ,0 RSP_VALUE
	  ,0 RSP_VALUE_W_1
      ,0 [Planned_Promo_Shelf_Price]
      ,0 [Target_ASP_Max]
      ,0 [Target_ASP_Min]
      ,0 [TTL_Sold_Standard]
	  ,0 Sales_AMT_W_1
	  ,0 Sales_Qty_W_1	   
	  ,GETDATE() [Create_Time]
       ,'[dm].[SP_Fct_YH_Maco_Per_Store_Upsert]'[Create_By]
       ,GETDATE() [Update_Time]
       ,'[dm].[SP_Fct_YH_Maco_Per_Store_Upsert]'[Update_By]
  FROM [Foodunion].[dm].[Fct_YH_Store_Target] T
  LEFT JOIN [dm].[Dim_Store] S
  ON T.[Store_Code]=S.Account_Store_Code
  LEFT JOIN (SELECT DISTINCT YEAR,Monthkey,Month_Name_Short FROM [dm].[Dim_Calendar]) C
   ON T.Monthkey=C.Monthkey 
   WHERE  T.[Target] IS NOT NULL
   GROUP BY  C.[Year]
      ,T.[MonthKey]
      ,C.[Month_Name_Short]     
	  ,[Province_Short]
      ,CASE WHEN [Province_Short] IN ('河北','天津','湖南') THEN [Province_Short] ELSE [Sales_Area_CN] END
  */
  ;


END TRY

	BEGIN CATCH
	SELECT @errmsg =  ERROR_MESSAGE();
	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;
	RAISERROR(@errmsg,16,1);
	END CATCH
END

GO
