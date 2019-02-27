/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2017 (14.0.3045)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [ISLData]
GO

/****** Object:  StoredProcedure [dbo].[prcLoanInformation_upd]    Script Date: 12/20/2018 7:51:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcLoanInformation_upd]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcLoanInformation_upd] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcLoanInformation_upd]
      @loanApplicationID      BIGINT
    , @old_RequestedAmount    INT
    , @new_RequestedAmount    INT
    , @old_AuthorizedAmount   INT
    , @new_AuthorizedAmount   INT
    , @old_CostofLivingAmount DECIMAL(8,2)
    , @new_CostofLivingAmount DECIMAL(8,2)
    , @old_TuitionAmount      DECIMAL(8,2)
    , @new_TuitionAmount      DECIMAL(8,2)
    , @action                 VARCHAR(8)


AS
  BEGIN
    SET NOCOUNT ON;

    SELECT 'BEFORE', * FROM [tbtLoanInformation] WHERE [LoanApplicationId] = @loanApplicationID
    ;

    IF (@action = 'update')
      BEGIN
        IF (@new_RequestedAmount IS NULL AND @new_AuthorizedAmount IS NULL AND @new_CostofLivingAmount IS NULL AND @new_TuitionAmount IS NULL)
          BEGIN
            SELECT 'No new amounts listed.  No changes were made.';
          END;
        ELSE
          BEGIN

            DECLARE @historyDetail VARCHAR(1000)
            , @old_EscrowAmount DECIMAL(8,2);

            SELECT @historyDetail =
                   CASE WHEN @old_requestedAmount IS NULL THEN ''
                   ELSE ' RequestedAmount From '     + COALESCE(CAST(@old_RequestedAmount  AS VARCHAR(10)), 'NULL') + ' TO ' + COALESCE(CAST(@new_RequestedAmount     AS VARCHAR(10)),'NULL') + ';'
                   END
                   + CASE WHEN @old_AuthorizedAmount IS NULL THEN ''
                     ELSE 'AuthorizedAmount from '   + COALESCE(CAST(@old_AuthorizedAmount   AS VARCHAR(10)), 'NULL') + ' TO ' + COALESCE(CAST(@new_AuthorizedAmount    AS VARCHAR(10)),'NULL') + ';'
                     END
                   + CASE WHEN @old_CostofLivingAmount IS NULL THEN ''
                     ELSE 'CostOfLivingAmount from ' + COALESCE(CAST(@old_CostofLivingAmount AS VARCHAR(10)), 'NULL') + ' TO ' + COALESCE(CAST(@new_CostofLivingAmount  AS VARCHAR(10)),'NULL') + ';'
                     END
                   + CASE WHEN @old_TuitionAmount IS NULL THEN ''
                     ELSE 'TuitionAmount from '      + COALESCE(CAST(@old_TuitionAmount      AS VARCHAR(10)), 'NULL') + ' TO ' + COALESCE(CAST(@new_TuitionAmount       AS VARCHAR(10)),'NULL') + ';'
                     END
            ;
            SELECT @old_EscrowAmount = [EscrowAmount] FROM [tbtLoanInformation] WHERE [LoanApplicationId] = @loanApplicationID;

            BEGIN TRY
            BEGIN TRANSACTION;
            UPDATE [tbtLoanInformation]
            SET [RequestedAmt] = CASE WHEN @new_RequestedAmount IS NULL THEN [RequestedAmt]
                                 ELSE @new_RequestedAmount
                                 END
              , [AuthorizedAmount] = CASE WHEN @new_AuthorizedAmount IS NULL THEN [AuthorizedAmount]
                                     ELSE @new_AuthorizedAmount
                                     END
              , [CostOfLivingAmount] = CASE WHEN @new_CostofLivingAmount IS NULL THEN [CostOfLivingAmount]
                                       ELSE @new_CostofLivingAmount
                                       END
              , [TuitionAmount] = CASE WHEN @new_TuitionAmount IS NULL THEN [TuitionAmount]
                                  ELSE @new_TuitionAmount
                                  END
              , [EscrowAmount] = CASE WHEN COALESCE([EscrowAmount],0) > 0 AND @new_AuthorizedAmount IS NOT NULL THEN ([EscrowPercent] * @new_AuthorizedAmount)/100.0
                                 ELSE [EscrowAmount]
                                 END
            WHERE 1=1
                  AND [LoanApplicationId] = @loanApplicationID
                  AND [RequestedAmt] = CASE WHEN @new_RequestedAmount IS NOT NULL THEN @old_RequestedAmount
                                       ELSE [RequestedAmt]
                                       END
                  AND [AuthorizedAmount] = CASE WHEN @new_AuthorizedAmount IS NOT NULL THEN @old_AuthorizedAmount
                                           ELSE [AuthorizedAmount]
                                           END
                  AND [CostOfLivingAmount] = CASE WHEN @new_CostOfLivingAmount IS NOT NULL THEN @old_CostofLivingAmount
                                             ELSE [CostOfLivingAmount]
                                             END
                  AND [TuitionAmount] = CASE WHEN @new_TuitionAmount IS NOT NULL THEN @old_TuitionAmount
                                        ELSE [TuitionAmount]
                                        END

            IF @@rowcount = 1
              BEGIN
                SELECT @HistoryDetail =   @historyDetail
                                          + CASE WHEN @new_AuthorizedAmount IS NOT NULL AND COALESCE([EscrowPercent],0) > 0 THEN 'EscrowAmount from ' + CAST(@old_EscrowAmount AS VARCHAR(10)) + ' TO ' + CAST(([EscrowAmount]) AS VARCHAR(10))
                                            ELSE ''
                                            END
                FROM [tbtLoanInformation]
                WHERE [LoanApplicationId] = @loanApplicationID;

                INSERT INTO [tbtLoanApplicationHistory]
                ([LoanApplicationId], [HistoryItemType], [EventType], [Text], [UserName], [Role], [CurrentStatus], [CreationDt])
                  SELECT @LoanApplicationID, 2, 'MANUAL_COMMENT', 'Update tbtLoanInformation: ' + @historyDetail , suser_sname(), NULL, [CurrentStatus], SYSDATETIME()
                  FROM [tbtLoanApplication]
                  WHERE [LoanApplicationId] = @loanApplicationID
                ;
              END;
            COMMIT TRANSACTION
            ;

            SELECT 'AFTER', *   FROM [tbtLoanInformation] WHERE [LoanApplicationId] = @loanApplicationID
            ;

            END TRY
            BEGIN CATCH
            SELECT 'Email dbadmin with the following error information:  '
                   + 'dbo.prcLoanInformation_upd - Loan App ID ' + CAST(@loanApplicationID AS VARCHAR(10)) AS 'Error updating tbtLoanInformation'
              , ERROR_MESSAGE() AS ErrorMessage
              , ERROR_NUMBER() AS ErrorNumber
              , ERROR_STATE() AS errorState
            ;
            ROLLBACK TRANSACTION
            ;
            END CATCH;
          END;
      END;


      ;

    /* For testing purposes
    DECLARE
        @loanApplicationID   BIGINT = 85415        --Required
      , @old_RequestedAmount    INT = NULL
      , @new_RequestedAmount    INT = NULL

      , @old_AuthorizedAmount   INT = NULL
      , @new_AuthorizedAmount   INT = NULL

      , @old_CostofLivingAmount INT = NULL
      , @new_CostofLivingAmount INT = NULL

      , @old_TuitionAmount      INT = NULL
      , @new_TuitionAmount      INT = NULL


      , @actionCode      varchar(8) =  'update'

        EXEC dbo.prcLoanInformation_UPD
            @loanApplicationID
          , @old_RequestedAmount
          , @new_RequestedAmount
          , @old_AuthorizedAmount
          , @new_AuthorizedAmount
          , @old_CostofLivingAmount
          , @new_CostofLivingAmount
          , @old_TuitionAmount
          , @new_TuitionAmount
          , @actionCode
    ;
    select * from tbtloanapplicationhistory where loanapplicationid = @loanapplicationid order by creationdt desc

    */


  END;


GO


