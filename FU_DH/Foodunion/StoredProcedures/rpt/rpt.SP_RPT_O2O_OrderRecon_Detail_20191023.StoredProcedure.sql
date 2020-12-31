USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_O2O_OrderRecon_Detail_20191023]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_O2O_OrderRecon_Detail_20191023]
AS
BEGIN
/*
	DROP TABLE IF EXISTS #orderdetail;
	-- ���޶���
	SELECT 
		yr.Period AS [�����ڼ�]
		
		,c.Month_SNM AS [�·�]
		,ob.Order_Create_Time AS [��������ʱ��]
		,ob.Order_Close_Time AS [���׳ɹ�ʱ��]
		,yr.Order_No AS [������]
		,yr.Order_No AS [Ψһֵ]
		,od.Product_Name AS [��Ʒ����]
		,CASE WHEN ob.Express_Type='���跢����������Ʒ������' THEN '������Ʒ'
			WHEN ob.is_cycle=1 THEN '���ڹ���Ʒ' ELSE '��ͨ������Ʒ' END AS [��Ʒ����]

		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.delivery_cnt ELSE NULL END AS [����]
		,CASE WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.pcs_cnt * od.QTY ELSE NULL END  AS [ÿ������]
		,CASE WHEN ob.is_cycle=0 THEN CAST(od.payment AS DECIMAL(18,2)) WHEN ob.Order_Status <>'TRADE_CLOSED' THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) ELSE NULL END AS [ÿ�ν��]
		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN yr.Delivery_Cnt ELSE NULL END AS [�ڼ������ʹ���]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','������') OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL ELSE yr.Delivery_Cnt * od.pcs_cnt * od.QTY END AS [�ڼ�����������]
		,CAST(yr.Income_Amount AS DECIMAL(18,2)) AS [���˽��]	
		,CASE WHEN ob.Express_Type='���跢����������Ʒ������' OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL
			WHEN ob.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt * yr.Delivery_Cnt AS DECIMAL(18,2)) 
			ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [�ڼ������ͽ��]
		,cast(0 AS decimal(9,2)) AS [�ڼ��˷�]

		,CASE WHEN ob.pay_type in ('��Ʒ��֧��','���֧��') THEN 'Y' ELSE NULL END AS [��Ʒ��]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','������') THEN yr.Order_No ELSE NULL END AS [��SKU�Ķ���]	
		,ISNULL(ob.Shipping_Amount,0) AS [�˷�] --�˷�	
		,od.Product_ID AS [������]
		,CASE WHEN ISNULL(od.SKU_ID,'������') ='������' THEN '�������' ELSE TRIM(od.SKU_ID) END AS [��Ʒ����]
		,CAST(pl.SKU_Price AS DECIMAL(9,2)) AS [020�����Ľ�����]
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
			ELSE op.KolName END AS [����Ա��]
		,od.QTY * od.pcs_cnt AS [��Ʒ����]
		,CAST(od.payment AS DECIMAL(18,2)) AS [��Ʒʵ�ʳɽ����]	
		,ISNULL(ob.Refund_Amount,0) AS [��Ʒ���˿���]  
		,ob.Receiver_Name AS [�ջ���/�����]
		,ob.Receiver_Mobile AS [�ջ����ֻ���/������ֻ���]
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
			WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') NOT in ('1180004','1180003') THEN 'Subscription-Non-Fresh Milk' ELSE 'Normal' END AS [��������]
		,ISNULL(fx.KolName,'') AS [����Ա]
		,CAST(yr.Recon_Date AS DATETIME) AS [�����״���������]
		,CAST(NULL AS INT) AS [��ǰ�ۼ����ʹ���]
		,'' AS [�����ѹ���]
		,'' AS [���ļ�������]
		,ROW_NUMBER() OVER (PARTITION BY yr.Order_No ORDER BY od.Product_Name,od.SKU_ID) AS SeqID

	INTO #orderdetail
	FROM (
		SELECT Order_No
			,MIN(Recon_Date) AS Recon_Date
			,CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) AS [Period]
			--,CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
			--	ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END AS [Period]
			,COUNT(CASE WHEN Recon_Type='��������' THEN 1 ELSE NULL END) AS Delivery_Cnt 
			,SUM(CASE WHEN Recon_Type='��������' THEN Amount ELSE 0 END + CASE WHEN Recon_Type='�˿�' THEN Amount ELSE 0 END) AS Income_Amount
		FROM [dm].[Fct_Youzan_Recon] WITH(NOLOCK) 
		--WHERE Recon_DateKey BETWEEN 20190927 and 20190930 
		--AND Order_No='E20190929180819029900045'
		GROUP BY Order_No
			,CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112)
			--,CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
			--	ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END
		)yr
	INNER JOIN [dm].[Fct_O2O_Order_Base_info] ob WITH(NOLOCK) ON yr.Order_No=ob.Order_No
	INNER JOIN [dm].[Fct_O2O_Order_Detail_info] od WITH(NOLOCK) ON ob.Order_ID=od.Order_ID
	LEFT JOIN (
		SELECT DISTINCT Year_Month,Month_EN_NM,Month_SNM
		FROM FU_EDW.Dim_Calendar
		)c ON CONVERT(VARCHAR(6),CAST(dbo.split(yr.Period,'-',1) AS DATE),112)=C.Year_Month
	LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON pl.Price_List_Name='ͳһ����' AND pl.SKU_ID=od.SKU_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] op ON ob.Operator_Employee_id=op.KOL_Employee_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] fx ON ob.Fenxiao_Employee_id=fx.KOL_Employee_ID
	ORDER BY yr.Period,yr.Order_No,od.Product_Name,od.SKU_ID
	;

	--------------------------------
	--SELECT SUM(�ڼ������ʹ���) OVER(PARTITION BY [������] ORDER BY [�����ڼ�]),* FROM #orderdetail WHERE ����=13 ORDER BY [������],[�����ڼ�] ;
	--�������ڹ����� ��ֹ��ǰ���ʹ���
	UPDATE tmp
		SET tmp.[��ǰ�ۼ����ʹ���] = y.[��ǰ�ۼ����ʹ���]
	FROM #orderdetail tmp
	JOIN( 
		SELECT *,SUM([�ڼ������ʹ���]) OVER(PARTITION BY [������] ORDER BY [�����ڼ�]) AS [��ǰ�ۼ����ʹ���] FROM (
		SELECT DISTINCT [�����ڼ�],[������],[�ڼ������ʹ���]	FROM #orderdetail WHERE [��Ʒ����]='���ڹ���Ʒ'
		)x )y ON tmp.[�����ڼ�]=y.[�����ڼ�] AND tmp.[������]=y.[������];

	--select top 10 * from #orderdetail
	--�ж����ͽ����Ķ������Ƿ������һ�����ڹ�����
	UPDATE tmp
		SET [�����ѹ���] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [�ջ����ֻ���/������ֻ���] ,MAX([������]) AS [������],MAX([�����ڼ�]) AS [�����ڼ�]
		FROM #orderdetail tmp 
		WHERE [��ǰ�ۼ����ʹ���]=[����]
		GROUP BY [�ջ����ֻ���/������ֻ���]
		)z ON tmp.[������]=z.[������] AND tmp.[�����ڼ�]=z.[�����ڼ�]
	LEFT JOIN #orderdetail t2
		ON  z.[�ջ����ֻ���/������ֻ���]=t2.[�ջ����ֻ���/������ֻ���]
		AND t2.[��������]<>'Normal'
		AND t2.[������]>z.[������]   -- �����󲻴��������ڹ���
	WHERE t2.[������] IS NULL;

	--�ж����ͼ�������(�����ڶ���)�Ķ������Ƿ������һ�����ڹ�����
	UPDATE tmp
		SET [���ļ�������] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [�ջ����ֻ���/������ֻ���] ,MAX([������]) AS [������],MAX([�����ڼ�]) AS [�����ڼ�]
		FROM #orderdetail tmp 
		WHERE [��ǰ�ۼ����ʹ���]=[����]-1
		GROUP BY [�ջ����ֻ���/������ֻ���]
		)z ON tmp.[������]=z.[������] AND tmp.[�����ڼ�]=z.[�����ڼ�]
	LEFT JOIN #orderdetail t2
		ON  z.[�ջ����ֻ���/������ֻ���]=t2.[�ջ����ֻ���/������ֻ���]
		AND t2.[��������]<>'Normal'
		AND (t2.[������]>z.[������] OR (t2.[������]=tmp.[������] AND t2.[��ǰ�ۼ����ʹ���]=tmp.[����]))   -- �����������ڹ���, �Ҳ�������ᶩ��
	WHERE t2.[������] IS NULL;


	--select * from #orderdetail where [������]=	'E20190502121021049700037';
	--------------------------------


	--��Ҫ��ֵĶ���
	DROP TABLE IF EXISTS #order2split;
	SELECT [�����ڼ�],[������],MAX(SeqID) SeqID 
	INTO #order2split
	FROM #orderdetail 
	WHERE SeqID>1
	GROUP BY [�����ڼ�],[������];
	
	--��ֶ������� [��Ʒʵ�ʳɽ����] �� ��� [���˽��]��Ϊ�˻��ܽ�����һ�£����һ����¼���ÿۼ����ó���
	UPDATE tmp
		SET tmp.[���˽��] = CASE WHEN tol.[��Ʒʵ�ʳɽ����]=0 THEN 0 ELSE CAST(tmp.[���˽��] * tmp.[��Ʒʵ�ʳɽ����] / tol.[��Ʒʵ�ʳɽ����] AS DECIMAL(18,2)) END
		,tmp.[��Ʒ���˿���] = 0  
		,tmp.[�˷�] = 0 
	FROM #orderdetail tmp
	JOIN #order2split x  -- ��Ҫ��ֵĶ���
		ON tmp.[�����ڼ�]=x.[�����ڼ�] AND tmp.[������]=x.[������]
		AND tmp.SeqID <> x.SeqID  --�Ȳ��������һ�ʽ��
	JOIN (
		SELECT [�����ڼ�],[������],SUM(��Ʒʵ�ʳɽ����) AS [��Ʒʵ�ʳɽ����]
		FROM #orderdetail
		GROUP BY [�����ڼ�],[������]
		) tol ON tmp.[�����ڼ�]=tol.[�����ڼ�] AND tmp.[������]=tol.[������] --�ö����ܽ��
	
	UPDATE	tmp
		SET tmp.[���˽��] = tmp.[���˽��] - spl.[�ѷ�̯���˽��]
		--,tmp.[�ڼ��˷�] = tmp.[���˽��] - spl.[�ѷ�̯���˽��] - tmp.[�ڼ������ͽ��]
    FROM #orderdetail tmp
	JOIN #order2split x  
		ON tmp.[�����ڼ�]=x.[�����ڼ�] AND tmp.[������]=x.[������]
		AND tmp.SeqID = x.SeqID  --�۳��� �������һ�ʽ��
	JOIN(
		SELECT tmp.[�����ڼ�],tmp.[������],SUM(tmp.[���˽��]) AS [�ѷ�̯���˽��]
		FROM #orderdetail tmp
		JOIN #order2split x  
		ON tmp.[�����ڼ�]=x.[�����ڼ�] AND tmp.[������]=x.[������]
		AND tmp.SeqID <> x.SeqID
		GROUP BY tmp.[�����ڼ�],tmp.[������]
		) spl
		ON tmp.[�����ڼ�]=spl.[�����ڼ�] AND tmp.[������]=spl.[������]
		;

	
	UPDATE	tmp
		SET tmp.[Ψһֵ] = NULL
    FROM #orderdetail tmp
	WHERE SeqID <> 1;
	
	UPDATE	tmp
		SET tmp.[�ڼ��˷�] = cast([���˽��] as decimal(18,2))-cast(isnull([�ڼ������ͽ��],0) as decimal(18,2))
    FROM #orderdetail tmp	;

	ALTER TABLE #orderdetail DROP COLUMN SeqID;
	SELECT * FROM #orderdetail ORDER BY [�����ڼ�],[������],[��Ʒ����],[��Ʒ����]
	--WHERE [������]='E20190731123136006900015'
	;
*/

	SELECT [�����ڼ�]
      ,[�·�]
      ,[��������ʱ��]
      ,[���׳ɹ�ʱ��]
      ,[������]
      ,[Ψһֵ]
      ,[��Ʒ����]
      ,[��Ʒ����]
      ,[����]
      ,[ÿ������]
      ,[ÿ�ν��]
      ,[�ڼ������ʹ���]
      ,[�ڼ�����������]
      ,[���˽��]
      ,[�ڼ������ͽ��]
      ,[�ڼ��˷�]
      ,[��Ʒ��]
      ,[��SKU�Ķ���]
      ,[�˷�]
      ,[������]
      ,[��Ʒ����]
      ,[020�����Ľ�����]
      ,[RSP*����]
      ,[�ۿ�]
      ,[�����ֿ�]
      ,[����Ա��]
      ,[��Ʒ����]
      ,[��Ʒʵ�ʳɽ����]
      ,[��Ʒ���˿���]
      ,[�ջ���/�����]
      ,[�ջ����ֻ���/������ֻ���]
      ,[��ϸ�ջ���ַ/�����ַ]
      ,[�µ�����]
      ,[�̼Ҷ�����ע]
      ,[��Ʒ����״̬]
      ,[��Ʒ������ʽ]
      ,[��Ʒ����ʱ��]
      ,[��Ʒ�˿�״̬]
      ,[���ڹ���Ϣ]
      ,[��������]
      ,[����Ա]
      ,[�����״���������]
      ,[��ǰ�ۼ����ʹ���]
      ,[��ǰ��Ծ���ĵ�]
      ,[�����ѹ���]
      ,[���ļ�������]
	FROM [rpt].[O2O_OrderRecon_Detail]


