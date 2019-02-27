
Use $(LoanTypeService_dbname)

/*

EXEC [dbo].[prcCreateLoanType] @new_loan_type_short_description = '', @LoanTypeDescription = 'A', @DetailedDescription = 'A', @MarketSegmentCode = '827825', @LenderCode = '827825', @GradeLevels = '4,-5,A,-B,ALL';
EXEC [dbo].[prcCreateLoanType] @new_loan_type_short_description = '', @LoanTypeDescription = 'A', @DetailedDescription = 'A', @MarketSegmentCode = '827825', @LenderCode = '827825', @GradeLevels = 'ALL';

*/
GO

CREATE OR ALTER PROCEDURE [dbo].[prcCreateLoanType]

	  @Execute char(1) = 'N'
    , @model_loan_type_short_description varchar(255) = NULL
    , @new_loan_type_short_description varchar(255)
    
    ------Loan Type Parameters------
    , @Enabled bit = 0
    , @LoanTypeDescription varchar(255)
    , @DetailedDescription varchar(1024)
    , @MarketSegmentCode varchar(10) = NULL
    , @LenderCode varchar(8) = NULL
    , @CreditTypeDescription varchar(20) = NULL
    , @FixedRate bit = NULL
    , @NchelpCd char(3) = NULL
    , @LoanProgramDescription varchar(100) = NULL
    , @TermsUrl varchar(1000) = NULL
    , @LoanFundingDescription varchar(255) = NULL
    , @InterestRateTypeDescription varchar(255) = NULL
    , @RepaymentOptionCode char(1) = NULL
    , @BondIssueCode varchar(20) = NULL
    , @DefermentRequestCode char(1) = NULL
    , @MinimumAmount int = NULL
    , @AnnualMax int = NULL
    , @BorrowerInterestIndicator bit = NULL
    , @ServicerId tinyint = NULL
    , @Consolidation bit = NULL
    , @Counteroffer bit = NULL
    , @JointCosignerCounteroffer bit = NULL
    , @RequiresUnderwriting bit = NULL
    , @SchoolUseOnly varchar(23) = NULL
    , @CompassLoanProgram varchar(6) = NULL
    , @ShareDebtToIncome bit = NULL
    , @ShowCostOfLiving bit = NULL
    , @MinTuition int = NULL
    , @MaxTuition int = NULL
    , @MaxCostOfLiving int = NULL
    , @RepurposeCLFields bit = NULL
    , @RepaymentTerm smallint = NULL
    , @AlternativeBankruptcyLogic bit = NULL
    , @CertificationRequired bit = NULL
    , @SpecialCriteria varchar(20) = 'NONE'
    , @MinimumLoanAmount int = NULL
    , @LoanTermBelowMinimumMonths smallint = NULL
    , @XMLConfigurationName varchar(255) = NULL
    , @IndexCode varchar(64) = NULL
    , @StartDate date = NULL
    , @EndDate date = NULL
    , @AlternativeAppVersion char(4) = '0001'
    
    , @IsCosignerAllowed bit
    , @DocumentTypes varchar(max)
    -----------------------------
    
    -----Grouping Parameters-----
    , @GradeLevels varchar(max) = NULL		--ALL, -GL, GL
    , @States varchar(max) = NULL			--ALL, -ST, ST
    , @SchoolList varchar(max) = NULL		--ALL, -DOEID, DOEID
    -----------------------------
    
    , @PrintedApplicationDescription                 VARCHAR(255) = NULL
    , @MarketSegmentApplicationDisclosureDescription VARCHAR(255) = NULL
    , @InterestCapitalizationDescription             VARCHAR(50)  = NULL
    , @InterimRepaymentDescription                   VARCHAR(50)  = NULL
    , @GracePeriod                                   INT          = NULL
    , @MaxDefermentPeriod                            INT          = NULL
    , @LateChargeRate                                NUMERIC(5,2) = NULL
    , @LateChargeCap                                 NUMERIC(7,2) = NULL
    , @ReturnedCheckRate                             NUMERIC(5,2) = NULL
    , @ReturnedCheckFlat                             NUMERIC(7,2) = NULL
    , @MinPayment                                    NUMERIC(7,2) = NULL
    , @MaxInterestRate                               NUMERIC(5,2) = NULL
    , @ApplicantCreditAgreement_SignableDocName      VARCHAR(50)  = NULL
    , @CosignerAddendum_SignableDocName              VARCHAR(50)  = NULL
    , @ApplicantReferenceCount                       TINYINT      = NULL
    
    
    , @from_pladds bit = 0
	
AS

