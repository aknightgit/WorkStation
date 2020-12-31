USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Fct_Qulouxia_BoxSlot_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Fct_Qulouxia_BoxSlot];   --07富友占用货道费明细
	INSERT INTO [dm].[Fct_Qulouxia_BoxSlot]
		  ([DateKey]
		  ,[Store_ID]
		  ,[Store_CODE]
		  ,[Store_Name]
		  ,[Next_Day_Booking]
		  ,[SKU_ID]
		  ,[SKU_CODE]
		  ,[SKU_Name]
		  ,[Category]
		  ,[Shelf_Life_D]
		  ,[Slot_QTY]
		  ,[Single_Widths]
		  ,[Total_Widths]
		  ,[Is_FU]
		  ,[Slot_Type]
		  ,[Slot_Charge]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By])
	SELECT  CONVERT(VARCHAR(10),[Date],112)
		  ,S.[Store_ID]
		  ,O.Store_ID AS CODE
		  ,S.[Store_Name]
		  ,O.[Next_Day_Booking]
		  ,P.[SKU_ID]
		  ,O.SKU_ID AS CODE
		  ,O.[SKU_Name]
		  ,O.[Category]
		  ,O.[Shelf_Life_D]
		  ,O.[QTY_Passage]
		  ,O.[Single_Widths]
		  ,O.[Total_Widths]
		  ,O.[Is_FU]
		  ,[Passage_Type]
		  ,[Passage_Charge]
		  ,GETDATE() AS [Create_Time]
		  ,'[dm].[SP_Fct_Qulouxia_GoodsPassage_Update]' AS [Create_By]
		  ,GETDATE() AS [Update_Time]
		  ,'[dm].[SP_Fct_Qulouxia_GoodsPassage_Update]' AS [Update_By]
	  FROM [ODS].[ods].[File_Qulouxia_GoodsPassage] O
	   LEFT JOIN [dm].[Dim_Store] S
	  ON O.[Store_ID]=S.Account_Store_Code
	  LEFT JOIN (SELECT * FROM [Foodunion].[dm].[Dim_Product_AccountCodeMapping] WHERE [Account]='ZBox') P
	  ON O.[SKU_ID]=P.SKU_Code
	  LEFT JOIN [dm].[Fct_Qulouxia_BoxSlot] D
	  ON CONVERT(VARCHAR(10),[Date],112)=[DateKey] AND S.[Store_ID]=D.Store_ID AND P.[SKU_ID]=D.SKU_ID AND O.SKU_ID=D.[SKU_CODE] AND O.[Shelf_Life_D]=D.[Shelf_Life_D]
	  WHERE D.Store_ID IS NULL ;

	--TRUNCATE TABLE [dm].[Fct_Qulouxia_BoxSlot_Charge];    --15富友占用货道费统计
	INSERT INTO [dm].[Fct_Qulouxia_BoxSlot_Charge] 
			([DateKey]
			,[Slot_Type]
			,[Slot_Charge]
			,[Total_Widths]
			,[Total_Slot_Charge]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
	SELECT  CONVERT(VARCHAR(10),O.[Date],112) [Date]
			,O.[Passage_Type]
			,O.[Passage_Charge]
			,O.[Total_Widths]
			,[Total_Passage_Charge]      
			,GETDATE() AS [Create_Time]
			,'[dm].[SP_Fct_Qulouxia_GoodsPassage_Update]' AS [Create_By]
			,GETDATE() AS [Update_Time]
			,'[dm].[SP_Fct_Qulouxia_GoodsPassage_Update]' AS [Update_By]
		FROM [ODS].[ods].[File_Qulouxia_GoodsPassage_Charge] O
		LEFT JOIN [dm].[Fct_Qulouxia_BoxSlot_Charge] D
		ON CONVERT(VARCHAR(10),O.[Date],112)=D.[DateKey] AND O.[Passage_Type]=D.Slot_Type
		WHERE D.[DateKey] IS NULL AND D.Slot_Type IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END
GO
