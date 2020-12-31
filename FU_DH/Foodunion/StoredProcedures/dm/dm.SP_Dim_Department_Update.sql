USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dm].[SP_Dim_Department_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	


	DELETE o
	FROM [Foodunion].dm.Dim_Department o
	JOIN ODS.[ods].[Fxxk_DepartmentInfo] s
	ON o.[Department_ID]=s.departmentid;

	INSERT INTO dm.Dim_Department
	(
	   [Department_ID]
      ,[Name]
      ,[Description]
      ,[Parent_ID]
      ,[Level_No]
      ,[Is_Active]
      ,[Status]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT 
	    departmentid
	   ,name
	   ,description
	   ,parentdepartmentid
	   ,0 as [Level_No]
	   ,case when isstop='false' then 1 else 0 end as  [Is_Active]
	   ,case status when 1 then 'Active' when 2 then 'Stopped' end as [Status]
	   ,getdate() as  [Create_Time]
	   ,'ODS.[ods].[Fxxk_DepartmentInfo]' as [Create_By]
	   ,getdate() as [Update_Time]
	   ,'ODS.[ods].[Fxxk_DepartmentInfo]' as [Update_By]
	FROM ODS.[ods].[Fxxk_DepartmentInfo]
	;

--------------------------------------------update [Level_No]
	
	IF exists (select * from tempdb.dbo.sysobjects where id = object_id(N'#Temp_Department') and type='U')
    DROP TABLE #Temp_Department ;

	  with cte as
	(
		select Department_ID,Parent_ID,Name, 0 as [Level_Nov] from [Foodunion].[dm].[Dim_Department] 
		where Department_ID = 999999
		union all
		select d.Department_ID,d.Parent_ID,d.Name,[Level_Nov] + 1 from cte c inner join [Foodunion].[dm].[Dim_Department]  d
		on c.Department_ID = d.Parent_ID
	)
	select * into #Temp_Department from cte

	UPDATE dm.Dim_Department
	SET [Level_No]=#Temp_Department.[Level_Nov] 
	FROM #Temp_Department
	WHERE dm.Dim_Department.Department_ID=#Temp_Department.Department_ID
	;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

	END


GO