BEGIN

	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcLoanType] t1 WHERE t1.ShortDescription = @new_loan_type_short_description)
	BEGIN

		PRINT 'Loan Type Already Exists'
		RETURN

	END
	;

	DECLARE
		  @MarketSegmentId smallint
		, @CreditTypeId tinyint
		, @LoanProgramId smallint
		, @TermsId smallint
		, @LoanFundingId smallint
		, @InterestRateTypeID tinyint
		, @SpecialCriteriaId tinyint
		, @MinimumLoanTermId tinyint
		, @ReferenceNotesConfigId tinyint
		, @IndexCodeId tinyint
		, @ParentLoan bit
		, @SortIndex smallint = NULL
		, @GradeLevelGroupId smallint
		, @StateGroupId  int
		, @SchoolGroupId int

        , @InterestCapitalizationID                TINYINT
        , @DefaultInterimRepaymentID               TINYINT
        , @InterimRepaymentOptionID                TINYINT
        , @ApplicantCreditAgreement_SignableDocID  SMALLINT
        , @CosignerAddendum_SignableDocID          SMALLINT 

   
	;

	SELECT @MarketSegmentId = t1.MarketSegmentId, @ParentLoan = [ParentLoan] FROM [dbo].[tbcMarketSegment] t1 WHERE 1 = 1 AND t1.[MarketSegmentCode] = @MarketSegmentCode AND t1.[LenderCode] = @LenderCode;
	SELECT @CreditTypeId = t1.[CreditTypeId] FROM [dbo].[tbdCreditType] t1 WHERE 1 = 1 AND t1.CreditTypeDescription = @CreditTypeDescription;
	SELECT @LoanProgramId = [LoanProgramId]	FROM [dbo].tbcLoanProgram t1 WHERE 1 = 1 AND t1.LoanProgramDescription = @LoanProgramDescription;
	SELECT @TermsId = t1.[TermsId] FROM [dbo].[tbcTerms] t1 WHERE 1 = 1	AND t1.[TermsUrl] = @TermsUrl;
	SELECT @LoanFundingId = t1.LoanFundingId FROM [dbo].tbcLoanFunding t1 WHERE 1 = 1 AND t1.LoanFundingDescription = @LoanFundingDescription;
	SELECT @InterestRateTypeID = t1.[InterestRateTypeID] FROM [dbo].[tbcInterestRateType] t1 WHERE 1 = 1 AND t1.[InterestRateTypeDescription] = @InterestRateTypeDescription;
	SELECT @SpecialCriteriaId = t1.SpecialCriteriaId FROM [dbo].[tbcSpecialCriteria] t1	WHERE 1 = 1	AND t1.SpecialCriteria = @SpecialCriteria;
	SELECT @MinimumLoanTermId = t1.MinimumLoanTermId FROM [dbo].[tbcMinimumLoanTerm] t1	WHERE 1 = 1	AND t1.MinimumLoanAmount = @MinimumLoanAmount AND t1.LoanTermBelowMinimumMonths = @LoanTermBelowMinimumMonths;
	SELECT @ReferenceNotesConfigId = t1.ReferenceNotesConfigId FROM [dbo].[tbcReferenceNotesConfig] t1	WHERE 1 = 1	AND t1.XMLConfigurationName = @XMLConfigurationName AND t1.XMLConfigurationName <> '';
	SELECT @IndexCodeId = t1.IndexCodeId FROM [dbo].[tbcIndexCode] t1	WHERE 1 = 1	AND t1.IndexCode = @IndexCode;
   	SELECT @InterestCapitalizationID = t1.InterestCapitalizationID FROM [dbo].[tbcInterestCapitalization] t1 WHERE 1 = 1 AND t1.InterestCapitalizationDescription = @InterestCapitalizationDescription;
   	SELECT @DefaultInterimRepaymentID = t1.DefaultInterimRepaymentID FROM tbcDefaultInterimRepayment t1 WHERE DefaultInterimRepayment = @InterimRepaymentDescription;
    SELECT @InterimRepaymentOptionID = t1.InterimRepaymentOptionID from tbdInterimRepaymentOption t1 WHERE InterimRepaymentOption = @InterimRepaymentDescription AND InterestCapitalizationID = @InterestCapitalizationID
    SELECT @ApplicantCreditAgreement_SignableDocID = t1.SignableDocumentID from dbo.tbcSignableDocument t1 WHERE 1=1 AND SignableDocumentName = @ApplicantCreditAgreement_SignableDocName; 
    -- the following fields can be null
    IF @CosignerAddendum_SignableDocName IS NOT NULL BEGIN SELECT @CosignerAddendum_SignableDocID = t1.SignableDocumentID from dbo.tbcSignableDocument t1 WHERE 1=1 AND SignableDocumentName = @CosignerAddendum_SignableDocName; END

	IF @GradeLevels IS NOT NULL
	BEGIN

		WHILE CHARINDEX(', ', @GradeLevels) > 0 SET @GradeLevels = REPLACE(@GradeLevels, ', ', ',');
		WHILE CHARINDEX(' ,', @GradeLevels) > 0 SET @GradeLevels = REPLACE(@GradeLevels, ' ,', ',');
		SET @GradeLevels = LTRIM(RTRIM(@GradeLevels));

		DECLARE @SelectedGradeLevels TABLE (
				GradeLevelCd char(1)
			  , Selected bit
				)
		;

		DECLARE @tmpGradeLevels TABLE (
				GradeLevelCd char(1)
			  , Selected bit
				)
		;
  
		;WITH GradeLevel1 (StartPosition, EndPosition, GradeLevelItem) AS
		(
			SELECT
				  1 AS StartPosition
				, ISNULL(NULLIF(CHARINDEX(',', @GradeLevels, 1), 0), LEN(@GradeLevels) + 1) AS EndPosition
				, SUBSTRING(@GradeLevels, 1, ISNULL(NULLIF(CHARINDEX(',', @GradeLevels, 1), 0), LEN(@GradeLevels) + 1) - 1) AS GradeLevelItem
			WHERE @GradeLevels IS NOT NULL

			UNION ALL

			SELECT
				  CONVERT(int, EndPosition) + 1 AS StartPosition
				, ISNULL(NULLIF(CHARINDEX(',', @GradeLevels, EndPosition + 1), 0), LEN(@GradeLevels) + 1) AS EndPosition
				, SUBSTRING(@GradeLevels, EndPosition + 1, ISNULL(NULLIF(CHARINDEX(',', @GradeLevels, EndPosition + 1), 0), LEN(@GradeLevels) + 1) - EndPosition - 1) AS GradeLevelItem
			FROM GradeLevel1
			WHERE EndPosition < LEN(@GradeLevels) + 1
		)
		, GradeLevel2 (GradeLevelItem, Selected) AS
		(
		SELECT
			  CASE WHEN GradeLevelItem LIKE '-%' THEN RIGHT(GradeLevelItem, LEN(GradeLevelItem) - 1) ELSE GradeLevelItem END AS GradeLevelItem
			, CASE WHEN GradeLevelItem LIKE '-%' THEN 0 ELSE 1 END AS Selected
		FROM GradeLevel1
		)
		, GradeLevel3 (GradeLevelItem, Selected) AS
		(
		SELECT
			  CASE WHEN GradeLevelItem IN ('ALL') THEN '%' ELSE GradeLevelItem END AS GradeLevelItem
			, Selected
		  FROM GradeLevel2
		)
		INSERT INTO @SelectedGradeLevels (GradeLevelCd, Selected)
		SELECT
			  GradeLevelItem
			, Selected
		FROM GradeLevel3
		OPTION (MAXRECURSION 0)
		;

		INSERT @tmpGradeLevels (GradeLevelCd, Selected)
		SELECT
			  t1.GradeLevelCd
			, t1.Selected
		FROM @SelectedGradeLevels t1
		WHERE 1 = 1
		AND t1.GradeLevelCd <> '%'

		UNION

		SELECT
			  t1.GradeLevelCd
			, 1 AS Selected
		FROM dbo.tbdGradeLevel t1
		CROSS JOIN @SelectedGradeLevels t2
		WHERE 1 = 1
		AND t2.GradeLevelCd = '%'
		AND NOT EXISTS (
			SELECT *
			FROM @SelectedGradeLevels t3
			WHERE 1 = 1
			AND t1.GradeLevelCd = t3.GradeLevelCd
			)
		;

		;WITH current_grade_groups AS
		(
			SELECT 
				  t3.GradeLevelGroupId
				, t1.[GradeLevelCd]
				, COUNT(*) OVER (PARTITION BY t3.GradeLevelGroupId) AS set_count
			FROM dbo.tbdGradeLevel t1
			INNER JOIN [dbo].[tbcGradeLevelGroupGradeLevelCode] t2 ON t1.GradeLevelCd = t2.GradeLevelCd
			INNER JOIN [dbo].[tbcGradeLevelGroup] t3 ON t2.GradeLevelGroupId = t3.GradeLevelGroupId
		) , new_grade_group AS
		(
			SELECT
				  t1.[GradeLevelCd]
				, COUNT(*) OVER () AS set_count
			FROM @tmpGradeLevels t1
			WHERE 1 = 1
			AND t1.Selected = 1
		)
		SELECT
			  @GradeLevelGroupId = t1.GradeLevelGroupId
		FROM current_grade_groups t1
		INNER JOIN new_grade_group t2 ON t1.set_count = t2.set_count
									 AND t1.GradeLevelCd = t2.GradeLevelCd
		WHERE 1 = 1
		GROUP BY
			  t1.GradeLevelGroupId
			, t1.set_count
		HAVING 
			  COUNT(*) = t1.set_count
		;

	END
	;

	IF @States IS NOT NULL
	BEGIN

		WHILE CHARINDEX(', ', @States) > 0 SET @States = REPLACE(@States, ', ', ',');
		WHILE CHARINDEX(' ,', @States) > 0 SET @States = REPLACE(@States, ' ,', ',');
		SET @States = LTRIM(RTRIM(@States));

		DECLARE @SelectedStateCodes TABLE (
				StateCode char(2)
			  , Selected bit
				)
		;

		DECLARE @tmpStateCodes TABLE (
				StateCode char(2)
			  , Selected bit
				)
		;

		;WITH StateCode1 (StartPosition, EndPosition, StateCodeItem) AS
		(
			SELECT
				  1 AS StartPosition
				, ISNULL(NULLIF(CHARINDEX(',', @States, 1), 0), LEN(@States) + 1) AS EndPosition
				, SUBSTRING(@States, 1, ISNULL(NULLIF(CHARINDEX(',', @States, 1), 0), LEN(@States) + 1) - 1) AS StateCodeItem
			WHERE @States IS NOT NULL

			UNION ALL

			SELECT
				  CONVERT(int, EndPosition) + 1 AS StartPosition
				, ISNULL(NULLIF(CHARINDEX(',', @States, EndPosition + 1), 0), LEN(@States) + 1) AS EndPosition
				, SUBSTRING(@States, EndPosition + 1, ISNULL(NULLIF(CHARINDEX(',', @States, EndPosition + 1), 0), LEN(@States) + 1) - EndPosition - 1) AS StateCodeItem
			FROM StateCode1
			WHERE EndPosition < LEN(@States) + 1
		), StateCode2 (StateCodeItem, Selected) AS
		(
		SELECT
			  CASE WHEN StateCodeItem LIKE '-%' THEN RIGHT(StateCodeItem, LEN(StateCodeItem) - 1) ELSE StateCodeItem END AS StateCodeItem
			, CASE WHEN StateCodeItem LIKE '-%' THEN 0 ELSE 1 END AS Selected
		FROM StateCode1
		), StateCode3 (StateCodeItem, Selected) AS
		(
		SELECT
			  CASE WHEN StateCodeItem IN ('ALL') THEN '%' ELSE StateCodeItem END AS StateCodeItem
			, Selected
		  FROM StateCode2
		)
		INSERT INTO @SelectedStateCodes (StateCode, Selected)
		SELECT
			  StateCodeItem
			, Selected
		FROM StateCode3
		OPTION (MAXRECURSION 0)
		;

		INSERT @tmpStateCodes (StateCode, Selected)
		SELECT
			  t1.StateCode
			, t1.Selected
		FROM @SelectedStateCodes t1
		WHERE 1 = 1
		AND t1.StateCode <> '%'

		UNION

		SELECT
			  t1.StateCode
			, 1 AS Selected
		FROM dbo.tbcState t1
		CROSS JOIN @SelectedStateCodes t2
		WHERE 1 = 1
		AND t2.StateCode = '%'
		AND NOT EXISTS (
			SELECT *
			FROM @SelectedStateCodes t3
			WHERE 1 = 1
			AND t1.StateCode = t3.StateCode
			)
		;

		;WITH current_state_groups AS
		(
			SELECT 
				  t3.StateGroupId
				, t1.[StateCode]
				, COUNT(*) OVER (PARTITION BY t3.StateGroupId) AS set_count
			FROM dbo.tbcState t1
			INNER JOIN [dbo].[tbcStateGroupStateCode] t2 ON t1.StateCode = t2.StateCode
			INNER JOIN [dbo].[tbcStateGroup] t3 ON t2.StateGroupId = t3.StateGroupId
		) , new_grade_group AS
		(
			SELECT
				  t1.[StateCode]
				, COUNT(*) OVER () AS set_count
			FROM @tmpStateCodes t1
			WHERE 1 = 1
			AND t1.Selected = 1
		)
		SELECT
			  @StateGroupId = t1.StateGroupId
		FROM current_state_groups t1
		INNER JOIN new_grade_group t2 ON t1.set_count = t2.set_count
									 AND t1.StateCode = t2.StateCode
		WHERE 1 = 1
		GROUP BY
			  t1.StateGroupId
			, t1.set_count
		HAVING 
			  COUNT(*) = t1.set_count
		;

	END
	;

	IF @SchoolList IS NOT NULL
	BEGIN

		WHILE CHARINDEX(', ', @SchoolList) > 0 SET @SchoolList = REPLACE(@SchoolList, ', ', ',');
		WHILE CHARINDEX(' ,', @SchoolList) > 0 SET @SchoolList = REPLACE(@SchoolList, ' ,', ',');
		SET @SchoolList = LTRIM(RTRIM(@SchoolList));

		DECLARE @SelectedSchools TABLE (
				DOEID char(8)
			  , Selected bit
				)
		;

		DECLARE @tmpSchools TABLE (
				DOEID char(8)
			  , Selected bit
				)
		;
		
		;WITH SchoolCode1 (StartPosition, EndPosition, SchoolCodeItem) AS
		(
			SELECT
				  1 AS StartPosition
				, ISNULL(NULLIF(CHARINDEX(',', @SchoolList, 1), 0), LEN(@SchoolList) + 1) AS EndPosition
				, SUBSTRING(@SchoolList, 1, ISNULL(NULLIF(CHARINDEX(',', @SchoolList, 1), 0), LEN(@SchoolList) + 1) - 1) AS SchoolCodeItem
			WHERE @SchoolList IS NOT NULL

			UNION ALL

			SELECT
				  CONVERT(int, EndPosition) + 1 AS StartPosition
				, ISNULL(NULLIF(CHARINDEX(',', @SchoolList, EndPosition + 1), 0), LEN(@SchoolList) + 1) AS EndPosition
				, SUBSTRING(@SchoolList, EndPosition + 1, ISNULL(NULLIF(CHARINDEX(',', @SchoolList, EndPosition + 1), 0), LEN(@SchoolList) + 1) - EndPosition - 1) AS SchoolCodeItem
			FROM SchoolCode1
			WHERE EndPosition < LEN(@SchoolList) + 1
		), SchoolCode2 (SchoolCodeItem, Selected) AS
		(
		SELECT
			  CASE WHEN SchoolCodeItem LIKE '-%' THEN RIGHT(SchoolCodeItem, LEN(SchoolCodeItem) - 1) ELSE SchoolCodeItem END AS SchoolCodeItem
			, CASE WHEN SchoolCodeItem LIKE '-%' THEN 0 ELSE 1 END AS Selected
		FROM SchoolCode1
		), SchoolCode3 (SchoolCodeItem, Selected) AS
		(
		SELECT
			  CASE WHEN SchoolCodeItem IN ('ALL') THEN '%' ELSE SchoolCodeItem END AS SchoolCodeItem
			, Selected
		  FROM SchoolCode2
		)
		INSERT INTO @SelectedSchools (DOEID, Selected)
		SELECT
			  SchoolCodeItem
			, Selected
		FROM SchoolCode3
		OPTION (MAXRECURSION 0)

		INSERT @tmpSchools (DOEID, Selected)
		SELECT
			  t1.DOEID
			, t1.Selected
		FROM @SelectedSchools t1
		WHERE 1 = 1
		AND t1.DOEID <> '%'
		AND (
				LEFT(t1.DOEID, 1) = '9'
				OR
				EXISTS (
					SELECT *
					FROM [dbo].[tbcPEPS] t10
					WHERE 1 = 1
					AND t1.DOEID = t10.OPEID
					AND t10.SCHTYPE IN ('1', '2')
					AND t10.PGMLENGTH IN ('01', '05', '06', '07', '08')
					AND t10.ELIGIND = 'Y'
					)
			)

		UNION

		SELECT
			  t1.DOEID
			, 1 AS Selected
		FROM dbo.tbcSchool t1
		CROSS JOIN @SelectedSchools t2
		WHERE 1 = 1
		AND t2.DOEID = '%'
		AND NOT EXISTS (
			SELECT *
			FROM @SelectedSchools t3
			WHERE 1 = 1
			AND t1.DOEID = t3.DOEID
			)
		AND (
				LEFT(t1.DOEID, 1) = '9'
				OR
				EXISTS (
					SELECT *
					FROM [dbo].[tbcPEPS] t10
					WHERE 1 = 1
					AND t1.DOEID = t10.OPEID
					AND t10.SCHTYPE IN ('1', '2')
					AND t10.PGMLENGTH IN ('01', '05', '06', '07', '08')
					AND t10.ELIGIND = 'Y'
					)
			)
		;

		;WITH current_school_groups AS
		(
			SELECT 
				  t3.SchoolGroupId
				, t1.[DOEID]
				, COUNT(*) OVER (PARTITION BY t3.SchoolGroupId) AS set_count
			FROM dbo.tbcSchool t1
			INNER JOIN [dbo].[tbcSchoolGroupSchoolID] t2 ON t1.SchoolID = t2.SchoolID
			INNER JOIN [dbo].[tbcSchoolGroup] t3 ON t2.SchoolGroupId = t3.SchoolGroupId
		) , new_school_group AS
		(
			SELECT
				  t1.[DOEID]
				, COUNT(*) OVER () AS set_count
			FROM @tmpSchools t1
			WHERE 1 = 1
			AND t1.Selected = 1
		)
		SELECT
			  @SchoolGroupId = t1.SchoolGroupId
		FROM current_school_groups t1
		INNER JOIN new_school_group t2 ON t1.set_count = t2.set_count
									 AND t1.DOEID = t2.DOEID
		WHERE 1 = 1
		GROUP BY
			  t1.SchoolGroupId
			, t1.set_count
		HAVING 
			  COUNT(*) = t1.set_count
		;

	END
	;

    IF (@InterestCapitalizationDescription IS NOT NULL AND @InterestCapitalizationID IS NULL)
    BEGIN
        SELECT @InterestCapitalizationiD   = MAX(InterestCapitalizationID) + 1 from tbcInterestCapitalization

        INSERT INTO dbo.tbcInterestCapitalization 
        (InterestCapitalizationId, InterestCapitalizationDescription)
        SELECT @InterestCapitalizationID, @InterestCapitalizationDescription;

    END

    IF (@InterimRepaymentDescription IS NOT NULL AND @DefaultInterimRepaymentID IS NULL)
    BEGIN
        SELECT @DefaultInterimRepaymentID   = MAX(DefaultInterimRepaymentID) + 1 from tbcDefaultInterimRepayment

        INSERT INTO dbo.tbcDefaultInterimRepayment
        (DefaultInterimRepaymentID, DefaultInterimRepayment)
        SELECT @DefaultInterimRepaymentID, @InterimRepaymentDescription;

    END

    IF (@InterimRepaymentDescription IS NOT NULL AND @InterimRepaymentOptionID IS NULL)
    BEGIN
        SELECT @InterimRepaymentOptionID = MAX(InterimRepaymentOptionID) + 1 from tbdInterimRepaymentOption

        INSERT INTO dbo.tbdInterimRepaymentOption
        (InterimRepaymentOptionID, InterestCapitalizationID, InterimRepaymentOption)
        SELECT @InterimRepaymentOptionID , @InterestCapitalizationID, @InterimRepaymentDescription
    END    

    IF (@ApplicantCreditAgreement_SignableDocName IS NOT NULL AND @ApplicantCreditAgreement_SignableDocID IS NULL)
    BEGIN
        SELECT @ApplicantCreditAgreement_SignableDocID  = MAX(SignableDocumentID) + 1 from tbcSignableDocument
        INSERT INTO dbo.tbcSignableDocument 
        (SignableDocumentId, SignableDocumentName)
        SELECT @ApplicantCreditAgreement_SignableDocID, @ApplicantCreditAgreement_SignableDocName;
    END
    
    IF (@CosignerAddendum_SignableDocName IS NOT NULL AND @CosignerAddendum_SignableDocID IS NULL)
    BEGIN
        
        SELECT @CosignerAddendum_SignableDocID = MAX(SignableDocumentID) + 1 FROM dbo.tbcSignableDocument
        ;
        INSERT INTO dbo.tbcSignableDocument 
        (SignableDocumentId, SignableDocumentName)
        SELECT @CosignerAddendum_SignableDocID, @CosignerAddendum_SignableDocName
        ;
    END


	IF @model_loan_type_short_description IS NOT NULL
	BEGIN

		--SELECT 'Started Section @model_loan_type_short_description'

		IF @MarketSegmentId IS NULL AND @MarketSegmentCode IS NULL AND @LenderCode IS NULL
		SELECT @MarketSegmentId = t1.MarketSegmentId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @CreditTypeId IS NULL AND @CreditTypeDescription IS NULL
		SELECT @CreditTypeId = t1.[CreditTypeId] FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @FixedRate IS NULL
		SELECT @FixedRate = t1.FixedRate FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @NchelpCd IS NULL
		SELECT @NchelpCd = t1.NchelpCd FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @LoanProgramId IS NULL
		SELECT @LoanProgramId = t1.[LoanProgramId] FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @TermsId IS NULL
		SELECT @TermsId = t1.TermsId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @LoanFundingId IS NULL
		SELECT @LoanFundingId = t1.[LoanFundingId] FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @InterestRateTypeID IS NULL
		SELECT @InterestRateTypeID = t1.InterestRateTypeID FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @RepaymentOptionCode IS NULL
		SELECT @RepaymentOptionCode = t1.RepaymentOptionCode FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @BondIssueCode IS NULL
		SELECT @BondIssueCode = t1.BondIssueCode FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @DefermentRequestCode IS NULL
		SELECT @DefermentRequestCode = t1.DefermentRequestCode FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @MinimumAmount IS NULL
		SELECT @MinimumAmount = t1.MinimumAmount FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @AnnualMax IS NULL
		SELECT @AnnualMax = t1.AnnualMax FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @BorrowerInterestIndicator IS NULL
		SELECT @BorrowerInterestIndicator = t1.BorrowerInterestIndicator FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @ServicerId IS NULL
		SELECT @ServicerId = t1.ServicerId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @Consolidation IS NULL
		SELECT @Consolidation = t1.Consolidation FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @Counteroffer IS NULL
		SELECT @Counteroffer = t1.Counteroffer FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @JointCosignerCounteroffer IS NULL
		SELECT @JointCosignerCounteroffer = t1.JointCosignerCounteroffer FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @RequiresUnderwriting IS NULL
		SELECT @RequiresUnderwriting = t1.RequiresUnderwriting FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @SchoolUseOnly IS NULL
		SELECT @SchoolUseOnly = t1.SchoolUseOnly FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @CompassLoanProgram IS NULL
		SELECT @CompassLoanProgram = t1.CompassLoanProgram FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @ShareDebtToIncome IS NULL
		SELECT @ShareDebtToIncome = t1.ShareDebtToIncome FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @ShowCostOfLiving IS NULL
		SELECT @ShowCostOfLiving = t1.ShowCostOfLiving FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @MinTuition IS NULL
		SELECT @MinTuition = t1.MinTuition FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @MaxTuition IS NULL
		SELECT @MaxTuition = t1.MaxTuition FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @MaxCostOfLiving IS NULL
		SELECT @MaxCostOfLiving = t1.MaxCostOfLiving FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @RepurposeCLFields IS NULL
		SELECT @RepurposeCLFields = t1.RepurposeCLFields FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @RepaymentTerm IS NULL
		SELECT @RepaymentTerm = t1.RepaymentTerm FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @AlternativeBankruptcyLogic IS NULL
		SELECT @AlternativeBankruptcyLogic = t1.AlternativeBankruptcyLogic FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @CertificationRequired IS NULL
		SELECT @CertificationRequired = t1.CertificationRequired FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @SpecialCriteriaId IS NULL
		SELECT @SpecialCriteriaId = t1.SpecialCriteriaId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @MinimumLoanTermId IS NULL AND @MinimumLoanAmount IS NULL AND @LoanTermBelowMinimumMonths IS NULL
		SELECT @MinimumLoanTermId = t1.MinimumLoanTermId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @ReferenceNotesConfigId IS NULL
		SELECT @ReferenceNotesConfigId = t1.ReferenceNotesConfigId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @IndexCodeId IS NULL
		SELECT @IndexCodeId = t1.IndexCodeId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @StartDate IS NULL
		SELECT @StartDate = t1.StartDate FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @EndDate IS NULL
		SELECT @EndDate = t1.EndDate FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @GradeLevels IS NULL
		SELECT @GradeLevelGroupId = t1.GradeLevelGroupId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @States IS NULL
		SELECT @StateGroupId = t1.StateGroupId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

		IF @SchoolList IS NULL
		SELECT @SchoolGroupId = t1.SchoolGroupId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;


        IF @PrintedApplicationDescription IS NULL
        SELECT @PrintedApplicationDescription = t1.PrintedApplicationDescription FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @MarketSegmentApplicationDisclosureDescription IS NULL
        SELECT @MarketSegmentApplicationDisclosureDescription = t1.MarketSegmentApplicationDisclosureDescription FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @InterestCapitalizationID IS NULL
        SELECT @InterestCapitalizationID = t1.InterestCapitalizationID FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @DefaultInterimRepaymentID IS NULL
        SELECT @DefaultInterimRepaymentID = t1.DefaultInterimRepaymentID FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @InterimRepaymentOptionID IS NULL
        SELECT @InterimRepaymentOptionID = t1.InterimRepaymentOptionID FROM [dbo].[tbcLoanTypeInterimRepaymentOption] t1 JOIN tbcLoanType t2 on t1.LoanTypeId = t2.LoanTypeId WHERE 1=1 and t2.ShortDescription = @model_loan_type_short_description

        IF @GracePeriod IS NULL
        SELECT @GracePeriod = t1.GracePeriod FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @MaxDefermentPeriod IS NULL
        SELECT @MaxDefermentPeriod = t1.MaxDefermentPeriod FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @LateChargeRate IS NULL
        SELECT @LateChargeRate = t1.LateChargeRate FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @LateChargeCap IS NULL
        SELECT @LateChargeCap = t1.LateChargeCap FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @ReturnedCheckRate IS NULL
        SELECT @ReturnedCheckRate = t1.ReturnedCheckRate FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @ReturnedCheckFlat IS NULL
        SELECT @ReturnedCheckFlat = t1.ReturnedCheckFlat FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @MinPayment IS NULL
        SELECT @MinPayment = t1.MinPayment FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @MaxInterestRate IS NULL
        SELECT @MaxInterestRate = t1.MaxInterestRate FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @IsCosignerAllowed IS NULL
        SELECT @IsCosignerAllowed = t1.MaxInterestRate FROM [dbo].[tbcLoanType] t1 WHERE 1=1 and t1.ShortDescription = @model_loan_type_short_description

        IF @ApplicantCreditAgreement_SignableDocID IS NULL
        SELECT @ApplicantCreditAgreement_SignableDocID = t1.ApplicantCreditAgreementId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;
        
        IF @CosignerAddendum_SignableDocID IS NULL    
        SELECT @CosignerAddendum_SignableDocID = t1.CosignerAddendumId FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;

        IF @ApplicantReferenceCount is NULL
        SELECT @ApplicantReferenceCount = t1.ApplicantReferenceCount FROM [dbo].[tbcLoanType] t1 WHERE 1 = 1 AND t1.ShortDescription = @model_loan_type_short_description;


		
