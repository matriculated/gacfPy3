USE $(LoanTypeService_dbname)
GO

CREATE OR ALTER PROCEDURE [dbo].[prcAddPriceTier]
	  @ShortDescription varchar(255)
	, @SortOrder tinyint
	, @OriginationFeePercent numeric(5, 2)
	, @InterestRate numeric(6, 3)
	, @MinimumFicoScore smallint
	, @MinimumAnnualIncome int
	, @MortgageModel numeric(5, 2)
	, @NonMortgageModel numeric(5, 2)
	, @LenderNonEdBranchId char(2)
	, @PriceTierCd varchar(3) = ''
	, @JobCategoryName varchar(20) = NULL
    , @GuaranteeFee numeric(5,2)
	, @OverrideDuplicateWarning char(1) = 'N'
	, @from_pladds bit = 0

AS

BEGIN

SET NOCOUNT ON;

	DECLARE
		  @LoanTypeId int
		, @PriceTierId int
		, @JobCategoryId tinyint
	;

	SELECT @LoanTypeId = t1.LoanTypeId FROM [dbo].[tbcLoanType] t1 WHERE t1.ShortDescription = @ShortDescription;

	IF @JobCategoryName IS NOT NULL
	BEGIN

		SELECT @JobCategoryId = t1.[JobCategoryId]
		FROM [dbo].[tbdJobCategory] t1
		WHERE 1 = 1
		AND t1.[JobCategoryName] = @JobCategoryName
		;

	END
	;

	DECLARE @exception_list varchar(max) = '';
	
		IF @LoanTypeId IS NULL SET @exception_list = @exception_list + 'Loan Type Does Not Exist' + CHAR(13);
		IF @JobCategoryName IS NOT NULL AND @JobCategoryId IS NULL SET @exception_list = @exception_list + 'Invalid/Missing @JobCategoryName' + CHAR(13);

	IF @OverrideDuplicateWarning = 'N'
		AND EXISTS (
							SELECT *
							FROM [dbo].[tbcPriceTier] t1
							WHERE 1 = 1
							AND t1.[SortOrder] <> @SortOrder
							AND t1.[OriginationFeePercent] = @OriginationFeePercent
							AND t1.[InterestRate] = @InterestRate
							AND t1.[MinimumFicoScore] = @MinimumFicoScore
							AND t1.[MinimumAnnualIncome] = @MinimumAnnualIncome
							AND t1.[MortgageModel] = @MortgageModel
							AND t1.[NonMortgageModel] = @NonMortgageModel
							AND t1.[LenderNonEdBranchId] = @LenderNonEdBranchId
							AND t1.[PriceTierCd] = TRIM(@PriceTierCd)
							AND COALESCE(t1.[JobCategoryId], 0) = COALESCE(@JobCategoryId, 0)
                            AND GuaranteeFee = @GuaranteeFee
					)
	BEGIN

		SET @exception_list = @exception_list + 'Duplicate Price Tier Exists with Only SortOrder Difference.  Run Procedure With @OverrideDuplicateWarning = ''Y'' to Ignore' + CHAR(13);

	END
	;

	IF @exception_list <> ''
	BEGIN

		PRINT @exception_list
		RETURN

	END
	;

	SELECT @PriceTierId = t1.[PriceTierId]
	FROM [dbo].[tbcPriceTier] t1
	WHERE 1 = 1
	AND t1.[SortOrder] = @SortOrder
	AND t1.[OriginationFeePercent] = @OriginationFeePercent
	AND t1.[InterestRate] = @InterestRate
	AND t1.[MinimumFicoScore] = @MinimumFicoScore
	AND t1.[MinimumAnnualIncome] = @MinimumAnnualIncome
	AND t1.[MortgageModel] = @MortgageModel
	AND t1.[NonMortgageModel] = @NonMortgageModel
	AND t1.[LenderNonEdBranchId] = @LenderNonEdBranchId
	AND t1.[PriceTierCd] = @PriceTierCd
	AND COALESCE(t1.[JobCategoryId], 0) = COALESCE(@JobCategoryId, 0)
    AND GuaranteeFee = @GuaranteeFee
	;

	IF EXISTS (SELECT * FROM [dbo].[tbcLoanTypePriceTier] t1 WHERE t1.[LoanTypeId] = @LoanTypeId AND t1.[PriceTierId] = @PriceTierId)
	BEGIN

		PRINT 'Price Tier Already Linked to Loan Type'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		IF @PriceTierId IS NULL
		BEGIN

			SELECT @PriceTierId = MAX(t2.[PriceTierId])
			FROM (
					SELECT MAX(t1.[PriceTierId]) + 1 AS [PriceTierId]
					FROM [dbo].[tbcPriceTier] t1

					UNION

					SELECT MAX(t1.[PriceTierId]) + 1
					FROM [$(ISLData_dbname)].[dbo].[tbcPriceTier] t1
				) t2

			INSERT [dbo].[tbcPriceTier] ([PriceTierId], [SortOrder], [OriginationFeePercent], [InterestRate], [MinimumFicoScore], [MinimumAnnualIncome], [MortgageModel],
										 [NonMortgageModel], [LenderNonEdBranchId], [PriceTierCd], [JobCategoryId], [GuaranteeFee]
										 )
			SELECT
				  @PriceTierId
				, @SortOrder
				, @OriginationFeePercent
				, @InterestRate
				, @MinimumFicoScore
				, @MinimumAnnualIncome
				, @MortgageModel
				, @NonMortgageModel
				, @LenderNonEdBranchId
				, @PriceTierCd
				, @JobCategoryId
                , @GuaranteeFee

		END
		;

		INSERT [dbo].[tbcLoanTypePriceTier] ([LoanTypeId], [PriceTierId])
		SELECT
			  @LoanTypeId
			, @PriceTierId

		IF @from_pladds = 1
		BEGIN

			UPDATE t1
			SET t1.[InitialPriceTierSetupInLTS] = 1
			FROM [PLADDS].[tbdPLADDS_LoanType] t1
			WHERE 1 = 1
			AND @SortOrder = 0
			AND t1.[InitialPriceTierSetupInLTS] = 0
			AND t1.[SetupInLTS] = 0
			AND t1.[ShortDescription] = @ShortDescription
			AND t1.[OriginationFeePercent] = @OriginationFeePercent
			AND t1.[BaseRate] = @InterestRate
			AND t1.[MinimumFicoScore] = @MinimumFicoScore
			AND t1.[MinimumAnnualIncome] = @MinimumAnnualIncome
			AND t1.[MortgageModel] = @MortgageModel
			AND t1.[NonMortgageModel] = @NonMortgageModel
			AND t1.[LenderNonEdBranchId] = @LenderNonEdBranchId
			AND t1.[PriceTierCd] = @PriceTierCd
			AND COALESCE(t1.[JobCategoryId], 0) = COALESCE(@JobCategoryId, 0)
            AND t1.GuaranteeFee = @GuaranteeFee
			;

			UPDATE t1
			SET t1.[SetupInLTS] = 1
			FROM [PLADDS].[tbdPLADDS_PriceTier] t1
			WHERE 1 = 1
			AND t1.[SortOrder] = @SortOrder
			AND t1.[SetupInLTS] = 0
			AND t1.[ShortDescription] = @ShortDescription
			AND t1.[OriginationFeePercent] = @OriginationFeePercent
			AND t1.[InterestRate] = @InterestRate
			AND t1.[MinimumFicoScore] = @MinimumFicoScore
			AND t1.[MinimumAnnualIncome] = @MinimumAnnualIncome
			AND t1.[MortgageModel] = @MortgageModel
			AND t1.[NonMortgageModel] = @NonMortgageModel
			AND t1.[LenderNonEdBranchId] = @LenderNonEdBranchId
			AND t1.[PriceTierCd] = @PriceTierCd
			AND COALESCE(t1.[JobCategoryId], 0) = COALESCE(@JobCategoryId, 0)
            AND t1.GuaranteeFee = @GuaranteeFee
			;

		END

	COMMIT TRANSACTION


END
;
GO