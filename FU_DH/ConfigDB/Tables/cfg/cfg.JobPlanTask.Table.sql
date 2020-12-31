USE [ConfigDB]
GO
ALTER TABLE [cfg].[JobPlanTask] DROP CONSTRAINT [DF__JobPlanTa__Updat__5FDE205F]
GO
ALTER TABLE [cfg].[JobPlanTask] DROP CONSTRAINT [DF__JobPlanTa__Inser__5EE9FC26]
GO
ALTER TABLE [cfg].[JobPlanTask] DROP CONSTRAINT [DF__JobPlanTa__IsEna__5DF5D7ED]
GO
DROP TABLE [cfg].[JobPlanTask]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[JobPlanTask](
	[PlanID] [int] NOT NULL,
	[SequenceID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[TaskID] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL,
	[ParallelThreads] [smallint] NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [cfg].[JobPlanTask] ADD  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [cfg].[JobPlanTask] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[JobPlanTask] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
