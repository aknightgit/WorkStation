USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [Split_table](@text NVARCHAR(max))
RETURNS @tempTable TABLE(value NVARCHAR(1000))
AS
BEGIN
     DECLARE @StartIndex INT                --开始查找的位置
     DECLARE @FindIndex INT                --找到的位置
     DECLARE @Content    VARCHAR(4000)    --找到的值
     --初始化一些变量
     SET @StartIndex = 1 --T-SQL中字符串的查找位置是从1开始的
     SET @FindIndex=0
    
     --开始循环查找字符串逗号
     WHILE(@StartIndex <= LEN(@Text))
     BEGIN
         --查找字符串函数 CHARINDEX 第一个参数是要找的字符串
         --                            第二个参数是在哪里查找这个字符串
         --                            第三个参数是开始查找的位置
         --返回值是找到字符串的位置
         SELECT @FindIndex = CHARINDEX(',' ,@Text,@StartIndex)
         --判断有没找到 没找到返回0
         IF(@FindIndex =0 OR @FindIndex IS NULL)
         BEGIN
             --如果没有找到就表示找完了
             SET @FindIndex = LEN(@Text)+1
         END
         --截取字符串函数 SUBSTRING 第一个参数是要截取的字符串
         --                            第二个参数是开始的位置
         --                            第三个参数是截取的长度
         SET @Content =SUBSTRING(@Text,@StartIndex,@FindIndex-@StartIndex)
         --初始化下次查找的位置
         SET @StartIndex = @FindIndex+1
         --把找的的值插入到要返回的Table类型中
         INSERT INTO @tempTable (Value) VALUES (@Content)
     END
     RETURN
END
GO
