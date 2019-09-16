

DECLARE @SearchText   varchar(100)

SET @SearchText = 'Fct_ERP_Stock_InStockEntry'

SELECT
   schema_name(ob.schema_id)  SchemaName
  ,ob.name
  ,ob.type_desc
  ,len(mo.definition) CodeLength
  ,mo.definition
 from sys.sql_modules mo
  inner join .sys.objects ob
   on ob.object_id = mo.object_id
 where mo.definition like '%' + @SearchText + '%'
 order by
   case schema_name(ob.schema_id)
     when 'dbo' then 'A'
     else 'B' + str(ob.schema_id, 10)
   end
  ,ob.type_desc
  ,ob.name