USE $(LoanTypeService_dbname)
GO

CREATE OR ALTER PROCEDURE [dbo].[prcAddMarketSegment]
	  @MarketSegmentName varchar(100)
	, @MarketSegmentCode varchar(10)
	, @LenderCode varchar(8)
	, @RequireResponsibleBorrowing bit
	, @ReferralEligible bit
	, @PersonalLoan bit
	, @EmployerCode varchar(15) = ''
	, @ParentLoan bit
	, @AddOnOriginationFee bit
	, @BootCampProgram bit
	, @SelfCertEligible bit
	, @CollectApplicantJobTitle bit
	, @CollectCosignerJobTitle bit
	, @LoanProductName varchar(255) = NULL
	, @TaxInfoId tinyint = NULL
	, @Consolidation bit
	, @from_pladds bit = 0
	, @CreditMatrixCode varchar(100)
	, @FederalLoanEligible bit 
	, @InSchoolPeriodMonths tinyint 
	, @InSchoolPeriodMonthsOffset tinyint 
	, @DefaultDisbursementDay tinyint 
	, @DefaultDisbursementMonth tinyint 
AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcMarketSegment] t1 WHERE 1 = 1
				AND t1.MarketSegmentCode = @MarketSegmentCode
				AND t1.LenderCode = @LenderCode
				)
	BEGIN

		PRINT 'Market Segment Code, Lender Code Combination Already Exists'
		RETURN

	END
	;

	DECLARE @exception_list varchar(max) = '';

	DECLARE @LoanProductId tinyint;

	IF @LoanProductName IS NOT NULL
	BEGIN

		SELECT @LoanProductId = t1.LoanProductId
		FROM [dbo].[tbcLoanProduct] t1
		WHERE 1 = 1
		AND t1.LoanProductName = @LoanProductName

	END

	IF @LoanProductName IS NULL
	BEGIN

		SELECT @LoanProductId = t1.LoanProductId
		FROM [dbo].[tbcLoanProduct] t1
		WHERE 1 = 1
		AND t1.LoanProductName = CASE
                                     WHEN @PersonalLoan		= 1 THEN 'Consumer'
                                     WHEN @ParentLoan		= 1 THEN 'Parent'
                                     WHEN @Consolidation	= 1 THEN 'ReFi'
                                     ELSE 'InSchool'
                                 END

	END

	IF @LoanProductName IS NOT NULL AND @LoanProductId IS NULL
	BEGIN

		SET @exception_list = @exception_list + 'Loan Product Does not Exists' + CHAR(13);

	END
	;

	IF @TaxInfoId IS NOT NULL
		AND NOT EXISTS (
				SELECT * FROM [dbo].tbdTaxInfo t1
				WHERE 1 = 1
				AND t1.TaxInfoId = @TaxInfoId
				)
	BEGIN

		SET @exception_list = @exception_list + 'Tax Info Id Does not Exists' + CHAR(13);

	END
	;

    IF @CreditMatrixCode NOT IN (          SELECT 'OLDCREDS' 
                                 UNION ALL SELECT 'PQSOFTDEF'
                                )
	BEGIN

		SET @exception_list = @exception_list + 'CreditMatrixCode is invalid.' + CHAR(13);

	END
	;
 
	IF @exception_list <> ''
	BEGIN

		PRINT @exception_list
		RETURN

	END
	;	

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @MarketSegmentId smallint

		SELECT @MarketSegmentId = MAX(t2.MarketSegmentId)
			FROM (
					SELECT MAX(t1.MarketSegmentId) + 1 AS MarketSegmentId
					FROM [dbo].[tbcMarketSegment] t1

					UNION

					SELECT MAX(t1.MarketSegmentId) + 1
					FROM [$(ISLData_dbname)].[dbo].[tbcMarketSegment] t1
				) t2

		INSERT [dbo].[tbcMarketSegment] ([MarketSegmentId], [MarketSegmentName], [MarketSegmentCode], [LenderCode], [RequireResponsibleBorrowing], [ReferralEligible], [PersonalLoan], [EmployerCode], [ParentLoan]
											, [AddOnOriginationFee], [BootCampProgram], [SelfCertEligible], [CollectApplicantJobTitle], [CollectCosignerJobTitle], [LoanProductId], [TaxInfoId]
                                            , [CreditMatrixCode], [FederalLoanEligible], [InSchoolPeriodMonths], [InSchoolPeriodMonthsOffset], [DefaultDisbursementDay], [DefaultDisbursementMonth]                                             
                                            )
		SELECT
			  @MarketSegmentId
			, @MarketSegmentName
			, @MarketSegmentCode
			, @LenderCode
			, @RequireResponsibleBorrowing
			, @ReferralEligible
			, @PersonalLoan
			, @EmployerCode
			, @ParentLoan
			, @AddOnOriginationFee
			, @BootCampProgram
			, @SelfCertEligible
			, @CollectApplicantJobTitle
			, @CollectCosignerJobTitle
			, @LoanProductId
			, @TaxInfoId
            , @CreditMatrixCode
            , @FederalLoanEligible 
            , @InSchoolPeriodMonths 
            , @InSchoolPeriodMonthsOffset
            , @DefaultDisbursementDay    
            , @DefaultDisbursementMonth  
		;

		IF @from_pladds = 1
		BEGIN

			UPDATE t1
			SET t1.[MarketSegmentSetupInLTS] = 1
			FROM [PLADDS].[tbdPLADDS_LoanType] t1
			WHERE 1 = 1
			AND t1.[MarketSegmentSetupInLTS] = 0
			AND t1.[SetupInLTS] = 0
			AND t1.[MarketSegmentCode] = @MarketSegmentCode
			AND t1.[LenderDoeId] = @LenderCode

		END


	COMMIT TRANSACTION


