IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddCreditType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddCreditType] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddCreditType]
	  @CreditTypeDescription varchar(20)

AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbdCreditType] t1
				WHERE 1 = 1
				AND t1.CreditTypeDescription = @CreditTypeDescription
				)
	BEGIN

		PRINT 'Credit Type Already Exists'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @CreditTypeId tinyint

		SELECT @CreditTypeId = MAX(t2.CreditTypeId)
			FROM (
					SELECT MAX(t1.CreditTypeId) + 1 AS CreditTypeId
					FROM [dbo].[tbdCreditType] t1
				) t2

		INSERT [dbo].[tbdCreditType] ([CreditTypeId], [CreditTypeDescription])
		SELECT
			  @CreditTypeId
			, @CreditTypeDescription
		;


	COMMIT TRANSACTION


END
	
/*  
EXEC [dbo].[prcAddCreditType] @CreditTypeDescription = 'CREDIT_WORTHY';
EXEC [dbo].[prcAddCreditType] @CreditTypeDescription = 'NEW_TYPE';

SELECT *
FROM [dbo].[tbdCreditType]
WHERE CreditTypeDescription = 'NEW_TYPE'

DELETE [dbo].[tbdCreditType]
WHERE CreditTypeDescription = 'NEW_TYPE';
*/