USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [dbo].[Split](@str NVARCHAR(max), @seprator varchar(10), @offset int)

RETURNs NVARCHAR(1024)

AS

BEGIN

	DECLARE @out NVARCHAR(1024)

	--SELECT row_number() OVER(ORDER BY getdate()) rid,Value FROM string_split('this,is,a,test',',');

	IF charindex(@seprator,@str) = 0
	BEGIN
		SELECT @out = NULL
	END
	ELSE IF @offset = -1
	BEGIN
		SELECT TOP 1 @out = Value FROM 
		(SELECT row_number() OVER(ORDER BY getdate()) rid,Value FROM string_split(@str,@seprator))x
		ORDER BY rid DESC;
	END
	ELSE 
	BEGIN
		SELECT @out = Value FROM 
		(SELECT row_number() OVER(ORDER BY getdate()) rid,Value FROM string_split(@str,@seprator))x
		WHERE rid = @offset;
	END

	--SELECT @out = ISNULL(@out,'');
	RETURN (@out)

end

--select [dbo].[Split]('this is another test',' ',0)
--select charindex('d','adsfalkjds')
GO
