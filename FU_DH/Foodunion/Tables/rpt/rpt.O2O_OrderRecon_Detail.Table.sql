USE [Foodunion]
GO
DROP TABLE [rpt].[O2O_OrderRecon_Detail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_OrderRecon_Detail](
	[�����ڼ�] [varchar](17) NULL,
	[�·�] [nvarchar](30) NULL,
	[��������ʱ��] [datetime] NULL,
	[���׳ɹ�ʱ��] [datetime] NULL,
	[������] [varchar](100) NULL,
	[Ψһֵ] [varchar](100) NULL,
	[��Ʒ����] [varchar](128) NULL,
	[��Ʒ����] [varchar](12) NOT NULL,
	[����] [int] NULL,
	[ÿ������] [int] NULL,
	[ÿ�ν��] [decimal](18, 2) NULL,
	[�ڼ������ʹ���] [int] NULL,
	[�ڼ�����������] [int] NULL,
	[���˽��] [decimal](18, 2) NULL,
	[�ڼ������ͽ��] [decimal](18, 2) NULL,
	[�ڼ��˷�] [decimal](9, 2) NULL,
	[��Ʒ��] [varchar](1) NULL,
	[��SKU�Ķ���] [varchar](100) NULL,
	[�˷�] [decimal](18, 2) NOT NULL,
	[������] [varchar](64) NULL,
	[��Ʒ����] [nvarchar](4000) NULL,
	[020�����Ľ�����] [decimal](9, 2) NULL,
	[RSP*����] [decimal](9, 2) NULL,
	[�ۿ�] [decimal](19, 2) NULL,
	[�����ֿ�] [varchar](7) NOT NULL,
	[����Ա��] [varchar](100) NULL,
	[��Ʒ����] [int] NULL,
	[��Ʒʵ�ʳɽ����] [decimal](18, 2) NULL,
	[��Ʒ���˿���] [decimal](11, 2) NOT NULL,
	[�ջ���/�����] [varchar](255) NULL,
	[�ջ����ֻ���/������ֻ���] [varchar](255) NULL,
	[��ϸ�ջ���ַ/�����ַ] [varchar](1277) NULL,
	[�µ�����] [varchar](100) NULL,
	[�̼Ҷ�����ע] [varchar](512) NULL,
	[��Ʒ����״̬] [varchar](6) NOT NULL,
	[��Ʒ������ʽ] [varchar](64) NULL,
	[��Ʒ����ʱ��] [datetime] NULL,
	[��Ʒ�˿�״̬] [varchar](64) NULL,
	[���ڹ���Ϣ] [varchar](200) NULL,
	[��������] [varchar](27) NOT NULL,
	[����Ա] [varchar](100) NOT NULL,
	[�����״���������] [datetime] NULL,
	[��ǰ�ۼ����ʹ���] [int] NULL,
	[��ǰ��Ծ���ĵ�] [varchar](1) NOT NULL,
	[�����ѹ���] [varchar](1) NOT NULL,
	[���ļ�������] [varchar](1) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](39) NOT NULL
) ON [PRIMARY]
GO
