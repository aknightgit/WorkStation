USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[usp_ConvertQuery2HTMLTable_2] (@SQLQuery NVARCHAR(3000))
AS
BEGIN
   
	DECLARE @body NVARCHAR(MAX)
	SET     @body = N'<table border="1" style="width:100%">'
		+ CAST((
			SELECT TOP 10 *FROM DM.Dim_Brand
			FOR XML RAW('tr'), ELEMENTS
		) AS NVARCHAR(MAX))
		+ N'</table>'

	SET @body = REPLACE(@body, '<tdc>', '<td class="center">')
	SET @body = REPLACE(@body, '</tdc>', '</td>')

	select @body
END
GO
