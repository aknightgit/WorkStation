USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_LogisticsCost]
AS
BEGIN
	SELECT 
	CONVERT(VARCHAR(8),lc.[Date],112) AS Datekey
	  ,lc.[Date]
      ,CASE lc.[BizType] WHEN '工厂至RDC' THEN '工厂JV to RDC' WHEN '调拨' THEN '调拨Trasnfer' ELSE lc.[BizType] END [BizType]
      ,lc.[Dept]
      ,CASE WHEN lc.[CarType] LIKE '%常温%' THEN '常温车 Ambient Van' ELSE '冷藏车 Fresh Van' END AS CarType 
      ,ISNULL(lc.[SKU_ID], 'Others') AS [SKU_ID]
	  ,ISNULL(p.Product_Sort,'Others') AS [Product_Sort]
      ,lc.[SKU_Name_CN]
      ,lc.[ProduceDate]
      ,lc.[ProduceQTY]
      ,lc.[SaleQTY]
      ,lc.[From]
      ,lc.[To]
      ,lc.[Remarks]
      ,lc.[ProvinceRec]
      ,lc.[AddressRec]
      ,lc.[ContactRec]
      ,lc.[CarScale]
      ,lc.[BaseCost]
      ,lc.[LoadCost]
      ,lc.[AddCost]
      ,lc.[TotalCost]
      ,lc.[Damage]
      ,lc.[Weight_KG]
	  ,ISNULL(CAST(lc.[SaleQTY] AS DECIMAL(9,2)) * p.[Qty_BaseInTray] * p.[Base_Unit_Weight_KG], lc.[Weight_KG])  AS Net_Weight_KG
	  ,DENSE_RANK() OVER(ORDER BY lc.[Date],lc.[BizType],lc.[CarType],lc.[From]) AS CarID
  FROM ODS.[ods].[File_LogisticsCost] lc
  LEFT JOIN dm.Dim_Product p ON lc.SKU_ID = p.SKU_ID
  WHERE lc.[Date]>='2019-5-1'
  --WHERE p.SKU_ID IS NULL
  --WHERE Date='2019-08-01'
  --ORDER BY 1 DESC
END
GO
