USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [rpt].[SP_O2O_Order_Base_info_Delivery_Update]
AS 
BEGIN

DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

---------------------创建数字临时表
DROP TABLE IF EXISTS #Number
CREATE TABLE #Number
(id INT)

DECLARE @Number INT
SET @Number = 1
WHILE (@Number<1000)
BEGIN

INSERT INTO #Number
SELECT @Number

SET @Number+=1

END

TRUNCATE TABLE [Foodunion].[rpt].[O2O_Order_Base_info_Delivery]

INSERT INTO [Foodunion].[rpt].[O2O_Order_Base_info_Delivery]
(
		[Datekey]
      ,[Order_ID]
      ,[Order_No]
      ,[Order_Source]
      ,[Order_Type]
      ,[Fan_id]
      ,[KOL]
      ,[Fans_Nickname]
      ,[Open_id]
      ,[Union_id]
      ,[is_cycle]
      ,[Order_Status]
      ,[Order_Status_Str]
      ,[Pay_Status]
      ,[Pay_Type_Str]
      ,[Pay_Type]
      ,[Order_Amount]
      ,[Shipping_Amount]
      ,[Pay_Amount]
      ,[Refund_Amount]
      ,[Order_Create_Time]
      ,[Expired_Time]
      ,[Pay_Time]
      ,[Refund_Time]
      ,[Refund_State]
      ,[Close_Type]
      ,[Express_Type]
      ,[Consign_Time]
      ,[Offline_id]
      ,[Consign_Store]
      ,[Buyer_Mobile]
      ,[Receiver_Name]
      ,[Receiver_Mobile]
      ,[Delivery_Province]
      ,[Delivery_City]
      ,[Delivery_District]
      ,[Delivery_Address]
      ,[Fenxiao_Employee_id]
      ,[Fenxiao_Mobile]
      ,[Operator_Employee_id]
      ,[Remark]
      ,[is_deleted]
      ,[delivery_cnt]
      ,[SubscriptionType]
      ,[Delivery_Seq]
      ,[DeliveryDate]
      ,[DeliveryDateKey]
      ,[Delivery_Amt]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
)
SELECT [Datekey]
      ,[Order_ID]
      ,[Order_No]
      ,[Order_Source]
      ,[Order_Type]
      ,[Fan_id]
      ,[KOL]
      ,[Fans_Nickname]
      ,[Open_id]
      ,[Union_id]
      ,[is_cycle]
      ,[Order_Status]
      ,[Order_Status_Str]
      ,[Pay_Status]
      ,[Pay_Type_Str]
      ,[Pay_Type]
      ,[Order_Amount]
      ,[Shipping_Amount]
      ,[Pay_Amount]
      ,[Refund_Amount]
      ,[Order_Create_Time]
      ,[Expired_Time]
      ,[Pay_Time]
      ,[Refund_Time]
      ,[Refund_State]
      ,[Close_Type]
      ,[Express_Type]
      ,[Consign_Time]
      ,[Offline_id]
      ,[Consign_Store]
      ,[Buyer_Mobile]
      ,[Receiver_Name]
      ,[Receiver_Mobile]
      ,[Delivery_Province]
      ,[Delivery_City]
      ,[Delivery_District]
      ,[Delivery_Address]
      ,[Fenxiao_Employee_id]
      ,[Fenxiao_Mobile]
      ,[Operator_Employee_id]
      ,[Remark]
      ,[is_deleted]
	  ,delivery_cnt 
	  ,SubscriptionType  
	  ,Delivery_Seq
	  ,CASE WHEN is_cycle = 1 THEN  DATEADD(DAY,Delivery_Seq*7-7,CAST(Date_Str AS DATE)) ELSE Date_Str END AS DeliveryDate
	  ,CASE WHEN is_cycle = 1 THEN CONVERT(VARCHAR(8),DATEADD(DAY,Delivery_Seq*7-7+CASE WHEN Day_of_Week<=4 THEN 4-Day_of_Week ELSE 11-Day_of_Week END,CAST(Date_Str AS DATE)),112) ELSE CONVERT(VARCHAR(8),[Consign_Time],112) END AS DeliveryDateKey
	  ,Pay_Amount/delivery_cnt AS Delivery_Amt
	  ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
FROM(
	SELECT bi.[Datekey]
	      ,bi.[Order_ID]
	      ,bi.[Order_No]
	      ,bi.[Order_Source]
	      ,bi.[Order_Type]
	      ,bi.[Fan_id]
	      ,bi.[KOL]
	      ,bi.[Fans_Nickname]
	      ,bi.[Open_id]
	      ,bi.[Union_id]
	      ,bi.[is_cycle]
	      ,bi.[Order_Status]
	      ,bi.[Order_Status_Str]
	      ,bi.[Pay_Status]
	      ,bi.[Pay_Type_Str]
	      ,bi.[Pay_Type]
	      ,bi.[Order_Amount]
	      ,bi.[Shipping_Amount]
	      ,bi.[Pay_Amount]
	      ,bi.[Refund_Amount]
	      ,bi.[Order_Create_Time]
	      ,bi.[Expired_Time]
	      ,bi.[Pay_Time]
	      ,bi.[Refund_Time]
	      ,bi.[Refund_State]
	      ,bi.[Close_Type]
	      ,bi.[Express_Type]
	      ,bi.[Consign_Time]
	      ,bi.[Offline_id]
	      ,bi.[Consign_Store]
	      ,bi.[Buyer_Mobile]
	      ,bi.[Receiver_Name]
	      ,bi.[Receiver_Mobile]
	      ,bi.[Delivery_Province]
	      ,bi.[Delivery_City]
	      ,bi.[Delivery_District]
	      ,bi.[Delivery_Address]
	      ,bi.[Fenxiao_Employee_id]
	      ,bi.[Fenxiao_Mobile]
	      ,bi.[Operator_Employee_id]
	      ,bi.[Remark]
	      ,bi.[is_deleted]
		  ,CASE WHEN is_cycle = 1 THEN  di.delivery_cnt ELSE 1 END AS delivery_cnt
		  ,di.SubscriptionType 
		  ,ROW_NUMBER() OVER(PARTITION BY bi.Order_ID ORDER BY bi.Order_ID) AS Delivery_Seq
		  ,cal.Date_Str
		  ,cal.Day_of_Week
	FROM [dm].[Fct_O2O_Order_Base_info] bi 
	LEFT JOIN (SELECT DISTINCT Order_id,delivery_cnt,SubscriptionType FROM [dm].[Fct_O2O_Order_Detail_info]) di on bi.Order_ID = di.Order_ID
	LEFT JOIN #Number num ON 1=1 AND CASE WHEN is_cycle = 1 THEN  di.delivery_cnt ELSE 1 END>=num.id 
	LEFT JOIN dm.Dim_Calendar cal ON bi.Datekey = cal.Datekey
	WHERE /*is_cycle = 1  and*/ Order_Status_Str <> '已关闭'
) OS




END TRY
BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	RAISERROR(@errmsg,16,1);

END CATCH

END
GO
