USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  FUNCTION [dbo].[IndexOfNum](@st int,@s NVARCHAR(255))

RETURNs int

AS

BEGIN

DECLARE @in VARCHAR(255),@out int,@flag int

set @in=RIGHT(@s,LEN(@s)-@st)

set @out=LEN(@in)

set @flag = LEN(@in)

WHILE LEN(@in)>0     
BEGIN
SELECT @out=CASE WHEN /*ASCII(LEFT(@in,1))=63 or*/ (ASCII(LEFT(@in,1)) NOT BETWEEN 48 AND 57) AND @out=@flag THEN @flag-LEN(@in) ELSE @out END,@in=RIGHT(@in,LEN(@in)-1) 
END
RETURN (@out)

end
GO