/*
		SELECT
			  @MarketSegmentId AS MarketSegmentId				
			, @CreditTypeId AS CreditTypeId
			, @FixedRate AS FixedRate
			, @NchelpCd AS NchelpCd
			, @LoanProgramId AS LoanProgramId
			, @TermsId AS TermsId
			, @LoanFundingId AS LoanFundingId
			, @InterestRateTypeID AS InterestRateTypeID
			, @RepaymentOptionCode AS RepaymentOptionCode
			, @BondIssueCode AS BondIssueCode
			, @DefermentRequestCode AS DefermentRequestCode
			, @MinimumAmount AS MinimumAmount
			, @AnnualMax AS AnnualMax
			, @BorrowerInterestIndicator AS BorrowerInterestIndicator
			, @ServicerId AS ServicerId
			, @Consolidation AS Consolidation
			, @Counteroffer AS Counteroffer
			, @JointCosignerCounteroffer AS JointCosignerCounteroffer
			, @RequiresUnderwriting AS RequiresUnderwriting
			, @SchoolUseOnly AS SchoolUseOnly
			, @CompassLoanProgram AS CompassLoanProgram
			, @ShareDebtToIncome AS ShareDebtToIncome
			, @ShowCostOfLiving AS ShowCostOfLiving
			, @MinTuition AS MinTuition
			, @MaxTuition AS MaxTuition
			, @MaxCostOfLiving AS MaxCostOfLiving
			, @RepurposeCLFields AS RepurposeCLFields
			, @RepaymentTerm AS RepaymentTerm
			, @AlternativeBankruptcyLogic AS AlternativeBankruptcyLogic
			, @CertificationRequired AS CertificationRequired
			, @SpecialCriteriaId AS SpecialCriteriaId
			, @MinimumLoanTermId AS MinimumLoanTermId
			, @ReferenceNotesConfigId AS ReferenceNotesConfigId
			, @IndexCodeId AS IndexCodeId
			, @StartDate AS StartDate
			, @EndDate AS EndDate
			, @GradeLevelGroupId AS GradeLevelGroupId
			, @StateGroupId AS StateGroupId
			, @SchoolGroupId AS SchoolGroupId
			, @PrintedApplicationDescription AS PrintedApplicationDescription 
			, @MarketSegmentApplicationDisclosureDescription AS MarketSegmentApplicationDisclosureDescription
			, @InterestCapitalizationDescription AS InterestCapitalizationDescription
			, @InterimRepaymentDescription AS InterimRepaymentDescription
			, @GracePeriod AS GracePeriod
			, @MaxDefermentPeriod AS MaxDefermentPeriod
			, @LateChargeRate AS LateChargeRate 
			, @LateChargeCap AS LateChargeCap 
			, @ReturnedCheckRate AS ReturnedCheckRate 
			, @ReturnedCheckFlat AS ReturnedCheckFlat 
			, @MinPayment AS MinPayment 
			, @MaxInterestRate AS MaxInterestRate 
            , @IsCosignerAllowed as IsCosignerAllowed
			, @ApplicantCreditAgreement_SignableDocID AS ApplicantCreditAgreement_SignableDocID 
			, @CosignerAddendum_SignableDocID AS CosignerAddendum_SignableDocID 
			, @ApplicantReferenceCount AS ApplicantReferenceCount
		;
*/		

	END
	;
	
	SET @BondIssueCode = COALESCE(@BondIssueCode, '');
	SET @SchoolUseOnly = COALESCE(@SchoolUseOnly, '');
	SET @CompassLoanProgram = COALESCE(@CompassLoanProgram, '');
	SET @MinTuition = COALESCE(@MinTuition, 0);

	IF @MarketSegmentId IS NOT NULL
	SELECT @SortIndex = MAX(t1.SortIndex) + 1
	FROM dbo.tbcLoanType t1
	WHERE 1 = 1
	AND t1.MarketSegmentId = @MarketSegmentId
	AND t1.SortIndex < 99;

	SET @SortIndex = COALESCE(@SortIndex, 1);
	
	IF NOT EXISTS (SELECT * FROM [dbo].[tbdRepaymentOption] WHERE [RepaymentOptionCode] = @RepaymentOptionCode) AND @RepaymentOptionCode IS NOT NULL
	SET @RepaymentOptionCode = NULL;

	DECLARE @exception_list varchar(max) = '';

		IF EXISTS (
					SELECT *
					FROM @tmpSchools t1
					WHERE 1 = 1
					AND t1.Selected = 1
					AND NOT EXISTS(
						SELECT *
						FROM dbo.tbcSchool t2
						WHERE 1 = 1
						AND t1.DOEID = t2.DOEID
						)
					)
		BEGIN

			SET @exception_list = @exception_list + 'Not All Schools are Setup' + CHAR(13);

		END
		;

		WHILE CHARINDEX(', ', @DocumentTypes) > 0 SET @DocumentTypes = REPLACE(@DocumentTypes, ', ', ',');
		WHILE CHARINDEX(' ,', @DocumentTypes) > 0 SET @DocumentTypes = REPLACE(@DocumentTypes, ' ,', ',');

		IF EXISTS (
				SELECT *
				FROM string_split(@DocumentTypes,',') t1
				WHERE 1 = 1
				AND NOT EXISTS (
					SELECT *
					FROM dbo.tbdDocumentType t2
					WHERE 1 = 1
					AND CONVERT(varchar(15), t1.[value]) = t2.DocumentType
					)
				)
		BEGIN

			SET @exception_list = @exception_list + 'Invalid @DocumentTypes Submitted' + CHAR(13);

		END
		;


		IF @LoanTypeDescription = '' SET @exception_list = @exception_list + '@LoanTypeDescription is required' + CHAR(13);
		IF @DetailedDescription = '' SET @exception_list = @exception_list + '@DetailedDescription is required' + CHAR(13);
		IF @MarketSegmentId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @MarketSegmentCode/@LenderCode Combination' + CHAR(13);
		IF @CreditTypeId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @CreditTypeDescription' + CHAR(13);
		IF @FixedRate IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @FixedRate' + CHAR(13);
		IF @NchelpCd IS NULL OR LEN(@NchelpCd) <> 3 SET @exception_list = @exception_list + 'Invalid or Missing @NchelpCd' + CHAR(13);
		IF @LoanProgramId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @LoanProgramDescription' + CHAR(13);
		IF @TermsId IS NULL	SET @exception_list = @exception_list + 'Invalid or Missing @TermsUrl' + CHAR(13);
		IF @LoanFundingId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @LoanFundingDescription' + CHAR(13);
		IF @InterestRateTypeID IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @InterestRateTypeDescription' + CHAR(13);
		IF @RepaymentOptionCode IS NULL	SET @exception_list = @exception_list + 'Invalid or Missing @RepaymentOptionCode' + CHAR(13);
		IF @DefermentRequestCode IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @DefermentRequestCode' + CHAR(13);
		IF @MinimumAmount IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @MinimumAmount' + CHAR(13);
		IF @BorrowerInterestIndicator IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @BorrowerInterestIndicator' + CHAR(13);
		IF @ServicerId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @ServicerId' + CHAR(13);
		IF @Consolidation IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @Consolidation' + CHAR(13);
		IF @Counteroffer IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @Counteroffer' + CHAR(13);
		IF @JointCosignerCounteroffer IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @JointCosignerCounteroffer' + CHAR(13);
		IF @RequiresUnderwriting IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @RequiresUnderwriting' + CHAR(13);
		IF LEN(@CompassLoanProgram) NOT IN (0, 5, 6) SET @exception_list = @exception_list + 'Invalid or Missing @CompassLoanProgram' + CHAR(13);
		IF @ShareDebtToIncome IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @ShareDebtToIncome' + CHAR(13);
		IF @ShowCostOfLiving IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @ShowCostOfLiving' + CHAR(13);
		IF @RepurposeCLFields IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @RepurposeCLFields' + CHAR(13);
		IF @RepaymentTerm IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @RepaymentTerm' + CHAR(13);
		IF @AlternativeBankruptcyLogic IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @AlternativeBankruptcyLogic' + CHAR(13);
		IF @CertificationRequired IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @CertificationRequired' + CHAR(13);
		IF @SpecialCriteriaId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @SpecialCriteria' + CHAR(13);
		IF @MinimumLoanTermId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @MinimumLoanAmount/@LoanTermBelowMinimumMonths Combination' + CHAR(13);
		IF @IndexCodeId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @IndexCode' + CHAR(13);
		IF @StartDate IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @StartDate' + CHAR(13);
		IF @EndDate IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @EndDate' + CHAR(13);
		IF @GradeLevels IS NULL AND @GradeLevelGroupId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @GradeLevels' + CHAR(13);
		IF @States IS NULL AND @StateGroupId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @States' + CHAR(13);
		IF @SchoolList IS NULL AND @SchoolGroupId IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @SchoolList' + CHAR(13);
		IF @IsCosignerAllowed IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @IsCosignerAllowed' + CHAR(13);
		IF @DocumentTypes IS NULL SET @exception_list = @exception_list + 'Missing @DocumentTypes Parameter' + CHAR(13);
		IF @InterestCapitalizationID IS NULL SET @exception_list = @exception_list + 'Missing @InterestCapitalizationID' + CHAR(13);
        IF @DefaultInterimRepaymentID IS NULL SET @exception_list = @exception_list + 'Missing @DefaultInterimRepaymentID' + CHAR(13);
        IF @InterimRepaymentOptionID IS NULL SET @exception_list = @exception_list + 'Missing @InterimRepaymentOptionID' + CHAR(13);
        IF @GracePeriod  IS NULL SET @exception_list = @exception_list + 'Missing @GracePeriod' + CHAR(13);
        IF @MaxDefermentPeriod IS NULL  SET @exception_list = @exception_list + 'Missing @MaxDefermentPeriod' + CHAR(13);
        IF @LateChargeRate IS NULL  SET @exception_list = @exception_list + 'Missing @LateChargeRate' + CHAR(13);
        IF @LateChargeCap IS NULL  SET @exception_list = @exception_list + 'Missing @LateChargeCap' + CHAR(13);
