USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_Sales_销售渠道客户达成日报_Update]
AS
BEGIN

	DELETE FROM rpt.[Sales_销售渠道客户达成日报] WHERE [Monthkey] = CONVERT(CHAR(6),DATEADD(DAY,-1,GETDATE()),112) ;

	INSERT INTO [rpt].[Sales_销售渠道客户达成日报]
           ([Monthkey]
           ,[Channel]
           ,[Customer]
           ,[Sales]
           ,[Data_Up_to]
		   ,[Is_UTD]
		   ,[Row_Attr]
           ,[Update_Time]
           ,[Update_By])
	SELECT CONVERT(CHAR(6),DATEADD(DAY,-1,GETDATE()),112) 
			, dc.Channel_Type as 'Channel'
			, dc.Channel_Name_Short AS 'Customer'
			, REPLACE(convert(varchar,ROUND(CAST(SUM(Amount) AS money),0),1),'.00','') AS Sales
			, MAX(c.Month_Name_Short)+'-'+CAST(MAX(c.Day_of_Month) AS VARCHAR(2)) AS 'Data_Up_to'  
			, CASE WHEN MAX(c.Datekey) = CONVERT(CHAR(8),DATEADD(DAY,-1,GETDATE()),112) THEN 1 ELSE 0 END
			, CASE WHEN dc.Channel_Type = 'YH' THEN 'bgcolor=#E6E6E6'
				WHEN dc.Channel_Type = 'Vanguard' THEN 'bgcolor=#E2EFDA' ELSE '' END
			, GETDATE()
			, '[rpt].[SP_Sales_销售渠道客户达成日报_Update]'
	FROM dm.Fct_Sales_SellOut_ByChannel so WITH(NOLOCK)  
	JOIN dm.Dim_Channel dc  WITH(NOLOCK) ON so.Channel_ID=dc.Channel_ID  
	JOIN dm.Dim_Calendar c WITH(NOLOCK) ON so.DateKey=c.Datekey  
	WHERE so.DateKey/100 = CONVERT(CHAR(6),DATEADD(DAY,-1,GETDATE()),112) 
	AND dc.Channel_Type IN ('YH','Vanguard','Distributor') 
	GROUP BY dc.Channel_Type
		, dc.Channel_Name_Short
	HAVING SUM(Amount) <> 0
	ORDER by 1 DESC 

END


GO
