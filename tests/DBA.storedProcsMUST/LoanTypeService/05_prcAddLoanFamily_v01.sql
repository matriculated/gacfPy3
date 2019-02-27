IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddLoanFamily]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddLoanFamily] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddLoanFamily]
	  @LoanFamilyDescription varchar(40)
	, @AggregateAmountLimit int
	, @AggregateOldLoans bit

AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcLoanFamily] t1
				WHERE 1 = 1
				AND t1.LoanFamilyDescription = @LoanFamilyDescription
				)
	BEGIN

		PRINT 'Loan Family Already Exists'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @LoanFamilyId tinyint

		SELECT @LoanFamilyId = MAX(t2.LoanFamilyId)
			FROM (
					SELECT MAX(t1.LoanFamilyId) + 1 AS LoanFamilyId
					FROM [dbo].[tbcLoanFamily] t1

					UNION

					SELECT MAX(t1.LoanFamilyId) + 1
					FROM [CWDBSQL002.ISLLCNETS.STUDENTLOAN.ORG\CORPPROD,52001].[ISLData].[dbo].[tbcLoanFamily] t1
				) t2

		INSERT [dbo].[tbcLoanFamily] ([LoanFamilyId], [LoanFamilyDescription], [AggregateAmountLimit], [AggregateOldLoans])
		SELECT
			  @LoanFamilyId
			, @LoanFamilyDescription
			, @AggregateAmountLimit
			, @AggregateOldLoans
		;


	COMMIT TRANSACTION


END
	
/*  
EXEC [dbo].[prcAddLoanFamily] @LoanFamilyDescription = 'ASLABC'    , @AggregateAmountLimit = 100000, @AggregateOldLoans = 1;
EXEC [dbo].[prcAddLoanFamily] @LoanFamilyDescription = 'NEW_FAMILY', @AggregateAmountLimit = 100000, @AggregateOldLoans = 1;

SELECT *
FROM [dbo].[tbcLoanFamily]
WHERE LoanFamilyDescription = 'NEW_FAMILY'

DELETE [dbo].[tbcLoanFamily]
WHERE LoanFamilyDescription = 'NEW_FAMILY';
*/