USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_O2O_OrderRecon_Detail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_O2O_OrderRecon_Detail]
AS
BEGIN

	SELECT [入账期间]
      ,[月份]
      ,[订单创建时间]
      ,[交易成功时间]
      ,[订单号]
      ,[唯一值]
      ,[商品名称]
      ,[商品类型]
      ,[期数]
      ,[每次数量]
      ,[每次金额]
      ,[期间内配送次数]
      ,[期间内配送数量]
      ,[入账金额]
      ,[期间内配送金额]
      ,[期间运费]
      ,[礼品卡]
      ,[无SKU的订单]
      ,[运费]
      ,[规格编码]
      ,[商品编码]
      ,[020渠道的进货价]
      ,[RSP*数量]
      ,[折扣]
      ,[发货仓库]
      ,[发货员工]
      ,[商品数量]
      ,[商品实际成交金额]
      ,[商品已退款金额]
      ,[收货人/提货人]
      ,[收货人手机号/提货人手机号]
      ,[详细收货地址/提货地址]
      ,[下单网点]
      ,[商家订单备注]
      ,[商品发货状态]
      ,[商品发货方式]
      ,[商品发货时间]
      ,[商品退款状态]
      ,[周期购信息]
      ,[订单类型]
      ,[分销员]
      ,[本期首次入账日期]
      ,[当前累计配送次数]
      ,[当前活跃订阅单]
      ,[订阅已过期]
      ,[订阅即将过期]
	FROM [rpt].[O2O_OrderRecon_Detail];


END
GO
