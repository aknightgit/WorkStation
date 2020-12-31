USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[Errorlog](
	[ID] [bigint] NOT NULL,
	[DatabaseName] [varchar](100) NULL,
	[ExecName] [varchar](200) NULL,
	[JobID] [int] NULL,
	[ErrorMessage] [nvarchar](2000) NULL,
	[CreateBy] [varchar](200) NULL,
	[CreateTime] [datetime] NULL,
 CONSTRAINT [PK_Errorlog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [aud].[Errorlog] ADD  DEFAULT (getdate()) FOR [CreateTime]
GO