--        IF @ReturnedCheckRate IS NULL  SET @exception_list = @exception_list + 'Missing @ReturnedCheckRate' + CHAR(13);
--        IF @ReturnedCheckFlat IS NULL  SET @exception_list = @exception_list + 'Missing @ReturnedCheckFlat' + CHAR(13);
--        IF @MinPayment IS NULL  SET @exception_list = @exception_list + 'Missing @MinPayment' + CHAR(13);
        IF @MaxInterestRate IS NULL SET @exception_list = @exception_list + 'Missing @MaxInterestRate' + CHAR(13);
        IF (@ApplicantCreditAgreement_SignableDocName IS NOT NULL AND @ApplicantCreditAgreement_SignableDocID IS NULL) SET @exception_list = @exception_list + 'Invalid or Missing @ApplicantCreditAgreement_SignableDocName' + CHAR(13);
		IF (@CosignerAddendum_SignableDocName IS NOT NULL AND @CosignerAddendum_SignableDocID IS NULL) SET @exception_list = @exception_list + 'Invalid or MIssing @CosignerAddendum_signableDocName'  + CHAR(13);
		IF @ApplicantReferenceCount IS NULL SET @exception_list = @exception_list + 'Invalid or Missing @ApplianceReferenceCount' + CHAR(13);
        
		

	IF @exception_list <> ''
	BEGIN

		PRINT @exception_list
		RETURN

	END
	;

	DECLARE
		  @LoanTypeId int
		, @is_new_grade_level_group bit = 0
		, @is_new_school_group bit = 0
		, @is_new_state_group bit = 0
	;

	SELECT @LoanTypeId = t1.[LoanTypeId] FROM [$(ISLData_dbname)].[dbo].[tbcLoanType] t1 WHERE t1.ShortDescription = @new_loan_type_short_description;

	IF @LoanTypeId IS NULL OR EXISTS (SELECT * FROM [dbo].[tbcLoanType] t1 WHERE t1.LoanTypeId = @LoanTypeId)
	BEGIN

			SELECT @LoanTypeId = MAX(t2.[LoanTypeId])
			FROM (
					SELECT MAX(t1.[LoanTypeId]) + 1 AS [LoanTypeId]
					FROM [dbo].[tbcLoanType] t1

					UNION

					SELECT MAX(t1.[LoanTypeId]) + 1
					FROM [$(ISLData_dbname)].[dbo].[tbcLoanType] t1
				) t2
	END
	;

	IF @Execute = 'Y'
	BEGIN

		SET XACT_ABORT ON; 

		BEGIN TRANSACTION

			IF @GradeLevelGroupId IS NULL
			BEGIN

				SET @is_new_grade_level_group = 1;

				SELECT @GradeLevelGroupId = MAX([GradeLevelGroupId]) + 1
				FROM [dbo].[tbcGradeLevelGroup] t1
				;

				INSERT [dbo].[tbcGradeLevelGroup] ([GradeLevelGroupId], [GradeLevelGroupName])
				SELECT
					  @GradeLevelGroupId AS [GradeLevelGroupId]
					, CONCAT('Grade Level Group', SPACE(1), @GradeLevelGroupId) AS [GradeLevelGroupName]
				;

				INSERT [dbo].[tbcGradeLevelGroupGradeLevelCode] ([GradeLevelGroupId], [GradeLevelCd])
				SELECT
					  @GradeLevelGroupId AS [GradeLevelGroupId]
					, t1.GradeLevelCd
				FROM @tmpGradeLevels t1
				WHERE 1 = 1
				AND t1.Selected = 1
				;
	
			END
			;

			IF @StateGroupId IS NULL
			BEGIN

				SET @is_new_state_group = 1;

				SELECT @StateGroupId = MAX([StateGroupId]) + 1
				FROM [dbo].[tbcStateGroup] t1
				;

				INSERT [dbo].[tbcStateGroup] ([StateGroupId], [StateGroupName])
				SELECT
					  @StateGroupId AS [StateGroupId]
					, CONCAT('State Level Group', SPACE(1), @StateGroupId) AS [StateCodeGroupName]
				;

				INSERT [dbo].[tbcStateGroupStateCode] ([StateGroupId], [StateCode])
				SELECT
					  @StateGroupId AS [StateGroupId]
					, t1.StateCode
				FROM @tmpStateCodes t1
				WHERE 1 = 1
				AND t1.Selected = 1
				;
	
			END

			IF @SchoolGroupId IS NULL
			BEGIN

				SET @is_new_school_group = 1;

				SELECT @SchoolGroupId = MAX([SchoolGroupId]) + 1
				FROM [dbo].[tbcSchoolGroup] t1
				;

				INSERT [dbo].[tbcSchoolGroup] ([SchoolGroupId], [SchoolGroupName])
				SELECT
					  @SchoolGroupId AS [SchoolGroupId]
					, CONCAT('School Group', SPACE(1), @SchoolGroupId) AS [SchoolGroupName]
				;

				INSERT [dbo].[tbcSchoolGroupSchoolID] ([SchoolGroupId], [SchoolID])
				SELECT
					  @SchoolGroupId AS [SchoolGroupId]
					, t2.SchoolID
				FROM @tmpSchools t1
				INNER JOIN [dbo].[tbcSchool] t2 ON t1.DOEID = t2.DOEID
				WHERE 1 = 1
				AND t1.Selected = 1
				;
	
			END

			INSERT [dbo].[tbcLoanType] ([LoanTypeId], [Enabled], [LoanTypeDescription], [ShortDescription], [DetailedDescription], [MarketSegmentId], [CreditTypeId], [FixedRate], [NchelpCd], [LoanProgramId]
									  , [TermsId], [LoanFundingId], [InterestRateTypeID], [RepaymentOptionCode], [BondIssueCode], [DefermentRequestCode], [MinimumAmount], [AnnualMax]
									  , [BorrowerInterestIndicator], [ServicerId], [Consolidation], [Counteroffer], [JointCosignerCounteroffer], [RequiresUnderwriting], [SchoolUseOnly], [SortIndex]
									  , [CompassLoanProgram], [ShareDebtToIncome], [ShowCostOfLiving], [MinTuition], [MaxTuition], [MaxCostOfLiving], [RepurposeCLFields], [RepaymentTerm], [AlternativeBankruptcyLogic]
									  , [CertificationRequired], [GradeLevelGroupId], [StateGroupId], [SchoolGroupId], [SpecialCriteriaId], [MinimumLoanTermId], [ReferenceNotesConfigId], [IndexCodeId], [StartDate]
									  , [EndDate], [Exported], [EntryDate], [AlternativeAppVersion]
                                      , [PrintedApplicationDescription], [MarketSegmentApplicationDisclosureDescription], [InterestCapitalizationID], [DefaultInterimRepaymentID], [GracePeriod], [MaxDefermentPeriod]
                                      , [LateChargeRate], [LateChargeCap], [ReturnedCheckRate], [ReturnedCheckFlat], [MinPayment], [MaxInterestRate], [IsCosignerAllowed]
                                      , [ApplicantCreditAgreementId], [CosignerAddendumId], [ApplicantReferenceCount]
                                      ) 
			SELECT                      
				  @LoanTypeId
				, @Enabled
				, @LoanTypeDescription
				, @new_loan_type_short_description
				, @DetailedDescription
				, @MarketSegmentId
				, @CreditTypeId
				, @FixedRate
				, @NchelpCd
				, @LoanProgramId
				, @TermsId
				, @LoanFundingId
				, @InterestRateTypeID
				, @RepaymentOptionCode
				, @BondIssueCode
				, @DefermentRequestCode
				, @MinimumAmount
				, @AnnualMax
				, @BorrowerInterestIndicator
				, @ServicerId
				, @Consolidation
				, @Counteroffer
				, @JointCosignerCounteroffer
				, @RequiresUnderwriting
				, @SchoolUseOnly
				, @SortIndex
				, @CompassLoanProgram
				, @ShareDebtToIncome
				, @ShowCostOfLiving
				, @MinTuition
				, @MaxTuition
				, @MaxCostOfLiving
				, @RepurposeCLFields
				, @RepaymentTerm
				, @AlternativeBankruptcyLogic
				, @CertificationRequired
				, @GradeLevelGroupId
				, @StateGroupId
				, @SchoolGroupId
				, @SpecialCriteriaId
				, @MinimumLoanTermId
				, @ReferenceNotesConfigId
				, @IndexCodeId
				, @StartDate
				, @EndDate
				, 0 AS [Exported]
				, SYSDATETIME() AS [EntryDate]
				, @AlternativeAppVersion
				, @PrintedApplicationDescription 
				, @MarketSegmentApplicationDisclosureDescription 
				, @InterestCapitalizationID
				, @DefaultInterimRepaymentID
				, @GracePeriod
				, @MaxDefermentPeriod
				, @LateChargeRate
				, @LateChargeCap
				, @ReturnedCheckRate
				, @ReturnedCheckFlat
				, @MinPayment
				, @MaxInterestRate
                , @IsCosignerAllowed
				, @ApplicantCreditAgreement_SignableDocID
				, @CosignerAddendum_SignableDocID
				, @ApplicantReferenceCount                   
    
			;

            INSERT INTO [dbo].[tbcLoanTypeInterimRepaymentOption]
            (LoanTypeID, InterimRepaymentOptionID)
            SELECT LoanTypeID, @InterimRepaymentOptionID
            FROM tbcLoanType where ShortDescription = @new_loan_type_short_description

            INSERT [dbo].[tbcLoanTypeRoleTypeDocumentType] (LoanTypeId, RoleTypeId, DocumentTypeId)
			SELECT
				  t3.LoanTypeId
				, t5.RoleTypeId
				, t2.DocumentTypeId
			FROM string_split(@DocumentTypes,',') t1
			INNER JOIN dbo.tbdDocumentType t2 ON CONVERT(varchar(15), t1.[value]) = t2.DocumentType
			CROSS APPLY (VALUES (@LoanTypeId)) t3 (LoanTypeId)
			CROSS APPLY (
					SELECT t4.RoleTypeId
					FROM [dbo].[tbdRoleType] t4
					WHERE 1 = 1
					AND (
							CASE
								WHEN @IsCosignerAllowed = 1 THEN 1
								ELSE 0
							END = 1
							OR
							CASE
								WHEN @IsCosignerAllowed = 0 THEN t4.RoleType
								ELSE 'INVALID'
							END = 'APPLICANT'
						)
					) t5
			WHERE 1 = 1
			AND NOT EXISTS (
				SELECT *
				FROM [dbo].[tbcLoanTypeRoleTypeDocumentType] t6
				WHERE 1 = 1
				AND t3.[LoanTypeId] = t6.LoanTypeId
				AND t5.RoleTypeId = t6.RoleTypeId
				AND t2.DocumentTypeId = t6.DocumentTypeId
				)

			UNION

			SELECT
				  @LoanTypeId
				, t2.RoleTypeId
				, t3.DocumentTypeId
			FROM (
				VALUES
					(@ParentLoan, 'APPLICANT', 'STUDENT_AUTH')
				) t1 ([ParentLoan], RoleType, DocumentType)
			INNER JOIN [dbo].[tbdRoleType] t2 ON t1.RoleType = t2.RoleType
			INNER JOIN dbo.tbdDocumentType t3 ON t1.DocumentType = t3.DocumentType
			WHERE 1 = 1
			AND t1.ParentLoan = 1
			;

			IF @from_pladds = 1
			BEGIN

				UPDATE t1
				SET t1.[LoanTypeSetupInLTS] = 1
				FROM [PLADDS].[tbdPLADDS_LoanType] t1
				WHERE 1 = 1
				AND t1.[LoanTypeSetupInLTS] = 0
				AND t1.[SetupInLTS] = 0
				AND t1.[ShortDescription] = @new_loan_type_short_description
				;

			END


		COMMIT TRANSACTION

		SET XACT_ABORT OFF; 

	END
	;

	IF @Execute = 'N'
	BEGIN

			IF @GradeLevelGroupId IS NULL
			BEGIN

				SET @is_new_grade_level_group = 1;

				SELECT @GradeLevelGroupId = MAX([GradeLevelGroupId]) + 1
				FROM [dbo].[tbcGradeLevelGroup] t1
				;
	
			END
			;

			IF @StateGroupId IS NULL
			BEGIN

				SET @is_new_state_group = 1;

				SELECT @StateGroupId = MAX([StateGroupId]) + 1
				FROM [dbo].[tbcStateGroup] t1
				;
	
			END


			IF @SchoolGroupId IS NULL
			BEGIN

				SET @is_new_school_group = 1;

				SELECT @SchoolGroupId = MAX([SchoolGroupId]) + 1
				FROM [dbo].[tbcSchoolGroup] t1
				;

			END
			;

			SELECT
				  @LoanTypeId AS LoanTypeId
				, @Enabled AS [Enabled]
				, @LoanTypeDescription AS LoanTypeDescription
				, @new_loan_type_short_description AS [ShortDescription]
				, @DetailedDescription AS [DetailedDescription]
				, @MarketSegmentId AS [MarketSegmentId]
				, @CreditTypeId AS [CreditTypeId]
				, @FixedRate AS [FixedRate]
				, @NchelpCd AS [NchelpCd]
				, @LoanProgramId AS [LoanProgramId]
				, @TermsId AS [TermsId]
				, @LoanFundingId AS [LoanFundingId]
				, @InterestRateTypeID AS [InterestRateTypeID]
				, @RepaymentOptionCode AS [RepaymentOptionCode]
				, @BondIssueCode AS [BondIssueCode]
				, @DefermentRequestCode AS [DefermentRequestCode]
				, @MinimumAmount AS [MinimumAmount]
				, @AnnualMax AS [AnnualMax]
				, @BorrowerInterestIndicator AS [BorrowerInterestIndicator]
				, @ServicerId AS [ServicerId]
				, @Consolidation AS [Consolidation]
				, @Counteroffer AS [Counteroffer]
				, @JointCosignerCounteroffer AS [JointCosignerCounteroffer]
				, @RequiresUnderwriting AS [RequiresUnderwriting]
				, @SchoolUseOnly AS [SchoolUseOnly]
				, @SortIndex AS [SortIndex]
				, @CompassLoanProgram AS [CompassLoanProgram]
				, @ShareDebtToIncome AS [ShareDebtToIncome]
				, @ShowCostOfLiving AS [ShowCostOfLiving]
				, @MinTuition AS [MinTuition]
				, @MaxTuition AS [MaxTuition]
				, @MaxCostOfLiving AS [MaxCostOfLiving]
				, @RepurposeCLFields AS [RepurposeCLFields]
				, @RepaymentTerm AS [RepaymentTerm]
				, @AlternativeBankruptcyLogic AS [AlternativeBankruptcyLogic]
				, @CertificationRequired AS [CertificationRequired]
				, @GradeLevelGroupId AS [GradeLevelGroupId]
				, @is_new_grade_level_group AS IsNewGradeLevelGroup
				, @StateGroupId AS [StateGroupId]
				, @is_new_state_group AS IsNewStateGroup
				, @SchoolGroupId AS [SchoolGroupId]
				, @is_new_school_group AS IsNewSchoolGroup
				, @SpecialCriteriaId AS [SpecialCriteriaId]
				, @MinimumLoanTermId AS [MinimumLoanTermId]
				, @ReferenceNotesConfigId AS [ReferenceNotesConfigId]
				, @IndexCodeId AS [IndexCodeId]
				, @StartDate AS [StartDate]
				, @EndDate AS [EndDate]
				, @AlternativeAppVersion AS [AlternativeAppVersion]
                , @PrintedApplicationDescription                  AS PrintedApplicationDescription                  
				, @MarketSegmentApplicationDisclosureDescription  AS MarketSegmentApplicationDisclosureDescription  
				, @InterestCapitalizationID                       AS InterestCapitalizationID                       
				, @DefaultInterimRepaymentID                      AS DefaultInterimRepaymentID                      
                , @InterimRepaymentOptionID                       AS InterimRepaymentOptionID
				, @GracePeriod                                    AS GracePeriod
				, @MaxDefermentPeriod                             AS MaxDefermentPeriod
				, @LateChargeRate                                 AS LateChargeRate
				, @LateChargeCap                                  AS LateChargeCap
				, @ReturnedCheckRate                              AS ReturnedCheckRate
				, @ReturnedCheckFlat                              AS ReturnedCheckFlate
				, @MinPayment                                     AS MinPayment
				, @MaxInterestRate                                AS MaxInterestRate
                , @ApplicantCreditAgreement_SignableDocID         AS ApplicantCreditAgreement_SignableDocID
                , @CosignerAddendum_SignableDocID                 AS CosignerAddendum_SignableDocID
                , @ApplicantReferenceCount                        AS ApplicantReferenceCount                 
			;

			SELECT
				  t3.LoanTypeId AS tbcLoanTypeRoleTypeDocumentType_LoanTypeId
				, t5.RoleTypeId AS tbcLoanTypeRoleTypeDocumentType_RoleTypeId
				, t2.DocumentTypeId AS tbcLoanTypeRoleTypeDocumentType_DocumentTypeId
			FROM string_split(@DocumentTypes,',') t1
			INNER JOIN dbo.tbdDocumentType t2 ON CONVERT(varchar(15), t1.[value]) = t2.DocumentType
			CROSS APPLY (VALUES (@LoanTypeId)) t3 (LoanTypeId)
			CROSS APPLY (
					SELECT t4.RoleTypeId
					FROM [dbo].[tbdRoleType] t4
					WHERE 1 = 1
					AND (
							CASE
								WHEN @IsCosignerAllowed = 1 THEN 1
								ELSE 0
							END = 1
							OR
							CASE
								WHEN @IsCosignerAllowed = 0 THEN t4.RoleType
								ELSE 'INVALID'
							END = 'APPLICANT'
						)
					) t5
			WHERE 1 = 1
			AND NOT EXISTS (
				SELECT *
				FROM [dbo].[tbcLoanTypeRoleTypeDocumentType] t6
				WHERE 1 = 1
				AND t3.[LoanTypeId] = t6.LoanTypeId
				AND t5.RoleTypeId = t6.RoleTypeId
				AND t2.DocumentTypeId = t6.DocumentTypeId
				)

			UNION

			SELECT
				  @LoanTypeId
				, t2.RoleTypeId
				, t3.DocumentTypeId
			FROM (
				VALUES
					(@ParentLoan, 'APPLICANT', 'STUDENT_AUTH')
				) t1 ([ParentLoan], RoleType, DocumentType)
			INNER JOIN [dbo].[tbdRoleType] t2 ON t1.RoleType = t2.RoleType
			INNER JOIN dbo.tbdDocumentType t3 ON t1.DocumentType = t3.DocumentType
			WHERE 1 = 1
			AND t1.ParentLoan = 1
			;

	END


