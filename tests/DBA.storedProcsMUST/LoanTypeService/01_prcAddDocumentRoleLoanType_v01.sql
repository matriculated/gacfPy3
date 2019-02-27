IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcAddDocumentRoleLoanType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcAddDocumentRoleLoanType] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcAddDocumentRoleLoanType]
	  @ShortDescription varchar(255)
	, @RoleType varchar(15)
	, @DocumentType varchar(15)

AS

BEGIN

SET NOCOUNT ON;

	DECLARE
		  @LoanTypeId int
		, @RoleTypeId tinyint
		, @DocumentTypeId tinyint
	;
	
	SELECT @LoanTypeId = t1.LoanTypeId FROM [dbo].[tbcLoanType] t1 WHERE t1.ShortDescription = @ShortDescription;
	SELECT @RoleTypeId = t1.RoleTypeId FROM [dbo].[tbdRoleType] t1 WHERE t1.RoleType = @RoleType;
	SELECT @DocumentTypeId = t1.DocumentTypeId FROM [dbo].[tbdDocumentType] t1 WHERE t1.DocumentType = @DocumentType;

	DECLARE @exception_list varchar(max) = '';
	
		IF @LoanTypeId IS NULL SET @exception_list = @exception_list + 'Loan Type Does Not Exist' + CHAR(13);
		IF @RoleTypeId IS NULL SET @exception_list = @exception_list + 'Role Type Does Not Exist' + CHAR(13);
		IF @DocumentTypeId IS NULL SET @exception_list = @exception_list + 'Document Type Does Not Exist' + CHAR(13);

	IF @exception_list <> ''
	BEGIN

		PRINT @exception_list
		RETURN

	END
	;

	IF EXISTS (SELECT * FROM [dbo].[tbcLoanTypeRoleTypeDocumentType] WHERE 1 = 1
					AND [LoanTypeId] = @LoanTypeId
					AND [RoleTypeId] = @RoleTypeId
					AND [DocumentTypeId] = @DocumentTypeId			
				)
	BEGIN

		PRINT 'Loan Type, Role Type, Document Type Combination Already Exists'
		RETURN

	END
	;

	BEGIN TRANSACTION

		INSERT [dbo].[tbcLoanTypeRoleTypeDocumentType] ([LoanTypeId], [RoleTypeId], [DocumentTypeId])
		VALUES (@LoanTypeId, @RoleTypeId, @DocumentTypeId)
		;

	COMMIT TRANSACTION


END
	  