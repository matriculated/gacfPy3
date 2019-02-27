IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddSchool]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddSchool] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddSchool]
	  @DOEID varchar(8)
	, @SchoolName varchar(255)
	, @AddressType varchar(255) = 'Main'
	, @AddressLine1 varchar(50)
	, @AddressLine2 varchar(50) = NULL
	, @City varchar(24)
	, @State varchar(2)
	, @Zip varchar(5)
	, @ZipExt varchar(4) = NULL
	, @Country varchar(50) = NULL
	, @ForeignProvince varchar(30) = NULL
	, @ForeignPostalCd varchar(14) = NULL
    , @Phone varchar(10) = NULL
	, @FaxPhoneNumber varchar(10) = NULL
	, @CertificationMethod varchar(10)
	, @ContactName varchar(50) = NULL
	, @HoldFunds bit
	, @ShowSchoolWillProvideLoanPeriodOption bit
	, @SendCommonlineResponseOption bit
	, @AddWhereMissing char(1) = 'N'
	, @OverridePLADDS  char(1) = 'N'
	, @from_pladds bit = 0

AS

BEGIN

SET NOCOUNT ON;

	DECLARE @already_exists tinyint = 0

	DECLARE @exception_list varchar(max) = '';

	IF EXISTS (
		SELECT *
		FROM [dbo].[tbcSchool] t1
		WHERE 1 = 1
		AND t1.DOEID = @DOEID
		)
	BEGIN

		SET @already_exists = @already_exists + 1

	END
	;

	IF EXISTS (
		SELECT *
		FROM [dbo].[tbcInstitution] t1
		WHERE 1 = 1
		AND t1.DOEID = @DOEID
		)
	BEGIN

		SET @already_exists = @already_exists + 1

	END
	;

	IF @already_exists = 2
	BEGIN

		PRINT @DOEID + ' School Already Exists in tbcInstitution and tbcSchool'
		RETURN

	END
	;

	IF @already_exists = 1 AND @AddWhereMissing = 'N'
	BEGIN

		SET @exception_list = @DOEID + ':  ' + @exception_list + 'School Already Exists in either tbcInstitution and tbcSchool.  Run procedure with @AddWhereMissing = ''Y'' to add to missing table.' + CHAR(13);

	END
	;

	DECLARE
		  @CertificationMethodId tinyint
		, @AddressTypeId tinyint
		, @InstitutionTypeId tinyint
		, @SchoolID int
		;

	SELECT @CertificationMethodId = [CertificationMethodId]
	FROM dbo.tbdCertificationMethod t1
	WHERE 1 = 1
	AND t1.CertificationMethod = @CertificationMethod
	;

	SELECT @AddressTypeId = t1.AddressTypeId
	FROM dbo.tbcAddressType t1
	WHERE 1 = 1
	AND t1.AddressType = @AddressType
	;

	SELECT @InstitutionTypeId = t1.InstitutionTypeId
	FROM dbo.tbcInstitutionType t1
	WHERE 1 = 1
	AND t1.InstitutionType = 'School'
	;

	SELECT @SchoolID = [InstitutionID]
	FROM [<Corresponding ISLData_dbname, varchar(20), ISLData>].[dbo].[tbcInstitution] t1
	WHERE 1 = 1
	AND t1.[DOEID] = @DOEID
	;

	IF @SchoolID IS NULL AND @OverridePLADDS = 'Y'
	BEGIN

		SELECT @SchoolID = MAX(t2.[SchoolID])
			FROM (
					SELECT MAX(t1.[SchoolID]) + 1 AS [SchoolID]
					FROM [dbo].tbcSchool t1

					UNION

					SELECT MAX(t1.[InstitutionID]) + 1
					FROM [<Corresponding ISLData_dbname, varchar(20), ISLData>].[dbo].[tbcInstitution] t1
				) t2
		;
	END
	
	IF @CertificationMethodId IS NULL SET @exception_list = @exception_list + '@CertificationMethod is missing or invalid' + CHAR(13);
	IF @AddressTypeId IS NULL SET @exception_list = @exception_list + '@AddressType is missing or invalid' + CHAR(13);
	IF @SchoolID IS NULL SET @exception_list = @exception_list + 'School Missing in ISLData.  Setup School in ISLData and then Rerun.  Alternately, run procedure with @OverridePLADDS = ''Y''' + CHAR(13);

	IF @exception_list <> ''
	BEGIN

		PRINT @DOEID + ':  ' +  @exception_list
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		INSERT [dbo].[tbcInstitution] ([DOEID], [InstitutionName], [InstitutionTypeId])
		SELECT
			  t1.[DOEID]
			, t1.[InstitutionName]
			, t1.[InstitutionTypeId]
		FROM (
			VALUES (@DOEID, @SchoolName, @InstitutionTypeId)
			) t1 ([DOEID], [InstitutionName], [InstitutionTypeId])
		WHERE 1 = 1
		AND NOT EXISTS (
			SELECT *
			FROM [dbo].[tbcInstitution] t2
			WHERE 1 = 1
			AND t1.DOEID = t2.DOEID
			)
		;

		INSERT [dbo].[tbcInstitutionAddress] ([DOEID], [AddressTypeId], [AddressLine1], [AddressLine2], [City], [State], [Zip], [ZipExt], [Country], [ForeignProvince], [ForeignPostalCd], [Phone], [FaxPhoneNumber])
		SELECT
			  t1.[DOEID]
			, t1.[AddressTypeId]
			, t1.[AddressLine1]
			, t1.[AddressLine2]
			, t1.[City]
			, t1.[State]
			, t1.[Zip]
			, t1.[ZipExt]
			, t1.[Country]
			, t1.[ForeignProvince]
			, t1.[ForeignPostalCd]
			, t1.[Phone]
			, t1.[FaxPhoneNumber]
		FROM (
			VALUES (@DOEID, @AddressTypeId, @AddressLine1, @AddressLine2, @City, @State, @Zip, @ZipExt, @Country, @ForeignProvince, @ForeignPostalCd, @Phone, @FaxPhoneNumber)
			) t1 ([DOEID], [AddressTypeId], [AddressLine1], [AddressLine2], [City], [State], [Zip], [ZipExt], [Country], [ForeignProvince], [ForeignPostalCd], [Phone], [FaxPhoneNumber])
		WHERE 1 = 1
		AND NOT EXISTS (
			SELECT *
			FROM [dbo].[tbcInstitutionAddress] t2
			WHERE 1 = 1
			AND t1.DOEID = t2.DOEID
			)
		;

		INSERT [dbo].[tbcSchool] ([SchoolID], [DOEID], [CertificationMethodId], [ContactName], [HoldFunds], [ShowSchoolWillProvideLoanPeriodOption], [SendCommonlineResponseOption])
		SELECT
			  t1.SchoolID
			, t1.[DOEID]
			, t1.[CertificationMethodId]
			, t1.[ContactName]
			, t1.[HoldFunds]
			, t1.[ShowSchoolWillProvideLoanPeriodOption]
			, t1.[SendCommonlineResponseOption]
		FROM (
			VALUES (@SchoolID, @DOEID, @CertificationMethodId, @ContactName, @HoldFunds, @ShowSchoolWillProvideLoanPeriodOption, @SendCommonlineResponseOption)
			) t1 ([SchoolID], [DOEID], [CertificationMethodId], [ContactName], [HoldFunds], [ShowSchoolWillProvideLoanPeriodOption], [SendCommonlineResponseOption])
		WHERE 1 = 1
		AND NOT EXISTS (
			SELECT *
			FROM [dbo].[tbcSchool] t2
			WHERE 1 = 1
			AND t1.DOEID = t2.DOEID
			)
		;

		IF @from_pladds = 1
		BEGIN

			UPDATE t1
			SET t1.[SetupInLTS] = 1
			FROM [PLADDS].[tbdPLADDS_School] t1
			WHERE 1 = 1
			AND t1.[SetupInLTS] = 0
			AND t1.DOEID = @DOEID
			AND EXISTS (
				SELECT *
				FROM dbo.tbcSchool t2
				WHERE 1 = 1
				AND t1.DOEID = t2.DOEID
				)
			AND EXISTS (
				SELECT *
				FROM dbo.tbcInstitution t2
				WHERE 1 = 1
				AND t1.DOEID = t2.DOEID
				)
			;

		END

	COMMIT TRANSACTION


END
	
GO

/*  

EXEC [dbo].[prcAddSchool]
	  @DOEID = '90009400'
	, @SchoolName = 'Carolina Career College'
	, @AddressLine1 = '5400 S. Miami Blvd STE 140'
	, @City = 'Durham'
	, @State = 'NC'
	, @Zip = '27703'
	, @CertificationMethod = 'FILE'
	, @ContactName = ''
	, @HoldFunds = 1
    , @Phone = 'phone'
    , @FaxPhoneNumber = 'faxphone'
	, @ShowSchoolWillProvideLoanPeriodOption = 1
	, @SendCommonlineResponseOption = 0
	, @AddWhereMissing = 'N'
	, @OverridePLADDS = 'Y'
	;

*/




