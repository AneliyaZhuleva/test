CREATE OR ALTER FUNCTION [dbo].[fnGenerateEGNByID]
(
	@PersonID INT
)
RETURNS VARCHAR(10)
AS
BEGIN

	DECLARE 
		@Year VARCHAR(50),
		@Month VARCHAR(50),
		@Day VARCHAR(50),
		@Rand VARCHAR(10)


	SELECT 
	@Year = RIGHT(		
							CAST(
									(DATEPART(YEAR, DateOfBirth)) 
									AS VARCHAR(50)
							)		
							, 2),
	@Month = CAST(DATEPART(MONTH, DateofBirth) AS VARCHAR(50)),
	@Day = CAST(DATEPART(DAY, DateofBirth) AS VARCHAR(50)),
	@Rand = dbo.fnGetRandomNumberStringByLength(4)
	FROM 
		tblPersons
	WHERE 
		ID = @PersonID

	RETURN 
		@Year
		+ CASE   
			WHEN @Month < 10 THEN '0' + @Month 
			ELSE @Month
		  END
		+ CASE 
			WHEN @Day <10 THEN '0' + @Day
			ELSE @Day
		  END
		+ @Rand

END
