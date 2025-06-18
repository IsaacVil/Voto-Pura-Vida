CREATE PROCEDURE [dbo].[SP_Dashboard]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el usuario esté activo y verificado
    IF NOT EXISTS (
        SELECT 1
        FROM PV_Users u
        INNER JOIN PV_UserStatus us ON u.userStatusId = us.userStatusId
        WHERE u.userid = @UserId AND us.active = 1 AND us.verified = 1
    )
    BEGIN
        RAISERROR('El usuario no está activo y verificado.', 16, 1);
        RETURN;
    END

    -- Validar que tenga el permiso 9 que es el de ver votaciones
    IF NOT EXISTS (
        SELECT 1
        FROM PV_UserPermissions up
        WHERE up.userid = @UserId AND up.permissionid = 9 AND up.enabled = 1 AND up.deleted = 0
    )
    BEGIN
        RAISERROR('El usuario no tiene el permiso requerido.', 16, 1);
        RETURN;
    END

    -- votaciones recientes con segmentación dinámica, o sea que dependen de los segmentos asociados
    SELECT
        vc.votingconfigid,
        p.proposalid,
        p.title AS Propuesta,
        qt.name AS TipoPropuesta,
        q.question AS Pregunta,
        vo.optionid,
        vo.optiontext AS Opcion,
        vr.votecount AS Votos,
        ISNULL(ps.name, 'General') AS Segmento,
        ISNULL(vts.segmentid, 0) AS SegmentId,
        COUNT(DISTINCT u.userid) AS VotantesPorSegmento,
        vc.enddate
    INTO #TopVotingDetails
    FROM PV_VotingConfigurations vc
    INNER JOIN PV_Proposals p ON vc.proposalid = p.proposalid
    INNER JOIN PV_ProposalTypes qt ON p.proposaltypeid = qt.proposaltypeid
    INNER JOIN PV_VotingOptions vo ON vo.votingconfigid = vc.votingconfigid
    INNER JOIN PV_VotingQuestions q ON vo.questionId = q.questionId
    LEFT JOIN PV_VoteResults vr ON vr.optionid = vo.optionid
    LEFT JOIN PV_VotingTargetSegments vts ON vts.votingconfigid = vc.votingconfigid
    LEFT JOIN PV_PopulationSegments ps ON vts.segmentid = ps.segmentid
    LEFT JOIN PV_Votes v ON v.votingconfigid = vc.votingconfigid AND v.publicResult = vo.optiontext
    LEFT JOIN PV_UserSegments us ON us.userid = v.userId AND (vts.segmentid IS NULL OR us.segmentid = vts.segmentid)
    LEFT JOIN PV_Users u ON v.userId = u.userid
    WHERE vc.enddate IS NOT NULL
    GROUP BY vc.votingconfigid, p.proposalid, p.title, qt.name, q.question, vo.optionid, vo.optiontext, vr.votecount, ps.name, vts.segmentid, vc.enddate
    ORDER BY vc.enddate DESC;

    -- solo los 5 más recientes usando tabla temporal
    SELECT TOP 5 proposalid, enddate
    INTO #TopVotings
    FROM #TopVotingDetails
    GROUP BY proposalid, enddate
    ORDER BY enddate DESC;

    -- Mostrar el detalle de las votaciones (solo las top 5)
    SELECT *
    FROM #TopVotingDetails
    WHERE proposalid IN (SELECT proposalid FROM #TopVotings)
    ORDER BY enddate DESC;

    -- ver solo proposals que salieron en el primer SELECT pero si tienen inversiones
    SELECT
        p.proposalid,
        p.title AS Propuesta,
        ISNULL(p.budget, 0) AS MontoSolicitado,
        ISNULL((SELECT SUM(i.amount) FROM PV_Investments i WHERE i.proposalid = p.proposalid), 0) AS MontoInvertido,
        ISNULL((
            SELECT SUM(is2.amount)
            FROM PV_InvestmentAgreements ia
            INNER JOIN PV_investmentSteps is2 ON ia.agreementId = is2.investmentAgreementId
            WHERE ia.proposalid = p.proposalid
        ), 0) AS MontoEjecutado
    FROM PV_Proposals p
    WHERE p.proposalid IN (SELECT proposalid FROM #TopVotings);

    DROP TABLE #TopVotingDetails;
    DROP TABLE #TopVotings;
END;
GO

EXEC [dbo].[SP_Dashboard] @UserId = 1;

DROP PROCEDURE IF EXISTS [dbo].[SP_Dashboard];


/*
ahora si, asumamos que ese sp sirve, ahora procede:

bueno obvio ponerlo en flyway y asi aja

en powerbi me conecto al ssms y escojo consulta avanzada

pongo el exec del sp pero hacer tipo un input para el userid


*/