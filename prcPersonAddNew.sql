CREATE OR ALTER PROCEDURE [dbo].[prcPersonAddNew]
(
	@FirstName		VARCHAR(250) = '',
	@LastName		VARCHAR(250) = '',
	@DOB			DATE = '2000-01-01',
	@Gender			CHAR(1) = '',
	@Country		VARCHAR(250) = '',
	@City			VARCHAR(250) = '',
	@Street			VARCHAR(500) = '',
	@Number			INT = 1,
	@ZipCode		VARCHAR(250) = '',
	@AddressNote	VARCHAR(MAX) = '',
	@Fruit			VARCHAR(200) 
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PersonID INT
	DECLARE @AddressID INT
	DECLARE @CityID INT
	DECLARE @CountryID INT
	DECLARE @FruitID INT

	SET @Gender = IIF(@Gender NOT IN ('M','F', 'O'), 'O', @Gender)

	IF (ISNULL(@FirstName	, '') = '') BEGIN SELECT '@FirstName must be provided!' AS Error; RETURN; END
	IF (ISNULL(@LastName	, '') = '') BEGIN SELECT '@LastName must be provided!'	AS Error; RETURN; END
	IF (ISNULL(@DOB			, '') = '') BEGIN SELECT '@DOB must be provided!'		AS Error; RETURN; END
	IF (ISNULL(@Country		, '') = '') BEGIN SELECT '@Country must be provided!'	AS Error; RETURN; END
	IF (ISNULL(@City		, '') = '') BEGIN SELECT '@City must be provided!'		AS Error; RETURN; END
	IF (ISNULL(@ZipCode		, '') = '') BEGIN SELECT '@ZipCode must be provided!'	AS Error; RETURN; END
	IF (ISNULL(@Fruit		, '') = '') BEGIN SELECT '@Fruit must be provided!'		AS Error; RETURN; END

	SET @FirstName		= LTRIM(RTRIM(@FirstName	));
	SET @LastName		= LTRIM(RTRIM(@LastName		));
	SET @Country		= LTRIM(RTRIM(@Country		));
	SET @City			= LTRIM(RTRIM(@City			));
	SET @Street			= LTRIM(RTRIM(@Street		));
	SET @AddressNote	= LTRIM(RTRIM(@AddressNote	));
	SET @ZipCode		= LTRIM(RTRIM(@ZipCode		));
	SET @Fruit			= LTRIM(RTRIM(@Fruit		));

	IF EXISTS 
		(
			SELECT TOP (1) 1
			FROM dbo.tblPersons
			WHERE FirstName = @FirstName
			AND LastName = @LastName
			AND DateOfBirth = @DOB
		)
	BEGIN
		SELECT 'Person with these FN, LN & DoB already exists!' AS Error
		RETURN;
	END

	IF NOT EXISTS
		(
			SELECT TOP (1) 1
			FROM tblCountries 
			WHERE [Name] = @Country
		)
	BEGIN
		SELECT 'Country "'+ @Country +'" does not exist!' AS Error
		RETURN;
	END
	ELSE
	BEGIN
		SELECT @CountryID = ID
		FROM tblCountries
		WHERE [Name] = @Country
	END

	IF NOT EXISTS
		(
			SELECT TOP (1) 1
			FROM tblCities 
			WHERE [Name] = @City
		)
	BEGIN
		SELECT 'City "'+ @City +'" does not exist!' AS Error
		RETURN;
	END
	ELSE
	BEGIN
		SELECT @CityID = ID
		FROM tblCities
		WHERE [Name] = @City
	END

	IF NOT EXISTS
		(
			SELECT TOP (1) 1
			FROM tblCities ci 
			JOIN tblCountries co ON ci.CountryID = co.ID
			WHERE ci.[Name] = @City
			AND co.[Name] = @Country
		)
	BEGIN
		SELECT @City +'is not located in '+@Country+'!' AS Error
		RETURN;
	END

	
	IF NOT EXISTS
		(
			SELECT TOP (1) 1
			FROM tblFruits 
			WHERE [Name] = @Fruit
		)
	BEGIN
		SELECT 'Fruit "'+ @Fruit +'" does not exist!' AS Error
		RETURN;
	END
	ELSE
	BEGIN
		SELECT @FruitID = ID
		FROM tblFruits
		WHERE [Name] = @Fruit
	END


	BEGIN TRANSACTION

	INSERT INTO dbo.tblPersons
		(
			 FirstName
			,LastName
			,DateOfBirth
			,Gender
		)
	VALUES
		(
			 @FirstName
			,@LastName
			,@DOB
			,@Gender
		)

	SET @PersonID = SCOPE_IDENTITY()

	INSERT INTO dbo.tblAddresses
		(CityID
		,Street
		,Number
		,ZipCode
		,Notes)
	VALUES
		(@CityID
		,@Street
		,@Number
		,@ZipCode
		,@AddressNote)
		
	SET @AddressID = SCOPE_IDENTITY()
		
	INSERT INTO dbo.tblPersonsAdditionalData
		(PersonID
		,AddressID
		,RegistrationDate
		,FavouriteMovieID
		,FavouriteBookID
		,QuizScore
		,FavouriteFruitID)
	SELECT
		 @PersonID
		,@AddressID
		,GETDATE() AS RegistrationDate
		,NULL AS FavouriteMovieID
		,NULL AS FavouriteBookID
		,NULL AS QuizScore
		,@FruitID AS FavouriteFruitID

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION

	SELECT @PersonID AS PersonID

	RETURN

END
