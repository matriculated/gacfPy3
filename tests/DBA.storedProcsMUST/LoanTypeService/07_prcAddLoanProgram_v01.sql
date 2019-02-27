IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddLoanProgram]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddLoanProgram] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddLoanProgram]
	  @LoanFamilyDescription varchar(40)
	, @LoanProgramDescription varchar(100)
	, @AggregateAmountLimit int
	, @AnnualLimit int

AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcLoanProgram] t1
				WHERE 1 = 1
				AND t1.[LoanProgramDescription] = @LoanProgramDescription
				)
	BEGIN

		PRINT 'Loan Program Already Exists'
		RETURN

	END
	;

	DECLARE @exception_list varchar(max) = '';

	DECLARE @LoanFamilyId tinyint;

	SELECT @LoanFamilyId = t1.[LoanFamilyId]
	FROM [dbo].[tbcLoanFamily] t1
	WHERE 1 = 1
	AND t1.LoanFamilyDescription = @LoanFamilyDescription
	;

	IF @LoanFamilyId IS NULL
	BEGIN

		SET @exception_list = @exception_list + 'Loan Family Does not Exists' + CHAR(13);

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
			  @LoanProgramId smallint

		SELECT @LoanProgramId = MAX(t2.LoanProgramId)
			FROM (
					SELECT MAX(t1.LoanProgramId) + 1 AS LoanProgramId
					FROM [dbo].[tbcLoanProgram] t1

					UNION

					SELECT MAX(t1.LoanProgramId) + 1
					FROM [CWDBSQL002.ISLLCNETS.STUDENTLOAN.ORG\CORPPROD,52001].[ISLData].[dbo].[tbcLoanProgram] t1
				) t2

		INSERT [dbo].[tbcLoanProgram] ([LoanProgramId], [LoanFamilyId], [LoanProgramDescription], [AggregateAmountLimit], [AnnualLimit])
		SELECT
			  @LoanProgramId
			, @LoanFamilyId
			, @LoanProgramDescription
			, @AggregateAmountLimit
			, @AnnualLimit
		;


	COMMIT TRANSACTION


END
	
/*  
EXEC [dbo].[prcAddLoanProgram]
			  @LoanFamilyDescription = 'ISL'
			, @LoanProgramDescription = 'ISL'
			, @AggregateAmountLimit = 10000
			, @AnnualLimit = 10000
	;

EXEC [dbo].[prcAddLoanProgram]
			  @LoanFamilyDescription = 'ISL'
			, @LoanProgramDescription = 'NEW_LP'
			, @AggregateAmountLimit = 10000
			, @AnnualLimit = 10000
	;

SELECT *
FROM [dbo].[tbcLoanProgram]
WHERE LoanProgramDescription = 'NEW_LP'

DELETE [dbo].[tbcLoanProgram]
WHERE LoanProgramDescription = 'NEW_LP'
*/
	  