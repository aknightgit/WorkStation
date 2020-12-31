USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dm].[SP_Dim_Employee_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	DELETE dm
	FROM [dm].[Dim_Employee] dm
	JOIN ODS.ods.fxxk_userList ods ON ods.openUserId=dm.[Employee_No];
	--TRUNCATE TABLE  [dm].[Dim_Employee];

	INSERT INTO [dm].[Dim_Employee]
           ([Employee_No]
           ,[Name]
           ,[English_Name]
           ,[Nick_Name]
           ,[Gender]
           ,[UserID_Fxxk]
           ,[LeaderID]
		   ,[Leader_Name]
           ,[Department]
           ,[Employee_Role]
           ,[Region]
           ,[Mobile]
           ,[Email]
           ,[Join_Date]
           ,[Is_Active]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
     SELECT ods.openUserId,
		ods.[name],
		'',
		ods.nickName,
		ods.gender,
		ods.openUserId,
		ods.leaderId,
		ods2.[name],
		'',
		ods.position,
		'',
		cast(ods.mobile as varchar(11)),
		ods.email,
		ods.hireDate,
		case when ods.isStop='True' then 0 else 1 end,
		GETDATE(),'ODS.ods.fxxk_userList',
		GETDATE(),'ODS.ods.fxxk_userList'
	 FROM ODS.ods.fxxk_userList ods
	 LEFT JOIN ODS.ods.fxxk_userList ods2 ON ods.leaderId=ods2.openUserId
	 LEFT JOIN [dm].[Dim_Employee] dm ON ods.openUserId=dm.[Employee_No]
	 WHERE dm.[Employee_No] IS NULL;

	 --UPDATE  [dm].[Dim_Employee] SET Name='王鹤明',English_Name='Louis.Wang' WHERE Nick_Name='王鹤明LouisWang';
	 --UPDATE  [dm].[Dim_Employee] SET Name='蔡文亮',English_Name='Wenliang.Cai' WHERE Nick_Name='蔡文亮WenliangCai';
	 --UPDATE  [dm].[Dim_Employee] SET Name='冯子路',English_Name='Kevin.Feng' WHERE Nick_Name='冯子路KevinFeng';
	 --UPDATE  [dm].[Dim_Employee] SET Name='徐谦',English_Name='Paulus.Xu' WHERE Nick_Name='徐谦PaulusXu';
	 --UPDATE  [dm].[Dim_Employee] SET Name='罗宽',English_Name='Sunny.Luo' WHERE Nick_Name='罗宽SunnyLuo';
	 --UPDATE  [dm].[Dim_Employee] SET Name='谢建平',English_Name='Jianping.Xie' WHERE Nick_Name='谢建平JianpingXie';
	 --UPDATE  [dm].[Dim_Employee] SET Name='张兴华',English_Name='Allen.Zhang' WHERE Nick_Name='张兴华AllenZhang';
	 --UPDATE  [dm].[Dim_Employee] SET Name='黄晶晶',English_Name='Yoyo.Huang' WHERE Nick_Name='黄晶晶YoyoHuang';
	 --UPDATE  [dm].[Dim_Employee] SET Name='李砚庆',English_Name='Louis.Li' WHERE Nick_Name='李砚庆LouisLi';
	 --UPDATE  [dm].[Dim_Employee] SET Name='刘宁',English_Name='Louis.Liu' WHERE Nick_Name='刘宁LouisLiu';
	 --UPDATE  [dm].[Dim_Employee] SET Name='赵波',English_Name='Robert.Zhao' WHERE Nick_Name='赵波RobertZhao';
	 --UPDATE  [dm].[Dim_Employee] SET Name='刘海平',English_Name='Herman.Liu' WHERE Nick_Name='刘海平HermanLiu';
	 --UPDATE  [dm].[Dim_Employee] SET Name='薛浩',English_Name='Justin.Xue' WHERE Nick_Name='薛浩JustinXue';
	 --UPDATE  [dm].[Dim_Employee] SET Name='张国庆',English_Name='Guoqing.Zhang' WHERE Nick_Name='张国庆GuoqingZhang';
	 --UPDATE  [dm].[Dim_Employee] SET Name='张宵宁',English_Name='Xiaoning.Zhang' WHERE Nick_Name='张宵宁XiaoningZhang';
	 --UPDATE  [dm].[Dim_Employee] SET Name='陈朋朋',English_Name='Alisa.Chen' WHERE Nick_Name='陈朋朋AlisaChen';
	 --UPDATE  [dm].[Dim_Employee] SET Name='冯玉廷',English_Name='Rio.Feng' WHERE Nick_Name='冯玉廷RioFeng';
	 --UPDATE  [dm].[Dim_Employee] SET Name='曾兴宇',English_Name='Xingyu.Zeng' WHERE Nick_Name='曾兴宇XingyuZeng';
	 --UPDATE  [dm].[Dim_Employee] SET Name='黄文彪',English_Name='Aaron.Wong' WHERE Nick_Name='黄文彪AaronWong';
	 --UPDATE  [dm].[Dim_Employee] SET Name='林清友',English_Name='Frank.Lin' WHERE Nick_Name='林清友FrankLin';
	 --UPDATE  [dm].[Dim_Employee] SET Name='刘方勇',English_Name='Fangyong.Liu' WHERE Nick_Name='刘方勇FangyongLiu';
	 --UPDATE  [dm].[Dim_Employee] SET Name='刘揽',English_Name='Louise.Liu' WHERE Nick_Name='刘揽LouiseLiu';
	 --UPDATE  [dm].[Dim_Employee] SET Name='罗健瑞',English_Name='Jerry.Luo' WHERE Nick_Name='罗健瑞JerryLuo';
	 --UPDATE  [dm].[Dim_Employee] SET Name='罗俊',English_Name='Jun.Luo' WHERE Nick_Name='罗俊JunLuo';
	 --UPDATE  [dm].[Dim_Employee] SET Name='罗曦琳',English_Name='Xilin.Luo' WHERE Nick_Name='罗曦琳XilinLuo';
	 --UPDATE  [dm].[Dim_Employee] SET Name='邱锋',English_Name='Feng.Qiu' WHERE Nick_Name='邱锋FengQiu';
	 --UPDATE  [dm].[Dim_Employee] SET Name='魏艳华',English_Name='Alisa.Wei' WHERE Nick_Name='魏艳华AlisaWei';
	 --UPDATE  [dm].[Dim_Employee] SET Name='谢佳芹',English_Name='JiaQin.Xie' WHERE Nick_Name='谢佳芹JiaQinXie';
	 --UPDATE  [dm].[Dim_Employee] SET Name='杨建军',English_Name='Jianjun.Yang' WHERE Nick_Name='杨建军JianjunYang';
	 --UPDATE  [dm].[Dim_Employee] SET Name='郑伟',English_Name='Eason.Zheng' WHERE Nick_Name='郑伟EasonZheng';
	
	 END TRY
	 BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


--select * from [dm].[Dim_Employee]


--select * into [dm].[Dim_Employee_20201105]
--from [dm].[Dim_Employee]

--[dbo].[USP_Change_TableColumn] '[dm].[Dim_Employee]','add','Leader_Name varchar(200)','LeaderID',0
GO
