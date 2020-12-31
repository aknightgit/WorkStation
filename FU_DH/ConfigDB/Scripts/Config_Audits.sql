USE [ConfigDB]
GO
DELETE FROM  [cfg].[AuditConfig] WHERE AuditID>=100;

/*
IT Shanghai 钉钉群： 160aeaaca1147294d158ca648e289542e58de936a2d51787dca38d261750baa5
EDI 测试群：23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d
Dashboard群： 1147ad1811346c43a18f75d9b30c8268c75293f586b07915cebb76201afb9607
*/

SET IDENTITY_INSERT  [cfg].[AuditConfig] ON ;
INSERT INTO [cfg].[AuditConfig]
           ([AuditID],[AuditName],[AuditDesc],[ConnectionID],[CheckQuery]
           ,[MaxAllowed],[IsEnabled],[AlertLevel],[NotifyBy]
           ,[DingRobot],[Mobile],[MailDL],[MailCC]
           ,[ContentType],[ContentText],[XMLConfigFile],[AlertOnce]
           ,[AlertBeginHour],[AlertEndHour],[CheckOnce],[LastRunDate],[LastRunReturn]
           ,[InsertDatetime],[UpdateDatetime])
SELECT 100,'YH门店库存预警','YH门店库存预警',2,'',0,0,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_100.xml',1,9,12,0,NULL,NULL,GETDATE(),GETDATE()
UNION
SELECT 101,'YH门店库存预警-柴纯杰','YH门店库存预警-柴纯杰',2,'',0,0,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_101.xml',1,9,12,0,NULL,NULL,GETDATE(),GETDATE()
UNION
SELECT 102,'YH门店库存预警-张兴华','YH门店库存预警-张兴华',2,'',0,0,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_102.xml',1,9,12,0,NULL,NULL,GETDATE(),GETDATE()
UNION
SELECT 103,'YH门店库存预警-张在峰','YH门店库存预警-张在峰',2,'',0,0,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_103.xml',1,9,12,0,NULL,NULL,GETDATE(),GETDATE()

UNION
SELECT 110,'YH门店日销售异常','YH门店日销售异常',2,'',0,0,1,'Mail',''
,'','ak.wang@foodunion.com.cn','','ReadXML','','D:\Config\Audits\Config_AuditID_110.xml',1,10,12,0,NULL,NULL,GETDATE(),GETDATE()
UNION
SELECT 111,'YH销售月记录突破','YH销售月记录突破',2,'',0,1,1,'Ding','160aeaaca1147294d158ca648e289542e58de936a2d51787dca38d261750baa5'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_111.xml',1,10,12,0,NULL,NULL,GETDATE(),GETDATE()

UNION
-- Alert Dingding when YH Data not available around 10:30
-- 
SELECT 112,'YH data Delay','YH data Delay',2,'',0,1,1,'Ding','1147ad1811346c43a18f75d9b30c8268c75293f586b07915cebb76201afb9607'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_112.xml',1,11,12,0,NULL,NULL,GETDATE(),GETDATE()   
UNION
SELECT 113,'CRV data Delay','CRV data Delay',2,'',0,0,1,'Ding','1147ad1811346c43a18f75d9b30c8268c75293f586b07915cebb76201afb9607'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_113.xml',1,11,12,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 114,'Kidswant data Delay','Kidswant data Delay',2,'',0,0,1,'Ding','1147ad1811346c43a18f75d9b30c8268c75293f586b07915cebb76201afb9607'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_114.xml',1,11,12,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 115,'O2O Data Delay','O2O Data Delay',2,'',0,0,1,'Ding','1147ad1811346c43a18f75d9b30c8268c75293f586b07915cebb76201afb9607'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_115.xml',1,11,12,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 116,'Zbox Data Delay','Zbox Data Delay',2,'',0,0,1,'Ding','1147ad1811346c43a18f75d9b30c8268c75293f586b07915cebb76201afb9607'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_116.xml',1,11,12,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 119,'Daily/Hourly Failure alert','Daily Hourly任务失败监控',3,'',0,1,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_119.xml',1,7,11,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 200,'OmniChannel CustomerMapping Missing','监测是否有和ERP中Customer不匹配项',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_200.xml',1,9,10,1,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 201,'Calendar is not updated','监测Calendar今天是否更新过',2,'',0,0,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_201.xml',1,11,12,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 202,'Dim_Channel Check','监测新增Channel 是否没有分配Team，ChannelType',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_202.xml',1,8,11,1,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 203,'Product Barcode Check','监测Product 表中是否存在Barcode 的SKU 或者 字段内容不全',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_203.xml',1,8,11,0,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 204,'Store Province & City Check','监测新增Store是否存在没有省份城市',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_204.xml',1,8,11,1,NULL,NULL,GETDATE(),GETDATE()  
UNION
SELECT 205,'Job运行超时监控','任务超时监控',3,'',0,1,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_205.xml',0,8,16,0,NULL,NULL,GETDATE(),GETDATE()  

UNION
SELECT 206,'Product维度表监控','Product维度表异常数据监控',3,'',0,1,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_206.xml',1,8,16,1,NULL,NULL,GETDATE(),GETDATE()  

UNION
SELECT 207,'Order Table Channel Mapping Check','监测是否存在未Mapping Channel 的Order Data',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_207.xml',1,8,15,0,NULL,NULL,GETDATE(),GETDATE()  

UNION
SELECT 208,'猫武士数据上传监控','监测到猫武士最近3天没有数据上传',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_208.xml',1,12,15,0,NULL,NULL,GETDATE(),GETDATE()  --猫武士数据上传监控


UNION
SELECT 209,'Zbox数据加载监控','Zbox数据加载缺失数据监控',3,'',0,1,1,'Ding','23309b903435e06735ba2177f7e9b67443b0dbbff5039064e70c091b1e07577d'
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_209.xml',1,13,16,1,NULL,NULL,GETDATE(),GETDATE()  

UNION
SELECT 301,'YH销售区域达成日报','YH销售区域达成日报',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_301.xml',1,9,20,0,NULL,NULL,GETDATE(),GETDATE() 
UNION
SELECT 302,'销售渠道客户达成日报','销售渠道客户达成日报',2,'',0,0,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_302.xml',1,9,18,0,NULL,NULL,GETDATE(),GETDATE() 
UNION
SELECT 303,'YH销售区域达成日报-1','YH销售区域达成日报-1',2,'',0,1,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_303.xml',1,9,20,0,NULL,NULL,GETDATE(),GETDATE() 
UNION
SELECT 304,'YH销售门店进销日报','YH销售门店进销日报',2,'',0,0,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_304.xml',1,9,20,0,NULL,NULL,GETDATE(),GETDATE() 
UNION
SELECT 305,'YH销售代表月度指标达成日报-1','YH销售代表月度指标达成日报-1',2,'',0,0,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_305.xml',1,9,20,0,NULL,NULL,GETDATE(),GETDATE() 

UNION
SELECT 999,'测试邮件','测试邮件',2,'',0,0,1,'Mail',''
,'','','','ReadXML','','D:\Config\Audits\Config_AuditID_999.xml',0,9,20,0,NULL,NULL,GETDATE(),GETDATE() 




SET IDENTITY_INSERT  [cfg].[AuditConfig] OFF ;

--SELECT * FROM  [cfg].[AuditConfig]
--UPDATE [cfg].[AuditConfig] SET IsEnabled=0;
--UPDATE [cfg].[AuditConfig] SET IsEnabled=1 WHERE AuditID=110;
