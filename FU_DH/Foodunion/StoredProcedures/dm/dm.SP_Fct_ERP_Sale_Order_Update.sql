USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dm].[SP_Fct_ERP_Sale_Order_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--TRUNCATE TABLE  [dm].[Fct_ERP_Sale_Order] ;  -- ERP delete records

		UPDATE p
		SET p.[Bill_No] = c.[BillNo]
			,p.[Datekey] = convert(varchar(8),c.Date,112)
			,p.[Business_Type] = c.[BusinessType]
			,p.[Date] = c.[Date]
			,p.[Channel_ID] = dc.Channel_ID
			,p.[Customer_Name] = ISNULL(c.[Customer],'')
			,p.[Sale_Org] = c.[SaleOrg]
			,p.[Sale_Dept] = c.[SaleDept]
			,p.[Document_Status] = c.[DocumentStatus]
			,p.[Close_Status] = c.[CloseStatus]
			,p.[Note] = c.[Note]
			,p.[Store_Name] = c.[StoreName]
			,p.[Address] = c.[Address]
			,p.[Mobile] = c.[Mobile]
			,p.[Contact_Name] = c.[ContactName]
			,p.[FOC_Type] = c.[FOCType]
			,p.[Update_Time] = GETDATE() 
			,p.[Update_By] = @ProcName
		FROM [dm].[Fct_ERP_Sale_Order] p
		JOIN ODS.[ods].[ERP_Sale_Order] c
		ON p.[Sale_Order_ID] = c.[SaleOrderID]
		LEFT JOIN (SELECT ERP_Customer_Name,MAX(Channel_ID) AS Channel_ID FROM dm.Dim_Channel GROUP BY ERP_Customer_Name) dc 
		ON ISNULL(c.[Customer],'') = dc.ERP_Customer_Name
		;
	
		INSERT INTO [dm].[Fct_ERP_Sale_Order]
			( [Sale_Order_ID]
			  ,[Datekey]
			  ,[Bill_No]
			  ,[Bill_Type]
			  ,[Business_Type]
			  ,[Date]
			  ,[Channel_ID]
			  ,[Customer_Name]
			  ,[Sale_Org]
			  ,[Sale_Dept]
			  ,[Document_Status]
			  ,[Close_Status]
			  ,[Cancel_Status]
			  ,[Note]
			  ,[Store_Name]
			  ,[Address]
			  ,[Mobile]
			  ,[Contact_Name]
			  ,[FOC_Type]
			  ,[Create_Time]
			  ,[Create_By]
			  ,[Update_Time]
			  ,[Update_By]
			)
		SELECT 
			c.[SaleOrderID]
			,convert(varchar(8),c.Date,112)
			,c.[BillNo]
			,c.[BillType]
			,c.[BusinessType]
			,c.[Date]
			,dc.Channel_ID
			,ISNULL(c.[Customer],'')
			,c.[SaleOrg]
			,c.[SaleDept]
			,c.[DocumentStatus]
			,c.[CloseStatus]
			,c.[CancelStatus]
			,c.[Note]
			,c.[StoreName]
			,c.[Address]
			,c.[Mobile]
			,c.[ContactName]
			,c.[FOCType]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Sale_Order] c
		LEFT JOIN [dm].[Fct_ERP_Sale_Order] p
		ON p.[Sale_Order_ID] = c.[SaleOrderID]		
		LEFT JOIN (SELECT ERP_Customer_Name,MAX(Channel_ID) AS Channel_ID FROM dm.Dim_Channel GROUP BY ERP_Customer_Name) dc 
		ON ISNULL(c.[Customer],'') = dc.ERP_Customer_Name
		WHERE p.[Sale_Order_ID] IS NULL AND c.[BillNo] <>''
		;
		
		--ERP存在删除销售订单行为
		DELETE p
		FROM [dm].[Fct_ERP_Sale_Order] p
		LEFT JOIN ODS.[ods].[ERP_Sale_Order] c 
		ON p.[Sale_Order_ID] = c.[SaleOrderID]
		WHERE c.[SaleOrderID] IS NULL;


		--强制更新一些省份信息
		UPDATE dm.Fct_ERP_Sale_Order SET Province='陕西省',City='西安市'	WHERE address like '%新开门%' AND ISNULL(Province,'')<>'陕西省';
		UPDATE dm.Fct_ERP_Sale_Order SET Province='陕西省',City='西安市'	WHERE address like '%文景广场%' AND ISNULL(Province,'')<>'陕西省';
		UPDATE dm.Fct_ERP_Sale_Order SET Province='江苏省',City='南京市'	WHERE address like '%大厂葛关路%' AND ISNULL(Province,'')<>'江苏省';
		UPDATE dm.Fct_ERP_Sale_Order SET Province='江苏省',City='南京市'	WHERE address like '%尧佳路%' AND ISNULL(Province,'')<>'江苏省';



	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
