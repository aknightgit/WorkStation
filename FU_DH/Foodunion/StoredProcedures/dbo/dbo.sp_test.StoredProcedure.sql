USE [Foodunion]
GO
DROP PROCEDURE [dbo].[sp_test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE    [dbo].[sp_test]
AS
BEGIN
declare @Mindays decimal(18,6)
declare @i int
set @Mindays=0
set @i=1
select * FROM  [Foodunion].[dbo].[test]  where rn=@i
  while @@ROWCOUNT>0
  begin update  [Foodunion].[dbo].[test]  set test=(case when [Fresh_Days]-@Mindays>out_days 
  then out_days else [Fresh_Days]-@Mindays end) where rn=@i
   declare @freshdays decimal(18,6)
  set @FRESHDAYS = (select TEST FROM  [Foodunion].[dbo].[test]  where rn=@i)
  set @i=@i+1
  set @Mindays=@Mindays+@freshdays
  select * FROM  [Foodunion].[dbo].[test]  where rn=@i
  end 
END
GO