END

/*  
EXEC [dbo].[prcAddMarketSegment]
	  @MarketSegmentName = 'Invalid Loan Product'
	, @MarketSegmentCode = '555555'
	, @LenderCode = '555555'
	, @RequireResponsibleBorrowing = 1
	, @ReferralEligible = 1
	, @PersonalLoan = 1
	, @EmployerCode = ''
	, @ParentLoan = 1
	, @AddOnOriginationFee = 1
	, @BootCampProgram = 1
	, @SelfCertEligible = 1
	, @CollectApplicantJobTitle = 1
	, @CollectCosignerJobTitle = 1
	, @LoanProductName = 'Inv LP'
	, @TaxInfoId = NULL
	, @Consolidation = 1
	, @from_pladds = 0
    , @CreditMatrixCode = 'OLDCREDS'
    , @FederalLoanEligible = NULL
    , @InSchoolPeriodMonths = NULL
    , @InSchoolPeriodMonthsOffset = NULL
    , @DefaultDisbursementDay = NULL
    , @DefaultDisbursementMonth = NULL
	;

EXEC [dbo].[prcAddMarketSegment]
	  @MarketSegmentName = 'Duplicate'
	, @MarketSegmentCode = '827825'
	, @LenderCode = '827825'
	, @RequireResponsibleBorrowing = 1
	, @ReferralEligible = 1
	, @PersonalLoan = 1
	, @EmployerCode = ''
	, @ParentLoan = 1
	, @AddOnOriginationFee = 1
	, @BootCampProgram = 1
	, @SelfCertEligible = 1
	, @CollectApplicantJobTitle = 1
	, @CollectCosignerJobTitle = 1
	, @LoanProductName = NULL
	, @TaxInfoId = NULL
	, @Consolidation = 0
	, @from_pladds = 0
    , @CreditMatrixCode = 'OLDCREDS'
    , @FederalLoanEligible = 1
    , @InSchoolPeriodMonths = 12
    , @InSchoolPeriodMonthsOffset  = 2
    , @DefaultDisbursementDay = 4
    , @DefaultDisbursementMonth =12
	;
	
EXEC [dbo].[prcAddMarketSegment]
	  @MarketSegmentName = 'Invalid Credit Matrix'
	, @MarketSegmentCode = '999999'
	, @LenderCode = '999999'
	, @RequireResponsibleBorrowing = 1
	, @ReferralEligible = 1
	, @PersonalLoan = 1
	, @EmployerCode = ''
	, @ParentLoan = 1
	, @AddOnOriginationFee = 1
	, @BootCampProgram = 1
	, @SelfCertEligible = 1
	, @CollectApplicantJobTitle = 1
	, @CollectCosignerJobTitle = 1
	, @LoanProductName = NULL
	, @TaxInfoId = NULL
	, @Consolidation = 1
	, @from_pladds = 0
    , @CreditMatrixCode = 'x'
    , @FederalLoanEligible = 1
    , @InSchoolPeriodMonths = 12
    , @InSchoolPeriodMonthsOffset  = 2
    , @DefaultDisbursementDay = 4
    , @DefaultDisbursementMonth =12	;
    ;

EXEC [dbo].[prcAddMarketSegment]
	  @MarketSegmentName = 'New MS'
	, @MarketSegmentCode = '999999'
	, @LenderCode = '999999'
	, @RequireResponsibleBorrowing = 1
	, @ReferralEligible = 1
	, @PersonalLoan = 0
	, @EmployerCode = ''
	, @ParentLoan = 0
	, @AddOnOriginationFee = 1
	, @BootCampProgram = 0
	, @SelfCertEligible = 1
	, @CollectApplicantJobTitle = 1
	, @CollectCosignerJobTitle = 1
	, @LoanProductName = NULL
	, @TaxInfoId = NULL
	, @Consolidation = 1
	, @from_pladds = 0
    , @CreditMatrixCode = 'OLDCREDS'
    , @FederalLoanEligible = 1
    , @InSchoolPeriodMonths = 12
    , @InSchoolPeriodMonthsOffset  = 2
    , @DefaultDisbursementDay = 4
    , @DefaultDisbursementMonth =12
	;


SELECT *
FROM [dbo].[tbcMarketSegment]
WHERE MarketSegmentCode = '999999' AND LenderCode = '999999'

SELECT * FROM tbcLoanProduct

DELETE [dbo].[tbcMarketSegment]
WHERE MarketSegmentCode = '999999' AND LenderCode = '999999'
*/
	
GO


