/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2017 (14.0.3045)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [EmployerBenefits]
GO

/****** Object:  StoredProcedure [setup].[prcEmployerBenefitsSetups ]    Script Date: 12/20/2018 7:52:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[setup].[prcEmployerBenefitsSetups ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [setup].[prcEmployerBenefitsSetups ] AS' 
END
GO




ALTER PROCEDURE [setup].[prcEmployerBenefitsSetups ]
	  @SetupType varchar(25)	-- Servicer - Provider - Employer - Institution
	, @Name varchar(100)
	, @Code varchar(15)
	, @Address1 varchar(50)
	, @Address2 varchar(50) = ''
	, @Address3 varchar(50) = NULL
	, @City varchar(20)
	, @State char(2)
	, @ZipCode varchar(9)
	, @BenefitDesc varchar(max)	--> comma seperated-> 'Student Loan Contributions,College Savings Contributions'  .. can have multiple benefits (needed for ALL setup types)
	, @PaymantMethodDescription varchar(50) = NULL
	, @MinimumContributionAmt decimal(15,2) = 0.00

--WITH NATIVE_COMPILATION, SCHEMABINDING 
  
AS

BEGIN

SET NOCOUNT ON;

	DECLARE @exception_list varchar(max) = '';
	
		WHILE CHARINDEX(', ', @BenefitDesc) > 0 SET @BenefitDesc = REPLACE(@BenefitDesc, ', ', ',');
		WHILE CHARINDEX(' ,', @BenefitDesc) > 0 SET @BenefitDesc = REPLACE(@BenefitDesc, ' ,', ',');

		IF EXISTS ( SELECT * FROM [dbo].[tbcInstitution] t1
					 WHERE 1 = 1 AND t1.[InstitutionCode] = @Code )
        BEGIN
			SET @exception_list = @exception_list + 'InstitutionCode already exists in the tbcInstitution table.' + CHAR(13);
		END
		;
		IF EXISTS (
				SELECT *
				FROM string_split(@BenefitDesc,',') t1
				WHERE 1 = 1
				AND NOT EXISTS (
					SELECT *
					FROM dbo.tbcBenefit t2
					WHERE 1 = 1
					AND t2.[Description] = CONVERT(varchar(100), t1.[value]) 
					)
				)
		BEGIN
			SET @exception_list = @exception_list + 'Invalid Benefit Description Submitted' + CHAR(13);
		END
		;
		IF @SetupType = '' SET @exception_list = @exception_list + 'Please specify the type of setup (Servicer - Provider - Employer - Institution)' + CHAR(13);
		IF @Name = '' SET @exception_list = @exception_list + '@Name is required' + CHAR(13);
		IF @Code = '' SET @exception_list = @exception_list + '@Code is required' + CHAR(13);
		IF @Address1 = '' SET @exception_list = @exception_list + '@Address1 is required' + CHAR(13);
		IF @City = '' SET @exception_list = @exception_list + '@City is required' + CHAR(13);
		IF @State = '' SET @exception_list = @exception_list + '@State is required' + CHAR(13);
		IF @ZipCode = '' SET @exception_list = @exception_list + '@ZipCode is required' + CHAR(13);
		IF NOT EXISTS (
				SELECT *
				FROM [dbo].[tbdPaymentMethod] pm 
				WHERE 1 = 1
				AND pm.[Description] = @PaymantMethodDescription
				)
		BEGIN
			SET @exception_list = @exception_list + 'Invalid PaymentMethod Submitted' + CHAR(13);
		END
		;
		IF @SetupType not in('Servicer', 'Provider', 'Employer', 'Institution')
			BEGIN
				SET @exception_list = @exception_list + 'Invalid @SetupType.  Valid choices are Servicer, Provider, Employer or Institution' + CHAR(13);
			END
			;


	IF @exception_list <> ''
	BEGIN

		PRINT @exception_list
		RETURN

	END
	;

	BEGIN TRANSACTION

		DECLARE @Instid int;

			-- track the type of setup in the audit table
			INSERT INTO  [setup].[tbtAudit] ( valueadded, userid, modifieddate)
			VALUES ( CONCAT('Setup ' , @Code, ' as ', @SetupType)
						, SUSER_SNAME()
		 				, sysdatetime()	
		 				)


			IF @SetupType IN('Employer','Institution')
				/* For Employer/Institution setup, theInstitutionCode MUST BE IN [dbo].[tbcEmployer] to associate with the tbcEmployerOfferedBenefit table */
				IF NOT EXISTS (SELECT * FROM [dbo].[tbcEmployer] WHERE 1 = 1 AND  [InstitutionCode] = @Code )	
					BEGIN
						INSERT INTO [dbo].[tbcEmployer]([InstitutionCode], [EmployerName])
						SELECT @Code, @Name
			   		     WHERE 1=1
			     		  AND NOT EXISTS (SELECT * FROM [dbo].[tbcEmployer] 
								  		   WHERE 1 = 1
											AND  [InstitutionCode] = @Code
											)
						-- track table insert  
						INSERT INTO  [setup].[tbtAudit] ( valueadded, userid, modifieddate)
						VALUES ( CONCAT('tbcEmployer', ' ...InstitutionName: ', @Name 
													 , ' ...InstitutionCode: ', @Code)
					     		, SUSER_SNAME()
		 			     		, sysdatetime()	
		 			     		)
				    END
				   ;


				IF NOT EXISTS (SELECT * FROM [dbo].[tbcInstitution] WHERE 1 = 1 AND  [InstitutionCode] = @Code )	
					BEGIN		
			  			INSERT INTO [dbo].[tbcInstitution]( [Name], [InstitutionCode])
			  			SELECT @Name, @Code
			   			WHERE 1=1
			     			AND NOT EXISTS (SELECT * FROM [dbo].[tbcInstitution] 
								  			WHERE 1 = 1
												AND  [InstitutionCode] = @Code
												)
					-- track table insert  
						INSERT INTO  [setup].[tbtAudit] ( valueadded, userid, modifieddate)
						VALUES ( CONCAT('tbcInstitution', ' ...InstitutionCode: ', @Code
														, ' ...InstitutionName: ', @Name )
					     		, SUSER_SNAME()
		 			     		, sysdatetime()	
		 			     		)
					END
					;
		  
			    Select @Instid = [InstitutionId] from [dbo].[tbcInstitution] where [InstitutionCode] = @Code
		
			    IF NOT EXISTS (SELECT * FROM [dbo].[tbcInstitutionAddress] WHERE 1 = 1 AND [InstitutionId] = @Instid )	
					BEGIN		
						INSERT INTO [dbo].[tbcInstitutionAddress]( [InstitutionId], [AddressLine1], [AddressLine2], [AddressLine3], [City], [State], [ZipCode])
						SELECT @Instid, @Address1, @Address2, @Address3, @City, @State, @ZipCode
						 WHERE 1=1
						   AND NOT EXISTS (SELECT * FROM [dbo].[tbcInstitutionAddress] 
											WHERE 1 = 1
											  AND  [InstitutionId] = @Instid
												)
						-- track table insert
						INSERT INTO  [setup].[tbtAudit] ( valueadded, userid, modifieddate)
						VALUES ( CONCAT('tbcInstitutionAddress', ' ...InstitutionCode: ', @Code
															   , ' ...InstitutionId: ', @Instid
															   , ' ...AddressLine1: ', @Address1
															   , ' ...AddressLine2: ', @Address2
															   , ' ...AddressLine3: ', @Address3
															   , ' ...City: ', @City
															   , ' ...State: ', @State
															   , ' ...ZipCode: ', @ZipCode)
								 , SUSER_SNAME()
		 						 , sysdatetime()	
		 						 )
					END
					;


		
				WHILE CHARINDEX(', ', @BenefitDesc) > 0 SET @BenefitDesc = REPLACE(@BenefitDesc, ', ', ',');
				WHILE CHARINDEX(' ,', @BenefitDesc) > 0 SET @BenefitDesc = REPLACE(@BenefitDesc, ' ,', ',');

				IF NOT EXISTS (SELECT * FROM [dbo].[tbcPaymentRecipientInstitution] WHERE 1 = 1 AND  [InstitutionId] = @Instid	)
					BEGIN		
						INSERT INTO [dbo].[tbcPaymentRecipientInstitution]( [BenefitId], [InstitutionId], [PaymentMethodId], [MinimumContributionAmt])
						SELECT t2.BenefitId	
							 , @Instid
							 , pm.[PaymentMethodId]
							 , @MinimumContributionAmt
						 FROM string_split(@BenefitDesc,',') t1
  						INNER JOIN [dbo].[tbdPaymentMethod] pm ON pm.[Description] = @PaymantMethodDescription
						INNER JOIN [dbo].[tbcBenefit] t2 ON CONVERT(varchar(100), t1.[value]) = t2.[Description]
						WHERE 1=1
						  AND NOT EXISTS ( SELECT * FROM [dbo].[tbcPaymentRecipientInstitution] 
											WHERE 1 = 1
											  AND  [InstitutionId] = @Instid
											  AND  [BenefitId] = t2.BenefitId
												)
						-- track table insert  
						INSERT INTO  [setup].[tbtAudit] ( valueadded, userid, modifieddate)
						VALUES ( CONCAT('tbcPaymentRecipientInstitution', ' ...BenefitDesc: ', @BenefitDesc
																		, ' ...InstitutionID: ', @Instid
																		, ' ...PaymantMethodDescription: ',  @PaymantMethodDescription
																		, ' ...MinimumContributionAmt: ', @MinimumContributionAmt )
								 , SUSER_SNAME()
		 						 , sysdatetime()	
		 						 )
					END
					;



				WHILE CHARINDEX(', ', @BenefitDesc) > 0 SET @BenefitDesc = REPLACE(@BenefitDesc, ', ', ',');
				WHILE CHARINDEX(' ,', @BenefitDesc) > 0 SET @BenefitDesc = REPLACE(@BenefitDesc, ' ,', ',');

				--IF NOT EXISTS (SELECT * FROM [dbo].[tbcEmployerOfferedBenefit] WHERE 1 = 1 AND  [InstitutionCode] = @Code )
				IF @SetupType IN('Employer','Institution') -- Provider/Servicer should bypass this section...but it is writing to the audit
					BEGIN		
						INSERT INTO [dbo].[tbcEmployerOfferedBenefit]( [InstitutionCode], [BenefitId])
						SELECT @Code, t2.BenefitId
						FROM string_split(@BenefitDesc,',') t1
						INNER JOIN [dbo].[tbcBenefit] t2 ON CONVERT(varchar(100), t1.[value]) = t2.[Description]
						WHERE 1=1
							AND NOT EXISTS (SELECT * FROM [dbo].[tbcEmployerOfferedBenefit] 
											WHERE 1 = 1
												AND  [InstitutionCode] = @Code
												AND  [BenefitId] = t2.BenefitId
											)
						-- track table insert
						INSERT INTO  [setup].[tbtAudit] ( valueadded, userid, modifieddate)
						VALUES ( CONCAT('tbcEmployerOfferedBenefit', ' ...InstitutionCode: ', @Code
																   , ' ...BenefitDescription: ', @BenefitDesc )
									, SUSER_SNAME()
		 							, sysdatetime()	
		 							)
				    END
				;

	COMMIT TRANSACTION

