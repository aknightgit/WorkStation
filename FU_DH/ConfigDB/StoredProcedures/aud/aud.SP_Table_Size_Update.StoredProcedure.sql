USE [ConfigDB]
GO
DROP PROCEDURE [aud].[SP_Table_Size_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE PROC [aud].[SP_Table_Size_Update]
AS
BEGIN



DROP TABLE IF EXISTS #test_space
create table #test_space(   
name varchar(255),   
[rows] int,   
reserved varchar(50),   
data varchar(50),   
index_size varchar(50),   
unused varchar(50)   
)  
   
insert into #test_space   
exec sp_MSforeachtable "exec sp_spaceused '?'"  
  
DELETE aud.[Table_Size] WHERE Datekey = CONVERT(VARCHAR(8),CAST(GETDATE() AS DATE),112)


INSERT INTO [ConfigDB].[aud].[Table_Size]
(
	   [Datekey]
      ,[name]
      ,[rows]
      ,[reserved]
      ,[data]
      ,[index_size]
      ,[unused]

)
select 
	 CONVERT(VARCHAR(8),CAST(GETDATE() AS DATE),112) AS DATEKEY
	,[name]
    ,[rows]
    ,[reserved]
    ,[data]
    ,[index_size]
    ,[unused]
	from  #test_space     

END
GO
