USE [Foodunion]
GO
DROP FUNCTION [dbo].[Split_table]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[Split_table](@text NVARCHAR(max))
RETURNS @tempTable TABLE(value NVARCHAR(1000))
AS
BEGIN
     DECLARE @StartIndex INT                --��ʼ���ҵ�λ��
     DECLARE @FindIndex INT                --�ҵ���λ��
     DECLARE @Content    VARCHAR(4000)    --�ҵ���ֵ
     --��ʼ��һЩ����
     SET @StartIndex = 1 --T-SQL���ַ����Ĳ���λ���Ǵ�1��ʼ��
     SET @FindIndex=0
    
     --��ʼѭ�������ַ�������
     WHILE(@StartIndex <= LEN(@Text))
     BEGIN
         --�����ַ������� CHARINDEX ��һ��������Ҫ�ҵ��ַ���
         --                            �ڶ����������������������ַ���
         --                            �����������ǿ�ʼ���ҵ�λ��
         --����ֵ���ҵ��ַ�����λ��
         SELECT @FindIndex = CHARINDEX(',' ,@Text,@StartIndex)
         --�ж���û�ҵ� û�ҵ�����0
         IF(@FindIndex =0 OR @FindIndex IS NULL)
         BEGIN
             --���û���ҵ��ͱ�ʾ������
             SET @FindIndex = LEN(@Text)+1
         END
         --��ȡ�ַ������� SUBSTRING ��һ��������Ҫ��ȡ���ַ���
         --                            �ڶ��������ǿ�ʼ��λ��
         --                            �����������ǽ�ȡ�ĳ���
         SET @Content =SUBSTRING(@Text,@StartIndex,@FindIndex-@StartIndex)
         --��ʼ���´β��ҵ�λ��
         SET @StartIndex = @FindIndex+1
         --���ҵĵ�ֵ���뵽Ҫ���ص�Table������
         INSERT INTO @tempTable (Value) VALUES (@Content)
     END
     RETURN
END
GO
