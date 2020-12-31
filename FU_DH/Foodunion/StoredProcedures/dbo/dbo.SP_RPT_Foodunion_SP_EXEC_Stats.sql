USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROC [dbo].[SP_RPT_Foodunion_SP_EXEC_Stats]
AS
BEGIN


DELETE FROM ConfigDB.dbo.SP_EXEC_Stats_Foodunion WHERE CONVERT(VARCHAR(10),[Load_Date],112)=CONVERT(VARCHAR(10),GETDATE(),112);
INSERT INTO ConfigDB.dbo.SP_EXEC_Stats_Foodunion
      ([Object_ID]
      ,[Database_ID]
      ,[Database_Name]
      ,[Schema_Name]
      ,[存储过程名称]
      ,[创建日期]
      ,[修改日期]
      ,[最后一次运行时间(S)]
      ,[总耗时时间(S)]
      ,[执行总次数]
      ,[最后一次执行时间]
      ,[创建天数(天)]
      ,[运行频率(次/天)]
	  ,[Load_Date])
SELECT A.Object_ID, 
       ISNULL(Database_ID,6) AS Database_ID, 
	   ISNULL(DB_NAME( Database_ID),'Foodunion') AS Database_Name,	 
	   S.name                AS Schema_Name,
       A.name                AS 存储过程名称,
       A.create_date         AS 创建日期,
       A.modify_date         AS 修改日期,
	   C.last_elapsed_time/1000000   AS [最后一次运行时间(S)],
	   Total_Elapsed_Time/1000000    AS [总耗时时间(S)],
	   ISNULL(Execution_Count,0)     AS 执行总次数,
	   ISNULL(Last_Execution_Time,'1900-01-01')   AS 最后一次执行时间,
	   DATEDIFF(DAY,A.create_date,GETDATE()) AS [创建天数(天)],
	   CAST(ISNULL(Execution_Count/CAST(DATEDIFF(DAY,A.create_date,Last_Execution_Time) AS decimal(19,3)),0) AS decimal(19,2)) AS [运行频率(次/天)] ,
	   GETDATE() AS [Load_Date]
FROM sys.procedures A 
LEFT JOIN 
	(SELECT   Object_ID, Database_ID, DB_NAME( Database_ID) AS Database_Name,
	 OBJECT_NAME(object_id, database_id) AS SP_Name,  SUM( execution_count) AS Execution_Count,SUM(total_elapsed_time) Total_Elapsed_Time,
	 MAX(  last_execution_time)  as Last_Execution_Time
	 FROM sys.dm_exec_procedure_stats 
	 WHERE  database_id = DB_ID('Foodunion')
	 GROUP BY   object_id,  database_id, DB_NAME( database_id),
	 OBJECT_NAME(object_id, database_id) ) B
 ON A.object_id=B.object_id  
 LEFT JOIN 
	 ( SELECT Object_ID,last_elapsed_time,ROW_NUMBER()OVER(PARTITION BY Object_ID ORDER BY last_execution_time DESC) NUM
	 FROM sys.dm_exec_procedure_stats 
	 WHERE  database_id = DB_ID('Foodunion')) C
 ON A.object_id=C.object_id 
 LEFT JOIN sys.schemas S
 ON A.schema_id=S.schema_id
 WHERE S.name <> 'rpt' OR A.name LIKE '%Update%'
 ORDER BY Schema_Name

END
GO
