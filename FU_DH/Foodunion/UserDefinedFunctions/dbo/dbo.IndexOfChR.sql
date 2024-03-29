﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [dbo].[IndexOfChR](@s NVARCHAR(255))

RETURNs int

AS

BEGIN

DECLARE @in VARCHAR(255),@out int,@flag int

set @in=@s

set @out=LEN(@in)

set @flag = LEN(@in)

WHILE LEN(@in)>0     
BEGIN
SELECT @out=CASE WHEN ASCII(RIGHT(@in,1))=63 or ASCII(RIGHT(@in,1))>127 AND @out=@flag THEN @flag-LEN(@in) ELSE @out END,@in=LEFT(@in,LEN(@in)-1) 
END
RETURN (@out)

end
GO
