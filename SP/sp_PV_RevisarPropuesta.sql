CREATE OR ALTER PROCEDURE [dbo].[revisarPropuesta]

    @proposalid INT,
    @mensaje NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @currentDateTime DATETIME = GETDATE();
    DECLARE @proposalTypeId INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PV_Proposals WHERE proposalid = @proposalid)
        BEGIN
            SET @mensaje = 'La propuesta especificada no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obtener el tipo de propuesta
        SELECT @proposalTypeId = proposaltypeid 
        FROM PV_Proposals 
        WHERE proposalid = @proposalid;

        -- Consultar tipo de propuesta y sus criterios de validación
        SELECT 
            pt.proposaltypeid,
            pt.typename,
            pt.description,
            pt.enabled,
            pt.createdon
        FROM PV_ProposalTypes pt
        WHERE pt.proposaltypeid = @proposalTypeId;

        -- Extraer criterios de validación para este tipo
        SELECT 
            vc.criterionid,
            vc.proposaltypeid,
            vc.criterionname,
            vc.description,
            vc.validationrule,
            vc.isrequired,
            vc.weight,
            vc.enabled,
            vc.createdon
        FROM PV_ValidationCriteria vc
        WHERE vc.proposaltypeid = @proposalTypeId
          AND vc.enabled = 1
        ORDER BY vc.weight DESC, vc.criterionname;

        SET @mensaje = 'Tipo de propuesta y criterios de validación consultados exitosamente';

    END TRY
    BEGIN CATCH
        SET @mensaje = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END