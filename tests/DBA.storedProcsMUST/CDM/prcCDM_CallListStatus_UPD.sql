/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2008 R2 (10.50.6220)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2008 R2
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [CampaignDataManager_POD]
GO

/****** Object:  StoredProcedure [dbo].[prcCDM_CallListStatus_UPD]    Script Date: 12/20/2018 7:52:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcCDM_CallListStatus_UPD]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcCDM_CallListStatus_UPD] AS' 
END
GO





/*  procedure will be in both POD and MCS databases */
ALTER PROCEDURE [dbo].[prcCDM_CallListStatus_UPD]
	  @tablename varchar(50) 			--, [POD_PHEAACallList], [POD_RECOVERYCallList], [POD_SITCallList], [POD_SPECIALCallList]
	, @i3rowid varchar(100)				
	, @currentstatus  char(1)				
	, @newststatus char(1)				
	, @action varchar(20)	= 'lookup'  --> lookup or update- default will be lookup
AS
--============================================================
--Server:    CWDBSQL004\TELECOMPROD
--DB:        CampaignDataManager_MCS and CampaignDataManager_POD
--============================================================
--DECLARE 
--      @tablename varchar(50) = 'POD_PHEAACallList'
--	, @i3rowid 	varchar(100) = '002CEC46-4144-4BB0-94FA-8ABEB09451DB' 			
--	, @currentstatus  = 'C'				
--	, @newststatus = 'E'			
--	, @action 	varchar(20) = 'update' 

BEGIN

SET NOCOUNT ON;

	DECLARE @exception_list varchar(max) = ''
		  , @sql varchar(max)
		  , @foundi3rowid int  = 0
	
	    
		IF @tablename = 'POD_PHEAACallList'
		   BEGIN
			 IF @i3rowid in(SELECT [I3_rowid] FROM [dbo].[POD_PHEAACallList] WHERE  I3_rowid = @i3rowid) 
			    SET @foundi3rowid = 1  
		   END
		IF @tablename = 'POD_RECOVERYCallList'
		   BEGIN
			 IF @i3rowid in(SELECT [I3_rowid] FROM [dbo].[POD_RECOVERYCallList] WHERE  I3_rowid = @i3rowid) 
			    SET @foundi3rowid = 1  
		   END
		IF @tablename = 'POD_SITCallList'
		   BEGIN
			 IF @i3rowid in(SELECT [I3_rowid] FROM [dbo].[POD_SITCallList] WHERE  I3_rowid = @i3rowid) 
			    SET @foundi3rowid = 1  
		   END
		IF @tablename = 'POD_SPECIALCallList'
		   BEGIN
			 IF @i3rowid in(SELECT [I3_rowid] FROM [dbo].[POD_SPECIALCallList] WHERE  I3_rowid = @i3rowid) 
			    SET @foundi3rowid = 1  
		   END
		IF @foundi3rowid = 0 SET @exception_list = @exception_list + 'I3_RowID not found in the specified CallList table' + CHAR(13);

		IF @i3rowid   = '' SET @exception_list = @exception_list + 'I3_RowID is required' + CHAR(13);
		IF @tablename = '' SET @exception_list = @exception_list + 'CallList table name is required' + CHAR(13);
		IF @tablename not in('POD_PHEAACallList', 'POD_RECOVERYCallList', 'POD_SITCallList', 'POD_SPECIALCallList')
			BEGIN
				SET @exception_list = @exception_list + 'Invalid @tablename.  Valid choices are POD_PHEAACallList, POD_RECOVERYCallList, POD_SITCallList, POD_SPECIALCallList' + CHAR(13);
			END
			;
