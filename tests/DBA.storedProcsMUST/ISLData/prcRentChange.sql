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

/****** Object:  StoredProcedure [dbo].[prcRentChange]    Script Date: 12/20/2018 7:50:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prcRentChange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prcRentChange] AS' 
END
GO

ALTER PROCEDURE [dbo].[prcRentChange]
      @loanApplicationID  INT
    , @creditPersonID     INT
    , @OriginalRentAmount INT
    , @NewRentAmount      INT
    , @action             VARCHAR(10)
AS
  BEGIN
    SET NOCOUNT ON;

    DECLARE @UpdateSuccess TINYINT = 0;
    --------------------
    IF EXISTS ( SELECT ca.[LoanApplicationId]
                FROM [tbtCosignerAddendum] ca
                  JOIN [tbtCosigner] c
                    ON ca.[CosignerAddendumID] = c.[CosignerAddendumID]
                WHERE ca.[LoanApplicationId] = @loanApplicationID
                      AND c.[CosignerID] = @CreditPersonID
                UNION ALL
                SELECT a.[LoanApplicationId]
                FROM [tbtApplicant] a
                WHERE a.[LoanApplicationId] = @loanApplicationID
                      AND a.[ApplicantID] = @CreditPersonID
    )
      BEGIN

        --tbtCreditPerson, tbtCreditChar, tbtDebtIncomeRatio
        SELECT 'BEFORE', 'tbtCreditPerson', a.[CreditPersonId], [RentMonthlyPayment]
        FROM [tbtCreditPerson] a
        WHERE [CreditPersonId] = @creditPersonID
        ;

        SELECT 'BEFORE', 'tbtCreditCharacteristic', [CreditCharID], [CharacteristicID], [CharacteristicValue]
        FROM [tbtCreditCharacteristic]
        WHERE [PersonId] = @creditPersonID
              AND [CharacteristicID] = 'M13A'
        ;

        SELECT 'BEFORE', 'tbtDebtIncomeRatio', [DebtIncomeRatioId], [CreditRentPayment]
        FROM [tbtDebtIncomeRatio]
        WHERE [PersonId] = @creditPersonID
        ;
        IF @action = 'Update'
          BEGIN
            DECLARE @role VARCHAR(10);
            SELECT @role = WhoIsIt
            FROM (
                   SELECT 'COS' + CAST([PositionIndex]+1 AS VARCHAR) AS WhoIsIt
                   FROM [tbtCosignerAddendum] ca
                     JOIN [tbtCosigner] c
                       ON ca.[CosignerAddendumID] = c.[CosignerAddendumID]
                   WHERE ca.[LoanApplicationId] = @loanApplicationID
                         AND c.CosignerID = @creditPersonID
                   UNION ALL
                   SELECT 'Applicant' AS WhoIsIt
                   FROM [tbtApplicant] a
                   WHERE a.[LoanApplicationId] = @loanApplicationID
                         AND a.[ApplicantID] = @CreditPersonID
                 ) t1;

            BEGIN TRANSACTION;
            UPDATE [tbtCreditPerson]
            SET [RentMonthlyPayment] = @NewRentAmount
            WHERE [CreditPersonId] = @creditPersonID
                  AND [RentMonthlyPayment] = @OriginalRentAmount;

            SELECT @UpdateSuccess = @UpdateSuccess + @@Rowcount;

            UPDATE [tbtCreditCharacteristic]
            SET [CharacteristicValue] = CAST(@NewRentAmount AS VARCHAR(10))
            WHERE [PersonId] = @creditPersonID
                  AND [CharacteristicID] = 'M13A'
                  AND [CharacteristicValue] = RIGHT('0000000000'+ CAST(@OriginalRentAmount AS VARCHAR(10)), 10);

            SELECT @UpdateSuccess = @UpdateSuccess + @@Rowcount;

            UPDATE [tbtDebtIncomeRatio]
            SET [CreditRentPayment] = @NewRentAmount
            WHERE [PersonID] = @creditPersonID
                  AND [CreditRentPayment] = @OriginalRentAmount;

            SELECT @UpdateSuccess = @UpdateSuccess + @@Rowcount;

            IF @UpdateSuccess = 3
              BEGIN

                INSERT INTO [tbtLoanApplicationHistory]
                ([LoanApplicationId], [HistoryItemType], [EventType], [Text], [UserName], [Role], [CurrentStatus], [CreationDt])
                  SELECT @loanApplicationId, 2, 'MANUAL_COMMENT', 'Rent Change:'+ CAST(@OriginalRentAmount AS VARCHAR) + ' --> ' + CAST(@NewRentAmount AS VARCHAR) + ' for ' + @role, SUSER_SNAME(), NULL, [CurrentStatus], SYSDATETIME()
                  FROM [tbtLoanApplication] WHERE [LoanApplicationId] = @loanApplicationID;

                COMMIT;

                SELECT 'AFTER', 'tbtCreditPerson',a.[CreditPersonId], [RentMonthlyPayment]
                FROM [tbtCreditPerson] a
                WHERE [CreditPersonId] = @creditPersonID
                ;

                SELECT 'AFTER', 'tbtCreditCharacteristic', [CreditCharID], [CharacteristicID], [CharacteristicValue]
                FROM [tbtCreditCharacteristic]
                WHERE [PersonId] = @creditPersonID
                      AND [CharacteristicID] = 'M13A'
                ;

                SELECT 'AFTER', 'tbtDebtIncomeRatio', [DebtIncomeRatioId], [CreditRentPayment]
                FROM [tbtDebtIncomeRatio]
                WHERE [PersonId] = @CreditPersonID
                ;
                SELECT TOP 1 * FROM [tbtLoanApplicationHistory] WHERE [LoanApplicationId] = @loanApplicationID ORDER BY 1 DESC;

              END;
            ELSE
              BEGIN
                ROLLBACK;
                SELECT 'No tables updated.';
              END;
          END;
      END;
    ELSE SELECT 'LoanApplicationID - CreditPersonID mismatch';

  END;


/* For testing purposes
DECLARE @loanApplicationID  INT = 12345
      , @creditPersonID     INT = 223344
      , @OriginalRentAmount int = 111
      , @NewRentAmount      int = 0
      , @action             varchar(10) = 'lookup'   --update or looup
;


    EXEC [dbo].[prcRentChange]
           @loanApplicationID
         , @creditPersonID
         , @OriginalRentAmount
         , @NewRentAmount
         , @action
    ;
*/

GO