END
;
GO

/*

EXEC [dbo].[prcCreateLoanType]
	  @Execute = 'N'
	, @model_loan_type_short_description = 'SKtrueHOOdaIO36'
	, @new_loan_type_short_description = 'Test_New_ShortDesc'
	, @LoanTypeDescription = 'Test_New_LTD'
	, @DetailedDescription = 'Test_New_DD'
	, @DefermentRequestCode = 'Y'
    , @IsCosignerAllowed = 1
    , @DocumentTypes = 'OTHER,PAYSTUB'
	, @ApplicantCreditAgreement_SignableDocName = 'hello'
	;

EXEC [dbo].[prcCreateLoanType]
	  @Execute = 'N'
	, @model_loan_type_short_description = 'SKtrueHOOdaIO36'
	, @new_loan_type_short_description = 'SKtrueHOOdaIO36'
	, @LoanTypeDescription = 'Duplicate'
	, @DetailedDescription = 'Duplicate'
	, @DefermentRequestCode = 'Y'
    , @IsCosignerAllowed = 1
    , @DocumentTypes = 'OTHER,PAYSTUB'
    , @ApplicantCreditAgreement_SignableDocName = 'hello'
	;

EXEC [dbo].[prcCreateLoanType]
	  @Execute = 'Y'
	, @model_loan_type_short_description = 'SKtrueHOOdaIO36'
	, @new_loan_type_short_description = 'Test_New_ShortDesc'
	, @LoanTypeDescription = 'Test_New_LTD'
	, @DetailedDescription = 'Test_New_DD'
	, @DefermentRequestCode = 'Y'
    , @IsCosignerAllowed = 1
    , @DocumentTypes = 'OTHER,PAYSTUB'
    , @PrintedApplicationDescription                 = 'PrintedApplicationDescription'
    , @MarketSegmentApplicationDisclosureDescription = 'MarketSegmentApplicationDisclosureDescription'
    , @InterestCapitalizationDescription             = 'InterestCapitalizationDescription'
    , @InterimRepaymentDescription                   = 'InterimRepaymentDescription'
    , @GracePeriod                                   = 100
    , @MaxDefermentPeriod                            = 111
    , @LateChargeRate                                = 99
    , @LateChargeCap                                 = 97
    , @ReturnedCheckRate                             = 96
    , @ReturnedCheckFlat                             = 95
    , @MinPayment                                    = 94
    , @MaxInterestRate                               = 93
    , @ApplicantCreditAgreement_SignableDocName      = 'ApplicantCreditAgreement_SignableDocName'
    , @CosignerAddendum_SignableDocName              = 'CosignerAddendum_SignableDocName'
    , @ApplicantReferenceCount                       = 	7
;

SELECT *
FROM dbo.tbcLoanType t1
WHERE 1 = 1
AND t1.ShortDescription IN ('Test_New_ShortDesc', 'SKtrueHOOdaIO36')
;


SELECT t1.ShortDescription, t3.*, t4.*
FROM dbo.tbcLoanType t1
JOIN dbo.tbcLoanTypeRoleTypeDocumentType t2 on t1.LoanTypeID = t2.LoanTypeID
JOIN dbo.tbdRoleType t3 on t2.RoleTypeID = t3.RoleTypeID
JOIN dbo.tbdDocumentType t4 on t2.DocumentTypeID = t4.DocumentTypeID
WHERE 1 = 1
AND t1.ShortDescription IN ('Test_New_ShortDesc', 'SKtrueHOOdaIO36')



DELETE t2 
FROM dbo.tbcLoanType t1
JOIN dbo.tbcLoanTypeRoleTypeDocumentType t2 on t1.LoanTypeID = t2.LoanTypeID
WHERE 1 = 1
AND t1.ShortDescription = 'Test_New_ShortDesc'

DELETE t1
FROM dbo.tbcLoanType t1
WHERE 1 = 1
AND t1.ShortDescription = 'Test_New_ShortDesc'
;


*/

