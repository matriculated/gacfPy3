IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddMinimumLoanTerm]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddMinimumLoanTerm] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddMinimumLoanTerm]
	  @MinimumLoanAmount varchar(20)
	, @LoanTermBelowMinimumMonths smallint

AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcMinimumLoanTerm] t1
				WHERE 1 = 1
				AND t1.[MinimumLoanAmount] = @MinimumLoanAmount
				AND t1.[LoanTermBelowMinimumMonths] = @LoanTermBelowMinimumMonths
				)
	BEGIN

		PRINT 'Minimum Loan Term Already Exists'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @MinimumLoanTermId smallint

		SELECT @MinimumLoanTermId = MAX(t2.MinimumLoanTermId)
			FROM (
					SELECT MAX(t1.MinimumLoanTermId) + 1 AS MinimumLoanTermId
					FROM [dbo].[tbcMinimumLoanTerm] t1

					UNION

					SELECT MAX(t2.MinimumLoanTermId) + 1
					FROM [CWDBSQL002.ISLLCNETS.STUDENTLOAN.ORG\CORPPROD,52001].[ISLData].[dms].[tbcMinimumLoanTerm] t2
				) t2

		INSERT [dbo].[tbcMinimumLoanTerm] ([MinimumLoanTermId], [MinimumLoanAmount], [LoanTermBelowMinimumMonths])
		SELECT
			  @MinimumLoanTermId
			, @MinimumLoanAmount
			, @LoanTermBelowMinimumMonths
		;


	COMMIT TRANSACTION


END
	
/*  
EXEC [dbo].[prcAddMinimumLoanTerm]
			  @MinimumLoanAmount = 1000
			, @LoanTermBelowMinimumMonths = 37
	;

EXEC [dbo].[prcAddMinimumLoanTerm]
			  @MinimumLoanAmount = 1000
			, @LoanTermBelowMinimumMonths = 38
	;

SELECT *
FROM [dbo].[tbcMinimumLoanTerm]
WHERE MinimumLoanAmount = 1000
AND [LoanTermBelowMinimumMonths] = 38

DELETE [dbo].[tbcMinimumLoanTerm]
WHERE MinimumLoanAmount = 1000
AND [LoanTermBelowMinimumMonths] = 38
*/
	  