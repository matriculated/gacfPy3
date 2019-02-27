IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddSpecialCriteria]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddSpecialCriteria] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddSpecialCriteria]
	  @SpecialCriteria varchar(20)
	, @SpecialCriteriaDescription varchar(100)

AS

BEGIN

SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM [dbo].[tbcSpecialCriteria] t1
				WHERE 1 = 1
				AND t1.[SpecialCriteria] = @SpecialCriteria
				)
	BEGIN

		PRINT 'Special Criteria Already Exists'
		RETURN

	END
	;

	SET XACT_ABORT ON; 

	BEGIN TRANSACTION

		DECLARE
			  @SpecialCriteriaId smallint

		SELECT @SpecialCriteriaId = MAX(t2.SpecialCriteriaId)
			FROM (
					SELECT MAX(t1.SpecialCriteriaId) + 1 AS SpecialCriteriaId
					FROM [dbo].[tbcSpecialCriteria] t1
				) t2

		INSERT [dbo].[tbcSpecialCriteria] ([SpecialCriteriaId], [SpecialCriteria], [SpecialCriteriaDescription])
		SELECT
			  @SpecialCriteriaId
			, @SpecialCriteria
			, @SpecialCriteriaDescription
		;


	COMMIT TRANSACTION


END
	
/*  
EXEC [dbo].[prcAddSpecialCriteria]
			  @SpecialCriteria = 'NONE'
			, @SpecialCriteriaDescription = 'DUPLICATE'
	;

EXEC [dbo].[prcAddSpecialCriteria]
			  @SpecialCriteria = 'NEW_SC'
			, @SpecialCriteriaDescription = 'NEW_SC'
	;

SELECT *
FROM [dbo].[tbcSpecialCriteria]
WHERE SpecialCriteria = 'NEW_SC'

DELETE [dbo].[tbcSpecialCriteria]
WHERE SpecialCriteria = 'NEW_SC'
*/
	  