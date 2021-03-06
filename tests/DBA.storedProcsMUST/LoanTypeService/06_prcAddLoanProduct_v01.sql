IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddLoanProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddLoanProduct] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddLoanProduct]
	  @LoanProductName varchar(255)

AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcLoanProduct] t1
				WHERE 1 = 1
				AND t1.LoanProductName = @LoanProductName
				)
	BEGIN

		PRINT 'Loan Product Already Exists'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @LoanProductId tinyint

		SELECT @LoanProductId = MAX(t2.LoanProductId)
			FROM (
					SELECT MAX(t1.LoanProductId) + 1 AS LoanProductId
					FROM [dbo].[tbcLoanProduct] t1
				) t2

		INSERT [dbo].[tbcLoanProduct] ([LoanProductId], [LoanProductName])
		SELECT
			  @LoanProductId
			, @LoanProductName
		;


	COMMIT TRANSACTION

END
	
/*  
EXEC [dbo].[prcAddLoanProduct] @LoanProductName = 'ReFi';
EXEC [dbo].[prcAddLoanProduct] @LoanProductName = 'NewProd';

SELECT *
FROM [dbo].[tbcLoanProduct]
WHERE LoanProductName = 'NewProd'

DELETE [dbo].[tbcLoanProduct]
WHERE LoanProductName = 'NewProd';
*/