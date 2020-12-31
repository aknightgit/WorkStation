USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_Youzan_Revenue_Detail_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_Youzan_Revenue_Detail_Update]
AS
BEGIN

	DROP TABLE IF EXISTS #orderdetail;
	-- ���޶���
	SELECT 
		 yr.Revenue_Time AS [Revenue Date]
		,c.Month_SNM AS [Month]
		,ob.Order_Create_Time AS [Created date]
		,ob.Order_Close_Time AS [���׳ɹ�ʱ��]
		,yr.Order_No AS [Order Number]
		,yr.Order_No AS [Ψһֵ]
		,od.Product_Name AS [Product Name]
		,CASE WHEN ob.Express_Type='���跢����������Ʒ������' THEN '������Ʒ'
			WHEN ob.is_cycle=1 THEN '���ڹ���Ʒ' ELSE '��ͨ������Ʒ' END AS [��Ʒ����]
		,prod.Sale_Unit_CN AS [Sales unit]
		,ob.Order_Status AS [Order Status]
		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.delivery_cnt ELSE NULL END AS [Length of Subsrciption, week]
		,CASE WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.pcs_cnt * od.QTY ELSE NULL END  AS [ÿ������]
		,CASE WHEN ob.is_cycle=0 THEN CAST(od.payment AS DECIMAL(18,2)) WHEN ob.Order_Status <>'TRADE_CLOSED' THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) ELSE NULL END AS [ÿ�ν��]
		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN yr.Delivery_Cnt ELSE NULL END AS [�ڼ������ʹ���]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','������') OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL ELSE yr.Delivery_Cnt * od.pcs_cnt * od.QTY END AS [Qty, sales unit]
		,CAST(yr.Income_Amount AS DECIMAL(18,2)) AS [Actual Order amount]	
		,CASE WHEN ob.Express_Type='���跢����������Ʒ������' OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL
			WHEN ob.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt * yr.Delivery_Cnt AS DECIMAL(18,2)) 
			ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [�ڼ������ͽ��]
		,cast(0 AS decimal(9,2)) AS [�ڼ��˷�]

		,CASE WHEN ob.pay_type in ('��Ʒ��֧��','���֧��') THEN 'Y' ELSE NULL END AS [��Ʒ��]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','������') THEN yr.Order_No ELSE NULL END AS [��SKU�Ķ���]	
		,ISNULL(ob.Shipping_Amount,0) AS [�˷�] --�˷�	
		,od.Product_ID AS [������]
		,CASE WHEN ISNULL(od.SKU_ID,'������') ='������' THEN '�������' ELSE TRIM(od.SKU_ID) END AS [SKU ID]
		,yr.Revenue_Name
		,CAST(pl.SKU_Price AS DECIMAL(9,2)) AS [RSP per sales unit]
		,CASE WHEN ob.Order_Status <>'TRADE_CLOSED' THEN CAST(yr.Delivery_Cnt * od.pcs_cnt * od.QTY * pl.SKU_Price AS DECIMAL(9,2)) ELSE NULL END AS [RSP*����]
		,CAST(yr.Delivery_Cnt * od.pcs_cnt * od.QTY * pl.SKU_Price AS DECIMAL(9,2)) 
			- CASE WHEN ob.Express_Type='���跢����������Ʒ������' OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL
			WHEN ob.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt * yr.Delivery_Cnt AS DECIMAL(18,2)) 
			ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [�ۿ�]	
		,CASE WHEN op.KolName in('�¾���') AND ob.Express_Type='��ݷ���' THEN 'O2O��;'
			WHEN op.KolName='�¾���' AND ob.Express_Type='ͬ������' THEN '������'
			ELSE 'O2O.03' END AS [�����ֿ�] --1������Ա��=kol��ֱ��=020.03  2���������Ա��=yuki�ģ��Ҷ�������=��ݵģ�����020��;��3������Ա��=yuki���������=ͬ�ǣ�����ע����Ϊ������
		,CASE WHEN ob.Consign_Store='�����й�' AND ob.Remark is null THEN '�¾���' 
			WHEN  ob.Consign_Store='�����й�' AND ob.Remark is NOT null THEN '������'
			ELSE op.KolName END AS [Operator]
		,od.QTY * od.pcs_cnt AS [��Ʒ����]
		,CAST(od.payment AS DECIMAL(18,2)) AS [��Ʒʵ�ʳɽ����]	
		,ISNULL(ob.Refund_Amount,0) AS [��Ʒ���˿���]  
		,ob.Receiver_Name AS [Consignee]
		,ob.Receiver_Mobile AS [Consignee's cellphone#]
		,isnull(ob.Delivery_Province,'')+isnull(ob.Delivery_City,'')+isnull(Delivery_District,'')+ob.Delivery_Address AS [��ϸ�ջ���ַ/�����ַ]
		,ob.Consign_Store AS [�µ�����]
		,ob.Remark AS [�̼Ҷ�����ע]
		,CASE WHEN ob.Express_Type='���跢����������Ʒ������' THEN '-' ELSE '�ѷ���' END AS [��Ʒ����״̬]
		,ob.Express_Type AS [��Ʒ������ʽ]
		,ob.Consign_Time AS [��Ʒ����ʱ��]
		,ob.Refund_State AS [��Ʒ�˿�״̬] 	
		,CASE WHEN ob.is_cycle=1 THEN od.SubscriptionType ELSE NULL END AS [���ڹ���Ϣ]	
		--,null AS [��ұ�ע]
		--������ҵ�������
		--ͬ���ʹ�ʱ��/���ʱ��
		--����ջ���Ϣ	
		--��Ʒ����������˾	
		--����ʱ��	
		--������ҵ���Ʒʵ�����	
		,CASE WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') in ('1180004','1180003') THEN 'Subscription-Fresh Milk' 
			WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') NOT in ('1180004','1180003') THEN 'Subscription-Non-Fresh Milk' ELSE 'Normal' END AS [Order Type]
		,ISNULL(fx.KolName,'') AS [KOL]
		,CAST(yr.Revenue_Time AS DATETIME) AS [�����״���������]
		,CAST(NULL AS INT) AS [��ǰ�ۼ����ʹ���]
		,'' AS [��ǰ��Ծ���ĵ�]
		,'' AS [�����ѹ���]
		,'' AS [���ļ�������]
		,ROW_NUMBER() OVER (PARTITION BY yr.Order_No ORDER BY od.Product_Name,od.SKU_ID) AS SeqID
		,CASE WHEN ISNULL(ob.Order_Amount,0) <> 0 THEN 1 ELSE 0 END AS [Delivery time in the period per week]
	INTO #orderdetail
	FROM (
		SELECT Order_No
			,Revenue_Time
			,Revenue_Name
			,COUNT(CASE WHEN Revenue_Type='��������' THEN 1 ELSE NULL END) AS Delivery_Cnt 
			,SUM(CASE WHEN Revenue_Type='��������' THEN Income_Amount ELSE 0 END + CASE WHEN Revenue_Type='�˿�' THEN Income_Amount ELSE 0 END) AS Income_Amount
		FROM [dm].[Fct_Youzan_Revenue_Details] WITH(NOLOCK) 
		GROUP BY Order_No
			,Revenue_Time
			,Revenue_Name
		)yr
	INNER JOIN [dm].[Fct_O2O_Order_Base_info] ob WITH(NOLOCK) ON yr.Order_No=ob.Order_No
	INNER JOIN [dm].[Fct_O2O_Order_Detail_info] od WITH(NOLOCK) ON ob.Order_ID=od.Order_ID
	LEFT JOIN (
		SELECT DISTINCT Year_Month,Month_EN_NM,Month_SNM
		FROM FU_EDW.Dim_Calendar
		)c ON CONVERT(VARCHAR(6),CAST(Revenue_Time AS DATE),112)=C.Year_Month
	LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON pl.Price_List_Name='ͳһ����' AND pl.SKU_ID=od.SKU_ID
	LEFT JOIN dm.Dim_Product prod ON od.SKU_ID = prod.SKU_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] op ON ob.Operator_Employee_id=op.KOL_Employee_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] fx ON ob.Fenxiao_Employee_id=fx.KOL_Employee_ID
	ORDER BY yr.Revenue_Time,yr.Order_No,od.Product_Name,od.SKU_ID
	;

	--------------------------------
	--SELECT SUM(�ڼ������ʹ���) OVER(PARTITION BY [Order Number] ORDER BY [Revenue Date]),* FROM #orderdetail WHERE ����=13 ORDER BY [Order Number],[Revenue Date] ;
	--�������ڹ����� ��ֹ��ǰ���ʹ���
	UPDATE tmp
		SET tmp.[��ǰ�ۼ����ʹ���] = y.[��ǰ�ۼ����ʹ���]
	FROM #orderdetail tmp
	JOIN( 
		SELECT *,SUM([�ڼ������ʹ���]) OVER(PARTITION BY [Order Number] ORDER BY [Revenue Date]) AS [��ǰ�ۼ����ʹ���] FROM (
		SELECT DISTINCT [Revenue Date],[Order Number],[�ڼ������ʹ���]	FROM #orderdetail WHERE [��Ʒ����]='���ڹ���Ʒ'
		)x )y ON tmp.[Revenue Date]=y.[Revenue Date] AND tmp.[Order Number]=y.[Order Number];

	--select top 10 * from #orderdetail
	--�ж����ͽ����Ķ������Ƿ������һ�����ڹ�����
	UPDATE tmp
		SET [�����ѹ���] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [Consignee's cellphone#] ,MAX([Order Number]) AS [Order Number],MAX([Revenue Date]) AS [Revenue Date]
		FROM #orderdetail tmp 
		WHERE [��ǰ�ۼ����ʹ���]=[Length of Subsrciption, week]
		GROUP BY [Consignee's cellphone#]
		)z ON tmp.[Order Number]=z.[Order Number] AND tmp.[Revenue Date]=z.[Revenue Date]
	LEFT JOIN #orderdetail t2
		ON  z.[Consignee's cellphone#]=t2.[Consignee's cellphone#]
		AND t2.[Order Type]<>'Normal'
		AND t2.[Order Number]>z.[Order Number]   -- �����󲻴��������ڹ���
	WHERE t2.[Order Number] IS NULL;

	--�ж����ͼ�������(�����ڶ���)�Ķ������Ƿ������һ�����ڹ�����
	UPDATE tmp
		SET [���ļ�������] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [Consignee's cellphone#] ,MAX([Order Number]) AS [Order Number],MAX([Revenue Date]) AS [Revenue Date]
		FROM #orderdetail tmp 
		WHERE [��ǰ�ۼ����ʹ���]=[Length of Subsrciption, week]-1
		GROUP BY [Consignee's cellphone#]
		)z ON tmp.[Order Number]=z.[Order Number] AND tmp.[Revenue Date]=z.[Revenue Date]
	LEFT JOIN #orderdetail t2
		ON  z.[Consignee's cellphone#]=t2.[Consignee's cellphone#]
		AND t2.[Order Type]<>'Normal'
		AND (t2.[Order Number]>z.[Order Number] OR (t2.[Order Number]=tmp.[Order Number] AND t2.[��ǰ�ۼ����ʹ���]=tmp.[Length of Subsrciption, week]))   -- �����������ڹ���, �Ҳ�������ᶩ��
	WHERE t2.[Order Number] IS NULL AND tmp.[���׳ɹ�ʱ��] IS NULL;

	--�ж��Ƿ�ǹرյģ�δ����������ڹ�����
	UPDATE tmp
		SET tmp.[��ǰ��Ծ���ĵ�] = 'Y'
	FROM #orderdetail tmp
	JOIN (
		SELECT [Order Number],MAX([��ǰ�ۼ����ʹ���]) AS [��ǰ�ۼ����ʹ���]
		FROM #orderdetail  
		WHERE [Order Type]<>'Normal'
		GROUP BY [Order Number]
		)t3 ON tmp.[Order Number]=t3.[Order Number] AND tmp.[Length of Subsrciption, week]>t3.[��ǰ�ۼ����ʹ���] AND tmp.[���׳ɹ�ʱ��] IS NULL;

	--select * from #orderdetail where [Order Number]=	'E20190502121021049700037';
	--------------------------------


	--��Ҫ��ֵĶ���
	DROP TABLE IF EXISTS #order2split;
	SELECT [Revenue Date],[Order Number],MAX(SeqID) SeqID 
	INTO #order2split
	FROM #orderdetail 
	WHERE SeqID>1
	GROUP BY [Revenue Date],[Order Number];
	
	--��ֶ������� [��Ʒʵ�ʳɽ����] �� ��� [Actual Order amount]��Ϊ�˻��ܽ�����һ�£����һ����¼���ÿۼ����ó���
	UPDATE tmp
		SET tmp.[Actual Order amount] = CASE WHEN tol.[��Ʒʵ�ʳɽ����]=0 THEN 0 ELSE CAST(tmp.[Actual Order amount] * tmp.[��Ʒʵ�ʳɽ����] / tol.[��Ʒʵ�ʳɽ����] AS DECIMAL(18,2)) END
		,tmp.[��Ʒ���˿���] = 0  
		,tmp.[�˷�] = 0 
	FROM #orderdetail tmp
	JOIN #order2split x  -- ��Ҫ��ֵĶ���
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number]
		AND tmp.SeqID <> x.SeqID  --�Ȳ��������һ�ʽ��
	JOIN (
		SELECT [Revenue Date],[Order Number],SUM(��Ʒʵ�ʳɽ����) AS [��Ʒʵ�ʳɽ����]
		FROM #orderdetail
		GROUP BY [Revenue Date],[Order Number]
		) tol ON tmp.[Revenue Date]=tol.[Revenue Date] AND tmp.[Order Number]=tol.[Order Number] --�ö����ܽ��
	
	UPDATE	tmp
		SET tmp.[Actual Order amount] = tmp.[Actual Order amount] - spl.[�ѷ�̯���˽��]
		--,tmp.[�ڼ��˷�] = tmp.[Actual Order amount] - spl.[�ѷ�̯���˽��] - tmp.[�ڼ������ͽ��]
    FROM #orderdetail tmp
	JOIN #order2split x  
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number]
		AND tmp.SeqID = x.SeqID  --�۳��� �������һ�ʽ��
	JOIN(
		SELECT tmp.[Revenue Date],tmp.[Order Number],SUM(tmp.[Actual Order amount]) AS [�ѷ�̯���˽��]
		FROM #orderdetail tmp
		JOIN #order2split x  
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number]
		AND tmp.SeqID <> x.SeqID
		GROUP BY tmp.[Revenue Date],tmp.[Order Number]
		) spl
		ON tmp.[Revenue Date]=spl.[Revenue Date] AND tmp.[Order Number]=spl.[Order Number]
		;

	
	UPDATE	tmp
		SET tmp.[Ψһֵ] = NULL
    FROM #orderdetail tmp
	WHERE SeqID <> 1;
	
	UPDATE	tmp
		SET tmp.[�ڼ��˷�] = cast([Actual Order amount] as decimal(18,2))-cast(isnull([�ڼ������ͽ��],0) as decimal(18,2))
    FROM #orderdetail tmp	;

	ALTER TABLE #orderdetail DROP COLUMN SeqID;

	--DROP TABLE IF EXISTS rpt.O2O_OrderRecon_Detail;
	--SELECT * 
	--	,getdate() AS [Update_Time]
 --       ,'[rpt].[SP_Youzan_Revenue_Detail_Update]' as [Update_By]
	--INTO rpt.O2O_OrderRecon_Detail FROM #orderdetail ORDER BY [Revenue Date],[Order Number],[Product Name],[SKU ID]

	----WHERE [Order Number]='E20190731123136006900015'
	--CREATE CLUSTERED index inx_O2O_OrderRecon_Detail on rpt.O2O_OrderRecon_Detail([Revenue Date],[Order Number],[Product Name],[SKU ID])
	--;
	SELECT [Revenue Date]
		  ,[Created date]
		  ,[Actual Order amount]
		  ,[SKU ID]
		  ,[Revenue_Name] AS [Revenue Name]
		  ,[Product Name]
		  ,[Qty, sales unit]
		  ,[Sales unit]
		  ,[Length of Subsrciption, week]
		  ,[Delivery time in the period per week]
		  ,[Consignee]
		  ,[Consignee's cellphone#]
		  ,[Order Type]
		  ,[KOL]
		  ,[Order Number]
		  ,[RSP per sales unit]
		  ,[Month]
		  ,[Operator]
		  ,[Order Status]
	FROM #orderdetail




END


GO