END

--select cast([���˽��] as decimal(9,2))-cast([�ڼ������ͽ��] as decimal(9,2)) from #orderdetail

--select cast([�ڼ������ͽ��] as decimal(9,2)) from #orderdetail
--select * from  #orderdetail order by '������'
-- select * from  #orderdetail  where '������'='E20190927140035040600071'
--select top 100 * from [dm].[Fct_Youzan_Recon] 
----where Recon_DateKey BETWEEN 20190927 and 20190930 
--order by order_no 

--SELECT CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
--		ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END AS [Period]
--	,Order_No
--	,ROW_NUMBER() OVER (PARTITION BY Order_No ORDER BY CASE WHEN ISNULL(od.SKU_ID,'������') ='������' THEN '' END) AS SID
--FROM [dm].[Fct_Youzan_Recon] WITH(NOLOCK) 
--WHERE Recon_Type='��������'
--AND Recon_DateKey BETWEEN 20190927 and 20190930 
----AND Order_No='E20190920105523098700056'
--GROUP BY Order_No
--	,CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
--		ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END


--select * from dm.Fct_O2O_Order_Base_info where order_no='E20190923142350062500004'
--select * from dm.Fct_O2O_Order_Detail_info where Order_ID='373518436619390976'
--select * from dm.Fct_Youzan_Recon where Order_No='E20190927140035040600071'

--select * from ods.ods.File_Youzan_Order_MonthlyRecon where Order_No='E20190929180819029900045'


--		�˷�/�˿� ��ϸ �ŵ�һ����
--		���˽�� =net
GO
