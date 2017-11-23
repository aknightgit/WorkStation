--GET Column List
declare @name nvarchar(max)
Select @name=case when @name is null then '' else @name+',' end +Name FROM Sys.Columns Where object_id=Object_Id('dms.stockhaltlist')
select @name