USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [rpt].[SP_RPT_CRV_Distribution]
AS 
BEGIN
	SELECT ods.Yearkey
		,Replace(ods.[WeekNo],'W','Week') AS WeekName
		,CAST(Replace(ods.[WeekNo],'W','') AS INT) WeekNo
		  ,ods.[BU]
		  ,ods.[Sort]
		  ,ods.[TargetStore]
		  ,ods.[TargetSKU]
		  ,ods.[ActualStore]
		  ,ods.[ActualSKU]
		  ,ods.[Remark]
		,s.TargetStore AS TargetStoreTol
		,s.[TargetSKU] AS TargetSKUTol
		,CAST(isnull(ods.[ActualStore],0) as DECIMAL(9,2))/ods.TargetStore AS StorePct
		,CAST(isnull(ods.[ActualSKU],0) AS DECIMAL(9,2))/ods.TargetSKU  AS SKUPct
	  FROM [ODS].ods.[File_CRV_Distribution] ods
	  JOIN (SELECT 
		  [Year],Week_of_Year AS Week_Year_NBR,min(Date_Str) AS [Date]
		  FROM dm.[Dim_Calendar] GROUP BY [Year],	Week_of_Year) c
		ON ods.Yearkey = c.[Year] AND CAST(Replace(ods.[WeekNo],'W','') AS INT) = c.Week_Year_NBR
	  LEFT JOIN 
		(SELECT Yearkey,WeekNo,[Sort]
		,SUM([TargetStore]) [TargetStore]
		,SUM([TargetSKU]) [TargetSKU] 
		FROM [ODS].ods.[File_CRV_Distribution] ods
		GROUP BY Yearkey,WeekNo,[Sort]
		)s ON ods.[WeekNo]=s.[WeekNo] AND ods.[Sort]=s.[Sort] AND ods.Yearkey=s.Yearkey
	WHERE c.[Date] < getdate()
	AND ods.BU NOT IN ('Tesco','Suguo');  --9月之前不入场
END
  --LEFT JOIN [FU_EDW].[Dim_Calendar] c ON ods.Yearkey=c.Year

  --select top 10 *from [FU_EDW].[Dim_Calendar]

GO
