use [VotoPuraVida]
go

select * from PV_Documents;
select * from PV_DocumentTypes;
select * from PV_workflows;
select * from PV_workflowsType;

insert into PV_workflowstype(name) values ('Revision de documentos');
insert into PV_workflows(name, description, endpoint, workflowTypeId, params)
values (
    'Validacion de archivos sobre comentarios',
    'Se enviara a validar cualquier archivo necesario para un comment',
    '/api/validate/comment-document',
    1,
    N'{
        "requiredFields": ["mediafileId" ],
        "validationLevel": "strict",
        "notifyOnFail": true
    }'
);
insert into PV_DocumentTypes (name, description, workflowId) 
values ('Documentos de Comentarios de Propuestas', 'Aca irian todos los documentos que ayudarian a validar los comentarios correspondientes', 1);

GO

CREATE OR ALTER PROCEDURE dbo.SP_CrearDocumentosPorUsuario
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @documentTypeId INT = (SELECT TOP 1 documentTypeId FROM PV_DocumentTypes WHERE name = 'Documentos de Comentarios de Propuestas');
    DECLARE @userId INT;
    DECLARE @aivalidationstatus VARCHAR(20);
    DECLARE @aivalidationresult VARCHAR(50);
    DECLARE @documentid INT;

    DECLARE @Resultados TABLE (
        userid INT,
        documentid INT,
        aivalidationstatus VARCHAR(20),
        aivalidationresult VARCHAR(50)
    );

    DECLARE user_cursor CURSOR FOR
        SELECT userid FROM PV_Users;

    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @userId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (ABS(CHECKSUM(NEWID())) % 10) < 9
        BEGIN
            SET @aivalidationstatus = 'Completado';
            SET @aivalidationresult = 'Validado';
        END
        ELSE
        BEGIN
            SET @aivalidationstatus = 'Completado';
            SET @aivalidationresult = 'No Validado';
        END

        INSERT INTO PV_Documents (
            documenthash,
            aivalidationstatus,
            aivalidationresult,
            humanvalidationrequired,
            mediafileId,
            periodicVerificationId,
            documentTypeId,
            version
        )
        VALUES (
            CAST(NEWID() AS VARBINARY(256)),
            @aivalidationstatus,
            @aivalidationresult,
            0,
            NULL,
            NULL,
            @documentTypeId,
            1
        );

        SET @documentid = SCOPE_IDENTITY();

        INSERT INTO @Resultados VALUES (@userId, @documentid, @aivalidationstatus, @aivalidationresult);

        FETCH NEXT FROM user_cursor INTO @userId;
    END

    CLOSE user_cursor;
    DEALLOCATE user_cursor;

    SELECT * FROM @Resultados;
END
GO

-- Para ejecutar y ver los resultados:
EXEC dbo.SP_CrearDocumentosPorUsuario;
select * from PV_Documents;
select * from PV_Documenttypes;
