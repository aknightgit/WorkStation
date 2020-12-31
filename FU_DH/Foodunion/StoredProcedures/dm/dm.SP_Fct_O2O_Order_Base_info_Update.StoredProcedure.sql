USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_O2O_Order_Base_info_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dm].[SP_Fct_O2O_Order_Base_info_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

/*
*/
	DROP TABLE IF EXISTS #Fans_Order_cnt
	SELECT outer_user_id
		  ,COUNT(DISTINCT order_no) AS Fans_Orders_Cnt
	INTO #Fans_Order_cnt
	FROM ODS.ods.SCRM_order_base_info
	WHERE ISNULL(outer_user_id,'') <> ''
	GROUP BY outer_user_id


	--new table [dm].[Fct_O2O_Order_Base_info];
	TRUNCATE TABLE [dm].[Fct_O2O_Order_Base_info];
	INSERT INTO [dm].[Fct_O2O_Order_Base_info]
           ([Datekey]
           ,[Order_ID]
           ,[Order_No]
           ,[Order_Source]
           ,[Order_Type]
           ,[Fan_id]
           ,[KOL]
           ,[Fans_Nickname]
           ,[Open_id]
		   ,[Fans_Orders_Cnt]
		   ,[Fans_Order_Cnt_Grp]
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
		   ,[Order_Close_Time]
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
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
     SELECT 
		CAST(CONVERT(VARCHAR(8),i.order_create_time,112) AS INT) AS Datekey,
		i.id as Order_ID,
		i.order_no as Order_No,
		CASE i.source WHEN 1 THEN '�����̳��̳�' WHEN 2 THEN '΢�̳�' WHEN 3 THEN '��è' WHEN 4 THEN '����' 
			WHEN 5 THEN '�����̳�С����' WHEN 6 THEN '�����̳�' WHEN 7 THEN '����ͨ' WHEN 8 THEN 'ƴ���' END as Order_Source,
		CASE i.type 
		 WHEN 0 THEN '��ͨ����' WHEN 1 THEN '���񶩵�' WHEN 2 THEN '����' WHEN 3 THEN '�����ɹ���' WHEN 4 THEN '��Ʒ' WHEN 5 THEN '��Ը��' 
		 WHEN 6 THEN '��ά�붩��' WHEN 7 THEN '�ϲ�������' WHEN 8 THEN '1��Ǯʵ����֤' WHEN 9 THEN 'Ʒ��' WHEN 10 THEN 'ƴ��' WHEN 15 THEN '����' 
		 WHEN 35 THEN '�Ƶ�' WHEN 40 THEN '����' WHEN 41 THEN '��ʳ���' WHEN 46 THEN '������' WHEN 51 THEN 'ȫԱ����' WHEN 61 THEN '��������̨����' 
		 WHEN 71 THEN '��ҵԤԼ��' WHEN 72 THEN '��ҵ����' WHEN 75 THEN '֪ʶ����' WHEN 81 THEN '��Ʒ��' WHEN 100 THEN '����' END as Order_Type,	
		fu.Fan_id,
		fu.KOL,
		i.Fans_Nickname,
		i.outer_user_id as Open_id,
		foc.Fans_Orders_Cnt,
		CASE WHEN foc.Fans_Orders_Cnt < 3 THEN '0~2 Orders Totally' 
			WHEN foc.Fans_Orders_Cnt >= 3 THEN '>=3 Orders Totally' 
			ELSE 'Unidentified' END AS Fans_Order_Cnt_Grp,
		i.wx_union_id as Union_id,
		CASE WHEN cy.order_id IS NULL AND i.cycle = 0 THEN 0 ELSE 1 END as is_cycle,
		i.order_status as Order_Status,
		i.order_status_str as Order_Status_Str,
		CASE  i.pay_status WHEN 1 THEN '������' WHEN 2 THEN '��֧��' END as Pay_Status,
		i.Pay_Type_Str,
		CASE i.pay_type 
		 WHEN 0 THEN 'δ֧��' WHEN 1 THEN '΢������֧��' WHEN 2 THEN '֧����wap' WHEN 3 THEN '֧����wap' WHEN 5 THEN '�Ƹ�ͨ' 
		 WHEN 7 THEN '����' WHEN 8 THEN '��������' WHEN 9 THEN '��������' WHEN 10 THEN '���˺Ŵ���' WHEN 11 THEN '����ģʽ' 
		 WHEN 12 THEN '�ٸ���' WHEN 13 THEN 'sdk֧��' WHEN 14 THEN '�ϲ�������' WHEN 15 THEN '��Ʒ' WHEN 16 THEN '�Żݶһ�' 
		 WHEN 17 THEN '�Զ�������' WHEN 18 THEN '��ѧ��' WHEN 19 THEN '΢��wap' WHEN 20 THEN '΢�ź��֧��' WHEN 21 THEN '����' 
		 WHEN 22 THEN 'ump���' WHEN 24 THEN '�ױ�֧��' WHEN 25 THEN '��ֵ��' WHEN 27 THEN 'qq֧��' WHEN 28 THEN '����E��֧��' 
		 WHEN 29 THEN '΢������' WHEN 30 THEN '֧��������' WHEN 33 THEN '��Ʒ��֧��' WHEN 35 THEN '��Ա���' WHEN 72 THEN '΢��ɨ���ά��֧��' 
		 WHEN 100 THEN '�����˻�' WHEN 300 THEN '��ֵ�˻�' WHEN 400 THEN '��֤���˻�' WHEN 101 THEN '�տ���' WHEN 102 THEN '΢��' 
		 WHEN 103 THEN '֧����' WHEN 104 THEN 'ˢ��' WHEN 105 THEN '��ά��̨��' WHEN 106 THEN '��ֵ��' WHEN 107 THEN '����E��' WHEN 110 THEN '����տ�-����΢��֧��' 
		 WHEN 111 THEN '����տ�-����֧����' WHEN 112 THEN '����տ�-����POSˢ��' WHEN 113 THEN 'ͨ��ˢ��֧��' WHEN 200 THEN '�����˻�' WHEN 201 THEN '�ֽ�' 
		 WHEN 202 THEN '���֧��' WHEN 203 THEN '�ⲿ֧��' WHEN 40 THEN '����֧��' END as Pay_Type,
		i.amount as Order_Amount,
		i.shipping_amount as Shipping_Amount,
		i.pay_amount as Pay_Amount,
		i.refund_amount as Refund_Amount,
		i.order_create_time as Order_Create_Time,
		i.[Order_Close_Time] as [Order_Close_Time],
		i.expired_time as Expired_Time,
		i.pay_time as Pay_Time,
		i.refund_time as Refund_Time,
		CASE i.refund_state WHEN 0 THEN 'δ�˿�' WHEN 1 THEN '�����˿���' WHEN 2 THEN '�����˿�ɹ�' WHEN 11 THEN 'ȫ���˿���' WHEN 12 THEN 'ȫ���˿�ɹ�' END as Refund_State,
		CASE i.close_type WHEN 0 THEN 'δ�ر�' WHEN 1 THEN '���ڹر�' WHEN 2 THEN '����˿�' WHEN 3 THEN '����ȡ��' WHEN 4 THEN '���ȡ��' WHEN 5 THEN '����ȡ��' 
			WHEN 6 THEN '�����˿�' WHEN 10 THEN '�޷���ϵ�����' WHEN 11 THEN '������Ļ�������' WHEN 12 THEN '����޳�����ɽ���' WHEN 13 THEN '��ͨ���������»��' 
			WHEN 14 THEN '��ͨ��ͬ�Ǽ��潻��' WHEN 15 THEN '��ͨ�����������' WHEN 16 THEN '��ͨ����������ֱ�ӻ��' WHEN 17 THEN '�Ѿ�ȱ���޷�����' END AS Close_Type,
		CASE i.express_type WHEN 0 THEN '��ݷ���' WHEN 1 THEN '��������' WHEN 2 THEN 'ͬ������' WHEN 9 THEN '���跢����������Ʒ������' END AS Express_Type,
		i.consign_time as Consign_Time,
		i.Offline_id,
		k.name as Consign_Store,
		i.Buy_phone AS Buyer_Mobile,
		i.Receiver_Name,
		i.Receiver_Tel AS Receiver_Mobile,
		i.Delivery_Province,
		i.Delivery_City,
		i.Delivery_District,
		i.Delivery_Address,
		coalesce(i.Fenxiao_Employee_id,i.Fenxiao_Mobile,'00000000000'), --ͬKOL���߼�����fenxiaoԱEmployeeID���÷���Ա�ֻ��š�
		i.Fenxiao_Mobile,
		i.Operator_Employee_id,
		i.Remark,
		i.deleted as is_deleted,
		getdate()
		,@ProcName AS [Create_By]
		,getdate()
		,@ProcName AS [Update_By]	
	FROM ODS.ods.SCRM_order_base_info i WITH(NOLOCK)
	LEFT JOIN (SELECT DISTINCT Order_id FROM ODS.ods.SCRM_order_detail_info WHERE (product_name LIKE '%�ƻ�%' OR product_name LIKE '%����%' OR  product_name LIKE '%����%') AND 
		product_name NOT LIKE '%�����ƻ���Ʒ������%') cy ON i.id = cy.order_id
	--LEFT JOIN dm.Dim_O2O_KOL k  WITH(NOLOCK) ON CAST(i.offline_id AS VARCHAR(20))= k.offline_id
	LEFT JOIN ods.ods.SCRM_youzan_store k WITH(NOLOCK) ON CAST(i.offline_id AS VARCHAR(20))= k.yz_id
	LEFT JOIN dm.Dim_O2O_Fans fu WITH(NOLOCK) ON i.wx_union_id = fu.union_id
	LEFT JOIN #Fans_Order_cnt foc ON isnull(i.outer_user_id,'') = foc.outer_user_id
	--where i.fans_nickname='����??��'
	;


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END

--select * from ODS.ods.SCRM_order_base_info i WITH(NOLOCK)
--where id=356916542119743488
--select * from dm.Dim_O2O_KOL  where offline_id=58815656
--select * from dm.Dim_O2O_KOL  where KolName='����'




GO
