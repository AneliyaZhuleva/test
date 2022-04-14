CREATE OR ALTER FUNCTION [dbo].[fnGetRandomNumberStringByLength]
(
	@Length INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Counter INT = 1
	DECLARE @String VARCHAR(MAX) = ''
	DECLARE @RandNumber INT

	WHILE(@Counter <= @Length)
	BEGIN
		SET @RandNumber = (SELECT TOP 1 Number FROM dbo.vwIntNumbers)
		SET @String = @String + CAST(@RandNumber AS VARCHAR(MAX))

		SET @Counter = @Counter + 1
	END

RETURN @String

END
