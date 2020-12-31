USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


   CREATE FUNCTION [dbo].[Format_CleanColumnName](@column NVARCHAR(100))
   RETURNS Nvarchar(100) 
   AS
   BEGIN
	   DECLARE @Newcolumn NVARCHAR(100)
	   SET @Newcolumn = replace(replace(@column,'["',''),'"]','')
	   RETURN @Newcolumn
   END
GO
