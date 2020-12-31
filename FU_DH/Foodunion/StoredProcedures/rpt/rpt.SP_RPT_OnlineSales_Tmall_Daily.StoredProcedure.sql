USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_OnlineSales_Tmall_Daily]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [rpt].[SP_RPT_OnlineSales_Tmall_Daily]
AS
BEGIN 
	
	--select * from ODS.[ods].[File_Tmall_DailyinAll]
	SELECT CAST([ͳ������] AS date) Date,
		CONVERT(VARCHAR(8),cast([ͳ������] as date),112) [ͳ������],
		[�콢��],
		[֧����������],
		CAST(REPLACE([�µ����],',','') AS decimal(18,9)) [�µ����],
		CAST(REPLACE([֧�����],',','') AS decimal(18,9)) [֧�����],
		CAST(REPLACE([�ɹ��˿���],',','') AS decimal(18,9)) [�ɹ��˿���],
		CAST(REPLACE([֧���Ӷ�����],',','') AS decimal(18,9)) [֧���Ӷ�����],
		CAST(REPLACE([�µ�����],',','') AS decimal(18,9)) [�µ�����],
		CAST(REPLACE([֧������],',','') AS decimal(18,9)) [֧������],
		CAST(REPLACE([�͵���],',','') AS decimal(18,9)) [�͵���],
		CAST(REPLACE([֧����Ʒ��],',','') AS decimal(18,9)) [֧����Ʒ��],
		[�ÿ���]
		,[�����]
		,[��Ʒ�����]
		,[ƽ��ͣ��ʱ��]
		,[��Ʒ�ղ������]
		,[�ӹ�����]
		,[֧�������]
		,[�µ�ת����]
		,[֧��ת����]
		,[�Ϸÿ���]
		,[�·ÿ���]
		,[֧���������]
		,[ֱͨ������]
		,[��ʯչλ����]
		,[������]
		,[���հ�����]
		,[����������]
		,[���Ͱ�����]
		,[ǩ�ճɹ�������]
		,[ƽ��֧��_ǩ��ʱ��(��)]
		,[�µ�-֧��ת����]
		,[�����ղ������]
	FROM ODS.[ods].[File_Tmall_DailyinAll]
	WHERE [ͳ������]>='2019-05-25'

	UNION

	SELECT [Payment_Date]
	,CONVERT(VARCHAR(8),[Payment_Date],112) Datekey
      ,[Platform_Name]
      ,[Order_Count]
      ,CAST(REPLACE([Order_Amount],',','') AS decimal(18,9)) [Order_Amount]
      ,CAST(REPLACE([Payment_Amount],',','') AS decimal(18,9)) [Payment_Amount]
      ,CAST(REPLACE([Refund_Amount],',','') AS decimal(18,9)) [Refund_Amount]
      ,[SubOrder_Count]
      ,[Orderitem_Qty]
      ,[Payitem_Qty]
      ,CAST(REPLACE([PerOrderAmount],',','') AS decimal(18,9)) [PerOrderAmount]
      ,[SkuCount]
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	FROM ODS.[ods].[File_TmallFlag_DailyPayment]
	where [Payment_Date]<='2019-05-24'
	ORDER by 1;

END

GO
