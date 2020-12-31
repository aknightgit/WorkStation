USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc uspTestDateInsert
@startDate datetime
,@endDate datetime
as
begin
    while(@startDate<=@enddate)
    begin
        insert into [and.ConfigDB] (c_date) values
        (Convert(bigint,CONVERT(char(8),@startDate,112)))

        set @startDate=DATEADD(day,1,@startdate)
    end
end

--exec uspTestDateInsert '2019-05-28','2019-08-23'
select* from  [and.ConfigDB]
GO
