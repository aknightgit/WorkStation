DECLARE @Server varchar(100);
SELECT @Server=@@SERVERNAME

PRINT 'Deploy ConfigDB ON '+@Server;

SET NOCOUNT ON;

use [ConfigDB]
GO

--cfg.JobPlans;
TRUNCATE TABLE cfg.JobPlans;
GO
SET IDENTITY_INSERT cfg.JobPlans ON;
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 0, 'FUDH 0AM Daily','ak.wang@foodunion.com.cn','FUNCHINA.BI@foodunion.com.cn;cn_sh_team_it@foodunion.com;',NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 1, 'FUDH SLA Daily','ak.wang@foodunion.com.cn','FUNCHINA.BI@foodunion.com.cn;cn_sh_team_it@foodunion.com;',NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 2, 'FUDH Hourly Job','ak.wang@foodunion.com.cn','FUNCHINA.BI@foodunion.com.cn;',NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 3, 'FUDH Onetime Load','ak.wang@foodunion.com.cn','',NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 4, 'FUDH YH Load','ak.wang@foodunion.com.cn','FUNCHINA.BI@foodunion.com.cn;cn_sh_team_it@foodunion.com',NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 5, 'FUDH Audit Alert','ak.wang@foodunion.com.cn','FUNCHINA.BI@foodunion.com.cn',NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlans (PlanID,PlanDescription,NotificationDL,NotificationCC,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 6, 'FUDH Generate&Export','ak.wang@foodunion.com.cn','FUNCHINA.BI@foodunion.com.cn',NULL,NULL,GETDATE(),GETDATE();
SET IDENTITY_INSERT cfg.JobPlans OFF;
GO
select * from cfg.JobPlans;


GO

--cfg.JobGroups;
TRUNCATE TABLE cfg.JobGroups;
GO
SET IDENTITY_INSERT cfg.JobGroups ON;
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 1, 'File Import - Onetime','Deal onetime historical FlatFile sources, import to STG',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 2, 'Data Import - Routine','Deal routine FlatFile/Data sources, import to STG',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 3, 'STG_2_ODS','Load STG into ODS',1,GETDATE(),GETDATE();
--INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
--SELECT 4, 'ODS_2_DM','Load ODS into FoodUnion DB',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 4, 'DM Procedures','Run Procedures Process in FoodUnion',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 5, 'RPT Update','Upddate RPT tables in FoodUnion',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 6, 'ConfigDB Update','ConfigDB Procedure Process',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 7, 'Other Executebales','System command or Executbales',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 8, 'Export Data','Export and push data to external',1,GETDATE(),GETDATE();
INSERT INTO cfg.JobGroups (GroupID,GroupName,GroupDescription, IsEnabled,InsertDatetime,UpdateDatetime)
SELECT 9, 'Others','Others',1,GETDATE(),GETDATE();
SET IDENTITY_INSERT cfg.JobGroups OFF;
GO
select * from cfg.JobGroups;


GO

--cfg.JobPlanTask;
TRUNCATE TABLE cfg.JobPlanTask;
GO

-------------------
-- PlanID = 0  0AM DAILY
-------------------
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 0, 2002,2,262,1,4,GETDATE(),GETDATE();				--EDI_YH_Inventory


-------------------
-- PlanID = 1 DAILY
-------------------
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,201,1,4,GETDATE(),GETDATE();		--File_Product
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,203,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,205,0,4,GETDATE(),GETDATE();  		--TP FILE COPY
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,204,1,4,GETDATE(),GETDATE();		--File_YHStore_glzx
--Wechat Fans/Orders
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,206,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,207,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,208,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,209,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,210,1,4,GETDATE(),GETDATE();		--File_Tmall_DailyPayment
--ERP
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,211,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,212,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,213,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,214,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,215,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,216,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,217,1,4,GETDATE(),GETDATE();				--Load_ERP_Stock_OutStock
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,218,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,219,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,220,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,221,1,4,GETDATE(),GETDATE();				--SCRM O2OMapping

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2004,2,223,1,4,GETDATE(),GETDATE();	 			-- Foodunion API
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,224,1,4,GETDATE(),GETDATE();				-- ReturnStock
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,225,1,4,GETDATE(),GETDATE();				-- MiscStock
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,228,1,4,GETDATE(),GETDATE();				-- Baidu Location API
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2004,2,230,0,4,GETDATE(),GETDATE();				-- File_Tmall_MonthlyReport

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2004,2,234,1,4,GETDATE(),GETDATE();				-- Vanguard Stores
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2005,2,235,0,4,GETDATE(),GETDATE();				-- Youzan Stores/Employee

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2005,2,236,1,4,GETDATE(),GETDATE();				-- Load_ERP_Stock_PurchaseOrder
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,240,1,4,GETDATE(),GETDATE();				-- Load_OMS_Orders
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2005,2,241,1,4,GETDATE(),GETDATE();				-- File_MiniSOP
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2004,2,244,1,4,GETDATE(),GETDATE();				-- File_Sales_SellOutTarget_KA
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2006,2,245,1,4,GETDATE(),GETDATE();				-- File_Youzan_CommStoreOrder

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,246,1,4,GETDATE(),GETDATE();				--File_Customer_Mapping_Fin

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2007,2,247,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2008,2,252,0,4,GETDATE(),GETDATE();              --File_MKT_Prouducts_Barcode

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2005,2,249,1,4,GETDATE(),GETDATE();				-- File_DemandPlanning

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2005,2,254,1,4,GETDATE(),GETDATE();				-- Load_OMS_Channel

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,255,1,4,GETDATE(),GETDATE();				--Load_OMS_OrderOthers

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2003,2,258,1,4,GETDATE(),GETDATE();				--Load_OMS_Refunds_Trade
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,260,1,4,GETDATE(),GETDATE();				--File_Sales_SellInOutTarget_KA


INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,263,1,4,GETDATE(),GETDATE();				--File_Product_VICVLC

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,274,1,4,GETDATE(),GETDATE();                                                          --LOAD SCRM2_WechatUser

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2002,2,276,1,4,GETDATE(),GETDATE();                --FXXK Load_Fxxk_AllInOne

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2004,2,280,1,4,GETDATE(),GETDATE();                --KA Product List

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,281,1,4,GETDATE(),GETDATE();                                                            -- O2O FILE ORDER DATA


INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 2001,2,285,1,4,GETDATE(),GETDATE();                --FXXK Load_Fxxk_EmpDepAccount




--TP Order
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 3001,3,303,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 3002,3,301,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 3003,3,302,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 3003,3,304,0,4,GETDATE(),GETDATE();

--ODS Procs
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 3001,3,305,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 3002,3,306,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 3003,3,307,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 3001,3,308,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 3001,3,309,1,4,GETDATE(),GETDATE();				--SCRM O2OMapping
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 3002,3,311,1,4,GETDATE(),GETDATE();				--SCRM Youzan store

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 1001,3,312,1,4,GETDATE(),GETDATE();				--update calendar

--StoreProc
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 1001,4,400,1,4,GETDATE(),GETDATE();			--dm.Dim_Calendar
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,401,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,402,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,403,1,4,GETDATE(),GETDATE();  --[dm].[SP_Dim_Store_Update] Infer Stores first
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,404,1,4,GETDATE(),GETDATE();  --Dim_Product, run after 413
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,405,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,406,1,4,GETDATE(),GETDATE();		--[dm].[SP_Dim_Employee_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,408,1,4,GETDATE(),GETDATE();		--[dm].[SP_Fct_O2O_FansOrder_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,409,1,4,GETDATE(),GETDATE();		--[dm].[SP_Dim_ERP_CustomerList_Update] / [dm].[Dim_ERP_Customer_Shipto]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,2,250,1,4,GETDATE(),GETDATE();		-- Load_ERP_CustomerList_Location_Baidu
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4004,2,248,1,4,GETDATE(),GETDATE();		-- Load_ERPShipTo_Location_Baidu


INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,410,1,4,GETDATE(),GETDATE();		-- [dm].[SP_Fct_ERP_Sale_Order_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,2,251,1,4,GETDATE(),GETDATE();		-- Load_ERP_SaleOrder_Location_Baidu

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,411,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,412,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,413,1,4,GETDATE(),GETDATE();		--Convert Rate, run at the very beginning
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,414,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,415,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 4003,4,416,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,417,0,4,GETDATE(),GETDATE();		--[dm].[SP_Dim_ERP_CustomerMapping_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,418,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4004,4,419,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4004,4,421,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4004,4,422,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4004,4,424,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,434,1,4,GETDATE(),GETDATE();		 --Fct_O2O_wx_ApplyData 
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,435,1,4,GETDATE(),GETDATE();		 --Fct_O2O_wx_Applylist 
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 4001,4,436,1,4,GETDATE(),GETDATE();		 --Dim_Order
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,436,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Order_ALLin1_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,437,0,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Order_Item_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,438,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Dim_Product_Leadtime_Update]
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 4004,4,441,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_Channel]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4005,4,442,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Production_DemandPlanning_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,443,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_ERP_Stock_MiscStock_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4006,4,444,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_KAStore_DailySalesInventory_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4006,4,445,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_KAStore_SalesTarget_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4004,4,446,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_ERP_Stock_PurchaseOrder_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4008,4,441,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellOut_ByChannel_ByRegion_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4009,4,447,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellOut_ByChannel_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,448,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Dim_Channel_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4005,4,449,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellIn_ByChannel_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,450,1,4,GETDATE(),GETDATE();		 --Fct_Sales_SellInTarget_ByChannel
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,420,1,4,GETDATE(),GETDATE();      	 --SP_Fct_YH_Target_Weekly
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 4001,4,451,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Order_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,460,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Dim_Customer_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4003,4,462,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellInOutTarget_ByKAarea_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,468,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellInOutTarget_byStore_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,465,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,466,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Dim_Store_SalesPerson_Monthly_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4006,4,467,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Dim_Product_VICVLC_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4006,4,464,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_ERP_Inventory_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4006,4,472,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellIn_ByChannel_Monthly_Update] 
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4007,4,483,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellIn_ByChannel_Monthly_Update] 

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4002,4,481,1,4,GETDATE(),GETDATE();		--[dm].[SP_Dim_Store_Fxxk_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 4001,4,482,1,4,GETDATE(),GETDATE();		--[dm].[SP_Dim_Department_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,501,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,514,1,4,GETDATE(),GETDATE();		--[rpt].[SP_O2O_Employee_Order_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,515,1,4,GETDATE(),GETDATE();		--[rpt].[SP_O2O_Employee_Commission_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,502,1,4,GETDATE(),GETDATE();		--[rpt].[SP_O2O_OrderRecon_Detail_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,524,1,4,GETDATE(),GETDATE();		 --[rpt].[SP_YH门店商品库存缺货日报_Update]


INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,517,1,4,GETDATE(),GETDATE();		--[rpt].[O2O_Order_Base_info_Delivery]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,518,1,4,GETDATE(),GETDATE();		--[rpt].[SP_O2O_Order_Base_info_MRR_By_Month_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 5001,5,520,1,4,GETDATE(),GETDATE();		--[rpt].[SP_Order_Customer_list_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 6001,6,602,1,4,GETDATE(),GETDATE();		--[aud].[Database_Monitor_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 8001,8,801,1,4,GETDATE(),GETDATE();  		--Export data to MDMExchange

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 8002,8,805,0,4,GETDATE(),GETDATE();  		--Export Lakto_offline_l3m

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 8003,8,807,1,4,GETDATE(),GETDATE();  		 --推送主数据到FXXK，本步骤必须绑定和Load_Fxxk_EmpDepAccount绑定一起跑

--Cleanup Archive Objects
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 9001,3,310,1,4,GETDATE(),GETDATE();		--Clean up archive objects in ODS 
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 9001,4,425,1,4,GETDATE(),GETDATE();		--Clean up archive objects in Foodunion
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 1, 9999,5,599,1,4,GETDATE(),GETDATE();		--[dbo].[USP_CreateDBSnapshot]



-------------------
-- PlanID = 2 HOURLY
-------------------
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2001,2,222,1,4,GETDATE(),GETDATE();				--YH 进销存基础数据
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2003,2,227,0,4,GETDATE(),GETDATE();				-- Kidswant
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2003,2,229,1,4,GETDATE(),GETDATE();				-- Inventory
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2002,2,231,1,4,GETDATE(),GETDATE();				-- CRV POS
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2003,2,232,1,4,GETDATE(),GETDATE();				-- plant
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2003,2,239,1,4,GETDATE(),GETDATE();				-- SG
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,233,1,4,GETDATE(),GETDATE();				-- Youzan Recon财务入账明细
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,242,1,4,GETDATE(),GETDATE();				-- qulouxia sales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,243,1,4,GETDATE(),GETDATE();				-- CenturyMart sales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2002,2,253,1,4,GETDATE(),GETDATE();				--Huaguan_DailyData

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2002,2,256,1,4,GETDATE(),GETDATE();				--Shuaibao_DailySales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2002,2,257,1,4,GETDATE(),GETDATE();				--HDX_DailySales

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2002,2,259,1,4,GETDATE(),GETDATE();				--Shunlian_DailySales

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2002,2,261,1,4,GETDATE(),GETDATE();				--File_YH_DailyInventory

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,271,1,4,GETDATE(),GETDATE();				-- qulouxia Inventory

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,273,1,4,GETDATE(),GETDATE();				-- qulouxia storeorders

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,275,1,4,GETDATE(),GETDATE();				-- qulouxia GoodsPassage

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,277,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,278,1,4,GETDATE(),GETDATE();				-- qulouxia 

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,279,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2004,2,282,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4001,4,403,1,4,GETDATE(),GETDATE();				--[dm].[SP_Dim_Store_Update] Infer Stores first
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,423,0,4,GETDATE(),GETDATE();				--Kidswant

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,433,1,4,GETDATE(),GETDATE();				--Fct_Inventory

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,426,1,4,GETDATE(),GETDATE();				--[dm].[SP_Fct_YH_JXT_Daily_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4002,4,439,1,4,GETDATE(),GETDATE();				--[dm].[SP_Fct_CRV_DailySales_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4002,4,440,1,4,GETDATE(),GETDATE();				--[dm].[SP_Fct_CRV_DailyInventory_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,451,1,4,GETDATE(),GETDATE();				--Qulouxia
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,461,1,4,GETDATE(),GETDATE();				--CenturyMart

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4009,4,471,1,4,GETDATE(),GETDATE();		 		--[dm].[SP_Fct_KAStore_DailySalesInventory_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,475,1,4,GETDATE(),GETDATE();				--Qulouxia GoodsPassage

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,477,1,4,GETDATE(),GETDATE();	                                                 --Qulouxia Handing fee

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4005,4,478,1,4,GETDATE(),GETDATE();				--Qulouxia

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 4004,4,479,1,4,GETDATE(),GETDATE();	

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 5001,5,516,1,4,GETDATE(),GETDATE();				--[dm].[SP_Fct_Youzan_Recon]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 5001,5,519,1,4,GETDATE(),GETDATE();				--[dm].[SP_Fct_Youzan_Revenue_Details]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 6100,6,601,1,4,GETDATE(),GETDATE();				--[aud].[ReportSourceMapping_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2003,2,267,1,4,GETDATE(),GETDATE();	                                                --Dim_Product_OutSKUMapping

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 2003,2,268,0,4,GETDATE(),GETDATE();	                                                --Dim_Product_OutSKUMapping

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 2, 1001,7,701,0,4,GETDATE(),GETDATE();

-------------------
-- PlanID = 3 ONETIME
-------------------

--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 3, 1001,1,1,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 3, 1001,1,2,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 1001,2,201,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 1, 1001,2,202,1,4,GETDATE(),GETDATE();

-------------------
-- PlanID = 4 YH
-------------------
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2001,2,204,1,4,GETDATE(),GETDATE();		--File_YHStore_glzx
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2001,2,226,1,4,GETDATE(),GETDATE();		--Load_EDI_YH_Sales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2001,2,237,1,4,GETDATE(),GETDATE();		--Load_CRV_DailySales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,228,1,4,GETDATE(),GETDATE();		--Baidu Location API
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,270,1,4,GETDATE(),GETDATE();		 --File_Qulouxia_DC2Box
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,269,1,4,GETDATE(),GETDATE();		 --File_Qulouxia_DCInventory
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,272,1,4,GETDATE(),GETDATE();		 --File_YH_KPIDB
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,283,0,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2001,2,284,0,4,GETDATE(),GETDATE();


INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4003,4,439,1,4,GETDATE(),GETDATE();		--CRV Sales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4003,4,440,1,4,GETDATE(),GETDATE();		--CRV Inventory
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4001,4,403,1,4,GETDATE(),GETDATE();		--[dm].[SP_Dim_Store_Update] Infer Stores first
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4002,4,470,1,4,GETDATE(),GETDATE();		--[dm].[SP_Fct_Qulouxia_DC2Box_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4004,4,469,1,4,GETDATE(),GETDATE();		--[dm].[SP_Fct_Qulouxia_DCInventory_Daily_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4004,4,426,1,4,GETDATE(),GETDATE();		--[dm].[SP_Fct_YH_JXT_Daily_Update]
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4004,4,427,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4004,4,428,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4004,4,429,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4004,4,430,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4004,4,431,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4004,4,432,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4005,5,453,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,452,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,454,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,455,0,4,GETDATE(),GETDATE();		--[dm].[SP_Fct_Sales_Plan_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,456,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,457,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,458,1,4,GETDATE(),GETDATE();

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,463,1,4,GETDATE(),GETDATE();       --SP_Fct_YH_Store_DailyOrders_Update

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4004,4,473,1,4,GETDATE(),GETDATE();		--[dm].[SP_Fct_YH_KPIDB_Upsert]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,4,474,1,4,GETDATE(),GETDATE();	    --[dm].[SP_Fct_YH_Maco_Per_Store_Upsert]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4003,4,476,1,4,GETDATE(),GETDATE();	    --[dm].[SP_Fct_FXXK_KAStoreVisit_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4005,4,480,0,4,GETDATE(),GETDATE();	    --[dm].[SP_Fct_POP6_Visit_Update]



--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4006,5,510,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,4,459,1,4,GETDATE(),GETDATE();
--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 4006,5,512,1,4,GETDATE(),GETDATE();
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4006,5,513,1,4,GETDATE(),GETDATE();

--刷新KAStore表
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4009,4,471,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_KAStore_DailySalesInventory_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4009,4,445,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_KAStore_SalesTarget_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4010,4,441,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellOut_ByChannel_ByRegion_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 4011,4,447,1,4,GETDATE(),GETDATE();		 --[dm].[SP_Fct_Sales_SellOut_ByChannel_Update]

--INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
--SELECT 4, 5001,5,521,0,4,GETDATE(),GETDATE();		 --[rpt].[SP_Sales_销售区域达成日报_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5002,5,522,0,4,GETDATE(),GETDATE();		 --[rpt].[SP_Sales_销售渠道客户达成日报_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5002,5,523,0,4,GETDATE(),GETDATE();		 --[rpt].[SP_Sales_销售渠道客户达成日报_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5003,5,525,1,4,GETDATE(),GETDATE();		 --[rpt].[SP_Sales_YH门店商品库存明细60天_Update]
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5003,5,526,0,4,GETDATE(),GETDATE();		 --[rpt].[SP_Sales_销售代表月度指标达成日报_Update]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5004,5,527,1,4,GETDATE(),GETDATE();		 --[rpt].[SP_Sales_YH门店商品库存OOS明细60天_Update]


INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5099,5,599,1,4,GETDATE(),GETDATE();		 --[dbo].[USP_CreateDBSnapshot]

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5099,8,808,1,4,GETDATE(),GETDATE();  		 --Load_Fxxk_StoreSalesPush

INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5010,8,802,1,4,GETDATE(),GETDATE();  		 --Export data to MDMExchange
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5011,8,238,1,4,GETDATE(),GETDATE();  		 --Load TMKT DATA AND Export data to Mail
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5012,8,804,1,4,GETDATE(),GETDATE();  		 --Export KA data to Sharepoint
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 5003,8,806,1,4,GETDATE(),GETDATE();  		 --Export YH门店商品库存缺货日报


-- PlanID = 4 YH EDI
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2002,2,264,1,4,GETDATE(),GETDATE();		 --EDI_YH_Sales
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,265,1,4,GETDATE(),GETDATE();		 --EDI_YH_SalesRatio
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 4, 2003,2,266,1,4,GETDATE(),GETDATE();		 --EDI_YH_StoreOrders


-------------------
-- PlanID = 5 Audit Alert
-------------------
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 5, 9001,9,999,1,1,GETDATE(),GETDATE();   	--RunAudit


-------------------
-- PlanID = 6 Generate&Export
-------------------
INSERT INTO cfg.JobPlanTask (PlanID,SequenceID,GroupID,TaskID,IsEnabled,ParallelThreads,InsertDatetime,UpdateDatetime)
SELECT 6, 8003,8,803,1,4,GETDATE(),GETDATE();  		--Generate_DBScripts_ASFiles 

GO
select * from cfg.JobPlanTask order by 1,2,3;

----------------------cfg.JobTasks;
TRUNCATE TABLE cfg.JobTasks;
GO
SET IDENTITY_INSERT cfg.JobTasks ON;
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 101, 1,'','Excel SCRM Lakto_zjmd_1203','CallJob','','File_Lakto_zjmd_1203',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 102, 1,'','Excel SCRM Lakto_zjmd_20190213','CallJob','','File_Lakto_zjmd_20190213',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

--Load into STG/ODS
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 201, 2,'','Load File_Product','CallJob','','File_Product',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 202, 2,'','File_Store','CallJob','','File_Store',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 203, 2,'','Load YH Store Target_BM_PG','CallJob','','File_YHStore_BMTarget',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 204, 2,'','Load File YHStore_glzx','CallJob','','File_YHStore_glzx',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 205, 2,'TP','Copy TPOrder xml files from FTP','CallJob','','Copy_FTP_TPOrder',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 206, 2,'SCRM','Load Orders from SCRM','CallJob','','Load_SCRM_Orders',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 207, 2,'SCRM','Load WechatFans from SCRM','CallJob','','Load_SCRM_WechatFans',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 208, 2,'SCRM','Load Wechat Fans from FGF','CallJob','','Load_FGF_MWCWechat',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 209, 2,'ERP','Load SKU/RSP from ERP','CallJob','','Load_ERP_SKU_RSP',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 210, 2,'','Load Tmall DailyPayment Summary to ODS','CallJob','','File_Tmall_DailyPayment',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 211, 2,'ERP','Load ERP Stock Inventory','CallJob','','Load_ERP_Stock_Inventory',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 212, 2,'SCRM','Load SCRM Member Info','CallJob','','Load_SCRM_MemberInfo',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 213, 2,'ERP','Load Sale-In Order from ERP','CallJob','','Load_ERP_Sale_Order',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 214, 2,'ERP','Load Unit ConvertRate from ERP','CallJob','','Load_ERP_UnitConvertRate',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 215, 2,'ERP','Load Customer List from ERP','CallJob','','Load_ERP_Customer',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 216, 2,'ERP','Load InStock records from ERP','CallJob','','Load_ERP_Stock_InStock',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 217, 2,'ERP','Load OutStock records from ERP','CallJob','','Load_ERP_Stock_OutStock',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 218, 2,'','Load SaleIn target from File','CallJob','','File_Sales_SellInTarget',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 219, 2,'ERP','Load TransferIN records from ERP','CallJob','','Load_ERP_Stock_TransferIN',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 220, 2,'ERP','Load TransferOUT records from ERP','CallJob','','Load_ERP_Stock_TransferOUT',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 221, 2,'SCRM','Load O2OMapping from File','CallJob','','Load_SCRM_O2OMapping',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 222, 2,'','Load YH Daily Orders and Sales','CallJob','','File_YH_JXT',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 223, 2,'SCRM','Load WX Foodunion Applylist','CallJob','','Load_WX_Foodunion_Applylist',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 224, 2,'ERP','Load ReturnStock records from ERP','CallJob','','Load_ERP_Stock_ReturnStock',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 225, 2,'ERP','Load MiscStock records from ERP','CallJob','','Load_ERP_Stock_MiscStock',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 226, 2,'','Load YH Sales from EDI','CallJob','','Load_EDI_YH_Sales',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();   --4月Mongo YH EDI失效

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 227, 2,'','Load Kidwant Sales from File','CallJob','','File_Kidswant_DailySales',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 228, 2,'','Load Store Location from BaiduAPI','CallJob','','Load_Store_Location_Baidu',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 229, 2,'','Load Inventory from File','CallJob','','File_Inventory',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 230, 2,'','Load Tmall OMS/Qianniu File','CallJob','','File_Tmall_MonthlyReport',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 231, 2,'','Load CRV DailyPos File','CallJob','','Load_CRV_DailySales',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 232, 2,'','Load Plant from File','CallJob','','File_Plant',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 233, 2,'','Load Youzan Recon from File','CallJob','','File_Youzan_Order_MonthlyRecon',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 234, 2,'','Load Vanguard Stores','CallJob','','File_VanguardStore_CRV',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 235, 2,'SCRM','Load youzan Employee Store','CallJob','','Load_SCRM_EmployeeStore',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 236, 2,'ERP','Load PurchaseOrder records from ERP','CallJob','','Load_ERP_Stock_PurchaseOrder',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 237, 2,'','Load CRV Sales from Mongo','CallJob','','Load_Mongo_CRV_Sales',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 238, 2,'','Load TMKT AND SEND MAIL','CallJob','','File_TMKT_MD',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 239, 2,'','Load SG DailySales File','CallJob','','File_SG_DailySales',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 240, 2,'OMS','Load Orders Infomation From OMS','CallJob','','Load_OMS_Orders',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 241, 2,'','Load MiniSOP forecast files','CallJob','','File_MiniSOP',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 242, 2,'','Load Qulouxia Sales files','CallJob','','File_Qulouxia',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 243, 2,'','Load CenturyMart Sales files','CallJob','','File_CenturyMart',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 244, 2,'','Load Sellout Target by KA','CallJob','','File_Sales_SellOutTarget_KA',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 245, 2,'','Load CommStoreOrder from Youzan','CallJob','','File_Youzan_CommStoreOrder',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 246, 2,'','Load File_Customer_Mapping_Fin','CallJob','','File_Customer_Mapping_Fin',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 247, 2,'','Load CPManagerTarget from Target','CallJob','','File_CP_ManagerTarget',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 248, 2,'','Load Province/City for [dm].[Dim_ERP_Customer_Shipto]','CallJob','','Load_ERPShipTo_Location_Baidu',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 249, 2,'','Load File_DemandPlanning','CallJob','','File_DemandPlanning',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 250, 2,'','Load ERP_CustomerList Location','CallJob','','Load_ERP_CustomerList_Location_Baidu',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 251, 2,'','Load ERP_SaleOrder Location','CallJob','','Load_ERP_SaleOrder_Location_Baidu',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 252, 2,'','Load MKT Prouducts Barcode','CallJob','','File_MKT_Prouducts_Barcode',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 253, 2,'','Load Huaguan Daily Data','CallJob','','File_Huaguan_DailyData',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 254, 2,'OMS','Load OMS Channel Infomation','CallJob','','Load_OMS_Channel',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 255, 2,'OMS','Load OrderOthers Infomation From OMS','CallJob','','Load_OMS_OrderOthers',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 258, 2,'OMS','Load Order Refunds Infomation From OMS','CallJob','','Load_OMS_Refunds_Trade',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 256, 2,'EC-EKA','Load Shuaibao_DailySales','CallJob','','File_Shuaibao_DailySales',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 257, 2,'EC-EKA','Load HDX_DailySales','CallJob','','File_HDX_DailySales',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 259, 2,'','Load Shunlian_DailySales','CallJob','','File_Shunlian_DailySales',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 260, 2,'','SellInOutTarget|SalesTerritory|StoreSalesPerson','CallJob','','File_Sales_SellInOutTarget_KA',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 261, 2,'','Load YH DailyInventory','CallJob','','File_YH_DailyInventory',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();  --File_YH_DailyInventory

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 263, 2,'','Load Product_VICVLC','CallJob','','File_Product_VICVLC',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();  --File_Product_VICVLC

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 262, 2,'EDI','Load EDI_YH_Inventory','CallJob','','EDI_YH_Inventory',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();  --EDI_YH_Inventory
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 264, 2,'EDI','Load EDI_YH_Sales','CallJob','','EDI_YH_Sales','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 265, 2,'EDI','Load EDI_YH_SalesRatio','CallJob','','EDI_YH_SalesRatio','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 266, 2,'EDI','Load EDI_YH_StoreOrders','CallJob','','EDI_YH_StoreOrders','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 267, 2,'','File_Product_AccountCodeMapping','CallJob','','File_Product_AccountCodeMapping','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 268, 2,'','File_KAStore_SalesMD','CallJob','','File_KAStore_SalesMD','',NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 269, 2,'','File_Qulouxia_DCInventory','CallJob','','File_Qulouxia_DCInventory','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 270, 2,'','File_Qulouxia_DC2Box','CallJob','','File_Qulouxia_DC2Box','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 271, 2,'','File_Qulouxia_Inventory','CallJob','','File_Qulouxia_Inventory','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 272, 2,'','File_YH_KPIDB','CallJob','','File_YH_KPIDB','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 273, 2,'','File_Qulouxia_StoresOrders','CallJob','','File_Qulouxia_StoresOrders','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 274, 2,'SCRM2','Load_SCRM2_WechatUser','CallJob','','Load_SCRM2_WechatUser',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 275, 2,'','File_Qulouxia_GoodsPassage','CallJob','','File_Qulouxia_GoodsPassage','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 276, 2,'FXXK','Load_Fxxk_AllInOne','CallJob','','Load_Fxxk_AllInOne',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 277, 2,'','File_Qulouxia_Handing_SMS_Fee','CallJob','','File_Qulouxia_Handing_SMS_Fee','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 278, 2,'','File_Qulouxia_OtherData','CallJob','','File_Qulouxia_OtherData','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 279, 2,'','File_YH_Store_Order_Satisfaction_Rate','CallJob','','File_YH_Store_Order_Satisfaction_Rate','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 280, 2,'','File_KA_Product_List','CallJob','','File_KA_Product_List','',NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 281, 2,'','File_Youzan_StoreOrder','CallJob','','File_Youzan_StoreOrder',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 282, 2,'','File_DataLoad_For_Report','CallJob','','File_DataLoad_For_Report','',NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 283, 2,'','File_POP6_AllInOne','CallJob','','File_POP6_AllInOne','',NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 284, 2,'','File_POP6_CopyFromFTP','CallJob','','File_POP6_CopyFromFTP','',NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 285, 2,'FXXK','Load_Fxxk_EmpDepAccount','CallJob','','Load_Fxxk_EmpDepAccount',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();



--Into ODS
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 301, 3,'TP','Load_TPOrder','CallJob','','Load_TPOrder',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 302, 3,'TP','Load_TPOrder_Refund','CallJob','','Load_TPOrder_Refund',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 303, 3,'TP','Load_TPOrder_CombineItem','CallJob','','Load_TPOrder_CombineItem',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 304, 3,'TP','Load_TPOrder_Shipment','CallJob','','Load_TPOrder_Shipment',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();

--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 305, 3,'SCRM','Load Wechat Fans to ODS','Stored Procedure','','','[ods].[SP_SCRM_Wechat_Fans_Upsert]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 306, 3,'SCRM','Load SCRM Order to ODS','Stored Procedure','','','[ods].[SP_SCRM_Order_Upsert]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 307, 3,'SCRM','Load FGF WecharFans to ODS','Stored Procedure','','','[ods].[SP_FGF_WeChat_update]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 404, 4,'Load SKU/RSP list to ODS','Stored Procedure','','','[ods].[SP_ERP_SKU_Upsert]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 308, 3,'SCRM','Load glzx YHStore to ods.Dim_store','Stored Procedure','','','[ods].[SP_Dim_Store_Upsert]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 309, 3,'SCRM','Load SCRM O2OMapping to ODS','Stored Procedure','','','[ods].[SP_SCRM_O2OMapping_Upsert]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 310, 3,'','DELETE BACKUP TABLE IN ODS','Stored Procedure','','','[ODS].[SP_Remove_Archive_Tables]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 311, 3,'SCRM','Load youzan_store to ODS','Stored Procedure','','','[ods].[SP_SCRM_youzan_EmployeeStore_Upsert]',NULL,1,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 312, 3,'','Update Calendar','Stored Procedure','','','[FU_EDW].[SP_Dim_Calendar]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();

--DM Procedures
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 400, 4,'','Update Dim_Calendar','Stored Procedure','','','[dm].[SP_Dim_Calendar_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 401, 4,'','Update [dm].[Dim_Product_Channel_Mapping]','Stored Procedure','','','[dm].[SP_Dim_Product_Channel_Mapping_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 402, 4,'TP','Update TP Orders','Stored Procedure','','','[dm].[SP_TP_Order_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 403, 4,'','Update [dm].[Dim_Store]','Stored Procedure','','','[dm].[SP_Dim_Store_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 404, 4,'','Update [dm].[Dim_Product]','Stored Procedure','','','[dm].[SP_Dim_Product_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 405, 4,'ERP','Update [dm].[Dim_Product_Pricelist]','Stored Procedure','','','[dm].[SP_Dim_Product_Pricelist_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 406, 4,'','[dm].[SP_Dim_Employee_Update]','Stored Procedure','','','[dm].[SP_Dim_Employee_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 408, 4,'SCRM','Update O2O Orders and Fans From ODS','Stored Procedure','','','[dm].[SP_Fct_O2O_FansOrder_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 409, 4,'ERP','Update [dm].[Dim_ERP_CustomerList] From ODS','Stored Procedure','','','[dm].[SP_Dim_ERP_CustomerList_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 410, 4,'ERP','Update [dm].[Fct_ERP_Sale_Order] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Sale_Order_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 411, 4,'ERP','Update [dm].[Fct_ERP_Sale_OrderEntry] From ODS]','Stored Procedure','','','[dm].[SP_Fct_ERP_Sale_OrderEntry_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 412, 4,'ERP','Update [dm].[Fct_ERP_Stock_Inventory] From ODS]','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_Inventory_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 413, 4,'ERP','Update [dm].[Dim_ERP_Unit_ConvertRate] From ODS','Stored Procedure','','','[dm].[SP_Dim_ERP_Unit_ConvertRate_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 414, 4,'ERP','Update [dm].[Fct_ERP_Stock_InStock] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_InStock_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 415, 4,'ERP','Update [dm].[Fct_ERP_Stock_OutStock] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_OutStock_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 416, 4,'','Update [dm].[Fct_Sales_SellInTarget] From ODS','Stored Procedure','','','[dm].[SP_Fct_Sales_SellInTarget_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 417, 4,'ERP','Update [dm].[Dim_ERP_CustomerMapping] From ODS','Stored Procedure','','','[dm].[SP_Dim_ERP_CustomerMapping_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 418, 4,'ERP','Update [dm].[Fct_ERP_Stock_TransferIn] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_TransferIn_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 419, 4,'ERP','Update [dm].[Fct_ERP_Stock_TransferOut] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_TransferOut_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 420, 4,'','Update [dm].[Fct_YH_Target_Weekly]','Stored Procedure','','','[dm].[SP_Fct_YH_Target_Weekly]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 421, 4,'ERP','Update [dm].[Fct_ERP_Stock_ReturnStock] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_ReturnStock_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 422, 4,'ERP','Update [dm].[Fct_ERP_Stock_MiscStock] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_MiscStock_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 423, 4,'','Update [dm].[Fct_Kidswant_DailySales] From ODS','Stored Procedure','','','[dm].[SP_Fct_Kidswant_DailySales_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 424, 4,'ERP','Update [dm].[Dim_ERP_RawMaterial] From ODS','Stored Procedure','','','[dm].[SP_Dim_ERP_RawMaterial_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 425, 4,'','DELETE BACKUP TABLE IN Foodunion','Stored Procedure','','','[dbo].[USP_Cleanup_Archive_Objects]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 426, 4,'','Update [dm].[Fct_YH_JXT_Daily] From ODS','Stored Procedure','','','[dm].[SP_Fct_YH_JXT_Daily_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 427, 4,'','Update [dw].[Fct_YH_Sales_All] From ODS','Stored Procedure','','','[dw].[SP_Fct_YH_Sales_All]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 428, 4,'','Update [dw].[Fct_YH_Inventory] From ODS','Stored Procedure','','','[dw].[SP_Fct_YH_Inventory]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 429, 4,'','Update [dw].[Fct_YH_Sales_Inventory] From ODS','Stored Procedure','','','[dw].[SP_Fct_YH_Sales_Inventory]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 430, 4,'','Update [dw].[Fct_Sales_Plan] From ODS','Stored Procedure','','','[dw].[SP_Fct_SALES_PLAN]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 431, 4,'','Update [dw].[Fct_YH_BM_Promotion] From ODS','Stored Procedure','','','[dw].[SP_Fct_YH_BM_Promotion]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 432, 4,'','Update [dw].[Fct_YH_Target] From ODS','Stored Procedure','','','[dw].[SP_Fct_YH_Target]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 433, 4,'','Update [dm].[Fct_RDC_Inventory] From ODS','Stored Procedure','','','[dm].[SP_Fct_RDC_Inventory_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 434, 4,'SCRM','Update [dm].[Fct_O2O_wx_ApplyData]','Stored Procedure','','','[dm].[SP_Fct_O2O_wx_ApplyData_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 435, 4,'SCRM','Update [dm].[Fct_O2O_wx_ApplyList]','Stored Procedure','','','[dm].[SP_Fct_O2O_wx_Applylist_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 436, 4,'','Update [dm].[Dim_Order]','Stored Procedure','','','[dm].[SP_Dim_Order_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 436, 4,'','Update Order Tables','Stored Procedure','','','[dm].[SP_Fct_Order_ALLin1_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 437, 4,'','Update [dm].[Fct_Order_Item]','Stored Procedure','','','[dm].[SP_Fct_Order_Item_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 438, 4,'','Update [dm].[Dim_Product_Leadtime]','Stored Procedure','','','[dm].[SP_Dim_Product_Leadtime_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 439, 4,'CRV','Update [dm].[Fct_CRV_DailySales]','Stored Procedure','','','[dm].[SP_Fct_CRV_DailySales_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 440, 4,'CRV','Update [dm].[Fct_CRV_DailyInventory]','Stored Procedure','','','[dm].[SP_Fct_CRV_DailyInventory_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 441, 4,'','Update [dm].[Fct_Sales_Channel]','Stored Procedure','','','[dm].[SP_Fct_Sales_Channel]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 441, 4,'','Update [dm].[Fct_Sales_SellOut_byChannel_byRegion]','Stored Procedure','','','[dm].[SP_Fct_Sales_SellOut_byChannel_byRegion_Update] ',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 442, 4,'','Update [dm].[Fct_Production_DemandPlanning]','Stored Procedure','','','[dm].[SP_Fct_Production_DemandPlanning_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 443, 4,'ERP','Update [dm].[Fct_ERP_Stock_MiscStock] From ODS','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_MiscStock_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 444, 4,'','Update [dm].[Fct_KAStore_DailySalesInventory]','Stored Procedure','','','[dm].[SP_Fct_KAStore_DailySalesInventory_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();



INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 445, 4,'ERP','Update Fct_KAStore_SalesTarget Monthly/Weekly','Stored Procedure','','','[dm].[SP_Fct_KAStore_SalesTarget_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 446, 4,'ERP','Update [dm].[Fct_ERP_Stock_PurchaseOrder]','Stored Procedure','','','[dm].[SP_Fct_ERP_Stock_PurchaseOrder_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 447, 4,'','Update [dm].[Fct_Sales_SellOut_ByChannel]','Stored Procedure','','','[dm].[SP_Fct_Sales_SellOut_ByChannel_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 448, 4,'','Update [dm].[Dim_Channel]','Stored Procedure','','','[dm].[SP_Dim_Channel_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 449, 4,'','Update [dm].[Fct_Sales_SellIn_ByChannel]','Stored Procedure','','','[dm].[SP_Fct_Sales_SellIn_ByChannel_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 450, 4,'','Update [dm].[Fct_Sales_SellInTarget_ByChannel] From ODS','Stored Procedure','','','[dm].[SP_Fct_Sales_SellInTarget_ByChannel_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 451, 4,'','Update [dm].[Fct_Qulouxia_Sales From ODS]','Stored Procedure','','','[dm].[SP_Fct_Qulouxia_Sales_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 451, 4,'','Update [dm].[Fct_Order] From ODS','Stored Procedure','','','[dm].[SP_Fct_Order_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 452, 4,'','Update [dm].[Fct_YH_Sales_Weight_Weekday]','Stored Procedure','','','[dm].[SP_Fct_YH_Sales_Weight_Weekday_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 453, 4,'','Update [dm].[Fct_YH_Sales_Inventory]','Stored Procedure','','','[dm].[SP_Fct_YH_Sales_Inventory_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 454, 4,'','Update [dm].[Fct_YH_Store_Score_Card]','Stored Procedure','','','[dm].[SP_Fct_YH_Store_Score_Card_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 455, 4,'','Update [dm].[Fct_Sales_Plan]','Stored Procedure','','','[dm].[SP_Fct_Sales_Plan_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 456, 4,'','Update [dm].[Fct_YH_BM_Promotion]','Stored Procedure','','','[dm].[SP_Fct_YH_BM_Promotion_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 457, 4,'','Update [dm].[Fct_YH_Target]','Stored Procedure','','','[dm].[SP_Fct_YH_Target_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 458, 4,'','Update [dm].[Fct_YH_Target_With_Weight]','Stored Procedure','','','[dm].[SP_Fct_YH_Target_With_Weight_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 510, 5,'','Update [dm].[Fct_YH360_MONTHLY]','Stored Procedure','','','[dm].[SP_Fct_YH360_MONTHLY]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 459, 4,'','Update [dm].[Fct_YH_Store_Flag_Daily]','Stored Procedure','','','[dm].[SP_Fct_YH_Store_Flag_Daily_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 460, 4,'','Update [dm].[Dim_Customer]','Stored Procedure','','','[dm].[SP_Dim_Customer_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 461, 4,'','Update [dm].[Fct_CenturyMart_DailySales]','Stored Procedure','','','[dm].[SP_Fct_CenturyMart_DailySales_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 462, 4,'','Update [dm].[Fct_Sales_Sell*Target_ByKAarea]','Stored Procedure','','','[dm].[SP_Fct_Sales_SellInOutTarget_ByKAarea_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 463, 4,'','Update [dm].[SP_Fct_YH_Store_DailyOrders_Update]','Stored Procedure','','','[dm].[SP_Fct_YH_Store_DailyOrders_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 464, 4,'','Update [dm].[Fct_ERP_Inventory]','Stored Procedure','','','[dm].[SP_Fct_ERP_Inventory_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 465, 4,'','Update [dm].[Dim_SalesTerritory_Mapping_Monthly]','Stored Procedure','','','[dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 466, 4,'','Update [dm].[Dim_Store_SalesPerson_Monthly]','Stored Procedure','','','[dm].[SP_Dim_Store_SalesPerson_Monthly_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 467, 4,'','Update [dm].[Dim_Product_VICVLC]','Stored Procedure','','','[dm].[SP_Dim_Product_VICVLC_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 468, 4,'','Update [dm].[Fct_Sales_SellInOutTarget_byStore]','Stored Procedure','','','[dm].[SP_Fct_Sales_SellInOutTarget_byStore_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 469, 4,'','Update [dm].[SP_Fct_Qulouxia_DCInventory_Daily_Update]','Stored Procedure','','','[dm].[SP_Fct_Qulouxia_DCInventory_Daily_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 470, 4,'','Update [dm].[SP_Fct_Qulouxia_DC2Box_Update]','Stored Procedure','','','[dm].[SP_Fct_Qulouxia_DC2Box_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 471, 4,'','Update [dm].[Fct_KAStore_DailySalesInventory]','SQL','','','EXEC [dm].[SP_Fct_KAStore_DailySalesInventory_Update] 7',NULL,2,1,NULL,NULL,GETDATE(),GETDATE(); 
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 472, 4,'','Update [dm].[Fct_Sales_SellIn_ByChannel_Monthly]','Stored Procedure','','','[dm].[SP_Fct_Sales_SellIn_ByChannel_Monthly_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 473, 4,'','Update [dm].[SP_Fct_YH_KPIDB_Upsert]','Stored Procedure','','','[dm].[SP_Fct_YH_KPIDB_Upsert]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 474, 4,'','Update [dm].[SP_Fct_YH_Maco_Per_Store_Upsert]','Stored Procedure','','','[dm].[SP_Fct_YH_Maco_Per_Store_Upsert]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE(); 

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 475, 4,'','[dm].[SP_Fct_Qulouxia_BoxSlot_Update]','Stored Procedure','','','[dm].[SP_Fct_Qulouxia_BoxSlot_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 476, 4,'','[dm].[SP_Fct_FXXK_KAStoreVisit_Update]','Stored Procedure','','','[dm].[SP_Fct_FXXK_KAStoreVisit_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 477, 4,'','[dm].[SP_Fct_Qulouxia_Handing_Fee_Update]','Stored Procedure','','','[dm].[SP_Fct_Qulouxia_Handing_Fee_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 478, 4,'','[dm].[SP_Fct_Qulouxia_OthersData_Update]','Stored Procedure','','','[dm].[SP_Fct_Qulouxia_OthersData_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 479, 4,'','[dm].[SP_Fct_YH_Order_Satisfaction_Rate]','Stored Procedure','','','[dm].[SP_Fct_YH_Order_Satisfaction_Rate]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 480, 4,'POP6','[dm].[SP_Fct_POP6_Visit_Update]','Stored Procedure','','','[dm].[SP_Fct_POP6_Visit_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 481, 4,'','[dm].[SP_Dim_Store_Fxxk_Update]','Stored Procedure','','','[dm].[SP_Dim_Store_Fxxk_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();


INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 482, 4,'','[dm].[SP_Dim_Department_Update]','Stored Procedure','','','[dm].[SP_Dim_Department_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 483, 4,'','Update [dm].[Fct_Sales_SellIn_ByChannel_BySKU] ','Stored Procedure','','','[dm].[SP_Fct_Sales_SellIn_ByChannel_BySKU_Update] ',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();


--RPT update Procedures
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 501, 5,'ERP','Update [rpt].[ERP_Sales_Order]','Stored Procedure','','','[rpt].[SP_ERP_Sales_Order_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 502, 5,'SCRM','Update [rpt].[O2O_OrderRecon_Detail]','Stored Procedure','','','[rpt].[SP_O2O_OrderRecon_Detail_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
--INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
--SELECT 512, 5,'','Update [dm].[Fct_YH_Store_Flag_Monthly]','Stored Procedure','','','[dm].[SP_Fct_YH_Store_Flag_Monthly]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 513, 5,'','Update [dm].[Dim_Store_Flag]','Stored Procedure','','','[dm].[SP_Dim_Store_Flag_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 514, 5,'SCRM','Update [rpt].[O2O_Employee_Order]','Stored Procedure','','','[rpt].[SP_O2O_Employee_Order_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 515, 5,'SCRM','Update [rpt].[O2O_Employee_Commission]','Stored Procedure','','','[rpt].[SP_O2O_Employee_Commission_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 516, 5,'SCRM','Update [dm].[Fct_Youzan_Recon]','Stored Procedure','','','[dm].[SP_Fct_Youzan_Recon]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 517, 5,'SCRM','Update [rpt].[SP_O2O_Order_Base_info_Delivery_Update]','Stored Procedure','','','[rpt].[SP_O2O_Order_Base_info_Delivery_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 518, 5,'SCRM','Update [rpt].[O2O_Order_Base_info_MRR_By_Month]','Stored Procedure','','','[rpt].[SP_O2O_Order_Base_info_MRR_By_Month_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 519, 5,'SCRM','Update [dm].[Fct_Youzan_Revenue_Details]','Stored Procedure','','','[dm].[SP_Fct_Youzan_Revenue_Details]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 520, 5,'','Update [rpt].[Order_Customer_list]','Stored Procedure','','','[rpt].[SP_Order_Customer_list_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 521, 5,'','Update [rpt].Sales_销售区域达成日报','Stored Procedure','','','[rpt].[SP_Sales_销售区域达成日报_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 522, 5,'','Update [rpt].Sales_销售渠道客户达成日报','Stored Procedure','','','[rpt].[SP_Sales_销售渠道客户达成日报_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 523, 5,'','Update [rpt].[Sales_销售门店进货日报]','Stored Procedure','','','[rpt].[SP_Sales_销售门店进货日报_Update]',NULL,2,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 524, 5,'','Update [rpt].[YH门店商品库存缺货日报]','Stored Procedure','','','[rpt].[SP_YH门店商品库存缺货日报_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 525, 5,'','Update [rpt].[Sales_YH门店商品库存明细60天]','Stored Procedure','','','[rpt].[SP_Sales_YH门店商品库存明细60天_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 526, 5,'','Update [rpt].[Sales_销售代表月度指标达成日报]','Stored Procedure','','','[rpt].[SP_Sales_销售代表月度指标达成日报_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 527, 5,'','Update [rpt].[Sales_YH门店商品库存OOS明细60天]','Stored Procedure','','','[rpt].[SP_Sales_YH门店商品库存OOS明细60天_Update]',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();


INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 599, 5,'','[dbo].[USP_CreateDBSnapshot]','SQL','','','EXEC [dbo].[USP_CreateDBSnapshot] ',NULL,2,1,NULL,NULL,GETDATE(),GETDATE();
UPDATE [ConfigDB].[cfg].[JobTasks] SET ExecQuery='EXEC [dbo].[USP_CreateDBSnapshot] '+'''Foodunion'''+','+ '''Foodunion_DailySnapshot'''+',' +'''D:\Backup\Snapshots'''+',1'  WHERE TaskID=599  --更新执行语句


--ConfigDB Procedures
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 601, 6,'','Update [aud].[ReportSourceMapping]','Stored Procedure','','','[aud].[ReportSourceMapping_Update]',NULL,3,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 602, 6,'','Update [aud].[Database_Monitor]','Stored Procedure','','','[aud].[Database_Monitor_Update]',NULL,3,1,NULL,NULL,GETDATE(),GETDATE();

--others
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 701, 7,'','Create NAS Z: link','SysExec','D:\\','nas.bat','',NULL,0,0,NULL,NULL,GETDATE(),GETDATE();

--Export and push
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 801, 8,'','Export and push data out to external','CallJob','','Export_ERP_DocsReceivable',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 802, 8,'','Export YHCombo','CallJob','','Export_Sales_YHCombo',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 803, 8,'','Export Database Foodunion/ODS/ConfigDB Scripts','CallJob','','Generate_DBScripts_ASFiles',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 804, 8,'','Export KA DATE AND push File to Sharepoint','CallJob','','Export_Sales_KA',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 805, 8,'','Lakto_offline_l3m','CallJob','','Export_Lakto_offline_l3m',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 806, 8,'','Export_Sales_YH_OOS_DailyReport','CallJob','','Export_Sales_YH_OOS_DailyReport',NULL,NULL,NULL,0,NULL,NULL,GETDATE(),GETDATE();

INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 807, 8,'','Export masterData to Fxxk API','CallJob','','Load_Fxxk_MasterDataPush',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 808, 8,'','Export Sellin Sellout to Fxxk API','CallJob','','Load_Fxxk_StoreSalesPush',NULL,NULL,NULL,1,NULL,NULL,GETDATE(),GETDATE();



--Run Audit 
INSERT INTO cfg.JobTasks (TaskID,GroupID,[Category],TaskName,TaskType,ExecutorPath,ExecutorName,ExecQuery,ExecParameters,ExecConnectionID,IsEnabled,LastRunDate,LastRunStatus,InsertDatetime,UpdateDatetime)
SELECT 999, 9,'Audit','Run Audit job hourly','CallJob','','RunAudit','',NULL,0,1,NULL,NULL,GETDATE(),GETDATE();

SET IDENTITY_INSERT cfg.jobtasks OFF;
GO
select * from cfg.JobTasks;


--cfg.Connections;
TRUNCATE TABLE cfg.Connections;
GO
DECLARE @Server varchar(100);
SELECT @Server=@@SERVERNAME
IF @Server='iZpphctxo1l2lyZ\FUDHMSSQL17'
BEGIN
	SET IDENTITY_INSERT cfg.Connections ON;
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 0, 'UNK','UNK','','','','','',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 1, 'ODS','MSSQL','47.103.65.194','933','ODS','FU_ETL','I#8ius94*',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 2, 'FoodUnion','MSSQL','47.103.65.194','933','FoodUnion','FU_ETL','I#8ius94*',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 3, 'ConfigDB','MSSQL','47.103.65.194','933','ConfigDB','FU_ETL','I#8ius94*',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 4, 'ERP','MSSQL','rm-uf62j69t5v9z05mm9.sqlserver.rds.aliyuncs.com','1433','aissh20190314','powerbiuser','FuPower2019*',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 5, 'FTP_TP','FTP','47.101.59.95','21','','readonly','Fu@2019','/history/trade.synchronize',GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 6, 'ExchangeDB','MySQL','rm-uf64albutls6z73vg4o.mysql.rds.aliyuncs.com','3306','aissh20190314','mdmadmin','FoodUnion2019#',NULL,GETDATE(),GETDATE();	
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 9, 'Excel','Excel','','','','','','D:\Data\FU_DataHub\',GETDATE(),GETDATE();
	SET IDENTITY_INSERT cfg.Connections OFF;
END
IF @Server='powerbipro\FUDHMSSQL'
BEGIN
	SET IDENTITY_INSERT cfg.Connections ON;
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 0, 'UNK','UNK','','','','','',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 1, 'ODS','MSSQL','47.103.65.206','833','ODS','FU_ETL','XUY8jE5PKQ6@',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 2, 'FoodUnion','MSSQL','47.103.65.206','833','FoodUnion','FU_ETL','XUY8jE5PKQ6@',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 3, 'ConfigDB','MSSQL','47.103.65.206','833','ConfigDB','FU_ETL','XUY8jE5PKQ6@',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 4, 'ERP','MSSQL','rm-uf62j69t5v9z05mm9.sqlserver.rds.aliyuncs.com','1433','aissh20190314','powerbiuser','FuPower2019*',NULL,GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 5, 'FTP_TP','FTP','47.101.59.95','21','','readonly','Fu@2019','/history/trade.synchronize',GETDATE(),GETDATE();
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 6, 'ExchangeDB','MySQL','rm-uf64albutls6z73vg4o.mysql.rds.aliyuncs.com','3306','aissh20190314','mdmadmin','FoodUnion2019#',NULL,GETDATE(),GETDATE();	
	INSERT INTO cfg.Connections (ConnectionID,ConnectionName,ConnectionType,ServerName,PortNumber,DatabaseName,UserName,Password,FilePath,InsertDatetime,UpdateDatetime)
	SELECT 9, 'Excel','Excel','','','','','','D:\Data\FU_DataHub\',GETDATE(),GETDATE();
	SET IDENTITY_INSERT cfg.Connections OFF;
END
GO
select * from cfg.Connections;

go

--Daily Plan 1
select jp.PlanID,jp.PlanDescription,jpt.SequenceID,jg.GroupName,--jg.GroupDescription,
	jt.TaskName,jt.TaskType,jt.ExecutorName,jt.ExecQuery,--c.ConnectionName,
	c.DatabaseName
from cfg.JobPlans jp
join cfg.JobPlanTask jpt on jp.PlanID=jpt.PlanID
join cfg.JobGroups jg on jpt.GroupID=jg.GroupID
join cfg.JobTasks jt on jpt.TaskID=jt.TaskID
left join cfg.Connections c on jt.ExecConnectionID=c.ConnectionID
where jp.PlanID=1
and jpt.IsEnabled=1
order by jpt.SequenceID,jg.GroupID;

--Hourly Plan 2
select jp.PlanID,jp.PlanDescription,jpt.SequenceID,jg.GroupName,--jg.GroupDescription,
	jt.TaskName,jt.TaskType,jt.ExecutorName,jt.ExecQuery,--c.ConnectionName,
	c.DatabaseName
from cfg.JobPlans jp
join cfg.JobPlanTask jpt on jp.PlanID=jpt.PlanID
join cfg.JobGroups jg on jpt.GroupID=jg.GroupID
join cfg.JobTasks jt on jpt.TaskID=jt.TaskID
left join cfg.Connections c on jt.ExecConnectionID=c.ConnectionID
where jp.PlanID=2
and jpt.IsEnabled=1
order by jpt.SequenceID,jg.GroupID;