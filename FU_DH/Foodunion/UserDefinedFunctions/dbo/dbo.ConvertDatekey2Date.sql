USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  FUNCTION [dbo].[ConvertDatekey2Date](@datekey char(8))

RETURNs NVARCHAR(1024)

AS

BEGIN

	DECLARE @out NVARCHAR(1024)

	SELECT @out= CAST(left(@datekey,4) +'-'+ SUBSTRING(@datekey,5,2) +'-'+ right(@datekey,2) AS DATE)
	--SELECT @out = ISNULL(@out,'');
	RETURN (@out)

end

--select [dbo].[Split]('this is another test',' ',0)
--select charindex('d','adsfalkjds')
GO