END





/*
TRUNCATE TABLE setup.tbtaudit

--MUST BE IN [dbo].[tbcEmployer] to be added to Institution
-- Good Insert
EXEC [setup].[prcEmployerBenefitsSetups]
	  @SetupType = 'Employer'	-- Servicer - Provider - Employer - Institution
	, @Name = 'Provider Iowa Student Loan-2'
	, @Code =  'Pro_ISLAspire'
	, @Address1 = '6775 Vista Drive'
	, @City = 'West Des Moines'
	, @State = 'IA'
	, @ZipCode = '502669305'
	, @BenefitDesc = 'Student Loan Contributions,College Savings Contributions'		--> correct values
	, @PaymantMethodDescription = 'Single Check'
	;
 select * from setup.tbtaudit order by 1
 select * from [dbo].[tbcInstitution] i join [dbo].[tbcInstitutionAddress] ia ON ia.InstitutionId = i.InstitutionId where name = 'Iowa Student Loan-2'
 select * from [dbo].[tbcPaymentRecipientInstitution] pri join [dbo].[tbcInstitution] i ON i.InstitutionId = pri.InstitutionId where i.name = 'Iowa Student Loan-2'
 select * from [dbo].[tbcEmployerOfferedBenefit] where InstitutionCode = 'ISLAspire-2'	

-- Misspelled Benefit
EXEC [setup].[prcEmployerBenefitsSetups]
	  @SetupType varchar(25)	-- Servicer - Provider - Employer - Institution
	  @Name = 'Iowa Student Loan-3'
	, @Code =  'ISLAspire-3'
	, @Address1 = '6775 Vista Drive'
	, @City = 'West Des Moines'
	, @State = 'IA'
	, @ZipCode = '502669305'
	, @BenefitDesc = 'Student Loam Contributions,College Savings Contributions'		--> misspelled values
	, @PaymantMethodDescription = 'ETF'
	;
 select * from setup.tbtaudit
 select * from [dbo].[tbcInstitution] i join [dbo].[tbcInstitutionAddress] ia ON ia.InstitutionId = i.InstitutionId where name = 'Iowa Student Loan-3'
 select * from [dbo].[tbcPaymentRecipientInstitution] pri join [dbo].[tbcInstitution] i ON i.InstitutionId = pri.InstitutionId where i.name = 'Iowa Student Loan-3'
 select * from [dbo].[tbcEmployerOfferedBenefit] where InstitutionCode = 'ISLAspire-3'	


-- Missing CITY AND MISSPELLING
EXEC [setup].[prcEmployerBenefitsSetups]
	  @SetupType = 'Provider' 	-- Servicer - Provider - Employer - Institution
	, @Name = 'Iowa Student Loan-4'
	, @Code =  'ISLAspire-4'
	, @Address1 = '6775 Vista Drive'
	, @City = ''
	, @State = 'IA'
	, @ZipCode = '502669305'
	, @BenefitDesc = 'Student Loam Contributions,College Savings Contributions'	
	, @PaymantMethodDescription = 'ETF'
	;
 select * from setup.tbtaudit
 select * from [dbo].[tbcInstitution] i join [dbo].[tbcInstitutionAddress] ia ON ia.InstitutionId = i.InstitutionId where name = 'Iowa Student Loan-4'
 select * from [dbo].[tbcPaymentRecipientInstitution] pri join [dbo].[tbcInstitution] i ON i.InstitutionId = pri.InstitutionId where i.name = 'Iowa Student Loan-4'
 select * from [dbo].[tbcEmployerOfferedBenefit] where InstitutionCode = 'ISLAspire-4'	

 select * from setup.tbtaudit
 DELETE from [dbo].[tbcEmployerOfferedBenefit] where InstitutionCode = 'ISLAspire' AND BenefitId = 3	
 DELETE from [dbo].[tbcPaymentRecipientInstitution] where InstitutionId = 159
 DELETE from [dbo].[tbcInstitutionAddress] where InstitutionId = 159
 DELETE from [dbo].[tbcInstitution] where InstitutionCode = 'ISLAspire'
 -- this keeps the 'SERV0006' code in QA testing


*/
GO


