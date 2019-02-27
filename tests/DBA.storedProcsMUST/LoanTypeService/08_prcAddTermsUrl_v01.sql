IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddTermsUrl]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddTermsUrl] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddTermsUrl]
	  @TermsUrl varchar(1000)
	, @from_pladds bit = 0

AS

BEGIN

SET NOCOUNT ON;

	IF @TermsUrl NOT LIKE 'http%'
	BEGIN

		PRINT 'Terms URL Format is Invalid - must start http'
		RETURN

	END
	;
	
	IF EXISTS (SELECT * FROM [dbo].[tbcTerms] t1
				WHERE 1 = 1
				AND t1.[TermsUrl] = @TermsUrl
				)
	BEGIN

		PRINT 'Terms URL Already Exists'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @TermsId smallint

		SELECT @TermsId = MAX(t2.TermsId)
			FROM (
					SELECT MAX(t1.TermsId) + 1 AS TermsId
					FROM [dbo].[tbcTerms] t1
				) t2

		INSERT [dbo].[tbcTerms] ([TermsId], [TermsUrl])
		SELECT
			  @TermsId
			, @TermsUrl
		;

		IF @from_pladds = 1
		BEGIN

			UPDATE t1
			SET t1.[TermsURLSetupInLTS] = 1
			FROM [PLADDS].[tbdPLADDS_LoanType] t1
			WHERE 1 = 1
			AND t1.[TermsURLSetupInLTS] = 0
			AND t1.[SetupInLTS] = 0
			AND t1.[TermsUrl] = @TermsUrl

		END


	COMMIT TRANSACTION


END
	
/*  
EXEC [dbo].[prcAddTermsUrl]
			  @TermsUrl = 'wyncode.skills.fund'
	;

EXEC [dbo].[prcAddTermsUrl]
			  @TermsUrl = 'NEW_TERM_URL'
	;

SELECT *
FROM [dbo].[tbcTerms]
WHERE TermsUrl = 'NEW_TERM_URL'

DELETE [dbo].[tbcTerms]
WHERE TermsUrl = 'NEW_TERM_URL'
*/
	  