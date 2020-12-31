USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [dbo].[Format_Number2Thousand](@number float)

RETURNs NVARCHAR(1024)

AS

BEGIN

	DECLARE @out NVARCHAR(1024)

	SELECT @out= REPLACE(convert(varchar,ROUND(CAST(@number AS money),0),1),'.00','')
	--SELECT @out = ISNULL(@out,'');
	RETURN (@out)

end

--select [dbo].[Split]('this is another test',' ',0)
--select charindex('d','adsfalkjds')
GO
