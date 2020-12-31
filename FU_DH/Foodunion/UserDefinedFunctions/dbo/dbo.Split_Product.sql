USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Split_Product] (	@SKU NVARCHAR(MAX))
RETURNS  @ResultTab TABLE
		(SKU_ID NVARCHAR(MAX),
		 QTY  INT)
AS
BEGIN
insert into @ResultTab
(SKU_ID,QTY)
SELECT dbo.split(REPLACE(value,'*','X'),'X',1) as 'SKU_ID'
      ,dbo.split(REPLACE(value,'*','X'),'X',-1) as 'QTY'
FROM string_split(@SKU,'-')


RETURN ;

END;
GO
