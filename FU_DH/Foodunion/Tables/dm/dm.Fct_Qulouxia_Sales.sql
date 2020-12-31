USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Sales](
	[DATEKEY] [varchar](8) NOT NULL,
	[Order_no] [nvarchar](200) NOT NULL,
	[User_ID] [nvarchar](200) NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[Store_Code] [nvarchar](200) NOT NULL,
	[Store_Name] [nvarchar](200) NULL,
	[Store_Type] [nvarchar](200) NULL,
	[Payment_Method] [nvarchar](200) NULL,
	[Order_Source] [nvarchar](200) NULL,
	[Order_Channel] [nvarchar](200) NULL,
	[Is_Member_Order] [nvarchar](200) NULL,
	[Order_Amount] [decimal](18, 6) NULL,
	[Order_Create_Time] [datetime] NULL,
	[Order_Status] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[Goods_ID] [nvarchar](200) NULL,
	[Goods_Name] [nvarchar](200) NULL,
	[Goods_Category] [nvarchar](200) NULL,
	[Goods_Price_AMT] [decimal](18, 6) NULL,
	[Goods_Cost_AMT] [decimal](18, 6) NULL,
	[Sales_Qty] [decimal](18, 6) NULL,
	[Sales_AMT] [decimal](18, 6) NULL,
	[Discount] [decimal](18, 6) NULL,
	[Discount_AMT] [decimal](18, 6) NULL,
	[Service_Fee] [decimal](18, 6) NULL,
	[Payment] [decimal](18, 6) NULL,
	[Refund_QTY] [decimal](18, 6) NULL,
	[Refund_Type] [nvarchar](200) NULL,
	[Refund_AMT] [decimal](18, 6) NULL,
	[Refund_Time] [nvarchar](200) NULL,
	[Take_Out_Order_ID] [nvarchar](200) NULL,
	[Is_Special_Promotion] [char](1) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](132) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](132) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Sales_2EB8_30C4] PRIMARY KEY CLUSTERED 
(
	[Order_no] ASC,
	[SKU_ID] ASC,
	[Store_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Qulouxia_Sales] ADD  DEFAULT ((0)) FOR [Is_Special_Promotion]
GO