--		IF @currentstatus NOT IN (select Status from dbo.tbtApplicant where LoanApplicationId = @LoanApplicationID)
		    --AND @currentstatus NOT IN(select SignatureDt from dbo.tbtApplicant where LoanApplicationId = @LoanApplicationID)
				--SET @exception_list = @exception_list + 'The @currentstatus does not match the current value for the given I3_RowID'  + CHAR(13);
			
		IF @currentstatus not in(SELECT [StatusCd] FROM [dbo].[tbdStatus])
			BEGIN
				SET @exception_list = @exception_list + 'Invalid @currentstatus.  ' + CHAR(13);
			END
			;
		IF @newststatus not in(SELECT [StatusCd] FROM [dbo].[tbdStatus])
			BEGIN
				SET @exception_list = @exception_list + 'Invalid @newststatus.  ' + CHAR(13);
			END
			;
		
	IF @exception_list <> ''
	BEGIN

		PRINT @exception_list
		RETURN

	END
	;
	
--================================================================================================

	--BEGIN TRANSACTION
	   IF @tablename = 'POD_PHEAACallList'
 		   BEGIN
		   	 SELECT 'POD_PHEAACallList-BEFORE', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_PHEAACallList WHERE  I3_rowid = @i3rowid

  		   IF @action = 'update'
  			  BEGIN 
    				BEGIN TRY
  			  	BEGIN TRANSACTION;
  				 	  UPDATE t1 SET [status] = @newststatus FROM dbo.POD_PHEAACallList t1 WHERE  I3_rowid = @i3rowid AND [status] = @currentstatus
  					  IF @@Rowcount = 1
  					  BEGIN        
  					  SELECT 'POD_PHEAACallList-AFTER', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_PHEAACallList WHERE  I3_rowid = @i3rowid
  					  ;
  					  	INSERT INTO  [dbo].[tbtDBAudit] ( valueadded, userid, modifieddate)
  					  	VALUES ( 'dbo.POD_PHEAACallList status set to ''' + @newststatus + '''  for I3_ROWID: ' + @i3rowid 
  					  				, SUSER_SNAME()
  		 			  				, sysdatetime()	
  		 			  				)	
  						END
  						COMMIT TRANSACTION
  						;
  					END TRY
  					BEGIN CATCH
  						SELECT 'Email dbadmin with the following error information:  ' +  DB_NAME()
  								+ '.dbo.prcCDM_CallListStatus_UPD - POD_PHEAACallList->I3_rowid ' + @i3rowid AS 'Error updating CDM Status'
  								, ERROR_MESSAGE() AS ErrorMessage
  								, ERROR_NUMBER() AS ErrorNumber
  								, ERROR_STATE() AS errorState
  						;
  						ROLLBACK TRANSACTION
  						;
  					END CATCH;
  				END;
		 END

	   IF @tablename = 'POD_RECOVERYCallList'
		   BEGIN
		   	 SELECT 'POD_RECOVERYCallList-BEFORE', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_RECOVERYCallList WHERE  I3_rowid = @i3rowid

		  IF (@action = 'update')
			 BEGIN 
  				BEGIN TRY
				BEGIN TRANSACTION;
					UPDATE t1 SET [status] = @newststatus FROM dbo.POD_RECOVERYCallList t1 WHERE  I3_rowid = @i3rowid AND [status] = @currentstatus
					IF @@Rowcount = 1
					BEGIN
					SELECT 'POD_RECOVERYCallList-AFTER', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_RECOVERYCallList WHERE  I3_rowid = @i3rowid
					;
						INSERT INTO  [dbo].[tbtDBAudit] ( valueadded, userid, modifieddate)
						VALUES ( 'dbo.POD_RECOVERYCallList status set to ''' + @newststatus + '''  for I3_ROWID: ' + @i3rowid 
									, SUSER_SNAME()
		 							, sysdatetime()	
		 							)	
						END
						COMMIT TRANSACTION
						;
					END TRY
					BEGIN CATCH
						SELECT 'Email dbadmin with the following error information:  ' +  DB_NAME()
								+ '.dbo.prcCDM_CallListStatus_UPD - POD_RECOVERYCallList->I3_rowid ' + @i3rowid AS 'Error updating CDM Status'
								, ERROR_MESSAGE() AS ErrorMessage
								, ERROR_NUMBER() AS ErrorNumber
								, ERROR_STATE() AS errorState
						;
						ROLLBACK TRANSACTION
						;
					END CATCH;
				END;
		 END

	   IF @tablename = 'POD_SITCallList'
		   BEGIN
		   	 SELECT 'POD_SITCallList-BEFORE', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_SITCallList WHERE  I3_rowid = @i3rowid

		  IF (@action = 'update')
			 BEGIN 
  				BEGIN TRY
				BEGIN TRANSACTION;
					UPDATE t1 SET [status] = @newststatus FROM dbo.POD_SITCallList t1 WHERE  I3_rowid = @i3rowid AND [status] = @currentstatus
					IF @@Rowcount = 1
					BEGIN
					SELECT 'POD_SITCallList-AFTER', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_SITCallList WHERE  I3_rowid = @i3rowid
					;
						INSERT INTO  [dbo].[tbtDBAudit] ( valueadded, userid, modifieddate)
						VALUES ( 'dbo.POD_SITCallList status set to  ''' + @newststatus + '''  for I3_ROWID: ' + @i3rowid 
									, SUSER_SNAME()
		 							, sysdatetime()	
		 							)	
						END
						COMMIT TRANSACTION
						;
					END TRY
					BEGIN CATCH
						SELECT 'Email dbadmin with the following error information:  ' +  DB_NAME()
								+ '.dbo.prcCDM_CallListStatus_UPD - POD_SITCallList->I3_rowid ' + @i3rowid AS 'Error updating CDM Status'
								, ERROR_MESSAGE() AS ErrorMessage
								, ERROR_NUMBER() AS ErrorNumber
								, ERROR_STATE() AS errorState
						;
						ROLLBACK TRANSACTION
						;
					END CATCH;
				END;
		 END

	   IF @tablename = 'POD_SPECIALCallList'
		   BEGIN
		   	 SELECT 'POD_SPECIALCallList-BEFORE', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_SPECIALCallList WHERE  I3_rowid = @i3rowid

		  IF (@action = 'update')
			 BEGIN 
  				BEGIN TRY
				BEGIN TRANSACTION;
					UPDATE t1 SET [status] = @newststatus FROM dbo.POD_SPECIALCallList t1 WHERE  I3_rowid = @i3rowid AND [status] = @currentstatus
					IF @@Rowcount = 1
					BEGIN
					SELECT 'POD_SPECIALCallList-AFTER', I3_RowID, Status, Attempts, CampaignName, AccountNumber FROM dbo.POD_SPECIALCallList WHERE  I3_rowid = @i3rowid
					;
						INSERT INTO  [dbo].[tbtDBAudit] ( valueadded, userid, modifieddate)
						VALUES ( 'dbo.POD_SPECIALCallList status set to ''' + @newststatus + '''  for I3_ROWID: ' + @i3rowid 
									, SUSER_SNAME()
		 							, sysdatetime()	
		 							)	
					END
						COMMIT TRANSACTION
						;
				END TRY
					BEGIN CATCH
						SELECT 'Email dbadmin with the following error information:  ' +  DB_NAME()
								+ '.dbo.prcCDM_CallListStatus_UPD - POD_SPECIALCallList->I3_rowid ' + @i3rowid AS 'Error updating CDM Status'
								, ERROR_MESSAGE() AS ErrorMessage
								, ERROR_NUMBER() AS ErrorNumber
								, ERROR_STATE() AS errorState
						;
						ROLLBACK TRANSACTION
						;
					END CATCH;
		 END;
		END
	END
--	SELECT * FROM [dbo].[tbtDBAudit]

/****************		truncate table [dbo].[tbtDBAudit]
-- these guids are in MCS
-- use test POD_PHEAACallList
EXECUTE [dbo].[prcCDM_CallListStatus_UPD]
      @tablename = 'POD_PHEAACallList'
	, @i3rowid 	= '002CEC46-4144-4BB0-94FA-8ABEB09451DB' 	
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'lookup' 
	SELECT * FROM [dbo].[tbtDBAudit]

EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_PHEAACallList'
	, @i3rowid 	= '002CEC46-4144-4BB0-94FA-8ABEB09451DB' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'update' 
	SELECT * FROM [dbo].[tbtDBAudit]

-- use test POD_RECOVERYCallList
EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_RECOVERYCallList'
	, @i3rowid 	= '04219B5E-992D-4783-909B-60DC2B59EE33' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'lookup' 
	SELECT * FROM [dbo].[tbtDBAudit]

EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_RECOVERYCallList'
	, @i3rowid 	= '04219B5E-992D-4783-909B-60DC2B59EE33' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'update' 
	SELECT * FROM [dbo].[tbtDBAudit]

-- use test POD_SITCallList
EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_SITCallList'
	, @i3rowid 	= '001E70B5-2427-405F-A1EB-5987DEF47BF4' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'lookup' 
	SELECT * FROM [dbo].[tbtDBAudit]

EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_SITCallList'
	, @i3rowid 	= '001E70B5-2427-405F-A1EB-5987DEF47BF4' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'update' 
	SELECT * FROM [dbo].[tbtDBAudit]

-- use test POD_SPECIALCallList
EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_SPECIALCallList'
	, @i3rowid 	= '1576DFAA-134C-43A5-BD14-DD4D15C5C4EA' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'lookup' 
	SELECT * FROM [dbo].[tbtDBAudit]

EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_SPECIALCallList'
	, @i3rowid 	= '1576DFAA-134C-43A5-BD14-DD4D15C5C4EA' 			
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
	, @action 	= 'update' 
	SELECT * FROM [dbo].[tbtDBAudit]


-- FOR TESTING
SELECT TOP 1 I3_RowID, Status, Attempts, CampaignName, AccountNumber  FROM [CampaignDataManager_POD06].[dbo].[POD_PHEAACallList]
SELECT TOP 1 I3_RowID, Status, Attempts, CampaignName, AccountNumber  FROM [CampaignDataManager_POD06].[dbo].[POD_RECOVERYCallList]
SELECT TOP 1 I3_RowID, Status, Attempts, CampaignName, AccountNumber  FROM [CampaignDataManager_POD06].[dbo].[POD_SITCallList]
SELECT TOP 1 I3_RowID, Status, Attempts, CampaignName, AccountNumber  FROM [CampaignDataManager_POD06].[dbo].[POD_SPECIALCallList]

-- RESET THE STATUS
UPDATE a SET Status = 'C' FROM [CampaignDataManager_MCS06].[dbo].[POD_PHEAACallList] a WHERE I3_RowID = '002CEC46-4144-4BB0-94FA-8ABEB09451DB'
UPDATE a SET Status = 'C' FROM [CampaignDataManager_MCS06].[dbo].[POD_RECOVERYCallList] a WHERE I3_RowID = '04219B5E-992D-4783-909B-60DC2B59EE33'
UPDATE a SET Status = 'C' FROM [CampaignDataManager_MCS06].[dbo].[POD_SITCallList] a WHERE I3_RowID = '001E70B5-2427-405F-A1EB-5987DEF47BF4'
UPDATE a SET Status = 'C' FROM [CampaignDataManager_MCS06].[dbo].[POD_SPECIALCallList] a WHERE I3_RowID = '1576DFAA-134C-43A5-BD14-DD4D15C5C4EA'
	TRUNCATE TABLE [dbo].[tbtDBAudit]


-bad rowid
DECLARE @i3rowid_param uniqueidentifier = newid()--COMPLETELY RANDOM GUID

EXECUTE [dbo].[prcCDM_CallListStatus_UPD] 
      @tablename = 'POD_PHEAACallList'
       , @i3rowid    = @i3rowid_param
	, @currentstatus  = 'C'				
	, @newststatus = 'E'			
       , @action     = 'update' 

--SELECT @i3rowid_param
--SELECT *
--FROM [dbo].[tbtDBAudit] t1
--WHERE 1 = 1
--AND t1.valueadded LIKE '%' + CONVERT(varchar(36), @i3rowid_param) + '%'

	****/

GO


